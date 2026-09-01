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

-- ── DEBUG — bật tạm cho Phase 2 (GPU/power), 2026-09-01 ──────────────────────
-- Mặc định Hyprland TẮT log (disable_logs = true). Bật lên để nếu mất display
-- hay crash backend thì còn bằng chứng — đúng cách đã dùng để tìm ra nguyên nhân
-- login loop 13/07 (AQ_DRM_DEVICES + by-path, xem modules/env.lua).
--
-- Log nằm ở: $XDG_RUNTIME_DIR/hypr/<instance>/hyprland.log
-- TẮT LẠI sau khi xong Phase 2: đổi về true (hoặc xoá block này).
hl.config({
    debug = {
        disable_logs = false,
    },
})
