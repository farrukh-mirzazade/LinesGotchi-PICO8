# LinesGotchi

PICO-8 project workspace for LinesGotchi: a compact hybrid of Color Lines and a virtual pet.

The repository contains a playable local build with an original-style virtual
pet care loop, an 8x8 Color Lines game, persistent state, SFX, and a
pixel-perfect PICO-8 sprite sheet.

## Controls

- Left/Right: select a care icon or submenu item (the original A-button role).
- `O`: open or confirm (B-button role).
- `X`: cancel or return (C-button role).
- Hold `X` and press Left: toggle sound.
- The Game icon starts Lines; its own controls are shown on screen.

## Local Tools

- PICO-8: `/home/farrukh/.local/bin/pico8`
- VSCode: `/home/farrukh/.local/bin/code`
- Obsidian: `/home/farrukh/.local/bin/obsidian`

## Workspace Layout

- `carts/` - PICO-8 cartridge files.
- `src/` - future split Lua/PICO-8 source files, if we decide to use includes or export tooling.
- `docs/` - Obsidian vault and design documentation for this project only.
- `assets/` - references, screenshots, and future art notes.
- `build/` - generated local HTML/JavaScript exports (gitignored).
- `builds/` - reserved packaged builds.
- `exports/` - future exported carts/images/html packages.
- `scripts/` - local helper scripts for development.

## Current Target

Stabilize and polish the playable hybrid:

- Full-screen monochrome pet LCD with Food, Light, Game, Medicine, Toilet,
  Status, Discipline, Records, Sound and Attention in a 5x2 icon layout.
- The Game icon opens Lines.
- Lines raises happiness.
- Lines increases hunger over time/activity.
- Meal lowers hunger; Snack raises happiness; both raise weight.
- Lines slightly lowers weight.
- Local records are saved.
- Three upcoming balls are previewed before a non-scoring move.
- Care, growth state, illness, light state and records persist through
  `cartdata`.
- Visual work follows `assets/design/locked_reference.png`.

See `docs/00_INDEX.md` for the living specification.
