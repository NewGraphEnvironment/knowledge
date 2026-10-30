# Code-check round 2 (#119): branch diff, with round 1's fixes (03ee246) read hardest

## Checklist read

- code-check.md: index in full; the prose of all 14 H3s under `## Mechanisms` in full (table rows skipped).
  "Rules that stand alone", Security and Spreadsheets sections: index lines only (none names a shape this diff uses
  beyond those already covered by the mechanisms).
- code-check-r.md: index in full (115 headings). Full sections read (16): `system2(stdout = TRUE)` warns...;
  `tryCatch()` nests its handlers...; `on.exit()` at a script's top level...; Read-back shape...; CSV whitespace...;
  `$` on a list partial-matches...; A `data-raw/` script must load the source tree...; Under `R CMD check`, tests
  run from a temp dir...; Rscript reads a script as it runs...; A `function(...)` mock hides arguments...;
  `tryCatch(warning = )` DISCARDS...; `identical()` on two reader results...; Postgres row order...; An
  `information_schema` lookup by the literal table name...; A `pkg::` call in a test...; `tempfile()` lives in the
  session tempdir.... Not read in full: 99.
- code-check-shell.md: index in full (70 headings). Full sections read (3): `aws s3 cp` cannot tell a missing key
  from a missing bucket; An S3 multipart ETag depends on the uploader's part size...; A value validated with one
  numeric grammar.... Not read in full: 67.
- code-check-spatial.md: index in full (93 headings); no section read in full (the diff has no spatial code:
  R/site_gradient.R is plain data-frame arithmetic). Not read in full: 93.
- code-check-python.md: in full.

Probes: test-archive.R, test-grade_record.R and test-tune_promote.R copied to a temp dir and run against
`pkgload::load_all()` of the repo: 0 failed, 0 errors (46, 30, 126 passed). Finding 1 reproduced with the file's own
`mock_bucket()`/`run_fx()` in a temp dir (script below).

## Findings

- **[bug]** R/archive.R:464-475 (`knw_archive_undo`, round 1 fix 2) — an object whose current version already
  carries the indexed md5 is skipped (`next`) and nothing is recorded, so after an undo that failed partway — the case
  0335:126-130 handles by telling the operator to rerun `knw_archive_undo()` — the objects the failed attempt had
  already copied back are current, but the index's last `archived` row for them still names the ORIGINAL version,
  which became noncurrent when the undone run overwrote the folder and which the bucket's 180-day noncurrent
  lifecycle then deletes. `knw_archive_pull()` restores by that version id and fails once it has expired, although
  the bytes are still the current version. The rows are appended only at the end (line 479), so any failure between
  the first copy and the append (a network error, credentials expiring, the index write) leaves this state.
  Reproduced: two tokened runs promoted into one setup, undo with the 2nd `copy-object` failing, then the rerun
  succeeds: the grade table's index row says `v001`, the current version is `v016` (the copy); after dropping
  noncurrent versions (the lifecycle), `knw_archive_pull(grades = TRUE)` errors on the missing version. Fix: when the
  current md5 matches, read the current `VersionId` too (`--query "[Metadata.md5, VersionId]"`, as `knw_archive_put`
  does) and append an `archived` row whenever it is not the indexed one; or append each copy's row as it is made.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[fragile]** scripts/0320-tune-run.R:275 (round 1 fix 3, one axis over) — the pass-start clear now keeps
  `_grades_record.csv`, but the other delete of a key's grades, `unlink(<k>_grades.csv)` for a key this pass did not
  fit (curve NULL: `curve_failed`, or a no-fit status such as `too_few_groups`, which can change when a run directory is
  re-passed on another evidence build), still deletes the table alone, so the run keeps an orphan record of a table
  that no longer exists. 0335's archive pre-check lists keys by record (`archive_keys()`, 0335:89-92, run on the
  candidate at 0335:100 before `knw_tune_promote()`), so `knw_archive_plan()` stops with "<key>: the run lacks
  .../<key>_grades.csv": a whole-run promotion whose key is no-fit by design (which `knw_tune_promote()` would
  promote, moving only its summary and curve) is refused, and a `curve_failed` key gets that message instead of
  `knw_tune_promote()`'s "the run did not fit it; rerun it, or promote without it". `RUN=<run> 0336` refuses the same
  way. Line 275 should unlink the record with the table.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness"

