# Development Log

This is the chronological engineering log for LinesGotchi. Update it with each
completed development pass before committing and pushing.

## 2026-09-03

- Created the isolated `LinesGotchi-PICO8` project and GitHub repository.
- Configured the local PICO-8, VSCode, Obsidian, and Git workflow.
- Added the first playable cartridge with Pet, Lines, Stats, Records, and Result
  screens.
- Implemented the 8x8 Lines board, pathfinding, four-direction line detection,
  score handling, pet stats, and local records.
- Refined the initial screen layout and feeding behavior.

Commits already published:

- `85ebc73` - Initialize LinesGotchi README.
- `2d2f8b5` - Add LinesGotchi project workspace.
- `02d9355` - Build first playable LinesGotchi prototype.
- `b761ff7` - Refine pet UI and feeding behavior.
- `93fa2eb` - Tighten visual layout for PICO-8 screens.

## 2026-09-04 - Visual Production Pass

- Locked `assets/design/locked_reference.png` as the visual source of truth.
- Added reference crops and 128x128 PICO-8 screen references.
- Replaced fractional sprite scaling with strict 1:1 rendering.
- Built five 24x24 pet expressions and 8x8 puzzle balls and icons.
- Added room props, navigation icons, status icons, and 9-slice bezel tiles.
- Added clean sprite and preview tooling without image resampling or automatic
  palette quantization.
- Added three-ball Next Preview and selected-ball/pet micro-animation.
- Added five SFX entries and sound/hint settings.
- Added line-clear flash and particle staging while preserving the protected
  line-detection function.

## 2026-09-04 - Gameplay And Persistence Pass

- Added quit confirmation to Lines.
- Persisted pet stats, records, settings, care state, level, EXP, age, and growth
  data through `cartdata("linesgotchi_v2")`.
- Added toilet and sleep interactions.
- Added gradual weight-to-health effects and Baby, Child, Teen, and Adult stage
  thresholds.
- Removed demo records and demo progression from new-profile defaults.
- Corrected Home so repeated activation cannot feed the pet.
- Moved feeding to `X` on the Pet screen and added eating/full guards.
- Removed the incorrect happiness gain from feeding.
- Prevented quit sessions from granting records, rewards, EXP, or age.
- Prevented repeated sleep and toilet reward farming.
- Added multi-level EXP processing and save migration safeguards.
- Ensured every new Lines board starts with five balls and zero score.

## Current State

- Functional runtime audit: 40 passed, 0 failed.
- Native PICO-8 HTML export succeeds.
- `can_reach()` and `clear_lines()` remain unchanged from the protected baseline.
- Visual design correction has resumed; see [[12_DESIGN_CORRECTION]].

## 2026-09-04 - Reference Fidelity Review

- User rejected the bird-like small-eyed pet, rough menu/grid, and empty room.
- Compared the locked reference directly with the existing preview collage.
- Identified a flattened body, dark belly band, undersized eyes, undersized room
  props, and excessive cell bevels as specific discrepancies.
- Used built-in imagegen with the locked reference to create
  `assets/design/reference_correction_sheet_v3.png` as a supporting art brief.
- This generated sheet does not replace the approved reference or the cartridge.
  Its board geometry is not a valid 8x8 production asset.
- Recorded production constraints and remaining implementation work in
  [[12_DESIGN_CORRECTION]]. No gameplay or cartridge changes in this design pass.
