#!/usr/bin/env python3
"""Tái tạo theme GTK Graphite-Vivid-Dark từ theme upstream Graphite-purple-Dark.

VÌ SAO cần script này
---------------------
Theme upstream sơn màu bằng **literal hex** khắp nơi (vd sidebar accent #BA68C8
sơn thẳng vào .sidebar-pane), nên override `@define-color` KHÔNG với tới được.
Cách duy nhất là copy toàn bộ CSS rồi map hex.

Đợt map tay tháng 7/2026 chỉ phủ 15 màu ở GTK3 và 28 ở GTK4 -> hai bản LỆCH THẾ
HỆ palette (GTK3 kẹt ở #e8554f/#e0b020 cũ trong khi GTK4 đã sang #ea6b62/#e3b42c),
và cả hai bỏ trống ramp surface. Script này thay bản map tay đó.

PHƯƠNG PHÁP
-----------
Mỗi hex trong CSS upstream được map sang màu palette GẦN NHẤT trong không gian
**OKLab** (Euclid trên L,a,b). OKLab perceptually uniform nên phép này BẢO TOÀN
ĐỘ SÁNG -> giữ nguyên hierarchy thị giác của theme gốc, chỉ kéo hue/chroma về
họ Graphite Vivid.

Hai ngoại lệ có chủ đích:
  * accent purple upstream (hue OKLCH ~321): khoảng cách OKLab đưa nó về MAGENTA,
    sai ngữ nghĩa — nó là màu primary của theme. Ép về ramp violet, chọn stop
    theo L gần nhất.
  * #ffffff / #000000: giữ nguyên (highlight/shadow thuần, không phải màu thương hiệu).

DÙNG
----
    python3 ~/Dotfiles/theme/regen-from-upstream.py            # ghi vào repo
    cd ~/Dotfiles && git diff --stat theme gtk                 # xem thay đổi

Chạy lại sau mỗi lần: (a) `graphite-gtk-theme` update, (b) palette đổi màu.
Sau khi chạy: logout/login để app GTK nạp lại.
"""
import re, os, math, shutil, sys

UPSTREAM = '/usr/share/themes/Graphite-purple-Dark'
REPO     = os.path.expanduser('~/Dotfiles')
PALETTE  = os.path.expanduser('~/.config/colors/graphite-vivid/graphite-vivid.sh')

