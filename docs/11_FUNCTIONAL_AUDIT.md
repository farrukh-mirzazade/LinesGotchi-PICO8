# Functional Audit

Date: 2026-09-04

Runtime: locally installed PICO-8, headless execution through `-x`.

Result: **40 passed, 0 failed**.

This is a historical audit. The current reproducible suite is
`python3 scripts/check_native.py`; its 2026-09-05 care-input revision passes
34 assertions plus native pixel checks, not a repeat of all 40 older checks.

## 2026-09-05 Care Input Regression

- Reproduced the reported defect before fixing it: X returns from secondary
  screens to Home, where repeated X used to call feed_pet.
- Repeated X 120 times starting from each of all six screens: hunger,
  tomato inventory and eating state remain unchanged after the fix.
- Food is now selected through the existing tomato panel in Stats/care.
  Opening that screen alone does not feed; O on the tomato does.
- Verified food consumption, cooldown, full-pet and empty-inventory guards,
  sleep/feeding mutual exclusion, and Up/Down access to all three care actions.
- Art and layout are unchanged except the food panel's focus outline.
- Protected pathfinding and line detection still match the baseline.

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
