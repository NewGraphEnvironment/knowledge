# Code-check round 3: branch 111 (b1df1fa...87ddb28)

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, table rows skipped (the scratchpad extract `mech.txt`).
  No other heading read (about 25 not read).
- code-check-r.md: Read-back shape must match write-back shape; `sort()`/`order()` collate by `LC_COLLATE`; `$` on a list
  partial-matches; `nzchar(NA)` is TRUE; `fs::file_move()` onto an existing directory; CSV whitespace; `identical()` on
  two reader results; `ifelse()` with an all-NA test; `[[` on a named atomic vector; `system2(stdout = TRUE)` warns;
  Rscript reads a script as it runs; a `data-raw/` script must load the source tree; `paste()` with a zero-length
  argument; `match()` treats NA (the extract `rsel.txt`). 14 read, about 106 not read.
- code-check-shell.md and code-check-spatial.md: none read. The diff has no shell code and changes no spatial code
  beyond 0330's paths. 0 read.

How I checked: I ran the four touched test files in a fresh `git archive HEAD` copy (promote 94, run_ledger 5,
pick_report 24, thresholds_table 57; 0 failed, 0 errors, 0 skipped). I ran two probes on the tests' own fixture in the
scratchpad: `probe3.R` (stale maps and GeoPackage in a run) and `probe4.R` (an unfitted key with an earlier pass's
files). I read R/tune_run.R, 0320, 0330, 0325, R/thresholds_table.R and the bundle scripts for what each run writes and
what each reader requires. No database was used, and nothing was written in the repo except this file.

## Mechanism

I confirm the mechanism and narrow it. In both earlier rounds, presence or position stood in for provenance. The code
asked "is the field there?" or "does the name sort first?" when it needed "was this made by the step whose result is
being promoted?". The same mechanism has a third surface that the enumeration does not list: **the candidate directory
itself.** A candidate can be resumed (`RUN=` for 0320, the same `TUNE_DIR` for 0330, `STAGE=maps|gpkg` afterwards), and
nothing deletes a file that a later pass no longer writes. So in that directory, a file being present shows only that
*some* pass wrote it. It does not show that the pass whose record the key now carries wrote it. `knw_tune_promote()`
takes "the key's files in the run" to mean "what the run brings for the key". The source of truth is what the last
pass for that key wrote: 0320 writes only `<key>_summary.csv` and `<key>_curve.rds` for a no-fit key, and 0330's maps,
floodplain rows and GeoPackage belong to the comparison they were drawn from.

Every choice of a key set, file, run, ledger or log in the changed code:

