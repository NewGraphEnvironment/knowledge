## Outcome

Added `knw_tune_anchor()`, which sets each key's published pick from link's `default` and from its flow version (#80)
beside the rule the data score best: how far each sits behind it (deviance and SE) and how many parts (size test,
gradient, exception) separate them. It also measures each pick against the best rule a pick may be (in the region and
clear of the 200 m exception floor), because a best whose exception is under the floor can never be picked and part
of its distance is the floor's, not the start's. `scripts/0320` now writes these columns into every summary and
`pick_report.csv`, checked before a key's tables are written; `data-raw/tune_anchor_check.R` reads saved tables. The
verdict, both readings and grayling rearing's "before" for #140 are in `research/baseline_anchoring.md`. What was
learned: the first definition of the allowed best was a proxy twice over (it ignored the region, then its flag ignored
convergence); three review rounds each found the next instance, and the loop ended on an enumeration of every place
that defines or describes it.

## Measurement

- Published tables (full network, #92): 4 of 8 picks are the best-scoring rule; against the best a pick may be, the
  start moves grayling rearing 2 parts (0.55 SE behind), steelhead rearing 1 (0.40) and coho rearing 1 (0.26). Bull
  trout rearing's pick is the best a pick may be (its best carries a 100 m exception). The two starts agree on 6 of 8.
- Minimal-network candidate `20261103_0838` (#120): 3 of 7 at the best; the start moves bull trout rearing 2 parts
  (0.89 SE), grayling rearing 2 (0.85), steelhead rearing 1 (0.62), coho rearing 1 (0.38). The starts agree on 4 of 7.
- Wrong turn kept: the first logs ranked steelhead (published) as moving 3 parts, then 2; the floor reading (plan
  review) and the region (review round 1) each moved it, to 1 part. Bull trout rearing (published) went from 1 part to 0
  once the floor was read.
- `DEV=1 0320` on the minimal evidence with cached scores (3.9 min, no database): summaries and `pick_report.csv` equal
  the anchor on the run's own tables for all 8 keys.
- Full suite 1,900 passed, 1 error, pre-existing on `origin/main` (live placement test, #142).

## Evidence

`scripts/logs/habitat/20261104_tune_anchor_check-*`

Closed by: PR (this branch, `141-anchoring-check-report-the-pick-from-eac`)
