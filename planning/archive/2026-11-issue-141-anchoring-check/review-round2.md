# Code review, round 2 (#141)

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (tables skipped). Of the rest, none of the stand-alone,
  Security or Spreadsheets/PDFs headings names a tool or shape this diff uses; 28 not read.
- code-check-r.md: read in full the sections "`$` on a list partial-matches, so a longer sibling key answers for a
  missing one"; "`match()` treats NA as a matchable VALUE, so two unknowns join to each other"; "`system2(stdout = TRUE)`
  warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires"; "Inside a dplyr verb, a
  column named like a local variable wins"; "`identical()` on two reader results tests the reader, not the file"; "A
  `data-raw/` script must load the source tree, not the installed package"; "`data.frame()` recycles a scalar against a
  zero-length column"; "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests"; "A `function(...)`
  mock hides arguments the real callee no longer accepts". The other ~108 headings name tools or shapes the diff does
  not use; not read.
- code-check-shell.md, code-check-spatial.md: indexes read; no heading names a tool or shape in this diff (no shell, no
  spatial code); no section read.

## Findings

- **[severity: fragile]** R/tune_anchor.R:21-26, 86-88, 104 (`best_floor_ok`); data-raw/tune_anchor_check.R:75-76;
  research/baseline_anchoring.md, "What was asked", last sentence of the `d_floor` paragraph; scripts/0320-tune-run.R
  header (#141 bullet) — `best_floor_ok` is documented, logged and published as "the best carries an exception under
  d_floor", but it is FALSE whenever no best-tied rule is in the **allowed** set, and `allowed` requires `in_region`,
  which is `s0$region & conv` (R/tune_score.R:146). The best is `.tune_sel()`'s `which.min(tot)` over every pattern,
  converged or not (R/tune_score.R:447-452; a non-converged pattern still scores a finite deviance, `.tune_score_one()`
  returns `dev` with `ok = FALSE`). So on a table whose best pattern did not converge, the best is outside the region
  with or without an exception, `best_floor_ok` is FALSE, `tune_anchor_check.R` prints the key under "Keys whose best
  carries an exception under d_floor, which no pick may", and the research file's general claim "It is the best itself
  wherever the best's exception is 200 m or more, or it has none" is false for it. Reproduced in a temp copy: a
  two-rule table whose best (`ddev_best` 0, no exception) has `in_region = FALSE` returns `best_floor_ok = FALSE`,
  `rule_best_allowed` the other rule. No number published today is wrong: all 15 tables read have `converged` TRUE on
  every rule (measured over `data/tune/*_tune.csv` and `data/tune/candidate/20261103_0838/*_tune.csv`), and every best
  is in its region. It matters the first time a best fails to converge: the floor is then credited with a gap that is
  convergence's, in the log line, the 0320 block and the doc. This is the same mechanism as round 1's defect: a set
  named for one property (the floor) defined by a broader predicate (`.tune_pick()`'s `rr`, which carries convergence
  as well as the region). Either name and describe it as "the best is not a rule a pick may be" (floor or convergence),
  or split the reason by reading `converged`.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A fixture that cannot reach the failure mode"

No other issue found. Every number and claim in `research/baseline_anchoring.md` was re-derived independently from the
tune tables (not through `knw_tune_anchor()` or the logs): the eight published and seven minimal picks, their deviances
and SEs, the bests and tie counts ("2 to 4 rules on six of the fifteen tables"), the two 100 m bests, steelhead's best
allowed rule at 3.4546 with two better floor-clear rules outside the region (both converged), bull trout's 0.5983 and
0.7256, the parts, the starts' agreements (6 of 8; disagreements on 3 of 7), grayling's `default` (19.3/6.7 and
14.4/11.8), the review order's parts and SE ratios, "furthest of any from its best in deviance" (65.3) and "moves most
with the build" (BT rearing 0 to 2 parts, every other key unchanged). The log CSVs' `tune_md5` match the tables on disk,
and the code they were run at (22b8d88) is the code at HEAD for `R/` and `data-raw/`. Recomputing `.tune_pick()` at
d_floor 200 from each table's `in_region`, `departures` and `ddev_best` reproduces every table's `recommended` rule, so
the data-raw script's default floor is the one the tables were scored at. The grayling pointer's "since #92" is right:
`data/tune/GR_rear_summary.csv` names `width>=2|g<=0.0549|none` from 5500b94 (#92 phase 3) and
`width>=1.5|g<=0.0349|none` before. `test-tune_anchor.R` passes (55 expectations, 0 failed, no error) in a temp copy.

## Enumeration

Each set or quantity the diff defines, against its source of truth.

| definition (where) | source of truth | matches |
|---|---|---|
| the pick read = `recommended` (tune_anchor.R:71) | `.tune_pick()`'s `recommended` (after the floor), R/tune_score.R:461, written at :152 | yes |
| the flow pick = `recommended_flow` (:77) | `.tune_pick(dep = departures_flow)`'s `recommended`, :154 | yes |
| flow start = `departures_flow` present and not all NA (:74) | the same test, R/tune_score.R:130; `knw_tune_repick()` R/tune_repick.R:45 | yes |
| best = rules at `ddev_best == 0` (:81) | `s0$tot[col] - s0$tot[s0$best]`, `.tune_sel()`'s `which.min(tot)` over all patterns | yes (rules of the best pattern, plus any pattern tied exactly; a saved table's 6-dp rounding could add a pattern within 5e-7, not met in any table) |
| `rule_best` = first such rule in grid order (:102) | 0320's summary `filter(ddev_best == 0) \|> slice(1)` | yes, by the same predicate (so 0320's guard on this name cannot fire: both sides read one column with one predicate) |
| allowed = `in_region` and (`exc_d` NA or >= `d_floor`) (:86) | `.tune_pick()`'s `ok_d` = `rr` (region and converged) with that floor test; `in_region` = region and converged | yes |
| best allowed = lowest `ddev_best` in allowed, ties kept (:88) | "the best-scoring rule a pick may be": every allowed rule is the recommended rule from a start at itself | yes |
| `best_floor_ok` = best allowed at `ddev_best` 0 (:104) | described as "the best's exception is clear of the floor" | **no**: also FALSE when the best did not converge (finding above) |
| parts / departures (`.knw_rule_parts`, :133-139) | `knw_tune_grid()`'s departures: size (var or floor), gradient, exception present | yes from either start (pinned by the test against `knw_tune_grid()`); between two exception-bearing rules it extends the grid's count (q or d differing is one part), as documented |
| `rec_moved`, `flow_moved` (fewest parts to any best-tied rule, first such naming the parts) | the best set above | yes |
| `rec_moved_allowed`, `flow_moved_allowed` | the best-allowed set above | yes |
| `starts_apart` (parts between the two picks) | the two picks above | yes |
| `rec_is_best`, `flow_is_best` = pick's `ddev_best == 0` | the best set | yes (equivalent to `*_moved == 0`) |
| `starts_agree` = same row | "the two starts pick the same rule" | yes (grid rules are unique) |
| `d_floor` in 0320 = the score's `spec$d_floor`, else `knw_tune_run()`'s default | the floor `.tune_pick()` used; `knw_tune_run()` rescores a cache whose spec's `d_floor` differs | yes |
| `d_floor` in data-raw = `knw_tune_score()`'s default (200) | the tables do not record it | yes for every table read (recomputed recommended rules all match at 200) |
| steering order (data-raw): parts from best allowed desc, then `ddev/se` desc, then starts disagree first | research "Where the baseline review starts" | yes; `ddev/se` is distance to the region's edge, as the file says |
| "always under one SE, by construction" (research) | region is `ddev <= se` | yes up to the boundary (at most one) |
| research counts and claims | the 15 tune tables | yes, every one re-derived (above) |
