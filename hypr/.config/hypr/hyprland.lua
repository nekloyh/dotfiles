-- Hyprland entrypoint (Lua config, Hyprland ≥0.55) --
--
-- File này được ưu tiên hơn hyprland.conf khi tồn tại.
-- hyprland.conf + modules/*.conf được GIỮ LẠI làm fallback:
-- rollback = đổi tên file này (vd hyprland.lua.disabled) rồi
-- `hyprctl reload full-reset` (hoặc restart Hyprland).
--
-- Mỗi require() là một scope Lua riêng — lỗi trong một module
-- không chặn các module còn lại.

require("modules/monitors")
require("modules/env")
require("modules/autostart")
require("modules/decorations")
require("modules/animations")
require("modules/windowrules")
require("modules/workspacerules")
require("modules/layout")
require("modules/misc")
require("modules/input")
require("modules/binds")
