# Review round 4 (#120): terminating enumeration

Branch `120-tune-chinook-rearing-on-minimal-segments` at `26c2856`, diff `6b7c31d...HEAD`. Code was run in a copy
(`git archive HEAD`), never in the checkout. Nothing here connects to a database.

## Checklist read

- `code-check.md`, Mechanisms prose (not the tables): "A guard that fails toward pass", "A proxy is not the property",
  "Verification that reads its own output", "A guard's scope, escape hatches, and remedies", "A fix lands in one of two
  callers that share a harness", "Restore the bug and prove the guard fires", "Zero-length, empty, and unset are three
  different things", "Written data outlives the fix", "Serialization loses meaning silently", "One fact derived twice".
- Index lines for the patterns this diff uses: `code-check-r.md` "Read-back shape must match write-back shape",
  "`data-raw/` script must load the source tree", "Postgres row order is never fixed", "An `information_schema` lookup by
  the literal table name", "`sprintf("%g", x)`", "testthat counts an uncaught error under `error`"; `code-check-shell.md`
  index only. `feature-workflow.md` "Public-repo text describes the package, and points nowhere private" (CLAUDE.md).

Tests run in the copy with `NOT_CRAN=true`, `testthat::test_file()`: settings-register 272 pass, run_ledger 23,
tune_promote 133, build_record 19, link_access_check 9, parent_join 9, vignette-data 193 (2 skipped), data-dir 1; no
failures and no errors. `data-raw/minimal_network_check.R` rerun in the copy against the two test builds (symlinked,
read only, no `STORED`): its log is the committed `20261102_minimal_network_check.txt` line for line up to step 5,
which needs the database. So the access-code block round 2 added is what the current script writes.

## Set A: shapes changed or added, and every reader

