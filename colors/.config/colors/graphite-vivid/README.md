# Graphite Vivid

A graphite-neutral Linux palette with brighter, more energetic accents.
Derived from `craftzdog/solarized-osaka.nvim` via two transitional iterations
(*Solarized Osaka Carbon* → *Solarized Osaka Graphite* → *Graphite Vivid*).

The Solarized lineage gave us the layout (extended `50..950` ramps, semantic
aliases, surface layering); this revision moves away from Solarized's
purposely-muted canonical hues because they read as dusty on a neutral dark
background. The accents here are lifted to a "fresh but not neon" zone,
inspired more by Tokyo Night and modern editor themes than by Solarized
proper. The dropped *Solarized Osaka* prefix reflects that.

## Intent

- Neutral graphite surface ramp with perceptible depth between layers
  (ΔL\* ≥ 2 across the working range).
- Accents lifted from Solarized 500 to a vivid canonical, providing
  energy without crossing into neon/eye-strain territory.
- `300` stops act as soft highlights (lighter than canonical); `700/900/950`
  as dark variants. The ramp now reads consistently lighter → darker.
- Consistent palette across semantic aliases — `error`, `warning`, `success`,
  `info` all use the canonical vivid set, no dimmer/heritage hybrid.
- Selection aligned with `primary` (violet-tinted).

## Files

| File | Use case |
|------|----------|
| `graphite-vivid.css` | Waybar, SwayNC, GTK overrides |
| `graphite-vivid.hypr.conf` | Hyprland (`rgb(...)` + alpha helpers) |
| `graphite-vivid.alacritty.toml` | Alacritty terminal colors |
| `graphite-vivid.toml` | Generic TOML palette (Walker, custom scripts) |
| `graphite-vivid.sh` | Shell exports (`$NAME` and `$NAME_HEX`) |
| `graphite-vivid.nvim.lua` | Neovim palette table |
| `graphite-vivid.nanorc` | Nano UI theme (also *is* `~/.config/nano/nanorc` via the `nano` package symlink) |

## Key colors

| Role | Value |
|------|-------|
| crust | `#070709` |
| mantle | `#0c0d10` |
| base | `#11131a` |
| surface0 | `#1a1c22` |
| surface1 | `#22252c` |
| surface2 | `#2c303a` |
| surface3 | `#3a3e4a` |
| border | `#363b46` |
| text | `#c8ccd0` |
| primary / violet | `#8388e8` |
| info / blue | `#3aabf4` |
| hint / cyan | `#39c0b4` |
| warning / yellow | `#e3b42c` |
| error / red | `#ea6b62` |
| success / green | `#99be42` |
| secondary / orange | `#ea7b47` |
| special / magenta | `#e36da7` |
| selection | `#2e3252` |

## Design principles (for extending)

- **Layering**: declare up to 7 surface levels, but show only 3–4 in a single UI context.
- **Background chroma**: keep LCH chroma low for surfaces — slight cool bias is fine
  (helps warm accents pop), but avoid backgrounds that compete with accents for hue.
- **Contrast budget**: body text ≥ 7:1 (AAA), secondary ≥ 4.5:1 (AA),
  comment/disabled may go to ~3.5:1 but no lower.
- **60-30-10**: ~60% neutral surfaces, ~30% text, ~10% accent. Vivid accents
  are louder than Solarized, so respect this budget more strictly.
- **Anchor pairs**: warm anchor (yellow/orange), cool anchor (violet/blue).
  New accents should belong to one pole.

## Recommended Hyprland usage

```hyprlang
source = ~/.config/colors/graphite-vivid.hypr.conf

general {
    col.active_border = $primary
    col.inactive_border = $border
}

decoration {
    shadow {
        color = rgba($blackAlphaAA)
    }
}
```

## Recommended Alacritty usage

In `~/.config/alacritty/alacritty.toml`:

```toml
[general]
import = [
    "~/.config/colors/graphite-vivid.alacritty.toml",
]
```

## Migration from earlier versions

The variable schema (`bg`, `surface0..3`, `yellow`, `yellow500`, `primary`,
`border`, etc.) is unchanged. Only file basename and hex values differ, so
swapping the `source =` path in existing configs is usually sufficient:

```diff
- source = ~/.config/colors/solarized-osaka-graphite.hypr.conf
+ source = ~/.config/colors/graphite-vivid.hypr.conf
```

If you were relying on Solarized's exact 500 values (e.g. `yellow = #b28600`
for a printable mustard tone), those are gone — use the `700` stop for
heritage-Solarized-adjacent dim accents:

| Heritage Solarized 500 | Closest v3 stop |
|---|---|
| `yellow #b28600` | `yellow700 #a27d00` |
| `green #859900` | `green700 #668400` |
| `red #dc312e` | `red700 #af2c2b` |
| `blue #278bd3` | `blue700 #0072ae` |
