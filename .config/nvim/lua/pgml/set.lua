vim.g.mapleader = " "

vim.g.netrw_banner = 0
vim.g.netrw_preview = 1
vim.g.netrw_winsize = 20

vim.g.have_nerd_font = true

vim.o.showtabline = 2
vim.o.list = true
vim.o.background = "light"
vim.o.laststatus = 0
vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 3
vim.o.softtabstop = 3
vim.o.shiftwidth = 3

vim.o.signcolumn = "yes"
vim.o.colorcolumn = "75"

vim.o.guicursor = "n-v-c-i:block"
vim.o.listchars = "tab:  ,trail:⎵,nbsp:·,space:·"

vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.timeoutlen = 300
vim.o.updatetime = 250

vim.o.scrolloff = 10
vim.o.inccommand = "split"

vim.o.confirm = true
vim.o.termguicolors = true

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)


--- LSP stuff

vim.g.rust_recommended_style = false
vim.g.zig_recommended_style = false

vim.g.go_highlight_structs = 1
vim.g.go_highlight_methods = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_parameters = 1
vim.g.go_highlight_operators = 1
vim.g.go_highlight_types = 1
vim.g.go_highlight_fields = 1
vim.g.go_highlight_build_constraints = 1
vim.g.go_highlight_generate_tags = 1
vim.g.go_highlight_format_strings = 1
vim.g.go_highlight_variable_declarations = 1
vim.g.go_highlight_variable_assignments = 1
vim.g.go_auto_type_info = 1
vim.g.go_fmt_autosave = 1
vim.g.go_mod_fmt_autosave = 1
vim.g.go_gopls_enabled = 1
