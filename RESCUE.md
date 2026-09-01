# RESCUE — mất display / không boot được

> File này nằm trong repo `nekloyh/dotfiles` nên **đọc được từ điện thoại** khi
> laptop không lên hình: github.com/nekloyh/dotfiles → `RESCUE.md`.
> Trên máy: `cat ~/Dotfiles/RESCUE.md` (đọc được từ TTY, không cần GUI).
>
> Viết 2026-09-01 trước khi bắt đầu Phase 2 (GPU/power). Trạng thái đã kiểm chứng
> ở cuối file — nếu số liệu lệch thì kiểm lại trước khi tin.

---

## 0. Vào TTY (khi Hyprland còn sống nhưng hỏng, hoặc treo)

`Ctrl` + `Alt` + `F3` → đăng nhập bằng user + password thường.
Quay lại GUI: `Ctrl` + `Alt` + `F1` (hoặc F2 — nơi SDDM chạy).

Đọc log của Hyprland lần chạy gần nhất (debug log ĐANG BẬT trong Phase 2):

```
ls  $XDG_RUNTIME_DIR/hypr/
less $XDG_RUNTIME_DIR/hypr/*/hyprland.log
journalctl -b -e            # log hệ thống lần boot này
journalctl -k -b -1         # log kernel lần boot TRƯỚC (sau khi đã reboot)
```

---

## 1. Login loop (gõ đúng pass → màn đen → về lại màn login)

Đã xảy ra 13/07/2026. Gần như luôn là **Hyprland crash lúc khởi động**, không
phải sai password. Vào TTY (mục 0) rồi:

```
grep -iE 'CBackend|no gpus|aquamarine' $XDG_RUNTIME_DIR/hypr/*/hyprland.log
```

**Thủ phạm số 1: `AQ_DRM_DEVICES`.** File `~/.config/hypr/modules/env.lua`.
Hiện tại dòng đó **đang comment**, cố ý. Nếu ai đó bật lại:

```
nano ~/.config/hypr/modules/env.lua      # comment dòng hl.env("AQ_DRM_DEVICES", ...)
```

Lý do: aquamarine tách danh sách thiết bị bằng dấu **`:`** — mà tên
`/dev/dri/by-path/pci-0000:00:02.0-card` đầy dấu `:` → bị xé thành rác →
"Found no gpus to use" → `CBackend::create() failed`.
`by-path` **về bản chất không dùng được**. `cardN` thì colon-free nhưng máy này
đánh số **không ổn định** (NVIDIA nhảy card0 ↔ card2).

**Thủ phạm số 2: config Lua hỏng.** Rollback về hyprlang:

```
cd ~/Dotfiles
git checkout hypr-hyprlang-fallback -- hypr/
mv ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.disabled
hyprctl reload full-reset          # hoặc đăng xuất/đăng nhập lại
```

⚠ Bản `.conf` KHÔNG còn nằm sẵn trên đĩa — Phase 1 đã xoá 17 file đó
(`hyprland.conf` + `modules/*.conf`). Chúng chỉ còn trong git, ở tag
**`hypr-hyprlang-fallback`**. Câu lệnh `git checkout` ở trên là bước BẮT BUỘC,
không phải tuỳ chọn. Kiểm tra trước khi cần đến:

```
git -C ~/Dotfiles ls-tree -r --name-only hypr-hyprlang-fallback -- hypr/ | grep -c '\.conf$'    # phải ra 17
```

Nếu repo cũng mất: `git clone git@github.com:nekloyh/dotfiles.git` rồi
`git checkout hypr-hyprlang-fallback`.

---

## 2. Boot kernel LTS (khi kernel mới / driver NVIDIA hỏng)

Có sẵn **`linux-cachyos-lts 6.18.42`** và NVIDIA DKMS **đã build cho nó**
(`/usr/lib/modules/6.18.42-1-cachyos-lts/updates/dkms/nvidia.ko.zst`).

Lúc khởi động: **giữ phím `↓` ngay khi màn hình Lenovo tắt** →
menu GRUB → `Advanced options for CachyOS` → chọn dòng có `linux-cachyos-lts`.

> ⚠ `GRUB_TIMEOUT=1` — menu chỉ hiện **1 giây**. Nhấn phím mũi tên là dừng đếm.
> Trước mỗi thay đổi rủi ro nên tạm nâng lên:
> `sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT='5'/" /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg`

---

## 3. Rollback snapshot btrfs từ GRUB

`grub-btrfsd` đang chạy, `/boot/grub/grub-btrfs.cfg` có sẵn menu snapshot.
`snap-pac` tự tạo cặp pre/post quanh **mỗi giao dịch pacman**.

Menu GRUB → **`CachyOS snapshots`** → chọn theo ngày giờ + mô tả
(vd `pre | pacman -Rs qgis`) → boot vào đó (chế độ **read-only**).

Snapshot chỉ boot thử. Muốn giữ luôn thì sau khi vào được:

