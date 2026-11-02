# Review round 5 (#120): terminating enumeration

Branch `120-tune-chinook-rearing-on-minimal-segments` at `e0f64ca`, diff `6b7c31d...HEAD`. Code was run in a copy
(`git archive HEAD`), never in the checkout; nothing here connects to a database. Started from round 4's tables, each
row re-verified against the current code, with what they missed added.

## Checklist read

- `code-check.md`, Mechanisms prose (tables skipped): "A guard that fails toward pass" (incl. "Defaults and
  normalisers", "Where the guard sits"), "A fixture that cannot reach the failure mode", "A proxy is not the property",
  "Verification that reads its own output", "A guard's scope, escape hatches, and remedies", "A fix lands in one of two
  callers that share a harness", "Restore the bug and prove the guard fires".
- `code-check-r.md` index lines for patterns the diff uses: "Read-back shape must match write-back shape", "A `data-raw/`
  script must load the source tree", "Postgres row order is never fixed", "An `information_schema` lookup by the literal
  table name", "testthat counts an uncaught error under `error`", "A `pkg::` call in a test … undeclared" (all test
  `::` calls are chk, DBI, RPostgres, stats, tibble, tools, utils, withr: declared). `code-check-shell.md` "A verification
  command can be shadowed by a shell function" (met: `diff` here is a git wrapper; used `/usr/bin/diff`).
- `feature-workflow.md` "Public-repo text describes the package, and points nowhere private".

Run in the copy (`NOT_CRAN=true`, `testthat::test_file()`): build_record 19 pass, link_access_check 9, parent_join 12,
run_ledger 23, tune_promote 133, settings-register 272, data-dir 1; 0 failed, 0 errors. `roxygen2::roxygenise()` in the
copy leaves `man/` and `NAMESPACE` byte-identical. `knw_parent_join()` example runs. `data-raw/minimal_network_check.R`
rerun in the copy with `FULL_DIR=<absolute path>` (builds symlinked read-only): first line carries
`data/fdis/derived_zz415_default` (relative), and lines 2 to the end of step 4 equal the committed
`20261102_minimal_network_check.txt`.

Probes (copy): R4 F2's sentinel (`is_default_dir`, 0310:102-107) evaluated for nine spellings; R4 F3's length guard
run on the real full build's 2,082 visits and link's four `parent_<wsg>.csv.gz` (real, another build's lengths with and
without `overlap_m`, NA visit lengths); 0320's `DEV_DIR` check on an absolute path.

## Set A: shapes changed or added, and every reader

