return {
	src = "pgml/nvim-juliana",
	init = function()
		require "nvim-juliana".setup {
			colors = {
				--bg2 = "#343D46",
				bg2 = "#2E3842"
			}
		}

		vim.keymap.set("n", "<leader>thj", function()
			vim.cmd("colorscheme juliana")
			vim.cmd("set background=dark")
			--vim.cmd("set laststatus=0")
			vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#576C85" })
			vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "TabLineSel", { bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
		end, { desc = "Set dark colourtheme juliana" })
	end
}
