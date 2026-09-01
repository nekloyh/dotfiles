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

        -- Đánh thức màn hình khi DPMS off. CẢ HAI mặc định của Hyprland là
        -- false — nghĩa là màn tắt xong thì gõ phím / rê chuột KHÔNG bật lại
        -- được, chỉ `dispatch dpms` mới bật. Đó là lý do "tắt màn tạm thời rồi
        -- mở lại bị lỗi": không phải driver hỏng, mà là không có đường thức.
        -- Đo 2026-09-01: chu trình dpms off->on modeset lại eDP-1 2560x1600@165
        -- sạch sẽ, kernel log không một lỗi drm/i915/nvidia.
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,
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