| member | readers (grep of R/, scripts/, data-raw/, vignettes/, tests/, inst/) | verdict |
|---|---|---|
| plain ledger `<date>_evidence_build_ledger.csv` (default dir) | `knw_run_ledger()` fallback; `.knw_evidence_ledger()` `^[0-9]{8}_…\\.csv$`; `snap_limit_sensitivity.R:46`; 0325, 0330, `vignette_method.R` via `knw_run_ledger()`; `archive_seed.R`, `snap_candidate_check.R` name dated files | OK |
| tagged ledger `…_ledger-<base>.csv` | `.knw_evidence_ledger()` (0320, both checks); no `_ledger\\.csv$` pattern matches it; `knw_run_ledger()` reaches it only through a summary's `evidence_ledger` | OK |
| refused ledger `…_refused[-<base>].csv` | none; outside every ledger pattern | OK |
| ledger row `evidence_dir` (first row, `.knw_path_rel()`) | `.knw_evidence_ledger()` compares by `.knw_path_key()`; pre-#120 ledger (no row) taken as the default's | OK |
| ledger rows `settle_log`, `settle_override`, `settle_schema`, `schema_species`, `parent_dir`, `parent_joined`, `parent_straddle`, `parent_gradient_differs`; `access_disagree_<sp>` summed over groups | none outside 0310 (grep); kind `info` | OK |
| settle log `<date>_link_settle-<schema>.csv`; columns `schema`, `poll_min` | 0310 default list `_link_settle\\.csv$` excludes the tagged name; `SETTLE=` takes it; `st$schema` absent -> `fresh_default` | OK |
| `access_check.csv` + `watershed_group_code` | 0299 (guard), `minimal_network_check.R` step 3 (guard); no other reader | OK |
| `visits_link.csv` + `parent_id_segment`, `parent_gradient`, `parent_length_m`, `parent_straddle_m` | 0320 (`GRADIENT=parent_gradient`, column check); `minimal_network_check.R` step 4; 0290/0294/0296/0330 select by name. Step 1's `^parent_` exclusion also drops the pre-existing `parent_dist_m` (knw_link_flow), which is per FWA line and cannot differ between two placements on one Atlas line (all NA and equal in both builds, checked) | OK |
| summary columns `min_wsg`, `folds`, `evidence_dir` | `knw_tune_promote()` floors (main and `grad_fwa/`); 0330 `sum_dirs`; `knw_thresholds_table()`, `vignette_method.R` bind by name; `vignette_chinook.R` pins the promoted summary's md5 (moves only on promotion); 0322 writes its own grad_ext summaries, read by no publisher | OK |
| 0320 first log line | `vignette_chinook.R:91,:266`, `0322:106`: ledger path (relative, no space) still directly before " on link run" | OK |
| 0320 `Floors:` line, `-grad_parent` log suffix, `grad_parent/` | no positional reader; promote moves `grad_fwa/` only; 0330 and `knw_run_ledger()` list non-recursively | OK |
| `DEV_DIR` / `data/tune/dev_*/` | `.gitignore` `data/tune/dev_*/`; `dir_pub` from `grad_dirs` | OK (see F2 for what its log carries) |
| 0330 `Evidence %s (%s)…` line | no reader | OK |
| `<date>_segment_gradient_check[-<base>][-<n>].txt`, `<date>_minimal_network_check[-<n>].txt` | no reader; `.knw_free_path()` (rerun wrote `-2`) | OK |
| `knw_link_access_check(by_group =)` | 0310 only; `GROUP BY/ORDER BY 1, 2, 3` covers the full key | OK |
| `knw_build_record()` tokens from `<schema>.log` | `knw_grade_record_write()` (0320), `knw_archive_setup()`; link writes `token_*` on `log` only (link `R/lnk_log.R:1047`); tracked records are link 0.66.0, blank | OK |
| `knw_parent_join()` (export) | 0310; NAMESPACE, `_pkgdown.yml`, man page (regenerated identical) | OK (F1 for its guard) |
| env vars `EVIDENCE_DIR`, `SETTLE`, `PARENT_DIR`, `DEV_DIR`, `MIN_WSG`, `FOLDS`, `SCHEMA`/`POLL_MIN` (0300), `FULL_DIR`, `MIN_DIR`, `STORED` | each read only by the scripts that document it | OK |

## Set B: prose added or changed, and what it describes

