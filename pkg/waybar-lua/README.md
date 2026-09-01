# waybar 0.15.0-2.2 — bản vá Hyprland Lua IPC

## Vấn đề

Waybar 0.15.0 gửi lệnh `dispatch workspace N` theo cú pháp **legacy**. Hyprland
từ 0.55 chạy config provider `lua` từ chối cú pháp đó → **click vào workspace
trên bar không làm gì cả** (im lặng, không log).

Upstream đã sửa ở master (dò version ≥0.54 rồi gửi `hl.dsp.focus`):
`e17c0d9f0a`, `cdb792af41`, `74cf45d530`. `hyprland-lua-ipc.patch` là backport
3 commit đó lên tag 0.15.0.

## BẪY — vì sao phải track nguồn build

Gói local là `0.15.0-2.2` (bump pkgrel để thắng `0.15.0-2` của repo).
Nhưng:

    $ vercmp 0.15.0-2.2 0.15.0-3
    -1

⇒ Một lần repo rebuild pkgrel thông thường (bump `fmt`/`spdlog`) là **pacman đè
mất bản vá** và click workspace chết lại, âm thầm. Trước đây nguồn build chỉ nằm
ở `~/.cache/waybar-lua-build` — bị `.gitignore` loại → xoá cache là không dựng
lại được.

## Phát hiện đã bị đè

    pacman -Qi waybar | grep -E 'Version|Validated'
    # Bản vá:  Version 0.15.0-2.2   Validated By: None
    # Bị đè :  Version 0.15.0-3+    Validated By: Signature

Hoặc test trực tiếp: click một workspace trên bar; nếu không chuyển thì đã bị đè.

## Dựng lại

    mkdir -p ~/.cache/waybar-lua-build && cd ~/.cache/waybar-lua-build
    cp ~/Dotfiles/pkg/waybar-lua/{PKGBUILD.arch,hyprland-lua-ipc.patch} .
    cp PKGBUILD.arch PKGBUILD
    # thêm patch vào source=() + prepare(), bump pkgrel cao hơn bản repo hiện tại
    makepkg -si

## HẾT HẠN

Khi repo ship waybar **0.15.1 hoặc 0.16+** thì bản vá đã có sẵn upstream —
gỡ gói local, `pacman -S waybar`, và xoá package `pkg` này khỏi repo.
