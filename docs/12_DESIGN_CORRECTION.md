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
- Place the wall-floor boundary behind the pet's feet. Add a grounded shadow,
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
