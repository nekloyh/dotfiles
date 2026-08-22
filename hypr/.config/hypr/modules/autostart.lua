--- Autostart ---
-- Chạy trên event "hyprland.start" (tương đương exec-once cũ — chỉ fire một lần
-- lúc khởi động, KHÔNG fire lại khi reload config).
-- Order = logical dependency phase. hl.exec_cmd là async (không chờ hoàn tất),
-- nhưng việc fire sớm các service "nền" giúp app phía sau thấy môi trường ready.
--
-- App/daemon bọc `uwsm app --` → mỗi cái một systemd scope riêng trong
-- app-graphical.slice: log vào journal theo unit (journalctl --user), cleanup
-- sạch khi logout, không dính vào cgroup của Hyprland.

hl.on("hyprland.start", function()
    -- --- Phase 1: theme bridge & auth ---
    -- xsettingsd publish GTK theme cho XWayland/non-native app trước khi waybar/UI khởi động.
    hl.exec_cmd("uwsm app -- xsettingsd")
    -- gnome-keyring (Secret Service): KHÔNG start ở đây — gnome-keyring-daemon.socket (enabled)
    -- + D-Bus activation là chủ sở hữu duy nhất, giống swaync.
    -- Polkit agent: hyprpolkitagent.service ENABLED (WantedBy=graphical-session.target) —
    -- systemd tự start, không cần exec-once. (pkexec, mount, GUI auth)

    -- --- Phase 2: desktop services ---
    hl.exec_cmd("uwsm app -- hyprpaper")
    hl.exec_cmd("uwsm app -- hypridle")
    -- swaync: KHÔNG start ở đây — systemd user unit (enabled, WantedBy=graphical-session.target)
    -- + D-Bus activation là chủ sở hữu duy nhất. launch.sh cũng không đụng vào nữa.

    -- --- Phase 3: input method ---
    -- XDG autostart /etc/xdg/autostart/org.fcitx.Fcitx5.desktop bị mask
    -- (~/.config/autostart/org.fcitx.Fcitx5.desktop Hidden=true) để tránh double-start.
    hl.exec_cmd("uwsm app -- fcitx5 -D")

    -- --- Phase 4: clipboard ---
    -- elephant     : clipboard history backend cho walker — elephant.service ENABLED
    --                (graphical-session.target.wants), systemd tự start; không exec-once nữa.
    -- wl-clip-persist : giữ entry cuối khi app nguồn đã đóng (text + image)
    hl.exec_cmd("uwsm app -- wl-clip-persist --clipboard regular")

    -- --- Phase 5: status bar (cuối — hiện trên background đã ready) ---
    hl.exec_cmd("uwsm app -- waybar")
    -- Workspace-layout sync theo event monitor added/removed (socket2) —
    -- thay module custom/monitor-layout-sync polling 2s cũ trong waybar.
    hl.exec_cmd("uwsm app -- ~/.config/waybar/scripts/monitor-events.sh")
end)
