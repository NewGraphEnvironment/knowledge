# #28: habitat weights, not only cutoffs (BT rearing)

## Outcome

FDIS electrofishing site visits were placed on link's own segments (`scripts/0290`). An effort-corrected use curve was fitted by gradient class for three responses: BT caught, any fish caught, and BT given fish (`scripts/0291`). That was turned into a candidate BT rearing weight per gradient class, labelled expected use (`scripts/0292`, `data/habitat_weight_bt_rear.csv`). The position per driver is `research/habitat_weights.md`.

BT use falls with gradient, but the fall sits in whether visits catch fish at all, not in BT's share among fish. A single elevation term does not earn a place: elevation acts with opposite signs in held-out and calibration WSGs. Eight literature rows were added, and `elevation` joined the evidence vocabulary. The link issue is drafted in `link-issue-draft.md` and not filed.

The review record is the larger lesson. Review rounds repeatedly found defects inside the previous round's fixes, and two of those mechanisms recurred:
- a quantity defined from the response read as evidence about it (the `access_bt` code 2, flagged circular by the plan review and then used anyway);
- notes written from memory of a read rather than from the page.

Each loop was ended by enumerating the candidate set mechanically, never by a quiet round.

## Measurement

All from `data/bt_rear_use_curve.csv` and the 0291 log; weights are relative to count-weighted core rearing.

- **Population:**
  - 17,606 visits kept of 53,018 by the 0290 ledger, every drop counted;
  - 14,463 on stream or river edges with 10–10,000 m² fished;
  - the BT-caught fit uses 13,161 visits in 53 WSGs.
- **Steep classes against core** (10.49–12.49 / 12.49–13.49 / 13.49–14.49 / > 14.49 %):

  | response | 10.49–12.49 | 12.49–13.49 | 13.49–14.49 | > 14.49 |
  |---|---|---|---|---|
  | BT caught | 0.64 | 0.50 | 0.27 (underpowered) | 0.56 |
  | any fish | 0.38 | 0.34 | 0.24 | 0.29 |
  | BT given fish | 1.27 | 1.27 | 0.88 | 1.20 |

  Every BT-given-fish interval includes 1.
- **Candidate weight:** 0.95 / 0.95 / 0.89 / 0.74 on core, then 0.64 / 0.50 / 0.50 / 0.50. This changed the issue's framing from "habitat quality" to "expected use".
- **Elevation:**
  - held-out log-likelihood is worse by 82.4 with the elevation third;
  - held-out core detection falls by elevation third (0.40 / 0.28 / 0.11, even sampling);
  - calibration rises (0.10 / 0.17 / 0.16).

  This reversed a first-draft claim that step 5's taper was sampling density.
- **Effort exponent:** detection scales as area^0.07–0.19, not area^1. This drove spec Change 1, after the offset fits diverged.
- **Wrong turns kept**, in `findings.md` and the research file's dead ends:
  - the 5 m placement nudge (817 visits misplaced, 171 changing band);
  - the forked bootstrap that segfaulted under Accelerate BLAS;
  - "sampling density";
  - "as good as core";
  - the circular access-code argument.
- **Reproducibility:** 0291 re-run reproduces the curve CSV byte for byte (runs 6, 7, 8, 9).

## Evidence

- `scripts/logs/habitat/20261002_bt_use_*`: the 0290 ledger and the 0291 log.
- `scripts/logs/habitat/20261002_literature_verify*`: the 0280 gate.
- `review-*.md` in this directory: plan review plus code-check rounds per phase.

Research: `research/habitat_weights.md`.

Closed by: PR (this branch, `28-habitat-weights-bt-use`)
