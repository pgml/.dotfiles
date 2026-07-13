local M = {}

local defaults = {
	hide_separators_on_start = false,
	open_on_new_tab = false,
	open_on_start = false,
	width = 92,
	separator_color = "#43434c",
	keymaps = {
		toggle = "<leader>zz",
		reset = "<leader>r",
		repair = "<leader>zr",
		hide_separators = "<leader>hl",
	},
}

local state = {
	equalalways = nil,
	keymaps = {},
	separators_hidden = false,
}

M.config = vim.deepcopy(defaults)

--- Read a window-local marker without failing if the window is invalid.
---@param win integer
---@param name string
---@return any
local function get_win_var(win, name)
	local ok, value = pcall(vim.api.nvim_win_get_var, win, name)
	return ok and value or nil
end

--- Return all windows with a particular FakeZen marker in a tab.
---@param tab integer
---@param marker string
---@return integer[]
local function marked_windows(tab, marker)
	local windows = {}

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
		if get_win_var(win, marker) then
			table.insert(windows, win)
		end
	end

	return windows
end

--- Check whether FakeZen is enabled for a tab, even if its center window vanished.
---@param tab integer
---@return boolean
local function is_enabled(tab)
	local ok, value = pcall(vim.api.nvim_tabpage_get_var, tab, "pgml_fake_zen_enabled")
	return ok and value == true
end

--- Check whether a tab displays a terminal buffer.
---@param tab integer
---@return boolean
local function has_terminal_buffer(tab)
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
			return true
		end
	end

	return false
end

--- Resolve the highlight used as Normal in the current window.
---@return string
local function current_normal_highlight()
	for item in vim.wo.winhighlight:gmatch("[^,]+") do
		local from, to = item:match("^([^:]+):(.+)$")
		if from == "Normal" then
			return to
		end
	end

	return "Normal"
end

--- Apply either the configured separator color or the current background.
local function apply_separator_highlight()
	if not state.separators_hidden then
		if M.config.separator_color then
			vim.api.nvim_set_hl(0, "WinSeparator", { fg = M.config.separator_color })
		end
		return
	end

	local normal = vim.api.nvim_get_hl(0, {
		name = current_normal_highlight(),
		link = false,
	})

	if normal.bg then
		vim.api.nvim_set_hl(0, "WinSeparator", { fg = normal.bg, bg = normal.bg })
	else
		-- A transparent Normal highlight has no concrete background color.
		vim.api.nvim_set_hl(0, "WinSeparator", { fg = "NONE", bg = "NONE" })
	end
end

--- Create an unlisted scratch buffer that disappears when no longer displayed.
---@return integer
local function create_padding_buffer()
	return vim.api.nvim_create_buf(false, true)
end

--- Make the empty buffer created by :tabnew disappear once a file replaces it.
---@param buf integer
local function make_center_placeholder(buf)
	if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].buftype ~= "" or vim.bo[buf].modified then
		return
	end

	if vim.api.nvim_buf_line_count(buf) ~= 1 or vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= "" then
		return
	end

	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buflisted = false
	vim.bo[buf].swapfile = false
	vim.api.nvim_buf_set_var(buf, "is_fake_zen_placeholder", true)
end

--- Turn a named FakeZen placeholder back into a normal file buffer.
---@param buf integer
local function restore_placeholder_buffer(buf)
	local ok = pcall(vim.api.nvim_buf_get_var, buf, "is_fake_zen_placeholder")
	if not ok or vim.api.nvim_buf_get_name(buf) == "" then
		return
	end

	vim.bo[buf].bufhidden = ""
	vim.bo[buf].buflisted = true
	pcall(vim.api.nvim_buf_del_var, buf, "is_fake_zen_placeholder")
end

--- Remove visual editor UI from a padding window.
---@param win integer
local function style_padding_window(win)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].foldcolumn = "0"
	vim.wo[win].statuscolumn = ""
end

