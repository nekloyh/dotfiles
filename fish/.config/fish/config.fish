# Interactive-only setup
if not status is-interactive
    return
end

# Environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER firefox
set -gx TERMINAL alacritty
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p --paging=always'"
set -gx MANROFFOPT -c

# PATH
fish_add_path -p $HOME/bin $HOME/.local/bin $HOME/.cargo/bin /usr/local/bin
fish_add_path -a $HOME/Applications

# fnm (Node version manager)
set -gx FNM_PATH "$HOME/.local/share/fnm"
if test -d $FNM_PATH
    fish_add_path -p $FNM_PATH
    fnm env --shell fish | source
end

# fzf colors (matches graphite-vivid)
set -gx FZF_DEFAULT_COMMAND 'fd --hidden --strip-cwd-prefix --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --strip-cwd-prefix --exclude .git'
set -gx FZF_DEFAULT_OPTS "
  --height=40%
  --layout=reverse
  --border
  --info=inline
  --color=fg:#c8ccd0,bg:#11131a,hl:#e0b020
  --color=fg+:#e7e8ea,bg+:#2e3252,hl+:#f5d04a
  --color=info:#4cc4b8,prompt:#8388e8,pointer:#e25aa0
  --color=marker:#9bc23c,spinner:#e26a2c,header:#74d6cc
  --color=border:#363b46,gutter:#11131a
"

# Aliases (functions that survive completion)
if type -q eza
    alias ls 'eza --color=auto --icons --group-directories-first'
    alias ll 'eza --color=auto --icons --group-directories-first -alF'
    alias la 'eza --color=auto --icons --group-directories-first -A'
    alias tree 'eza --tree --icons --group-directories-first'
end
if type -q trash-put
    alias rm trash-put
    alias rmr /usr/bin/rm
end
alias nv nvim
alias cat 'bat --paging=never'

# zoxide
if type -q zoxide
    zoxide init fish | source
end

# starship prompt + transient
set -gx STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
if type -q starship
    starship init fish | source
    function starship_transient_prompt_func
        starship module character
    end
    enable_transience
end
