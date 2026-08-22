-- Animations — "alive but instant" --
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- Đơn vị tốc độ = decisecond (1 = 100ms).
--
-- Triết lý: mọi chuyển động THƯỜNG DÙNG kết thúc ≤ ~280ms (không chắn thao tác),
-- nhưng dùng curve giảm tốc mạnh (easeOutExpo) — 80% quãng đường xảy ra trong 1/3
-- thời gian đầu nên CẢM GIÁC gần như tức thì, phần đuôi chỉ là "hãm êm".
-- Cửa sổ mới có overshoot ~4% (softBack) — sống động mà không lố.
-- Đóng cửa sổ dùng ease-in nhanh: thứ biến mất phải biến mất ngay.

hl.config({
    animations = {
        enabled = true,
    },
})

-- == Curves ==
hl.curve("easeOutExpo", { type = "bezier", points = { {0.16, 1.00}, {0.30, 1.00} } }) -- giảm tốc mạnh — "bắn tới nơi rồi hãm êm"
hl.curve("softBack",    { type = "bezier", points = { {0.34, 1.27}, {0.64, 1.00} } }) -- overshoot ~4% — cửa sổ mới "nảy" nhẹ
hl.curve("easeInQuad",  { type = "bezier", points = { {0.55, 0.09}, {0.68, 0.53} } }) -- tăng tốc — cho thứ đang rời đi
hl.curve("linear",      { type = "bezier", points = { {0.00, 0.00}, {1.00, 1.00} } })

-- Default fallback
hl.animation({ leaf = "global",      enabled = true, speed = 2.4, bezier = "easeOutExpo" })

-- == Windows ==
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 2.8, bezier = "softBack",    style = "popin 85%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.6, bezier = "easeInQuad",  style = "popin 88%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.4, bezier = "easeOutExpo" })

-- == Fade ==
hl.animation({ leaf = "fade",    enabled = true, speed = 1.8, bezier = "easeOutExpo" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.4, bezier = "easeInQuad" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.6, bezier = "easeOutExpo" }) -- dim_inactive chuyển mượt khi đổi focus

-- == Layers (waybar, swaync, popups) ==
-- waybar/swaync có layer rule "animation slide top" riêng — hướng trượt khớp vị trí bar.
hl.animation({ leaf = "layersIn",  enabled = true, speed = 2.2, bezier = "easeOutExpo", style = "popin 92%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.4, bezier = "easeInQuad",  style = "fade" })

-- == Workspaces — slide định hướng (thấy được mình đi trái/phải) ==
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.6, bezier = "easeOutExpo", style = "slide" })

-- == Special workspace (scratchpad) — thả xuống từ trên như dropdown ==
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.4, bezier = "easeOutExpo", style = "slidefadevert 20%" })

-- == Border ==
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "easeOutExpo" })
-- borderangle: đã TẮT — border giờ là màu đặc (không gradient) nên xoay góc
-- không có gì để render. Nếu quay lại gradient border thì bật lại dòng dưới
-- (style mặc định "once" — chỉ xoay 1 vòng lúc reload, không loop tốn pin).
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear" })
