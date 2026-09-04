# Gotchi System

## Baseline Stats

- Hunger.
- Happiness.
- Health.
- Discipline.
- Weight.
- Age.

## Important Rule

Playing Lines is good for happiness but costs fullness.

Simple relationship:

```text
PLAY LINES -> happiness up
PLAY LINES -> hunger up
FEED       -> hunger down
FEED       -> weight up
PLAY LINES -> weight slightly down
```

## In-Game Pet Presence

The pet should eventually appear beside or near the Lines board and react emotionally to the session.

For MVP, this can be simplified to a small expression/status indicator.

## Implemented Care Rules

- On the Pet screen, `O` activates the selected navigation item.
- On the Pet screen, `X` has no care effect.
- In Stats/care, Up/Down selects tomato (food), toilet, or sleep. `O`
  confirms the selected care action; `X` returns home without applying care.
- Home is navigation only and never changes pet stats.
- Feeding consumes one tomato, lowers hunger, and raises weight.
- Feeding does not increase happiness.
- Feeding is blocked while eating, sleeping, already full, or out of tomatoes.
- Sleep cannot start while eating.
- Toilet rewards cannot be repeated without a new care need.
- Sleep gradually restores energy, with no immediate health/happiness reward.
- Quitting Lines does not grant records, end-of-game rewards, EXP, or age.

## Energy And Sleep

- Energy ranges from 0 to 100. New profiles and pre-energy saves start at 80.
- Awake time costs 1 energy per 900 updates (30 seconds at 30fps).
- Each successful Lines move costs 1 energy. Cursor movement and failed moves
  do not invoke that cost. Energy cannot fall below zero.
- New Lines sessions cannot start at zero energy or while sleeping. A session
  already in progress is not forcibly interrupted when energy reaches zero.
- Sleep restores 2 energy every 30 updates, stopping automatically at 100.
  From zero it takes 50 seconds; from 80 it takes 10 seconds.
- Repeated confirmation does not restart sleep or award extra stats. A fully
  rested pet refuses sleep. Feeding and starting Lines are blocked during sleep.
- The existing sleep panel shows energy percent; a plus prefix means sleeping.
  No panel, icon, sprite or layout redesign was introduced.
- Cartdata slots 21/22 store energy and remaining sleep frames; slot 23 marks
  the energy schema. The existing save namespace and older slots are preserved.
- Sleep resumes from its saved phase after reloading. Closed/paused time is not
  simulated: recovery and energy drain advance only on game updates.
- Invalid saved energy/duration values are bounded, and a positive sleep timer
  is constrained to the range consistent with the remaining energy deficit.

These are initial balance values, not a final tuning decision.
