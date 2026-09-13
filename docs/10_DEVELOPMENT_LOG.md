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

## 2026-09-05 - Text Readability Pass

- Added `ui_print()` helper for consistent text rendering with shadow to improve
  readability across all gameplay screens.
- Updated all explicit `print()` calls to use `ui_print`, including notice text,
  stat labels, settings/records/result lines, and action prompts.
- Adjusted a few fragile labels to avoid low-contrast combinations on light
  and cyan-accented backgrounds.
- No logic or gameplay functions changed in this pass; this is a pure UI
  readability pass.
- Feeding moved into the existing tomato control in Stats/care, above toilet
  and sleep. Up/Down chooses, O acts. Only a focus outline was added.
- Blocked feeding during sleep and starting sleep during eating.
- Current suite: 34 native assertions passed, including repeated X from all
  six screens and all three care controls. Existing five-colour queue pixel
  checks also pass. No sprite or protected algorithm changes.
- More pet-care depth is requested; no new needs or progression rules were
  silently added in this focused fix.

## 2026-09-05 - Energy And Gradual Sleep Recovery

- User approved the next small functional step: energy and meaningful sleep.
- Added bounded energy, awake-time and successful-move costs, and gradual
  recovery. Removed instant health/happiness awards from starting sleep.
- Preserved existing games at zero energy; block only new sessions until rest.
  Repeated sleep activation cannot restart or accelerate the timer.
- Added save slots 21-23 with old-save defaults and phase-preserving reload.
  No offline simulation is claimed.
- Reused the existing sleep status text for energy percent; no artwork or
  screen geometry changes. Detailed initial balance is in [[04_GOTCHI]].
- Native suite passes 51 assertions plus five-colour pixel comparisons;
  can_reach and clear_lines remain byte-identical to their baseline.

## 2026-09-05 - Cartridge Cover

- Generated cover with built-in imagegen: LinesGotchi title, round blue baby
  pet without limbs, cozy room and five-colour Lines board.
- Source artwork: `assets/design/linesgotchi_cover_v1.png`.
- Imported the cover with local PICO-8 into its 128x128 label format; preview:
  `assets/design/linesgotchi_cover_label.png`.
- Replaced only `__label__` in `carts/linesgotchi.p8`. Code, sprites, audio,
  and gameplay are unchanged. Visually checked the native PNG export.
- Shareable PICO-8 cartridge: `exports/linesgotchi.p8.png`. This is a playable
  cartridge for PICO-8, not a standalone browser build.

### Cover Revision: Small-Label Composition

- User rejected the detailed first cover at cartridge size. Generated v2
  with built-in imagegen, specifically composed for a 128x128 label.
- Prompt: two-line Lines/Gotchi title with margins, large round blue baby
  without limbs, five evenly spaced coloured balls, simple flat background,
  PICO-8 palette, no room details or decorative frame.
- Source: `assets/design/linesgotchi_cover_v2.png`. The generator returned
  larger raster artwork; PICO-8 imported it into its native label format.
  This is not a claim that the generator produced a native 128x128 file.
- Updated `linesgotchi_cover_label.png`, cart label and PNG cartridge export.
  Inspected both the 128x128 label and the complete 160x205 cartridge.
- Compared against the pre-revision cart: every byte outside `__label__`
  is unchanged. No gameplay tests needed for this label-only replacement.
- Centered the label artwork on request: moved existing pixels 5 pixels left
  and 4 pixels up, without scaling or redrawing. Horizontal margins are now
  13 pixels each; vertical margins are 3 and 4 pixels. Re-exported the label
  preview and PNG cartridge and visually checked the result.

## 2026-09-12 - Original Virtual-Pet Care Loop

- Replaced the five-tab application navigation on the pet screen with a single
  classic LCD and original-style A/B/C interaction: Left/Right select, O
  confirms, X cancels.
- Added Food (Meal/Snack), Light (On/Off), Game (Lines), Medicine, Toilet,
  four-page Status and Discipline. The eighth icon is a blinking Attention
  indicator rather than a selectable command.
- Added periodic mess, illness requiring one to three medicine doses, false
  calls, justified and unjust discipline, unresolved-care mistakes, automatic
  sleep, light stress during sleep, health loss, death and new-egg restart.
