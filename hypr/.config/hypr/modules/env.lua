-- Environment configuration --

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Cursor (theme set via gsettings/dconf, not env)
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

-- Aquamarine — primary GPU = Intel iGPU (00:02.0), fallback NVIDIA (01:00.0).
-- Hyprland ≥0.41 (aquamarine) đọc AQ_DRM_DEVICES; WLR_DRM_DEVICES là biến thời
-- wlroots và bị bỏ qua im lặng.
-- KHÔNG set AQ_DRM_DEVICES — để aquamarine tự dò GPU.
--
-- LÝ DO (2026-07-13, đây là nguyên nhân gây login loop): aquamarine tách danh
-- sách thiết bị bằng dấu HAI CHẤM ':'. Tên /dev/dri/by-path/pci-0000:00:02.0-card
-- CHỨA dấu ':' nên bị xé thành 3 mảnh rác ("/dev/dri/by-path/pci-0000", "00",
-- "02.0-card") → "Found no gpus to use" → CBackend::create() failed → Hyprland
-- crash ngay khi khởi động → SDDM đá về màn login (loop). Xác nhận trong
-- hyprland debug log. => by-path VỀ BẢN CHẤT không dùng được với AQ_DRM_DEVICES.
--
-- cardN (vd /dev/dri/card1) thì không có ':' nhưng máy này ĐÁNH SỐ KHÔNG ỔN ĐỊNH
-- (NVIDIA từng là card2 rồi card0; Intel=card1). Vì màn hình nội bộ (eDP) nằm
-- trên Intel và Intel là boot_vga, aquamarine tự dò sẽ chọn đúng Intel làm GPU
-- chính — an toàn hơn hardcode. NVIDIA vẫn dùng được qua PRIME offload
-- (__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <app>).
-- Nếu sau này muốn ép Intel-only bằng đường colon-free ỔN ĐỊNH: tạo udev symlink
-- (vd /dev/dri/intel) rồi hl.env("AQ_DRM_DEVICES", "/dev/dri/intel").
-- hl.env("AQ_DRM_DEVICES", ...)   (cố ý để trống)

-- Toolkit backend
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG_CURRENT_DESKTOP / XDG_SESSION_* are set by uwsm — do not duplicate here.

-- Wayland
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Qt
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- IME — fcitx5 (Qt/SDL/Java IM + XIM cho app XWayland)
-- GTK_IM_MODULE để TRỐNG có chủ đích: trên Wayland app GTK dùng Wayland text-input
-- frontend của fcitx5 (addon Wayland Diagnose khuyến nghị unset). App GTK chạy XWayland
-- vẫn nhận bộ gõ qua XMODIFIERS (XIM). Xem fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
-- hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("INPUT_METHOD", "fcitx")

-- NVIDIA
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "iHD")
-- hl.env("GBM_BACKEND", "nvidia-drm")
