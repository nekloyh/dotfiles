-- Monitors --

hl.monitor({ output = "eDP-1",    mode = "2560x1600@165", position = "0x0",    scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@75",  position = "2560x0", scale = 1 })

-- Fallback: any unknown monitor → preferred mode, auto-position, 1x scale
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
