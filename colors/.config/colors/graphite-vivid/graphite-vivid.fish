# ============================================================================
# Graphite Vivid — Fish shell color scheme
# Sources fish_color_* and fish_pager_color_* variables.
# Loaded from ~/.config/fish/conf.d/ on every interactive fish startup.
# Sibling files: graphite-vivid.alacritty.toml / .css / .hypr.conf / .sh / .toml / .nvim.lua
# ============================================================================

# Syntax highlighting
set -g fish_color_normal        c8ccd0
set -g fish_color_command       3aabf4
set -g fish_color_keyword       e36da7
set -g fish_color_quote         99be42
set -g fish_color_redirection   e36da7
set -g fish_color_end           39c0b4
set -g fish_color_error         ea6b62
set -g fish_color_param         c8ccd0
set -g fish_color_comment       969ca0 --italics
set -g fish_color_selection     --background=2e3252
set -g fish_color_search_match  --background=2e3252
set -g fish_color_operator      e58130
set -g fish_color_escape        e36da7
set -g fish_color_autosuggestion 72777d
set -g fish_color_valid_path    --underline
set -g fish_color_cwd           3aabf4
set -g fish_color_cwd_root      ea6b62
set -g fish_color_user          99be42
set -g fish_color_host          3aabf4
set -g fish_color_host_remote   e3b42c
set -g fish_color_cancel        ea6b62
set -g fish_color_option        e58130
set -g fish_color_history_current --bold

# Pager (autocomplete dropdown)
set -g fish_pager_color_completion   c8ccd0
set -g fish_pager_color_description  969ca0
set -g fish_pager_color_prefix       8388e8 --underline
set -g fish_pager_color_progress     39c0b4
set -g fish_pager_color_selected_background --background=2e3252
set -g fish_pager_color_selected_completion e7e8ea
set -g fish_pager_color_selected_description b0b5b9
set -g fish_pager_color_selected_prefix      fbd064 --underline
