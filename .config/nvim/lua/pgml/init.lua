require "pgml.set"

local plugins = require("pgml.plugins")

for _, plugin in ipairs(plugins) do
	if plugin.init then
		plugin.init()
	end
end

require "pgml.keymap"

vim.cmd("colorscheme base16-tokyo-night-terminal-light")
require "base16-colorscheme".setup({
	base00 = '#d5d6db',
	base01 = '#d5d6db',
	base02 = '#cbccd1',
	base03 = '#9699a3',
	base04 = '#4c505e',
	base05 = '#4c505e',
	base06 = '#1a1b26',
	base07 = '#1a1b26',
	base08 = '#8c4351',
	base09 = '#965027',
	base0A = '#8f5e15',
	base0B = '#33635c',
	base0C = '#0f4b6e',
	base0D = '#34548a',
	base0E = '#5a4a78',
	base0F = '#655259'
})
--end

vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
vim.api.nvim_set_hl(0, "TabLineSel", { bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })

-- autocommands

-- strip trailig whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*" },
	command = [[%s/\s\+$//e]],
})

-- i don't do c++ and you can't make me
vim.api.nvim_create_autocmd({ "BufNewFile" ,"BufRead" }, {
	pattern = { "*.h" },
	callback = function()
		vim.bo.filetype = "c"
	end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	float = {
		header = false,
		border = 'rounded',
		focusable = true,
	},
})

vim.filetype.add({
	extension = {
		["fs"] = "glsl",
		["vs"] = "glsl",
	},
})

vim.api.nvim_create_user_command("PackUpdate", function()
	require("vim.pack").update()
end, { desc = "Update all plugins using vim.pack" })

-- borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or 'rounded'

	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local function goto_center()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.w[win].is_zen_center then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
end

vim.api.nvim_create_user_command("PadReset", function()
	local buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
	vim.api.nvim_win_set_buf(0, buf)

	goto_center()
end, {})

vim.api.nvim_create_user_command("ZenFake", function()
	--vim.cmd("PadReset")
	vim.cmd("vsplit")
	--vim.cmd("vertical resize 30")
	vim.cmd("vsplit")
	--vim.cmd("vertical resize 30")
	vim.cmd("wincmd l")

	vim.w.is_zen_center = true
	vim.w.is_zen_active = true
end, {})
