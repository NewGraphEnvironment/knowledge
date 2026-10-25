# Code-check round 2: branch `73-rebuild-the-evidence-and-retune-on-the-r` at 87266b2 against 8af0a4e0

Written 2026-10-25 (UTC). Read-only review of the working tree at 87266b2; nothing in the tree was modified except
this file. Every probe ran against copies under the session scratchpad (`pkgcopy/`, `pkgfix/`, `pkgmut/`), never
against the checkout, and no script or test of the repository was run in place.

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.index.md`: in full. `code-check-r.md` (111 sections): 53 read in full: Read-back shape; Moving prose
  into a code chunk; `on.exit()` at top level; `data-raw/` loads the source tree; Regenerated binaries churn; Tests
  that silently do not run; `skip_if_not()` scope; `expect_gt()` info; duplicate knitr chunk label; Base name
  shadowing; Cross-function consistency; `$` partial-matches; `nzchar(NA)`; `paste()` zero-length; `strsplit()`
  trailing; `identical()` on reader results; Under `R CMD check`; `dbConnect(SQLite())`; CSV whitespace; `sort()`
  collation; global-option dispatch; scalar helper in glue/mutate; `vapply(USE.NAMES)`; `stats::aggregate()`;
  `tryCatch(warning=)`; abort inside a C++ warning handler; `match()` NA; `expect_message()` first condition;
  `expect_false(identical)`; `unlist()` split names; `tolerance` relative; `[[` on atomic; `data.frame()` recycles;
  dot-prefixed column; `summarise()`/`mutate()` order; `tempfile()` lifetime; failure snapshots; Postgres row order;
  `sprintf("%g")` Inf/NA; Rscript reads a script as it runs; `pkg::` in a test; dplyr column wins; `expect_message()`
  returns the condition; `bind_rows()` all-NULL; `sample.int(prob=)`; `system2(stdout=)`; forked `mclapply`;
  `c(name = x)`; `function(...)` mock; `expect_message(regexp = "$")`; `tryCatch()` nests; `load_all()` runs
  `data/*.R`; `ifelse()` all-NA. 58 not read: their tools (xml2, glue, fs::dir_ls, arrow, duckdb icu, pak, yaml, cffr,
  climr, earthdatalogin, readBin, lintr, roxygen placement, pagedown, cli, ggplot aes loops, `.Rbuildignore`, …) do not
  appear in this diff.
- `code-check-shell.index.md`: in full. `code-check-shell.md` (67 sections): 20 read in full: Paths; Quoting; `wait`;
  `pgrep -f`; `mktemp`; GNU `stat`/`date`; `&` binds the list; failed `cd`; EXIT trap; `for x in $(cmd | grep)`;
  `grep -c`; empty arrays under `set -u`; `timeout`; a second `trap EXIT`; `if ! cmd; then rc=$?`; `exit` inside a
  loop condition; one numeric grammar; last line without newline; sed/awk range to EOF; Python CLI buffering. 47 not
  read (git/gh/sed/awk/ssh/docker/s3/conda rules the two chain scripts do not use).
- `code-check-spatial.index.md`: in full. `code-check-spatial.md` (94 sections): 15 read in full: sf name validation;
  GeoPackage is SQLite; the same leak in R and OGR SQL; restoring a GeoPackage from a copy; GeoJSON projected;
  `summarise()` on sf; `st_read()` promotes multi; `st_make_valid()`; `st_union()` after transform; GDAL failure
  partway through `st_read()`; gdalwarp writes into an existing destination; FWA main stem downstream end; `pdist`;
  FWA `upstream_route_measure`; FWA main flow edge types. 79 not read (terra, bcdata, STAC, gdalcubes, lidR, Wayback,
  …, absent from the diff).
- `code-check.md` (37 sections): the prose of all 14 `## Mechanisms` H3s in full, tables skipped; the index of
  `Rules that stand alone`, `Security` and `Spreadsheets and PDFs`.

Probes (all on scratch copies, R 4.5 / testthat 3.3.2 / mgcv 1.9.3):
- `probe1.R`: `expect_message()` with two messages (first non-matching) → PASS, so testthat 3.3.2 captures the first
  *matching* message; `model.matrix(~ 0 + a + b, <0 rows>)` → 0 × 3; `.tune_null_heldout()` on the full modelled
  population equals the scorer's own no-rule score (278.8411 both); with every group of one fold removed it runs
  (242.88, against 242.39 for the scorer's per-group null summed over the same groups, the refit differing as it
  should); the `dense` path runs (242.98); the same rows with an unused `era` level kept against dropped: 209.5925
  against 209.5722.
- `run_one_test.R`: `tests/testthat/test-tune_run.R` with its helper on a copy of the fixed tree (`pkgfix/`): 6 tests,
  45 expectations, 0 failed, 0 errors. The same file on a copy with the old gate restored
  (`pkgmut/R/tune_run.R:253` reading `cv$heldout >= rec$null_heldout`): 2 red arms, both in "a curve no better than no
  rule on held-out groups has its grades withheld" (`run()$grade_withheld` at line 121 and `g$grade_withheld` at line
  134), 0 errors; the other 5 tests green.
- Greps over the diff's added lines for `/Users/`, `/home/`, `PGHOST`, `PGPASSWORD`, `:5432`, IPv4 literals,
  `tailscale`, `ssh`, private repository names: nothing. `expect_(gt|lt|gte|lte)(…, info =)` in `tests/`: nothing.
  Duplicate knitr chunk labels in `vignettes/`: none. `tools:::.check_packages_used_in_tests()` on the copy: nothing.
- Read-only reads of `data/tune/BT_spawn_{grades,summary}.csv` headers for finding 1.

## Findings

- **[fragile]** `scripts/0325-publish.R:89-111`, `scripts/0330-compare.R:157-166`, with `data/tune/BT_spawn_*` as the
  tree holds them — the round-1 fix changed the gate and nothing changed the verdict already written, and neither
  consumer can tell. `data/tune/BT_spawn_grades.csv` carries `grade_withheld = FALSE` on every row and
  `data/tune/BT_spawn_summary.csv` has `dev_curve = 397.252`, `dev_null = 401.4063` and no `null_heldout_curve` column
  (last written d02af54, 2026-10-24, before 87266b2; measured read-only), while the gate in `R/tune_run.R:251-253` now
  says that key is withheld (397.3 against 378.8, the triage's own number). `0325`'s `stale` test asks only for the
  `grade_withheld` column's presence and `0330`'s for `curve_prior_sd` and `grade_withheld`, so a `0325` run today
  publishes bull trout spawning's grades, and a `0330` run compares them, under a verdict the code no longer makes,
  with no message. The plan records the regrade as owed, which is a reminder, not a guard ("Written data outlives the
  fix"; "A guard that fails toward pass"). Remedy: have `0320` write `null_heldout_curve` into the grade table beside
  `grade_withheld` (it already writes `curve_prior_sd`), and have `0325` and `0330` refuse a table without it, so a
  table gated before the fix is refused the way one walked before #73 is. Until the BT regrade lands, the `same`
  check at `0320:294-299` is what will catch it, and only when `0320` is run.

- **[fragile]** `scripts/0330-compare.R:262-286` — the compose now excludes this run's failed keys (round 1), and a
  saved per-key table from *another comparison* still composes without a word: `read_saved()` refuses a table only
  when its column names differ (`other_comparison`), so a `<key>_compare.csv` written under a different `CONFIG_SHA`
  or `TUNED_AS` than this run's, with the same columns, is bound into `compare.csv`, `change.csv` and `checks.csv`, and
  the "Composed with the saved comparison of …" lines print `default_rule`, km and `tuned_rule`, not `config_sha` or
  `tuned_structure`. A mixed-baseline `compare.csv` then shows only in its `config_sha` column, which nothing reads.
  Round 1's second remedy (refuse a table older than the run's `config_sha`) was not taken. Remedy: after
  `as_like()`, compare the saved table's `unique(config_sha)` and `unique(tuned_structure)` with `config_sha` and
  `tuned_as`, and either refuse or print the mismatch beside the key in the "Composed with" line.

- **[fragile]** `R/tune_run.R:49-51` (and `man/knw_tune_run.Rd:69`) — the `cache_dir` roxygen says the opposite of
  the fix: "The other scoring arguments (`seed`, `folds`, `n_boot`, `seeds_more`, `d_floor`, `extra`) are not
  checked", while `knw_tune_run()` now compares `fit`, `prior_sd`, `seed`, `folds`, `d_floor` and `extra` through
  `spec` (`R/tune_run.R:207-225`). The ones still unchecked are `n_boot`, `seed_boot` and `seeds_more` (a cache's
  bootstrap and extra-seed tables are read back whatever the run asked for). State the checked set and the unchecked
  three, and that a cache without `spec` is read with a message.

- **[fragile]** `scripts/logs/habitat/20261023_chain_73.sh:21,23,29` and `20261023_chain2_73.sh:15,17,32` — each
  long run is `Rscript scripts/0320-tune-run.R` / `scripts/0330-compare.R` in place, not from a frozen copy, which is
  the pattern the repo prescribes for a run of hours (`code-check-r.md`, "Rscript reads a script as it runs"): an edit
  to either script while a chain is in flight is spliced into the run. These are records of runs that have finished,
  so the cost is to whoever copies them for the next chain; the frozen-copy form belongs in the next one.

## The round-1 fixes, checked

- **The gate (`R/tune_run.R:251-253`, `.tune_null_heldout()` at 262-266).** `.tune_fold_setup(dd, resp, fold_of,
  folds)` indexes `fold_of` by group name (`fold_of[as.character(dd$wsg)]`), so a `cv$data` whose groups are a subset
  of `sc$folds`'s is placed on the run's own folds, and extra names in `sc$folds` are harmless; a group in `cv$data`
  with no fold cannot reach it, because `knw_tune_curve()` stops on `anyNA(fo)` first (and would otherwise stop in
  `.tune_score_one()` on "a visit was in no held-out fold"). A fold with no held-out row in `dd` is built (its `Xh` a
  0 × p matrix, measured) and then dropped by the `Filter()` on `length(f$ho)`; its training set was every row, so
  nothing in it is used. `dv` has length `sum(lengths(ho))` over the kept folds, which is `nrow(dd)` because each row
  sits in exactly one fold, and `f$ho` indexes rows of `dd`, so `anyNA(dv)` is the right completeness check. The
  all-FALSE rule column is a zero column both fits drop (`NA`, read as 0), the `ridge` vector is `ncol(Xn) + 1` long,
  and the `dense` path reaches `glm.fit()` through the same `fs` (run on the copy). On a population where every visit
  has a size the value equals the scorer's own no-rule score to the last digit (278.8411). The two sides of the gate
  now share rows, folds, the per-group intercept refit (`.tune_group_dev()`) and the nuisance prior.
  One difference remains and is not a defect: within a fold `knw_tune_curve()` drops the training set's unused
  `data_set`/`era` levels before mgcv's `paraPen` while `.tune_fold_setup()` keeps them, so where a training fold
  lacks a level the ridge is split over two columns instead of one; measured at 0.02 of deviance on 209.6 for the fe
  side alone, against gate margins of 4.2 (BT_spawn) and more. Recorded here so no one reads a small disagreement
  between `null_heldout` and `null_heldout_curve` on identical rows as a bug.
- **The test (`tests/testthat/test-tune_run.R:106-140`).** It restores the defect: a curve on four visits in five
  with held-out deviance midway between no rule's score on those visits and on all of them is withheld under the new
  gate and would have been published under the old (`expect_false(mid >= r$null_heldout)` documents it). Measured
  by mutation on a copy: with `cv$heldout >= rec$null_heldout` restored the file goes red on `g$grade_withheld`
  (line 134) and on `run()$grade_withheld` (line 121, where the old operand differs from the recomputed one in the
  last bits), with no errors, and is green on the fixed tree. The `curve_failed` arm is pinned (`grade_withheld`
  FALSE). `.tune_modelled()` and `.tune_null_heldout()` are called unqualified from the test, which `test_file(package
  = "knowledge")` and `devtools::test()` both resolve.
- **The compose (`scripts/0330-compare.R:262-263`).** `saved` is taken from every `_curve.rds` with a pick and a
  curve minus `names(res)` and `failed`, and the excluded keys are named in the log. The residual above is the other
  axis of the same hazard.
- **The score cache (`R/tune_score.R:155-157`, `R/tune_run.R:207-225`, `.tune_spec_norm()`).** `spec` is recorded
  on every new score; the check runs after the grid check, so a pre-record cache on another grid is rescored rather
  than read with the message; `.tune_spec_norm()` folds `5L`/`5` and leaves `Inf`, logicals and strings exact;
  `sc$spec[names(spec)]` on a cache lacking a later setting gives a `NULL` entry and so a rescore. The test pins
  `prior_sd`, `seed`, the message on a cache without `spec`, and the rescore on a cache lacking a grid column.
- **The home paths.** Gone from both chain scripts (`cd "$(dirname "$0")/../../.."`); the added lines of the diff
  carry no path under a home directory, host, port, login, credential path or private repository.
- **`previous` (`scripts/0320-tune-run.R:154`).** `if (length(previous)) previous else NULL`, and `knw_tune_run()`
  still refuses an unnamed non-empty vector.

## Checked and clean

- `knw_tune_smoke()`: the roles and fits are keyed on the in/out pattern as the scorer keys them, a previous pick
  equal to `default` is one fit, `coef_max` is `max(…, na.rm = TRUE)` over rows whose `rule` coefficient is `NA` only
  for no rule, and the mocked `.tune_score_one`/`.tune_group_dev` tests reach the gates they name.
- `knw_compare_rules()`: `rule_names` drive the flags, the FDIS check and the lift bootstrap alike; the `tuned`
  columns are copies of the `tuned_as` structure; `graded` makes a withheld key's graded km `NA` rather than 0; the
  `is_default_rule` assertion is confined to `door` with no pair; the near-river table is rebuilt per group by
  fresh's own walk; the scratch geometry cast refuses a multi-part segment, which is the intended failure.
- `knw_thresholds_table()`: `near_river_scope` is read only for a fitted rule with a pair, refuses a missing or
  many-valued comparison and a structure link has no scope for, and is `NA` with no `compare_dir`; the `[[` on the
  named scope vector is guarded by `%in%`.
- `knw_grade_species()`: `target_in_group` is `NA` where no river was found or the walk names none; the `match()`
  on `large_lfid` meets no `NA` on its right side; `ref_edge` falls back to `knw_tune_run()`'s default as the test
  pins.
- `0320`: `null_heldout_curve` and `grade_withheld` reach the summary and the `_curve.rds`; a withheld key is walked
  and written with `NA` grades; the keep-check compares the verdict, the prior, the walk, the reference edge types
  and the flow build. `0325`: a withheld table is left out of the published set and named; the stale, edge-type and
  flow-build checks read the tables' own records.
- `data-raw/vignette_chinook.R` and `vignettes/chinook_rearing.Rmd`: `compare` is the tuned structure's rows,
  checked for one row per group; the checks table is read by the structure name (`tuned_as %in% fv$rule`), which is
  how `knw_compare_rules()` names its rows; the wetland table has one `as_tuned` row and the vignette's `stopifnot`
  reads it.
- Shell: `set -u`, `mktemp` with six X's, `wait "$pid"` per job, `kill -0` on PIDs, the renames gated on `-nt`
  against a stamp taken at start, an exit on either failed job before the dependent comparison.
- `tests/testthat/test-tune_run.R:71`: `expect_message(…, "records no settings")` sits behind the smoke run's own
  messages and passes on testthat 3.3.2, which captures the first *matching* message (measured); the convention's
  "first condition" wording describes an older behaviour.

## Triage (session, 2026-10-25)

- **fragile, the written verdict outlives the fix** — fixed: `0320` writes `null_heldout_curve` into every grade table
  beside `grade_withheld`, its keep-check regrades a table without the column, and `0325` and `0330` refuse one (the
  stop names the reason). So every table on disk is refused until the host regrades them all (about 190 min, every
  key's walk), which is the cost of the guard, and the only run that can publish BT spawning's verdict is one made by
  the corrected gate. The plan's owed box says so.
- **fragile, a saved comparison under another baseline** — fixed: a saved per-key table whose `config_sha` or
  `tuned_structure` differs from the run's is left out and named with both values.
- **fragile, the `cache_dir` roxygen** — fixed: the checked set, the unchecked three, and the message for a cache
  without `spec`.
- **fragile, the chain scripts run `Rscript` in place** — accepted: they are records of finished runs, kept as they
  ran; the frozen-copy form is the rule for the next chain (CLAUDE.md, the Resume).
