-- Keep saved files free of trailing whitespace.
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

local listchars_plain = vim.o.listchars
local listchars_dots = listchars_plain:gsub("tab:[^,]*", "tab:··")

vim.keymap.set("n", "<leader>td", function()
	vim.g.tab_dots = not vim.g.tab_dots
	vim.o.listchars = vim.g.tab_dots and listchars_dots or listchars_plain
	vim.cmd.redraw({ bang = true })
end, { desc = "Toggle tabs shown as dots" })