--- Create one padding window beside the center window.
---@param center integer
---@param side "left"|"right"
---@return integer
local function create_padding_window(center, side)
	vim.api.nvim_set_current_win(center)
	vim.cmd(side == "left" and "leftabove vsplit" or "rightbelow vsplit")

	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, create_padding_buffer())
	-- :split copies window variables from the center window.
	pcall(vim.api.nvim_win_del_var, win, "is_fake_zen_center")
	vim.api.nvim_win_set_var(win, "is_fake_zen_padding", true)
	vim.api.nvim_win_set_var(win, "fake_zen_padding_side", side)
	style_padding_window(win)

	return win
end

local infer_padding_side

--- Recreate the center window if another plugin deleted it with its buffer.
---@param tab integer
---@return integer?
local function ensure_center_window(tab)
	local centers = marked_windows(tab, "is_fake_zen_center")
	if #centers > 0 then
		return centers[1]
	end

	local paddings = marked_windows(tab, "is_fake_zen_padding")
	if #paddings == 0 then
		return nil
	end

	local anchor = paddings[1]
	local side = get_win_var(anchor, "fake_zen_padding_side") or "left"
	vim.api.nvim_set_current_win(anchor)
	vim.cmd(side == "left" and "rightbelow vsplit" or "leftabove vsplit")

	local center = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(center, create_padding_buffer())
	-- This split originates from a padding window, so discard its markers.
	pcall(vim.api.nvim_win_del_var, center, "is_fake_zen_padding")
	pcall(vim.api.nvim_win_del_var, center, "fake_zen_padding_side")
	vim.api.nvim_win_set_var(center, "is_fake_zen_center", true)
	vim.api.nvim_set_current_win(center)

	return center
end

--- Infer which side of the center an older unlabelled padding window occupies.
---@param win integer
---@param center integer
---@return "left"|"right"
infer_padding_side = function(win, center)
	local side = get_win_var(win, "fake_zen_padding_side")
	if side == "left" or side == "right" then
		return side
	end

	local win_column = vim.api.nvim_win_get_position(win)[2]
	local center_column = vim.api.nvim_win_get_position(center)[2]
	return win_column < center_column and "left" or "right"
end

--- Ensure an active FakeZen tab still has one scratch padding window on each side.
---@param tab integer
local function ensure_padding_windows(tab)
	if tab ~= vim.api.nvim_get_current_tabpage() then
		return
	end

	local center = ensure_center_window(tab)
	if not center then
		return
	end

	local sides = {}

	for _, win in ipairs(marked_windows(tab, "is_fake_zen_padding")) do
		local side = infer_padding_side(win, center)
		sides[side] = win
		pcall(vim.api.nvim_win_del_var, win, "is_fake_zen_center")
		vim.api.nvim_win_set_var(win, "fake_zen_padding_side", side)

	end

	local current = vim.api.nvim_get_current_win()

	if not sides.left or not vim.api.nvim_win_is_valid(sides.left) then
		create_padding_window(center, "left")
	end

	if not sides.right or not vim.api.nvim_win_is_valid(sides.right) then
		create_padding_window(center, "right")
	end

	if vim.api.nvim_win_is_valid(current) then
		vim.api.nvim_set_current_win(current)
	elseif vim.api.nvim_win_is_valid(center) then
		vim.api.nvim_set_current_win(center)
	end
end

--- Check whether any tab currently has an active FakeZen layout.
---@return boolean
local function any_fake_zen_active()
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		if M.is_active(tab) then
			return true
		end
	end

	return false
end

--- Check whether a tab contains a FakeZen center window.
---@param tab? integer Defaults to the current tab.
---@return boolean
function M.is_active(tab)
	tab = tab or vim.api.nvim_get_current_tabpage()
	return #marked_windows(tab, "is_fake_zen_center") > 0
end

