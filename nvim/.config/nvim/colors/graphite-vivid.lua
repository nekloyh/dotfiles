-- Graphite Vivid — colorscheme chính thức của hệ theme.
--
-- Chạy trên engine highlight của solarized-osaka.nvim (bộ ánh xạ hàng trăm
-- highlight group cho treesitter/LSP/plugin) nhưng 100% GIÁ TRỊ MÀU lấy từ
-- bảng trung tâm ~/.config/colors/graphite-vivid/graphite-vivid.nvim.lua —
-- xem lua/plugins/colorscheme.lua (on_colors thay toàn bộ palette, cả bản
-- light suy ra từ cùng một bảng).
--
-- Dùng:  :colorscheme graphite-vivid
--        :set background=light / dark  → tự chuyển bản sáng/tối.
require("solarized-osaka").load()
vim.g.colors_name = "graphite-vivid"
