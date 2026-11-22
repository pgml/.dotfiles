vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false

pcall(vim.treesitter.start)

local function remove_unused_imports()
	local rows = {}
	for _, d in ipairs(vim.diagnostic.get(0)) do
		local line = vim.api.nvim_buf_get_lines(0, d.lnum, d.lnum + 1, false)[1] or ""
		if d.message:lower():find("unused import") and line:find("^%s*import%s") then
			rows[d.lnum] = true
		end
	end
	local sorted = vim.tbl_keys(rows)
	table.sort(sorted, function(a, b) return a > b end)
	for _, row in ipairs(sorted) do
		vim.api.nvim_buf_set_lines(0, row, row + 1, false, {})
	end
end

local imports_group = vim.api.nvim_create_augroup("OdinUnusedImports", { clear = false })
vim.api.nvim_clear_autocmds({ group = imports_group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePre", { group = imports_group, buffer = 0, callback = remove_unused_imports })

--vim.api.nvim_create_autocmd("BufWritePre", {
--	buffer = 0,
--	callback = function()
--		if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" }) > 0 then
--			vim.lsp.buf.format({ async = false })
--		end
--	end,
--})

require("pgml.align").attach({
	{ "^(%s*[%w_, ]-:)%s*([^:=%s].*)$", " " },
	{ "^(%s*[%w_]+)%s*::%s*(.*)$", " :: " },
	{ "^(%s*[%w_%.]+)%s*(:?=)%s*([^=].*)$" },
})
