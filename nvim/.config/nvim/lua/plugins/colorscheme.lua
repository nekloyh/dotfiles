-- Graphite Vivid trên solarized-osaka — cả DARK lẫn LIGHT.
--
-- Nguồn màu duy nhất: ~/.config/colors/graphite-vivid/graphite-vivid.nvim.lua
-- (mirror dark canonical). Bản LIGHT không có file riêng — được suy ra tại chỗ
-- theo ĐÚNG công thức M.light của solarized-osaka (đảo ramp base, đảo stop
-- accent 50↔950/100↔900/300↔700, canonical giữ nguyên; bg=base3, fg=base01).
--
-- Chuyển chế độ:  :set background=light   /   :set background=dark
-- (autocmd bên dưới tự re-setup: light tắt transparent vì nền cream trên
-- terminal tối sẽ không đọc được; dark giữ transparent như cũ.)

local HUES = { "yellow", "orange", "red", "magenta", "violet", "blue", "cyan", "green" }
-- Mirror chỉ có stop 50/100/300/500/700/900/950; solarized-osaka còn dùng
-- 200/400/600/800 → fill từ stop kế cận (giữ thứ tự sáng→tối) để không sót
-- màu Solarized cũ.
local FILL = { ["200"] = "300", ["400"] = "500", ["600"] = "700", ["800"] = "900" }

local last_vivid

local function load_vivid()
	local ok, vivid = pcall(dofile, vim.fn.expand("~/.config/colors/graphite-vivid/graphite-vivid.nvim.lua"))
	if not ok or type(vivid) ~= "table" then
		vim.notify("graphite-vivid.nvim.lua không đọc được — giữ màu solarized-osaka gốc", vim.log.levels.WARN)
		return nil
	end
	last_vivid = vivid
	return vivid
end

local function apply_dark(colors, vivid)
	for k, v in pairs(vivid) do
		colors[k] = v
	end
	for _, hue in ipairs(HUES) do
		for miss, src in pairs(FILL) do
			if vivid[hue .. src] then
				colors[hue .. miss] = vivid[hue .. src]
			end
		end
	end
end

local function apply_light(colors, vivid)
	-- Đảo ramp base (base04 tối nhất ↔ base4 sáng nhất)
	local basemap = {
		base04 = "base4", base03 = "base3", base02 = "base2", base01 = "base1", base00 = "base0",
		base0 = "base00", base1 = "base01", base2 = "base02", base3 = "base03", base4 = "base04",
	}
	for dst, src in pairs(basemap) do
		colors[dst] = vivid[src]
	end
	-- Accent: canonical giữ nguyên, ramp đảo; stop thiếu fill trong hệ ĐÃ đảo
	local flip = { ["50"] = "950", ["100"] = "900", ["300"] = "700", ["500"] = "500", ["700"] = "300", ["900"] = "100", ["950"] = "50" }
	for _, hue in ipairs(HUES) do
		colors[hue] = vivid[hue]
		for dst, src in pairs(flip) do
			if vivid[hue .. src] then
				colors[hue .. dst] = vivid[hue .. src]
			end
		end
		for miss, near in pairs(FILL) do
			colors[hue .. miss] = colors[hue .. near]
		end
	end
	-- Nền/chữ theo công thức light của plugin (giá trị lấy từ ramp GỐC)
	colors.bg = vivid.base3 -- #ece8dc — cream graphite
	colors.bg_highlight = vivid.base2 -- #d9dedc
	colors.fg = vivid.base01 -- #676c72 — mực xám đậm (nâng L cho sàn 3.5:1)
	-- Token phụ plugin đã tính TRƯỚC on_colors trên palette cũ → tính lại
	colors.border = colors.base02
	colors.bg_popup = colors.base04
	colors.bg_statusline = colors.base03
	colors.bg_sidebar = colors.base04
	colors.bg_float = colors.base04
	colors.fg_float = colors.fg
	colors.error = colors.red500
	colors.warning = colors.yellow500
	colors.info = colors.blue500
	colors.hint = colors.cyan500
	colors.todo = colors.violet500
end

-- Remap vai trò màu theo ngữ nghĩa Graphite Vivid (engine solarized-osaka
-- phân vai kiểu Solarized: keyword xanh lá, số dòng vàng đất — không mang
-- identity violet của hệ theme):
--   keyword/statement → violet primary (khớp waybar/hyprland)
--   Visual            → token `selection` của palette (README: violet-tinted)
--   LineNr            → xám overlay (khớp nano numbercolor)
local function graphite_highlights(hl, _)
	local vivid = last_vivid or load_vivid()
	if not vivid then
		return
	end
	local light = require("solarized-osaka.config").is_light()
	-- violet canonical đủ nổi trên nền tối; trên nền cream dùng bản đậm hơn
	local kw = light and vivid.violet700 or vivid.violet

	local function set_fg(name, fg)
		local d = hl[name]
		if type(d) == "table" and not d.link then
			d.fg = fg
		else
			hl[name] = { fg = fg }
		end
	end

	set_fg("Keyword", kw)
	set_fg("Statement", kw)
	for name, d in pairs(hl) do
		if name:sub(1, 8) == "@keyword" and type(d) == "table" and not d.link then
			d.fg = kw
		end
	end

	hl.Visual = { bg = light and vivid.violet100 or vivid.selection }
	set_fg("LineNr", vivid.overlay1)
	set_fg("CursorLineNr", kw)
end

local function build_opts()
	local light = vim.o.background == "light"
	return {
		transparent = not light,
		on_colors = function(colors)
			local vivid = load_vivid()
			if not vivid then
				return
			end
			if require("solarized-osaka.config").is_light() then
				apply_light(colors, vivid)
			else
				apply_dark(colors, vivid)
			end
		end,
		on_highlights = graphite_highlights,
	}
end

return {
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,
		init = function()
			vim.api.nvim_create_autocmd("OptionSet", {
				pattern = "background",
				callback = function()
					require("solarized-osaka").setup(build_opts())
					vim.cmd.colorscheme("graphite-vivid")
				end,
			})
		end,
		opts = build_opts,
	},
}
