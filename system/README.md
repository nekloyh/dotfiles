# `system/` — file thuộc `/etc`, **KHÔNG** stow

Stow chỉ mirror `$HOME`. Thư mục này giữ các file hệ thống cần `sudo` để cài,
để chúng được version-control và không mất kiến thức đã đào ra.

**`stow system` sẽ SAI** — nó tạo `~/pacman-hooks`, `~/udev`… Đừng chạy.

| file | đích | cài bằng |
|---|---|---|
| `pacman-hooks/nvidia-cdi.hook` | `/etc/pacman.d/hooks/` | `sudo install -Dm644 system/pacman-hooks/nvidia-cdi.hook /etc/pacman.d/hooks/nvidia-cdi.hook` |
| `udev/61-ideapad-conservation.rules` | `/etc/udev/rules.d/` | `sudo install -Dm644 system/udev/61-ideapad-conservation.rules /etc/udev/rules.d/` |
| `udev/61-intel-dri.rules` | `/etc/udev/rules.d/` | `sudo install -Dm644 system/udev/61-intel-dri.rules /etc/udev/rules.d/` |
| `modprobe.d/nvidia-gsp.conf` | `/etc/modprobe.d/` | `sudo install -Dm644 system/modprobe.d/nvidia-gsp.conf /etc/modprobe.d/` **rồi `sudo mkinitcpio -P`** |

Sau khi sửa udev: `sudo udevadm control --reload && sudo udevadm trigger`.