# đích: (file upstream, [các file đích trong repo])
TARGETS = [
    (f'{UPSTREAM}/gtk-3.0/gtk.css', [
        f'{REPO}/theme/.themes/Graphite-Vivid-Dark/gtk-3.0/gtk.css',
        f'{REPO}/theme/.themes/Graphite-Vivid-Dark/gtk-3.0/gtk-dark.css']),
    (f'{UPSTREAM}/gtk-4.0/gtk.css', [
        f'{REPO}/theme/.themes/Graphite-Vivid-Dark/gtk-4.0/gtk.css',
        f'{REPO}/theme/.themes/Graphite-Vivid-Dark/gtk-4.0/gtk-dark.css',
        f'{REPO}/gtk/.config/gtk-4.0/graphite-vivid-theme.css']),
]
# BẢNG SEMANTIC vs OKLab
# ----------------------
# Chỉ dùng OKLab-nearest là KHÔNG đủ: palette có đủ stop 50/100/300/500/700/900,
# nên `#f28b82` (đỏ lỗi của upstream) rơi vào `red300` thay vì `red` canonical —
# đúng về khoảng cách, sai về ngữ nghĩa. Vì vậy dùng bảng SEMANTIC cố định bên
# dưới (rút ra từ bản đã kiểm bằng mắt), OKLab chỉ là FALLBACK cho màu MỚI xuất
# hiện sau khi upstream update.
#
SEMANTIC = {
    '#031579': '#25285b',
    '#080808': '#070709',
    '#0f9ac8': '#3aabf4',
    '#131313': '#11131a',
    '#191919': '#1a1c22',
    '#1c6d38': '#00857b',
    '#1c71d8': '#0072ae',
    '#1d1d1d': '#0c0d10',
    '#1e1e1e': '#1a1c22',
    '#1f1f1f': '#1a1c22',
    '#202020': '#1a1c22',
    '#212121': '#22252c',
    '#213397': '#25285b',
    '#2196f3': '#3aabf4',
    '#242424': '#0c0d10',
    '#27a66c': '#668400',
    '#2861c6': '#0072ae',
    '#29ae74': '#39c0b4',
    '#2b2928': '#22252c',
    '#2c2c2c': '#11131a',
    '#2ec27e': '#99be42',
    '#33302f': '#2c303a',
    '#337fdc': '#0072ae',
    '#342c27': '#2c303a',
    '#343434': '#2c303a',
    '#363636': '#2c303a',
    '#393484': '#25285b',
    '#393634': '#2c303a',
    '#393939': '#3a3e4a',
    '#3a323c': '#2c303a',
    '#3c3c3c': '#22252c',
    '#3f51b5': '#4e54c5',
    '#403c3a': '#3a3e4a',
    '#413543': '#3a3e4a',
    '#414141': '#3a3e4a',
    '#463e39': '#3a3e4a',
    '#474341': '#3a3e4a',
    '#474747': '#3a3e4a',
    '#479863': '#668400',
    '#4b4b4b': '#2c303a',
    '#4cb168': '#99be42',
    '#505050': '#5c626e',
    '#555555': '#5c626e',
    '#565656': '#5c626e',
    '#574f4a': '#5c626e',
    '#5e5c64': '#676c72',
    '#6a007e': '#25285b',
    '#6a7ce0': '#8388e8',
    '#6ab85b': '#99be42',
    '#6b5f2e': '#5c626e',
    '#6b6b6b': '#676c72',
    '#6d53e0': '#8388e8',
    '#6e6d71': '#696e73',
    '#73c48f': '#39c0b4',
    '#757575': '#696e73',
    '#785336': '#5c626e',
    '#7a59ca': '#4e54c5',
    '#7ad9f1': '#6bdace',
    '#7b736e': '#696e73',
    '#81c995': '#99be42',
    '#830e97': '#4e54c5',
    '#83b6ec': '#76c5ff',
    '#8adba6': '#6bdace',
    '#8de6b1': '#6bdace',
    '#94a6ff': '#a5a9ee',
    '#9945b5': '#4e54c5',
    '#999999': '#7d8388',
    '#9c27b0': '#4e54c5',
    '#9e91e8': '#9298f9',
    '#9e9e9e': '#969ca0',
    '#9f9792': '#969ca0',
    '#a27100': '#a27d00',
    '#a2f3be': '#a8fff0',
    '#a844b9': '#4e54c5',
    '#ac1800': '#af2c2b',
    '#b08952': '#a27d00',
    '#b155c1': '#8388e8',
    '#b5e98a': '#b5d86d',
    '#b84acb': '#8388e8',
    '#ba68c8': '#8388e8',
    '#be916d': '#969ca0',
    '#c074cc': '#8388e8',
    '#c0bfbc': '#b0b5b9',
    '#c26c00': '#a27d00',
    '#c27acf': '#8388e8',
    '#c37bcf': '#8388e8',
    '#c47ed0': '#9298f9',
    '#caeaf2': '#d9efff',
    '#cb78d4': '#9298f9',
    '#cb8dd6': '#9298f9',
    '#cc8fd6': '#9298f9',
    '#ce8cd7': '#a5a9ee',
    '#ce93d8': '#a5a9ee',
    '#cef8d8': '#ecffd0',
    '#cf3b00': '#ab4400',
    '#cf95d9': '#8388e8',
    '#cfe1f5': '#d9dedc',
    '#d1a023': '#e3b42c',
    '#d25de6': '#8388e8',
    '#d29d09': '#e3b42c',
    '#d5d2f5': '#d4d7ff',
    '#d68400': '#ea7b47',
    '#d8d7d3': '#d9dedc',
    '#de8800': '#ea7b47',
    '#e1b602': '#e3b42c',
    '#e33b6a': '#ea6b62',
    '#e3cf9c': '#ffb88a',
    '#e5d6ca': '#d9dedc',
    '#e62d42': '#ea6b62',
    '#e6f9d7': '#ecffd0',
    '#e7c2e8': '#ffd0e6',
    '#e973ab': '#e36da7',
    '#eb4b3d': '#ea6b62',
    '#eb5ec3': '#fa8dc1',
    '#ed5b00': '#ea7b47',
    '#ef4e9b': '#e36da7',
    '#f0766b': '#ea6b62',
    '#f15d22': '#ea6b62',
    '#f28b82': '#ea6b62',
    '#f2eade': '#ece8dc',
    '#f77466': '#ff8d83',
    '#f78773': '#ff8d83',
    '#f8d2ce': '#ffd6d4',
    '#f8e359': '#fbd064',
    '#f9e2a7': '#fbd064',
    '#f9f4e1': '#f7f4ea',
    '#faa41a': '#e3b42c',
    '#fac7de': '#ffd0e6',
    '#fcf4bf': '#fff7d4',
    '#fdd11a': '#fbd064',
    '#fdd633': '#e3b42c',
    '#fdf8d7': '#fff7d4',
    '#fefcef': '#f7f4ea',
    '#ff7043': '#ea7b47',
    '#ff793e': '#ea7b47',
    '#ff9262': '#ff9c6f',
    '#ff9800': '#ff9c6f',
    '#ffa95a': '#ff9c6f',
    '#ffca40': '#fbd064',
    '#ffcb62': '#fbd064',
    '#ffce51': '#fbd064',
    '#ffdb91': '#ffe999',
    '#ffe5c5': '#ffdfc8',
    '#ffead1': '#ffdfc8',
    '#fffa7d': '#d6ffa0',
    '#ffffa8': '#ecffd0',
}

