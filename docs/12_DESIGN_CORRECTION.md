# Reference Fidelity Correction

Date: 2026-09-04

## Source Of Truth

The approved source remains `assets/design/locked_reference.png`.
`assets/design/reference_correction_sheet_v3.png` is a supporting imagegen
design sheet, not a newly approved replacement and not an executable screen.

## Findings

- The current 24x24 pet has a flattened silhouette, tiny dark eyes and a broad
  dark lower-body band. This loses the reference character's round blue body,
  large white-rimmed eyes and distinct small smiling mouth.
- The room has small isolated props against a nearly featureless wall. Its
  floor division is below the pet, so the character does not feel grounded.
- Thick highlights and shadows dominate the board cells and compete with balls.
- The menu icons lose recognizable shapes at native size. Existing Python
  collages omit text and must not be treated as proof of final UI quality.

## Production Requirements

- Author and inspect the actual native sprites at 1:1. Never automatically
  quantize or shrink the generated concept sheet into a cartridge.
- Keep every expression on the same round silhouette, with large white eye
  surrounds, a small separate mouth and a narrow lower-edge shadow.
- The Baby form has NO arms, hands, wings, legs or feet, in every emotion and
  on every screen. Preserve the round body, large eyes and separate mouth.
- Place the wall-floor boundary behind the pet's lower body. Add a grounded shadow,
  restrained floor detail, a substantial sunny window and readable room props.
- Match the approved Home, Grid, Stats, Trophy and Gear silhouettes and baseline.
- Keep the real board exactly 8x8 and balls exactly 8x8. Use thin cell separators.
- Verify native PICO-8 screenshots including labels, focus, selection, messages
  and every pet expression. Compare to the locked reference before acceptance.

## Generated Sheet Limitations

The generated sheet supports character identity and room composition. It does
not meet the requested exact board geometry or production pixel-grid guarantee.
It is not evidence that the game is fixed or that reference fidelity is complete.
No sprites, draw functions, cartridge, or web build were changed in this pass.

## Image Generation Record

Tool: built-in imagegen, reference-guided generation.
Input: `assets/design/locked_reference.png`.
Output: `assets/design/reference_correction_sheet_v3.png`.

Prompt brief: faithfully preserve the approved blue round pet with enormous
white-rimmed glossy eyes, small smiling mouth and tiny feet; exclude beak,
wing-like limbs, flattened body and dark belly stripe. Preserve turquoise,
purple, coral and green device layouts. Add a coherent room with large sunny
window, foliage, plant, heart portrait, bookshelf, floorboards and cast shadow.
Request exactly 8x8 Lines cells, fine separators, round balls, sidebar and NEXT.
Preserve clear five-button menu and five consistent pet expressions. Request
hard-edged low-resolution pixel art without blur or antialiasing.

## 2026-09-05 - Limb-Free Reference Review

Candidate: `assets/design/reference_correction_sheet_v4.png`.
Generated with built-in imagegen from the v3 sheet. The locked original remains
unchanged. This is an annotated ART DIRECTION candidate, not an approved native
screen or an importable sprite sheet. No cartridge or build changes.

Visual inspection:

- All eight blue pet depictions (three screens and five expressions) have no
  arms or legs. Their round body and large eyes are preserved.
- Two intermediate edits still had seven columns and were rejected.
- The saved third edit has eight columns and eight rows. Five balls occupy
  individual cells and do not cross separators. Column/row labels are review
  annotations, not a requirement for the game UI.
- Cell proportions are still not exactly square. Approximate board extents
  on the generated sheet are x=613..909, y=118..432: 296x314, not 296x296.
  Do not copy these proportions into the cartridge.
- The three-ball NEXT preview is still absent. The five-ball control glyph
  under the board is NOT the preview.
- The sheet contains gradients and fine detail that have not been translated
  to the native palette and pixel grid. Its text, highlights and room props
  cannot be promised unchanged at 128x128.
- Ranking names and numbers remain illustrative, not evidence of an online
  leaderboard. The implemented project's records are local.

## Native Layout Acceptance Gate

Checked the installed 0.2.7 manual (`pico-8_manual.txt`, lines 37-43 and
1423-1425): 128x128 display, 16-colour palette, 8192 code tokens, 128 base
8x8 sprites plus 128 sharing map memory. Full-scene visual parity is NOT
established by this document or by the generated image.

Proposed geometry for native testing, not a replacement screen implementation:

- Board origin (8,24), eight rows/columns, pitch 9: extent 72x72 pixels.
  Each cell uses an 8x8 ball area and a one-pixel separator. Use integer sprite
  coordinates (8+9*column,24+9*row), no resampling. Final ball occupies
  x=71..78, y=87..94; board including separators ends at (79,95).
- Sidebar x=86..121 (36 pixels). A 24x24 pet fits at (92,64).
- NEXT label at (90,36); three 8x8 balls at (90,44), (100,44), (110,44),
  totaling 28 pixels including gaps. Keep this area separate from the score.
- Five 24x24 expressions require 45 base 8x8 tiles, not five tiles. Sprite
  allocation for balls, icons, room and bezels must be checked as a whole.
- Before approval, show actual native PICO-8 screenshots of each screen and
  emotion, at 1:1 and integer zoom, with real text and every focus/overlay state.
- Verify menu bounds, NEXT, quit confirmation, selected-ball bounce and room
  composition. Screenshots must prove that animation does not overlap the HUD.

Status: character correction done in the concept; exact board geometry,
palette, native readability and full screen fidelity remain unverified.
