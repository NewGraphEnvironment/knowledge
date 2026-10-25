# Code-check round 3: branch `73-rebuild-the-evidence-and-retune-on-the-r` at aa63419 against 8af0a4e0

Written 2026-10-25T17:05Z. Read-only review of the working tree at aa63419; nothing in the tree was modified except
this file. The two probes ran from the session scratchpad on literals alone (`fmt_probe.R`, `log_probe.R`); no script
or test of the repository was run, and every read of `data/` and `scripts/logs/` was a header or a column scan.

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.index.md`: in full. `code-check-r.md` (111 sections): 32 read in full: Read-back shape; `on.exit()` at
  top level; `data-raw/` loads the source tree; Regenerated binaries churn; Tests that silently do not run;
  `skip_if_not()` scope; `expect_gt()` info; duplicate knitr chunk label; `$` partial-matches; `identical()` on reader
  results; global-option dispatch; `stats::aggregate()`; `match()` NA; `[[` on atomic; Postgres row order;
  `sprintf("%g")` Inf/NA; dplyr column wins; `bind_rows()` all-NULL; `system2(stdout=)`; `c(name = x)`;
  `function(...)` mock; `ifelse()` all-NA; `paste()` zero-length; `nzchar(NA)`; CSV whitespace; `strsplit()` trailing;
  Base name shadowing; Cross-function consistency; `vapply(USE.NAMES)`; `tolerance` relative; `expect_message()`
  first condition; `expect_message()` returns the condition. 79 not read: their tools (xml2, glue, fs::dir_ls, arrow,
  duckdb icu, pak, yaml, cffr, climr, earthdatalogin, readBin, lintr, roxygen placement, pagedown, cli, ggplot aes
  loops, `.Rbuildignore` regex, `tryCatch(warning=)`, …) do not appear in this diff.
- `code-check-shell.index.md`: in full. `code-check-shell.md` (67 sections): 10 read in full: empty arrays under
  `set -u`; Quoting; Paths; `mktemp`; GNU `stat`/`date`; `&` binds the list; `wait`; `pgrep -f`; failed `cd`;
  `for x in $(cmd | grep)`. 57 not read (git/gh/sed/awk/ssh/docker/s3/conda rules the two chain scripts, accepted as
  records in round 2, do not use).
- `code-check-spatial.index.md`: in full. `code-check-spatial.md` (94 sections): 8 read in full: sf name validation;
  GeoPackage is SQLite; `summarise()` on sf; `st_read()` promotes multi; GDAL failure partway through `st_read()`; FWA
  main stem downstream end; FWA `upstream_route_measure`; FWA main flow edge types. 86 not read (terra, bcdata, STAC,
  gdalcubes, lidR, Wayback, …, absent from the diff).
- `code-check.md` (37 sections): the prose of all 14 `## Mechanisms` H3s in full, tables skipped, "Written data
  outlives the fix", "A guard's scope, escape hatches, and remedies" and "One fact derived twice" twice; the index of
  `Rules that stand alone`, `Security` and `Spreadsheets and PDFs`.

## Findings

All three are the mechanism named below, each on an axis the round-1 and round-2 fixes did not reach. None is a bug
in what the branch's own chain ran (measured below): the tree's tables are one baseline, one structure, and all eight
grade tables await the regrade round 2 made owed.

- **[fragile]** `R/tune_run.R:211-229`, `scripts/0320-tune-run.R:104-109,328-333`, `R/grade_species.R:121` — the
  evidence build's **content** is in no record and no cache key. The score cache is read back when `visits_in`
  (a row count), the grid's columns and `spec` match; `walks` (through `wi`, the exception rules' distances) and the
  values of `visits_link.csv` (`mad_pick`, `cw_deploy`, the gradient) are not compared, so a `0310` rerun on the same
  link run that moves flows (wet#103's reload, ±5 % on most segments, is the recorded case) or the walk convention
  (bank against centreline, this branch's own change) with the same visit count reads the old scores back as this
  run's. This run was rescored only because the grid gained `departures_flow` and `is_link_tuned` (round 1). The
  same gap reaches the records: `0320` logs the three derived tables' md5 (line 104) and checks nothing against them;
  the ledger carries md5s of `0310`'s inputs (`md5_sites`, `md5_catch`, `md5_fish`), not of the tables it wrote; and
  every grade table's `walk = "bank"` is the literal `knw_grade_species()` returns for its own walk
  (`R/grade_species.R:121`), which says nothing about the walks the curve was fitted on (`data/fdis/derived/walks.csv`,
  read at `0320:109` with no column or convention check). So the stamp certifies half of what the grade depends on,
  and the `0320` header's remedy ("remove `<key>_score.rds` after a change to R/tune_score.R") names the code and not
  the data. Remedy: have `0310` write the derived tables' md5s into the ledger, have `0320` refuse a derived table
  whose md5 is not the ledger's (so `run_uid` on every grade table is backed by a verified input), and pass that
  identity into `knw_tune_run()` as part of `spec` (an `evidence_id` argument, or the md5s themselves), with the
  cache test varying `walks` at a fixed row count.

- **[fragile]** `scripts/0325-publish.R:88-113`, `scripts/0330-compare.R:157-167,176-185,296-320` — the **pick** is
  the axis none of the three readers of a saved table checks. `0325` publishes each grade table under
  `rule_id = <key>_v1` and the thresholds row for the same `rule_id` carries `rec$rule` from `_tune.csv`; the grade
  table's own `rule` and `run_uid` columns are read into `heads` and compared with nothing. `0330` takes `job$pick`
  from `_curve.rds` and the grades from `_grades.csv` (`run_one` selects six columns, not `rule`), and its `stale`
  test asks for the record columns' presence and `walk == "bank"`. `0330`'s compose (`mismatch`) now refuses a saved
  per-key table under another `config_sha` or `tuned_structure`, and composes one under the same two whose
  `tuned_rule` is not `curves[[k]]$pick$rule`. The case that produces all three at once is ordinary: `0320` writes
  every key's `_tune.csv`, `_summary.csv` and `_curve.rds` before it grades any, so a run that dies mid-grading (the
  chain scripts record two such stops) leaves the ungraded keys' old grade tables beside new picks, and only `0320`'s
  own keep-check (`identical(head1$rule, r$pick$rule)`) knows. Until it is rerun, `0325` publishes grades graded under
  rule Y as `rule_id` X, and `0330` compares pick X's structures against grades and a `knw_size`/`knw_dist` walked for
  Y, with no message. Remedy: in `0325`, refuse a grade table whose `rule` is not the thresholds table's rule for its
  key or whose `run_uid` is not the ledger's; in `0330`'s `stale`, add `identical(h$rule, fitted[[k]]$pick$rule)`;
  in `mismatch`, add `tuned_rule` against `curves[[k]]$pick$rule`.

- **[fragile]** `data-raw/vignette_chinook.R:60-63,183-184,220` with `scripts/0320-tune-run.R:306` — the new log
  selector (the merge-base hard-coded `20261019_tune_run.txt`) takes "the newest tuning log with a line matching
  `^CH_rear grades:`" as the log that graded CH, and `0320`'s **kept** line matches it too: `"%s grades: already
  written under %s on %s, kept."` prints as `CH_rear grades: already written under …` (the *regraded* line was
  reworded to avoid the prefix, `0320:313`; this one was not, and three tracked logs already carry such lines:
  `20261017_tune_run.txt`, `20261017_tune_run-wct.txt`, `20261022_tune_run-ch_co.txt`). On the first full `0320` run
  that keeps CH's table, the script picks that log, `num_of("grades: ([0-9]+) groups")` returns `numeric(0)`
  (measured: `regmatches()` on no match), and it stops at line 220 with "the grade's groups () differ from compare's
  (125)", pointing at the comparison rather than at the log. It fails toward abort, so no bundle is written wrong;
  the cost is the misdiagnosis. Today the newest CH log (`20261024_tune_run.txt`) is a result line, so the script
  runs. Remedy: match the result line (`^CH_rear grades: [0-9]+ groups`), or reword the kept line as the regraded one
  was.

## The round-2 fixes, checked

- **`0320:293` `nhc_txt`.** `format(round(x, 4), nsmall = 4)` gives `"378.8123"`, `"10315.9123"`, `"12617.4062"`
  under default options (measured); `r$null_heldout_curve` is numeric wherever the loop reaches it (`if
  (is.null(r$curve)) next` first, and `.tune_null_heldout()` stops rather than returning `NA`). Nothing parses the
  column back: `0320`'s keep-check, `0325` and `0330` test its presence. Two notes, neither a defect: `format()`
  reads `getOption("digits")` and `OutDec` (`code-check-r.md`, global-option dispatch), so `options(digits = 3)`
  writes `1e+05` for a six-digit deviance and `OutDec = ","` writes `378,8123`; and `curve_prior_txt <-
  format(prior_sd)` on the same options is what the keep-check compares with `identical()`, so a session carrying
  either option regrades every key (the safe direction). `formatC(x, format = "f", digits = 4)` reads neither.
- **`0320:299-306` keep-check.** Compares `rule`, `run_uid`, `walk`, `ref_edge`, `discharge_load`, `curve_prior_sd`,
  `grade_withheld` by value and `null_heldout_curve` by presence. Presence is the right test for the gate's number:
  the verdict it produced is compared by value one clause up, and a moved number with the same verdict grades the
  same. What the check cannot see is finding 1 (the evidence content behind the curve) — `run_uid` is the link run,
  not the build.
- **`0325:88-98` `stale`.** Six columns' presence, `ref_population == "stream_branch"`, `walk == "bank"`; then one
  `ref_edge`, one `discharge_load`, equal to the live load; then `withheld` by `grade_withheld == "TRUE"` (the string
  `write_csv()` writes for `format(TRUE)`, read back as character). `curve_prior_sd` is not in the list and need not
  be: `0320` has written it since before `null_heldout_curve`, so no table carries the second without the first.
  Every table on disk is refused today: all eight `data/tune/*_grades.csv` headers carry five of the six columns
  (`null_heldout_curve` absent; measured read-only), which is the owed regrade round 2 recorded.
- **`0330:157-167` `stale`** matches `0325`'s set plus `curve_prior_sd`; same verdict on the tree. **`0330:308-320`
  `mismatch`**: `as_like()` leaves `config_sha` and `tuned_structure` character; a saved table with `config_sha`
  empty (`na = ""`) reads back `NA`, `identical(NA_character_, config_sha)` is `FALSE`, so it is left out as
  `config NA` (conservative); `vapply()` over `saved` names the result, so `mismatch[[k]]` resolves; an empty `saved`
  gives `character(0)` through every step. `composed` excludes `other` before `keep()`, and `keep()` guards the
  `other_comparison` sentinel again. The `change` and `checks` tables of a composed key carry no `config_sha` and are
  taken on the compare table's verdict, which `run_one` writes in the same `tryCatch`. The tree is clean on both axes:
  every `data/compare/*_compare.csv` carries one `config_sha` (`102762da`) and one `tuned_structure` (`door`)
  (measured).
- **`R/tune_run.R:46-56` roxygen** states the checked six, the unchecked three, and the message for a cache without
  `spec`; it does not say the data are unchecked (finding 1).

## Mechanism and enumeration

**(a) A record written by one run is read back by a later run or consumer, and the reader tests the record's
presence (a column, a file, a line) where the question is whether it was made under the current rule.** Rounds 1 and
2 found it on the gate's verdict (`grade_withheld` written before the gate was fixed), the score cache (settings not
in the key) and the compose (a failed job's table; another baseline's table). This round's findings are the same shape
on the axes those fixes did not name: the evidence content behind a record, the pick behind a grade or a saved
comparison, and a log line whose prefix two messages share. The enumeration below is every writer/reader pair the
branch's code holds, with what the reader checks.

