-- Misc --

local c = require("modules/colors")

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,

        vrr = 2,

        enable_swallow = true,
        swallow_regex = "^(Alacritty)$",

        focus_on_activate = false,
        animate_manual_resizes = false,

        middle_click_paste = false,
        background_color = c.crust,

        -- Nếu hyprlock crash, phiên lock mới được phép tiếp quản thay vì
        -- kẹt ở màn hình khoá chết (không nhập được password).
        allow_session_lock_restore = true,
    },
})
