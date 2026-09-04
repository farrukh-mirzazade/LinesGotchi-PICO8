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
- Toilet and sleep rewards cannot be repeated without a new care need.
- Quitting Lines does not grant records, end-of-game rewards, EXP, or age.
