# powerlevel10k prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/Applications"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

fpath=(/usr/share/zsh/site-functions $fpath)

plugins=(
  git 
  zsh-autosuggestions 
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# fzf-tab
if [[ -f /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]]; then
  source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always --group-directories-first $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza --icons --color=always --group-directories-first $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:cat:*' fzf-preview 'bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null'

# fzf
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'

export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --info=inline
"

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# environment
export EDITOR="nvim"
export BROWSER="firefox"
export TERMINAL="alacritty"

HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

# aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --color=auto --icons --group-directories-first'
  alias ll='eza --color=auto --icons --group-directories-first -alF'
  alias la='eza --color=auto --icons --group-directories-first -A'
  alias tree='eza --tree --icons --group-directories-first'
else
  alias ls='ls --color=auto'
  alias ll='ls -alF --color=auto'
  alias la='ls -A --color=auto'
fi

if command -v trash-put >/dev/null 2>&1; then
  alias rm='trash-put'
  alias rmr='/usr/bin/rm'
fi

alias szrc='source ~/.config/zsh/.zshrc'
alias zrc='nvim ~/.config/zsh/.zshrc'

alias ncf='nvim ~/.config/nvim/init.lua'
alias acf='nvim ~/.config/alacritty/alacritty.toml'
alias hcf='nvim ~/.config/hypr/hyprland.conf'
alias nv='nvim'

alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'
alias proj='cd ~/Projects'

alias night='redshift -O 2400'
alias day='redshift -x'

alias tm='tmux'
alias tml='tmux list-sessions'
alias tma='tmux attach -t'
alias tmn='tmux new -s'
alias tmk='tmux kill-session -t'
alias main='tmux new -A -s main'

alias nvsu='sudoedit'


# micromamba/conda 
# lazy load
loadmamba() {
  source ~/.config/zsh/scripts/conda.zsh
  echo "[OK] micromamba has been initialized"
}
# to auto load -> uncomment the line below
# [[ -f ~/.config/zsh/scripts/conda.zsh ]] && source ~/.config/zsh/scripts/conda.zsh

# fnm
FNM_PATH="$HOME/.local/share/fnm"

if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# powerlevel10k config
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

