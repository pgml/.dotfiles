return {
	src = "nvim-treesitter/nvim-treesitter",
	init = function()
		require "nvim-treesitter.configs".setup({
			auto_install = true,
			highlight = { enable = true },
			ensure_installed = {
				"bash",
				"c",
				"c_sharp",
				"go",
				"lua",
				"rust",
				"vim",
				"vimdoc",
			},
		})
	end
}
