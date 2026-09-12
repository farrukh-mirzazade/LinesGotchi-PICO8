# Game Loop

## Intended Loop

1. Egg appears.
2. Pet is born.
3. Player cares for pet.
4. Player chooses `PLAY`.
5. Lines game starts.
6. Lines result affects pet state.
7. Pet grows and eventually evolves.
8. Pet history is saved locally.
9. New generation begins.

## Implemented Loop

1. The LCD shows the pet and ten icons in two rows of five.
2. The player responds to hunger, low happiness, sleep, mess, illness, and
   false attention calls.
3. Food, light, medicine, toilet and discipline resolve different needs.
4. Game starts Lines; its result changes happiness, hunger and weight.
5. Unanswered needs become care mistakes and reduce health.
6. Virtual age advances with care time; the pet grows through stages.
7. If health reaches zero, the pet dies and `O` starts a new egg.
