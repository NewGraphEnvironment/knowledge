# Code-check round 1: branch `73-rebuild-the-evidence-and-retune-on-the-r` at 0dd49d4 against 8af0a4e0

Written 2026-10-25T16:23Z. Read-only review; nothing in the tree was modified except this file.

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.index.md`: in full. `code-check-r.md` (111 sections): 43 read in full: `$` partial-matches;
  database driver's value; `::text` spelling; Under `R CMD check`; CSV whitespace; `nzchar(NA)`; `paste()`
  zero-length; `strsplit()`; `identical()` on reader results; `tryCatch(warning=)`; `match()` NA; `expect_gt()`
  info; `[[` on an atomic vector; `data.frame()` recycles; `summarise()`/`mutate()` order; `tolerance` relative;
  Postgres row order; `sprintf("%g")` Inf/NA; Rscript reads a script as it runs; `pkg::` in a test; dplyr verb
  column wins; `system2(stdout=)`; forked `mclapply` segfault; `c(name = x)`; `bind_rows()` all-NULL;
  `tryCatch()` nests; `ifelse()` all-NA; `stats::aggregate()`; `function(...)` mock; `expect_false(identical)`;
  `vapply(USE.NAMES)`; scalar helper in glue/mutate; `unlist()` split names; `on.exit()` at top level;
  `data-raw/` loads the source tree; `skip_if_not()` scope; Tests that silently do not run; Base name shadowing;
  Cross-function consistency; URL reader timeout; Read-back shape. 68 not read: their tools (xml2, glue,
  fs::dir_ls, arrow, duckdb icu, pak, yaml, cffr, climr, earthdatalogin, readBin, lintr, roxygen placement,
  pagedown, cli, ggplot aes loops, …) do not appear in this diff.
- `code-check-shell.index.md`: in full. `code-check-shell.md` (67 sections): 14 read in full: Paths; `wait`;
  `pgrep -f`; `mktemp`; GNU `stat`/`date`; `&` binds the list; failed `cd`; EXIT trap; `for x in $(cmd | grep)`;
  `grep -c`; empty arrays under `set -u`; Quoting; `timeout`; a second `trap EXIT`. 53 not read (git/gh/sed/awk/
  ssh/docker/s3 rules the two chain scripts do not use).
- `code-check-spatial.index.md`: in full. `code-check-spatial.md` (93 sections): 12 read in full: sf name
  validation; `summarise()` on sf; `st_read()` promotes multi; GDAL failure partway through `st_read()`; GeoPackage
  is SQLite; the same leak in R and OGR SQL; FWA `upstream_route_measure`; FWA main flow edge types; FWA main stem
  downstream end; `st_union()` after `st_transform()`; `pdist`; GeoJSON in a projected CRS. 81 not read (terra,
  bcdata, STAC, gdalcubes, lidR, …, absent from the diff).
- `code-check.md` (37 sections): the prose of all 14 `## Mechanisms` H3s in full, tables skipped; the index of
  `Rules that stand alone`, `Security` and `Spreadsheets and PDFs`.

Probes run against copies or read-only: fresh 0.42.0's `frs_near_river()`, `.frs_near_river_specs()`,
`.frs_near_river_table()` and `frs_habitat_predicates()` sources (vector thresholds, `DELETE` by group before
insert, `s.` alias: all consistent with `R/compare_rules.R`); `format()` of lfids; `names(character())`; each
`data/tune/<key>_curve.rds` beside its `_tune.csv` and `_summary.csv` (read only).

## Findings

- **[bug]** `R/tune_run.R:230-232` (and `scripts/0320-tune-run.R:312`, `scripts/0325-publish.R:106-110`, which act
  on it) — `grade_withheld` compares two deviances summed over different visit populations. `cv$heldout` is
  `knw_tune_curve()`'s held-out deviance over `dd`, the rows left after `ok <- is.finite(log_size) & !is.na(grad) &
  !is.na(log_dist)` and a second `.tune_modelled()` (`R/tune_curve.R:81-84`); `rec$null_heldout` is the scorer's
  no-rule deviance over every modelled visit, including those with no size. Each dropped visit removes its deviance
  from the curve's side only, so the gate fails toward "publish the grades". Measured on the branch's own tables:
  RB_rear fits 10,047 of 12,959 scorer visits (3,055 with no size; curve 9,409.8 vs null 12,617.4); GR_rear 1,049
  of 1,230 and 25 of 26 groups (curve 743.6 vs null 828.0, a margin of 84 against 181 missing visits whose null
  deviance is roughly 0.67 each, about 120); BT_spawn 450 of 475 (397.3 vs 401.4, a margin of 4 against 25 missing
  visits). GR_rear's and BT_spawn's "not withheld" verdicts are inside the mismatch, so the published grade set for
  those keys rests on a comparison that cannot be read as "the curve beats no rule". Remedy: score the no-rule model
  on the curve's own rows (the same `.tune_group_dev()` per held-out group with `eta = 0`, over `dd`), or compare
  both over the common rows, and record both numbers. The same mismatch sits behind the pre-existing
  `dev_curve` vs `dev_best` log line, which the branch turned from a report into a decision.

- **[fragile]** `scripts/0330-compare.R:293-316` — the combined tables compose a *failed* job's stale per-key table.
  `saved <- setdiff(<every fitted key>, names(res))` is taken after `res <- res[setdiff(names(res), failed)]`
  (line 261), so a key that failed this run and has an older `data/compare/<key>_compare.csv` on disk is read back and
  bound into `compare.csv`, `change.csv` and `checks.csv`, logged as "Composed with the saved comparison of …", a line
  that reads as success. The only tell is a differing `config_sha` column, and only when the older run used another
  commit. The chain script guards this by hand (`20261023_chain2_73.sh:22`: "the four-species comparison would compose
  its stale tables; not run"), which is the evidence the script itself does not. The branch's `compare.csv` is clean
  (one `config_sha` over 1,756 rows, measured). Exclude `failed` from `saved`, or refuse to compose a table older than
  the run's `config_sha`.

- **[fragile]** `R/tune_run.R:203-210` — the score cache is under-keyed on the inputs this branch added. The cache is
  reused when `visits_in` and every grid column match; `fit` and `prior_sd` (and, as before, `seed`, `folds`,
  `d_floor`, `extra`) are not compared, and `knw_tune_score()`'s result records neither, so `<key>_tune.csv` cannot say
  which prior scored it (only the curve's `curve_prior_sd` reaches the summary). This run was rescored by accident of
  the new `departures_flow`/`is_link_tuned` columns; the next `prior_sd` change reads a stale cache back as its own
  result unless the operator follows `scripts/0320-tune-run.R:62`'s instruction to delete it. Store `fit`, `prior_sd`,
  `seed`, `folds`, `d_floor` and `extra` in `sc$population` (or a `sc$spec`) and compare them in the cache check.

- **[security]** `scripts/logs/habitat/20261023_chain_73.sh:7` and `scripts/logs/habitat/20261023_chain2_73.sh:8` —
  `cd /Users/airvine/Projects/repo/knowledge || exit 1`: a home path carrying the operator's login in two tracked
  files, committed 2026-10-22/23, after the 2026-10-16 cutover CLAUDE.md sets for home paths. `public_sweep.py`
  exempts `scripts/logs/` (`EXEMPT_PREFIX`, line 37), so the sweep will not see it before the repo goes public. The
  scripts also fail for any other user (`code-check-shell.md`, Paths). Replace with
  `cd "$(dirname "$0")/../../.." || exit 1` or a `REPO_ROOT` argument.

- **[fragile]** `scripts/0320-tune-run.R:141-154` with `R/tune_run.R:94-95` — on a `data/tune` with no `_tune.csv`,
  `previous <- character()` has `NULL` names (`names(character())` is NULL, measured), and
  `knw_tune_run(previous = previous)` stops with "previous must be named by species_stage" before anything runs.
  The script's intent is "no previous picks"; pass `if (length(previous)) previous else NULL`, or have
  `knw_tune_run()` accept an empty unnamed vector.

- **[fragile]** `R/tune_smoke.R:140-146` — the `coef` gate reads the `rule` coefficient as well as the nuisance terms,
  so a degenerate smoke candidate (a `previous` pick or link's `default_tuned` row that is in for every detected visit
  and out for a few undetected ones) separates on the rule term and stops the whole tuning run as a scorer defect
  (`R/tune_run.R:185-190`). `tests/testthat/test-tune_smoke.R` saw exactly this on `default` at `size_min = 0.1`
  (15.7 on fold 1) and moved the fixture rather than the gate. The report names the candidate, so an operator can
  tell, but the stop is unconditional. Either read the nuisance columns alone for the scorer gate and report the
  rule's separately, or document that a separated candidate is a stop.

## Checked and clean

- `inst/sql/ch_dist_profile.sql`: the 11 output columns are set on every `RETURN NEXT` and the terminal `RETURN QUERY`;
  connectors are excluded as targets and summed per polygon only after the current line's target search, which
  matches fresh's rule as `data-raw/walk_bank_check.R` measured it (0 of 2,460 BULK starts in the `bank` class).
  `R/link_walks.R:68` rebuilds the row binding so a multi-row result keeps one start per row.
- `R/compare_rules.R`: `frs_near_river()` accepts the vector specs `.frs_near_river_specs()` returns, deletes the
  table's own groups before inserting, and the predicates reference the streams table as `s.`, so the per-group walk
  and the CASE predicates compose; the `is_default_rule` assertion is correctly restricted to the `door` structure with
  no pair; `checks` is guarded against an empty list before `rbind`.
- `R/tune_score.R`: the group-absorbing IRLS projects the groups out of the real rows only and appends the ridge
  pseudo-rows afterwards, which is the right Frisch–Waugh form for a penalty on `b` alone; `.tune_group_dev()`'s
  bracket has opposite signs whenever the group holds both outcomes, which `.tune_modelled()` guarantees for every
  caller; socket workers receive all three internals by name and the test with `workers = 2` pins it.
- `R/grade_species.R`: the lfid array literal is built with `format(scientific = FALSE, trim = TRUE)`, which keeps
  every digit of a nine-digit id (measured); `match()` on `large_lfid` cannot meet an NA on the right because `lf`
  is `na.omit()`ed and the query returns only existing ids.
- Scripts take the schema from `SCHEMA` (0320, 0330, `data-raw/vignette_chinook.R`), and no hard-coded
  `fresh_default` remains in a path the run reads; the only `fresh_default` strings left are defaults and prose.
- No host, port, login, credential path or private repository appears in the diff beyond the home path above.
- `knw_tune_smoke` is exported, in `NAMESPACE` and `_pkgdown.yml`, and its example runs on a single-level
  `data_set`/`era` population as `knw_tune_score()`'s does.

## Triage (session, 2026-10-25)

- **bug, the gate's populations** — confirmed by scoring no rule on each curve's own visits with the scorer's own
  functions (`gate_probe.R`, session scratchpad): BT_rear 6,026.3 (grid 6,031.2), BT_spawn 378.8 (401.4), CH 1,374.2
  (1,380.5), CO 4,021.5 (4,024.0), GR 763.9 (828.0), RB 10,315.9 (12,617.4), ST 419.1 (420.8), WCT 1,329.7 (1,329.7).
  Against the curve's held-out deviance the verdict changes for **BT spawning alone** (397.3 against 378.8: withheld,
  not published by 4.2); GR's margin is 20.3, not 84.4, RB's 906.1, not 3,207.6; the other five verdicts stand.
  Fixed: `knw_tune_run()` scores no rule over `cv$data` on the run's folds (`.tune_null_heldout()`), records it as
  `null_heldout_curve`, and the gate compares it with the curve; `0320` writes the column to the summary and logs both
  no-rule scores; `test-tune_run.R` restores the defect (a curve on four visits in five, scoring between the two
  no-rule deviances, is withheld; the old gate would have published). The grade tables and comparison on disk still
  carry BT spawning as graded: the regrade (0320, which the keep-check reruns for a key whose verdict moved) and
  recompare (0330 BT) run on the database's host, not here; recorded in the plan.
- **fragile, compose of a failed job** — fixed: `saved` excludes `failed`, with a log line naming them.
- **fragile, the score cache's settings** — fixed: `knw_tune_score()` records `spec` (fit, prior_sd, seed, folds,
  d_floor, extra); `knw_tune_run()` rescores on a mismatch and, for a cache from before the record, reads it with a
  message naming the settings it is read as (deleting it would rescore every key for settings that did not move; the
  existing caches were scored with the defaults). Tests pin both.
- **security, home paths in the chain scripts** — fixed: `cd "$(dirname "$0")/../../.."`. Earlier revisions are
  #56's history sweep.
- **fragile, `previous <- character()`** — fixed in `0320` (`NULL` when empty).
- **fragile, the `coef` gate reads the rule term** — accepted for this branch: the stop is conservative and the report
  names the candidate; narrowing the gate to the nuisance terms is a change to the gate Al set, for Al to decide.
