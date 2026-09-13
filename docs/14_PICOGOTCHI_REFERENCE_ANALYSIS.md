# PicoGotchi Reference Analysis

## Product Pivot

PicoGotchi is a virtual-pet game first. The pet's life, care and evolution are
the main game. Lines remains one optional activity behind the Game icon; it is
no longer the product identity or the primary progression system.

## Supplied Reference Set

The user supplied eight images on 2026-09-13. Two pairs are exact duplicates,
leaving six unique references:

- a V4.5 jobs chart;
- a large food catalogue;
- a character and item silhouette sheet;
- a broad monochrome character roster;
- a V5 family and training evolution chart;
- a simpler Gen 1 care-based growth chart.

The external images are analysis references only. They are not copied into the
open-source repository because their characters, names and artwork belong to
their respective owners.

## What We Take From Them

- Strong monochrome silhouettes that remain readable at very low resolution.
- Each growth stage visibly changes the creature, not only its face.
- Adult forms branch according to accumulated care rather than a single level.
- Food, training, health and play contribute differently to development.
- A large roster creates long-term discovery and replay value.
- Jobs can extend a completed adult life, but are not required for the first
  complete PicoGotchi loop.

## What We Do Not Copy

- Existing character sprites, names or exact silhouettes.
- Branded icons, interface layouts or job illustrations.
- Exact published evolution trees and hidden requirements.
- The V5 family system in the first version; it is too large for the current
  PICO-8 cartridge and would hide the core single-pet loop.

All PicoGotchi creatures, food icons, names and evolution rules must be
original. The references define density, readability and system depth only.

## Proposed Core Evolution

```text
egg -> baby -> child -> teen -> adult
                       |       |-- thriving form
                       |       |-- playful form
                       |       |-- disciplined form
                       |       |-- unusual form
                       |       `-- neglected form
                       `-- care history selects the branch
```

The first complete version should contain one Egg, one Baby, two Child forms,
three Teen forms and five Adult forms. This is enough to make care decisions
matter while remaining feasible in PICO-8.

## Evolution Inputs

- Care mistakes and unanswered Attention calls.
- Health and recovered illnesses.
- Discipline accuracy: correct calls versus unjust discipline.
- Happiness and voluntary play.
- Weight and feeding balance.
- Sleep quality and lights-off behaviour.

No single Lines score should determine evolution. Lines contributes only to
the general play and activity history.

## Food Scope

The food catalogue demonstrates variety, but the first PicoGotchi release
uses the two classic functional categories:

- Meal: fullness up, small weight gain.
- Snack: happiness up, larger weight gain.

More food sprites are a collection and animation expansion, not a prerequisite
for the core loop.

## PICO-8 Production Limits

- Active creature sprites remain pixel-perfect with integer rendering.
- Baby remains round and has no arms or legs.
- Later stages may gain limbs and distinct silhouettes.
- Only the active form needs full animation frames; discovered-species records
  can use compact portraits.
- Branch count must be validated against sprite, code-token and cartdata use
  before art production.

## Save Direction

The existing cart already persists slots 0 through 36. PicoGotchi should add a
versioned save schema for current life, generation count and discovered forms.
Changing the cartdata id without migration would hide existing saves, so the
rename requires an explicit one-time migration from `linesgotchi_v2`.

## Locked Lifecycle Decisions

- Two timing profiles: a normal multi-day life and an accelerated test mode.
- The normal profile reaches Baby after hatching, Child after one day, Teen
  after three days and Adult after approximately six real days.
- Time continues while the game is closed. On the next launch PicoGotchi
  simulates no more than 12 hours of missed time.
- Offline simulation may make needs critical, but it cannot directly kill the
  pet: health stops at 1 and a short active-care grace period starts on load.
- Death is permanent for the current pet. The life is added to history and the
  player begins a new Egg; generation count and discoveries remain saved.
- Exact evolution conditions stay hidden. Players discover them through
  repeated generations rather than reading numeric requirements.
- Accelerated mode reaches Adult after 60 minutes.
- The timing profile is selected for each new Egg and remains locked for that
  generation.
- The player names each pet manually.
- Names contain at most six characters. An on-screen keyboard is always
  available; physical keyboard input is an optional fast path.
- First-version creatures have no sex or breeding system. A new generation
  begins from a new Egg after the previous life ends.
- A deliberate Pause mode freezes age and all needs indefinitely. Paused time
  is marked in life history and never enters offline simulation.
- Adults age naturally. Good care produces an expected total lifespan of
  roughly 10 to 14 real days; poor care and illness can end it earlier.
- Every generation begins from the same Egg with no random or selected
  predisposition. Care history alone determines the evolution branch.
- Hall of Gotchi keeps the five most recent lives with name, species, age,
  timing profile and cause of death.
- Death first plays a short farewell scene and then opens a memorial screen
  with portrait, name, age and care result. A new Egg starts only after player
  confirmation.
- Pet condition is presented as hearts on separate status pages. Exact 0-100
  values remain internal and are not shown to the player.
- Each visible condition meter uses four hearts.
- The first release includes two mini-games: Lines and one short classic-style
  guessing or reaction game.
- The short game is a five-round left/right prediction game: the player guesses
  which direction the pet will turn.
- Sleep follows local time. The player chooses a convenient bedtime, while the
  required sleep duration depends on the current growth stage.
- An unresolved Attention call repeats its sound every five minutes while the
  indicator continues blinking. The global sound setting still mutes calls.
- Discipline is valid only for a false Attention call with no real unmet need.
  Unjust discipline counts against care quality.
- Illness requires between one and three medicine doses. Every dose gives
  readable feedback so the player knows whether treatment must continue.
- Up to three messes can remain on screen. Two uncleared messes can cause
  illness, and Toilet clears the current messes together.

## Recommended Implementation Order

1. Lock the PicoGotchi lifecycle and evolution thresholds.
2. Define the versioned save schema and migration.
3. Separate pet progression from Lines-specific records and rewards.
4. Implement deterministic evolution tests before drawing the full roster.
5. Produce original silhouettes and animation frames for approved branches.
6. Add jobs and a larger food catalogue only after one full generation works.
