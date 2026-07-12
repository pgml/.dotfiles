vim.keymap.set("n", "<F1>", "noop")
vim.keymap.set("n", "<C-z>", "noop")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste but keeps register" })
vim.keymap.set("n", "<A-q>", vim.cmd.tabprevious)
vim.keymap.set("n", "<A-e>", vim.cmd.tabnext)
vim.keymap.set("t", "<A-q>", vim.cmd.tabprevious)
vim.keymap.set("t", "<A-e>", vim.cmd.tabnext)

vim.keymap.set("n", "<leader>sn", "<cmd>set number<CR><cmd>set relativenumber<CR>");
vim.keymap.set("n", "<leader>hn", "<cmd>set nonumber<CR><cmd>set norelativenumber<CR>");
vim.keymap.set("n", "<leader>l", "<cmd>set list<CR>")
vim.keymap.set("n", "<leader>nl", "<cmd>set nolist<CR>")
vim.keymap.set("n", "<leader>tn", vim.cmd.tabnew);
vim.keymap.set("n", "<leader>w", vim.cmd.tabclose);

vim.keymap.set('t', '<C-esc>', "<C-\\><C-n>")
vim.keymap.set('t', 'jk',    "<C-\\><C-n>")
vim.keymap.set('t', '<C-h>', "<Cmd>wincmd h<CR>")
vim.keymap.set('t', '<C-j>', "<Cmd>wincmd j<CR>")
vim.keymap.set('t', '<C-k>', "<Cmd>wincmd k<CR>")
vim.keymap.set('t', '<C-l>', "<Cmd>wincmd l<CR>")
vim.keymap.set('t', '<C-w>', "<C-\\><C-n><C-w>")

vim.keymap.set("n", "<leader>i", function()
	if vim.lsp.inlay_hint.is_enabled() then
		vim.lsp.inlay_hint.enable(false)
	else
		vim.lsp.inlay_hint.enable()
	end
end, { desc = "Toggles inlay hints" })

vim.keymap.set("n", "<leader>hl", function()
	vim.cmd("highlight WinSeparator guifg=#2e3842")
end)