--- Recalculate the center and padding widths for a tab.
---@param tab? integer Defaults to the current tab.
function M.repair(tab)
	tab = tab or vim.api.nvim_get_current_tabpage()

	if not vim.api.nvim_tabpage_is_valid(tab) or (not M.is_active(tab) and not is_enabled(tab)) then
		return
	end

	ensure_padding_windows(tab)

	local centers = marked_windows(tab, "is_fake_zen_center")
	local paddings = marked_windows(tab, "is_fake_zen_padding")
	local separator_width = #paddings
	local center_width = math.min(M.config.width, math.max(1, vim.o.columns - separator_width - #paddings))
	local available_padding = math.max(2, vim.o.columns - center_width - separator_width)
	local left_padding = math.max(1, math.ceil(available_padding / 2))
	local right_padding = math.max(1, math.floor(available_padding / 2))

	for _, win in ipairs(paddings) do
		if vim.api.nvim_win_is_valid(win) then
			local side = get_win_var(win, "fake_zen_padding_side")
			local width = side == "left" and left_padding or right_padding
			pcall(vim.api.nvim_win_set_width, win, width)
			style_padding_window(win)
		end
	end

	for _, win in ipairs(centers) do
		if vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_set_width, win, center_width)
		end
	end

	apply_separator_highlight()
end

--- Replace both padding buffers and restore their styling and widths.
function M.reset()
	local tab = vim.api.nvim_get_current_tabpage()

	if not M.is_active(tab) then
		return
	end

	for _, win in ipairs(marked_windows(tab, "is_fake_zen_padding")) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_set_buf(win, create_padding_buffer())
			style_padding_window(win)
		end
	end

	M.repair(tab)
end

--- Enable FakeZen in the current tab.
function M.enable()
	local tab = vim.api.nvim_get_current_tabpage()
	if M.is_active(tab) then
		return
	end
	vim.api.nvim_tabpage_set_var(tab, "pgml_fake_zen_enabled", true)

	if state.equalalways == nil then
		state.equalalways = vim.o.equalalways
	end
	vim.o.equalalways = false

	local center = vim.api.nvim_get_current_win()
	local view = vim.fn.winsaveview()
	make_center_placeholder(vim.api.nvim_win_get_buf(center))
	vim.api.nvim_win_set_var(center, "is_fake_zen_center", true)

	create_padding_window(center, "left")
	create_padding_window(center, "right")

	vim.api.nvim_set_current_win(center)
	vim.fn.winrestview(view)
	M.repair(tab)
end

--- Disable FakeZen in the current tab and close its padding windows.
function M.disable()
	local tab = vim.api.nvim_get_current_tabpage()
	local centers = marked_windows(tab, "is_fake_zen_center")

	if #centers == 0 and not is_enabled(tab) then
		pcall(vim.api.nvim_tabpage_del_var, tab, "pgml_fake_zen_enabled")
		return
	end
	pcall(vim.api.nvim_tabpage_del_var, tab, "pgml_fake_zen_enabled")

	for _, win in ipairs(marked_windows(tab, "is_fake_zen_padding")) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	for _, win in ipairs(centers) do
		if vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_del_var, win, "is_fake_zen_center")
		end
	end

	if not any_fake_zen_active() and state.equalalways ~= nil then
		vim.o.equalalways = state.equalalways
		state.equalalways = nil
	end
end

--- Toggle FakeZen in the current tab.
function M.toggle()
	if M.is_active() then
		M.disable()
	else
		M.enable()
	end
end

--- Hide split separators using the active window's background color.
function M.hide_separators()
	state.separators_hidden = true
	apply_separator_highlight()
end

--- Restore the configured visible separator color.
function M.show_separators()
	state.separators_hidden = false
	apply_separator_highlight()
end

--- Toggle split separators between visible and hidden.
function M.toggle_separators()
	if state.separators_hidden then
		M.show_separators()
	else
		M.hide_separators()
	end
end

--- Report FakeZen markers and dimensions for the current tab.
function M.debug()
	local lines = { "columns=" .. vim.o.columns, "wins:" }

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		table.insert(lines, string.format(
			"  win=%d width=%d center=%s padding=%s",
			win,
			vim.api.nvim_win_get_width(win),
			tostring(get_win_var(win, "is_fake_zen_center")),
			tostring(get_win_var(win, "is_fake_zen_padding"))
		))
	end

	vim.notify(table.concat(lines, "\n"))
end

--- Create or replace a user command owned by this module.
---@param name string
---@param callback function
---@param desc string
local function set_command(name, callback, desc)
	pcall(vim.api.nvim_del_user_command, name)
	vim.api.nvim_create_user_command(name, callback, { desc = desc })
