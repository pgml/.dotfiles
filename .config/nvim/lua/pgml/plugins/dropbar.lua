return {
	src = "Bekaboo/dropbar.nvim",
	init = function()
		require("dropbar").setup({
			icons = {
				kinds = {
					symbols = {
						Array = '',
						BlockMappingPair = '',
						Boolean = '',
						BreakStatement = '',
						Call = '',
						CaseStatement = '',
						Class = '',
						Color = '',
						Constant = '',
						Constructor = '',
						ContinueStatement = '',
						Copilot = '',
						Declaration = '',
						Delete = '',
						DoStatement = '',
						Element = '',
						Enum = '',
						EnumMember = '',
						Event = '',
						Field = '',
						File = '',
						Folder = '',
						ForStatement = '',
						Function = '',
						GotoStatement = '',
						Identifier = '',
						IfStatement = '',
						Interface = '',
						Keyword = '',
						List = '',
						Log = '',
						Lsp = '',
						Macro = '',
						MarkdownH1 = '',
						MarkdownH2 = '',
						MarkdownH3 = '',
						MarkdownH4 = '',
						MarkdownH5 = '',
						MarkdownH6 = '',
						Method = '',
						Module = '',
						Namespace = '',
						Null = '',
						Number = '',
						Object = '',
						Operator = '',
						Package = '',
						Pair = '',
						Property = '',
						Reference = '',
						Regex = '',
						Repeat = '',
						Return = '',
						Rule = '',
						RuleSet = '',
						Scope = '',
						Section = '',
						Snippet = '',
						Specifier = '',
						Statement = '',
						String = '',
						Struct = '',
						SwitchStatement = '',
						Table = '',
						Terminal = '',
						Text = '',
						Type = '',
						TypeParameter = '',
						Unit = '',
						Value = '',
						Variable = '',
						WhileStatement = '',
					}
				}
			}

		})

		local dropbar_api = require('dropbar.api')
		vim.keymap.set('n', '<Leader>;', dropbar_api.pick, {
			desc = 'Pick symbols in winbar'
		})
		vim.keymap.set('n', '[;', dropbar_api.goto_context_start, {
			desc = 'Go to start of current context'
		})
		vim.keymap.set('n', '];', dropbar_api.select_next_context, {
			desc = 'Select next context'
		})
	end
}
