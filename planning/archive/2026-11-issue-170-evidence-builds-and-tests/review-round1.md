# Code check, round 1: branch 170-backlog-move-1-evidence-builds-and-tests

## Checklist read

- code-check-python.md: in full (nothing in this diff is Python).
- code-check-r.md: by heading. Read 9: "A `skip_if_not()` skips only its own `test_that()` block"; "`$` on a list partial-matches, so a longer sibling key answers for a missing one"; "`nzchar(NA)` is TRUE — non-empty checks silently pass NA"; "`identical()` on two reader results tests the reader, not the file"; "Under `R CMD check`, tests run from a temp dir against the INSTALLED package"; "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests"; "`match()` treats NA as a matchable VALUE, so two unknowns join to each other"; "`as.integer("NaN")` is `0`, and `as.integer(NaN)` is `NA`"; "`read.delim()` quotes by default, so a `"` in a field silently swallows rows". The rest not read.
- code-check-shell.md: no heading touches this diff; 0 read.
- code-check-spatial.md: no heading touches this diff; 0 read.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped). Nothing else read.

## What I ran

- `tests/testthat/test-archive.R` in a detached worktree at HEAD (`NOT_CRAN=true`, `load_all()`): 22 blocks, 0 failed, 0 errors, 0 skipped.
- `cat(..., sep = "\n", append = TRUE)` in `minimal_network_check.R`'s `block()`: it ends the last line with a newline (bytes checked), so a later `say()` starts on its own line. Not a defect.
- `DBI::dbExistsTable(conn, Id(schema, table))` on RPostgres 1.4.10 reads `information_schema.tables`, which leaves out materialized views. link and fresh create `streams` and `streams_habitat_*` as tables (there is no `MATERIALIZED VIEW` in either repo's `R/`), so the new skip in `test-link_place.R` cannot skip a schema that has them. Not a defect.
- I could not reach the database from this machine (connection timeout), so the relkind check above comes from the source, not from the catalogue.

## Findings

- **[severity: fragile]** R/archive.R:34-35, 50 (`.knw_archive_sites_check`'s remedy), with scripts/0336-archive.R:51 (the `SITES_DIR` default)
  - Before this branch, a staged-copy archive (`TUNE_DIR=… COMPARE_DIR=… EVIDENCE_DIR=… BUILD_DIR=… Rscript scripts/0336-archive.R`, the form in the old RUN line and in scripts/README.md) read `fdis_sites.csv` from the staged `EVIDENCE_DIR`. Now it reads `data/fdis/derived/fdis_sites.csv` from the checkout unless `SITES_DIR` is also set.
  - CLAUDE.md describes the staged case as the one where the host's `data/fdis/derived` is another build's. Two things follow:
    1. **The guard's remedy is wrong in that case.** Where the host's table differs from the staged `BUILD_DIR/sites.rds`, the check stops with "rerun scripts/0240". But 0240 hard-codes `build <- "data/fdis/build"` and `derived <- "data/fdis/derived"` (0240:42, 0240:154). Rerunning it rewrites the host's table, plus the tracked `data/fdis_evidence.csv` and `data/fdis_summary_ch_bt.csv`, from the host's own build, not from `BUILD_DIR`. The archive then refuses again. The fix the operator actually needs, `SITES_DIR=<the staged derived/>`, appears in neither message.
    2. **Where the host's table passes the placement check, the archive silently takes the host's bytes.** That happens when it was built from the same `sites.rds` but differs in a column the check does not hold (the catch counts, `fwa_basin` from the database, or a 0240 rerun with another readr). The archive then stores the host's table in place of the run's, under a different `evidence_id` from the one an archive of the genuine copy gives. `knw_archive_pull()` refuses keys whose runs name two evidence builds ("the keys' runs name 2 evidence builds"), so keys of one run archived one way and the other cannot be restored together.
  - In the untagged default (`SITES_DIR == EVIDENCE_DIR == data/fdis/derived`) and in the tagged-`EVIDENCE_DIR` case with the default `BUILD_DIR`, the remedy is right and the ids do not move. The defect is limited to a non-default `BUILD_DIR` (a staged copy) with `SITES_DIR` left at its default.
  - Possible fixes:
    - name `SITES_DIR` in the refusal whenever `f_sites` is not under the `data/fdis/derived` that 0240 writes, or whenever `build_dir` is not `data/fdis/build`;
    - or, in 0336, refuse a non-default `BUILD_DIR` with `SITES_DIR` unset, rather than defaulting to the checkout's table.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ; code-check.md "A guard that fails toward pass"

Nothing else found. In particular:
- The MANIFEST's row order and names are unchanged by the `from` column (it is dropped before the md5s).
- The pull pre-check matches the old in-loop refusal file for file, now before any write. The record and the receipt rows it includes are present by construction.
- The column comparison handles every type the fixture and the real build carry: Date as text, logical, integer, double to 1e-9, `""` as NA, and integer64 refused.
- The `skip_if()` and `skip_if_not()` calls sit in the block whose assertions they gate.
