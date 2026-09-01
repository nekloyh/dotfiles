# systemd (user units)

## Vì sao có package này

`elephant.service` là unit **tự viết** (không thuộc gói pacman nào —
`pacman -Qo` trả về "No package owns"). Nó chạy backend `elephant` cho walker.
Trước đây unit chỉ nằm trên máy, không được version → clone repo lên máy mới thì
walker mất provider mà README lại hướng dẫn `elephant service enable`, một lệnh
sinh unit ở đúng chỗ này. Vòng lặp cụt.

## Cài

    stow systemd
    systemctl --user daemon-reload
    systemctl --user enable --now elephant.service

## KHÔNG track (tạo lại bằng lệnh, không phải file cấu hình)

Các mask `-> /dev/null` trong `~/.config/systemd/user/` — tái tạo bằng:

    systemctl --user mask localsearch-3.service obex.service \
        tracker-extract-3.service tracker-miner-fs-3.service \
        tracker-miner-fs-control-3.service tracker-writeback-3.service \
        tracker-xdg-portal-3.service

(Mask tracker/localsearch = quyết định P1/P4 có chủ đích: indexer nền không cần
thiết cho workflow này, tốn CPU/IO liên tục.)

Các thư mục `*.target.wants/` cũng không track — chúng do `systemctl --user enable` sinh.
