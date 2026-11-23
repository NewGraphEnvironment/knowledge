# Plan review of #233's task_plan (move 14, #226)

Plan agent, read-only, spawned 2026-11-22 04:58 UTC against the baseline `dd0d2ffd`, reported 05:04 UTC. It ran
nothing. Each finding below carries the verdict after a probe of the lines it cites.

Blockers raised: 2
Owner forks: 0

## Blockers

**B1. The score cache does not know the reading.** `R/tune_run.R:218-243`: the cache is `<key>_score.rds`, and its
settings hold the fit, prior, seed, folds, `d_floor`, `extra`, the evidence id and the gradient, with no `mad` column
and no walk source. Four readings sharing a `cache_dir` and an evidence id would each read the first's score, and the
run without LFRA would overwrite the full one.
- **Confirmed** by reading `R/tune_run.R:212-252`.
- **Folded into Phase 5:** one cache directory per reading and per LFRA variant, the reading's label in
  `evidence_id`, and the control scored from an empty directory, never `data/tune/`.

**B2. One mini-grid of every reading's rules does not give the verdict's SE.** `R/tune_score.R:447-453`: `se_diff` is
each rule's SE against the grid's own best, and no per-group matrix is returned.
- **Confirmed** (`.tune_sel()`: `se <- sqrt(n) * sd(M - M[, best])`).
- **Folded into Phase 5:** one two-row grid per window reading (the control's recommended rule and that reading's),
  `extra = FALSE`, once per seed 54 to 58; the row that is not the best carries the paired difference and its SE. The
  grid carries `rule`, `departures`, `is_default` (the control row), `exc_d`, the rule's own columns, and two columns
  of its own for the size column and the walk source. Each pair's `dev_heldout` must equal that reading's own run.

## Gaps

**G1. The label against the source in `knw_link_walks()`.** `R/link_walks.R:82` and the SQL's own check refuse
anything but the three sources; `$4` is both the function's source and the stored `src`; the hit query, `todo` and the
worker are keyed by source; `.knw_walk_cache_prepare()` hard-codes `knw_walk_md5()`.
- **Confirmed.** **Folded into Phase 3:** the bare source goes to SQL and the label is a separate value in the insert,
  the hit query and the returned table; the published path's SQL is held to a stored string by a test.

**G2. The walk's flow read.** Flow is read only in the LATERAL at `inst/sql/ch_dist_profile.sql:63-72`. A weighted
sum is faithful if it is taken per segment before the size filter and the `LIMIT`, with every month present on one
source; the marked region must hold the line that also lists the edge types.
- **Confirmed.** **Folded into Phase 3:** `count(*) = cardinality(months)` and one source; the text test also holds
  the edge-type list equal in both files.
- The suggestion to add the window file to `inst/method/settings.csv`'s `where` is **declined**: the register lists
  what shapes a published result, and nothing published reads the window walk.

**G3. Month completeness is proven only for Phase 1's segments.** The window walk passes over a segment missing a
month, silently, and the month-0 test cannot see it.
- **Accepted.** **Folded into Phase 4:** before any walk, the count over the whole load of segments with a picked
  annual flow but without the window's months on that source, logged, zero or stop; and the window flow is positive
  wherever MAD is.

**G4. `window_run.csv` sits under the ignored `data/fdis/`.** **Confirmed** (`.gitignore`). **Folded into Phase 4:**
its fields are written to tracked `data/tune/flow_window/ch_rear_window_evidence_run.csv` as well.

**G5. The control's call.** Pass `thresholds_extra` (the published table has an `is_link_tuned` row), compare as
`0322` does (`max(abs(round(new, 6) - published)) <= 1e-6`), and take the ledger the summary names.
- **Accepted.** **Folded into Phase 5.**

## Scope

**The scorer never reads the target flags** (`R/tune_run.R:136` passes no `no_lake_target`). Writing them as `NA` on
the window rows drops the width and regulation queries from Phase 4.
- **Accepted:** the window rows carry `NA` flags, which `knw_walk_index()` reads as `FALSE`, and the run record says so.

## Acceptance and ordering

- The text test's grade-record half runs only in the source tree (`data/` is build-ignored): **accepted**, the test
  skips where the records are absent and the plan says so.
- "Nothing lists `data/tune/` below its top level": the review cites every listing, all non-recursive
  (`R/run_ledger.R:26`, `R/thresholds_table.R:63`, `scripts/0325-publish.R:72`, `scripts/0330-compare.R:123,170,197`,
  `scripts/0320-tune-run.R:354`, `scripts/0336-archive.R:65`, `data-raw/vignette_chinook.R:135`,
  `data-raw/vignette_method.R:86`, `tests/testthat/test-tune_repick.R:59`, `test-vignette-data.R:141`). **Accepted as
  the evidence** for that checkbox.
- Phase 4's check against Phase 1's medians needs a tolerance (Phase 1 ran on wet 0.4.36): **accepted**, 1e-9.
- A timed walk of 500 starts before the full set: **accepted**, in Phase 4.
- "Phase 1's boxes are unticked": **not so**; the review read the baseline, and `267fcd06` ticks them.

## Confirmed by the review, no change

- The population and the modelled set read no size column, so the four readings score the same rows; a visit with no
  flow fails the size test and can still enter by the exception.
- No path lets a window row be read by the published walk or the reverse: the hit query filters `src` and `walk_md5`,
  and both are in the cache's primary key.
- No existing test breaks on a new SQL file or a new export.

## Not settled by reading (each is measured in its phase)

- Whether `pick` sits on one source with every month on every walked segment (Phase 4's count).
- The window walk's run time (Phase 4's timed 500).
- Whether wet 0.4.39 returns Phase 1's medians (Phase 4's check).

## Files the plan names

R/link_flow.R
R/link_walks.R
R/tune_run.R
R/tune_score.R
R/rule_in.R
inst/sql/ch_dist_profile.sql
inst/sql/ch_dist_profile_window.sql
tests/testthat/test-link_flow.R
tests/testthat/test-link_walks.R
data-raw/chinook_window_flow.R
data-raw/chinook_window_evidence.R
data-raw/chinook_window_tune.R
scripts/0322-tune-grad-extend.R
research/chinook_window_flow.md
research/chinook_stream_size.md
vignettes/tuning-method.Rmd
DESCRIPTION
_pkgdown.yml
CLAUDE.md
