# LinesGotchi

PICO-8 project workspace for LinesGotchi: a compact hybrid of Color Lines and a virtual pet.

This repository is currently prepared for development only. Gameplay code has not been implemented yet.

## Local Tools

- PICO-8: `/home/farrukh/.local/bin/pico8`
- VSCode: `/home/farrukh/.local/bin/code`
- Obsidian: `/home/farrukh/.local/bin/obsidian`

## Workspace Layout

- `carts/` - PICO-8 cartridge files.
- `src/` - future split Lua/PICO-8 source files, if we decide to use includes or export tooling.
- `docs/` - Obsidian vault and design documentation for this project only.
- `assets/` - references, screenshots, and future art notes.
- `builds/` - future exported builds.
- `exports/` - future exported carts/images/html packages.
- `scripts/` - local helper scripts for development.

## Current Target

Prepare a first playable MVP:

- Pet screen.
- `PLAY` action opens Lines.
- Lines raises happiness.
- Lines increases hunger over time/activity.
- Feeding lowers hunger and raises weight.
- Lines slightly lowers weight.
- Local records are saved.

See `docs/00_INDEX.md` for the living specification.