- **[fragile]** scripts/0335-promote.R:132-134 (round 1 fix 4) — the remedy for a BUNDLES=FALSE promotion moved
  unarchived says "Where the evidence is, run KEYS=… PROMOTED=TRUE Rscript scripts/0336-archive.R". 0336 archives
  `data/tune`'s grade tables, curves and segments, which are ignored and exist only on the machine that just
  promoted them; on another machine that holds the evidence the command stops with "the run lacks
  data/tune/<key>_grades.csv". The command that works is on this machine with the evidence copied or staged
  (`EVIDENCE_DIR=… BUILD_DIR=…`, which 0336 takes), and until it is run the promoted grade tables have no copy
  anywhere else.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[fragile]** scripts/0335-promote.R:99, 125-131 with R/archive.R:466-471 (round 1 fix 2) — an undo now calls the
  bucket (`head-object` per object, `copy-object` where needed), but the archive pre-check skips undos
  (`!undo && archive_now`) and the header still says "An undo sends nothing" (0335:27-28). On a machine without bucket
  credentials the tables are moved back first and the index update fails after, leaving the index naming the undone
  run as published (so `.knw_archive_published()` guards the wrong run) until the rerun is done; the forward path is
  refused before anything moves for the same condition. A `get-bucket-versioning` probe before the move when
  `undo` and `archive_keys(file.path("data/tune/candidate", run))` is non-empty would close it.
  - **Rule:** code-check.md "A guard that fails toward pass"

- **[fragile]** scripts/0320-tune-run.R:413-414 — the record's `knowledge_commit` is read when grading starts, after
  the scoring (the code ran from the `load_all()` at the script's start), so a commit made during the run names a
  later commit than the code that ran; and `git status --porcelain -- R scripts inst` counts untracked files, so the
  evidence ledger 0310 has just written to `scripts/logs/habitat/` (tracked directory, not ignored) marks a clean
  tree `+dirty` on the usual 0310 → 0320 sequence. Nothing reads the field today, so it is a wrong provenance stamp,
  not a failure; capture both at the script's start and pass `--untracked-files=no` (as 0299 does).
  - **Rule:** code-check.md "A guard that fails toward pass" (its "Provenance, and repair" paragraph)

- **[fragile]** R/archive.R:110-120 (`knw_archive_plan`) — the evidence build is named by a MANIFEST over six files,
  but only the three visit tables are held to the grades (`evidence_md5`); `fdis_sites.csv`, `reconcile.csv` and
  `sites.rds` are taken from whatever `evidence_dir`/`build_dir` hold. 0336 takes `EVIDENCE_DIR` and `BUILD_DIR`
  separately, and CLAUDE.md records a host whose own `data/fdis/` is an older build than the promoted run, so staging
  the derived tables and leaving `BUILD_DIR` at the default archives a mixed build under a fresh evidence id, and every
  later restore delivers it as the run's evidence (the methodology bundle's md5 pins catch it only where they are
  checked). Holding the build files to something the run recorded (the ledger, or the method bundle's pins) would
  close it.
  - **Rule:** code-check.md "A proxy is not the property"

## Probe for finding 1

Run from a temp dir holding the first 83 lines of tests/testthat/test-archive.R as helpers.R:

```r
pkgload::load_all("/Users/airvine/Projects/repo/knowledge", quiet = TRUE)
library(testthat); source("helpers.R")
test_that("probe", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  idx <- file.path(root, "index.csv"); b <- mock_bucket()
  x <- run_fx(root, run = "20261101_0000", tokens = tok); knw_archive_put(plan_of(x), idx, promoted = TRUE)
  x <- run_fx(root, run = "20261102_0000", tokens = tok, grade = 0.2); knw_archive_put(plan_of(x), idx, promoted = TRUE)
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  real <- .knw_aws; n <- 0
  local_mocked_bindings(.knw_aws = function(a) { if (a[2] == "copy-object") { n <<- n + 1; if (n == 2) stop("network") }; real(a) })
  try(knw_archive_undo("CH_rear", x$tune, idx))
  local_mocked_bindings(.knw_aws = real)
  knw_archive_undo("CH_rear", x$tune, idx)        # the rerun 0335 asks for
  # index: grades.csv.zst -> v001; current version v016
  for (o in names(b$objects)) b$objects[[o]] <- utils::tail(b$objects[[o]], 1)   # lifecycle expiry
  # knw_archive_pull("CH_rear", dest, grades = TRUE, index = idx) -> error: version v001 not found
})
```
