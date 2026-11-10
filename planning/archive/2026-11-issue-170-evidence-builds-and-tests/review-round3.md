# Review round 3 — branch 170-backlog-move-1-evidence-builds-and-tests

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: prose of every H3 under `## Mechanisms` (14), tables skipped; Rules that stand alone not opened (none of their headings names a shape this diff uses).
- code-check-r.md: by heading, 7 read ("CSV whitespace: `trim_ws` and `strip.white`…", "`nzchar(NA)` is TRUE…", "`match()` treats NA as a matchable VALUE…", "A `skip_if_not()` skips only its own `test_that()` block", "`identical()` on two reader results tests the reader, not the file", "Under `R CMD check`, tests run from a temp dir…", "`read.delim()` quotes by default…"); 113 not read.
- code-check-shell.md, code-check-spatial.md: no heading names a tool or shape the diff uses; 0 read.

## The mechanism behind rounds 1 and 2

Both came from one assumption. The check and its callers treat 0240's defaults as describing one build, and they rebuild 0240's output contract from their own side instead of from what 0240 does. 0240 hardcodes `build <- "data/fdis/build"` and `derived <- "data/fdis/derived"` and writes with `readr::write_csv(na = "")` in UTF-8. Round 1 broke on the paths: a staged BUILD_DIR paired with the host's derived/. Round 2 broke on the bytes: the base reader read native while readr wrote UTF-8. Every place in this diff the assumption reaches:

| place | holds? |
|---|---|
| sites_dir paired with build_dir in 0336 | holds: a non-default BUILD_DIR now needs SITES_DIR |
| the same pairing in 0335 (lines 114, 147) | holds: both are fixed defaults |
| `knw_archive_plan()` called directly with its default `sites_dir` | holds as accepted: the content check fails closed |
| the refusal's remedy text ("rerun scripts/0240, or set SITES_DIR") | **does not hold**: finding 1 |
| encoding of the csv against the rds | holds after round 2 (UTF-8) |
| NA against "" | holds: readr with `na = ""` writes both as an empty field, and the check maps an rds "" to NA (re-measured) |
| a literal "NA" string | holds: it stays "NA" on both sides, because `na.strings = ""` (re-measured) |
| integer formatting | holds: `as.character(100000L)` is "100000" |
| Date and logical | hold: ISO text and TRUE/FALSE, as readr writes them |
| doubles | hold: tolerance branch |
| a POSIXct column | would refuse (fails closed); the real sites.rds has none: 11 character, 1 Date, 10 integer, 20 logical, 18 numeric |
| Inf in a double column | latent: `abs(x - Inf) <= 1e-9 * pmax(1, Inf)` is `Inf <= Inf`, so any finite csv value passes against an rds Inf; the real data has 0 infinite values in its 18 double columns, so it is not a current failure |
| the pull pre-check against the pull loop | holds: both take md5sum of `file.path(dest, source)` |

test-archive.R: 22 tests, 0 failed, 0 errors, 0 skipped, run in a detached worktree at HEAD.

## Findings

- **[severity: fragile]** R/archive.R:36-37 and R/archive.R:56-57. The sites check's remedy ("rerun scripts/0240, or set SITES_DIR to the table made from it") does not hold in two of the three places that can raise it:
  - **0336 with a staged BUILD_DIR/SITES_DIR.** This is exactly the case round 1's guard now sends here. 0240 hardcodes `build <- "data/fdis/build"` (0240:42) and `derived <- "data/fdis/derived"` (0240:154), so rerunning it never touches the staged table, and the check refuses again. It also connects to the database (0240:65) and rewrites three tracked files from the host's build: `data/fdis_evidence.csv`, `data/fdis_maturity_check.csv` and `data/fdis_summary_ch_bt.csv`. That is round 1's defect still living in the message text.
  - **0335.** It raises the same error from `knw_archive_plan()` at 0335:114 (before the move) and 0335:147, but never reads SITES_DIR, so the second remedy does nothing there.
  - **Fix:** name `scripts/0240` only when `f_rds` is `data/fdis/build/sites.rds`. Otherwise name SITES_DIR alone, which 0336 alone takes.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"
