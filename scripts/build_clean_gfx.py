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
    assert len(rows) == 8 and all(len(row) == 8 for row in rows), sid
    put((sid % 16) * 8, (sid // 16) * 8, rows)

# ----------------------------------------------------------------------
# 1. STARTER PET (24x24 = 3x3 tiles, 5 facial expressions)
# ----------------------------------------------------------------------
# Native 24x24 master. Expressions share one limb-free silhouette.
def draw_pet_body(x0, y0):
    put(x0, y0, [
        ".........11.............",
        ".........1c1............",
        "..........1c111.........",
        ".......111cccc111.......",
        ".....11cccccccccc11.....",
        "....1cccccccccccccc1....",
        "...1cccccccccccccccc1...",
        "..1cccccccccccccccccc1..",
        "..1cccccccccccccccccc1..",
        ".1cccccccccccccccccccc1.",
        ".1cccccccccccccccccccc1.",
        ".1cccccccccccccccccccc1.",
        ".1cccccccccccccccccccc1.",
        ".1cccccccccccccccccccc1.",
        ".1cccccccccccccccccccc1.",
        ".1cccccccccccccccccccc1.",
        "..1cccccccccccccccccc1..",
        "..1cccccccccccccccccc1..",
        "...1cccccccccccccccc1...",
        "....1cccccccccccccc1....",
        ".....1cccccccccccc1.....",
        "......11cccccccc11......",
        "........11111111........",
        "........................",
    ])
    # One-pixel lower rim, not a dark belly.
    for x, y in [(4,17),(5,18),(6,19),(7,20),(8,20),(9,21),
                 (10,21),(11,21),(12,21),(13,21),(14,21),(15,20),(16,20),(17,19)]:
        px(x0+x, y0+y, "d")

def draw_face(x0, y0, expression):
    if expression == "sleepy":
        for x in (5,14):
            put(x0+x, y0+11, ["1....1", ".1111."])
    else:
        for x in (4,13):
            put(x0+x, y0+8, [
                "..777..",
                ".77777.",
                "7711177",
                "7711117",
                "7111117",
                "7111117",
                ".71117.",
                "..777..",
            ])
    if expression == "hungry":
        put(x0+10,y0+17, [".11.", "1771", "1111"])
    elif expression == "sleepy":
        put(x0+10,y0+17, [".11.", "1..1"])
    elif expression == "excited":
        put(x0+9,y0+17, ["111111", ".1881.", "..11.."])
    else:
        put(x0+10,y0+17, ["1111", ".81."])

# Generate 5 pet faces side-by-side at x = 0, 24, 48, 72, 96, y = 0
for idx, expr in enumerate(["happy", "neutral", "hungry", "sleepy", "excited"]):
    x_pos = idx * 24
    draw_pet_body(x_pos, 0)
    draw_face(x_pos, 0, expr)

# ----------------------------------------------------------------------
# 2. PUZZLE BALLS (8x8, sprites 48-54)
# ----------------------------------------------------------------------
def make_ball(sid, main_col, shade_col, highlight_col="7", outline_col="1"):
    # Bright 8x8 sphere: a coloured rim and a small upper-left specular.
    # Keep the silhouette identical across all five playable colours.
    rows = [
        f"..{main_col}{main_col}{main_col}{main_col}..",
        f".{main_col}{highlight_col}{highlight_col}{main_col}{main_col}{main_col}.",
        f"{main_col}{highlight_col}{main_col}{main_col}{main_col}{main_col}{main_col}{shade_col}",
        f"{main_col}{main_col}{main_col}{main_col}{main_col}{main_col}{main_col}{shade_col}",
        f"{main_col}{main_col}{main_col}{main_col}{main_col}{main_col}{main_col}{shade_col}",
        f"{main_col}{main_col}{main_col}{main_col}{main_col}{main_col}{shade_col}{shade_col}",
        f".{shade_col}{main_col}{main_col}{main_col}{shade_col}{shade_col}.",
        f"..{shade_col}{shade_col}{shade_col}{shade_col}..",
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
# Filled silhouettes remain legible at 8x8 in both focus states.
sprite(64, ["...77...", "..7777..", ".777777.", "77777777",
            ".777777.", ".77..77.", ".77..77.", ".77..77."])
sprite(65, ["77.77.77", "77.77.77", "........", "77.77.77",
            "77.77.77", "........", "77.77.77", "77.77.77"])
sprite(66, ["......77", "......77", "...77.77", "...77.77",
            "77.77.77", "77.77.77", "77.77.77", "77.77.77"])
sprite(67, [".777777.", "77aaaa77", "7.aaaa.7", ".77aa77.",
            "...aa...", "...77...", "..7777..", ".777777."])
sprite(68, ["...77...", ".7.77.7.", "..7777..", "777..777",
            "777..777", "..7777..", ".7.77.7.", "...77..."])
sprite(69, ["...77...", "...77...", "...77...", "77777777",
            "77777777", "...77...", "...77...", "...77..."])
sprite(70, ["...88...", "..8888..", ".b.88.c.", "bbb..ccc",
            ".b.aa.c.", "..aaaa..", "...aa...", "........"])
sprite(71, ["7......7", ".7....7.", "..7..7..", "...77...",
            "...77...", "..7..7..", ".7....7.", "7......7"])

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
# Large room window: native 32x32, tiles 160..163 / 208..211.
# The map is unused; the shared sprite bank is reserved for room and bezel art.
fill(0,80,31,111,"4")
fill(1,81,30,110,"f")
fill(2,82,29,109,"c")
fill(15,82,16,109,"4")
fill(2,96,29,97,"4")
put(4,86, ["..777...", ".77777..", "7777777."])
put(19,86, ["..aaa..", ".aaaaa.", "aaaaaaa", "aaaaaaa", ".aaaaa.", "..aaa.."])
put(3,101, ["...33.......", "..3bb3......", ".3bbbb3.....", "3bbbbbb3....",
            "bbbbbbbb3333", "bbbbbbbbbbbb", "333333333333", "333333333333"])
put(17,100, [".....33.....", "....3bb3....", "...3bbbb3...", "..3bbbbbb3..",
             ".3bbbbbbbb3.", "3bbbbbbbbbb3", "bbbbbbbbbbbb", "333333333333", "333333333333"])
fill(15,82,16,109,"4")
fill(2,96,29,97,"f")

# 16x16 hanging portrait in tiles 164/165/180/181.
put(32,80, [".......44.......", "......4ff4......", ".....4ffff4....."])
fill(33,83,46,95,"4")
fill(34,84,45,94,"f")
fill(35,85,44,93,"7")
put(36,87, [".ee..ee.", "eeeeeeee", "eeeeeeee", ".eeeeee.", "..eeee..", "...ee..."])

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
