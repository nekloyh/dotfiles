return {
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,
		opts = function()
			return {
				transparent = true,
				-- Graphite Vivid: bơm palette trung tâm vào solarized-osaka.
				-- Mirror ~/.config/colors/graphite-vivid/graphite-vivid.nvim.lua
				-- được thiết kế sẵn cho on_colors (xem header file đó) —
				-- giữ nguyên cấu trúc theme, chỉ thay bảng màu.
				on_colors = function(colors)
					local ok, vivid = pcall(dofile, vim.fn.expand("~/.config/colors/graphite-vivid/graphite-vivid.nvim.lua"))
					if not ok or type(vivid) ~= "table" then
						vim.notify("graphite-vivid.nvim.lua không đọc được — giữ màu solarized-osaka gốc", vim.log.levels.WARN)
						return
					end
					for k, v in pairs(vivid) do
						colors[k] = v
					end
					-- Mirror chỉ có stop 50/100/300/500/700/900/950; solarized-osaka
					-- còn dùng 200/400/600/800 → fill từ stop kế cận cùng ramp
					-- (giữ thứ tự sáng→tối) để không sót màu Solarized cũ.
					local fill = { ["200"] = "300", ["400"] = "500", ["600"] = "700", ["800"] = "900" }
					for _, hue in ipairs({ "yellow", "orange", "red", "magenta", "violet", "blue", "cyan", "green" }) do
						for miss, src in pairs(fill) do
							if vivid[hue .. src] then
								colors[hue .. miss] = vivid[hue .. src]
							end
						end
					end
				end,
			}
		end,
	},
}
