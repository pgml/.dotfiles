-- autocommands


-- UPDATE PLIUGINS
vim.api.nvim_create_user_command("PackUpdate", function()
	require("vim.pack").update()
end, { desc = "Update all plugins using vim.pack" })


-- OPEN A TERMINAL IN A NEW TAB
local function terminal_tab()
	vim.cmd.tabnew()
	vim.cmd.terminal()
	vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("TerminalTab", terminal_tab, {
	desc = "Open a terminal in a new tab",
})
vim.keymap.set("n", "<leader>tt", terminal_tab, {
	desc = "Open terminal in new tab",
})


-- STRIP TRAILIG WHITESPACE
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*" },
	command = [[%s/\s\+$//e]],
})


-- I DON'T DO C++ AND YOU CAN'T MAKE ME
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "*.h" },
	callback = function()
		vim.bo.filetype = "c"
	end,
})


-- HIGHLIGHT WHEN YANKING (COPYING) TEXT
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})


-- YANK DIAGNOSTICS
local function yank_diagnostics()
	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diagnostics = vim.diagnostic.get(0, { lnum = line })

	if #diagnostics == 0 then
		vim.notify("No diagnostics found on this line", vim.log.levels.WARN)
		return
	end

	local messages = {}
	for _, d in ipairs(diagnostics) do
		table.insert(messages, d.message)
	end

	local content = table.concat(messages, "\n")
	vim.fn.setreg("+", content)
	vim.notify("Copied diagnostic(s) to clipboard", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("YankDiagnostics", yank_diagnostics, {})
vim.keymap.set("n", "<leader>d", "<CMD>YankDiagnostics<CR>")
