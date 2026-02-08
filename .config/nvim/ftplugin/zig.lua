vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
--vim.o.list = false
vim.o.expandtab = true

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.zig",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
