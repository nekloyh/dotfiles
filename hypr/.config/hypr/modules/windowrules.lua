------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Suppress maximize requests from all apps
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag ghost windows
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Floating accent: thicker border + larger rounding to distinguish floats
-- (Hyprland 0.54 removed per-window bordercolor; only general:col.active_border applies)
hl.window_rule({
    name  = "float-distinct",
    match = { float = true },
    border_size = 3,
    rounding = 16,
})

-- Common dialogs / pickers float
hl.window_rule({
    name  = "float-common-dialogs",
    match = { class = "^(file_progress|confirm|dialog|download|notification|error|splash|confirmreset|org\\.gnome\\.FileRoller)$" },
    float = true,
})
hl.window_rule({
    name  = "float-by-title",
    match = { title = "^(Open File|Save File|Library|Choose Files|File Operation Progress)$" },
    float = true,
})

-- Pavucontrol / nm-applet
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|nm-connection-editor|blueman-manager)$" },
    float  = true,
    size   = { 720, 540 },
    center = true,
})

-- Picture-in-Picture
hl.window_rule({
    name  = "pip-firefox",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
    size  = { 480, 270 },
    -- góc dưới-phải, chừa lề 20px (tương đương "100%-w-20 100%-h-20" cũ)
    move  = { "monitor_w-window_w-20", "monitor_h-window_h-20" },
})

-- Idle inhibit — hypridle KHÔNG dim màn hình khi có window fullscreen được focus
-- (xem video/thuyết trình 30' không bị tối màn giữa chừng)
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})
-- mpv: chặn idle ngay cả khi windowed, miễn là đang focus
hl.window_rule({
    name  = "idle-inhibit-mpv",
    match = { class = "^(mpv)$" },
    idle_inhibit = "focus",
})

-- Scratchpad terminal (SUPER+S → scripts/scratchpad.sh)
hl.window_rule({
    name  = "scratchpad-term",
    match = { class = "^(scratchpad)$" },
    float  = true,
    size   = { 1580, 930 },
    center = true,
    workspace = "special:magic",
})

-- Shadow chỉ cho cửa sổ FLOAT.
-- Lý do: shadow.range = 12 lớn gấp 3 lần gaps_in = 4, nên trong lưới tiled bóng
-- của hai cửa sổ kề nhau chồng HOÀN TOÀN lên nhau — đọc ra là vệt bẩn chứ không
-- phải chiều sâu. Bóng chỉ có nghĩa khi có nền để đổ lên; trong lưới tiled thì
-- "nền" chính là cửa sổ bên cạnh. Bỏ ở đây trả lại cho bóng đúng một nghĩa:
-- thứ gì có bóng là thứ NỔI LÊN TRÊN (dialog, pavucontrol, PiP, scratchpad).
-- Tín hiệu focus của cửa sổ tiled do decoration.glow lo (xem decorations.lua).
hl.window_rule({
    name  = "no-shadow-tiled",
    match = { float = false },
    no_shadow = true,
})

-- Smart gaps: no gaps when only 1 tiled window or fullscreen
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding = 0,
})

hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding = 0,
})

--------------
--- LAYERS ---
--------------
hl.layer_rule({
    match = { namespace = "swaync-control-center" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    match = { namespace = "walker" },
    -- no_anim ĐÃ BỎ: walker là bề mặt được gọi ra có ý thức nhiều nhất trong
    -- ngày, mà lại là bề mặt duy nhất xuất hiện không một chuyển động nào.
    -- Giờ nó dùng layersIn (easeOutExpo 220ms, popin 92%) — 80% quãng đường
    -- xong ở 51ms nên KHÔNG chậm hơn về cảm giác, chỉ là có đà tới.
    blur = true,
    ignore_alpha = 0.1,
})

hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.1,
    -- Bar ở cạnh trên → trượt xuống từ cạnh trên thay vì popin giữa màn
    animation = "slide top",
})

-- Notification popup của swaync (góc trên) — trượt từ cạnh trên, khớp hướng xuất hiện
hl.layer_rule({
    match = { namespace = "swaync-notification-window" },
    animation = "slide top",
})

-- Screenshot tools — tắt animation để slurp/hyprpicker không leak popin residual vào grim capture.
-- Lý do: layersOut "popin 80%" co lại từ anchor → grim chụp sau khi slurp exit vẫn thấy layer
-- đang co lại thành viền xám tại góc selection. noanim → layer biến mất ngay lập tức.
hl.layer_rule({ match = { namespace = "selection" },  no_anim = true })
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })
