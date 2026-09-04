# Development Workflow

## VSCode

Use VSCode for code and project files:

```bash
code "/home/farrukh/Projects/PICO-8 (LinesGotchi)"
```

VSCode tasks are prepared:

- `PICO-8: open LinesGotchi cart`
- `PICO-8: run LinesGotchi cart`

These tasks require a normal graphical desktop session.

## Obsidian

Use only this folder as the LinesGotchi vault:

```text
/home/farrukh/Projects/PICO-8 (LinesGotchi)/docs
```

Do not use or modify any BioGotchi vault for this project.

## PICO-8

Main cart scaffold:

```text
/home/farrukh/Projects/PICO-8 (LinesGotchi)/carts/linesgotchi.p8
```

Pixel-perfect graphics and SFX are generated into the cart without image
resampling or palette quantization:

```bash
python3 scripts/build_clean_gfx.py
```

After running this, open the cart in PICO-8 and switch to the Sprite Editor.
The starter pet faces, menu icons, status icons, board tile, cursor, puzzle
balls, room props, and 9-slice bezel pieces should be visible in the sprite
sheet. Do not introduce fractional `sspr` scaling.

Local validation:

```bash
SDL_VIDEODRIVER=dummy /home/farrukh/.local/bin/pico8 -export build/linesgotchi.html carts/linesgotchi.p8
```
