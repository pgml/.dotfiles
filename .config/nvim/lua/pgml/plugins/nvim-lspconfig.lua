return {
	src = "neovim/nvim-lspconfig",
	dependencies = {
		"Decodetalkers/csharpls-extended-lsp.nvim",
	},
	init = function()
		vim.lsp.enable({
			"lua_ls",
			"gopls",
			"csharp_ls",
			"clang",
			"rust_analyzer",
			"zls",
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols)
		vim.keymap.set("n", "<leader><leader>", vim.diagnostic.open_float)
		vim.keymap.set('n', 'gd', builtin.lsp_definitions)
		vim.keymap.set('n', 'gr', builtin.lsp_references)

		vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

		local lspconfig = require("lspconfig")

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
						path = vim.split(package.path, ";")
					},
					workspace = {
						useThirdParty = { os.getenv("HOME") .. ".local/share/LuaAddons" },
						checkThirdParty = "Apply",
						library = {
							vim.api.nvim_get_runtime_file("", true),
							vim.fn.getcwd(),
							"${3rd}/love2d/library",
						}
					},
					diagnostics = {
						globals = {
							"vim",
							"require",
							"love",
						}
					},
				}
			}
		})

		vim.lsp.config("clangd", {})
		vim.lsp.config("rust_analyzer", {})

		vim.lsp.config("gopls", {
			settings = {
				completeUnimported = true,
				usePlaceholders = true,
				staticcheck = true,
				semanticTokens = true,
				gofumpt = true,
				codelenses = {
					gc_details = false,
					generate = true,
					regenerate_cgo = true,
					run_govulncheck = true,
					test = true,
					tidy = true,
					upgrade_dependency = true,
					vendor = true,
				},
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
				analyses = {
					fieldalignment = true,
					nilness = true,
					unusedparams = true,
					unusedwrite = true,
					useany = true,
				},
			}
		})

		vim.lsp.config("csharp_ls", {
			filetypes = { "cs" },
			init_options = {
				AutomaticWorkspaceInit = true,
			},
			flags = {
				debounce_text_changes = 150,
			},
			handlers = {
				["textDocument/definition"] = require("csharpls_extended").handler,
				["textDocument/typeDefinition"] = require("csharpls_extended").handler,
			},
			enable_editorconfig_support = true,
			enable_roslyn_analyzers = true,
			enable_ms_build_load_projects_on_demand = false,
			enable_import_completion = true,
			sdk_include_prereleases = true,
			analyze_open_documents_only = true,
			on_attach = function(client, bufnr)
				--navic.attach(client, bufnr)
				client.server_capabilities.semanticTokensProvider = nil
				client.server_capabilities.codeLensProvider = nil
			end,
		})

		vim.lsp.config("zls", {
			cmd = { "zls" },
			zig_exe_path = "~/.local/bin/zig",
			filetypes = { "zig", "zir" },
			single_file_support = true,
			root_dir = lspconfig.util.root_pattern("build.zig", ".git") or vim.loop.cmd,
		})
	end
}
