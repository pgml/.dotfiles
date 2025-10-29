return {
	src = "nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	init = function()
		require "telescope".setup({
			defaults = {
				layout_strategy = "center",
				mappings = {
					i = {
						["<C-u>"] = false,
						["<C-d>"] = false,
					},
				},
				initial_mode = "normal",
				scroll_strategy = "cycle",
				sorting_strategy = "ascending",
			},
			pickers = {
				buffers = { theme = "dropdown", },
				live_grep = { initial_mode = "insert", theme = "ivy", },
				git_files = { initial_mode = "insert", },
				find_file = { initial_mode = "insert", },
				--lsp_document_symbols = { initial_mode = "insert", }
			},
			extensions = {
				["ui-select"] = { require("telescope.themes").get_dropdown(), },
			},
		})

		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<C-p>", builtin.git_files)
		vim.keymap.set("n", "<leader>pf", builtin.find_files)
		vim.keymap.set('n', "<leader>e", builtin.buffers)
		vim.keymap.set("n", "<leader>sg", builtin.live_grep)
		vim.keymap.set('n', '<leader>sd', builtin.diagnostics)

	end
}