| where | chooses | by | verdict |
|---|---|---|---|
| `knw_tune_promote()` per-key loop | which keys need grades and a comparison | `status` against `knw_tune_run()`'s statuses | sound (`curve_failed`, `smoke`, NA all refused) |
| `knw_tune_promote()` `fitted` | whose tracked files and rows may be removed | `status` not in the no-fit set | sound for removal |
| `knw_tune_promote()` `plan_dir()` | **which run files are a key's promoted state** | **name prefix present in the run directory** | **wrong for a no-fit key after a fitted pass (finding 1)** |
| `knw_tune_promote()` `plan_dir()` on `gpkg/`, `fig/`, and `floodplain.csv` rows | **whether the run's maps, GeoPackage and floodplain rows are of the promoted comparison** | **presence in the run** | **wrong after any recompare that was not followed by STAGE=maps/GPKG (finding 2)** |
| `knw_tune_promote()` `record()` | the build fields of a promoted key | first row of summary/grades, `one()` of the compare | sound for fitted keys; for a no-fit key it reads finding 1's stale grades |
| `knw_tune_promote()` comparison freshness | the compare is of the current grades | `mtime(compare) >= mtime(grades)` | sound (moves and `copy.date` keep mtimes; grades kept by 0320 keep theirs) |
| `knw_tune_promote()` logs | which logs come with the run | every `_tune_run*`/`_compare*` log in the run | sound by design (readers select by `tune_run`) |
| `knw_tune_promote()` `kept`, grad_fwa source | the set the promotion must agree with | tracked summaries; the run's sensitivity, else the tracked one | sound |
| `.knw_rows_merge()` | a key's rows in the combined tables | `species_code`+`stage`, `lost` on fitted | sound (all four tables carry both columns) |
| `0335` SPECIES | keys | candidate summaries by species prefix | sound |
| `0335` `live$evidence_md5` | the evidence the set is held to | the three derived md5s, **only when all three files exist** | **guard fails toward pass (finding 3)** |
| `0320` `pass` | the order of a run's passes | `1 +` count of logs **in this directory** | per-directory count, not an order across the run (finding 4, part a) |
| `0320` `ledger_path` | the build a new run scores | newest name | intended |
| `0320` `dir_pub` | the published side of the pick report | tracked `data/tune[/grad_fwa]` | sound (every tracked tune table has the columns and one recommended rule, checked) |
| `0330` `run`, `knw_run_ledger(tune_dir)` | the candidate and its build | `basename(TUNE_DIR)`; the summaries' ledger | sound. The TUNE_DIR pattern also admits `replaced_<stamp>`, which would write into an archive; not reported |
| `vignette_chinook.R` log | the log that graded CH_rear | `tune_run`, then highest pass with a grade line | sound given the numbering; see finding 4 |
| `vignette_chinook.R` fallback | the log for pre-branch tables | newest name, stamped logs excluded | sound |
| `knw_run_ledger()` (0325, 0330, vignette_method) | the ledger | the summaries' `evidence_ledger`, else newest | sound; the fallback is as accepted |

## Findings

- **[bug] R/tune_promote.R:166-188 (plan_dir with :86). A key that a later pass of the same run no longer fits is
  promoted with the earlier pass's tune, grades and comparison.** When the resumed pass sets a key to
  `too_few_groups`, `no_response` or `no_stream_rule`, 0320 writes only that key's `_summary.csv` and `_curve.rds`
  (scripts/0320-tune-run.R, the `else` branch and the summary loop). The earlier pass's `_tune.csv`, `_curves.csv`,
  `_grades.csv`, `_score.rds`, `_smoke.csv`, `_seeds.csv` and `_honest.csv` stay in `data/tune/candidate/<run>/`. Its
  `_compare.csv`, `_change.csv`, `_checks.csv` and `_segments.rds` stay in `data/compare/candidate/<run>/`.
  `plan_dir()` lists `^<key>_` in the run and moves all of them into the tracked directories. This contradicts the
  per-key loop's comment ("a summary (and a smoke table) only, nothing graded or compared") and the round-1 rule ("a
  key the run no longer fits leaves none of its last fit behind"). Reproduced with the test fixture (`probe4.R`):
  with CH_rear's run summary set to `too_few_groups` and its earlier files left in place, `promote()` returned 0
  notes. The tracked set afterwards held `CH_rear_{curve.rds,grades.csv,summary.csv,tune.csv}` and
  `CH_rear_compare.csv`, with the tune table tagged "new". `record()` also reads those stale grades for the build
  check, so the refusal can name the wrong cause: a discharge_load or walk mismatch from the old pass. 0325 then stops
  after the move, on `mispick` (a grade table under a status with no rule), and points at "rerun 0320". The test "a key
  the run no longer fits leaves none of its last fit behind" deletes the run's CH files by hand first, so it cannot
  reach this. Reaching it takes only a resume (`RUN=` after an evidence or code change), which the 0320 header
  documents. Suggested fix: for a key whose status is in `.knw_no_fit`, take only `<key>_summary.csv` and
  `<key>_curve.rds` from the run, and treat every other run and tracked file of the key as not brought (tracked ones
  removed and archived).

