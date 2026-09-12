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

- Left/Right cycles the seven original-style care icons. `O` opens or confirms
  an action; `X` cancels a submenu and never applies care by itself.
- Meal lowers hunger by 25 and adds one weight. Snack raises happiness by 15
  and adds two weight. Feeding is blocked while eating or sleeping.
- Light On/Off is controlled manually. The pet falls asleep automatically at
  low energy; leaving the light on while it sleeps creates an attention need.
- The pet creates mess periodically. Two uncleared messes cause illness.
- Medicine takes one to three doses. Toilet clears all current mess.
- A false attention call must be answered with Discipline. Correct discipline
  raises its meter; unjust discipline lowers happiness.
- Hunger, unhappiness, sickness, mess, a false call, or light during sleep can
  activate the blinking Attention indicator. Three unresolved care ticks add a
  care mistake and reduce health.
- Feeding is blocked while eating or sleeping. A full pet refuses another meal.
- Sleep starts automatically and gradually restores energy. The light turns on
  automatically when the pet wakes.
- Toilet and medicine rewards cannot be repeated without a matching need.
- Quitting Lines does not grant records, end-of-game rewards, EXP, or age.
- Hold `X` and press Left on the main LCD to toggle sound, matching the
  original toy's C+A shortcut with the LinesGotchi button mapping.
- After death, `O` creates an egg; it hatches after a short protected delay.

## Energy And Sleep

- Energy ranges from 0 to 100. New profiles and pre-energy saves start at 80.
- Awake time costs 2 energy per 900 updates (30 seconds at 30fps).
- Each successful Lines move costs 1 energy. Cursor movement and failed moves
  do not invoke that cost. Energy cannot fall below zero.
- New Lines sessions cannot start at zero energy or while sleeping. A session
  already in progress is not forcibly interrupted when energy reaches zero.
- Sleep restores 2 energy every 30 updates, stopping automatically at 100.
  From zero it takes 50 seconds; from 80 it takes 10 seconds.
- Feeding and starting Lines are blocked during sleep. Leaving the light on
  activates Attention; the light turns on automatically after waking.
- Cartdata slots 21/22 store energy and remaining sleep frames; later schema
  slots preserve illness, mess, discipline calls, death, egg and species state.
- Sleep resumes from its saved phase after reloading. Closed/paused time is not
  simulated: recovery and energy drain advance only on game updates.
- Invalid saved energy/duration values are bounded, and a positive sleep timer
  is constrained to the range consistent with the remaining energy deficit.

The main care tick is 900 updates, about 30 seconds at 30fps. One virtual age
day is ten care ticks, about five active minutes. These compressed timings make
the full loop testable in PICO-8 and remain balance values for later tuning.
