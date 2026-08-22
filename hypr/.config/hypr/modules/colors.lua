-- Hyprland color palette — sourced from the central colors store.
-- Edit ~/.config/colors/graphite-vivid/graphite-vivid.hypr.conf to change the palette.
--
-- Parse trực tiếp file hyprlang canonical để giữ SINGLE SOURCE OF TRUTH:
-- mỗi dòng `$name = value` trở thành M.name = value.
-- Ví dụ: M.primary = "rgb(8388E8)", M.primaryAlpha = "8388E8".

local M = {}

local path = os.getenv("HOME") .. "/.config/colors/graphite-vivid/graphite-vivid.hypr.conf"
local f = io.open(path, "r")
if not f then
    error("colors.lua: cannot open palette file: " .. path)
end

for line in f:lines() do
    local name, value = line:match("^%$([%w_]+)%s*=%s*(.-)%s*$")
    if name and value and value ~= "" then
        M[name] = value
    end
end
f:close()

return M
