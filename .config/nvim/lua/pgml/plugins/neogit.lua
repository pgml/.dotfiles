return {
	src = "NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration
	},
	init = function()
		local neogit = require("neogit")
		local focus_group = vim.api.nvim_create_augroup("pgml-neogit-focus", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = focus_group,
			pattern = "NeogitStatus",
			callback = function(args)
				vim.api.nvim_create_autocmd("BufWinLeave", {
					group = focus_group,
					buffer = args.buf,
					once = true,
					callback = function()
						local tab = vim.api.nvim_get_current_tabpage()

						vim.schedule(function()
							if vim.api.nvim_tabpage_is_valid(tab)
								and vim.api.nvim_get_current_tabpage() == tab then
								require("pgml.fake_zen").focus_center()
							end
						end)
					end,
				})
			end,
		})

		vim.keymap.set("n", "<leader>gg", function()
			vim.cmd("Neogit")
		end, { desc = "Open Neogit" })
		vim.keymap.set("n", "<leader>gp", function()
			vim.cmd("Neogit pull")
		end, { desc = "Git pull" })
		vim.keymap.set("n", "<leader>gP", function()
			vim.cmd("Neogit push")
		end, { desc = "Git push" })
		vim.keymap.set("n", "<leader>gl", function()
			vim.cmd("Neogit log")
		end, { desc = "Git log" })

		require("neogit").setup({
			graph_style = "unicode",
			integrations = {
				telescope = true,
				diffview = true,
			},
			--git_services = {
			--	["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
			--},
			kind = "floating",
			commit_view = {
				kind = "floating",
				verify_commit = vim.fn.executable("gpg") == 1,
			},
			commit_editor = {
				kind = "floating",
				show_staged_diff = true,
				-- staged_diff_split_kind = "split_above",
			},
			popup = {
				kind = "floating",
			},
			mappings = {
				status = {
					--["q"] = false,
					--["<c-c>"] = "Close"
				},
			},
		})
	end,
}
