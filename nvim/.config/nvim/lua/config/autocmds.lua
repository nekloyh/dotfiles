-- fcitx5: thoát Insert thì về English để normal mode không bị bộ gõ nuốt
-- phím lệnh; vào lại Insert thì khôi phục trạng thái bộ gõ trước đó.
local fcitx_was_active = false
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		vim.system({ "fcitx5-remote" }, { text = true }, function(out)
			fcitx_was_active = (out.stdout or ""):match("^2") ~= nil
			if fcitx_was_active then
				vim.system({ "fcitx5-remote", "-c" })
			end
		end)
	end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		if fcitx_was_active then
			vim.system({ "fcitx5-remote", "-o" })
		end
	end,
})

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.opt.conceallevel = 0
	end,
})
