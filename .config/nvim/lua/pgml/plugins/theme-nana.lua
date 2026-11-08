return {
	src = "pgml/nana",
	init = function()
		vim.keymap.set("n", "<leader>thn", function()
			vim.cmd("colorscheme nana")
			vim.cmd("set background=dark")
		end, { desc = "Set dark colourtheme nana" })

		vim.keymap.set("n", "<leader>thl", function()
			vim.cmd("colorscheme nana")
			vim.cmd("set background=light")
		end, { desc = "Set light colourtheme nana" })
	end
}
