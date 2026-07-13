# dotfiles

Hyprland desktop on CachyOS (Wayland), themed **Graphite Vivid** (neutral graphite
surfaces + vivid accents, violet `#8388e8` primary — palette lives in the `colors`
package and every app derives from it).

Managed with [GNU Stow](https://www.gnu.org/software/stow/): each top-level folder is
a *package* whose inner tree mirrors `$HOME`. `stow <pkg>` symlinks it into place, so
edits in `~/.config/…` write straight back to this repo.

## Install on a new machine

```sh
git clone git@github.com:nekloyh/dotfiles.git ~/Dotfiles
cd ~/Dotfiles
sudo pacman -S stow                      # if not present
stow */                                  # link every package …
# …or pick: stow hypr waybar fish starship
```

Stow refuses to overwrite existing real files — move/delete the conflicting
`~/.config/<app>` first, or use `stow --adopt <pkg>` to pull the current file into
the repo (then `git diff` to review).

## Packages

| Group | Packages |
|-------|----------|
| WM / desktop | `hypr` `waybar` `swaync` `walker` `wlogout` |
| Theme / look | `colors` `gtk` `qt` `xsettingsd` |
| Shell / terminal / tools | `zsh` `fish` `alacritty` `tmux` `starship` `btop` `mpv` |
| Misc | `bash` `git` |

## Dependencies (Arch/CachyOS names)

`hyprland hyprpaper hypridle hyprlock hyprpolkitagent waybar swaync walker elephant
wl-clip-persist wlogout fish zsh starship alacritty tmux btop mpv fastfetch
qt5ct qt6ct kvantum xsettingsd papirus-icon-theme ttf-jetbrains-mono-nerd inter-font
bibata-cursor-theme` — plus `power-profiles-daemon` for the waybar profile module.

## ⚠️ Machine-specific — review after cloning

These carry values tied to this laptop; edit them on a new machine:

- **`hypr/.config/hypr/monitors.conf`** — monitor names / resolution / scale.
- **`hypr/.config/hypr/modules/env.conf`** — GPU. Currently no `AQ_DRM_DEVICES`
  (aquamarine auto-detects). On a different GPU layout, verify it still picks the
  right card. *Do not* use `/dev/dri/by-path/…` here — the `:` in those names is
  aquamarine's device separator and breaks the compositor.
- **`hypr/.config/hypr/hyprpaper.conf`** — wallpaper file paths (images not tracked).
- **`gtk/.config/gtk-3.0/bookmarks`** — Nautilus sidebar paths under `/home/<user>/`.
- A few CSS `@import` / `include` lines hardcode `/home/nekloyh` — fine if the new
  machine reuses the same username, otherwise sed them.

## Not included (by design)

- **Secrets** — SSH/GPG keys, `.git-credentials`, tokens, `.env` (see `.gitignore`).
- **App state / caches** — browsers, Electron apps, package stores.
- **fcitx5 IME**, `mimeapps.list`, `*-flags.conf` — left out of this repo.
