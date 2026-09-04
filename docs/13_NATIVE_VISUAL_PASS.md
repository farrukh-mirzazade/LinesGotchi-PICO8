# Native Visual Pass

Date: 2026-09-05

## Target And Scope

The user supplied the limb-free v4 sheet as the implementation target. The
original locked reference remains intact. This pass changes native sprite
data and screen rendering, not the protected pathfinding or line detector.
It is a playable native adaptation, not a claim of pixel-identical reproduction
of a much larger illustration.

## Implemented

- Five native 24x24 Baby expressions on one round silhouette without arms,
  feet or wings. Larger white eye surrounds and a separate mouth.
- Authored sprite data is stored in the cartridge's sprite editor. No source
  reference image was quantized, imported at fractional scale, or resampled.
- A native 32x32 window, 16x16 heart portrait, floorboards, plant, bookshelf
  and grounded shadow replace the mostly empty room.
- Teal, purple, coral and green device bodies use the existing 9-slice sprites.
  Display-palette mappings survive temporary draw-palette resets.
- Five readable menu silhouettes fit between x=7 and x=120; the rightmost
  button no longer extends outside the inner device bounds.
- Lines uses 72x72 board geometry with 9px pitch and 8x8 balls. Corrected
  malformed seven-character rows in the ball source and added tile assertions.
- Thin separators replace heavy cell bevels. Selection bounces upward so a
  following row cannot erase the selected ball's lower edge.
- The sidebar includes three preview sprites, status bars and a native 24x24
  pet. Confirmation and message panels stay within screen bounds.
- Stats and Settings use compact layouts with real values and existing care
  controls. Large values are abbreviated and right-aligned.
- Records displays actual local totals instead of fabricated ranked players.
  This intentionally differs from the illustrative leaderboard in the sheet.
- Quit results display zero food reward.

## Verification

Run from the project directory:

```bash
python3 scripts/build_clean_gfx.py
python3 scripts/check_native.py
bash scripts/run_pico8_cart.sh
```

The reproducible harness runs the installed PICO-8 with isolated input and
in-memory cartdata; it never modifies the player's save. Sixteen assertions
pass: Home repetition, initial population, preview count and spawn colours,
open/blocked paths, four line directions, short-line rejection, quit/cancel,
pet save roundtrip, sound and hints toggles.

Both protected functions match commit f45a081 byte-for-byte. This is a focused
regression suite, not a claim that every gameplay state has been exhausted.

Screenshots come from the real cartridge renderer through PICO-8's
extcmd("screen",4), including native text. Seven main/overlay captures pass
512x512 dimensions, <=16 colours and uniform 4x4 pixel-block checks.
All five expressions and selected/message/large-value states were also
captured. Main screens, settings, confirmation and result were visually read.

Tracked evidence: assets/review/native-2026-09-05/.
Full reproducible output: build/native-review/ (ignored).
The old scripts/render_preview.py manually reconstructs an obsolete layout
and omits text; do not use it for acceptance.

HTML export succeeded through the installed PICO-8:

```bash
/home/farrukh/.local/bin/pico8 -export build/linesgotchi.html carts/linesgotchi.p8
```

## Remaining Fidelity Limits

The supplied sheet has smooth shading and detail beyond these native assets.
The 24x24 pet, room decoration, plastic highlights and icon contours are still
simpler than that illustration. User acceptance is outstanding. No statement
of one-to-one visual parity or completed exhaustive gameplay QA is made.

## Lines Polish: Five Colours And Queue

The follow-up changes only the Lines presentation and ball artwork:

- One centred preview tray (x=88..119, y=92..101), centred NEXT label, and
  three 8x8 balls at x=90/100/110, y=93. Equal 2px horizontal margins/gaps.
  A small upward move of the sidebar pet creates room above the bottom bezel.
- All five playable colours keep the same circular silhouette. A coloured
  rim, less dark shading and small white highlights increase visible colour.
  Green uses its vivid native palette value only on the Lines screen.
- A light board with peach separators improves colour contrast without
  changing the 8x8 grid, cell pitch, selection or gameplay.
- The native harness captures both queue combinations needed to cover all
  five colours. Every pixel of each queued ball matches its board counterpart.
  All 16 gameplay regression checks still pass.
- Latest review captures: assets/review/lines-polish/lines.png and
  assets/review/lines-polish/five_colours.png.
