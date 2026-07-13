return {
	src = "moll/vim-bbye",
	init = function()
		vim.keymap.set("n", "<leader>q", function()
			local buf = vim.api.nvim_get_current_buf()
			local hidden_terminal = vim.bo[buf].buftype == "terminal" and not vim.bo[buf].buflisted

			-- vim-bbye only deletes listed buffers after switching the window away.
			if hidden_terminal then
				vim.bo[buf].buflisted = true
			end

			local ok, err = pcall(vim.cmd.Bdelete)

			-- Restore the visibility rule if deletion was cancelled or failed.
			if hidden_terminal and vim.api.nvim_buf_is_valid(buf) then
				vim.bo[buf].buflisted = #vim.fn.win_findbuf(buf) == 0
			end

			if not ok then
				error(err)
			end
		end, { desc = "Delete buffer" })
	end,
}
