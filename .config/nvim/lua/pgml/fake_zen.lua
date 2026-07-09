--- Fake ZEN

local function get_win_var(win, name)
	local ok, val = pcall(vim.api.nvim_win_get_var, win, name)
	return ok and val or nil
end

local function set_win_width(win, width)
	vim.api.nvim_win_call(win, function()
		vim.cmd("vertical resize " .. width)
	end)
end

local function goto_center()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if get_win_var(win, "is_zen_center") then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
end

local function apply_padding_style(win)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	--vim.wo[win].signcolumn = "no"
	--vim.wo[win].foldcolumn = "0"
	--vim.wo[win].statuscolumn = ""
end

local function is_zen_active()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if get_win_var(win, "is_zen_center") then
			return true
		end
	end
	return false
end

local function zen_repair()
	local center_width = 92

	if vim.o.columns < center_width then
		return
	end

	vim.o.equalalways = false

	local remaining = vim.o.columns - center_width - 2 -- 2 separators
	local pad_width = math.max(1, math.floor(remaining / 2))

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if get_win_var(win, "is_zen_padding") then
			set_win_width(win, pad_width)
			apply_padding_style(win)
		end
	end

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if get_win_var(win, "is_zen_center") then
			set_win_width(win, center_width)
		end
	end

	vim.cmd("highlight WinSeparator guifg=#43434c")
end
vim.api.nvim_create_user_command("ZenRepair", zen_repair, {})

vim.api.nvim_create_user_command("ZenDebug", function()
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local lines = { "columns=" .. vim.o.columns, "wins:" }
	for _, win in ipairs(wins) do
		local center = get_win_var(win, "is_zen_center")
		local pad = get_win_var(win, "is_zen_padding")
		local w = vim.api.nvim_win_get_width(win)
		table.insert(lines, string.format("  win=%d width=%d center=%s padding=%s", win, w, tostring(center), tostring(pad)))
	end
	vim.notify(table.concat(lines, "\n"))
end, {})

vim.api.nvim_create_user_command("PadReset", function()
	local buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
	vim.api.nvim_win_set_buf(0, buf)

	goto_center()
	zen_repair()

	vim.cmd("highlight WinSeparator guifg=#43434c");
end, {})

vim.api.nvim_create_user_command("ZenFake", function()
	if is_zen_active() then
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_win_is_valid(win) then
				if get_win_var(win, "is_zen_padding") then
					vim.api.nvim_win_close(win, true)
				elseif get_win_var(win, "is_zen_center") then
					vim.api.nvim_win_del_var(win, "is_zen_center")
				end
			end
		end
		return
	end

	vim.cmd("PadReset")

	vim.cmd("vsplit")
	vim.cmd("wincmd l")
	vim.api.nvim_win_set_var(0, "is_zen_padding", true)
	vim.cmd("set norelativenumber")
	vim.cmd("set nonumber")

	vim.cmd("wincmd h")

	vim.cmd("vsplit")
	vim.api.nvim_win_set_var(0, "is_zen_padding", true)
	vim.cmd("set norelativenumber")
	vim.cmd("set nonumber")

	vim.cmd("wincmd l")

	vim.api.nvim_win_set_var(0, "is_zen_center", true)

	vim.cmd("highlight WinSeparator guifg=#43434c");
	vim.cmd("ZenRepair")
end, {})

vim.api.nvim_create_autocmd("WinClosed", {
	callback = function(args)
		local win = tonumber(args.match)
		if not win then return end

		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype

		if ft == "undotree" then
			vim.schedule(function()
				vim.cmd("ZenRepair")
			end)
		end
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		if is_zen_active() then
			vim.schedule(function()
				zen_repair()
			end)
		end
	end,
})

vim.keymap.set("n", "<leader>zz", "<cmd>ZenFake<CR>")
vim.keymap.set("n", "<leader>r", "<cmd>PadReset<CR>")
vim.keymap.set("n", "<leader>zr", "<cmd>ZenRepair<CR>")
