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

## 2026-09-05 - Baby Reference And Geometry Correction

- User clarified that the initial pet must have no arms or legs and rejected
  references without verified PICO-8 feasibility.
- Generated a limb-free character correction, rejected two seven-column board
  edits, then saved the annotated eight-by-eight candidate as
  `assets/design/reference_correction_sheet_v4.png`.
- Checked all eight pet depictions and board cell count visually. Recorded
  remaining nonsquare cell proportions, missing NEXT and unverified palette
  and detail in [[12_DESIGN_CORRECTION]]. This is not a production-ready sheet.
- Checked display/sprite/token constraints against the installed 0.2.7 manual;
  documented integer-coordinate board/sidebar geometry and native acceptance
  requirements. No claim of a native runtime visual test in this pass.
- Corrected the obsolete reference instruction mentioning the Baby's feet.
- Original locked reference, game logic, sprite data and web build unchanged.

## 2026-09-05 - Native Reference Implementation

- Implemented limb-free Baby sprites, room artwork, native-size balls, compact
  menus, device colours and revised screen layouts in the playable cartridge.
- Corrected malformed ball rows, rightmost menu overflow, palette resets and
  selected-ball downward clipping. Replaced fabricated ranking data with real
  local totals and corrected displayed food reward on quit.
- Added scripts/check_native.py: isolated real PICO-8 execution, 16 passing
  regression assertions and exact protected-function comparison.
- Captured native screenshots with real text and verified the main captures'
  dimensions, palette count and integer pixel grid. Tracked six review images.
- Exported the HTML build successfully. Full visual parity is not claimed;
  details and remaining limitations are in [[13_NATIVE_VISUAL_PASS]].

## 2026-09-05 - Lines Queue And Colour Polish

- Responded to misaligned NEXT balls and dull colours: added a shared centred
  tray, equal spacing, brighter ball surfaces and a lighter board.
- Kept exactly five playable colours and native 8x8 sprite rendering. No game
  rules, pet sprites, other screen layouts or protected functions changed.
- Re-ran 16 passing native regression checks and added pixel-for-pixel
  queue/board comparisons covering all five colours.
- Saved actual PICO-8 review captures under assets/review/lines-polish/.

## 2026-09-05 - Remove Accidental X Feeding

- User reported feeding through repeated X from every screen and requested
  small functional fixes without further visual redesign.
- Added a failing native regression, reproduced the Home X feed binding,
  and removed it. X is now back/cancel outside Home and inert on Home.
- Feeding moved into the existing tomato control in Stats/care, above toilet
  and sleep. Up/Down chooses, O acts. Only a focus outline was added.
- Blocked feeding during sleep and starting sleep during eating.
- Current suite: 34 native assertions passed, including repeated X from all
  six screens and all three care controls. Existing five-colour queue pixel
  checks also pass. No sprite or protected algorithm changes.
- More pet-care depth is requested; no new needs or progression rules were
  silently added in this focused fix.
