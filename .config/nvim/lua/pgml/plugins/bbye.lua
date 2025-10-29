return {
	src = "moll/vim-bbye",
	init = function()
		vim.keymap.set("n", "<leader>q", "<cmd>Bdelete<CR>")
	end,
}
