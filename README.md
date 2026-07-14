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
sudo pacman -S --needed stow uwsm        # stow = linking, uwsm = autostart wrapper
stow */                                  # link every package …
# …or pick: stow hypr waybar fish starship
```

Stow refuses to overwrite existing real files — move/delete the conflicting
`~/.config/<app>` first, or use `stow --adopt <pkg>` to pull the current file into
the repo (then `git diff` to review).

### Enable services (not carried by dotfiles)

The autostart deliberately does *not* `exec-once` these — they run as `enable`d
systemd units (sole owner via systemd + D-Bus activation, so exec-once would
double-start). On a fresh machine:

```sh
# user session
systemctl --user enable --now \
  hyprpolkitagent.service swaync.service elephant.service gnome-keyring-daemon.socket

# system
sudo systemctl enable --now power-profiles-daemon.service
sudo systemctl enable --now fcitx5-lotus-server@$USER.service   # see IME section
```

## Packages

| Group | Packages |
|-------|----------|
| WM / desktop | `hypr` `waybar` `swaync` `walker` `wlogout` |
| Theme / look | `colors` `gtk` `qt` `xsettingsd` |
| Shell / terminal / tools | `zsh` `fish` `alacritty` `tmux` `starship` `btop` `mpv` |
| Input (Vietnamese IME) | `fcitx5` |
| Misc | `bash` `git` |

## Dependencies (Arch/CachyOS names)

```sh
sudo pacman -S --needed \
  stow uwsm \
  hyprland hyprpaper hypridle hyprlock hyprpolkitagent waybar swaync walker elephant \
  wl-clip-persist wlogout fish zsh starship alacritty tmux btop mpv fastfetch \
  qt5ct qt6ct kvantum xsettingsd papirus-icon-theme ttf-jetbrains-mono-nerd inter-font \
  bibata-cursor-theme power-profiles-daemon \
  fcitx5 fcitx5-gtk fcitx5-qt fcitx5-lotus
```

`power-profiles-daemon` powers the waybar profile module; `uwsm` wraps every
autostart entry into its own systemd scope. AUR/extra: `elephant` (walker
clipboard backend) may need `paru`/`yay` depending on your repos.

### Vietnamese IME (fcitx5 + lotus) — config alone is NOT enough

The `fcitx5` package carries the config (incl. `conf/lotus.conf` → `Mode="Uinput
(Super Smooth)"`), but a working setup on a new machine also needs:

- **Env vars** — already in `hypr/.config/hypr/modules/env.conf` (`QT_IM_MODULE`,
  `XMODIFIERS`, `SDL_IM_MODULE`, `INPUT_METHOD` = `fcitx`; `GTK_IM_MODULE` left empty
  for Wayland text-input). Needs a re-login to take effect.
- **Electron flags** — `~/.config/{code,antigravity-ide}-flags.conf` with
  `--enable-wayland-ime --wayland-text-input-version=3` (NOT tracked here — these are
  the excluded `*-flags.conf`; recreate them for VS Code / Antigravity IME).
- **Uinput service** — lotus' "Uinput" modes inject via `/dev/uinput` through a
  privilege-separated `uinput_proxy` user and `fcitx5-lotus-server@<user>.service`
  (system unit from the `fcitx5-lotus` package). Enable it:
  `sudo systemctl enable --now fcitx5-lotus-server@$USER.service`. If uinput typing
  misbehaves in an app, fall back to `Mode="Preedit"` in `conf/lotus.conf`.

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
- **`mimeapps.list`, `*-flags.conf`** — default-app associations and per-app Electron
  flags (the latter still needed for IME — see the IME section above).
- **System-level IME bits** — the `uinput_proxy` user + `fcitx5-lotus-server@.service`
  are package/root-managed, not dotfiles (see IME section).
