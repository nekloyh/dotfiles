-- nvim-treesitter branch MAIN (bản viết lại) — KHÔNG override `config`:
-- logic cài parser + bật highlight/indent/fold nằm trong spec của LazyVim,
-- đè config là mất auto-install (bài học 2026-08-22: 0 parser được cài).
-- opts_extend gộp ensure_installed với danh sách mặc định của LazyVim.
--
-- playground đã bỏ: plugin archive, chỉ chạy với branch master cũ;
-- main có sẵn :InspectTree / :EditQuery thay thế.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"astro",
				"cmake",
				"cpp",
				"css",
				"fish",
				"gitignore",
				"go",
				"graphql",
				"http",
				"java",
				"php",
				"rust",
				"scss",
				"sql",
				"svelte",
			},
		},
		-- MDX chưa có parser riêng — đăng ký dùng parser markdown
		init = function()
			vim.filetype.add({ extension = { mdx = "mdx" } })
			vim.treesitter.language.register("markdown", "mdx")
		end,
	},
}
