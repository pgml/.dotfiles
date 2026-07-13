-- Update all plugins managed by Neovim's built-in package manager.
vim.api.nvim_create_user_command("PackUpdate", function()
	require("vim.pack").update()
end, { desc = "Update all plugins using vim.pack" })