- Removed tomato inventory from feeding and RPG level rewards from the Lines
  result. Growth stage now follows virtual age. Lines remains the hybrid's
  central mini-game and still affects hunger, happiness and weight.
- Added cartdata schema slots 24-36 for the new care state while preserving old
  saves and record slots.
- Reworked the pet view as an egg-shaped pale shell with a monochrome LCD and
  three physical-button marks. No copyrighted Bandai logo or character sprite
  was introduced; the round LinesGotchi baby remains the pet.
- Replaced obsolete care tests with interaction and state tests for all seven
  icons. Native suite passes 50 checks; five-colour queue comparisons pass;
  `can_reach` and `clear_lines` hashes remain unchanged.
- Follow-up audit added persisted death/new-egg state, a short protected egg
  hatch, original-style X+Left sound toggle, and visible Child/Teen/Adult
  silhouette changes. Adult form branches into three care-quality variants.
- Removed unreachable legacy Stats, Records and Settings screen code after the
  single-LCD menu replaced it. Records remain available on Status page 4 and
  sound remains available through the original-style shortcut.

## 2026-09-13 - Strict Eight-Icon LCD Grid

- Corrected the care menu to show exactly eight icons at all times: four above
  and four below the pet area.
- Both rows now share columns x=24, 48, 72 and 96. The previous 22-pixel step
  biased both rows to the left.
- Attention remains visible in a muted LCD colour while idle and blinks dark
  when care is required. It remains an indicator rather than an eighth action.
- Added native screenshot assertions for all eight icon cells and row alignment.

## 2026-09-13 - Full-Screen Pet LCD

- User supplied an original interface reference and explicitly removed the
  decorative Tamagotchi-like shell from the game view.
- The complete 128x128 PICO-8 viewport is now the LCD. Removed the shell,
  LinesGotchi heading and three decorative hardware buttons.
- Preserved the approved eight-icon rule despite the supplied reference showing
  five icons per row: four icons now sit at x=12, 44, 76 and 108 on y=6 and
  y=114, leaving the full centre area for the pet and care states.
- Replaced the oversized selection corners with a small inward-facing underline
  so selecting an action does not change the apparent icon size.
- User then approved matching the reference's five-icons-per-row geometry.
  The LCD now has ten permanent positions at x=8, 34, 60, 86 and 112.
  Records and Sound fill the two added actionable positions; Attention remains
  the tenth, non-selectable indicator.
- Native suite now includes direct Records and Sound icon checks: 52 checks in
  total, plus the ten-cell screenshot assertion and Lines queue comparison.

## 2026-09-13 - Baby Pet Face Polish

- Kept the approved five-by-two menu positions and all care interactions
  unchanged.
- Rebuilt the shared 24x24 Baby silhouette as a clean symmetric circle without
  arms, legs, a top tuft or a heavy lower rim.
- Reworked all five expressions with rounded outlined eyes, smaller pupils and
  clearer mouths. The happy state now uses a simple curved pixel smile.
- Changed the monochrome LCD rendering to a light body with dark outlines and
  facial features. The Lines side panel retains the full-colour blue version.
- Native suite passes all 52 checks. `can_reach` and `clear_lines` hashes are
  unchanged, and the ten-icon alignment assertion still passes.

## 2026-09-13 - PicoGotchi Product Pivot References

- Analysed eight user-supplied original virtual-pet reference images; two pairs
  were exact duplicates, leaving six unique references.
- Defined the new priority: pet care and branching evolution are the product;
  Lines becomes one optional mini-game.
- Selected the simpler Gen 1 care-driven tree as the feasible foundation.
  Family groups, jobs and a large food catalogue remain later expansions.
- Added [[14_PICOGOTCHI_REFERENCE_ANALYSIS]] with original-content boundaries,
  a proposed roster, evolution inputs, save migration requirements and an
  implementation order.
- Updated the vault index and top-level TZ. No cartridge code, visuals or save
  identifiers were changed in this documentation-only step.
- Locked the first lifecycle decisions: dual timing profiles, Adult near day
  six, at most 12 hours of offline simulation, offline-death protection,
  permanent life endings with persistent history, and hidden evolution rules.
