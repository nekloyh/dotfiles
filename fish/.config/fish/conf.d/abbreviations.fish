if not status is-interactive
    return
end

# Navigation
abbr -a -- - 'cd -'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a docs 'cd ~/Documents'
abbr -a desk 'cd ~/Desktop'
abbr -a proj 'cd ~/Projects'

# Editor / config shortcuts
abbr -a zrc 'nvim ~/.config/zsh/.zshrc'
abbr -a fcf 'nvim ~/.config/fish/config.fish'
abbr -a ncf 'nvim ~/.config/nvim/init.lua'
abbr -a acf 'nvim ~/.config/alacritty/alacritty.toml'
abbr -a hcf 'nvim ~/.config/hypr/hyprland.lua'
abbr -a sfr 'source ~/.config/fish/config.fish'

# Git
abbr -a g git
abbr -a gs 'git status'
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gcm 'git commit -m'
abbr -a gca 'git commit --amend'
abbr -a gco 'git checkout'
abbr -a gb 'git branch'
abbr -a gp 'git push'
abbr -a gpl 'git pull'
abbr -a gd 'git diff'
abbr -a gds 'git diff --staged'
abbr -a gl 'git log --oneline --graph --decorate'
abbr -a gst 'git stash'

# Tmux
abbr -a tm tmux
abbr -a tml 'tmux list-sessions'
abbr -a tma 'tmux attach -t'
abbr -a tmn 'tmux new -s'
abbr -a tmk 'tmux kill-session -t'
abbr -a main 'tmux new -A -s main'

# Misc
abbr -a night 'pkill gammastep 2>/dev/null; gammastep -O 2400 >/dev/null 2>&1 & disown'
abbr -a day 'pkill gammastep 2>/dev/null'
abbr -a nvsu sudoedit
