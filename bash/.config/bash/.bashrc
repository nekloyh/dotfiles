#
# ~/.bashrc — minimal fallback for tty rescue / chroot
#

[[ $- != *i* ]] && return

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend checkwinsize cmdhist

export EDITOR="nvim"
export VISUAL="nvim"

alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  PS1='\[\e[38;5;141m\]\u\[\e[0m\]@\[\e[38;5;75m\]\h\[\e[0m\] \[\e[38;5;179m\]\w\[\e[0m\] \$ '
fi
