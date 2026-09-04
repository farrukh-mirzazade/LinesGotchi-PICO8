#!/usr/bin/env python3
"""Build clean, pixel-perfect PICO-8 spritesheet for LinesGotchi."""

from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CART = ROOT / "carts" / "linesgotchi.p8"
W = H = 128
gfx = [["0" for _ in range(W)] for _ in range(H)]

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

def px(x, y, color):
    if 0 <= x < W and 0 <= y < H:
        gfx[y][x] = color

def fill(x0, y0, x1, y1, color):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px(x, y, color)

def put(x, y, rows):
    for yy, row in enumerate(rows):
        for xx, color in enumerate(row):
            if color != ".":
                px(x + xx, y + yy, color)

def sprite(sid, rows):
    put((sid % 16) * 8, (sid // 16) * 8, rows)

# ----------------------------------------------------------------------
# 1. STARTER PET (24x24 = 3x3 tiles, 5 facial expressions)
# ----------------------------------------------------------------------
# Base round body silhouette
# Colors: 1 = outline, c = light blue, d = shade/belly, 7 = white, 8 = mouth/tongue, e = blush

def draw_pet_body(x0, y0):
    # Tufts of hair (3 prongs on top)
    # Middle tuft
    px(x0 + 11, y0 + 1, "1"); px(x0 + 12, y0 + 1, "1")
    px(x0 + 11, y0 + 2, "c"); px(x0 + 12, y0 + 2, "c")
    # Left tuft
    px(x0 + 9,  y0 + 2, "1"); px(x0 + 10, y0 + 2, "1")
    px(x0 + 10, y0 + 3, "c")
    # Right tuft
    px(x0 + 13, y0 + 2, "1"); px(x0 + 14, y0 + 2, "1")
    px(x0 + 13, y0 + 3, "c")

    # Body spans (round chubby bean / sphere)
    spans = [
        (3, 7, 16),
        (4, 5, 18),
        (5, 4, 19),
        (6, 3, 20),
        (7, 2, 21),
        (8, 2, 21),
        (9, 2, 21),
        (10, 2, 21),
        (11, 2, 21),
        (12, 1, 22),
        (13, 1, 22),
        (14, 1, 22),
        (15, 2, 21),
        (16, 2, 21),
        (17, 3, 20),
        (18, 4, 19),
        (19, 6, 17),
    ]
    for y, x_start, x_end in spans:
        # Outline
        px(x0 + x_start, y0 + y, "1")
        px(x0 + x_end,   y0 + y, "1")
        # Fill body
        for x in range(x_start + 1, x_end):
            # Soft shadow at bottom
            if y >= 17:
                px(x0 + x, y0 + y, "1")
            elif y >= 15:
                px(x0 + x, y0 + y, "d")
            else:
                px(x0 + x, y0 + y, "c")

    # Tiny arms on sides
    # Left arm
    px(x0 + 0, y0 + 12, "1"); px(x0 + 0, y0 + 13, "1")
    px(x0 + 1, y0 + 12, "c"); px(x0 + 1, y0 + 13, "c")
    # Right arm
    px(x0 + 23, y0 + 12, "1"); px(x0 + 23, y0 + 13, "1")
    px(x0 + 22, y0 + 12, "c"); px(x0 + 22, y0 + 13, "c")

    # Tiny feet
    # Left foot
    fill(x0 + 6, y0 + 20, x0 + 8, y0 + 20, "1")
    px(x0 + 7, y0 + 20, "d")
    px(x0 + 7, y0 + 21, "1")
    # Right foot
    fill(x0 + 15, y0 + 20, x0 + 17, y0 + 20, "1")
    px(x0 + 16, y0 + 20, "d")
    px(x0 + 16, y0 + 21, "1")

def draw_face(x0, y0, expression):
    if expression == "happy":
        # Big glossy anime eyes
        # Left eye
        fill(x0 + 5, y0 + 8, x0 + 9, y0 + 12, "1")
        fill(x0 + 6, y0 + 9, x0 + 8, y0 + 11, "1")
        # Big white gloss
        fill(x0 + 6, y0 + 8, x0 + 7, y0 + 9, "7")
        px(x0 + 8, y0 + 11, "7")
        # Right eye
        fill(x0 + 14, y0 + 8, x0 + 18, y0 + 12, "1")
        fill(x0 + 15, y0 + 9, x0 + 17, y0 + 11, "1")
        fill(x0 + 15, y0 + 8, x0 + 16, y0 + 9, "7")
        px(x0 + 17, y0 + 11, "7")
        # Cute smile with open red mouth
        fill(x0 + 11, y0 + 13, x0 + 12, y0 + 14, "8")
        px(x0 + 10, y0 + 13, "1"); px(x0 + 13, y0 + 13, "1")
        px(x0 + 11, y0 + 15, "1"); px(x0 + 12, y0 + 15, "1")

    elif expression == "neutral":
        # Same big glossy eyes
        fill(x0 + 5, y0 + 8, x0 + 9, y0 + 12, "1")
        fill(x0 + 6, y0 + 8, x0 + 7, y0 + 9, "7")
        px(x0 + 8, y0 + 11, "7")
        fill(x0 + 14, y0 + 8, x0 + 18, y0 + 12, "1")
        fill(x0 + 15, y0 + 8, x0 + 16, y0 + 9, "7")
        px(x0 + 17, y0 + 11, "7")
        # Small quiet line mouth
        fill(x0 + 11, y0 + 13, x0 + 12, y0 + 13, "1")

    elif expression == "hungry":
        # Worried / hungry eyes (slightly lowered)
        fill(x0 + 5, y0 + 9, x0 + 9, y0 + 13, "1")
        fill(x0 + 6, y0 + 9, x0 + 7, y0 + 10, "7")
        fill(x0 + 14, y0 + 9, x0 + 18, y0 + 13, "1")
        fill(x0 + 15, y0 + 9, x0 + 16, y0 + 10, "7")
        # Open wavy hungry mouth (gasping)
        fill(x0 + 10, y0 + 14, x0 + 13, y0 + 16, "1")
        fill(x0 + 11, y0 + 15, x0 + 12, y0 + 15, "8")

    elif expression == "sleepy":
        # Closed eyes (cute curved happy / sleepy arcs)
        px(x0 + 5, y0 + 10, "1"); px(x0 + 9, y0 + 10, "1")
        fill(x0 + 6, y0 + 11, x0 + 8, y0 + 11, "1")
        px(x0 + 14, y0 + 10, "1"); px(x0 + 18, y0 + 10, "1")
        fill(x0 + 15, y0 + 11, x0 + 17, y0 + 11, "1")
        # Tiny cute mouth
        px(x0 + 11, y0 + 14, "1"); px(x0 + 12, y0 + 14, "1")
        # Cute "Zzz"
        px(x0 + 19, y0 + 6, "7"); px(x0 + 20, y0 + 6, "7")
        px(x0 + 19, y0 + 7, "7"); px(x0 + 20, y0 + 8, "7")

    elif expression == "excited":
        # Big super sparkly eyes + blush
        fill(x0 + 5, y0 + 7, x0 + 9, y0 + 11, "1")
        fill(x0 + 6, y0 + 7, x0 + 7, y0 + 8, "7")
        px(x0 + 8, y0 + 10, "7")
        fill(x0 + 14, y0 + 7, x0 + 18, y0 + 11, "1")
        fill(x0 + 15, y0 + 7, x0 + 16, y0 + 8, "7")
        px(x0 + 17, y0 + 10, "7")
        # Pink blush on cheeks
        px(x0 + 4, y0 + 12, "e"); px(x0 + 5, y0 + 12, "e")
        px(x0 + 18, y0 + 12, "e"); px(x0 + 19, y0 + 12, "e")
        # Big happy open smile
        fill(x0 + 10, y0 + 12, x0 + 13, y0 + 15, "1")
        fill(x0 + 11, y0 + 13, x0 + 12, y0 + 14, "8")
        px(x0 + 11, y0 + 14, "e")

# Generate 5 pet faces side-by-side at x = 0, 24, 48, 72, 96, y = 0
for idx, expr in enumerate(["happy", "neutral", "hungry", "sleepy", "excited"]):
    x_pos = idx * 24
    draw_pet_body(x_pos, 0)
    draw_face(x_pos, 0, expr)

# ----------------------------------------------------------------------
# 2. PUZZLE BALLS (8x8, sprites 48-54)
# ----------------------------------------------------------------------
def make_ball(sid, main_col, shade_col, highlight_col="7", outline_col="1"):
    # Crisp, symmetrical 8x8 round orb with specular gloss
    rows = [
        f"..{outline_col}{outline_col}{outline_col}{outline_col}..",
        f".{outline_col}{main_col}{main_col}{main_col}{main_col}{outline_col}.",
        f"{outline_col}{highlight_col}{main_col}{main_col}{main_col}{shade_col}{outline_col}",
        f"{outline_col}{main_col}{main_col}{main_col}{main_col}{main_col}{outline_col}",
        f"{outline_col}{main_col}{main_col}{main_col}{main_col}{main_col}{outline_col}",
        f"{outline_col}{main_col}{shade_col}{shade_col}{shade_col}{shade_col}{outline_col}",
        f".{outline_col}{shade_col}{shade_col}{shade_col}{shade_col}{outline_col}.",
        f"..{outline_col}{outline_col}{outline_col}{outline_col}..",
    ]
    sprite(sid, rows)

# 1: Green (11), 2: Blue (12), 3: Pink/Red (14), 4: Yellow (10), 5: Purple (13), 6: Cyan (12/7)
make_ball(48, "b", "3") # Green
make_ball(49, "c", "1") # Blue
make_ball(50, "e", "2") # Pink
make_ball(51, "a", "9") # Yellow
make_ball(52, "d", "2") # Purple
make_ball(53, "7", "6", "7", "5") # White / Silver
make_ball(54, "8", "2") # Red

# Empty board tile (sprite 55) & Cursor (sprite 56)
sprite(55, [
    "77777776",
    "7ffffff6",
    "7ffffff6",
    "7ffffff6",
    "7ffffff6",
    "7ffffff6",
    "7ffffff6",
    "66666666",
])
sprite(56, [
    ".aaaaaa.",
    "a......a",
    "a......a",
    "a......a",
    "a......a",
    "a......a",
    "a......a",
    ".aaaaaa.",
])

# ----------------------------------------------------------------------
# 3. MENU ICONS (8x8, sprites 64-71)
# ----------------------------------------------------------------------
# Home (64)
sprite(64, [
    "...11...",
    "..1771..",
    ".177771.",
    "17777771",
    "17711771",
    "17711771",
    "17711771",
    "11111111",
])
# Grid / Play (65)
sprite(65, [
    "11111111",
    "17171711",
    "11111111",
    "17171711",
    "11111111",
    "17171711",
    "11111111",
    "........",
])
# Stats / Bars (66)
sprite(66, [
    "........",
    "....11..",
    "....171.",
    "..11171.",
    ".171171.",
    ".1711711",
    ".1711717",
    "11111111",
])
# Trophy (67)
sprite(67, [
    ".111111.",
    "1aaaaaa1",
    "11aaaa11",
    ".11aa11.",
    "...11...",
    "...11...",
    "..1aa1..",
    ".111111.",
])
# Gear (68)
sprite(68, [
    "..1111..",
    ".171171.",
    "17177171",
    "117..711",
    "117..711",
    "17177171",
    ".171171.",
    "..1111..",
])
# D-pad (69)
sprite(69, [
    "...11...",
    "...171..",
    "11117111",
    "17777771",
    "11117111",
    "...171..",
    "...11...",
    "........",
])
# Buttons (70)
sprite(70, [
    "...88...",
    "..8888..",
    ".b....a.",
    "bbb..aaa",
    ".b....a.",
    "..cc11..",
    "...11...",
    "........",
])
# Cancel / Cross (71)
sprite(71, [
    "11....11",
    ".11..11.",
    "..1111..",
    "...11...",
    "..1111..",
    ".11..11.",
    "11....11",
    "........",
])

# ----------------------------------------------------------------------
# 4. STATUS ICONS (8x8, sprites 80-87)
# ----------------------------------------------------------------------
# Green Heart (80)
sprite(80, [
    ".11..11.",
    "1bb11bb1",
    "1b7bbbb1",
    "1bbbbbb1",
    ".1bbbb1.",
    "..1bb1..",
    "...11...",
    "........",
])
# Yellow Smiley (81)
sprite(81, [
    "..1111..",
    ".1aaaa1.",
    "1a1aa1a1",
    "1aaaaaa1",
    "1a1aa1a1",
    "1aa11aa1",
    ".1aaaa1.",
    "..1111..",
])
# Star (82)
sprite(82, [
    "...11...",
    "...1a1..",
    "1111a111",
    ".1aaaa1.",
    "..1aa1..",
    ".1a11a1.",
    ".11..11.",
    "........",
])
# Diamond (83)
sprite(83, [
    "...11...",
    "..1cc1..",
    ".1cccc1.",
    "1cccccc1",
    ".1cccc1.",
    "..1cc1..",
    "...11...",
    "........",
])
# Tomato (84)
sprite(84, [
    "...33...",
    "..3bb3..",
    ".188881.",
    "18878881",
    "18888881",
    "18888881",
    ".188881.",
    "..1111..",
])
# Toilet (85)
sprite(85, [
    ".11111..",
    ".17771..",
    ".17771..",
    "1177711.",
    "1cc77cc1",
    ".1cccc1.",
    "..1771..",
    ".111111.",
])
# Moon & Stars (86)
sprite(86, [
    "...11..a",
    "..1aa1..",
    ".1aa1...",
    ".1aa1..a",
    ".1aa1...",
    "..1aa1..",
    "...11...",
    "........",
])
# Bezel Top Heart (87)
sprite(87, [
    ".11..11.",
    "1ee11ee1",
    "1eeeeee1",
    ".1eeee1.",
    "..1ee1..",
    "...11...",
    "........",
    "........",
])

# ----------------------------------------------------------------------
# 5. ROOM PROPS (Pet screen, sprites 96-107)
# ----------------------------------------------------------------------
# Window (16x16, 2x2 tiles, sprites 96, 97 / 112, 113)
# Top-left (96)
sprite(96, [
    "44444444",
    "4cccccc4",
    "4ccaacc4",
    "4caaaac4",
    "4ccaacc4",
    "4cccccc4",
    "4cccccc4",
    "44444444",
])
# Top-right (97)
sprite(97, [
    "44444444",
    "4cccccc4",
    "4c77ccc4",
    "47777cc4",
    "4cccccc4",
    "4cccccc4",
    "4cccccc4",
    "44444444",
])
# Bottom-left (112)
sprite(112, [
    "44444444",
    "4cccccc4",
    "4cccccc4",
    "4cc33cc4",
    "4c3333c4",
    "43333334",
    "43333334",
    "44444444",
])
# Bottom-right (113)
sprite(113, [
    "44444444",
    "4cccccc4",
    "4cccccc4",
    "4cccccc4",
    "4cc33cc4",
    "4c3333c4",
    "43333334",
    "44444444",
])

# Plant on Stool (8x16, sprites 98 / 114)
sprite(98, [
    "...b....",
    "..bbb...",
    ".bb3bb..",
    ".3b33b..",
    "..b33b..",
    ".bb3bb..",
    "..bbb...",
    "...b....",
])
sprite(114, [
    ".499994.",
    ".499994.",
    "..4994..",
    "..4994..",
    ".444444.",
    "..4..4..",
    "..4..4..",
    "..4..4..",
])

# Picture Frame with heart (sprite 99)
sprite(99, [
    "44444444",
    "47777774",
    "47117174",
    "41ee1ee4",
    "41eeee14",
    "471ee174",
    "47711774",
    "44444444",
])

# Bookshelf (sprites 100, 101)
sprite(100, [
    "........",
    ".11..11.",
    ".1c1.181",
    ".1c1.181",
    ".1c1.181",
    ".1c1.181",
    "44444444",
    ".4....4.",
])
sprite(101, [
    "........",
    ".11..11.",
    ".1b1.1a1",
    ".1b1.1a1",
    ".1b1.1a1",
    ".1b1.1a1",
    "44444444",
    ".4....4.",
])

# ----------------------------------------------------------------------
# 6. DEVICE 9-SLICE (sprites 128-136)
# ----------------------------------------------------------------------
# Color 6 is remapped to the screen-specific body color at draw time.
sprite(128, [
    "...55555", "..577777", ".5766666", "57666666",
    "57666666", "57666666", "57666666", "57666666",
])
sprite(129, [
    "55555555", "77777777", "66666666", "66666666",
    "66666666", "66666666", "66666666", "66666666",
])
sprite(130, [
    "55555...", "777775..", "6666675.", "66666675",
    "66666675", "66666675", "66666675", "66666675",
])
sprite(131, [
    "57666666", "57666666", "57666666", "57666666",
    "57666666", "57666666", "57666666", "57666666",
])
sprite(132, [
    "66666666", "66666666", "66666666", "66666666",
    "66666666", "66666666", "66666666", "66666666",
])
sprite(133, [
    "66666675", "66666675", "66666675", "66666675",
    "66666675", "66666675", "66666675", "66666675",
])
sprite(134, [
    "57666666", "57666666", "57666666", "57666666",
    "57666666", ".5766666", "..555555", "...55555",
])
sprite(135, [
    "66666666", "66666666", "66666666", "66666666",
    "66666666", "66666666", "55555555", "55555555",
])
sprite(136, [
    "66666675", "66666675", "66666675", "66666675",
    "66666675", "6666675.", "555555..", "55555...",
])

# ----------------------------------------------------------------------
# Export to preview PNG and update Cartridge
# ----------------------------------------------------------------------
preview = Image.new("RGB", (W, H))
preview.putdata([palette[int(color, 16)] for row in gfx for color in row])
preview.resize((W * 4, H * 4), Image.Resampling.NEAREST).save(ROOT / "assets" / "design" / "clean_spritesheet_preview.png")
print("Saved clean_spritesheet_preview.png")

def make_sfx(notes, speed=8, instrument=2):
    encoded = []
    for pitch, volume in notes:
        encoded.append(f"{pitch:02x}{instrument:x}{volume:x}0")
    encoded.extend(["00000"] * (32 - len(encoded)))
    return f"00{speed:02x}0000" + "".join(encoded)

sfx_lines = [
    make_sfx([(24, 3), (28, 2)], 4),
    make_sfx([(26, 4), (31, 4)], 5),
    make_sfx([(20, 4), (15, 4)], 7, 3),
    make_sfx([(24, 5), (28, 5), (31, 5), (36, 5), (40, 5)], 5),
    make_sfx([(14, 4), (11, 4), (16, 4), (12, 3)], 4, 6),
]

text = CART.read_text()
head = text.split("\n__gfx__\n", 1)[0].rstrip() + "\n"
label = text.split("\n__label__\n", 1)[1] if "\n__label__\n" in text else ""

gfx_block = "__gfx__\n" + "\n".join("".join(row) for row in gfx) + "\n"
sfx_block = "__sfx__\n" + "\n".join(sfx_lines) + "\n"
if label:
    CART.write_text(head + gfx_block + sfx_block + "__label__\n" + label)
else:
    CART.write_text(head + gfx_block + sfx_block)

print(f"Updated sprite sheet in {CART}")
