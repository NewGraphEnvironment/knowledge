# Code-check round 5: branch `73-rebuild-the-evidence-and-retune-on-the-r` at bcbe155 against 8af0a4e0

Written 2026-10-25 (UTC). Read-only review of the fix commit bcbe155 (round 4's findings) as new code, with the whole
files it touches read from the working tree at bcbe155; nothing in the tree was modified except this file. One probe
ran from the session scratchpad (`r5/probe.R`) against copies of `R/thresholds_table.R` and `R/tune_repick.R` and on
literals; no script or test of the repository was run, and every read of `data/` and `scripts/logs/` was a header or a
`grep` of a log line.

## Checklist read

- `code-check.md`: the `## Mechanisms` H3 prose of "A guard that fails toward pass" (in full, including "Where the
  guard sits"), "Zero-length, empty, and unset are three different things", "Written data outlives the fix",
  "Serialization loses meaning silently" and "One fact derived twice"; the index of the other nine mechanisms and of
  `Rules that stand alone`, `Security` and `Spreadsheets and PDFs`.
- `code-check-r.md`: in full, the sections "Read-back shape must match write-back shape", "`nzchar(NA)` is TRUE",
  "`identical()` on two reader results tests the reader, not the file", "CSV whitespace: `trim_ws` and `strip.white`",
  "`match()` treats NA as a matchable VALUE", "`data.frame()` recycles a scalar against a zero-length column", "Inside
  a dplyr verb, a column named like a local variable wins", "`ifelse()` with an all-NA test returns a logical vector";
  `code-check-r.index.md` in full for the rest.
- `code-check-shell.index.md`, `code-check-spatial.index.md`, `code-check-python.index.md`: in full. The fix commit
  touches no shell, spatial or Python code, so none of their sections was read in full.

## Findings

One finding, on where the fix's new guard sits; it is the only real issue in the commit.

- **[fragile]** `scripts/0325-publish.R:65-80` against `99-114` — **the thresholds table is written and published before
  the checks that say whether its rows have a grade.** Line 65 builds `tt`, 66-67 write the tracked
  `data/thresholds.csv` and `data/thresholds_groups.csv`, and 78-80 call `knw_publish()` on them, which with
  `PUBLISH=TRUE` uploads the Parquet and the manifest to `knowledge/thresholds/v1/` before it returns
  (`R/publish.R:117,155-159`). `mispick` (99-108) and the new `no_grade` (111-114) run after all of that, in the grades
  section, so the comment at 109-110, "a run that stopped between the picks and the grades cannot publish the picks
  alone", states the opposite of what the code does: on that run the picks are published (the thresholds dataset) and
  only the grade dataset is refused. `knw_publish()` refuses to replace a published version's contents without
  `republish = TRUE` (`R/publish.R:145-147`), so a first publish, or the documented `REPUBLISH=TRUE` route (0325:27,
  33), ships the thresholds alone; and `data/thresholds.csv` is overwritten whether or not the script then stops.
  `mispick` has sat at 99 since round 3 (measured on `15f23ce`: lines 65-67, 78, 83, 89, 99 in the same order), so the
  position is pre-existing; it is named here because the fix added a guard whose stated purpose is the pre-publish
  property and placed it after the publish (`code-check.md`, "Where the guard sits": a check that exists only after
  the write refuses after the write it should have prevented). Remedy: move 83-124 (`gfiles`, `heads`, `stale`,
  `mispick`, `no_grade`, `evidence`, `ref_edges`, `loads`) above line 66; none of them reads `man_thr` or anything
  written at 66-80 (`tt`, `run_uid`, `discharge_load` and `tune_dir` are all bound by 65), and `knw_publish()` of the
  grades at 152 is unaffected.

## The round-4 fixes, checked

- **`0320:227,263-273` (the summary row and the `_curve.rds` record).** `evidence_md5` and `run_uid` are added in the
  fitted branch's `mutate()` (227); `row`'s columns at 188-190 are eight fixed names, none of them these, so the data
  mask falls through to the script's variables (measured: `mutate(evidence_md5 = evidence_md5)` on a tibble without
  the column takes the environment's value). `bind_rows()` at 263 fills the not-fitted rows with `NA`, so every
  `_summary.csv` written at 266-267 carries the two columns, a value on fitted and underpowered keys and an empty cell
  on the rest (`na = ""`). `out[[k]]$evidence_md5` and `run_uid` are set (268-269) before `saveRDS()` (270-272), and the
  `intersect()`'s first argument now names them, so they are in every `_curve.rds`, the not-fitted keys' included
  (harmless: `0330:94` keeps only records with `pick` and `curve`). The string is `tools::md5sum()`'s lowercase hex
  joined by `;` (106-110), 98 characters, no comma, quote or space, and a missing derived table stops at `read_csv()`
  (111) before any log or table is written.
- **CSV round trip of the string.** Measured: `readr::write_csv(na = "")` of the summary row, then `utils::read.csv()`,
  `read_csv(cols(.default = "c"))` and `read_csv()` with guessing give `character` on all three, `identical()` to each
  other and to the literal, and the extracted columns carry no attributes. The same bytes through `saveRDS()` are
  `identical()` too.
- **`knw_thresholds_table()` (`R/thresholds_table.R:59-70,86,144`).** Three input shapes, measured on copies: a summary
  with a value (`character`); a summary whose `evidence_md5` cell is empty, which is what 0320 writes for a not-fitted
  key (`read.csv()` types the one-row column `logical NA`, and `do.call(rbind, parts)` with a `character` sibling gives
  a `character` column with `NA`); a summary with no such column at all (the union bind at 63-67 sets `NA`, the same
  coercion). Line 70 covers a directory where no summary has the column. Line 144 maps `NA` of either type to
  `NA_character_`, and the not-fitted row (86) is `NA_character_` by construction, so the column is `character` on
  every row. The new test (`tests/testthat/test-thresholds_table.R:122-133`) reaches the absent-column case and the
  value case; the present-but-empty case is not pinned by a test, and is measured here to behave.
- **`0325:99-108` (`mispick`).** On a fitted key the four rows share one `evidence_md5`, so `length(ev) == 1L` and
  `!is.na(ev)` hold and the head's string is compared by value (measured TRUE on matching values). On a not-fitted key
  whose stray `_grades.csv` is on disk, the single row has `rule = NA_character_`, so `identical(h$rule, NA_character_)`
  is FALSE and the key is refused before `ev` matters (measured); such a row is in `heads` only when its table is on
  disk, and a 0320 rerun does not delete it (the grade loop skips keys with no curve, 290-292), so the message's "rerun
  0320" is one step short, which is pre-existing. A key absent from the thresholds table gives `length(rule) == 0`
  (measured), refused. A fitted row whose summary predates the record gives `ev = NA_character_`, refused with the new
  message, which is today's state for all eight tables and summaries on disk (`CH_rear_summary.csv` has no
  `evidence_md5`; no `_grades.csv` has one): the owed regrade.
- **`0325:111-114` (`no_grade`).** `fitted_keys` is the set of `rule_id`s with status `fitted` or `underpowered`;
  `R/tune_run.R:250-251` gives those two statuses only when the curve did not fail, 0320 writes `_tune.csv` only with a
  score and a curve (192-194), and the grade loop walks exactly the keys with a curve (290-292), writing a withheld
  key's table with `NA` grades (334-343). So the two sides of the `setdiff()` have one producer, and a withheld key is
  never named (measured on the fixture: `fitted_keys = CH_rear`, `setdiff()` against `CH_rear_grades.csv` empty).
  `heads` is `list.files("data/tune")` non-recursive (83) and `tune_dir` is the literal `data/tune` (34), so `dev/`
  and `grad_ext/` are outside both sides and 0325 never reads a `DEV=1` run.
- **`0330:157-171` (`stale`).** `h$evidence_md5` is a `character(1)` from an all-character read; `curves[[k]]$evidence_md5`
  is `character(1)` from the rds, or `NULL` on a record written before the fix, and `identical(<chr>, NULL)` is FALSE
  (measured), so an old record refuses. `$` on the list cannot partial-match: no other name of the record begins with
  `evidence_md5`.
- **`data-raw/vignette_chinook.R:130-136`.** `out$summary` is one row read with guessing (`character`, measured), `g1`
  one row all-character; the `%in% names()` guard precedes the comparison. The log regex matches the three md5 lines
  0320 writes at 109 (`"  <table> md5 <32 hex>"`: measured on the real line shapes, and each of the eleven tracked
  tuning logs carries exactly three), `sub()` strips the prefix, and the order of the lines is the `vapply()` order at
  106, the `paste()` order at 110, so the joined string equals the table's (measured). A log the selector (60-64)
  admits has a result line, so it is the run that graded the table it is compared with, which closes round 4's third
  finding.
- **Other writers of the two records.** `scripts/0322-tune-grad-extend.R:189-190` writes `grad_ext/CH_rear_summary.csv`
  and `grad_ext/CH_rear_curve.rds` without the new fields, under `data/tune/grad_ext/`, which `knw_thresholds_table()`
  (non-recursive `list.files`), `0330:92` (non-recursive) and `0325` never read; the vignette script reads
  `grad_ext_summary` as the record of the earlier run and compares no evidence on it by design (176-179). `DEV=1`
  writes both records with the fields under `data/tune/dev/`, which nothing reads back. No other writer
  (`grep` over `R/`, `scripts/`, `data-raw/`, `tests/`).
- Public-repo sweep over the commit's added lines: no path under a home directory, host, port, login, credential path
  or private repository; `SCHEMA` and `PG*` unchanged.

## Enumeration

**The mechanism:** a record written by one run is read back by a later run or consumer, and the reader tests the
record's presence where the question is whether it was made under the current rule. Round 4's table, re-walked at
bcbe155 with each reader's lines. A row is **closed** when the reader compares every identity the record carries that
the reader can also obtain; **open** names what it does not.

| record | writer | reader | what the reader checks now | status |
|---|---|---|---|---|
| `<key>_grades.csv` | `0320:337-343` | `0320` keep-check (304-321) | `rule`, `run_uid`, `walk`, `ref_edge`, `discharge_load`, `curve_prior_sd`, `grade_withheld`, `evidence_md5` by value; `null_heldout_curve` present | closed |
| | | `0325:89-124` | nine columns present; `ref_population`, `walk`; `rule` = thresholds row's, `run_uid` = ledger's, `evidence_md5` = thresholds row's and the row has one (99-108); every fitted or underpowered row has a table (111-114); one `evidence_md5`, one `ref_edge`, one `discharge_load` = live | closed on the pick, the run, the evidence and the complement; **the checks sit after the thresholds are written and published** (finding) |
| | | `0330:157-171` | `ref_population`, `walk`; `rule` = `curves[[k]]$pick$rule`, `run_uid` = ledger's, `evidence_md5` = `curves[[k]]$evidence_md5`; the prior, withheld and gate columns present | closed |
| | | `data-raw/vignette_chinook.R:82-88,129-136` | `ref_population`, `walk`; the gate's four columns; `rule` = `rec`; `evidence_md5` = the summary's and = the selected log's three md5 lines | closed |
| `<key>_score.rds` (cache) | `knw_tune_score()`, `R/tune_run.R:242` | `R/tune_run.R:220-237` | `visits_in`; every grid column; `spec` incl. `evidence` by value | closed (unchanged) |
| `<key>_curve.rds` | `0320:268-272` | `0330:92-94,164-165,316-320` | has `pick` and `curve`; its `pick$rule` and `evidence_md5` are what the grade is held to; `pick$rule` is what a saved comparison is held to | closed: the record now carries `evidence_md5` and `run_uid`, and `0330` holds the grade to it |
| | | `data-raw/vignette_chinook.R:242-258` | `cr$q`, `dist_cap_m`; md5 in `meta$md5_local` | closed by hash |
| `<key>_summary.csv` | `0320:263-267` | `knw_thresholds_table()` (`R/thresholds_table.R:59-70,78-98,144`) | status; `seeds_n`, `seeds_rec_in_region`; `evidence_md5` carried onto the rows (`NA` before the record) | closed: the identity is now on the record and carried to `0325` |
| | | `0320:146-152` (`previous`, from `_tune.csv`) | `recommended` present, exactly one `TRUE` | closed (unchanged) |
| | | `data-raw/vignette_chinook.R:92,121,130` | one row; `evidence_md5` = the grade table's | closed |
| `<key>_tune.csv`, `_groups.csv` | `0320:194,198-199` (inside the per-key loop) | `knw_thresholds_table()` (`R/thresholds_table.R:91-96,101,134-147,152-153`) | one-SE replay equals `recommended`; `rule`, `value`, `range_*`, `n_visits`, `n_detect`, `n_wsg` are read from here while `evidence_md5`, `status` and the readings come from the summary | **open, low:** nothing compares the two files of one key (`summ$rule_recommended` is read by nothing: `grep` over `R/`, `scripts/0325`, `0330`, `data-raw/`, `tests/`). `_tune.csv` is written per key inside the loop (194) and every `_summary.csv` after it (265-267), so a run that stops inside the loop (186-262; `if (dflt$in_region)` at 241 on an empty `dflt` is the one literal stop) leaves the keys already passed with a new grid beside an old summary, and the thresholds row then carries the new grid's `rule` and values with the old summary's `evidence_md5`; `mispick` passes where the rule string held, because the grade is the old evidence's too. The window is narrower than round 4's (the loop has few stops and runs in minutes) and a 0320 rerun repairs it. Remedy: `knw_thresholds_table()` requires `identical(summ$rule_recommended[i], rec$rule)`, or 0320 writes `evidence_md5` on the `_tune.csv` rows and the reader compares it with the summary's |
| `<key>_compare.csv` | `0330 run_one` (190) | `0330` compose (300-327) | columns identical; `config_sha`, `tuned_structure`, `tuned_rule` = this run's | **open, low, unchanged since round 4 and not claimed fixed:** the row carries no evidence identity, so a saved comparison whose grades were read from an earlier evidence build composes under the same pick; a research table (`compare.csv`), and `near_river_scope` (`R/thresholds_table.R:114-123`) reads only its `tuned_structure`. A remedy (write the head's `evidence_md5` on the compare rows) would make every saved table `other_comparison` until rerun, which is the right effect |
| | | `0330 STAGE=maps` (231-250) | file and `_segments.rds` exist; segments newer than the grade table | unchanged, low |
| | | `data-raw/vignette_chinook.R:96-107` | `structure`, `tuned_structure`; one row per group; md5 | closed by hash |
| `<key>_change.csv`, `_checks.csv` | `0330 run_one` | `0330` compose | columns identical; composed on the compare table's verdict | as the compare row |
| `<key>_segments.rds` | `0330 run_one` | `0330 STAGE=maps`; vignette script | mtime; `meta$md5_local` | closed |
| evidence ledger | `0310` | `0320:97-101`, `0325:38-41`, `0330:88-91` | `link_run_uid`, `run_link_sha` read | the identity every reader holds a grade to is `evidence_md5`, derived from the tables (the declared non-fix) |
| `data/fdis/derived/*.csv` | `0310` | `0320:106-114` | md5 taken and carried | closed by identity (the declared non-fix) |
| `data/thresholds.csv`, `thresholds_v1` | `0325:66,78` | vignette script; `test-vignette-data.R`; link | `rec` equal; CH rows' md5 | written before `mispick` and `no_grade` run (finding) |
| vignette bundle | `data-raw/vignette_chinook.R` | `test-vignette-data.R` | every tracked source's md5; CH rows; km reconcile | closed |
| tuning log | `0320:354` (`fail()`: 90) | `data-raw/vignette_chinook.R:60-64,133-136,198-199` | newest log with a result line; exactly one; its three md5 lines = the grade table's | closed |
| `grad_ext/` summary and curve | `0322:189-190` | vignette script (168-193) | the record of the earlier run, by design | outside the set (no reader gates on them) |

