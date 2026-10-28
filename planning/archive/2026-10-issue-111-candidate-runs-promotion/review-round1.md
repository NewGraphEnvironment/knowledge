# Code-check round 1: branch 111 (b1df1fa...fc54898)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of every H3 under `## Mechanisms` (14 headings, table rows skipped). Of the other headings I read
  only "A preview flag is only safe if it previews" (by index line). About 25 other headings not read.
- code-check-r.md: Read-back shape must match write-back shape; A `data-raw/` script must load the source tree; `$` on a
  list partial-matches; `nzchar(NA)` is TRUE; `paste()` with a zero-length argument; `identical()` on two reader
  results; Rscript reads a script as it runs; `system2(stdout = TRUE)` warns on a non-zero exit; `fs::file_move()` onto
  an existing directory; Base `file.info()` has no inode column. 10 read, about 110 not read.
- code-check-shell.md: none read (the diff has no shell code). 0 read.
- code-check-spatial.md: none read (the diff changes no spatial code beyond 0330's paths). 0 read.

How I checked: the three new test files pass in a copy of the package (promote 79, run_ledger 5, pick_report 24; 0 failed,
0 errors). I probed the promotion with the tests' own fixture in the scratchpad (probe1.R, probe2.R) and ran
`pkgdown::check_pkgdown()` on the copy. No database was used and nothing was written in the repo except this file.

## Findings

- **[bug] _pkgdown.yml:54-66.** `knw_run_ledger` is exported (NAMESPACE, man/knw_run_ledger.Rd) but is not in the
  reference index. `pkgdown::check_pkgdown()` on the branch fails with `In _pkgdown.yml, 1 topic missing from index:
  "knw_run_ledger"`, so the pkgdown workflow goes red on merge. The other two new exports are in the index.

- **[bug] R/tune_promote.R:200-211 with .knw_rows_merge, :260-278.** If a promoted key has no rows in the run's
  `compare.csv`, `change.csv`, `checks.csv` or `floodplain.csv`, its rows are deleted from the tracked table. No note
  or refusal says so. `k %in% keys` takes `new$rows[new$key == k]`, which is empty. This happens when 0330 runs
  normally: a key that failed in the latest 0330 pass is left out of the combined tables (scripts/0330-compare.R:361-364,
  "Not composed (failed this run …)"). Its `<key>_compare.csv` from an earlier pass of the same candidate still passes
  every per-key check (same rule, made after the grades). Reproduced with the test fixture: with CH missing from the
  run's compare.csv, `promote(fx)` returned no notes and wrote a tracked compare.csv holding only BT's rows. The old
  rows survive only in `replaced_<stamp>`. The same blind spot hits a key that the new run no longer fits (no rule).
  `plan_dir()` notes and keeps its tracked `<key>_compare.csv`, gpkg and figures, because the run wrote none, and
  `record()` never checks them (the promoted key's record reads only the run). So a stale compare made under another
  config can survive, and `data-raw/vignette_method.R` then refuses on it ("the comparison read 2 link config
  commits"). Suggested fix: before anything moves, refuse when a fitted promoted key is missing from any combined table
  the run carries.

- **[fragile] scripts/0330-compare.R:94.** The comparison log is named `<date>_compare-<run>[-stage].txt`, with no
  SPECIES and no pass number (0320 numbers its passes). A second same-day 0330 pass over the same candidate with another
  SPECIES= overwrites the first pass's log, so the log of the comparison that made the first keys' tables is lost before
  promotion. Combined with by-key promotion it also blocks: promote CH (its log is copied to scripts/logs/habitat/),
  run `SPECIES=BT 0330` on the same run that day, then promote BT. That stops at R/tune_promote.R:192, "a different
  log is already tracked". The same applies to 0335's own log (scripts/0335-promote.R:69): a second same-day by-key
  promotion of one run overwrites the first promotion's record.

- **[fragile] R/tune_promote.R:125-146 and scripts/0320-tune-run.R:104-109.** The Atlas-gradient sensitivity is promoted
  only from `<run>/grad_fwa/`. RUN defaults to a minute stamp, so `GRADIENT=fwa_gradient 0320` run without an explicit
  `RUN=` of the main run lands in a separate candidate. After an evidence change, promoting the main run is then
  refused ("would leave grad_fwa/CH_rear on another evidence_md5 … promote them too from a run on this build"). The
  grad_fwa-only candidate cannot be promoted either, because it has no `<key>_summary.csv` at its root. The refusal
  comes before anything moves, but its remedy cannot be followed. Neither the 0320 header nor scripts/README.md says
  the sensitivity must be run with the main run's `RUN=`.

- **[fragile] scripts/0335-promote.R:52-54 (the documented undo).** CLAUDE.md, 0335's header and knw_tune_promote's
  roxygen say `RUN=replaced_<stamp>` undoes a promotion. Through 0335 that undo is refused whenever the promotion moved
  the evidence build, because `live$evidence_md5` is this machine's `data/fdis/derived`, which is the new build.
  Reproduced: after promoting a run on e2, undoing with live e2 gives "the promoted keys carry evidence_md5 e1, not e2
  (this machine and tree)". A walk change blocks it the same way. So the undo works only when called as
  `knw_tune_promote()` directly, or after restoring the old derived tables, which is the case an undo is most needed
  for.

- **[fragile] data-raw/vignette_chinook.R:65-68.** The run's logs are picked by a prefix match on `<tune_run>-` or
  `<tune_run>.`. RUN allows `.`, so run `r1` also matches run `r1.b`'s logs (`…_tune_run-r1.b.txt`). A RUN named like
  a lowercase species code or `dev` matches the legacy tracked logs `20261019_tune_run-ch.txt` and
  `20261023_tune_run-dev.txt`. Logs are ordered by pass number alone, so a same-day `-2` pass ranks above a later day's
  unnumbered pass of the same run. If both regraded CH_rear, the older one is taken. The evidence-md5 cross-check at
  line 156 catches only a log on another evidence build, not one from another flow load or regrade. Matching the exact
  stem (`^<run>(-|\.txt$)`) and ordering by mtime would close both.

- **[fragile] scripts/0335-promote.R:55.** With `DRY=1` (and with `BUNDLES=FALSE`) the live flow load is never read, so
  a dry run reports success where the real run refuses (`discharge_load`). The real run still refuses before anything
  moves, so nothing is lost. But the preview does not run the check most likely to stop it after a wet reload.

Checked and found sound: every refusal in knw_tune_promote (per-key record, build agreement, live values, log
conflict, header merge, archive placement) is evaluated before the first `file.rename`. No path in 0320 or 0330 writes
under the tracked data/tune, data/compare, research/fig or scripts/logs/habitat any more; DEV goes to data/tune/dev/
and the catalog cache stays in the ignored data/compare/catalog/. The candidate paths and the archive are covered by
.gitignore. On today's tracked summaries, which have no `tune_run` or `evidence_ledger`, `knw_run_ledger()` and
vignette_chinook fall back to the newest ledger or log, which is exactly the behaviour from before the branch.
`.knw_rows_merge`'s key columns (species_code, stage) are present in all four combined tables.