| record | writer | reader | what the reader checks | status |
|---|---|---|---|---|
| `<key>_grades.csv` | `0320:328-333` | `0320` keep-check (299-306) | `rule`, `run_uid`, `walk`, `ref_edge`, `discharge_load`, `curve_prior_sd`, `grade_withheld` by value; `null_heldout_curve` present | guarded on everything but the build's content (finding 1) |
| | | `0325:88-113` | six columns present; `ref_population`, `walk`; one `ref_edge`; one `discharge_load` = live; `grade_withheld` | not guarded on `rule` against the thresholds table, nor `run_uid` against the ledger (finding 2) |
| | | `0330:157-167,176-185` | `ref_population`, `walk`; `curve_prior_sd`, `grade_withheld`, `null_heldout_curve` present | not guarded on `rule` against `fitted[[k]]$pick` (finding 2) |
| | | `data-raw/vignette_chinook.R:81-83` | `ref_population`, `walk` | `rule` is checked indirectly (`rec` = thresholds rule, and the compare's km reconcile); `grade_withheld`/`null_heldout_curve` unread — a withheld CH would fail at the `wl$grade_median_tuned > 0.2` `stopifnot` in the Rmd |
| `<key>_score.rds` (cache) | `knw_tune_score()` | `knw_tune_run():211-229` | `visits_in` row count; every grid column; `spec` (fit, prior_sd, seed, folds, d_floor, extra); a cache without `spec` read with a message | guarded on settings and grid; **not on the walks' or visits' content** (finding 1); `n_boot`, `seed_boot`, `seeds_more` documented as unchecked |
| `<key>_curve.rds` | `0320:270-272` | `0330:89-91` (`pick`, `curve`) | fitted = has `pick` and `curve` | the pick is the current one by construction (`0320` rewrites every key's rds each run); nothing ties it to the grade table it is compared with (finding 2) |
| | | `data-raw/vignette_chinook.R` (`cr`, surface) | `cr$q`, `dist_cap_m` present; md5 in `meta$md5_local` | guarded |
| `<key>_summary.csv`, `_tune.csv`, `_groups.csv` | `0320` | `knw_thresholds_table()` | status; one-SE replay equals `recommended` (a content check); `groups.csv` taken as is | guarded on the tune table's own consistency; `_summary.csv`'s `rule_recommended` is not compared with `_tune.csv`'s — written in one loop iteration, so no real exposure |
| | | `0320:120-126` (`previous`) | `recommended` column present, exactly one `TRUE` | guarded; a previous pick not in the new grid stops the run loudly (`knw_tune_smoke()`, "not in the grid") |
| | | `data-raw/vignette_chinook.R` | `rec` equals the thresholds rule; one-SE replay per key; `_seeds.csv`/`_honest.csv` print as the log's blocks | guarded by content |
| `<key>_compare.csv` | `0330 run_one:186` | `0330` compose (296-320) | columns identical to this run's; `config_sha`, `tuned_structure` equal this run's | guarded on baseline and structure; **not on `tuned_rule`** against `curves[[k]]$pick$rule` (finding 2) |
| | | `0330 STAGE=maps` (227-247) | file exists; `_segments.rds` not older than `_grades.csv` | labels itself from the table (`structure == tuned_structure`, the title's `tuned_structure[1]`); `config_sha`/`tuned_as` of the run not compared — a maps step, reads as saved |
| | | `knw_thresholds_table():107-116` (`near_river_scope`) | file exists; one non-NA `tuned_structure`; in `c(door, door_wetland)` | guarded on what it reads; `tuned_rule`/`config_sha` unchecked — the scope is `TUNED_AS`, a run setting, so a comparison of another pick gives the same scope unless `TUNED_AS` moved; low consequence |
| | | `data-raw/vignette_chinook.R:93-99` | `structure`, `tuned_structure` present; one row per group; md5 | guarded by md5 |
| `<key>_change.csv`, `_checks.csv` | `0330 run_one:187-188` | `0330` compose | columns identical; composed on the compare table's verdict | guarded through the compare table of the same `tryCatch` |
| `<key>_segments.rds` | `0330 run_one:189` | `0330 STAGE=maps`; vignette script | mtime vs grade table; `meta$md5_local` | guarded |
| evidence ledger | `0310` | `0320`, `0325`, `0330` (newest by filename) | `link_run_uid`, `run_link_sha` read | **no check that `SCHEMA` is that run's schema**, nor that `data/fdis/derived/*.csv` are that build's (finding 1); the vignette script checks the ledger the log names equals the newest |
| `data/fdis/derived/{visits_link,visits_species,walks}.csv` | `0310` | `0320:104-109`, `0330:97-99` | md5 logged (`0320`), nothing compared; `knw_walk_index()` requires `dist_m` and `status` | **not guarded** (finding 1): a centreline `walks.csv` would tune on centreline distances under grade tables stamped `walk = "bank"` |
| `data/thresholds.csv` | `0325` | vignette script; `test-vignette-data.R` | `rec` equal; CH rows' md5 (`md5_rows`) | guarded |
| vignette bundle (`inst/vignette-data/*.rds`) | `data-raw/vignette_chinook.R` | `tests/testthat/test-vignette-data.R` | every tracked source's md5 equals `meta$md5`; CH rows of `thresholds.csv`; `as_tuned` structure equals `meta$tuned_structure`; km reconcile | guarded by content; the ignored sources (`_segments.rds`, `_curve.rds`, `_score.rds`) are hashed into `meta$md5_local`, which no test reads (they are absent from a checkout, by design) |
| tuning log (`<date>_tune_run*.txt`) | `0320` | `data-raw/vignette_chinook.R:60-63,183-184` | newest file with a line matching `^CH_rear grades:`; exactly one such line; seeds and nested-selection blocks print as the tables | guarded on the blocks; **the prefix matches the kept line** (finding 3) |
| `fdis/README.md`, `0299`'s `walks` description | `0299` | publish | `knw_publish()` refuses a published version whose contents differ | the `walks` table's columns and `dist_m`'s meaning changed under the `v3` name (`0299:92`); `v3` is unpublished (CLAUDE.md, 2026-10-20), so no consumer holds the old meaning; a note, not a finding |

Two members are checks on the writer's side rather than readers, and both hold: `knw_grade_species()` returns
`ref_edge`, `q` and `walk` from the call, and `0320:321` stops when the grade's `ref_edge` is not the curve's; and the
grade's `walk = "bank"` is true of `knw_link_walks()` by construction (the package SQL is the bank walk,
`test-link_place.R` pins that the frozen `scripts/sql/` copy is not).

**(b) Two populations summed and compared as one.** The round-1 defect (the curve's rows against the grid's) is the
only instance in the code, and it is fixed: `cv$heldout` and `null_heldout_curve` are both over `cv$data` on
`sc$folds` through `.tune_group_dev()`, and `test-tune_run.R:106-140` restores the defect (round 2 measured it red).
Every other comparison in the diff is over one population by construction:

| comparison | populations | status |
|---|---|---|
| `grade_withheld`: `cv$heldout >= null_heldout_curve` (`R/tune_run.R:254-257`) | both `cv$data`, same folds, same per-group intercept refit | guarded; `.tune_null_heldout()` drops a fold with no held-out row and `anyNA(dv)` stops on a row in no fold |
| smoke `null_ratio` (`R/tune_smoke.R:85-86,105`) | `null_ho` and `null_in` over `d` after `.tune_modelled()` | one population |
| smoke `behind_null` (105) | every pattern's `sum(dev)` against `null_ho`, all over `d` | one population |
| nested selection `honest` (`R/tune_score.R:178-185`) | `dev_rec`, `dev_default`, `dev_null` over `in_k` per fold | one population |
| `0320:242-245` log: "Curve held-out %.1f vs grid best %.1f"; `_summary.csv`'s `dev_curve` beside `dev_null`/`dev_best` | curve's visits against the grid's | **still two populations in one sentence and in adjacent columns**, a report, not a decision; the next log line prints both no-rule scores with their visit counts, and `null_heldout_curve` sits beside `dev_curve` in the summary. `vignettes/chinook_rearing.Rmd` reads none of `dev_curve`, `dev_null`, `null_heldout_curve` (measured). A reader of `_summary.csv` can still make the round-1 comparison; a column note or dropping `dev_null` from beside `dev_curve` would end it |
| `knw_compare_rules()` `per_group()`: `default_km`/`tuned_km`/`change_pct`, `graded_km`, class km, `gained_exception*_km` | one `seg` per structure, the tuned curve's grade applied to both rules' segments (by design) | one population |
| FDIS check and bcfishobs lift (`checks`) | the same `vv`/`ls` for every `rule_name` | one population |
| vignette `rate(tuned_as, ·)` against `rate("default", ·)`; `wl$km_tuned < wl$km_default`; `wl_free$km_tuned > wl$km_default` | one `fv`; one `wl` (every row of `x$wetland` is built from the same through-wetland segments) | one population |
| `knw_grade_species()`: reference over `ref_rows`, grades over every accessible segment | by design (#65), recorded as `ref_edge` | guarded by record |

## Checked and clean

- `R/compare_rules.R`: `ks()` and `lift()` take a rule name and index `seg[[paste0(flag, "_", k)]]`; `bs` gets
  `colnames(bs) <- rule_names` (and `vapply()` would have named the rows from the first call anyway); `diff_of()`
  runs over `structures` only; `checks$tuned_structure` is set only when `checks` is non-NULL; `pred_cache` is
  assigned with `<<-` into the enclosing frame, where it lives; `target_in_group` enters the scratch `grades` table as
  a logical column (`NA` logical when the table lacks it) and `localcode_present` as `IS NOT NULL`; `change` carries
  `structure`, `species_code`, `stage`, `tuned_rule` (no `config_sha`, see the enumeration).
- `R/tune_run.R`: `prev <- unname(previous[[key]])` guarded by `%in% names(previous)`; `previous = NULL` passes
  through `do.call()` as an explicit NULL; `smoke_only` sets `status = "smoke"` on prepared keys only; `spec` carries
  `extra`, so a `DEV` cache under the same directory would be rescored rather than read (and `DEV` uses its own
  directory). `rec$grade_withheld` is `NA`, not `TRUE`, when `cv$heldout >= null_heldout_curve` is `NA`
  (`!FALSE && NA`, measured), and `0320`'s `isTRUE()` writes it `FALSE`; the arm is unreachable today
  (`.tune_null_heldout()` stops rather than returning `NA`, `cv$heldout` is a finite sum) — a `stop()` on
  `is.na(rec$grade_withheld)` would make it a deliberate resting place.
- `R/tune_grid.R`: `is_link_tuned` matches on values that entered the ladders through the same `sort(unique(c(…)))`,
  so `==` on doubles is exact; a row equal to `default` is allowed to be both.
- `R/tune_smoke.R`: `packBits()` keys dedupe identical in/out patterns; `max(rules$coef_max, na.rm = TRUE)` is `-Inf`
  only when no fit returns a coefficient, which `"rule"` always does.
- `0320`: `fail()` writes the log before stopping; `previous` reads `data/tune` non-recursively, so `dev/`, `grad_ext/`
  and `ref_*/` are out; `sum(r$recommended == "TRUE")` meets no `NA` because `knw_tune_score()` writes every row
  `TRUE`/`FALSE`. `0325`'s `prov$tune_logs` and the vignette's log search include a `-dev.txt` log; the vignette
  filters it out (no grades line), and the provenance list is cosmetic.
- `0330`: `config_sha` from `system2(stdout = TRUE, stderr = TRUE)` is tested on `attr(, "status")` before the
  40-hex check (the `system2` rule); `tuned_as` outside a species' structures stops inside `knw_compare_rules()` and
  the job is `failed`, excluded from the compose; the GeoPackage is written group by group with
  `append = file.exists(f)` after `unlink(f)`, from one-part MultiLineStrings throughout, so the layer's geometry type
  is one; `data/compare/gpkg/` is ignored.
- `data-raw/walk_bank_check.R`: `tryCatch(main(), finally = …)` drops the scratch schema and writes the log on every
  exit (not `on.exit()` at top level); the walk's `pg()` is qualified for the socket workers.
- `inst/sql/ch_dist_profile.sql` and `R/link_walks.R`: unchanged since round 2's reading; `knw_link_walks()` requires
  the exact row count and coerces `dist_centre_m`, `bank_m` numeric; `test-link_walks.R` pins `dist_m == pmax(dist_centre_m
  - bank_m, 0)` and no connector target on a live schema (skipped without one; the bank rule itself is
  `walk_bank_check.R`'s 0-of-2,460).
- Tests: `expect_(gt|lt|gte|lte)(…, info =)` absent (the comparison expectations take none); `expect_message(expect_equal(…),
  "records no settings")` assigns nothing from the return value; the `function(...)` mocks of `knw_tune_curve` are in a
  file whose other tests call the real one; `knowledge:::` reaches the internals under `R CMD check`; the one source-tree
  read (`scripts/sql/`) is behind `skip_if_not(file.exists())` in its own block. `.Rbuildignore` lists `^data-raw$`,
  `^scripts$`, `^data$`, `^research$`, `^planning$`, and `^\.git$`.
- Public-repo sweep over the diff's added lines: no path under a home directory, host name, port, login, credential
  path, IPv4 literal or private repository; the two chain scripts `cd "$(dirname "$0")/../../.."`. No `fresh_default`
  literal in a path a run reads: `0320`, `0330` and `data-raw/vignette_chinook.R` take `SCHEMA`, the tests' and
  `data-raw/walk_bank_check.R`'s literals are a scratch schema and defaults.

## Probes

- `fmt_probe.R` (scratchpad, literals only): `format(round(x, 4), nsmall = 4)` on 378.8123456, 10315.91234,
  12617.40625, 1374.2, 100000.12345, 0.5 → `"378.8123" "10315.9123" "12617.4062" "1374.2000" "100000.1234" "0.5000"`;
  under `options(digits = 3)` the fifth becomes `"1e+05"`; under `OutDec = ","`, `"378,8123"`. `format(2.5)` →
  `"2.5"`, `format(Inf)` → `"Inf"`, `format(isTRUE(NA))` → `"FALSE"`; `!FALSE && 5 >= NA_real_` → `NA`.
- `log_probe.R` (scratchpad, literals only): `grepl("^CH_rear grades:", "CH_rear grades: already written under … ,
  kept.")` is `TRUE`; `as.numeric(sub(pat, "\\1", regmatches(gl, regexpr(pat, gl))))` on it is `numeric(0)` and
  `identical(numeric(0), 29)` is `FALSE`; on a result line it is `31`.
- Read-only measurements of the tree: each of the eight `data/tune/*_grades.csv` headers carries five of the six
  record columns (no `null_heldout_curve`); `data/fdis/derived/walks.csv`'s header carries `dist_centre_m` and
  `bank_m`; the newest ledger (`20261022_evidence_build_ledger.csv`) has `walk_convention`, `walk_bank_m_positive`,
  input md5s only; every `data/compare/*_compare.csv` has one `config_sha` (`102762da`) and one `tuned_structure`
  (`door`); three tracked tuning logs carry a `grades: already written` line; the newest log with `^CH_rear grades:`
  (`20261024_tune_run.txt`) is a result line; the merge-base's `data-raw/vignette_chinook.R:55` hard-coded
  `path_log`.

## Triage (session, 2026-10-25)

- **fragile, the evidence's content is in no record** — fixed: `0320` names the evidence by the md5s of the three
  derived tables (`evidence_md5`), passes it to `knw_tune_run(evidence_id = )`, which puts it in the score cache's
  settings (a cache made on another build of the same visit count is rescored; tested), and writes it on every grade
  table, where the keep-check compares it and `0325` requires one value across the published set; `0330` requires it.
  The ledger-side half (0310 recording its outputs' md5s) is not taken here: 0310's output cannot be rebuilt on this
  machine, and the identity the readers need is the one `0320` now carries.
- **fragile, the pick is unchecked by the readers** — fixed: `0325` refuses a grade table whose `rule` or `run_uid` is
  not the thresholds row's; `0330` refuses one whose `rule` is not the curve's pick or whose `run_uid` is not the
  ledger's, and its compose leaves out a saved table whose `tuned_rule` is not the pick, naming it;
  `data-raw/vignette_chinook.R` refuses a grade table graded under another rule than the recommended one.
- **fragile, the log selector matched the kept line** — fixed: the selector and the result-line grep match
  `^CH_rear grades: [0-9]+ groups`, and the kept line is reworded (`<key>: grades already written …`) so no future
  line of that shape begins with the key and "grades:". The vignette script also refuses a grade table without the
  gate's record.
- The enumeration (mechanism a, the 18-row table above) now reads: guarded on every axis the readers can see (walk,
  reference edges, flow load, curve prior, verdict, gate number, evidence, pick, link run, baseline, structure), with
  two low-consequence rows unchanged (`near_river_scope`, `STAGE=maps`). Round 4 reviews these fixes.
