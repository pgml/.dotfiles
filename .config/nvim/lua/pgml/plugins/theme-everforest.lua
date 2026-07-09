return {
	src = "sainnhe/everforest",
	init = function()
		vim.keymap.set("n", "<leader>the", function()
			vim.g.everforest_colors_override = {
				blue = { "#D3C6AA	", "223" },
				bg2 = { "#2D353B", "223" },
				grey1 = { "#7A8478", "223" },
				grey2 = { "#2D353B", "223" },
				statusline1 = { "#56635f", "223" },
			}
			vim.cmd("colorscheme everforest")
			vim.cmd("set background=dark")
		end, { desc = "Set dark colourtheme everforest" })
	end
}
