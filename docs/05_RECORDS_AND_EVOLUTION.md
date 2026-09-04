# Records And Evolution

## Local Records

PICO-8 should use local persistent storage for records.

Candidate values:

- High score.
- Best line.
- Total lines.
- Games played.
- Longest life.
- Generations.
- Species discovered.

## Hall Of Gotchi

Save compact historical records:

- Species id.
- Age.
- Best score during life.
- Optional name.
- Best-life flag.

## Evolution Inputs

Evolution should eventually consider:

- Care mistakes.
- Games played.
- Best score.
- Total lines.
- Happiness.
- Health.
- Weight.
- Age.

## Implemented Growth Foundation

The current cart derives a growth stage from age or level:

- Baby: age below 3 and level below 4.
- Child: age 3+ or level 4+.
- Teen: age 7+ or level 7+.
- Adult: age 14+ or level 10+.

One age day is earned after three completed Lines sessions. Age, health,
discipline, level progress, settings, and care state are stored in cartdata.

Healthy weight is 6-16. Weight outside that range gradually lowers the
maximum sustainable health; returning to the healthy range restores health
over subsequent care ticks.
