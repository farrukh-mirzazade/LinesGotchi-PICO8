# Open Questions

## Lines

- Board size: `8x8` for MVP.
- Number of colors: `5` for MVP.
- Clear length: fixed at `5+` for MVP.
- Diagonals: enabled from the start.
- New balls per non-scoring move: `3`.

## Gotchi

- Hunger scale direction: `0 = full`, `100 = starving`.
- Main UI displays `full = 100 - hunger`; feeding fills this bar.
- Feeding does not increase happiness in MVP.
- Death and new-egg restart are implemented.
- Stage timing is implemented; distinct evolved species and sprites remain.
- Pet appears during Lines as a compact expression/status indicator.
- Weight affects health gradually. The healthy range is `6..16`; values outside
  it lower sustainable health over care ticks.

## Records

- MVP saves high score, games played, total lines, and best line.
- Hall of Gotchi remains a later feature.

## Visual Style

- Care screen uses an egg-shaped 1997-style shell, monochrome LCD, seven care
  icons and blinking Attention. Lines remains colourful for game readability.
