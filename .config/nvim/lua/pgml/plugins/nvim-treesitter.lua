return {
	src = "nvim-treesitter/nvim-treesitter",
	enabled = false,
	init = function()
		require('nvim-treesitter').setup {
			install_dir = vim.fn.stdpath('data') .. '/site'
		}
		require "nvim-treesitter".install({
			"bash",
			"c",
			"c_sharp",
			"go",
			"lua",
			"rust",
			"vim",
			"vimdoc",
			"zig",
		}):wait(3000)
	end
}
