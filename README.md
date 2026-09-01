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
| Editors | `nvim` `nano` |
| Input (Vietnamese IME) | `fcitx5` |
| Misc | `bash` `git` |
| Fonts | `fontconfig` |
| GTK theme (generated) | `theme` |
| systemd user units | `systemd` |
| Package sources (**không stow**) | `pkg` |
| File `/etc` cần sudo (**không stow**) | `system` |

## Dependencies (Arch/CachyOS names)

```sh
sudo pacman -S --needed \
  stow uwsm \
  hyprland hyprpaper hypridle hyprlock hyprpolkitagent waybar swaync walker elephant \
  wl-clip-persist wlogout fish zsh starship alacritty tmux btop mpv fastfetch neovim nano \
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

## Architecture decisions

### Shell parity: zsh and fish stay in sync (2026-09-01)

zsh is the login shell and what alacritty starts; `fish_history` was last touched
three months ago and no fish process is usually running. Fish is kept anyway, and
kept **fully in sync** — a deliberate choice so switching shells stays a one-line
change rather than a migration.

The cost is real and this batch paid it three times: the FZF palette, the git
alias semantics, and the `hcf` shortcut all had to be fixed in both shells. So:

- **Anything derived from the palette goes through `render-mirrors.py`**, which
  writes both `zsh/.zshrc` and `fish/config.fish` between `gv-mirror` markers.
  Never hand-edit inside those markers.
- **Anything hand-written — aliases, hooks, env — must be added to both**, and
  must mean the same thing in both. Fish's `conf.d/abbreviations.fish` is the
  source of truth for the git shortcuts; oh-my-zsh's 250 aliases are overridden
  where they collide (see the block near `starship init zsh`).
- **Parity means same name, same intent — not blind copying.** `sfr` reloads the
  shell's own rc, so it is `source config.fish` in fish and `source .zshrc` in
  zsh. Copying the fish body into zsh would feed fish syntax to zsh.
- Before finishing a change that touches shell config, diff the two:

```sh
# fish -ic, not -c: conf.d/ is only sourced for interactive shells
diff <(fish -ic 'abbr --list' 2>/dev/null | sort) \
     <(zsh  -ic 'alias'       2>/dev/null | cut -d= -f1 | sort) | grep '^<'
```

### Hyprland config: Lua only, no hyprlang fallback (2026-09-01)

`hyprland.conf` + `modules/*.conf` used to be kept as a rollback layer beside the
Lua config. Every single `.conf` had drifted — last touched `2026-07-13` while
every `.lua` moved on to `2026-08-22` — so the "safety net" would have restored a
**different desktop**, silently. Worse than no net.

They are removed. Rollback is git:

```sh
git checkout hypr-hyprlang-fallback -- hypr/     # tag = last commit where .conf was correct
mv ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.off
hyprctl reload full-reset                        # only way to switch provider live
```

Under provider `lua`, `hyprctl keyword` is refused and `hyprctl dispatch <old-name>`
exits 7 — scripts must use `hyprctl eval 'hl.config({...})'` and
`hyprctl dispatch 'hl.dsp.*(...)'`.

### GTK theme is generated, not hand-edited

`theme/.themes/Graphite-Vivid-Dark/` and `gtk/.config/gtk-4.0/graphite-vivid-theme.css`
are **generated** from the upstream `graphite-gtk-theme` package. Do not edit by hand —
regenerate:

```sh
python3 ~/Dotfiles/theme/regen-from-upstream.py
```

The script carries a fixed `SEMANTIC` map (upstream hex → palette token) plus an
OKLab-nearest fallback for colours that appear after an upstream update; it prints
any colour that hit the fallback so it can be reviewed and pinned. Assets are copied
in as **real files**, so the theme does not depend on `graphite-gtk-theme` staying
installed.

### CSS `@import` uses relative paths

GTK resolves `@import` against the path it was *given*, not the resolved symlink
target — verified empirically (a deliberately broken relative import reports
`Error opening file /home/<user>/.config/colors/...`). So `../colors/graphite-vivid/…`
works through the stow symlink and the repo carries no absolute `/home/<user>` paths
in CSS. Same for waybar's `include`, which accepts `~`.

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
