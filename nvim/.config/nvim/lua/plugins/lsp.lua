return {
	-- tools
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"shellcheck",
				"shfmt",
				"tailwindcss-language-server",
				"css-lsp",
			})
		end,
	},

	-- lsp servers
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = false },
			---@type lspconfig.options
			servers = {
				cssls = {},
				tailwindcss = {
					-- API mới (nvim 0.11 / lspconfig v2): root_markers thay cho
					-- root_dir = lspconfig.util.root_pattern(...) kiểu cũ
					root_markers = { ".git" },
				},
				-- TypeScript: KHÔNG config ở đây — extras.lang.typescript (lazy.lua)
				-- chọn vtsls và force-disable tsserver/ts_ls/tsgo còn lại.
				-- Block tsserver cũ (root_dir + inlayHints) đã chết từ khi extra
				-- chuyển sang vtsls → xoá 2026-08-22; inlay hints vốn tắt toàn cục
				-- (inlay_hints.enabled = false ở trên).
				html = {},
				yamlls = {
					settings = {
						yaml = {
							keyOrdering = false,
						},
					},
				},
				lua_ls = {
					-- enabled = false,
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",
							},
							misc = {
								parameters = {
									-- "--log-level=trace",
								},
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							doc = {
								privateName = { "^_" },
							},
							type = {
								castNumberToInteger = true,
							},
							diagnostics = {
								disable = { "incomplete-signature-doc", "trailing-space" },
								-- enable = false,
								groupSeverity = {
									strong = "Warning",
									strict = "Warning",
								},
								groupFileStatus = {
									["ambiguity"] = "Opened",
									["await"] = "Opened",
									["codestyle"] = "None",
									["duplicate"] = "Opened",
									["global"] = "Opened",
									["luadoc"] = "Opened",
									["redefined"] = "Opened",
									["strict"] = "Opened",
									["strong"] = "Opened",
									["type-check"] = "Opened",
									["unbalanced"] = "Opened",
									["unused"] = "Opened",
								},
								unusedLocalExclude = { "_*" },
							},
							format = {
								enable = false,
								defaultConfig = {
									indent_style = "space",
									indent_size = "2",
									continuation_indent_size = "2",
								},
							},
						},
					},
				},
			},
			setup = {},
		},
	},
	{
		-- gd qua telescope, không reuse window.
		-- (keymaps.get() cũ đã deprecated — LazyVim giờ nhận keys qua servers["*"])
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				["*"] = {
					keys = {
						{
							"gd",
							function()
								require("telescope.builtin").lsp_definitions({ reuse_win = false })
							end,
							desc = "Goto Definition",
							has = "definition",
						},
					},
				},
			},
		},
	},
}