**Verdict.** The axis round 4 left open is closed: the evidence identity is on the summary and the curve record, and
`0325`, `0330` and the vignette script each hold a grade to its pick's evidence as well as its rule and run, and
`0325` refuses a fitted row with no table. Two members stay open, both low and both outside the fix's claim: the
summary and the tune table of one key are tied by nothing a reader compares (the thresholds row's `rule` and its
`evidence_md5` come from different files written at different points of the run), and the saved comparison carries
no evidence identity. The one finding is on where the closed checks sit: after the thresholds are written and
published, so the complement check cannot do what its comment says until it moves above line 66.

## Probes

- `r5/probe.R` (scratchpad; copies of `R/thresholds_table.R` and `R/tune_repick.R`, literals otherwise): the 98-character
  string through `write_csv(na = "")` then `read.csv()`, `read_csv(cols(.default = "c"))` and `read_csv()` guessing is
  `character` and `identical()` on every pair and to the literal, with no attributes on the extracted columns;
  `mutate(evidence_md5 = evidence_md5, run_uid = run_uid)` on a tibble without those columns takes the environment's
  values; a one-row CSV with an empty `evidence_md5` cell reads as `logical NA` and `rbind()` with a `character`
  sibling gives `character`; the absent-column case the same; `knw_thresholds_table()` on the fixture gives all-`NA`
  `character`, on the test's edited fixture `"a;b;c"` for CH and `NA` for KO, and on 0320's shape (a value on CH, an
  empty cell on KO) the value and `NA`; `mispick`'s arithmetic on a fitted row TRUE, on a not-fitted row FALSE at the
  rule, on an absent key `length(ev) == 0`; `no_grade`'s `setdiff()` empty; the log regex on the four real line
  shapes gives three lines whose join equals the string; `identical(<chr>, NULL)` FALSE; the rds round trip
  `identical()`.
