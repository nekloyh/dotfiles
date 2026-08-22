-- Decoration - minimal Graphite Vivid --
-- https://wiki.hypr.land/Configuring/Basics/Variables/

local c = require("modules/colors")

-- Border palette
-- rgb()  takes 6 hex (RRGGBB), rgba() takes 8 hex (RRGGBBAA)
-- Màu ĐẶC theo ví dụ chuẩn của palette (col.active_border = $primary) và
-- ngữ nghĩa accent trên waybar: violet = identity/focus, orange = group.
-- Bản gradient cũ (violet→blue / orange→yellow 45deg): xem git log file này.
local activeBorderColor   = c.primary    -- rgb(8388E8) — tím đặc
local inactiveBorderColor = "rgba(" .. c.overlay1Alpha .. "55)"
local groupActiveColor    = c.secondary  -- rgb(EA7B47) — cam đặc
local groupInactiveColor  = "rgba(" .. c.overlay1Alpha .. "55)"

hl.config({
    general = {
        gaps_in = 4,
        -- top nhỏ hơn để window ôm sát waybar
        -- (1 window đã có smart-gaps = 0; đây là gap khi ≥2 window)
        gaps_out = { top = 4, right = 10, bottom = 10, left = 10 },

        border_size = 2,

        col = {
            active_border   = activeBorderColor,
            inactive_border = inactiveBorderColor,
        },

        resize_on_border = true,
        allow_tearing = false,

        layout = "dwindle",

        snap = {
            enabled = true,
        },
    },

    group = {
        col = {
            border_active          = groupActiveColor,
            border_inactive        = groupInactiveColor,
            border_locked_active   = activeBorderColor,
            border_locked_inactive = inactiveBorderColor,
        },

        groupbar = {
            enabled = true,
            height = 4,
            gradients = true,
            text_color = c.text,
            col = {
                active   = c.orange,
                inactive = c.overlay0,
            },
        },
    },

    decoration = {
        rounding = 12,
        rounding_power = 2.5,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,

        -- Chỉ dùng dim_inactive (overlay đen nhẹ) làm chỉ báo focus,
        -- không double-dim bằng opacity nữa.
        dim_inactive = true,
        dim_strength = 0.10,
        dim_special = 0.30,

        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = "rgba(00000066)",
            color_inactive = "rgba(00000033)",
            offset = { 0, 2 },
        },

        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            new_optimizations = true,
            xray = false,
            noise = 0.02,
            contrast = 1.05,
            brightness = 0.95,
            vibrancy = 0.15,
        },
    },
})

-- Layer blur: dùng hl.layer_rule trong windowrules.lua (blurls là cơ chế cũ, đã bỏ).
-- hyprlock tự blur background trong hyprlock.conf — không cần rule ở compositor.