| member | readers (grep of R/, scripts/, data-raw/, vignettes/, tests/, inst/) | verdict |
|---|---|---|
| ledger `<date>_evidence_build_ledger.csv` (default dir, unchanged name) | `knw_run_ledger()` fallback `_evidence_build_ledger\\.csv$`; `.knw_evidence_ledger()` `^[0-9]{8}_evidence_build_ledger\\.csv$`; `snap_limit_sensitivity.R:46`; `0325`, `0330`, `vignette_method.R` via `knw_run_ledger()` | OK |
| tagged ledger `<date>_evidence_build_ledger-<base>.csv` | `.knw_evidence_ledger()` (0320, segment/minimal checks); no default pattern matches it (all end `_ledger\\.csv$`); `knw_run_ledger()` reaches it only through a summary's `evidence_ledger` | OK |
| refused ledger `<date>_evidence_build_refused[-<base>].csv` | no reader; outside every ledger pattern | OK |
| ledger row `evidence_dir` (first row) | `.knw_evidence_ledger()` compares by `.knw_path_key()`; a pre-#120 ledger without it is taken as the default's | OK |
| ledger rows `settle_log`, `settle_override`, `settle_schema`, `schema_species`, `parent_dir`, `parent_joined`, `parent_straddle`, `parent_gradient_differs` | none (grep); kind `info`, so no drop/kept partition sum moves | OK |
| ledger rows `access_disagree_<sp>` (now summed over groups) | none outside 0310 | OK |
| settle log name `<date>_link_settle-<schema>.csv` | 0310 default list `_link_settle\\.csv$` excludes it; taken only with `SETTLE=` | OK |
| settle log columns `schema`, `poll_min` | 0310 reads `st$schema` (absent before #120 -> `fresh_default`), `status`, `run_uid`, `link_*` | OK |
| settle log rows written whole each poll (`write_log()`) | no append across formats | OK |
| `access_check.csv` + `watershed_group_code` (2nd column) | `0299` (new guard), `minimal_network_check.R` step 3 (guard); no other reader | OK |
| `visits_link.csv` + `parent_id_segment`, `parent_gradient`, `parent_length_m`, `parent_straddle_m` (only with `PARENT_DIR`) | 0320 (`GRADIENT=parent_gradient`, column check), `minimal_network_check.R` step 4 (excluded from the column diff by `^parent_`); 0290/0294/0296/0330 select by name; 0299 records the schema in the manifest | OK |
| summary columns `min_wsg`, `folds` | `knw_tune_promote()` floors check (main and `grad_fwa/`); `knw_thresholds_table()` and `vignette_method.R` bind on the union of columns | OK |
| summary column `evidence_dir` | `0330` (`sum_dirs`), else unread; union binding as above | OK |
| grade record columns | unchanged (`.knw_cols_grade_record_extra` not in the diff) | OK |
| 0320 first log line (ledger path kept before " on link run") | `vignette_chinook.R:91` and `:266`, `0322:106` regexes; tested against the new line shape | OK |
| 0320 `Floors:` log line | no reader by position; `vignette_chinook.R` reads `^<key> grades:` and `^ +<f> md5 ` lines | OK |
| 0320 log name `-grad_parent` suffix | `vignette_chinook.R` stem accepts `(-[a-z_]+)*` but filters on grade lines, which a parent pass lacks; `knw_tune_promote()` copies it (accepted tradeoff) | OK |
| `DEV_DIR` / `data/tune/dev_*/` | `.gitignore:39` ignores it (checked with `git check-ignore`); 0320 `dir_pub` now from `grad_dirs`, not a regex over `dir_out` | OK |
| `grad_parent/` under a candidate | `knw_tune_promote()` lists `run_tune` and `grad_fwa/` only; `0330` and `knw_run_ledger()` list non-recursively | OK |
| `0330` log line "Evidence %s (%s)…" | no reader | OK |
| `<date>_segment_gradient_check[-<base>][-<n>].txt` | no reader; `.knw_free_path()` never writes over | OK |
| `<date>_minimal_network_check[-<n>].txt` | no reader; `-2` confirmed on rerun in the copy | OK |
| `knw_link_access_check(by_group =)` | 0310 only; empty case keeps the column (test) | OK |
| `knw_build_record()` tokens from `<schema>.log` | `knw_grade_record_write()` (0320), `knw_archive_setup()` names folders; 0336 compares run/flows/walk only. Tracked records are link 0.66.0 (blank tokens), so no written record disagrees with the new reader | OK |
| `knw_parent_join()` (new export) | 0310; NAMESPACE, `_pkgdown.yml`, man page present | OK (see F3 for its guard) |
| env vars `EVIDENCE_DIR`, `SETTLE`, `PARENT_DIR`, `DEV_DIR`, `MIN_WSG`, `FOLDS`, `SCHEMA`/`POLL_MIN` (0300), `FULL_DIR`, `MIN_DIR`, `STORED` | each read only by the scripts that document it; `EVIDENCE_DIR` keeps one meaning across 0310/0320/0330/0336/site and compare checks | OK |

## Set B: prose added or changed, and what it describes

| sentence / claim | source | verdict |
|---|---|---|
| CLAUDE.md: 0310 writes `EVIDENCE_DIR`, ledger first row names it, tagged name outside the fallback | `0310:85-97`, `R/run_ledger.R` | OK |
| CLAUDE.md: "0310 refuses the default directory to a build settled on another schema's log … so a test build never becomes the build a default reader takes" | `0310:123` keys on the path string | FINDING F2 |
| CLAUDE.md: 0320 and segment_gradient_check take `EVIDENCE_DIR` and find the ledger by it; summary names `evidence_dir`, grade record does not | code | OK |
| CLAUDE.md: 0330 reads the summaries' directory or `EVIDENCE_DIR`, refuses tables whose md5s are not the curves' | `0330:147-158` | OK |
| CLAUDE.md:413-414: "Paths written into ledgers, summaries and logs are relative to the repo root, or under `~`, never a home path" | true of 0310, 0320, 0330; false of `segment_gradient_check.R:48` and `minimal_network_check.R:45` | FINDING F1 |
| CLAUDE.md: tokens on `<schema>.log`, read over every row; log and log_recompute run ids differ in the proofs | `R/build_record.R`; settle logs `log_run_uid` 415_minimal vs `run_uid` 415_recompute_minimal | OK |
| CLAUDE.md: 0300 takes `SCHEMA`, `POLL_MIN`, writes both on every row | `0300:59`, settle logs | OK |
| CLAUDE.md: 0320 `MIN_WSG`/`FOLDS`, summaries record them, promote refuses others | code, tests | OK |
| CLAUDE.md: only BT rearing has four groups with both outcomes; smoke refuses CH rearing on three folds (separation) | dev logs (CH_rear groups_both=3), CH log `coef: rule 20.04 … (limit 5.0): FAIL` | OK |
| research/README row: 52.0 / 5.8 % full, 2.8 / 1.5 % minimal; placement, walks, outcomes, access unchanged; parent tunes identically | segment_gradient_check logs; minimal_network_check log; dev logs | OK |
| minimal_network_tuning.md, answer table (52.0/5.8 %, 298/458 m; 2.8/1.5 %, 742/742 m) | `20261102_segment_gradient_check-derived_zz415_*.txt` "by catch (stream branch)" | OK |
| "same 2,082 visits … walks and outcomes byte-identical … accessible km equal in every group" | minimal_network_check steps 1-3 (md5s equal; 0 rows differ) | OK |
| "parent gradient reads exactly the minimal gradient at all 2,082 visits"; BT rearing "byte-identical scores and curves" | step 4 (2082/2082); `BT_rear_tune.csv`, `_curves.csv`, `_groups.csv` md5 equal between `dev_zz415_minimal` and `dev_zz415_default/grad_parent` (summary and curve.rds differ only by provenance fields) | OK |
| Checks table: settle (three equal polls, run ids) | settle logs | OK |
| build record tokens | ledgers' `build_record` rows | OK |
| evidence: 2,082 placed, 43,625 elsewhere, 0.4 min cold, 5,724 cached | ledgers (`no_link_segment` 43625, `walk_cache_*`) | OK |
| placement: 36 of 227 columns, all segment/elevation/access/habitat | check log step 1 | OK |
| walks 40,068 rows, visits_species 22,902 | step 2 | OK |
| access: 141 pairs, all 1→2, none across zero | step 3 (63+38+7+26+1+1+5) | OK |
| parent: no straddle, 1,175 read another gradient | step 4 (670+505), ledger `parent_gradient_differs` 1175 | OK |
| tuning: nine species, BT rear fitted, region 87 vs 117, Atlas 20 % vs 25 %, 0.2 min for 18 keys | dev logs (region rows wrap: 176/2-1, 236/2-1) | OK |
| grading: CH three groups refused at 3/3 (coef 20.0 vs 5); BT graded 4.3 and 4.1 min, withheld | tune_run logs | OK |
| comparison: `default` regenerated equals stored km in every group, 0 km; 0.6 and 0.7 min | compare logs give totals (10392 / 10287 km = step 5 stored totals) and times; the per-group zeros are in the ignored `BT_rear_compare.csv` (`stored_vs_default_differ_km` 0 in all four groups, both runs), not in the cited log | OK (provenance note only) |
| stored habitat: CH 104/97/59/6 km, BT 5-49, ST 8-122, spawning under 10 | step 5 | OK |
| measured gradient: 1,178 visits, rho 0.696 both, CH 11 % flips 8.5 % (minimal) 8.7 % (full) | site_gradient_check logs (`.txt` minimal, `-2.txt` full) | OK |
| "round trip 1.0 ms" | logs 0.8-1.0 ms | OK (rounded) |
| flows 2026-10-15 vs published 2026-10-19 | ledgers; `data/tune/CH_rear_grades_record.csv` | OK |
| "How the runs are set up" bullets (tokens, evidence dir, settle, parent, floors, access per group) | code | OK |
| "a placed visit with no parent stops the build" | `R/parent_join.R:45` | OK (but see F3 for what the stop can see) |
| research/README, data-raw/README, scripts/README (0300, 0310, 0320, 0330 STAGE=maps, link >= 0.78.1) | code | OK |
| roxygen `knw_build_record` (run_uid from log_recompute; tokens over every log row; mixed refused) | code, test | OK |
| roxygen `knw_link_access_check(by_group)` | code, test | OK |
| roxygen `knw_parent_join`: "A placed visit whose segment has no parent row is an error: the parent table is not the full network's" | the check sees missing ids only; link's ids run 1..n per group | FINDING F3 |
| roxygen `knw_tune_promote` floors | code, tests | OK |
| `R/run_ledger.R` comments (`.knw_path_key` "without resolving links"; `.knw_path_rel` "so no home path is published") | true of the helpers; the helper is not called by two writers (F1) | OK / F1 |
| 0300 header and comments | code | OK |
| 0310 header (GATE, INPUT, OUTPUT, RUN) and comments at 81-86, 104-109, 121-122, 131-134, 148, 221-224, 277 | code | OK, except 121-122 "a test build never writes the default directory" (F2) |
| 0320 header (INPUT, DEV_DIR, parent, floors) and comments 107-119, 131, 136, 187-188, 370 | code | OK |
| 0330 header INPUT and comment 144-146 | code | OK |
| segment_gradient_check header (INPUT, OUTPUT, RUN) and comment 33-34 | code, `.knw_free_path()` | OK |
| minimal_network_check header (five checks, INPUT, OUTPUT, RUN) | code; rerun in copy | OK |

## Set C: guards added, their scope, escape hatches and remedies

| guard | claimed scope | escape hatches checked | remedy works | verdict |
|---|---|---|---|---|
| `knw_build_record()`: tokens mixed with NULL rows refused; two values refused | "not one build" | empty-string token -> refused as two values or errors on all-empty; no `log` table -> NA (pre-0.70) | none needed | OK (test fires) |
| `knw_parent_join()`: duplicate parent keys | one parent per segment | `%.0f` key; character/integer64 ids | n/a | OK (test fires) |
| `knw_parent_join()`: placed visit with no parent | "the parent table is not this network's" | a table from another build of the same groups: ids are 1..n per group (measured on all four `parent_<wsg>.csv.gz`), so it covers every id and joins silently | message diagnoses a case it cannot see | FINDING F3 |
| `knw_link_access_check()` `chk_flag(by_group)` | flag | NA refused (test) | n/a | OK |
| `.knw_evidence_tag()` base-name characters | ledger name safe | spaces, `-` refused | message says which characters | OK (test fires) |
| `.knw_evidence_ledger()` none / other directory of the same base name | a build's own ledger | pre-#120 plain ledger accepted only for the default; `..`/case variants refused (toward refusal) | "run EVIDENCE_DIR=… scripts/0310 first" | OK (tests fire) |
| `knw_tune_promote()` floors (main and `grad_fwa/`) | "a test run, never promoted" | column absent -> pass (pre-#120 by design); `grad_parent/` never moved; non-floor test builds pass (promotion is the operator's word) | n/a | OK (tests fire) |
| 0299 `access_check` without `watershed_group_code` | v3's description | arrow Table `names()` checked in a probe (fires on an old-shape CSV); stops before upload | "rerun scripts/0310" | OK |
| 0300 `POLL_MIN` positive, `SCHEMA` identifier | inputs | empty string, text -> refused | message | OK |
| 0310 `SETTLE` file missing | settle log | `~` expands | names the path | OK |
| 0310 default directory refused to `SETTLE=` or a non-`fresh_default` settle log (`:123`) | "a test build never writes the default directory" | keyed on `.knw_path_key()` of the string: `data/fdis/derived/../derived` -> tag `-derived`; on case-insensitive APFS `data/fdis/DERIVED` -> tag `-DERIVED` and `file.exists()` resolves it to `data/fdis/derived` (both shown in the copy); a symlink likewise | the stop's remedy is right when it fires | FINDING F2 |
| 0310 `PARENT_DIR` holds no parent files | parent present | upper-case file names -> none matched or missing visits -> refused | message | OK |
| 0320 `DEV_DIR` without `DEV=1`; outside `data/tune/dev[_<name>]` | ignored output | absolute path to this repo's `data/tune` accepted (still ignored); `..`/case refused (toward refusal) | message | OK |
| 0320 `MIN_WSG`/`FOLDS` integers >= 2 | inputs | NA, text refused | message | OK |
| 0320 `GRADIENT` column present | `parent_gradient` needs PARENT_DIR | `knw_tune_run()` refuses a missing column too | "(0310 joins it with PARENT_DIR)" | OK |
| 0330 summaries name more than one directory | one build | NA summaries omitted | none | OK |
| 0330 tables' md5 must equal the curves' `evidence_md5` | "held by md5, not by path" | curve without `evidence_md5` -> NA -> refused; `EVIDENCE_DIR=""` -> NA md5 -> refused; no fitted keys -> no check, nothing compared | "set EVIDENCE_DIR to a directory holding that build's tables" (reachable since round 3) | OK |
| minimal_network_check: `access_check.csv` without group column | step 3 | both builds checked | "rebuild with 0310 from #120" | OK |

## Findings

- **[severity: security]** `data-raw/segment_gradient_check.R:48`, `data-raw/minimal_network_check.R:45` — both write the
  raw `EVIDENCE_DIR` / `FULL_DIR` / `MIN_DIR` strings into their logs under `scripts/logs/habitat/`, which is tracked (not
  ignored; `20261102_*` copies are committed). Round 3 added `.knw_path_rel()` and applied it to 0310, 0320 and 0330
  only. Proved in the copy: `FULL_DIR=$PWD/data/fdis/derived_zz415_default` is accepted (the ledger finder compares by
  `.knw_path_key()`) and the first log line carries the absolute path verbatim; in the checkout that path is under the
  home directory. This contradicts CLAUDE.md:413-414 ("Paths written into ledgers, summaries and logs are relative to
  the repo root, or under `~`, never a home path") and the public discipline. Wrap both with `.knw_path_rel()` (the
  two other data-raw checks already use `home_rel()`).
  - **Rule:** `code-check.md`, "A fix lands in one of two callers that share a harness"; `feature-workflow.md`,
    "Public-repo text describes the package, and points nowhere private".
- **[severity: fragile]** `scripts/0310-evidence-build.R:123` (with `R/run_ledger.R` `.knw_evidence_tag()`) — the
  refusal that keeps a test build out of the default directory decides by the path string, not the directory. On this
  Mac's case-insensitive APFS, `EVIDENCE_DIR=data/fdis/DERIVED` gets tag `-DERIVED`, passes the refusal, and writes into
  `data/fdis/derived` (shown in the copy: tag `-DERIVED`, `file.exists("data/fdis/DERIVED")` TRUE resolving to
  `…/data/fdis/derived`); `data/fdis/derived/../derived` and a symlink to it do the same. The test tables then sit under
  the plain ledger of the provincial build, so a default 0320 reads them under the old ledger's run, whose schema check
  passes, and scores the test evidence as the province's (its md5s are logged but nothing compares them to the ledger).
  CLAUDE.md and the comment at 121-122 say this "never" happens. Compare directory identity instead, after
  `dir.create()`: `normalizePath(dir_out) == normalizePath(.knw_evidence_dir_default, mustWork = FALSE)` or
  `fs::file_info()` inode and device.
  - **Rule:** `code-check.md`, "A proxy is not the property"; "A guard's scope, escape hatches, and remedies".
- **[severity: fragile]** `R/parent_join.R:40-50` (called at `scripts/0310-evidence-build.R:229`) — the only identity
  check on a parent table is that every placed `(group, id_segment)` has a row, and the error says "the parent table
  is not this network's". link numbers segments 1..n per group (all four `parent_<wsg>.csv.gz` files, measured), so a
  parent table from any other build of the same groups (a rebuilt `zz415_default`, or later a link#444 export of a
  different run than `SCHEMA`) covers every id and joins silently with wrong `parent_gradient`, which
  `GRADIENT=parent_gradient` then tunes on; the ledger records the files' md5s but nothing ties them to the schema's
  run. A content check is available and holds exactly on the real data: `overlap_m + straddle_m` equals the visit's
  full `segment_length_m` on all 2,082 visits (max difference 2e-10 m); require `overlap_m` and refuse a mismatch.
  - **Rule:** `code-check.md`, "A proxy is not the property" (presence of an id is not provenance of the table).
