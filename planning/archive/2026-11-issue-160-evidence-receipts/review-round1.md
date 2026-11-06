# Code-check review, round 1 (#160 branch)

## Checklist read
- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of every H3 under `## Mechanisms` (14), skipping table rows; none of the 25 standalone/security/spreadsheet headings read in full.
- code-check-r.md: read "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising…", "`$` on a list partial-matches…", "Under `R CMD check`, tests run from a temp dir against the INSTALLED package", "Rscript reads a script as it runs…"; about 130 headings not read.
- code-check-shell.md: read "Paths"; about 100 headings not read.
- code-check-spatial.md: none read; the diff touches no spatial tool (about 110 headings).

Tests run (no database, no S3): test-evidence_receipt, test-receipt, test-grade_receipt, test-archive and test-publish. All pass: 25, 93, 47, 90 and 30 assertions, with no failures, errors or skips.

## Findings

- **[severity: bug]** scripts/0310-evidence-build.R:221-222, together with R/evidence_receipt.R `.knw_sha256_files()` (the manifest line `paste(sha, paths)`)
  The `link_configs` input is hashed from a manifest of **absolute** paths: `list.files(system.file("extdata/configs/default", package = "link"), full.names = TRUE)`. On this machine that path is `/Users/airvine/Library/R/arm64/4.5/library/link/...`, so the input's sha256 depends on the user's home directory, the R minor version, the architecture and whichever library link is installed in, as well as on the config bytes. I reproduced this in the scratchpad: the same config files copied to another directory gave `85e80534…` against `10a1eecc…`.
  Consequences:
  - Two machines, such as the #158 pair, or one machine after an R 4.5 to 4.6 upgrade, can build byte-identical evidence from identical link configs and still get a different evidence `recipe_id`. `crt_receipt_compare` then answers `different`, never `identical` or `equivalent`.
  - Every grade receipt names the evidence by that recipe_id (`.knw_receipt_evidence`), so every grade rebuilt on the other machine also compares `different`.
  - The helper's own comment ("the same files at the same paths give the same value") holds only for the relative `data/fiss_step2_*` paths it was also given.
  - #160's only comparison (`scripts/logs/habitat/evidence_receipt_160/20261106_evidence_receipt_compare.txt`) ran two builds on one machine, so it could not catch this.
  - Fix: hash the paths relative to the configs directory (`list.files(..., full.names = FALSE)` and read through `file.path(dir, rel)`), or key the manifest on paths relative to a root the caller passes.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check-shell.md "Paths"

- **[severity: fragile]** scripts/0320-tune-run.R:599-630 (keep-check, not changed on this branch), against R/receipt.R `.knw_receipt_evidence` and R/grade_receipt.R:99
  The branch changes what a grade receipt names as its evidence, from the visit tables' sha256 to the evidence receipt's `recipe_id`. That recipe includes knowledge's commit, link's configs and every other input. The keep-check that decides whether to keep a grade table and its receipt still holds the evidence only by `evidence_md5`, plus a receipt that names the record's `grades_md5`.
  - When 0310 is rerun into the same directory at another knowledge commit (or with any other recipe input moved), the visit tables come out byte-identical. #160's log shows this: three tables byte-identical. Every grade table is then kept, and its receipt still names the **previous** evidence recipe_id. Meanwhile 0310 has replaced `evidence_receipt.json` in the directory with the new recipe.
  - `knw_archive_plan()` then stores the new evidence receipt beside grade receipts that name a recipe_id the archive does not hold. Its evidence guard compares md5s only, and promotion checks only `grades_md5`.
  - So a grade receipt's `evidence` input can no longer be resolved to any stored evidence receipt.
  - A rebuild of that grade names the current recipe and compares `different` against the archived receipt, though the evidence bytes are the same.
  - The same applies to kept receipts written before #160 (the sha256 form), which the conventions accept, but this case arises on every evidence rebuild at a new commit.
  - Fix: in the keep-check, also require that the kept receipt's `recipe$inputs$evidence` equals what `.knw_receipt_evidence(evidence_dir, evidence_md5, ledger_path)` returns now; otherwise regrade. Alternatively, have the archive refuse grade receipts whose evidence recipe_id is not the stored evidence receipt's.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness" ; code-check.md "Written data outlives the fix"

## Triage (main session)
1. `link_configs` hashed absolute paths: real. `.knw_sha256_files(root =)` hashes paths relative to the root; 0310
   passes link's configs directory. Tested: the same files in two places hash the same.
2. A kept grade whose receipt names other evidence: real. 0320 reads the evidence input at the start
   (`.knw_receipt_evidence()`, which also refuses a stale receipt before any work) and regrades a kept table whose
   receipt names other evidence. Kept tables graded before #160 (three-table inputs) are therefore regraded once.
   The archive is left to compare md5s: refusing there would block archiving an earlier run after an evidence rebuild,
   and each grade receipt keeps `evidence_md5` in its context.
