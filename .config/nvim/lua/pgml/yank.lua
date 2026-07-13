-- Briefly show the text affected by a successful yank.
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

--- Copy every diagnostic on the current line to the system clipboard.
local function yank_diagnostics()
	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diagnostics = vim.diagnostic.get(0, { lnum = line })

	if #diagnostics == 0 then
		vim.notify("No diagnostics found on this line", vim.log.levels.WARN)
		return
	end

	local messages = {}
	for _, diagnostic in ipairs(diagnostics) do
		table.insert(messages, diagnostic.message)
	end

	local content = table.concat(messages, "\n")
	vim.fn.setreg("+", content)
	vim.notify("Copied diagnostic(s) to clipboard", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("YankDiagnostics", yank_diagnostics, {})
vim.keymap.set("n", "<leader>d", "<CMD>YankDiagnostics<CR>")
