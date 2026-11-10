# Plan review — #170 (Plan agent, 2026-11-09)

Read-only review of `task_plan.md` against the code, spawned after the baseline. Findings as the agent reported them,
each with what was done.

## Blocker

- **B1. The restore refusal did not come before writing anything.** `knw_archive_pull` refused a target with another
  md5 inside its write loop, after the evidence rows ahead of it (the three visit tables) were already in. **Done:** a
  pass over every target before any fetch; pinned by "a restore refuses an fdis_sites.csv of other bytes before it
  writes anything (#136)", and red when the pass is removed.

## Gaps

- **G1.** `plan_of()` must pass `sites_dir`, or every test reads `tests/testthat/data/fdis/derived`. **Done** (it was
  already in the first test commit's working tree).
- **G2.** A new column on `.knw_archive_evidence_files` breaks the receipt row's `rbind`. **Done:** `from` is dropped
  once the sources are set; the receipt test passes.
- **G3.** Staged-copy commands need `SITES_DIR`: `0335`'s BUNDLES=FALSE message, `0336`'s RUN line,
  `scripts/README.md`. **Done.**
- **G4.** The five placement columns miss `flag_not_placed`, `ws50_checked` and `watershed_group_code`, which
  `vignette_method.R` reads. Measured: all 55 shared columns match as text except doubles' formatting, a Date and
  `blocks_absence_of` ("" vs NA). **Done:** every shared column is compared (Date as text, doubles elementwise to 1e-9,
  "" as NA). Accepted limit: the columns 0240 takes from `catch.rds` and the database are tied to nothing. An
  `integer64` column refuses rather than being misread.
- **G5.** `minimal_network_check.R` created its log before the ledgers were read and named the log only at the end.
  **Done:** created after the ledgers, its path printed at the start. Not done: logging errors outside step 3's
  refusal (the issue asks only that earlier steps survive).
- **G6.** The #142 skip does not cover a missing table. **Done:** `dbExistsTable` skips for `streams` and
  `streams_habitat_bt`; verified with a scratch copy naming a table that does not exist.

## Ordering

- **O1.** Run the sites check once, after the per-key loop. **Done** as planned.
- **O2.** The restore pass before any fetch. **Done** (B1).
- **O3.** A missing `fdis_sites.csv` should name 0240 and `SITES_DIR`. Not done: the message names the full path it
  looked for, which says where.

## Scope and acceptance

- **S2.** The hand-copied `fdis_sites.csv` in `data/fdis/derived_parent/` and `derived_minimal/` are no longer read.
  Left in place (ignored data on this machine; the owner's to delete).
- **Behaviour change:** `0335` plans the archive before moving, so a promotion now refuses a stale `fdis_sites.csv`.
  Stated in the PR body.
