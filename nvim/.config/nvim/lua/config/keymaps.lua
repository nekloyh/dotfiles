local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Di chuyển giữa split nvim VÀ pane tmux bằng cùng một phím
-- (smart-splits + block is_vim trong tmux.conf)
keymap.set("n", "<C-h>", function()
	require("smart-splits").move_cursor_left()
end, opts)
keymap.set("n", "<C-j>", function()
	require("smart-splits").move_cursor_down()
end, opts)
keymap.set("n", "<C-k>", function()
	require("smart-splits").move_cursor_up()
end, opts)
keymap.set("n", "<C-l>", function()
	require("smart-splits").move_cursor_right()
end, opts)