end

--- Remove keymaps installed by an earlier setup call.
local function clear_keymaps()
	for _, lhs in ipairs(state.keymaps) do
		pcall(vim.keymap.del, "n", lhs)
	end
	state.keymaps = {}
end

--- Install one optional normal-mode keymap.
---@param lhs? string|false
---@param callback function
---@param desc string
local function set_keymap(lhs, callback, desc)
	if not lhs or lhs == "" then
		return
	end

	vim.keymap.set("n", lhs, callback, { desc = desc })
	table.insert(state.keymaps, lhs)
end

--- Configure and initialize the local FakeZen plugin.
---@param opts? table
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
	state.separators_hidden = M.config.hide_separators_on_start

	for _, name in ipairs({
		"ZenToggle",
		"ZenRepair",
		"ZenReset",
		"ZenDebug",
		"ZenHideSeparators",
		"ZenShowSeparators",
		"ZenToggleSeparators",
		"ZenFake",
		"PadReset",
	}) do
		pcall(vim.api.nvim_del_user_command, name)
	end

	set_command("FakeZenToggle", M.toggle, "Toggle centered FakeZen layout")
	set_command("FakeZenRepair", function()
		M.repair()
	end, "Repair centered FakeZen layout")
	set_command("FakeZenReset", M.reset, "Reset FakeZen padding windows")
	set_command("FakeZenDebug", M.debug, "Show FakeZen layout details")
	set_command("FakeZenHideSeparators", M.hide_separators, "Hide split separators")
	set_command("FakeZenShowSeparators", M.show_separators, "Show split separators")
	set_command("FakeZenToggleSeparators", M.toggle_separators, "Toggle split separators")

	clear_keymaps()
	set_keymap(M.config.keymaps.toggle, M.toggle, "Toggle FakeZen layout")
	set_keymap(M.config.keymaps.reset, M.reset, "Reset FakeZen padding windows")
	set_keymap(M.config.keymaps.repair, M.repair, "Repair FakeZen layout")
	set_keymap(M.config.keymaps.hide_separators, M.toggle_separators, "Toggle split separators")

	local group = vim.api.nvim_create_augroup("pgml-fake-zen", { clear = true })

	vim.api.nvim_create_autocmd({ "WinClosed", "WinNew", "VimResized", "TabEnter" }, {
		group = group,
		callback = function()
			vim.schedule(function()
				for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
					M.repair(tab)
				end
			end)
		end,
	})

	-- Rebuild the center before plugins such as Neogit open their replacement buffer.
	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function()
			local tab = vim.api.nvim_get_current_tabpage()
			if is_enabled(tab) and not M.is_active(tab) then
				M.repair(tab)
				vim.schedule(function()
					if vim.api.nvim_tabpage_is_valid(tab) and is_enabled(tab) then
						M.repair(tab)
					end
				end)
			end
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = apply_separator_highlight,
	})

	vim.api.nvim_create_autocmd("BufFilePost", {
		group = group,
		callback = function(args)
			restore_placeholder_buffer(args.buf)
		end,
	})

	apply_separator_highlight()

	if M.config.open_on_start then
		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			once = true,
			callback = function()
				-- Let startup plugins finish creating their initial window first.
				vim.schedule(function()
					if not M.is_active() then
						M.enable()
					end
				end)
			end,
		})
	end

	if M.config.open_on_new_tab then
		vim.api.nvim_create_autocmd("TabNewEntered", {
			group = group,
			callback = function()
				local tab = vim.api.nvim_get_current_tabpage()

				-- Let commands such as :terminal replace the new tab's buffer first.
				vim.schedule(function()
					if not vim.api.nvim_tabpage_is_valid(tab) or M.is_active(tab) or has_terminal_buffer(tab) then
						return
					end

					local original_win = vim.api.nvim_get_current_win()
					local target_win = vim.api.nvim_tabpage_list_wins(tab)[1]
					vim.api.nvim_set_current_win(target_win)
					M.enable()

					if vim.api.nvim_win_is_valid(original_win) then
						vim.api.nvim_set_current_win(original_win)
					end
				end)
			end,
		})
	end
end

return M
