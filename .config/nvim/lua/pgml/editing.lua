-- Keep saved files free of trailing whitespace.
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

-- Treat C-style headers as C because this config does not use C++.
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.h",
	callback = function()
		vim.bo.filetype = "c"
	end,
})
