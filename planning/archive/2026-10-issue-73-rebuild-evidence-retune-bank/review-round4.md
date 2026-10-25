# Code-check round 4: branch `73-rebuild-the-evidence-and-retune-on-the-r` at 15f23ce against 8af0a4e0

Written 2026-10-25 (UTC). Read-only review of the working tree at 15f23ce, the round-3 fixes read as new code; nothing
in the tree was modified except this file. One probe ran from the session scratchpad on literals alone
(`spec_probe.R`); no script or test of the repository was run, and every read of `data/` and `scripts/logs/` was a
header, a column scan or a `grep` of a log line.

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.index.md`: in full. `code-check-r.md` (111 sections): 24 read in full: Read-back shape; `on.exit()` at
  top level; `data-raw/` loads the source tree; Tests that silently do not run; `skip_if_not()` scope; `$`
  partial-matches; `identical()` on reader results; CSV whitespace; `nzchar(NA)`; `paste()` zero-length; `match()` NA;
  `[[` on atomic; global-option dispatch; `expect_message()` first condition; `expect_message()` returns the
  condition; `function(...)` mock; `expect_false(identical)`; `system2(stdout=)`; Postgres row order; Rscript reads a
  script as it runs; `pkg::` in a test; `bind_rows()` all-NULL; `ifelse()` all-NA; `vapply(USE.NAMES)`. 87 not read:
  their tools do not appear in the round-3 fix or the files it touched.
- `code-check-shell.index.md`: in full. `code-check-shell.md` (67 sections): 3 read in full: Paths; a verification
  command can be shadowed; `grep -c`. 64 not read (the fix commit touches no shell).
- `code-check-spatial.index.md`: in full. `code-check-spatial.md` (94 sections): none read in full: the fix touches no
  spatial code.
- `code-check.md` (37 sections): the prose of all 14 `## Mechanisms` H3s in full, tables skipped ("A guard that fails
  toward pass", "A proxy is not the property", "Verification that reads its own output", "A guard's scope, escape
  hatches, and remedies", "Written data outlives the fix" and "One fact derived twice" read twice); the index of
  `Rules that stand alone`, `Security` and `Spreadsheets and PDFs`.

## Findings

Two residuals of the round-3 mechanism, each on an axis the fixes did not record, and one pre-existing complement
the round-3 remedy named by implication. None is a bug in what the tree holds today (every grade table on disk is
refused by every reader, measured below), and none changes a number already published.

- **[fragile]** `scripts/0320-tune-run.R:212-235,262-267` (the summary row and `_curve.rds` carry no evidence identity)
  with `scripts/0325-publish.R:99-107`, `scripts/0330-compare.R:157-170,311-325`, `data-raw/vignette_chinook.R:86,128`
  — the **evidence identity is recorded on the grade tables and in the score cache, and nowhere else**, so the readers
  that now compare the grade's `rule` and `run_uid` with the pick's cannot compare the grade's evidence with the pick's.
  `_summary.csv` and `_tune.csv` have no evidence or md5 column (measured on `CH_rear_*.csv`), `_curve.rds` is the list
  at `0320:265` (`pick`, `curve`, the three gate numbers), and `knw_thresholds_table()` stamps `evidence_version`
  from the literal `0325:36` passes it (`R/thresholds_table.R:151`), so `0325`'s `evidence` check (106-107) is one
  value across the grade tables against nothing outside them, `0330`'s `stale` (164) asks only that the column exists,
  and the vignette script (86) asks the same. The window that produces the mismatch is the one `0320:162-163` names for
  the pick: `0320` writes every key's `_tune.csv`, `_summary.csv` and `_curve.rds` (194-267) before it connects for
  grading (275, the first stop: `pg()`; 281; 327; any walk failure), so a run on a rebuilt evidence that dies anywhere
  in the grade loop leaves the later keys' new picks and curves beside their old grade tables, and `run_uid` does not
  separate them (a `0310` rerun on the same link run keeps the uid; only `evidence_md5` moves). Where the rule string
  holds, which the stability checks exist to make likely, `0325` then publishes thresholds scored on evidence 2 with
  grades from evidence 1 under one `prov_grade$evidence_md5`, `0330` compares the evidence-2 pick against evidence-1
  grades (`graded_km`, the class km, `grade_median_tuned`), and the vignette script passes `g1$rule == rec`. A `0320`
  rerun repairs it (the keep-check, 310, compares `evidence_md5`), but nothing before that rerun says so. Remedy: write
  `evidence_md5` (and `run_uid`) into the summary row (212) and the `_curve.rds` list (265); have
  `knw_thresholds_table()` carry `summ$evidence_md5` onto its rows, or `0325` read the summaries' value and compare it
  with `evidence`; add `identical(h$evidence_md5, curves[[k]]$evidence_md5)` to `0330`'s `stale`; and in the vignette
  script compare `g1$evidence_md5` with `out$summary$evidence_md5` (and with the three md5 lines the selected log
  carries at its head, `0320:109`, which no reader compares either).

- **[fragile]** `scripts/0325-publish.R:99-105` — `mispick` walks `heads`, so it refuses a grade table with no fitted
  thresholds row (`rule` is `character(0)`, or `NA_character_` for a `curve_failed` key: `length(rule) == 1L` or
  `identical()` fails, the script stops; measured on literals) and says nothing about the **reverse**: a fitted
  thresholds row (`tt$thresholds$status %in% c("fitted", "underpowered")`) whose key has no `_grades.csv`. The grade set
  is enumerated from `data/tune/*_grades.csv` (83) and the thresholds from `*_summary.csv`, two producers, and a key
  whose grading never ran (the window above, before its turn) is absent from the published grades with only the
  `message()` at 138 counting species × stage. Pre-existing at the merge-base; named here because the round-3 remedy
  ("refuse a grade table whose `rule` is not the thresholds table's rule for its key") has a complement the fix did not
  write. Remedy: after `mispick`, `setdiff(unique(tt$thresholds$rule_id[fitted]), paste0(sub("_grades\\.csv$", "",
  names(heads)), "_v1"))` must be empty, or each member named as withheld or missing.

- **[fragile, low]** `data-raw/vignette_chinook.R:60-64,190-203` — the selector now picks the newest log that **has** a
  result line, and the log and the grade table it describes are still tied by nothing: the table carries `run_uid`,
  `evidence_md5`, `rule`, `ref_edge`, `q_walk`, and the log carries the run uid (line 1), the three md5s (lines 2-4) and
  the result line's edge types and river size, and `meta$grade` (200-203) is read from the log while `g1` is read from
  the table. `0320` writes its log last (348), so a run that graded CH and died on a later key leaves CH's new table
  with no log, and the next run keeps the table (kept line, 313) and writes a log the selector skips, so the selector
  falls through to the previous run's result line. The seeds-block check (155) catches that case when the rescoring
  moved the seeds; when the score cache was read back (the same evidence, a new flow build), it does not. Consequence
  today is confined to the bundle: `vignettes/chinook_rearing.Rmd` reads no `meta$grade` field (measured: its `meta$`
  reads are `curve_ref`, `link_sha`, `map_group`, `spec$folds`, `spec$n_boot`, `tuned_structure`) and
  `test-vignette-data.R` checks none of them, and the first finding's remedy (compare `g1` with the log's md5 lines and
  `run_uid`) closes it.

## The round-3 fixes, checked

- **`knw_tune_run(evidence_id = )` (`R/tune_run.R:100,102,217-218,242`).** `chk_null_or(vld_string)` admits a
  length-1 non-NA string and `NULL`; `spec$evidence` is `NA_character_` for `NULL`, so two runs without an id share a
  cache and a run with one never reads a run without one (and the reverse): measured on literals, a `spec` without
  `evidence` subset by `names(spec)` carries an `NA`-named `NULL` and is not `identical()` to either form, so a cache
  written between the round-2 and round-3 fixes (a `spec` with no `evidence`) is rescored, the safe direction; no such
  cache exists on disk (the eight `_score.rds` predate `spec` entirely and take the round-2 message path). The id is
  set on `sc$spec` after `knw_tune_score()` returns (242), so it reaches the cache on the `fe` and `dense` paths alike
  (`knw_tune_score()` records the same `spec` list for both, `R/tune_score.R`) and is unused on the `smoke_only` path,
  which returns at 196-198 before any cache is read or written; `0320:158` passes it there harmlessly. Deleting 242
  would be caught: the test's `run(small)` under the `stop("rescored")` mock (`test-tune_run.R:75`) would then
  rescore, because the cache `first` wrote would lack `evidence`.
- **`0320` (`106-110,158,181,303-310,313,331-337`).** `evidence_md5` is the three md5s joined with `;`, logged one per
  line (109); a missing derived table gives `NA` inside the string, and `read_csv()` at 111 stops on the file first.
  The keep-check compares it by value (310) and the grade table carries it (335). The kept line (313) begins
  `<key>: grades already written`, the regraded line (317) `<key>: grades on file`, and the result line (338) is the
  only line of the shape `<key> grades: <n> groups`: measured on the four shapes, the selector matches the result
  line alone, and on the eleven tracked logs it matches none of the old kept lines (`CH_rear grades: already written,
  kept.`), picks `20261024_tune_run.txt`, and reads `125 groups` and `reference rate 0.1460` off it.
- **`0325` (`89-96,99-117`).** `stale` requires `rule` and `run_uid` present before `mispick` reads them; `mispick`
  compares the head's `rule` with the thresholds row's for `<key>_v1` and `run_uid` with the ledger's; every value is
  character on both sides (readr `cols(.default = "c")` against `utils::read.csv(stringsAsFactors = FALSE)` for the
  rule, the ledger read as character for the uid), and the CSV round trip of `rule`, `run_uid`, `evidence_md5`,
  `curve_prior_sd`, `grade_withheld`, `null_heldout_curve`, `discharge_load` (with commas and parentheses) and
  `ref_edge` is `identical()` on every field (measured). `heads` is `list.files(tune_dir)` non-recursive, so `dev/`,
  `grad_ext/` and `ref_*/` are out. The withheld tables stay in `heads` for the evidence, edge-type and load checks
  and leave `gfiles` after (120-125), which is right: they are the same run's.
- **`0330` (`92-94,146-154,157-170,299-338`).** `curves` is every `_curve.rds` by key, `fitted` those with `pick` and
  `curve`, `jobs` from `fitted`, and `stale` runs over `names(jobs)`, so `curves[[k]]$pick$rule` is a `character(1)`
  wherever `stale` reads it; a `_curve.rds` without `pick` (a key that was never scored) has no job and no check, and
  its grade table, if one is on disk, is neither compared nor composed. `saved` (299) is also drawn from the picked and
  curved keys, so `mismatch`'s `curves[[k]]$pick$rule` (316-318) resolves; `tr` is `unique()` of an all-character
  column `as_like()` leaves character, never `NA` (`tuned_rule` is written on every row), so a one-rule table gives a
  `character(1)` and `identical()` is the right test; a two-rule table (two runs' rows in one file) gives length 2,
  is refused, and the `say()` prints both.
- **`data-raw/vignette_chinook.R` (`60-64,82-88,123-128,190`).** Order of definitions: `g1` (82), `out` (90-101),
  `out$thresholds` (95), `rec` (123), the `rec` against thresholds check (124), then `g1$rule` against `rec` (128);
  nothing reads a name before it is bound. `g1` is read all-character and `rec` is a character column of a guessed
  table, so `identical()` compares like with like. The gate's four columns are those `0320:334-335` writes. `gl` (190)
  matches the same shape as the selector, so a log the selector admitted has at least one such line and `length(gl)
  != 1` catches two.
- **`tests/testthat/test-tune_run.R:68-69`.** `evidence_id = "another build"` against the cache `first` wrote with
  none: `NA_character_` against a string, rescored. The matching-id read-back is the same `identical()` arm as the
  `seed`/`prior_sd` cases one line up and is not separately pinned.

## Mechanism and enumeration

**(a) A record written by one run is read back by a later run or consumer, and the reader tests the record's presence
where the question is whether it was made under the current rule.** Round 3's table, re-walked on the tree at 15f23ce
with each reader's lines. A row is **closed** when the reader compares every identity the record carries that the
reader can also obtain; **open** names what it cannot.

| record | writer | reader | what the reader checks now | status |
|---|---|---|---|---|
| `<key>_grades.csv` | `0320:331-337` | `0320` keep-check (303-310) | `rule`, `run_uid`, `walk`, `ref_edge`, `discharge_load`, `curve_prior_sd`, `grade_withheld`, `evidence_md5` by value; `null_heldout_curve` present | closed |
| | | `0325:89-117` | nine columns present; `ref_population`, `walk`; `rule` = thresholds row's, `run_uid` = ledger's (99-105); one `evidence_md5` (106); one `ref_edge`; one `discharge_load` = live; `grade_withheld` | closed on the pick and the run; **open on the evidence** (finding 1: compared with the other grade tables, not with the thresholds' source); **open on the complement** (finding 2: a fitted row with no table) |
| | | `0330:157-170` | `ref_population`, `walk`; `rule` = `curves[[k]]$pick$rule`, `run_uid` = ledger's (164); `evidence_md5`, `curve_prior_sd`, `grade_withheld`, `null_heldout_curve` present | closed on the pick and the run; **open on the evidence** (finding 1: the curve records none) |
| | | `data-raw/vignette_chinook.R:82-88,128` | `ref_population`, `walk`; the gate's four columns present; `rule` = `rec` | closed on the pick; **open on the evidence** and on the log's identity (findings 1 and 3) |
| `<key>_score.rds` (cache) | `knw_tune_score()`, `R/tune_run.R:242` | `R/tune_run.R:220-237` | `visits_in`; every grid column; `spec` incl. `evidence` by value; a cache without `spec` read with a message | closed (`n_boot`, `seed_boot`, `seeds_more` documented as unchecked) |
| `<key>_curve.rds` | `0320:265-267` | `0330:92-94,164,316-318` (`pick`) | has `pick` and `curve`; its `pick$rule` is what the grade and the saved comparison are held to | the pick is the identity the readers use; **the record itself carries no `evidence_md5` or `run_uid`** (finding 1), so it cannot be held to the grade |
| | | `data-raw/vignette_chinook.R:234-250` (`cr`) | `cr$q`, `dist_cap_m` present; md5 in `meta$md5_local` | closed by hash |
| `<key>_summary.csv`, `_tune.csv`, `_groups.csv` | `0320:194-199,262-264` | `knw_thresholds_table()` (`R/thresholds_table.R:56-100`) | status; one-SE replay equals `recommended`; `evidence_version` is the caller's literal (151) | guarded on the table's own consistency; **no evidence identity to compare** (finding 1) |
| | | `0320:146-152` (`previous`) | `recommended` present, exactly one `TRUE` | closed (a previous pick not in the grid stops in `knw_tune_smoke()`) |
| | | `data-raw/vignette_chinook.R:91-128,155-156` | `rec` = thresholds rule; one-SE replay per key; seeds and nested-selection blocks print as the log's | closed by content |
| `<key>_compare.csv` | `0330 run_one` | `0330` compose (299-338) | columns identical; `config_sha`, `tuned_structure`, `tuned_rule` = this run's (311-325) | closed on baseline, structure and pick; the evidence behind the grade it read is not on the row (finding 1's third reader; low consequence, a research table) |
| | | `0330 STAGE=maps` (230-247) | file and `_segments.rds` exist | labels itself from the table; unchanged, low consequence |
| | | `knw_thresholds_table():107-116` (`near_river_scope`) | one non-NA `tuned_structure` in `c(door, door_wetland)` | unchanged, low consequence |
| | | `data-raw/vignette_chinook.R:96-107` | `structure`, `tuned_structure` present; one row per group; md5 | closed by hash |
| `<key>_change.csv`, `_checks.csv` | `0330 run_one` | `0330` compose | columns identical; composed on the compare table's verdict | closed through the same `tryCatch` |
| `<key>_segments.rds` | `0330 run_one` | `0330 STAGE=maps`; vignette script | mtime; `meta$md5_local` | closed |
| evidence ledger | `0310` | `0320:97-101`, `0325:38-41`, `0330:88-91` | `link_run_uid`, `run_link_sha` read | the ledger carries no output md5s (the round-3 triage's declared non-fix); `evidence_md5` is derived by `0320` from the tables themselves, which is the identity every reader of a grade now holds |
| `data/fdis/derived/*.csv` | `0310` | `0320:106-114` | md5 taken and carried; `knw_walk_index()` requires `dist_m`, `status` | closed by identity, not by verification (the declared non-fix) |
| `data/thresholds.csv` | `0325:66` | vignette script; `test-vignette-data.R` | `rec` equal; CH rows' md5 | closed |
| vignette bundle | `data-raw/vignette_chinook.R` | `test-vignette-data.R` | every tracked source's md5; CH rows; `as_tuned` = `meta$tuned_structure`; km reconcile | closed |
| tuning log | `0320:348` (`fail()`: 90) | `data-raw/vignette_chinook.R:60-64,190-203` | newest log with a `<key> grades: [0-9]+ groups` line; exactly one; blocks print as the tables | closed on the line's shape; **open on the log's identity against the table's** (finding 3, low consequence: nothing prints `meta$grade`) |
| `fdis/README.md`, `0299` | `0299` | publish | contents differ → refused | unchanged (a note in round 3) |

Members on the writer's side hold as in round 3: `0320:327` stops when the grade's `ref_edge` is not the curve's, and
`walk = "bank"` is `knw_link_walks()`'s by construction.

**Verdict on (a).** Closed on every axis a reader can see **except one**: the evidence identity, which the round-3 fix
put on the grade tables and in the score cache but not on the `_summary.csv` / `_tune.csv` / `_curve.rds` family the
thresholds and the comparison's pick come from, so `0325`, `0330` and the vignette script hold a grade to its pick's
rule and run but cannot hold it to its pick's evidence (finding 1), and two low-consequence members stay open: the
published grade set's complement (finding 2) and the tuning log's identity against the table (finding 3).

**(b) Two populations summed and compared as one.** Unchanged since round 3: the gate's two sides are over `cv$data`
on `sc$folds` (`R/tune_run.R:263-265`), and the `0320:236-238` log line and the summary's `dev_curve` beside
`dev_null` are the accepted reports.

## Checked and clean

- `0320`'s `withheld_txt`, `curve_prior_txt` and `nhc_txt` are formatted once (291-297) and the same string is written
  and compared, so the keep-check cannot disagree with its own writer on a formatting option; `format()`'s
  `digits`/`OutDec` note from round 3 stands (the safe direction).
- `0325:106-107`: `vapply(heads, function(h) h$evidence_md5, character(1))` runs only after `stale` has required the
  column on every head, so no `NULL` reaches `vapply()`.
- `0330:164`: `identical(h$run_uid, run_uid)` with `run_uid` a `character(1)` from the ledger; a ledger with two
  `link_run_uid` rows would make it length 2 and refuse every job (and `0320:331` would have failed to write first).
- `data-raw/vignette_chinook.R:62`: `readLines(f, warn = FALSE)` on a `-dev.txt` log (no result line) filters it out,
  as round 3 noted.
- Public-repo sweep over the fix commit's added lines: no path under a home directory, host, port, login, credential
  path, IPv4 literal or private repository (the one `ssh` hit is the word in this review's checklist list in
  `review-round3.md`). `SCHEMA` and `PG*` are unchanged by the fix.
- Measured on the tree: all eight `data/tune/*_grades.csv` carry eight of the ten columns `0325:90-91` requires
  (`null_heldout_curve` and `evidence_md5` absent), so every reader refuses every table today, which is the owed
  regrade; `CH_rear_summary.csv` and `CH_rear_tune.csv` carry no evidence or md5 column; two ledgers
  (`20261017`, `20261022`); eleven tracked tuning logs, each with the three md5 lines at its head, four with a CH_rear
  result line, the newest `20261024_tune_run.txt`.

## Probes

- `spec_probe.R` (scratchpad, literals only): a `spec` list without `evidence`, subset by the seven names, has names
  `fit,prior_sd,seed,folds,d_floor,extra,NA` and is not `identical()` (after `.tune_spec_norm()`'s form) to a `spec`
  with `evidence = "a;b;c"` nor to one with `evidence = NA_character_`; the same list with the same id is. The
  selector regex on the four line shapes `0320` writes: result line TRUE, old kept line FALSE, new kept line FALSE,
  regraded line FALSE. `readr::write_csv(na = "")` then `read_csv(cols(.default = "c"))` of `rule`, `run_uid`,
  `evidence_md5`, `curve_prior_sd`, `grade_withheld`, `null_heldout_curve`, `discharge_load` (a value with commas and
  parentheses) and `ref_edge`: `identical()` on every field; `utils::read.csv()` of the same file gives the same
  `rule`. `length(unique(character(0)))` is 0; `identical("x", NA_character_)` is FALSE.

## Triage (session, 2026-10-25)

- **fragile, the pick's evidence is on no record the readers hold a grade to** — fixed: `0320` writes `evidence_md5`
  and `run_uid` on the summary row and into the `_curve.rds` record; `knw_thresholds_table()` carries the summary's
  `evidence_md5` (`NA` on a summary before the record; tested); `0325` refuses a grade table whose `evidence_md5` is
  not its thresholds row's (or whose row has none); `0330` refuses one whose `evidence_md5` is not the curve
  record's; the vignette script refuses a grade table whose `evidence_md5` is not the summary's, and a tuning log
  whose three md5 lines are not the table's.
- **fragile, a fitted row with no grade table** — fixed: `0325` refuses when a fitted or underpowered rule has no
  `<key>_grades.csv` (a withheld key's table is written too), naming the keys.
- **fragile, low, the log is tied to the table by nothing** — closed by the md5 check above: the selected log's md5
  lines must equal the grade table's `evidence_md5`.
