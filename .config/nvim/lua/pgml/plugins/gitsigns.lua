return {
	src = "lewis6991/gitsigns.nvim",
	init = function()
		require "gitsigns".setup({
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 0,
			},
		})

		vim.keymap.set("n", "<leader>bl", "<cmd>Gitsigns blame_line<CR>")
		--vim.keymap.set("n", "<leader>b", "<cmd>Gitsigns blame<CR>")
	end
}
