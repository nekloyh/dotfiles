-- Workspaces --

-- Internal display
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1", persistent = true, default = true })
hl.workspace_rule({ workspace = "4", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "eDP-1", persistent = true })

-- External display
hl.workspace_rule({ workspace = "6",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "7",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "8",  monitor = "HDMI-A-1", persistent = true, default = true })
hl.workspace_rule({ workspace = "9",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-1", persistent = true })
