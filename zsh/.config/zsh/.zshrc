# PATH
# typeset -U: khử trùng lặp PATH. .zshrc chạy cho MỌI interactive shell và các dòng
# export PATH bên dưới (+ fnm dòng ~150, opencode dòng ~300) đều prepend không kiểm tra,
# nên shell lồng nhau (alacritty -> tmux -> subshell) nhân đôi toàn bộ PATH.
typeset -U path PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/Applications"
export PATH="$HOME/.cargo/bin:$PATH"

# oh-my-zsh (no theme — starship takes over at end of file)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

fpath=(/usr/share/zsh/site-functions $fpath)

plugins=(
  git
  zsh-autosuggestions
)
# NOTE: zsh-syntax-highlighting is intentionally NOT here — it is sourced at the
# VERY END of this file (it must load after all custom widgets/keybindings).

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

# >>> gv-mirror fzf — regen bằng `python3 ~/.config/colors/graphite-vivid/render-mirrors.py`
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --info=inline
  --color=fg:#c8ccd0,bg:#11131a,hl:#e3b42c
  --color=fg+:#e7e8ea,bg+:#2e3252,hl+:#fbd064
  --color=info:#39c0b4,prompt:#8388e8,pointer:#e36da7
  --color=marker:#99be42,spinner:#ea7b47,header:#6bdace
  --color=border:#5c626e,gutter:#11131a
"
# <<< gv-mirror fzf

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# environment
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="firefox"
export TERMINAL="alacritty"
export MANPAGER="sh -c 'col -bx | bat -l man -p --paging=always'"
export MANROFFOPT="-c"
# HISTFILE is set ONCE in ~/.zshenv (XDG: ~/.local/state/zsh/history) so every
# zsh — interactive or not — agrees on a single history file. Do not set it here.

HISTSIZE=10000
SAVEHIST=10000

setopt EXTENDED_HISTORY        # ghi timestamp + thời lượng cho mỗi lệnh
setopt SHARE_HISTORY           # chia sẻ history giữa các phiên
setopt INC_APPEND_HISTORY      # ghi ngay xuống file — CẦN để hook _persist_ok_history flush print -sr
setopt HIST_IGNORE_SPACE       # lệnh mở đầu bằng dấu cách -> không lưu
setopt HIST_IGNORE_DUPS        # bỏ trùng LIÊN TIẾP (giữ các lần lặp cách quãng + timestamp)
setopt HIST_FIND_NO_DUPS       # Ctrl-R bỏ qua bản trùng (chỉ ảnh hưởng hiển thị, KHÔNG xoá khỏi file)
setopt HIST_REDUCE_BLANKS      # gọn khoảng trắng thừa trong lệnh
setopt HIST_VERIFY             # bung history-expansion ra dòng lệnh trước khi chạy
# (Cố ý KHÔNG bật HIST_SAVE_NO_DUPS / HIST_IGNORE_ALL_DUPS — chúng sẽ xoá mọi
#  bản trùng cũ khỏi toàn bộ file, làm mất phần lớn lịch sử. Bật nếu bạn muốn
#  history gọn hơn và chấp nhận đánh đổi.)
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
alias hcf='nvim ~/.config/hypr/hyprland.lua'
alias nv='nvim'

alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'
alias proj='cd ~/Projects'

alias night='pkill gammastep 2>/dev/null; gammastep -O 2400 >/dev/null 2>&1 & disown'
alias day='pkill gammastep 2>/dev/null'

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

# uv
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
if command -v starship >/dev/null 2>&1; then
# ── Ghi đè alias git của oh-my-zsh cho khớp abbr fish ─────────────────────────
# oh-my-zsh (qua gói cachyos-zsh-config) nạp 250 alias git, trong đó 5 cái TRÙNG
# TÊN với abbr tự viết trong fish/conf.d/abbreviations.fish nhưng NGƯỢC nghĩa.
# Nguy hiểm nhất là `gcm`: fish = `git commit -m`, oh-my-zsh = `git checkout main`
# — gõ theo thói quen ở nhầm shell là nhảy nhánh thay vì commit.
# Nguồn sự thật là abbr fish (do user viết); zsh khớp theo.
alias gc='git commit'
alias gca='git commit --amend'
alias gcm='git commit -m'
alias gl='git log --oneline --graph --decorate'
alias gst='git stash'

