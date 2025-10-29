return {
	src = "folke/zen-mode.nvim",
	init = function()
		require "zen-mode".setup({
			window = {
				backdrop = 1,
				width = 95,
			}
		})

		vim.api.nvim_create_autocmd("BufWinEnter", {
			callback = function()
				local current_tabpage = vim.api.nvim_get_current_tabpage()
				local wins = vim.api.nvim_tabpage_list_wins(current_tabpage)

				-- Count non-floating windows
				local normal_win_count = 0
				for _, win in ipairs(wins) do
					local cfg = vim.api.nvim_win_get_config(win)
					if cfg.relative == "" then -- not a floating window
						normal_win_count = normal_win_count + 1
					end
				end

				vim.schedule(function()
					if normal_win_count == 1 then
						require "zen-mode".open({
							window = {
								width = 95
							}
						})
					end
				end)
			end
		})

		vim.api.nvim_set_hl(0, "ZenBg", { bg = "NONE" })
		vim.keymap.set("n", "<leader>zz", function()
			require "zen-mode".toggle({
				window = {
					backdrop = 0.55,
					width = 95,
				},
				plugins = {
					options = {
						enabled = true,
						laststatus = 0,
						ruler = true,
						showcmd = true,
					},
					twilight = { enabled = true },
				},
			})
		end)
	end,
}