KEEP = {'#ffffff', '#000000'}
VIOLET_RAMP = ['#ecedff', '#d4d7ff', '#a5a9ee', '#9298f9', '#8388e8', '#4e54c5', '#25285b', '#0e103a']

def _lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def oklab(h):
    h = h.lstrip('#')
    r, g, b = (_lin(int(h[i:i+2], 16)) for i in (0, 2, 4))
    l = .4122214708*r + .5363325363*g + .0514459929*b
    m = .2119034982*r + .6806995451*g + .1073969566*b
    s = .0883024619*r + .2817188376*g + .6299787005*b
    l_, m_, s_ = (x ** (1/3) for x in (l, m, s))
    return (.2104542553*l_ + .7936177850*m_ - .0040720468*s_,
            1.9779984951*l_ - 2.4285922050*m_ + .4505937099*s_,
            .0259040371*l_ + .7827717662*m_ - .8086757660*s_)

def oklch(h):
    L, a, b = oklab(h)
    return L, math.hypot(a, b), math.degrees(math.atan2(b, a)) % 360

def load_palette():
    if not os.path.exists(PALETTE):
        sys.exit(f'không thấy palette: {PALETTE}')
    txt = open(PALETTE, encoding='utf-8').read()
    pal = {}
    for m in re.finditer(r'export ([A-Z0-9_]+)="(#[0-9a-fA-F]{6})"', txt):
        pal.setdefault(m.group(2).lower(), m.group(1).lower())
    return pal

def main():
    pal = load_palette()
    vec = {h: oklab(h) for h in pal}
    unknown = []
    def target(h):
        if h in SEMANTIC:                          # 1) bảng cố định — giữ ngữ nghĩa
            return SEMANTIC[h]
        unknown.append(h)
        L, C, H = oklch(h)
        if C > 0.07 and 295 <= H <= 345:            # 2) accent purple upstream -> ramp violet, giữ L
            return min(VIOLET_RAMP, key=lambda v: abs(oklch(v)[0] - L))
        v = oklab(h)                                # 3) fallback OKLab-nearest
        return min(vec, key=lambda p: sum((x - y) ** 2 for x, y in zip(v, vec[p])))

    for src, dests in TARGETS:
        if not os.path.exists(src):
            sys.exit(f'không thấy upstream: {src}\n  cài: sudo pacman -S graphite-gtk-theme')
        txt = open(src, encoding='utf-8').read()
        seen = {}
        def sub(mo):
            h = '#' + mo.group(1).lower()
            if h in pal or h in KEEP:
                return mo.group(0)
            if h not in seen:
                seen[h] = target(h)
            return seen[h]
        out = re.sub(r'#([0-9a-fA-F]{6})\b', sub, txt)
        for d in dests:
            os.makedirs(os.path.dirname(d), exist_ok=True)
            if os.path.exists(d):
                shutil.copy2(d, d + '.bak')
            open(d, 'w', encoding='utf-8').write(out)
        print(f'{os.path.basename(os.path.dirname(src))}: map {len(seen)} màu -> {len(dests)} file')
        if unknown:
            print(f'  ! {len(set(unknown))} màu MỚI không có trong SEMANTIC (dùng OKLab fallback):')
            for h in sorted(set(unknown))[:12]:
                print(f'      {h} -> {seen.get(h)}   # xem lại, cân nhắc thêm vào SEMANTIC')
            unknown.clear()

    # assets: copy THẬT (không symlink tuyệt đối) để theme tự chứa,
    # không phụ thuộc gói graphite-gtk-theme còn được cài hay không.
    for v in ('3', '4'):
        s = f'{UPSTREAM}/gtk-{v}.0/assets'
        for d in ([f'{REPO}/theme/.themes/Graphite-Vivid-Dark/gtk-{v}.0/assets'] +
                  ([f'{REPO}/gtk/.config/gtk-4.0/assets'] if v == '4' else [])):
            if os.path.exists(s):
                if os.path.exists(d): shutil.rmtree(d, ignore_errors=True)
                shutil.copytree(s, d, symlinks=False)
        print(f'gtk-{v}.0/assets: copy thật')

if __name__ == '__main__':
    main()
