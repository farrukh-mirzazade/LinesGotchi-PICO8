#!/usr/bin/env python3
"""Simulate PICO-8 drawing and render preview PNGs for linesgotchi.p8."""

from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
CART = ROOT / "carts" / "linesgotchi.p8"

palette = [
    (0, 0, 0),       # 0: black
    (29, 43, 83),    # 1: dark blue
    (126, 37, 83),   # 2: dark purple
    (0, 135, 81),    # 3: dark green
    (171, 82, 54),   # 4: brown
    (95, 87, 79),    # 5: dark gray
    (194, 195, 199), # 6: light gray
    (255, 241, 232), # 7: white / cream
    (255, 0, 77),    # 8: red
    (255, 163, 0),   # 9: orange
    (255, 236, 39),  # a (10): yellow
    (0, 228, 54),    # b (11): green
    (41, 173, 255),  # c (12): light blue
    (131, 118, 156), # d (13): indigo
    (255, 119, 168), # e (14): pink
    (255, 204, 170), # f (15): peach
]

# Read __gfx__
text = CART.read_text()
gfx_str = text.split("__gfx__\n", 1)[1].split("\n__", 1)[0].strip().split("\n")
gfx = [[int(c, 16) for c in row] for row in gfx_str]

class Pico8Canvas:
    def __init__(self):
        self.w = 128
        self.h = 128
        self.buf = [[0 for _ in range(self.w)] for _ in range(self.h)]
        self.pal_map = {i: i for i in range(16)}

    def cls(self, c=0):
        for y in range(self.h):
            for x in range(self.w):
                self.buf[y][x] = c

    def pset(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.buf[y][x] = self.pal_map.get(c, c)

    def rectfill(self, x0, y0, x1, y1, c):
        col = self.pal_map.get(c, c)
        for y in range(max(0, y0), min(self.h, y1 + 1)):
            for x in range(max(0, x0), min(self.w, x1 + 1)):
                self.buf[y][x] = col

    def rect(self, x0, y0, x1, y1, c):
        col = self.pal_map.get(c, c)
        for x in range(max(0, x0), min(self.w, x1 + 1)):
            if 0 <= y0 < self.h: self.buf[y0][x] = col
            if 0 <= y1 < self.h: self.buf[y1][x] = col
        for y in range(max(0, y0), min(self.h, y1 + 1)):
            if 0 <= x0 < self.w: self.buf[y][x0] = col
            if 0 <= x1 < self.w: self.buf[y][x1] = col

    def line(self, x0, y0, x1, y1, c):
        col = self.pal_map.get(c, c)
        dx = abs(x1 - x0)
        dy = abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx - dy
        x, y = x0, y0
        while True:
            self.pset(x, y, col)
            if x == x1 and y == y1: break
            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                x += sx
            if e2 < dx:
                err += dx
                y += sy

    def spr(self, sid, x, y):
        sx = (sid % 16) * 8
        sy = (sid // 16) * 8
        self.sspr(sx, sy, 8, 8, x, y)

    def sspr(self, sx, sy, sw, sh, dx, dy):
        for yy in range(sh):
            for xx in range(sw):
                c = gfx[sy + yy][sx + xx]
                if c != 0:
                    self.pset(dx + xx, dy + yy, self.pal_map.get(c, c))

    def pal(self, c0=None, c1=None):
        if c0 is None:
            self.pal_map = {i: i for i in range(16)}
        else:
            self.pal_map[c0] = c1

    def draw_bar(self, x, y, w, h, val, col):
        self.rectfill(x, y, x + w, y + h, 0)
        self.rect(x, y, x + w, y + h, 5)
        fw = int((w - 2) * max(0, min(100, val)) / 100)
        if fw > 0:
            self.rectfill(x + 1, y + 1, x + fw, y + h - 1, col)

    def device_bezel(self, frame_col):
        self.cls(15)
        self.pal(6, frame_col)
        self.rectfill(8, 8, 119, 119, 6)
        self.spr(128, 0, 0)
        self.spr(130, 120, 0)
        self.spr(134, 0, 120)
        self.spr(136, 120, 120)
        for x in range(8, 113, 8):
            self.spr(129, x, 0)
            self.spr(135, x, 120)
        for y in range(8, 113, 8):
            self.spr(131, 0, y)
            self.spr(133, 120, y)
        self.pal()
        for x in range(8, 25, 4):
            self.pset(x, 5, 1); self.pset(x, 7, 1)
        for x in range(103, 120, 4):
            self.pset(x, 5, 1); self.pset(x, 7, 1)
        self.spr(87, 60, 3)

    def inner_screen(self, x0, y0, x1, y1, bg_col=7):
        self.rectfill(x0, y0, x1, y1, bg_col)
        self.rect(x0, y0, x1, y1, 5)
        self.rect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, 1)

    def draw_nav(self, active):
        for i in range(1, 6):
            x = 6 + (i - 1) * 24
            is_act = (i == active)
            bg = 10 if is_act else 1
            border = 7 if is_act else 5
            self.rectfill(x, 106, x + 21, 122, bg)
            self.rect(x, 106, x + 21, 122, border)
            self.rect(x + 1, 107, x + 20, 121, 9 if is_act else 0)
            sid = 63 + i
            if is_act:
                self.pal(7, 1)
                self.spr(sid, x + 7, 110)
                self.pal()
            else:
                self.spr(sid, x + 7, 110)

    def to_image(self, scale=4):
        img = Image.new("RGB", (self.w, self.h))
        pixels = [palette[self.buf[y][x]] for y in range(self.h) for x in range(self.w)]
        img.putdata(pixels)
        if scale != 1:
            return img.resize((self.w * scale, self.h * scale), Image.Resampling.NEAREST)
        return img

# 1. Screen: PET ROOM
p1 = Pico8Canvas()
p1.device_bezel(3)
p1.inner_screen(5, 13, 122, 103, 7)
p1.spr(96, 12, 18); p1.spr(97, 20, 18)
p1.spr(112, 12, 26); p1.spr(113, 20, 26)
p1.spr(98, 12, 42); p1.spr(114, 12, 50)
p1.spr(99, 102, 18)
p1.spr(100, 98, 48); p1.spr(101, 106, 48)
p1.rectfill(6, 68, 121, 102, 15)
p1.line(6, 66, 121, 66, 15)
p1.line(6, 67, 121, 67, 5)
p1.sspr(0, 0, 24, 24, 52, 38)
p1.spr(80, 10, 75); p1.draw_bar(24, 77, 72, 5, 85, 11)
p1.spr(81, 10, 88); p1.draw_bar(24, 90, 72, 5, 55, 10)
p1.draw_nav(1)
p1.to_image().save(ROOT / "assets" / "design" / "clean_preview_pet.png")

# 2. Screen: LINES PLAY
p2 = Pico8Canvas()
p2.device_bezel(13)
p2.inner_screen(5, 13, 81, 103, 7)
p2.inner_screen(84, 13, 122, 103, 1)
ox, oy, cs = 7, 18, 9
ball_sample = [
    [0,0,0,0,0,0,0,0],
    [0,48,0,0,0,0,0,0],
    [0,0,0,0,49,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,50,0,48,0,0],
    [0,0,50,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
]
for y in range(8):
    for x in range(8):
        px = ox + x * cs
        py = oy + y * cs
        p2.spr(55, px, py)
        b = ball_sample[y][x]
        if b > 0:
            p2.spr(b, px, py)
p2.rect(ox - 1, oy - 1, ox + 8, oy + 8, 10)
p2.rect(ox, oy, ox + 7, oy + 7, 7)
p2.spr(67, 87, 18)
p2.spr(80, 87, 29); p2.draw_bar(97, 31, 11, 4, 85, 11)
p2.spr(81, 87, 40); p2.draw_bar(97, 42, 11, 4, 55, 10)
p2.rectfill(89, 52, 117, 78, 7)
p2.rect(89, 52, 117, 78, 5)
p2.sspr(0, 0, 24, 24, 91, 53)
p2.rectfill(87, 83, 119, 100, 5)
p2.rect(87, 83, 119, 100, 1)
p2.spr(48, 88, 91); p2.spr(49, 99, 91); p2.spr(50, 110, 91)
p2.rectfill(5, 106, 81, 122, 1)
p2.rect(5, 106, 81, 122, 5)
p2.rectfill(84, 106, 122, 122, 1)
p2.rect(84, 106, 122, 122, 5)
p2.to_image().save(ROOT / "assets" / "design" / "clean_preview_lines.png")

# 3. Screen: STATS
p3 = Pico8Canvas()
p3.device_bezel(14)
p3.inner_screen(5, 13, 122, 103, 1)
p3.rectfill(8, 16, 36, 44, 7)
p3.rect(8, 16, 36, 44, 5)
p3.sspr(0, 0, 24, 24, 10, 18)
p3.draw_bar(42, 26, 45, 5, 60, 14)
p3.spr(84, 94, 18)
p3.line(8, 47, 119, 47, 5)
p3.spr(80, 9, 51)
p3.spr(81, 9, 63)
p3.spr(82, 9, 75)
p3.spr(83, 9, 87)
p3.rectfill(91, 51, 119, 73, 5); p3.rect(91, 51, 119, 73, 1)
p3.spr(85, 93, 55)
p3.rectfill(91, 76, 119, 98, 5); p3.rect(91, 76, 119, 98, 1)
p3.spr(86, 93, 82)
p3.draw_nav(3)
p3.to_image().save(ROOT / "assets" / "design" / "clean_preview_stats.png")

# 4. Screen: RECORDS
p4 = Pico8Canvas()
p4.device_bezel(11)
p4.inner_screen(5, 13, 122, 103, 1)
p4.rectfill(8, 15, 44, 26, 10); p4.rect(8, 15, 44, 26, 5); p4.spr(67, 22, 17)
p4.rectfill(46, 15, 82, 26, 5); p4.rect(46, 15, 82, 26, 1); p4.spr(66, 60, 17)
p4.rectfill(84, 15, 119, 26, 5); p4.rect(84, 15, 119, 26, 1); p4.spr(65, 98, 17)
p4.line(8, 27, 119, 27, 5)
for idx, (rank, badge_col, avatar_col) in enumerate([
    (1, 10, 12), (2, 7, 14), (3, 9, 11), (4, 5, 13), (5, 14, 10)
]):
    y = 32 + idx * 12
    p4.rectfill(9, y, 17, y + 8, badge_col); p4.rect(9, y, 17, y + 8, 5)
    p4.rectfill(21, y, 29, y + 8, avatar_col); p4.rect(21, y, 29, y + 8, 5)
p4.draw_nav(4)
p4.to_image().save(ROOT / "assets" / "design" / "clean_preview_records.png")

# Combined 2x2 collage matching locked_reference
sheet = Image.new("RGB", (128 * 4 * 2 + 16, 128 * 4 * 2 + 16), (240, 235, 225))
sheet.paste(p1.to_image(), (0, 0))
sheet.paste(p2.to_image(), (128 * 4 + 16, 0))
sheet.paste(p3.to_image(), (0, 128 * 4 + 16))
sheet.paste(p4.to_image(), (128 * 4 + 16, 128 * 4 + 16))
sheet.save(ROOT / "assets" / "design" / "clean_preview_all.png")

print("Generated clean_preview_all.png and individual screen previews")
