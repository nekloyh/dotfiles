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
-- ── 3c (2026-09-01): ép aquamarine CHỈ dùng iGPU ────────────────────────────
-- Đo được: dGPU không bao giờ vào D3 khi Hyprland + hyprpaper giữ fd
-- /dev/nvidia0. Bằng chứng nhân quả (boot 14:31): nvidia-drm khởi tạo lúc
-- 14:31:21, Hyprland chạy lúc 14:32:35 — cách 74s; runtime_suspended_time
-- dừng ở 51 931 ms (~52s) rồi KHÔNG tăng thêm một mili-giây nào nữa.
-- dGPU ở P8 tốn 12,7 W liên tục (đã là sau khi bật GSP; trước đó 17,0 W).
--
-- ĐÁNH ĐỔI: HDMI-A-1 hard-wire qua dGPU ⇒ MẤT màn ngoài. User xác nhận
-- 2026-09-01 hiện không dùng màn rời. Cần lại thì comment 2 dòng dưới rồi
-- ĐĂNG XUẤT/ĐĂNG NHẬP (hyprctl reload KHÔNG nạp lại env).
-- CUDA/ollama/Docker KHÔNG ảnh hưởng: chúng mở /dev/nvidia* trực tiếp, không
-- qua compositor. App đồ hoạ vẫn chạy dGPU được bằng PRIME offload.
--
-- Vì sao là /dev/dri/intel chứ không phải by-path hay cardN: xem khối trên.
-- Symlink do system/udev/61-intel-dri.rules tạo, khớp theo ĐỊA CHỈ PCI
-- (KERNELS=="0000:00:02.0"), KHÔNG theo ATTRS{vendor} — vendor 0x8086 khớp cả
-- card NVIDIA vì cha nó là PCI root port của Intel (đã kiểm bằng udevadm).
--
-- GUARD: chỉ set khi symlink CÓ THẬT. Fail-closed — nếu udev rule chưa cài,
-- hay đổi BIOS sang mode Discrete (iGPU tắt hẳn, symlink biến mất), thì env
-- không được set và aquamarine tự dò như cũ. Không có guard này thì đúng kịch
-- bản login loop 13/07: config hỏng nằm im tới lần đăng nhập kế tiếp.
local function readable(path)
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

if readable("/dev/dri/intel") then
    hl.env("AQ_DRM_DEVICES", "/dev/dri/intel")
end

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
