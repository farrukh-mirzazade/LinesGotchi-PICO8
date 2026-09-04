# Lines System

## Baseline

The Lines mode should be simple and close to classic Color Lines.

## Implemented MVP Rules

- Board: `8x8`.
- Colors: `5`.
- Clear line length: `5`.
- Lines: horizontal, vertical, and diagonal.
- Three previewed balls spawn after a non-scoring move.
- A selected ball can move only through empty orthogonal cells.
- Cleared balls flash for 10 frames before final removal.
- Leaving Lines requires `X`, then `O` to confirm or `X` to cancel.
- Input: keyboard/gamepad first.

`can_reach()` and `clear_lines()` are protected core functions. Refactors must
preserve their behavior and should verify their source hashes before and after
changes.
