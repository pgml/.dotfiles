vim.keymap.set("n", "<F1>", "noop")
vim.keymap.set("n", "<C-z>", "noop")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste but keeps register" })

local function switch_tab(command)
	return function()
		command()
		if vim.bo.buftype == "terminal" then
			vim.cmd.startinsert()
		end
	end
end

local tabprevious = switch_tab(vim.cmd.tabprevious)
local tabnext = switch_tab(vim.cmd.tabnext)

vim.keymap.set({ "n", "t" }, "<A-q>", tabprevious)
vim.keymap.set({ "n", "t" }, "<A-e>", tabnext)

vim.keymap.set("n", "<leader>sn", "<cmd>set number<CR><cmd>set relativenumber<CR>");
vim.keymap.set("n", "<leader>hn", "<cmd>set nonumber<CR><cmd>set norelativenumber<CR>");
vim.keymap.set("n", "<leader>l", "<cmd>set list<CR>")
vim.keymap.set("n", "<leader>nl", "<cmd>set nolist<CR>")
vim.keymap.set("n", "<leader>tn", vim.cmd.tabnew, { desc = "Open tab in FakeZen" });
vim.keymap.set("n", "<leader>w", vim.cmd.tabclose);

vim.keymap.set('t', '<esc><esc>', "<C-\\><C-n>")
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
