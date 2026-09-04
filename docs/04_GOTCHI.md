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
- On the Pet screen, `X` feeds the pet.
- Home is navigation only and never changes pet stats.
- Feeding consumes one tomato, lowers hunger, and raises weight.
- Feeding does not increase happiness.
- Feeding is blocked while the pet is eating or already full.
- Toilet and sleep rewards cannot be repeated without a new care need.
- Quitting Lines does not grant records, end-of-game rewards, EXP, or age.
