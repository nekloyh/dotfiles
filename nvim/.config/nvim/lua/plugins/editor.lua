return {
	-- Điều hướng liền mạch nvim ⇆ tmux pane (cặp với block is_vim trong tmux.conf)
	{
		"mrjones2014/smart-splits.nvim",
		-- lazy: keymaps.lua require() nó ở lần bấm C-hjkl đầu tiên (đo được
		-- eager tốn 4.5ms sourcing lúc boot mà không đổi lấy gì)
		lazy = true,
		opts = {},
	},

	{
		"brenoprata10/nvim-highlight-colors",
		event = "BufReadPre",
		opts = {
			render = "background",
			enable_hex = true,
			enable_short_hex = true,
			enable_rgb = true,
			enable_hsl = true,
			enable_hsl_without_function = true,
			enable_ansi = true,
			enable_var_usage = true,
			enable_tailwind = true,
		},
	},

	{
		"saghen/blink.cmp",
		opts = {
			completion = {
				menu = {
					winblend = vim.o.pumblend,
				},
			},
			signature = {
				window = {
					winblend = vim.o.pumblend,
				},
			},
		},
	},
}
