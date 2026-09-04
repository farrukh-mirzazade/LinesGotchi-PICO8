# Functional Audit

Date: 2026-09-04

Runtime: locally installed PICO-8, headless execution through `-x`.

Result: **40 passed, 0 failed**.

## Verified Areas

### Pet And Care

- Home has no care side effects.
- Feeding consumes one tomato and increases fullness and weight.
- Feeding does not increase happiness.
- Feeding is blocked while eating and when already full.
- Sleep and toilet rewards cannot be farmed repeatedly.
- Overweight lowers health; healthy weight restores it gradually.

### Lines Session Lifecycle

- Quit asks for confirmation and `X` cancels it.
- `X` cancels a selected ball before opening quit confirmation.
- Quit grants no records, rewards, EXP, or age.
- Completed games update records and rewards.
- A new board contains exactly five balls and starts at score zero.
- Partial spawning correctly detects a full board.
- Next Preview colors spawn exactly once and then reroll.
- Clear animation restores marked balls temporarily and removes them afterward.

### Board Logic

- Reachability succeeds on an open path and fails for a blocked destination.
- Horizontal lines clear correctly.
- Vertical lines clear correctly.
- Both diagonal directions clear correctly.
- Four balls do not clear.
- Intersecting lines clear unique cells without double counting.

### Persistence And Progression

- Pet values round-trip through cartdata slots.
- Care state and settings round-trip correctly.
- Baby, Child, Teen, and Adult thresholds resolve correctly.
- Large EXP rewards can cross multiple level thresholds.
- The third completed session advances age; quit sessions do not.
- Legacy saves without `sleep_ready` migrate to a usable default.

## Protected Functions

The audit retained the protected implementations:

- `can_reach()` SHA-256:
  `11259e851b4724a55c6145d703d06237bafb66f67b2f9174e0ce5dfd4cc0b47f`
- `clear_lines()` SHA-256:
  `0b1fd18bfe5b4bc867c5386ceca35992fa6ff333ea81fee6e8cacd6dbcd89324`

## Build Verification

The final cartridge exports successfully to the gitignored local files:

- `build/linesgotchi.html`
- `build/linesgotchi.js`

Visual behavior was intentionally not changed during this functional audit.
