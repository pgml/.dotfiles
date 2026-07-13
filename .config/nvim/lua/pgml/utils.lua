-- Load personal features implemented locally instead of by plugins.
require("pgml.fake_zen").setup({
	hide_separators_on_start = true,
	open_on_new_tab = true,
	open_on_start = true,
	width = 92,
	separator_color = "#43434c",
})
require("pgml.pack")
require("pgml.terminal")
require("pgml.editing")
require("pgml.yank")
