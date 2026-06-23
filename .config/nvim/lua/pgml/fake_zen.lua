--- Fake ZEN

local function goto_center()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.w[win].is_zen_center then
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

local function zen_repair()
	local padding = vim.o.columns >= 300 and 107 or 68

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.w[win].is_zen_padding then
			vim.api.nvim_win_set_width(win, padding)
			apply_padding_style(win)
		end
	end

	vim.cmd("highlight WinSeparator guifg=#2E3842")
end
vim.api.nvim_create_user_command("ZenRepair", zen_repair, {})

vim.api.nvim_create_user_command("PadReset", function()
	local buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
	vim.api.nvim_win_set_buf(0, buf)

	goto_center()
	zen_repair()

	vim.cmd("highlight WinSeparator guifg=#2E3842");
end, {})

vim.api.nvim_create_user_command("ZenFake", function()
	if vim.w.is_zen_active then
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_win_is_valid(win) then
				if vim.w[win].is_zen_padding then
					vim.api.nvim_win_close(win, true)
				end
			end
		end
		vim.w.is_zen_active = false
		return
	end

	vim.cmd("PadReset")

	vim.cmd("vsplit")
	vim.cmd("wincmd l")
	vim.w.is_zen_padding = true
	vim.cmd("set norelativenumber")
	vim.cmd("set nonumber")

	vim.cmd("wincmd h")

	vim.cmd("vsplit")
	vim.w.is_zen_padding = true
	vim.cmd("set norelativenumber")
	vim.cmd("set nonumber")

	vim.cmd("wincmd l")

	vim.w.is_zen_center = true
	vim.w.is_zen_active = true

	vim.cmd("highlight WinSeparator guifg=#2E3842");
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
