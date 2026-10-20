# Code-check round 3 (#65): staged diff vs HEAD (`diff3.patch`)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of all 14 H3s under `## Mechanisms` (tables and evidence blocks skipped); index for the rest. 0 standalone sections read beyond the index (none names a tool or shape this diff uses).
- `code-check-r.md`: Read-back shape must match write-back shape; Tests that silently do not run; testthat counts an uncaught error under `error`; A `skip_if_not()` skips only its own block; `expect_gt()` takes no `info`; `$` on a list partial-matches; `paste()` with a zero-length argument; `identical()` on two reader results; Under `R CMD check`, tests run against the installed package; `match()` treats NA as a matchable value; `tolerance` is relative; `data.frame()` recycles a scalar; Postgres row order; A `pkg::` call in a test; A `function(...)` mock hides arguments; `ifelse()` with an all-NA test. 16 read; the other ~95 not read (index only).
- `code-check-spatial.md`: FWA `upstream_route_measure` misses the next segment's start; FWA main flow is not edge type 1000 alone; A Freshwater Atlas main stem's downstream end. 3 read; the rest index only.
- `code-check-shell.md`: index only (the diff has no shell).

## Verdict

Clean. No new defect in the diff. The checks run, and the mechanism the brief asked to name, follow.

## What was run

- `tests/testthat/test-grade_species.R` in a temp copy (`NOT_CRAN=true`, `load_all()`): 3 blocks, 18 expectations, 0 failed, 0 error, 0 skipped.
- `devtools::document()` in the copy: `man/` and `NAMESPACE` unchanged against the staged Rd files.
- `tools:::.check_packages_used_in_tests()`: empty (duckdb, DBI, tibble, mgcv, testthat are declared).
- Every saved `data/tune/*_curve.rds` with a curve carries `q` (10 for the six picks with no exception, 3 for CH rear and BT spawn, equal to their `exc_q`), so `q_walk` is never `NULL` on today's curves, and for 0320's picks the walked river is the curve's.
- `inst/sql/ch_dist_profile.sql` emits exactly `found`, `none`, `no_parent`, `too_many_hops`, so `walk_found + walk_none + walk_other` covers every walked segment.
- The match key `paste(blue_line_key, downstream_route_measure)`: both sides are doubles (`knw_link_segments()` and `knw_link_walks()` both `as.numeric()` the key; the measure reaches the walk table from `starts` unchanged through `cbind`), so the two `paste()` spellings agree.

## The mechanism behind round 1's defect

One column, `dist_m`, is produced by one predicate (the walk set in `knw_grade_species()`) and read by several consumers, each with its own predicate for which segments it reads the column on. Nothing ties them together; correctness rests on the walk set being a superset of every consumer's read set on every axis: accessibility, gradient (its NA and its range), size (its NA and its zero), edge type or branch, and the river `q` the distance is to. Round 1's defect was the size axis: the producer wrote `size > 0` (`knw_grade()`'s gradable test, where NA drops) while the comparison's SQL reads a missing size through `coalesce(..., FALSE)` as failing the size test, which the exception then admits. The two NA conventions disagreed, and each list was right for its own consumer.

## Every place the mechanism reaches, checked

| consumer of `dist_m` / `knw_dist` | segments it reads it on | inside the new walk set? |
|---|---|---|
| `knw_grade()` (`R/grade.R`) | size > 0 and gradient present; `rate` on every such segment, `grade` kept only where accessible | Yes for every accessible one. Inaccessible segments get a `rate` at the cap (`no_walk`), but their `grade` is set NA and `rate` is not published (0325 selects neither `rate` nor `dist_m`). |
| `knw_compare_rules()` tuned predicate (`R/compare_rules.R:128-131`) | accessible (`h.accessible AND access > 0`), stream branch, `gradient BETWEEN 0 AND grad_max`, size test fails (NA included) | Yes: `knw_link_segments()`'s `accessible` is the same gate (`accessible_stored %in% TRUE & access > 0`); `gradient` is the same `streams` column, and `grad_ok` needs it non-NA; no size or edge filter remains. Link's `rules.yaml` stream edge types for CH and BT are 1000/1100/2000/2300, the old default, so no stream-branch segment was outside the old set either. |
| change reasons, gained "exception" arm (L287) | stream, `g_tun`, size fails | Yes (was walked before too, so unchanged). |
| change reasons, lost "no exception" arm (L290) | stream, `w_ok`, `g_def`, size fails, reads `!ex_ok`, including `g_tun` FALSE | Walked now, not before, so a segment between a lower tuned maximum and default's can move to "gradient: tuned maximum lower". Already recorded in `findings.md` (Reviews); no current key has both a lower tuned maximum and an exception (CO and WCT have no exception; CH 0.09 and BT spawning 0.0549 are not below default), so no table moves today. |
| `0322` "beside CH_rear_v1" reasons (`exc_ok`, L360-366) | band or below-band stream segments inside the candidate's maximum, size fails | Yes; the candidate's old walk also covered them, so the reasons cannot move. |
| the river `q` | comparison reads `exc_d` against `tuned$exc_q`; grade reads the curve's `q` | `q_walk` is the pick's `exc_q` (the comparison's river), else `curve$q`. For 0320 picks the two agree (checked on every saved curve). For a 0322 candidate whose `exc_q` differs from the curve's, the grade reads another river: documented and accepted. 0330 reads `data/tune/<key>_grades.csv` without checking its `rule`; 0320 regrades whenever the rule differs, so the file is the 0330 job's pick. |
| `knw_tune_curve()` fit population | visits, from 0310's walks | Not this producer. Every fitted curve has `no_walk_at_cap = 0`, and its non-`found` statuses all read the cap, as the grade's do. |
| vignette examples, case filters (`chinook_rearing.Rmd:405-412`) | stream edges outside waterbodies, `mad < size_min` | For CH the tuned maximum (0.09) is above default's (0.0549), so every "Lost"/"Gained" candidate was walked before; the cases cannot change. |
| vignette examples table (`chinook_rearing.Rmd:446-458`) | `is.na(dist_m)` read as "not needed" when size passes; caption "measured only where the exception could apply" | Becomes wrong after the regrade (the kept-by-both row will show a distance). Already a Phase 3 task in `task_plan.md`, so not a new finding. |
| `counts` and 0320/0322 log lines | renamed `found` to `walk_found` | Nothing reads `found=` or `walked=` (grep over `R/`, `scripts/`, `data-raw/`, `vignettes/`, `tests/`); the vignette reads `segments=`, `accessible=`, `graded=`, `no_size=`, all unchanged. |
| `0325` publish | reads grades with `guess_max = 1e5` | Selects neither `dist_m` nor `dist_status`, so a mixed old/new set of grade files cannot shift a published column. |

## Noted, not a finding

The walk set grows from about 373 k (CH) and 682 k (BT spawning) starts to about 9.3 M across eight keys. `knw_link_walks()` has no retry and `parLapply()` raises on the first failed query, so one transient database error discards that key's walks after up to a few hours; 0320 writes each key's grades as it finishes, so a rerun loses only the key in flight. This is pre-existing in `knw_link_walks()`, the plan already sets `PGCONNECT_TIMEOUT`, and nothing is broken, so it is for the run log rather than the diff.
