vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

--vim.api.nvim_create_autocmd("BufWritePre", {
--	pattern = { "*.c", "*.h" },
--	callback = function()
--		vim.lsp.buf.format({ async = false })
--	end,
--})

require("pgml.align").attach({
	{ "^(%s*[%w_][%w_%s]-)%s+(%**[%w_]+%s*[;,:=%[].*)$", "  " },
	{ "^(%s*[%w_%.%[%]%->]*[%w_%]])%s*(=)%s*([^=].*)$" },
})
