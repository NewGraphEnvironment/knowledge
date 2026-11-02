# Plan review — #120 (Plan agent, run in plan mode 2026-11-02 15:31–15:37 UTC)

Spawned unnamed on the draft plan; findings verified against the code before folding (the three load-bearing ones
reproduced: `R/tune_run.R:102-103` floors, `R/grade_record.R:104-105` refusal, `0320:114` one DEV dir). Every
finding below is in `task_plan.md`.

## Blockers

- **B1.** Four groups cannot be fitted: `knw_tune_run()` labels a key `too_few_groups` under `max(min_wsg, folds)`
  = 5 (`R/tune_run.R:102-103, 183-186`); `0320` passes neither. The smoke run iterates `names(prep)` (empty),
  no curve or grade is written, `0330` filters to `fitted` keys (`0330:139`) and `knw_compare_rules()` needs a
  real grade table (`R/compare_rules.R:117-118`). → `MIN_WSG=`/`FOLDS=` on `0320`, logged, in the summary,
  refused by promotion (Phase 2); every Phase 3 acceptance line names the floor.
- **B2.** Gating the settle log on its schema refuses the documented rename path: the published build ran
  `SCHEMA=fresh_default_20261017` against a `fresh_default` settle log (`20261027_evidence_build_ledger.csv`;
  `0320:95`). `run_uid` is the gate (`0310:116`). → `schema` is a record column, never a gate.
- **B3.** An `evidence_dir` column on the grade record breaks the 8 tracked records: `knw_grade_record_read()`
  errors on a missing extra column (`R/grade_record.R:104-105`), read by `test-vignette-data.R:122-129`,
  `R/archive.R:68`, `0336:56-58`. → `evidence_dir` on the summary only.

## Gaps

- **G1.** `access_check.csv` has no group column (`R/link_access_check.R:34-44`): `n_*` differ trivially across
  networks, only `km` compares, and nothing localises a difference. → `by_group =`.
- **G2.** Two DEV runs overwrite each other (`0320:114`). → `DEV_DIR=`.
- **G3.** `0300` waits 10 min × 3 on a static scratch schema (`0300:22-23, 86-87`). → `POLL_MIN=`. Check
  `log_recompute.date_end` on the proof schemas before relying on `0300` (checked: set on all four groups).
- **G4.** `0310`'s link floor is 0.66.0 (`0310:70`). → 0.78.1.
- **G5.** link's `log` is one row per pipeline call per group; "distinct non-null" would pass a schema where half
  the groups carry no token. → a mix of NULL and valued rows is refused. (The reviewer proposed restricting to
  `log_recompute`'s run_uid; m4's proof schemas show the build's `log` uid `415_default` differs from the
  recompute's `415_recompute_default`, so the read is over every row instead.) Consumers of `rec$tokens`:
  `0320:420-422` only; `0330:206` and `0336:64` read `run_uid`, `discharge_load`, `walk_md5`.

## Ordering

- O1: B1's fix before any Phase 3 `0320`/`0330`. O2: link 0.78.1 installed before `0310` (reads the installed
  `default` config, `0310:143`); `LINK_REPO` has `origin/main` fetched so `0320`'s `git show <sha>` works.
  O3: `EVIDENCE_DIR` on `0320`/`0330`/`segment_gradient_check.R` before Phase 3; `segment_gradient_check.R`
  also hard-codes its log name (`:31`), overwritten by a second run the same day.

## Assumptions

- A1: the ledger-finder design was heavier than needed; default-directory readers go through `knw_run_ledger()`
  (`0325:40`, `0330:133`, `0335:169`, `vignette_method.R:57`), so a `-<tag>` ledger name mirroring `_refused.csv`
  keeps them unchanged, no exported finder, keep the `evidence_dir` info row. `knw_tune_promote()` compares only
  its `fields` list (`R/tune_promote.R:154`), so a summary column is ignored there.
- A2: "full, parent gradient" picks equal "minimal" is a hypothesis: the parent is the largest-overlap minimal
  segment (`parent_bulk.csv.gz`, lower-case names), so a visit on a straddling full segment can read the other
  minimal segment's gradient. → count those visits.
- A3: `GRADIENT=parent_gradient` needs no package change (`tune_run.R:112, 121-123, 228`); only `0320:101-102`
  refuses it; `grad_parent/` is never promoted (`tune_promote.R:172-181, 250`).
- A4: walks are segment-independent (`R/link_walks.R:50-51`, `inst/sql/ch_dist_profile.sql:31-33`); identical
  `walks.csv` presupposes identical starts and one flow load.
- A5: `log.species` exists (link `lnk_log.R:349`); whether `lnk_config("default")` gives the minimal build's
  species range and pooling is unverified (both `extends: default`).

## Scope and acceptance

- Beyond the issue, dropped: the grade-record column, an exported ledger finder.
- Ac1: the mutation check holds only if the mock keys on table name for both queries. Ac2: "four smoke gates pass"
  is vacuous until B1 is resolved; the write-up names the floor.