| sentence / claim | source | verdict |
|---|---|---|
| CLAUDE.md: 0310 writes `EVIDENCE_DIR`, first ledger row names it, tagged name outside the fallback | 0310:85-97, `R/run_ledger.R` | OK |
| CLAUDE.md / 0310:121-122 / research: 0310 refuses the default directory to a build on another schema's log or `SETTLE=`, so a test build never becomes the default readers' build | 0310:133-137 now gates on `is_default_dir`, asked of the disk (probe: `DERIVED`, `derived/../derived`, a symlink and the absolute path all read as the default; `derived_x`, `derived/sub`, `data/fdis` do not) | OK (R4 F2 fixed) |
| CLAUDE.md: 0320 and `segment_gradient_check.R` take `EVIDENCE_DIR` and find the ledger by it; summary names `evidence_dir`, grade record does not | code | OK |
| CLAUDE.md: 0330 reads the summaries' directory or `EVIDENCE_DIR`, refuses tables whose md5s are not the curves' | 0330:144-158 | OK |
| CLAUDE.md:413-414: "Paths written into ledgers, summaries and logs are relative to the repo root, or under `~`, never a home path" | true of 0310, 0330 (TUNE_DIR is forced relative), both data-raw checks (rerun), 0320's ledger and evidence dir; false of 0320's DEV log with an absolute `DEV_DIR` | FINDING F2 |
| CLAUDE.md: tokens on `<schema>.log`, never `log_recompute`; `log` and `log_recompute` run ids differ in the proofs | link `R/lnk_log.R` (tokens inserted on `log` with its own `run_uid`); settle log `log_run_uid` vs `run_uid` | OK |
| CLAUDE.md / scripts README: 0300 `SCHEMA`, `POLL_MIN`, both on every row | 0300:27-36, settle logs | OK |
| CLAUDE.md / research: `MIN_WSG`/`FOLDS`, recorded, refused by promote; only BT rear four groups, CH smoke refusal | code, tests, dev and tune logs | OK |
| research/README row and `minimal_network_tuning.md` (answer table, setups, checks table, limits, "How the runs are set up") | unchanged since round 4, which checked each against its log; step 1-4 figures re-confirmed by the rerun above | OK |
| research: "a placed visit with no parent stops the build" | `R/parent_join.R:46-51` | OK |
| roxygen `knw_parent_join`: lengths checked "where `visits` carries `segment_length_m` and `parent` `overlap_m`" | `R/parent_join.R:55`; states the condition accurately | OK (the condition itself is F1) |
| roxygen `knw_build_record`, `knw_link_access_check(by_group)`, `knw_tune_promote` floors | code, tests | OK |
| `R/run_ledger.R` comments (`.knw_path_key` without resolving links; `.knw_path_rel` "so no home path is published") | helpers; `..` inside the repo root yields a relative `../…`, outside the home a non-home absolute path | OK |
| 0300 header/comments; 0310 header (GATE, INPUT, OUTPUT, RUN) and comments 81-86, 98-109, 119-122, 146-148, 235-238, 290 | code | OK |
| 0320 header (INPUT, DEV_DIR, parent, floors) and comments 107-119, 131, 136, 187-188, 370, 420-422 | code | OK |
| 0330 header INPUT and comment 144-146; scripts/README 0330 line (written under STAGE=maps, but the check runs before every STAGE branch, 0330:144 vs :379) | code | OK |
| `segment_gradient_check.R` header and comment 33-34; `minimal_network_check.R` header (five checks, INPUT, OUTPUT, RUN); data-raw/README | code; rerun | OK |

## Set C: guards added, their scope, escape hatches and remedies

