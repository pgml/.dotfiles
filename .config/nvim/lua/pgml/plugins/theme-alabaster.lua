return {
	src = "mcncl/alabaster.nvim",
	init = function()
		vim.keymap.set("n", "<leader>tha", function()
			vim.cmd("colorscheme alabaster")
			vim.cmd("set background=dark")
		end, { desc = "Set dark colourtheme alabaster" })
	end
}
