# Code-check round 2: branch 111 (b1df1fa...60f8638)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, with the table rows skipped. No other heading read
  (about 25 not read).
- code-check-r.md: Read-back shape must match write-back shape; `sort()` and `order()` collate by `LC_COLLATE`; `$` on a
  list partial-matches; `nzchar(NA)` is TRUE; `fs::file_move()` onto an existing directory; CSV whitespace;
  `identical()` on two reader results; `ifelse()` with an all-NA test; `[[` on a named ATOMIC vector; `system2(stdout =
  TRUE)` warns; Rscript reads a script as it runs; A `data-raw/` script must load the source tree; `paste()` with a
  zero-length argument; `match()` treats NA. 14 read, about 106 not read.
- code-check-shell.md: none read, because the diff has no shell code. 0 read.
- code-check-spatial.md: none read, because the diff changes no spatial code beyond 0330's paths. 0 read.

How I checked: the three new test files pass in a copy of the package (promote 88, run_ledger 5, pick_report 24; 0
failed, 0 errors). I ran probes in the scratchpad: `probe_cf.R` (the tests' fixture, a curve_failed key) and
`probe_logs.R` (vignette_chinook's log ordering, run alone). No database was used and nothing was written in the repo
except this file. I re-read every round-1 fix in 60f8638 against the code that calls it.

## Findings

- **[bug] R/tune_promote.R:83, :169, :181 (and `.knw_rows_merge`, :276). A key whose curve fit failed is promoted as
  "no longer fitted", and its last good fit is deleted without a refusal or a note.** `knw_tune_run()` gives a key
  `status = "curve_failed"` when `knw_tune_curve()` errors (R/tune_run.R:262-271). 0320 then writes a summary with no
  `rule_recommended`, plus no `_tune.csv` and no grades. The promotion separates fitted from unfitted on
  `rule_recommended` alone. The per-key check therefore skips the key (`next`), `fitted` leaves it out, `plan_dir()`
  removes its tracked grades, tune, curves, compare, change, checks, segments, GeoPackage and figures, and
  `.knw_rows_merge()` drops its rows from compare/change/checks/floodplain.csv. Reproduced with the test fixture
  (`probe_cf.R`): with CH's candidate summary set to `curve_failed`, `promote()` returned 0 notes and removed
  CH_rear_grades.csv, _tune.csv and _compare.csv, and the tracked compare.csv kept 0 CH rows. 0325 then publishes the
  key with `status` curve_failed and no values (R/thresholds_table.R:85). A failed fit is a defect of the run, not a
  finding about the species, yet it unpublishes a fitted key while every guard reports pass. The files survive only in
  `replaced_<stamp>`. Round 1's fix ("a key the run no longer fits leaves none of its last fit behind") is right for
  `no_response`, `too_few_groups` and `no_stream_rule`, but it takes `curve_failed` in too. Suggested: in the
  per-key loop, before the `next`, refuse a key whose summary has a pick but no curve (`status == "curve_failed"`,
  or `rule_pick` set while `rule_recommended` is empty).

- **[fragile] data-raw/vignette_chinook.R:64-70. Two passes of one run on the same UTC day that name different
  species are not ordered by time, so the older pass's grade line can be taken.** The first pass of a run is
  `<day>_tune_run-<run>.txt` and a later `SPECIES=CH` pass is `<day>_tune_run-<run>-ch.txt`. Both are unnumbered, so
  both get pass 1 and tie on `(day, pass)`. `order()` keeps the order from the earlier
  `sort(decreasing = TRUE)`, and in that sort `.` (0x2E) beats `-` (0x2D), so the all-species pass comes first.
  `probe_logs.R` picks `20261028_tune_run-20261028_1200.txt` over the later `…-ch.txt`. Suppose both passes graded
  CH_rear: the first, then a regrade after a flow reload, or after the CH grades were removed to force one. The
  bundle then takes the superseded grade line's segment counts and reference rate (line 221 onward). The guards after
  it cannot tell the two passes apart. Both logs carry the same evidence md5s (line 156) and, after a regrade only,
  the same seeds and nested-selection blocks (lines 188-189). A mixed pair such as `-ch` and `-ch_bt` sorts on `_`
  against `.` in the same arbitrary way. The promotion copies logs with `copy.date = TRUE`, so ordering by mtime, or
  numbering every pass of a run (not only same-name repeats), would make "the pass that graded last" true.

- **[fragile] data-raw/vignette_chinook.R:63-64 (the fallback with no `tune_run`), with R/tune_promote.R's log copy.
  A by-key promotion of another species brings in a log that also grades CH, and the chinook bundle then takes it for
  the CH tables it does not describe.** Today's tracked CH_rear_summary.csv has no `tune_run` column, so the bundle
  falls back to the newest log of all that graded CH_rear. Take a by-key promotion that leaves CH behind
  (`SPECIES=BT 0335`) from a run that scored and graded every species. It copies that run's logs, such as
  `<day>_tune_run-<stamp>.txt`, which names a later day than the tracked `20261027_tune_run.txt`. That log is newest,
  so the bundle picks it for CH. The by-key gate holds the run to CH's build (evidence, flow load, walk), so the md5
  check at line 156 passes. If the run's CH result differs (a scorer change, which the gate does not compare), the
  seeds check at line 188 stops 0335's chain after the files have moved, with "the seeds table differs from the
  tuning log's". That message points at the CH tables rather than at the log choice. If the seeds agree but a
  grading change moved CH's grades, the article quotes the other run's grade numbers without any refusal. The window
  lasts until the first promotion that includes CH. Suggested: in the fallback, skip any log whose name carries a
  run stamp (`_tune_run-[0-9]{8}_[0-9]{4}`), since a summary with no `tune_run` predates them all.

Checked and found sound: every refusal in `knw_tune_promote()` (per-key record, build agreement across promoted, kept
and grad_fwa records, the live values, the log conflict, the combined-table header and the lost-key check) runs
before the first `file.rename`. The archive layout maps every planned directory, and an undo of it reads the same
layout. Logs are never archived or overwritten. `.knw_free_path()` is applied in 0320 (candidates), 0330 and 0335,
and the 0330 log names `SPECIES` (`only` is defined before use). 0320 refuses `GRADIENT=fwa_gradient` without a
`RUN=` that names a run with summaries. 0335's undo moves back with `live = NULL` and no rebuilds. The live
`evidence_md5` that 0335 builds has the same form and order as 0320's (three md5s joined by `;`). The grade tables
carry `walk_md5`, `discharge_load` and `ref_edge`, the names `record()` reads. `knw_tune_pick_report()` gets exactly
one recommended rule from every scored key (R/tune_score.R:152), so it cannot abort 0320 before grading. The new
candidate paths are git-ignored (checked with `git check-ignore -v`). `knw_thresholds_table()`, 0325 and
`knw_run_ledger()` list `data/tune/` without recursing, so a candidate never reaches them. vignette_bib.R takes its
ledger from the method bundle, which now uses `knw_run_ledger()`.
