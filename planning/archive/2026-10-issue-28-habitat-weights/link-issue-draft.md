# Draft — link issue (NOT FILED; for review)

link is PUBLIC: aggregates only, no project or client identifiers.

**Title:** Report use-weighted BT rearing km beside cutoff km, with weights as bundle data

**Body:**

**If we do it:**
- Every BT rollup and per-crossing aggregation gets a second number beside the cutoff km: km weighted by
  the expected use of each gradient class.
- Under option A below, rearing stream near the cutoff (8–10.49 %) counts at 0.74, and stream a looser
  cutoff admits counts at 0.5–0.64 rather than 1. A cutoff change then moves the weighted figure less than
  the cutoff figure.
- Under option B, the weighted figure no longer depends on the cutoff.

**If we never do:** the cutoff stays the only answer. It counts 12 % stream as rearing or not, depending on
a line no fish sees.

## Problem

BT rearing is on/off at `rear_gradient_max`. link#284 step 5 showed observations per km taper across that
line rather than stop.

An effort-corrected analysis of provincial electrofishing site visits, placed on link's own segments,
gives per-class weights. Use is relative to core rearing (`default`), on BT-accessible stream:

| segment gradient | rearing under `default` | weight |
|---|---|---:|
| 0–2 % | yes | 0.95 |
| 2–5 % | yes | 0.95 |
| 5–8 % | yes | 0.89 |
| 8–10.49 % | yes | 0.74 |
| 10.49–12.49 % | no | 0.64 |
| 12.49–13.49 % | no | 0.50 |
| 13.49–14.49 % | no | 0.50 |
| > 14.49 % | no | 0.50 |

The weights come from 13,161 visits in 53 WSGs (those with BT both caught and not caught). They are adjusted for fished area, data set, era
and WSG, then capped at 1 and made non-increasing.

**What the weight is:** expected BT use per visit.
- Among visits that caught any fish, BT's share does not fall on the steep classes.
- What falls with gradient is the share of visits catching fish at all.
- So the weight should be labelled **expected use**, not habitat quality. It folds in where fish and BT
  are present, which an upper-fish-limit model would separate out.

## Proposed solution

1. **Bundle data.** Add `habitat_weights.csv` to the config bundle, beside
   `parameters_habitat_thresholds.csv`:
   - columns `species_code, life_stage, gradient_min, gradient_max, weight, source`;
   - `default` ships the table above for BT rearing, with a public-safe `source` string;
   - no row for a species means no weighting.
2. **Rollups.** Add `rearing_km_weighted` beside `rearing_km`: the sum of segment length × weight.
3. **Per crossing.** Add the same weighted figure in the per-crossing aggregation.
4. **Validate.** Weights must lie in [0, 1], be non-increasing in gradient, and the classes must not
   overlap.

## Decision needed before building

**Which segments carry a weight?**
- **(A, recommended) Rearing-flagged segments only.** Weighted km ≤ cutoff km, and the cutoff still
  decides what counts. The weights above 10.49 % then matter only under `default_tuned` or a looser
  cutoff.
- **(B) All BT-accessible stream up to an outer limit** (e.g. 0.1449 or 0.15). The weight replaces the
  cutoff. Steep stream counts at its weight (0.5–0.64) whether or not a cutoff admits it, and the spawning-cluster
  rule no longer gates rearing.

(B) is the bigger change and needs its own validation against step 5's held-out WSGs.

## Not in scope

- A width or MAD term: segment width is null on about 13 % of visits, MAD on about 25 %.
- Separating where fish occur at all from BT's share among them, for example with an upper-fish-limit
  model. The any-fish decline suggests it matters; this analysis does not locate the limit.
- Other species.

Relates to #284
