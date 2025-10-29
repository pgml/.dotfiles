vim.keymap.set("n", "<C-z>", "noop")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste but keeps register" })
vim.keymap.set("n", "<A-q>", vim.cmd.bprevious, { desc = "Switch to previous buffer" })
vim.keymap.set("n", '<A-e>', vim.cmd.bnext, { desc = "Switch to next buffer" })

vim.keymap.set("n", "<leader>i", function()
	if vim.lsp.inlay_hint.is_enabled() then
		vim.lsp.inlay_hint.enable(false)
	else
		vim.lsp.inlay_hint.enable()
	end
end, { desc = "Toggles inlay hints" })

vim.keymap.set("n", "<leader>thj", function()
	vim.cmd("colorscheme juliana")
	vim.cmd("set background=dark")
	vim.cmd("set laststatus=0")
	vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#576C85" })
	vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TabLineSel", { bg = "NONE", bold = true })
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
end, { desc = "Set dark colourtheme juliana" })

vim.keymap.set("n", "<leader>thl", function()
	vim.cmd("colorscheme base16-tokyo-night-terminal-light")
	vim.cmd("set background=light")
	vim.cmd("set laststatus=0")
	vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TabLineSel", { bg = "NONE", bold = true })
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
	require "base16-colorscheme".setup({
		base00 = '#d5d6db',
		base01 = '#d5d6db',
		base02 = '#cbccd1',
		base03 = '#9699a3',
		base04 = '#4c505e',
		base05 = '#4c505e',
		base06 = '#1a1b26',
		base07 = '#1a1b26',
		base08 = '#8c4351',
		base09 = '#965027',
		base0A = '#8f5e15',
		base0B = '#33635c',
		base0C = '#0f4b6e',
		base0D = '#34548a',
		base0E = '#5a4a78',
		base0F = '#655259'
	})
end, { desc = "Set light colourtheme tokyo-night-terminal-light" })

vim.keymap.set("n", "<leader>l", "<cmd>set list<CR>")
vim.keymap.set("n", "<leader>nl", "<cmd>set nolist<CR>")
