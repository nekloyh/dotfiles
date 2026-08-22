-- Keybinds --
-- https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- Mapping flags từ hyprlang cũ:
--   binde  → { repeating = true }
--   bindl  → { locked = true }
--   bindel → { locked = true, repeating = true }
--   bindm  → { mouse = true }

local programs = require("modules/programs")

hl.config({
    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        movefocus_cycles_fullscreen = false,
    },
})

local mainMod = "SUPER"

------------
--- APPS ---
------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + C",      hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t"))

-- Walker launcher (replaces rofi drun on SUPER+D)
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("pkill walker || walker"))
hl.bind(mainMod .. " + D",     hl.dsp.exec_cmd("pkill walker || walker"))

-- Walker — clipboard history
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("walker -m clipboard"))
-- Walker — emoji/symbols (moved off "." which now switches monitor focus)
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.exec_cmd("walker -m symbols"))

-- Lock & power
-- SUPER+L bị chiếm bởi vim-style movefocus (bên dưới) — dùng SUPER+ESCAPE thay thế.
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("wlogout"))

-- Toggle blur intensity (chuyển từ middle-click battery trên waybar về bind riêng)
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/changeBlur.sh"))

--------------------------
--- WINDOW MANAGEMENT  ---
--------------------------
hl.bind(mainMod .. " + W",         hl.dsp.window.close())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + V",         hl.dsp.window.float())
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + G",         hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab",         hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev())
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.center())

-- Focus (vim-style)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Move active window within workspace.
-- group_aware = như movewindow, NHƯNG nếu đích là một group thì
-- nhập window vào group đó — group dùng được hoàn toàn bằng bàn phím.
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d", group_aware = true }))

-- Rút window đang active ra khỏi group
hl.bind(mainMod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }))

-- Move active window to next/prev monitor
hl.bind(mainMod .. " + ALT + h", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + ALT + l", hl.dsp.window.move({ monitor = "r" }))
hl.bind(mainMod .. " + ALT + k", hl.dsp.window.move({ monitor = "u" }))
hl.bind(mainMod .. " + ALT + j", hl.dsp.window.move({ monitor = "d" }))

-- Switch monitor focus
hl.bind(mainMod .. " + comma",  hl.dsp.focus({ monitor = "-1" }))
hl.bind(mainMod .. " + period", hl.dsp.focus({ monitor = "+1" }))

-- Cycle window focus (Alt+Tab style) — kèm alter_zorder để window float
-- được kéo lên trên cùng thay vì focus mà vẫn bị che
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
hl.bind("ALT + SHIFT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

---------------
--- RESIZE  ---
---------------
-- Quick resize (held)
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -50, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), { repeating = true })

-- Resize submap — Super+R to enter, hjkl to resize, Esc/Enter to exit
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("h", hl.dsp.window.resize({ x = -30, y = 0,   relative = true }), { repeating = true })
    hl.bind("l", hl.dsp.window.resize({ x = 30,  y = 0,   relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0,   y = -30, relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0,   y = 30,  relative = true }), { repeating = true })
    hl.bind("SHIFT + h", hl.dsp.window.resize({ x = -100, y = 0,    relative = true }), { repeating = true })
    hl.bind("SHIFT + l", hl.dsp.window.resize({ x = 100,  y = 0,    relative = true }), { repeating = true })
    hl.bind("SHIFT + k", hl.dsp.window.resize({ x = 0,    y = -100, relative = true }), { repeating = true })
    hl.bind("SHIFT + j", hl.dsp.window.resize({ x = 0,    y = 100,  relative = true }), { repeating = true })
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

------------------
--- WORKSPACES ---
------------------
-- Switch workspace: SUPER + [1-0]
-- Move window to workspace (follow): SUPER + SHIFT + [1-0]
-- Move window silently (no follow): SUPER + CTRL + SHIFT + [1-0]
for i = 1, 10 do
    local key = i % 10 -- phím 0 = workspace 10
    hl.bind(mainMod .. " + " .. key,                      hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,              hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. key,       hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mainMod .. " + grave", hl.dsp.focus({ workspace = "previous" }))

-- Workspace scroll on monitor (mouse wheel)
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad — tự spawn terminal lần đầu, sau đó toggle (xem scripts/scratchpad.sh)
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd("~/.config/hypr/scripts/scratchpad.sh"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

------------------
--- SCREENSHOT ---
------------------
-- Screenshot — wrapper riêng (~/.config/hypr/scripts/screenshot.sh) thay hyprshot.
-- Lý do: hyprshot's -z freeze vẫn để slurp selection rectangle leak thành "viền đen" trong
-- ảnh. Wrapper dùng slurp với colors trong suốt + hyprpicker freeze → capture sạch hoàn toàn.
-- Modifier nâng dần: bare=clipboard-only, SHIFT=save, SUPER=window, SUPER+SHIFT=output.
local screenshot = "~/.config/hypr/scripts/screenshot.sh"
hl.bind("Print",                         hl.dsp.exec_cmd(screenshot .. " region-clip"))
hl.bind("SHIFT + Print",                 hl.dsp.exec_cmd(screenshot .. " region"))
hl.bind(mainMod .. " + Print",           hl.dsp.exec_cmd(screenshot .. " window"))
hl.bind(mainMod .. " + SHIFT + Print",   hl.dsp.exec_cmd(screenshot .. " output"))

--------------------
--- SCREEN RECORD ---
--------------------
-- Quay màn hình — wf-recorder + VAAPI (Intel iGPU) + mic & âm thanh hệ thống.
-- Cùng một keybind là toggle: bấm lần đầu để bắt đầu, bấm lại để dừng & lưu mp4 vào
-- ~/Videos/Recordings. ALT+Print = chọn vùng, ALT+SHIFT+Print = nguyên màn hình focus.
local screenrecord = "~/.config/hypr/scripts/screenrecord.sh"
hl.bind("ALT + Print",         hl.dsp.exec_cmd(screenrecord .. " region"))
hl.bind("ALT + SHIFT + Print", hl.dsp.exec_cmd(screenrecord .. " full"))

-------------
--- MEDIA ---
-------------
-- Volume/brightness đi qua script chung với waybar → cùng step, cùng limit,
-- cùng notification, dù bấm phím hay scroll trên bar.
local volume = "~/.config/hypr/scripts/volume.sh"
local brightness = "~/.config/hypr/scripts/brightness.sh"

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volume .. " --inc"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(volume .. " --dec"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(volume .. " --toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(volume .. " --toggle-mic"), { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(brightness .. " --inc"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(brightness .. " --dec"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