```
sudo snapper --ambit classic rollback
sudo reboot
```

> ⚠ **Rollback CHỈ ảnh hưởng subvol `/` (`@`).**
> `@home`, `@srv`, `@cache`, `@log`, `@tmp` là subvol RIÊNG → **không** bị lùi.
> Nghĩa là: rollback KHÔNG mất dữ liệu trong `~`.
> Nhưng cũng có nghĩa: rollback **không** sửa được thứ hỏng nằm trong `~/.config`.

---

## 4. Revert từng thay đổi của Phase 2 (mỗi mục 1 file)

| Thay đổi | File | Revert |
|---|---|---|
| GSP firmware | `/etc/modprobe.d/nvidia-gsp.conf` | đổi `NVreg_EnableGpuFirmware=1` → `0`, rồi `sudo mkinitcpio -P && reboot` |
| Driver NVIDIA | (pacman) | `sudo pacman -S nvidia-580xx-dkms nvidia-580xx-utils nvidia-580xx-settings lib32-nvidia-580xx-utils lib32-opencl-nvidia-580xx opencl-nvidia-580xx` — hoặc rollback snapshot `pre` (mục 3) |
| Power profile | (không ghi file) | `powerprofilesctl set performance` |
| Conservation mode | udev rule | `echo 0 \| sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode` |
| `AQ_DRM_DEVICES` | `~/.config/hypr/modules/env.lua` | comment dòng đó lại (mục 1) |
| Hyprland debug log | `~/.config/hypr/modules/misc.lua` | `disable_logs = true` |
| Config Lua nói chung | `~/Dotfiles/hypr/` | `git checkout hypr-hyprlang-fallback -- hypr/` (mục 1) |

---

## 5. ⚠ BẪY MUX — đọc trước khi đụng `AQ_DRM_DEVICES`

Máy này **CÓ MUX ở tầng BIOS** (mục `Hybrid / Discrete` — user xác nhận 2026-09-01).
`supergfxctl -s` chỉ báo `[Integrated, Hybrid]` vì nó không thấy được MUX BIOS.

Ở chế độ **Discrete**, iGPU Intel bị TẮT HẲN. Nếu lúc đó `AQ_DRM_DEVICES` đang
trỏ vào iGPU (`/dev/dri/intel`) thì aquamarine không tìm thấy GPU nào →
**login loop, y hệt sự cố 13/07**, và sẽ rất khó đoán vì "hôm qua vẫn chạy".

→ Đổi mode MUX trong BIOS thì **phải** comment `AQ_DRM_DEVICES` trước.
→ Hoặc dùng udev symlink (colon-free) + đừng bao giờ hardcode `cardN`:
```
# /etc/udev/rules.d/61-intel-dri.rules
SUBSYSTEM=="drm", KERNEL=="card*", ATTRS{vendor}=="0x8086", SYMLINK+="dri/intel"
```
Verify `ls -l /dev/dri/intel` **trước** khi set env, vì `hyprctl reload` KHÔNG
nạp lại env — config hỏng nằm im cho tới lần login kế tiếp.

---

## 6. Thứ KHÔNG được "sửa"

- **Suspend/hibernate bị mask CÓ CHỦ ĐÍCH** (`sleep.target`, `suspend.target`,
  `hibernate.target`, `hybrid-sleep.target`, `suspend-then-hibernate.target`) +
  `logind` handlers = ignore. Đừng unmask để "thử".
- **Đừng cài `tlp` / `auto-cpufreq` / `thermald`** — xung đột `power-profiles-daemon`.
- **Đừng `killall -SIGUSR2 waybar`** — waybar 0.15 segfault. Restart process:
  `~/.config/waybar/scripts/launch.sh`.
- **Đừng set `"iptables": false`** trong `/etc/docker/daemon.json`.
- **Đừng set `GBM_BACKEND` / `__GLX_VENDOR_LIBRARY_NAME` toàn cục** — ép mọi app
  chạy dGPU, ngược mục tiêu tiết kiệm điện. Dùng PRIME offload cho từng app:
  `__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <app>`.

---

## 7. Trạng thái đã kiểm chứng (2026-09-01)

```
kernel chạy      7.1.8-1-cachyos          fallback  6.18.42-1-cachyos-lts  ✓ DKMS đã build
driver           nvidia-580xx-dkms 580.173.02
GPU              RTX 3060 Mobile (01:00.0) | iGPU Iris Xe (00:02.0, boot_vga)
màn nội bộ       eDP-1 trên card1 = i915          HDMI-A-1 trên card0 = nvidia
grub-btrfsd      active, 25 menuentry snapshot
snapper          config `root` (chỉ /), TIMELINE_CREATE=no, snap-pac pre/post
backup           KHÔNG có backup tự động (quyết định của user 2026-09-01:
                 Projects/Work/Courses tự quản bằng git). ~/.cache đã tách
                 thành subvol riêng nên snapshot /home sau này sẽ bỏ qua 33G đó.
```
