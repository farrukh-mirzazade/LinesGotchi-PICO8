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

The current cart derives growth stage from virtual age:

- Baby: age below 1.
- Child: age 1+.
- Teen: age 3+.
- Adult: age 6+.

One age day is earned after ten active care ticks. Age, health, discipline,
care mistakes, mess, illness, light state, medicine doses and care time are
stored in cartdata. Adult species branching from care quality is still pending.

Healthy weight is 6-16. Weight outside that range gradually lowers the
maximum sustainable health; returning to the healthy range restores health
over subsequent care ticks.
