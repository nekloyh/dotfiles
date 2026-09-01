#!/usr/bin/env python3
"""Regenerate hardcoded palette mirrors from the canonical graphite-vivid.sh.

Waybar Pango markup, Starship TOML palette and SwayNC CSS-vars can't @import the
CSS palette, so they mirror hex by hand. This keeps them in sync after a palette
edit. Auto-rewrites the marked regions (# >>> gv-mirror ... # <<< gv-mirror) in
starship.toml + waybar/config.jsonc; prints a copy-paste reference for the
SwayNC :root and tmux blocks (those interleave alpha/decimal/format strings).

Usage:  python3 ~/.config/colors/graphite-vivid/render-mirrors.py
"""
import os, re, sys

HOME = os.path.expanduser("~")
SH   = f"{HOME}/.config/colors/graphite-vivid/graphite-vivid.sh"

# --- parse canonical palette: export NAME="#hex" -> {name: hex} ---
pal = {}
for m in re.finditer(r'export ([A-Z0-9_]+)="(#[0-9a-fA-F]{6})"', open(SH).read()):
    pal[m.group(1).lower()] = m.group(2).lower()

def c(name):
    if name not in pal:
        sys.exit(f"missing palette var: {name}")
    return pal[name]

def rgb(name):  # "#rrggbb" -> "r, g, b"
    h = c(name).lstrip("#")
    return f"{int(h[0:2],16)}, {int(h[2:4],16)}, {int(h[4:6],16)}"

def replace_between(path, start, end, body):
    lines = open(path).read().split("\n")
    try:
        si = next(i for i, l in enumerate(lines) if start in l)
        ei = next(i for i, l in enumerate(lines) if end in l)
    except StopIteration:
        print(f"  ! markers not found in {path} — skipped"); return
    new = lines[: si + 1] + body.split("\n") + lines[ei:]
    open(path, "w").write("\n".join(new))
    print(f"  ✔ {os.path.basename(path)}")

# ---------------------------------------------------------------- Starship
# semantic/compat alias -> canonical palette key
S = dict(crust="crust", mantle="mantle", base="base", surface0="surface0",
         surface1="surface1", surface2="surface2", surface3="surface3",
         overlay0="overlay0", overlay1="overlay1", overlay2="overlay2",
         text="text", text_bright="text_bright", subtext0="subtext0", subtext1="subtext1",
         rosewater="magenta100", flamingo="magenta300", pink="magenta", mauve="violet",
         red="red", maroon="red700", peach="orange", yellow="yellow", green="green",
         teal="cyan", sky="blue300", sapphire="blue", blue="blue", lavender="violet300",
         violet950="violet950", violet900="violet900")
g = {k: c(v) for k, v in S.items()}
starship_body = f"""# --- background ---
crust    = "{g['crust']}"
mantle   = "{g['mantle']}"
base     = "{g['base']}"

surface0 = "{g['surface0']}"
surface1 = "{g['surface1']}"
surface2 = "{g['surface2']}"
surface3 = "{g['surface3']}"

overlay0 = "{g['overlay0']}"
overlay1 = "{g['overlay1']}"
overlay2 = "{g['overlay2']}"

# --- text ---
text         = "{g['text']}"
text_bright  = "{g['text_bright']}"
subtext0     = "{g['subtext0']}"
subtext1     = "{g['subtext1']}"

# --- accents (graphite-vivid, rebalanced) ---
rosewater = "{g['rosewater']}"
flamingo  = "{g['flamingo']}"
pink      = "{g['pink']}"
mauve     = "{g['mauve']}"
red       = "{g['red']}"
maroon    = "{g['maroon']}"
peach     = "{g['peach']}"
yellow    = "{g['yellow']}"
green     = "{g['green']}"
teal      = "{g['teal']}"
sky       = "{g['sky']}"
sapphire  = "{g['sapphire']}"
blue      = "{g['blue']}"
lavender  = "{g['lavender']}"

# Pill / dark accent shades
violet950 = "{g['violet950']}"   # git branch pill bg (dark violet-tinted)
violet900 = "{g['violet900']}\""""

