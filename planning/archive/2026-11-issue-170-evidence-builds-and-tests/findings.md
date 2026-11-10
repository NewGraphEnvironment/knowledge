# Findings — Backlog move 1: evidence builds and tests (#170)

## Issue context

**If we do it:** a build under a tagged `EVIDENCE_DIR` archives and checks with the default build's commands, and a full test run against an empty or partial `fresh_default` reads as untested rather than broken. **If we never do:** every run on another schema needs `fdis_sites.csv` copied in by hand (met on 2026-11-03 and again on 2026-11-05), and every test run on such a database reports an error unrelated to the code.

### Batch 1. Evidence-build and test fixes
- **Why here:** both bite every run off the published build, and #136 has recurred since it was filed. One test-suite run and one live check on the database's host verify both.
- **Touches:** `R/archive.R`, `scripts/0336-archive.R`, `data-raw/minimal_network_check.R`, `tests/testthat/test-link_place.R`.
- **Decided (Al, 2026-11-09):** the archive reads `fdis_sites.csv` from where `0240` writes it (`data/fdis/derived`), listed with `0230`'s `sites.rds` and `reconcile.csv` in `R/archive.R`'s `.knw_archive_evidence_files`, never from a tagged `EVIDENCE_DIR`; `0310` does not copy it. Why: the file is built from `sites.rds` and depends on no link schema (every tagged build's ledger records the same 51,587 sites); the archive already reads `0230`'s files from their own directory and checks `sites.rds` against the run's ledger; and a copy in each tagged directory would go stale whenever `0230` or `0240` rerun. Archived evidence ids do not move, since the archive keys files by name and md5. Owed with it: before archiving, hold `fdis_sites.csv` to the ledger's `sites.rds` (one row per site, placement columns equal: the check `data-raw/vignette_method.R` makes at lines 262-269), because nothing ties the file to the build today; and a restore refuses to overwrite a different `fdis_sites.csv` already in `data/fdis/derived`.

| issue | title |
|---|---|
| #136 | A tagged EVIDENCE_DIR is a second-class evidence build |
| #142 | Live placement test errors when fresh_default holds no BULK BT rearing segment |


---

Backlog: `planning/backlog.md`, move 1. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.







## Member issues

### #136

**If we do it:** a build under a tagged `EVIDENCE_DIR` (`0310`'s path for a test or second schema, #120) can be archived and checked with the same commands as the default build, and a check that stops early still leaves what it measured. **If we never do:** every run on another schema needs a hand-copied file before `0336` accepts it, and `minimal_network_check.R` loses its placement and walk results whenever a later step refuses.

Found by #120's plan review (branch `120-minimal-network-province`, `planning/active/review-plan.md`), each verified in the code:

- `scripts/0336-archive.R` defaults `EVIDENCE_DIR` to `data/fdis/derived` and `R/archive.R` lists `fdis_sites.csv` as part of an evidence build, but only `0240` writes that file, into the default directory; `0310` never writes it to a tagged `EVIDENCE_DIR`. Archiving a candidate scored on `data/fdis/derived_<name>` therefore needs `EVIDENCE_DIR=` on the command and a copy of `fdis_sites.csv` beside the build. 
  **Decided (Al, 2026-11-09):** the archive reads `fdis_sites.csv` from where `0240` writes it (`data/fdis/derived`), listed with `0230`'s `sites.rds` and `reconcile.csv` in `R/archive.R`'s `.knw_archive_evidence_files`, never from a tagged `EVIDENCE_DIR`; `0310` does not copy it. Why: the file is built from `sites.rds` and depends on no link schema (every tagged build's ledger records the same 51,587 sites); the archive already reads `0230`'s files from their own directory and checks `sites.rds` against the run's ledger; and a copy in each tagged directory would go stale whenever `0230` or `0240` rerun. Archived evidence ids do not move, since the archive keys files by name and md5. Owed with it: before archiving, hold `fdis_sites.csv` to the ledger's `sites.rds` (one row per site, placement columns equal: the check `data-raw/vignette_method.R` makes at lines 262-269), because nothing ties the file to the build today; and a restore refuses to overwrite a different `fdis_sites.csv` already in `data/fdis/derived`.
- `data-raw/minimal_network_check.R` stops at step 3 when either `access_check.csv` lacks `watershed_group_code` (the published build's, from 2026-10-27, predates the per-group columns) and writes its log only at the end, so steps 1 and 2 (placement, walks) leave nothing on disk. Write the log incrementally, or state each step's result as it completes.

Relates to #120, #119.



Met again on 2026-11-05: archiving #120's parent-gradient setup from `data/fdis/derived_parent` needed `fdis_sites.csv` copied in by hand, as the minimal build had (PR #150).




### #142

**If done:** `test-link_place.R`'s live test skips, with a reason, on a database whose `fresh_default` holds no BULK bull trout rearing segment, instead of erroring. **If never:** every full test run against such a database reports an error that says nothing about the code under test.

## Problem

`tests/testthat/test-link_place.R:32` ("placement runs against a live schema and re-gates the habitat flags on access") guards only on the schema existing (`skip_if_no_pg("fresh_default")`), then queries one BULK segment with `streams_habitat_bt.rearing`. When the schema exists but that query returns no row (a `fresh_default` rebuilt with other groups, or one whose BT habitat is empty), `data.frame()` at line 39 fails with `arguments imply differing number of rows: 1, 0`.

Measured 2026-11-04: errors the same way on `origin/main` (7d6712e) and on #141's branch, under `devtools::test()` and alone.

Measured again 2026-11-05 (during #124's validation): the cause there was a `fresh_default` empty in every group, not one missing BULK. `streams` and `streams_habitat_bt` held 0 rows; their statistics showed about 2.65 million and 1.78 million rows inserted and the same numbers deleted, last auto-analyzed 2026-11-03 19:22 UTC, with only the `log_*` tables populated and the dated builds (`fresh_default_20261023`, 11.4 million segments) intact. So the skip should name an empty schema as well as a missing group, and any reader of `fresh_default` (`0310`, `0320`/`0330` without `SCHEMA`) meets the same empty build.

## Proposed

- [ ] Skip with the reason when the query returns no row (`skip_if(nrow(one) == 0, "...")`), so an empty schema reads as untested, not as broken.




## Measured while planning (2026-11-09)

- `sites.rds` (md5 39f751b1…) and `data/fdis/derived/fdis_sites.csv`: 51,587 sites each, no duplicate `site_visit`, same set; `flag_far_snap`, `flag_ws50_mismatch`, `snap_confirmed`, `snap_moved` (logical) and `blue_line_key` (integer) identical as `utils::read.csv(colClasses = "character", na.strings = "")` vs `as.character()`.
- Every archived evidence build in `data/archive_index.csv` stores `fdis_sites.csv` with md5 `2de46c60774f987f1f11a46bcfa1835e`, which `derived/`, `derived_parent/` and `derived_minimal/` all hold; `derived_default_20261103/` has none.
- `knw_archive_pull()` already refuses any evidence target present with another md5.

## Errors Encountered

| Error | Resolution |
|-------|------------|
