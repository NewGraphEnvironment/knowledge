# Code-check round 4 (#120 branch, at 2fb8221)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of the H3s under `## Mechanisms` (tables skipped); no other heading.
- code-check-r.md: read by heading, 2 read ("`tryCatch()` nests its handlers, so a `stop()` in one is caught by a later
  one", for `refuse()` raised inside a `tryCatch(error =)` handler; "`[[` on a named ATOMIC vector with an absent key is an
  error, not `NULL`", for `rec$tokens[["grad"]]` and `r$curve$cols[["grad"]]`), the rest not read (about 125).
- code-check-shell.md: none read (no shell in the diff).
- code-check-spatial.md: none read (round 3's fixes touch no spatial code).

## Round 3's fixes, read for defects inside them

- `scripts/0320-tune-run.R` L256-272, the connect-time `refuse()` block. It sits inside `if (!dev)`, and a setup can never
  be DEV (refused at L141), so it runs for every setup. `led`, `path_log`, `log_lines`, `say` and `dir_out` (= `dir_run`
  for a setup, created at L218) all exist by then. `refuse()` names the log `_tune_refused` by `sub("_tune_run", …)` on
  `path_log`, whose directory (`data/tune/candidate/<stamp>`) cannot contain `_tune_run`, so only the file name changes;
  `.knw_free_path()` numbers a second refusal. The tryCatch has one handler, so the `stop()` in `refuse()` is not caught
  again (code-check-r's tryCatch nesting rule does not apply). `rec$tokens` is always a named vector over
  `cut, acc, grad, flow` (`knw_build_record()` L54), so `[["grad"]]` cannot hit an absent name, and a pre-0.70.0 build
  (all NA) is refused through `anyNA()`. The checks the block replaces were reachable only on a grading run, which for
  `parent_gradient` was only a setup, so `setup && gradient == "parent_gradient"` covers the same cases. `rec` is not
  reassigned before L561 (`tokens_rec <- rec$tokens`), so the grade records still take the tokens the check read.
- `scripts/0330-compare.R` L250-258: the `_compare_refused` name is made the same way the latency refusal makes it (L220),
  and `path_log`'s directory `data/compare/candidate/<run>` has no `_compare-`.
- `data-raw/setup_compare.R` L147-156: `run_uid_full` is `log_recompute`'s runs joined with `;` in `ORDER BY run_uid`
  order, which is how `knw_build_record()` joins them (`string_agg(DISTINCT … ORDER BY run_uid)`), and that join is the
  `link_run_uid` 0310 writes on the ledger and every record carries. So one full run compares equal both ways, and so
  does a schema with several runs. An NA `run_uid` on a record makes `identical()` fail, which refuses. The parent
  setup's ledger is read through its record's `evidence_ledger`, and `.knw_parent_held()` refuses a ledger with no
  `parent_table` row.
- `data-raw/compare_structures_check.R` L148-152: a curve with no `cols` gives `NULL`, which fails `identical()` and
  refuses; a `cols` without `grad` is a subscript error inside the same `tryCatch(error = fail)`. Either way the check
  stops before any comparison. The stop is logged under the script's normal name, as its other stops are, and nothing
  reads that log by pattern.

## Enumeration re-verified (row, holds y/n, evidence)

| place | holds? | evidence at 2fb8221 |
|---|---|---|
| `scripts/0320` run guards (L160-185) | y | `setup.txt` and every root summary's `curve_grad` (NA tolerated). The marker is written (L219) only after the four guards. The two runs from before the marker, `candidate/20261105_0436` and `_0437`, each hold a summary naming `parent_gradient` and `segment_fwa_gradient` (read 2026-11-04). A setup refused at connect leaves its marker in its run directory, which is correct: the run is a setup. |
| `scripts/0320` `dir_out`, log suffix, `dir_pub` | y | `setup` and `GRADIENT` (L187-200, L476) |
| `scripts/0320` grade, keep-check | y | `r$curve$cols[["grad"]]` (L594, L621); every graded key has a curve |
| `scripts/0320` grade tokens | y | Now checked at connect (L264-267), before the smoke run and the scoring, through a `_tune_refused` log. The token is applied at L561 from the same `rec`. |
| `scripts/0320` parent held | y | Now at connect (L268-271), before scoring, through the same refusal. The grade itself is not re-held to the ledger: `knw_link_segments(gradient = "parent")` holds the table only to the database as it stands, through `knw_parent_read()`. A table rebuilt during scoring with its minimal build would be graded unnoticed, but 0330 (L250) and `setup_compare.R` (L156) then hold it to the ledger and refuse. This is the same connect-only shape as the build check (#87), so it is not a finding. |
| `knw_grade_species()` | y | `grade_species.R` L85-89: refuses a curve with no gradient, or with one outside `.knw_grade_grads` |
| `knw_link_segments()` / `.knw_seg_grad_check()` | y | `gradient` argument; the parent source is checked by `knw_parent_read()`, the Atlas source by its coverage count |
| `knw_compare_rules()` callers | y | 0330 passes `.knw_grade_grads[[run_grad]]`. `compare_structures_check.R` now refuses any curve not on `segment_gradient`, so the `"segment"` default is the curve's own gradient. 0322 and `compare_parallel_check.R` read only the tracked `data/tune`, which only promotion writes, and promotion refuses a setup. |
| `scripts/0330` `run_grad` | y | the fitted curves' `cols[["grad"]]`, one per run; with no fitted key, nothing is compared |
| `scripts/0330` stale check | y | `.knw_grade_grad_ok(h, run_grad)` and the curve's own `grad` |
| `scripts/0330` parent held | y | the ledger note (L250-258), now refused through a `_compare_refused` log. The ledger is `knw_run_ledger(tune_dir)`, which a fitted key's summary names. |
| `knw_tune_promote()` | y | `tune_promote.R` L104-110: the marker and every summary's `curve_grad`, read before the key loop, over the whole run |
| `scripts/0335` | y | through `knw_archive_plan()` and `knw_tune_promote()` (unchanged since round 3) |
| `knw_archive_setup()`, `knw_archive_plan()`, `0336` | y | the grade record's `curve_grad` and `token_grad`; unchanged since round 3 |
| `knw_grade_record_write()` | y | `tokens_rec` from 0320, now taken from the `rec` checked at connect |
| `scripts/0310` | y | unchanged since round 3 |
| `scripts/0325`, `knw_thresholds_table()` | y | `.knw_grade_grad_ok(h)` on the tracked tables; unchanged |
| `data-raw/vignette_chinook.R`, `vignette_method.R` | y | `.knw_grade_grad_ok()`; unchanged |
| `data-raw/setup_compare.R` | y (was n) | L150-154: the published, parent and Atlas records name one link run, which equals the parent table's `run_uid_full`. `knw_parent_read()` holds that to the schema's `log_recompute`, so the saved segments and the geometry are on the database's full build. L155-156 holds the table to the parent setup's ledger. The minimal side is held as before (L143-146). |
| `data-raw/pick_network_compare.R`, `tune_anchor_check.R` | n/a | they report and decide nothing |
| tests | y | unchanged since round 3. The scripts' connect-time refusals have no test, as 0320 and 0330 have none. |

## Clean

No issues found in round 3's fixes, and every row of round 3's enumeration holds at 2fb8221.

Note, not a finding: commit 2fb8221 ("Every-setup report rerun") also added three files unrelated to the rerun:
`scripts/logs/habitat/20261017_tune_run-attempt{1,2,3}.out`. They are console captures of #57's tuning attempts of
2026-10-17. A grep found no home path, host or credential in them. They look swept in by a broad `git add`; whether they
belong in history is the author's call.
