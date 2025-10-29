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

-- borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or 'rounded'

	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