- `grep -cE` of the md5 line pattern over the eleven tracked `*_tune_run*.txt`: 3 on each.

## Triage (session, 2026-10-25)

- **fragile, the guard after the publish** — fixed: `0325` builds the thresholds table first (the grade checks hold each
  table to its row), then runs every refusing check (`stale`, `mispick`, `no_grade`, one evidence, one reference edge
  set, one flow load equal to the live one) before anything is written or published; the moved block reads only
  what is defined above it (checked).
- **open, low: a new tune table beside an old summary** — fixed in `knw_thresholds_table()`: a summary whose
  `rule_recommended` is not its tune table's recommended rule is refused (tested; every committed pair agrees).
- **open, low: the compare rows carry no evidence identity** — accepted: a research table composed under the run's
  `config_sha`, `tuned_structure` and the curve's pick; its evidence is the grade table's, which `0330` now holds to
  the curve record's before it reads a grade, and `near_river_scope` is a run setting.

## The enumeration that ends the review (session, mechanical; `grep` of every reader of a run's record)

| record | reader | what it compares (by value unless noted) |
|---|---|---|
| `<key>_grades.csv` | `0320` keep-check | rule, run_uid, walk, ref_edge, discharge_load, curve_prior_sd, grade_withheld, evidence_md5; null_heldout_curve present |
| `<key>_grades.csv` | `0325` | ref_population, walk, ref_edge, discharge_load, grade_withheld, null_heldout_curve, evidence_md5, rule, run_uid present; rule, run_uid and evidence_md5 = the thresholds row's; every fitted row has a table; one evidence, one ref_edge, one load = live; all before any write |
| `<key>_grades.csv` | `0330` | ref_population, walk present and right; curve_prior_sd, grade_withheld, null_heldout_curve present; rule = the curve record's pick, run_uid = the ledger's, evidence_md5 = the curve record's |
| `<key>_grades.csv` | `data-raw/vignette_chinook.R` | ref_population, walk, the gate's record present; rule = the recommended rule; evidence_md5 = the summary's = the log's three md5 lines |
| `<key>_score.rds` | `knw_tune_run()` | visits_in, every grid column, `spec` (fit, prior_sd, seed, folds, d_floor, extra, evidence); a cache without `spec` read with a message |
| `<key>_curve.rds` | `0330` | pick present; evidence_md5 compared with the grade table's |
| `<key>_summary.csv` | `knw_thresholds_table()` | rule_recommended = the tune table's recommended rule; evidence_md5 carried to the rows |
| `<key>_compare.csv` (saved) | `0330` compose | columns, config_sha, tuned_structure, tuned_rule = this run's; a failed key never read back |
| the bundle's sources | `test-vignette-data.R` | md5 of every source, the CH rows of thresholds.csv |
| the tuning log | `data-raw/vignette_chinook.R` | the result line's shape; its md5 lines = the grade table's evidence |

Open and accepted: the compare rows carry no evidence identity (low; see above). Rounds run: 5, past the bound
`agent-operations.md` §2 names, each of rounds 2–5 finding a defect inside the previous round's fix; the enumeration
above, not a reviewer's verdict, ends it.
