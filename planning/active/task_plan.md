# Task: Iterate on scores privately; promote a run to the tables and articles on the operator's word (#111)

Every retune rewrites the tracked tables (`data/tune/*.csv`, `data/compare/*.csv`, `data/thresholds.csv`), and
`tests/testthat/test-vignette-data.R` then fails until both articles' bundles are rebuilt and the prose that quotes them
is checked again. #92's chain was about 10 h of runs (scoring 43 min, grading about 87, comparison 269, GeoPackages 197)
and then five review rounds on the article prose, though the scoring alone answered which rule wins.

Retunes are now continuous: link's segmentation (`NewGraphEnvironment/link#326`, `NewGraphEnvironment/link#396`),
placement and flow changes are queued. So every iteration pays the cost of publishing, and the published state follows
whichever run happened last: #92's run was made on link 0.66.0's segments, which both link changes replace.

## What this proposes

Today any run of `0320`/`0330` overwrites the tracked tables, the tests then fail until both article bundles are rebuilt,
and the prose is reviewed again. So every check of "did the upstream change move the picks" costs a ~10 h chain plus
review rounds.

After this branch:

- **The everyday loop is `DEV=1 0320`**: minutes, no database (CH alone took 1.7 min on 8 workers; all keys about 10),
  ending in a **pick report** per key, new pick against the published one. It writes only to ignored
  `data/tune/dev/`, log included. Nothing tracked moves, no test fails, no article work.
- **A full run (grades, comparison) writes to an ignored candidate directory** and can be done one species at a time
  (`SPECIES=CH` grades and compares CH alone: CH rearing's comparison took 44 min of #92's 466). Still nothing tracked.
- **Promotion is the only step that touches tracked tables and articles**, on your word, **by key or whole run**, and
  it is the only time the bundles are rebuilt.

What it does not do: make a full run itself faster. It takes full runs out of the iteration loop.

## Decided at the gate

Al, 2026-10-28, at the plan gate:

- Candidate runs are named by a UTC stamp at launch (`YYYYMMDD_HHMM`), named on the log's first line; `RUN=<name>`
  reuses a directory so a failed or partial run resumes on its cached scores and grades.
- Promotion may go **by key** (Al asked for flexibility over provenance). The promote step refuses, before copying, a
  mix that `0325` and the bundle scripts would refuse anyway (promoted and kept keys on different evidence or link
  run), and says which keys would have to come along.
- Verification stays tight: no multi-hour runs. One `DEV=1 0320` here on #92's evidence (md5s match), fixture tests,
  and a copy-only promotion round trip of the current tracked run.

## Phase 1: Pick report in `DEV=1 0320`

- [ ] `R/tune_pick_report.R`: `knw_tune_pick_report(rules, published)`: per key, the new recommended rule and its
  `grad_max`, the published rule and its `grad_max`, whether the published rule is in the new one-SE region (`NA`
  when it is not in the new grid), its `ddev_best` and `se_diff` in the new run beside the published table's, and
  `same_pick`. Tests on fixture tables (`tests/testthat/test-tune_pick_report.R`), including a published rule
  absent from the grid and a key with no published table.
- [ ] `0320`: under `DEV=1`, write `data/tune/dev/pick_report.csv` and a block in the log; the published side is the
  tracked `data/tune/<key>_tune.csv` (already read as `previous`).
- [ ] `0320`: the `DEV=1` log goes to `data/tune/dev/<date>_tune_run-dev….txt`, not `scripts/logs/habitat/`, so the
  tree stays clean.

## Phase 2: Full runs write to candidates

- [ ] `0320` without `DEV`: `dir_out` is `data/tune/candidate/<run>/` (`RUN=` or the UTC stamp), log
  `<run>/<run>_tune_run….txt`; `GRADIENT=fwa_gradient` under `<run>/grad_fwa/`. Nothing written to `data/tune/`.
  The previous pick still comes from tracked `data/tune/`.
- [ ] `.gitignore`: `data/tune/candidate/`, `data/compare/candidate/`.
- [ ] `0330`: `TUNE_DIR=` is required and must be under `data/tune/candidate/`; reads curves and grades from it,
  writes `data/compare/candidate/<basename>/` (its `gpkg/`, `maps/`, `fig/` and log inside it; `research/fig/` only on
  promotion). Shared caches (`data/compare/catalog/`) stay where they are.
- [ ] Test that a candidate subdirectory is never read by `knw_thresholds_table()` (fixture with a summary under
  `candidate/x/`), pinning the non-recursive listing `0325` relies on.

## Phase 3: Promote

- [ ] `R/tune_promote.R`: `knw_tune_promote(run_tune, run_compare, keys, tune_dir, compare_dir, log_dir)` copies each
  key's files (tracked and ignored: tables, grades, curve.rds, score.rds, segments.rds), the run's logs into
  `scripts/logs/habitat/`, figures into `research/fig/`, and recomposes `compare.csv`/`change.csv`/`checks.csv` from
  the tracked per-key tables. Refuses, before any copy: a key missing its compare half, a tune/compare pair on
  different rules or evidence, and a by-key promotion whose keys' `evidence_md5`/`run_uid` differ from the kept keys'.
  Returns the files written. Fixture tests for each refusal and for "copies exactly these files".
- [ ] `scripts/0335-promote.R`: `RUN=<run> [SPECIES=…]`, calls `knw_tune_promote()`, then `0325` (no `PUBLISH`),
  `data-raw/vignette_chinook.R` (when CH rearing was promoted or any `_tune.csv` changed) and
  `data-raw/vignette_method.R` last; `BUNDLES=FALSE` copies only. Needs the database (the bundle scripts read it).

## Phase 4: Docs

- [ ] `CLAUDE.md`: bundles rerun after a promotion, not after any `0320`/`0325`/`0330` rerun; the loop is `DEV=1 0320`
  and its pick report; a full run and a promotion each start on Al's word. Layout lines for `data/tune/candidate/`,
  `data/compare/candidate/`, `data/tune/dev/pick_report.csv`.
- [ ] `scripts/README.md` run order: `0320` (candidate), `0330 TUNE_DIR=`, `0335` promote; header comments of
  `0320`, `0330`.

## Validation


- [ ] Tests pass (`devtools::test()`)
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- Pick report: `DEV=1 Rscript scripts/0320-tune-run.R` here on #92's evidence; every key's pick should equal the
  published one (same evidence, same code), and `git status --porcelain` is empty after it.
- Candidate paths and `0330 TUNE_DIR`: fixture tests and a dry check of the paths each resolves; no full run.
- Promotion: build `data/tune/candidate/roundtrip/` from a copy of the current tracked run (tables, ignored grades,
  curves, segments, the 20261027 logs), run `RUN=roundtrip BUNDLES=FALSE 0335`; `git status` must be empty (proves
  the copy and the recomposed combined tables are exact), then delete the round-trip candidate.
- Not proved on this branch: `0335`'s chaining into the bundle scripts (needs a real promotion).
