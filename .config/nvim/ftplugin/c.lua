vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.c", "*.h" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
