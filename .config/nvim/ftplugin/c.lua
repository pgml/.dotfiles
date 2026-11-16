vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.bo.smartindent = true
--vim.bo.expandtab = true

require("pgml.align").attach({
	-- Object-like #define values.
	{ "^(%s*#%s*define%s+[%w_]+)%s+(.*)$", " " },
	-- Lines with `=` only align on the `=`; the rest align type and name.
	{ "^(%s*[%w_%s%*%.%[%]%->]*[%w_%]])%s*(=)%s*([^=].*)$" },
	{ "^(%s*[%w_][%w_%s]-)%s+(%**[%w_]+%s*[;,:=%[].*)$", "  " },
})
