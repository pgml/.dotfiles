return {
	src = "S1M0N38/love2d.nvim",
	init = function()
		require "love2d".setup({
			path_to_love_bin = "/usr/bin/love"
		})
		--vim.keymap.set("<leader>v", desc = "LÖVE")
		vim.keymap.set("n", "<leader>b", "<cmd>LoveRun<cr>")
		vim.keymap.set("n", "<leader>vs", "<cmd>LoveStop<cr>")
	end
}
