--- Hide a terminal from buffer pickers while it is visible in a window.
--- Hidden terminal buffers remain listed so they can be opened again.
---@param buf integer
local function sync_terminal_buffer_visibility(buf)
	if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "terminal" then
		return
	end

	vim.bo[buf].buflisted = #vim.fn.win_findbuf(buf) == 0
end

--- Reapply the visibility rule to every terminal buffer.
local function sync_terminal_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		sync_terminal_buffer_visibility(buf)
	end
end

local terminal_buffers = vim.api.nvim_create_augroup("terminal-buffer-visibility", { clear = true })

vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
	group = terminal_buffers,
	callback = function(args)
		sync_terminal_buffer_visibility(args.buf)
	end,
})

-- Closing a window can change the visibility of more than one terminal.
vim.api.nvim_create_autocmd({ "BufWinLeave", "WinClosed", "TabClosed" }, {
	group = terminal_buffers,
	callback = function()
		-- Wait until the window or tab has actually been removed.
		vim.schedule(sync_terminal_buffers)
	end,
})

--- Open a terminal in its own tab and enter terminal mode immediately.
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
