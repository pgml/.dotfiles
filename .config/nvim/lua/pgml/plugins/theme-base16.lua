return {
	src = "RRethy/base16-nvim",
	init = function()
		vim.cmd("colorscheme base16-tokyo-night-terminal-light")
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

		vim.keymap.set("n", "<leader>thl", function()
			vim.cmd("colorscheme base16-tokyo-night-terminal-light")
			vim.cmd("set background=light")
			--vim.cmd("set laststatus=0")
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
	end
}