# ---------------------------------------------------------------- Waybar Pango
waybar_body = f"""                // >>> gv-mirror (regen: render-mirrors.py)
                "months":   "<span color='{c('violet')}'><b>{{}}</b></span>",
                "days":     "<span color='{c('text')}'>{{}}</span>",
                "weeks":    "<span color='{c('cyan')}'><i>w{{}}</i></span>",
                "weekdays": "<span color='{c('orange')}'><b>{{}}</b></span>",
                "today":    "<span color='{c('red')}'><b><u>{{}}</u></b></span>"
                // <<< gv-mirror"""
# note: the // markers are re-emitted so this block includes them; strip the
# wrapper marker lines from replace so we don't duplicate.
waybar_inner = "\n".join(waybar_body.split("\n")[1:-1])

# ---------------------------------------------------------------- FZF (zsh + fish)
# FZF_DEFAULT_OPTS phải nội suy hex trực tiếp (fzf không đọc CSS/TOML). Trước đây
# block này được hardcode NHÂN ĐÔI ở zsh/.zshrc và fish/config.fish, và đợt
# rebalance palette 2026-07 bỏ sót cả hai -> kẹt ở thế hệ màu cũ suốt 2 tháng.
def fzf_lines():
    return [
        f"  --color=fg:{c('text')},bg:{c('base')},hl:{c('yellow')}",
        f"  --color=fg+:{c('text_bright')},bg+:{c('selection')},hl+:{c('yellow300')}",
        f"  --color=info:{c('cyan')},prompt:{c('violet')},pointer:{c('magenta')}",
        f"  --color=marker:{c('green')},spinner:{c('orange')},header:{c('cyan300')}",
        f"  --color=border:{c('border')},gutter:{c('base')}",
    ]

_common = ["  --height=40%", "  --layout=reverse", "  --border", "  --info=inline"] + fzf_lines()
fzf_zsh  = 'export FZF_DEFAULT_OPTS="\n' + "\n".join(_common) + '\n"'
fzf_fish = 'set -gx FZF_DEFAULT_OPTS "\n' + "\n".join(_common) + '\n"'

print("Regenerating mirrors from graphite-vivid.sh:")
replace_between(f"{HOME}/.config/starship/starship.toml",
                "# >>> gv-mirror", "# <<< gv-mirror", starship_body)
replace_between(f"{HOME}/.config/waybar/config.jsonc",
                "// >>> gv-mirror", "// <<< gv-mirror", waybar_inner)
replace_between(f"{HOME}/.config/zsh/.zshrc",
                "# >>> gv-mirror fzf", "# <<< gv-mirror fzf", fzf_zsh)
replace_between(f"{HOME}/.config/fish/config.fish",
                "# >>> gv-mirror fzf", "# <<< gv-mirror fzf", fzf_fish)

# ---------------------------------------------------------------- Reference
print("\nManual-sync reference (interleaved alpha/decimal — paste as needed):")
print(f"  SwayNC ~/.config/swaync/style.css  :root")
print(f"    --cc-bg: rgba({rgb('base')}, 0.92)         base @92%")
print(f"    --noti-bg: {rgb('surface0')}               surface0")
print(f"    --noti-bg-darker: rgb({rgb('mantle')})     mantle")
print(f"    --noti-bg-hover: rgba({rgb('surface1')}, 0.75)")
print(f"    --noti-bg-focus: rgba({rgb('violet')}, 0.16)   violet")
print(f"    --noti-close-bg-hover: rgba({rgb('red')}, 0.20) red")
print(f"    --text-color: {c('text')}  --text-color-disabled: {c('overlay2')}  --bg-selected: {c('violet')}")
print(f"  tmux ~/.config/tmux/tmux.conf (inline fg=/bg= trong status format)")
print(f"    accent bar violet {c('violet')} · window-current green {c('green')} · clock {c('orange')} · host {c('blue')} · date {c('violet300')}")