- **[bug] R/tune_promote.R:196-197 and :212-222. The run's maps, GeoPackage and floodplain rows are promoted even when
  they were drawn from an earlier comparison of the same candidate.** A full 0330 never redraws maps or
  `floodplain.csv` (STAGE=maps only), and with `GPKG=FALSE` (the iterating setting in CLAUDE.md) it leaves the old
  GeoPackage. Take a candidate that ran STAGE=maps, then recompared a key: after a regrade, a new pick or a new
  CONFIG_SHA. Its `fig/compare_<key>_*.png`, `gpkg/<key>.gpkg` and its rows in `floodplain.csv` then describe the
  superseded comparison. The promotion's freshness check covers only `<key>_compare.csv` against `<key>_grades.csv`.
  The maps stage's own guard (segments against grades) runs only when the maps are drawn. Reproduced (`probe3.R`): with
  the run's CH GeoPackage, figure and floodplain.csv an hour older than CH's comparison, `promote()` gave 0 notes and
  wrote all three, so the tracked GeoPackage read "gpkg of the earlier comparison". The asymmetry is the defect: when a
  run drew *nothing* the promotion keeps and notes the tracked copy (the accepted tradeoff), but when it drew something
  stale it moves that in silently. `floodplain.csv` and `research/fig/` are tracked, and `floodplain.csv` records no
  tuned rule (`rule` is default/tuned/accessible), so no reader can catch it later. Suggested fix: refuse, or note and
  keep the tracked copy for, a key whose run GeoPackage or figures are older than its run `_segments.rds`, and the
  run's `floodplain.csv` when it is older than any promoted key's `_segments.rds`.

- **[fragile] scripts/0335-promote.R:64 (and the header's claim at :21). The evidence check is skipped when
  `data/fdis/derived` is missing, so the promotion moves files that the chain then refuses.** `live$evidence_md5` is
  set only when all three derived tables exist. On a machine without them (they are ignored, and a promotion can run
  where the candidate was copied), `knw_tune_promote()` gets no evidence value and lets any build through. The rebuild
  chain then rewrites `data/thresholds.csv` (0325 does not check evidence) and the chinook bundle, and stops at
  `vignette_method.R:93` ("data/fdis/derived is not the evidence the grades were made on") with the tracked tables
  already moved. A `DRY=1` run passes the same way. The header says the evidence is "CHECKED AGAINST THIS MACHINE
  before anything moves". Suggested fix: when the rebuilds will run (`bundles`), refuse a missing derived table before
  promoting, as the flow load is read.

- **[fragile] scripts/0320-tune-run.R:122 with data-raw/vignette_chinook.R:66-77. The pass that "graded last" is
  derived from facts that do not always hold, and the remaining failures surface only after a promotion has moved the
  files.** (a) The pass number is one plus the count of this run's logs *in this directory*. The 0320 header supports
  grading a subset of species on another host with the caches copied, but that host's directory has no logs, so it
  numbers from p1 again. When the outputs are merged back, two `p1` logs either collide by name or tie in
  vignette_chinook's order. A `.knw_free_path()` suffix (`-p3-2.txt`) does not match the stem's `(-[a-z_]+)*`, so that
  log is invisible to it. (b) 0320 writes its log only at the end (or in `fail()`). A pass that dies partway through
  grading, a dropped connection say, leaves grade tables with no log. The next pass keeps those grades ("grades
  already written … kept"), so no log of the run carries `CH_rear grades:`. After the files are moved, vignette_chinook
  stops with "no tuning log in scripts/logs/habitat graded CH_rear". Before the branch, the fallback would have taken
  an older run's log instead, so the loud stop is an improvement. The gap is only that `knw_tune_promote()` does not
  check, before anything moves, that a log of the run grades CH_rear when CH_rear is promoted.

Checked and found sound this round: the round-2 fixes. The status split is `knw_tune_run()`'s seven statuses with NA
refused. Passes are numbered and matched with the run's exact stem, so `r1` no longer matches `r1.b`, and 0320's RUN
pattern forbids `.` and lowercase. The legacy fallback excludes stamped logs. 0335's rebuild children inherit `RUN`,
`SPECIES`, `DRY` and `BUNDLES`, but none of 0325, the three data-raw scripts or `readme_figure.R` reads them. The pick
report cannot abort 0320 on today's tracked tables: every `data/tune[/grad_fwa]/*_tune.csv` has the seven columns and
exactly one recommended rule. Every refusal in `knw_tune_promote()` still runs before the first `file.rename`.