| guard | claimed scope | escape hatches checked | remedy works | verdict |
|---|---|---|---|---|
| `knw_build_record()` mixed / two-valued tokens | "not one build" | empty log -> NA (as pre-0.70); `;` in a token would split (link's tokens have none) | n/a | OK (tests fire) |
| `knw_parent_join()` duplicate keys; missing parent | one parent per segment; table covers the network | `%.0f` key; character ids (test) | n/a | OK (tests fire) |
| `knw_parent_join()` length guard (R4 F3 fix) | "the parent table is another build's" | proven in the copy on the real 2,082 visits: real table passes; another build's lengths (`overlap_m` x 1.1) STOP; the same table without `overlap_m` PASSES; visits with NA `segment_length_m` PASS (`off %in% TRUE`); the ledger does not say whether the check ran | n/a | FINDING F1 |
| `.knw_evidence_tag()` base-name characters | ledger name safe | spaces, `-` refused | message | OK |
| `.knw_evidence_ledger()` none / other directory of one base name | a build's own ledger | spelling variants refused (toward refusal); only the newest tagged ledger is compared (toward refusal) | "run EVIDENCE_DIR=… scripts/0310 first" | OK |
| 0310 `is_default_dir` sentinel + "default by another name" stop (R4 F2 fix) | the default directory, whatever the spelling | probed: case, `..`, symlink, absolute -> TRUE; sub-, sibling and parent dirs -> FALSE; sentinel removed on exit (`on.exit` inside `local()` fires: 0 left); fresh clone without the default -> created, TRUE for the default only; unwritable dir -> FALSE, but then the build's own writes fail | "write it as data/fdis/derived" works | OK |
| 0310 default directory refused to `SETTLE=` or a non-`fresh_default` settle log | test build never in the default dir | now keyed on `is_default_dir`; `SCHEMA=` a test schema on fresh_default's log -> `knw_build_record()` refuses the run | message names `data/fdis/derived_<name>` | OK |
| 0310 `SETTLE` file missing; `PARENT_DIR` empty | inputs | `~` expands; upper-case names unmatched -> refused | messages | OK |
| 0299 `access_check` without `watershed_group_code` | v3's description | Arrow Table `names()` | "rerun scripts/0310" | OK |
| 0300 `POLL_MIN` positive, `SCHEMA` identifier | inputs | `""`, text -> NA -> refused | message | OK |
| 0320 `DEV_DIR` form and `DEV=1` pairing | ignored output | `..`/case refused (toward refusal); an absolute path into this repo's `data/tune` accepted (still ignored output, but see F2) | message | OK / F2 |
| 0320 `MIN_WSG`/`FOLDS` >= 2; `GRADIENT` column present | inputs | NA, text refused; `knw_tune_run()` refuses a missing column too | messages | OK |
| `knw_tune_promote()` floors (main, `grad_fwa/`) | a test run never promoted | column absent -> pass (pre-#120 by design); `grad_parent/` never moved | n/a | OK (tests fire) |
| 0330 summaries name one directory; tables' md5 = curves' `evidence_md5` | one build, held by content | missing file / `EVIDENCE_DIR=""` -> NA md5 -> refused; no fitted keys -> nothing compared, nothing to compare | "set EVIDENCE_DIR to a directory holding that build's tables" | OK |
| `minimal_network_check.R` step 3 group column | step 3 | both builds | "rebuild with 0310 from #120" | OK |
| Paths as proxies: every path written to a tracked file | `.knw_path_rel()` | 0310 (evidence_dir, settle_log, parent_dir), 0320 (evidence_dir; ledger path relative by construction), 0330 (TUNE_DIR forced relative; ledger and dirs from summaries), both data-raw checks (rerun with an absolute dir: relative) | n/a | OK except 0320's `dir_out` (F2) |

## Findings

- **[severity: fragile]** `R/parent_join.R:55-61` (called at `scripts/0310-evidence-build.R:243`) — round 4's fix for
  F3 runs the length check only when `parent` has an `overlap_m` column, and counts only `off %in% TRUE`, so a parent
  table carrying the required columns but no `overlap_m`, or visits whose `segment_length_m` is NA, joins with no
  identity check at all, and nothing in the ledger says the check was skipped. Proven in the copy on the full build's
  2,082 visits and link's four `parent_<wsg>.csv.gz`: a table with another build's lengths (`overlap_m` x 1.1) stops;
  the same table with `overlap_m` dropped passes; NA visit lengths pass. `check_names()` already requires the
  prototype's other columns, and the only parent format that exists carries `overlap_m` (link#444's proposed
  `streams_parent` carries neither `straddle_m` nor `wsg`, so it fails `check_names()` already and the reader will be
  revised with it). Require `overlap_m` (and `segment_length_m` on `visits`) in `check_names()`, and count NA as a
  mismatch (`!(off %in% FALSE)`), so the guard R4 asked for cannot drop out on a missing input.
  - **Rule:** `code-check.md`, "A guard that fails toward pass" (Defaults and normalisers: a fallback that fires when
    an input is missing); "A guard's scope, escape hatches, and remedies".
- **[severity: security]** `scripts/0320-tune-run.R:133-140` with `:191`, `:275-276`, `:434-436` — the `DEV_DIR` check
  compares `.knw_path_key(dirname(dev_dir))` with `data/tune`'s, so an absolute path into the repo's `data/tune`
  is accepted (probed in the copy: `DEV_DIR=$PWD/data/tune/dev_x` passes), and `dir_out` is then written raw into the
  DEV log ("DEV=1: outputs under <path>", "Smoke run first … outputs under <path>", "Pick report … written to <path>").
  In the checkout that path is under the home directory. This branch's own evidence copies DEV logs into the tracked
  `scripts/logs/habitat/minimal_network_120/`, so the home path would be published; it contradicts CLAUDE.md:413-414
  ("Paths written into ledgers, summaries and logs are relative to the repo root, or under `~`, never a home path").
  Round 3 wrapped 0320's `evidence_dir` with `.knw_path_rel()` but not `dev_dir`. Set `dev_dir <- .knw_path_rel(dev_dir)`
  after the check, which makes `dir_run`, `dir_out` and every log line relative.
  - **Rule:** `code-check.md`, "A fix lands in one of two callers that share a harness"; `feature-workflow.md`,
    "Public-repo text describes the package, and points nowhere private".
