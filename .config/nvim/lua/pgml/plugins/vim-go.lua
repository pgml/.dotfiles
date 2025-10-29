return {
	src = "ray-x/go.nvim",
	init = function()
		require "go".setup({
			lsp_keymaps = false,
			lsp_inlay_hints = { enable = true }
		})

		local format_sync_grp = vim.api.nvim_create_augroup("goimports", {})
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.go",
			callback = function()
				require("go.format").goimports()
			end,
			group = format_sync_grp,
		})
	end
}
