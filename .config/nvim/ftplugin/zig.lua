vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
--vim.o.list = false
vim.o.expandtab = true

local bufnr = vim.api.nvim_get_current_buf()
local bin = vim.fn.expand("zigfmt-align")

local function format()
	local input = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
	local res = vim.system({ bin, "--stdin" }, { stdin = input }):wait()

	if res.code ~= 0 or res.stdout == input then
		return
	end

	local out = vim.split(res.stdout, "\n", { plain = true })

	for _, h in ipairs(vim.fn.reverse(vim.text.diff(input, res.stdout, { result_type = "indices" }))) do
		local a, ca, b, cb = unpack(h)
		if ca > 0 then
			a = a - 1
		end
		vim.api.nvim_buf_set_lines(bufnr, a, a + ca, false, vim.list_slice(out, b, b + cb - 1))
	end
end

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("zigfmt" .. bufnr, {}),
	buffer = bufnr,
	callback = format,
})
vim.keymap.set("n", "<leader>lf", format, { buffer = bufnr, desc = "Format buffer (zigfmt-align)" })

require("pgml.align").attach({
	{ "^(%s*[^%s:=]+:)%s*([^=%s].*)$", " " },
	{ "^(%s*[^=]-[^%s=!<>+%-*/%%&|^~])%s*=>%s*(.*)$", " => " },
	{ "^(%s*[^=]-[^%s=!<>+%-*/%%&|^~])%s*(=)%s*([^=>].*)$" },
})
