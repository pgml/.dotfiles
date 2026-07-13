require "pgml.set"

local plugins = require("pgml.plugins")

for _, plugin in ipairs(plugins) do
	if plugin.init then
		plugin.init()
	end
end

require "pgml.keymap"
require "pgml.utils"

vim.lsp.inlay_hint.enable(false)

vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
vim.api.nvim_set_hl(0, "TabLineSel", { bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })

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

-- borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or 'rounded'

	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