# ── Nhắc ~/Dotfiles chưa commit/push ─────────────────────────────────────────
# Đặt $DOTFILES_DIRTY cho [env_var.DOTFILES_DIRTY] của starship. Chi phí
# (git status ~2ms + rev-list ~1ms) được throttle 300s nên biên độ trên prompt
# xấp xỉ 0 — starship KHÔNG fork gì cả, chỉ đọc biến.
_gv_dotfiles_dirty() {
    local now=$EPOCHSECONDS
    (( now - ${_GV_DF_LAST:-0} < 300 )) && return
    _GV_DF_LAST=$now
    local d u
    d=$(git -C "$HOME/Dotfiles" status --porcelain 2>/dev/null | wc -l)
    u=$(git -C "$HOME/Dotfiles" rev-list --count @{u}..HEAD 2>/dev/null) || u=0
    # glyph dùng MỘT lần làm tiền tố, rồi mới tới các số.
    local out=""
    (( d > 0 )) && out="${d}"
    (( u > 0 )) && out="${out:+$out }↑${u}"
    [[ -n $out ]] && out=" $out"
    export DOTFILES_DIRTY="$out"
}
zmodload -F zsh/datetime +p:EPOCHSECONDS 2>/dev/null
# autoload tại chỗ: add-zsh-hook chỉ được autoload ở cuối file (~dòng 300),
# sau block này -> nếu không tự autoload thì hook không bao giờ được đăng ký.
autoload -Uz add-zsh-hook
add-zsh-hook precmd _gv_dotfiles_dirty

  eval "$(starship init zsh)"

  # Minimal-unique abbreviated cwd: mỗi thư mục cha rút xuống tiền tố ngắn nhất
  # đủ phân biệt với các thư mục anh em thực tế; thư mục hiện tại giữ nguyên.
  # /home/user1/project/sr1c/app  ->  /h/user1/p/sr1/app
  function _starship_short_pwd() {
    emulate -L zsh
    local p=${PWD/#$HOME/\~}
    local prefix=""
    [[ $p == /* ]] && prefix="/"

    local -a segs realsegs
    segs=("${(@s:/:)p}")
    segs=("${(@)segs:#}")
    realsegs=("${segs[@]}")
    [[ $realsegs[1] == "~" ]] && realsegs[1]=$HOME   # đường dẫn thật để glob

    local n=${#segs} out="" i seg parent L len other ok
    local -a sibs

    for (( i = 1; i <= n; i++ )); do
      seg=$segs[i]
      if (( i == n )); then
        out+=$seg                       # thư mục hiện tại: giữ đầy đủ
      elif [[ $seg == "~" ]]; then
        out+="~/"                        # giữ nguyên xử lý ~ như cũ
      else
        # thư mục cha thật (dùng tên gốc, ~ đã được đổi về $HOME)
        parent="${prefix}${(j:/:)realsegs[1,i-1]}"
        [[ -z $parent ]] && parent="/"

        # các thư mục anh em (cả ẩn lẫn thường)
        sibs=( ${parent}/*(/N:t) ${parent}/.*(/N:t) )

        # tiền tố ngắn nhất khiến seg là duy nhất trong số anh em
        len=0
        for (( L=1; L<=${#seg}; L++ )); do
          ok=1
          for other in $sibs; do
            [[ $other == $seg ]] && continue
            if [[ ${other[1,L]} == ${seg[1,L]} ]]; then ok=0; break; fi
          done
          (( ok )) && { len=$L; break; }
        done
        (( len == 0 )) && len=${#seg}                        # không phân biệt được -> cả tên
        [[ $seg == .* ]] && (( len < 2 )) && (( ${#seg} >= 2 )) && len=2

        out+="${seg[1,len]}/"
      fi
    done

    print -rn -- "$prefix$out"
  }

  # Transient prompt: on Enter, collapse the just-executed prompt to a short path + character
  function zle-line-init() {
    emulate -L zsh
    # Re-enable application cursor-key mode: this widget overrides oh-my-zsh's
    # zle-line-init (which called `echoti smkx`). Without it the terminal stays
    # in normal mode, so Up/Down send ^[[A/^[[B instead of the ^[OA/^[OB that
    # omz bound to history search -> arrow up/down would stop working.
    (( ${+terminfo[smkx]} )) && echoti smkx
    [[ $CONTEXT == start ]] || return 0
    while true; do
      zle .recursive-edit
      local -i ret=$?
      [[ $ret == 0 && $KEYS == $'\4' ]] || break
      [[ -o ignore_eof ]] || exit 0
    done
    local saved_prompt=$PROMPT
    local saved_rprompt=$RPROMPT
    PROMPT="%B%F{#76c5ff}$(_starship_short_pwd)%f%b $(starship module character)"
    RPROMPT=''
    zle .reset-prompt
    PROMPT=$saved_prompt
    RPROMPT=$saved_rprompt
    if (( ret )); then
      zle .send-break
    else
      zle .accept-line
    fi
    return ret
  }
  zle -N zle-line-init
fi

# --- Di chuyển con trỏ theo DÒNG MÀN HÌNH cho lệnh dài bị wrap ---------------
# zle chỉ biết "dòng logic" (tách bởi \n). Với một lệnh dài duy nhất bị wrap
# tràn nhiều dòng trên màn hình (vd: echo "đoạn văn rất dài..."), Up/Down mặc
# định không nhảy được giữa các dòng wrap -> nó coi cả lệnh là 1 dòng và rơi
# vào history. Cặp widget dưới đây cho phép Up/Down di chuyển theo dòng-màn-hình
# (bước = $COLUMNS ký tự) KHI buffer không có newline thật; ngược lại (lệnh
# nhiều dòng thật hoặc lệnh ngắn) thì giữ nguyên hành vi cũ: lên/xuống dòng
# logic, hoặc tìm trong lịch sử. Lưu ý: prompt nằm cùng dòng nên ở sát dòng
# trên cùng vị trí ngang có thể lệch vài cột — đây là giới hạn không tránh được.
_up_screen_line() {
  emulate -L zsh
  if [[ $BUFFER != *$'\n'* ]] && (( CURSOR >= COLUMNS )); then
    (( CURSOR -= COLUMNS ))
  else
    zle up-line-or-beginning-search
  fi
}
_down_screen_line() {
  emulate -L zsh
  if [[ $BUFFER != *$'\n'* ]] && (( CURSOR + COLUMNS <= $#BUFFER )); then
    (( CURSOR += COLUMNS ))
  elif [[ $BUFFER != *$'\n'* ]] && (( CURSOR / COLUMNS < $#BUFFER / COLUMNS )); then
    CURSOR=$#BUFFER            # dòng wrap cuối (chưa đầy) -> về cuối buffer
  else
    zle down-line-or-beginning-search
  fi
}
zle -N _up_screen_line
zle -N _down_screen_line
bindkey '^[[A' _up_screen_line   '^[OA' _up_screen_line
bindkey '^[[B' _down_screen_line '^[OB' _down_screen_line

# --- Chỉ lưu lệnh THÀNH CÔNG (exit 0) vào history ----------------------------
# zshaddhistory chạy TRƯỚC khi thực thi nên chưa biết exit code -> trả về 1 để
# giữ lệnh trong phiên hiện tại (Up-arrow vẫn gọi lại sửa được) nhưng KHÔNG ghi
# xuống file. Sau khi lệnh chạy xong, precmd kiểm tra $?; nếu == 0 mới ghi.
autoload -Uz add-zsh-hook
zshaddhistory() { _pending=${1%%$'\n'}; return 1; }
_persist_ok_history() {
  local r=$?
  if (( r == 0 )) && [[ -n $_pending ]]; then
    print -sr -- "$_pending"
  fi
  _pending=
}
add-zsh-hook precmd _persist_ok_history
# Đặt hook này chạy ĐẦU TIÊN trong precmd để đọc đúng $? của lệnh vừa chạy,
# trước khi precmd của starship thay đổi $?.
precmd_functions=(_persist_ok_history ${precmd_functions:#_persist_ok_history})

# --- zsh-syntax-highlighting: BẮT BUỘC nạp ở DÒNG CUỐI, sau mọi widget/bindkey
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# opencode
export PATH=/home/n91ym1nhky/.opencode/bin:$PATH
