# Review round 3: branch 176-backlog-move-7-fiss-workbooks-a-tested-p (base 8535ae0f, HEAD b75e69a4)

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check-r.md, by heading: read "Regenerated binaries churn git even when nothing changed", "A `data-raw/` script must load the source tree, not the installed package", "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires", "`ifelse()` with an all-NA test returns a logical vector, whatever `yes` and `no` are", "Under `R CMD check`, tests run from a temp dir against the INSTALLED package", "`.Rbuildignore` has no comment syntax — every line is a live regex" (6 read; the others not read, their tools absent from the diff or covered by rounds 1 and 2).
- code-check-shell.md, by heading: none read (no shell code in the diff; the one shell-out is `system2(soffice, ...)`); all not read.
- code-check-spatial.md, by heading: none read (no spatial code changed); all not read.
- code-check.md: the prose of every H3 under `## Mechanisms` (14), "A guard that fails toward pass", "Written data outlives the fix" and "Verification that reads its own output" at length; none under "Rules that stand alone".

## The mechanism behind rounds 1 and 2

Both findings came from trusting what a step does when it is not told: a default nobody chose decided the outcome. In round 1 a reconcile row's `pass = TRUE` and the NA-is-pass branch let the check pass whatever the data held. In round 2 openxlsx's default creator (the session login) and LibreOffice's profile author put a machine identity into tracked files. The assumption they share: text and verdicts the author did not write are not in the artifact. So this round lists every tracked artifact the branch writes, including the review records, and every check it adds or relies on, and asks of each what it holds or does by default.

## Findings

- **[severity: security]** planning/active/review-round2.md:24 (committed in b75e69a4) — The round-2 record quotes the login it reports: the fixtures' `<dc:creator>` value and the `git grep -c` command, both in plain ASCII. The branch was rewritten so that no commit holds the old fixtures. This tracked file then puts the same login back into the tree and the history, in a form a plain grep finds. The #56 sweep (`planning/archive/2026-10-issue-56-public-flip/public_sweep.py tree`, run read-only on HEAD) reports it as the tree's only `local_path` hit outside the generated CLAUDE.md conventions: `local_path planning/active/review-round2.md:24`. `planning/active/` is held to exactly that class (`PARTIAL`), so the sweep fails on this branch. The rest of the branch adds no hit (the DESCRIPTION and CLAUDE.md hits predate it). Fix: reword line 24 to "the session login" (with the `git grep` written as `git grep -c "$USER"` or dropped). The branch is unpushed, so rewrite b75e69a4, or fold the fix into it, so that no commit holds the string. Then rerun the sweep's `tree` mode and `git log -p 8535ae0f..HEAD | grep -c <login>` (expect 0) before the push. This file avoids the string for the same reason.
  - **Rule:** none (CLAUDE.md, "One discipline: everything here is public"; the #56 sweep's `local_path` class)

## Checked, not findings

Tracked artifacts the branch writes, checked for a login, home path, temp path, host or machine name:
- `inst/testdata/fiss/*.xlsx` (2): `docProps/core.xml` creator and lastModifiedBy are `knowledge`, and `app.xml` says only `Microsoft Excel`. The four `printerSettings*.bin` parts are one fixed openxlsx blob (one md5) with no UTF-16 or ASCII strings.
- `inst/testdata/fiss/*.xls` (4): their ASCII runs (len >= 4) and UTF-16LE runs hold only the sheet text, `Calc`, `Microsoft Excel 97-Tabelle`, `Biff8`, `knowledge` twice, and OLE stream names. No `LibreOffice`, OS or arch string, temp path, profile path or `file:` URL.
- Every commit in `git rev-list --all -- inst/testdata/fiss`: each `.xlsx` creator, read from the unzipped `core.xml`, is `knowledge`. A byte search for the login in ASCII and UTF-16 across every `.xls` revision found none, so the history rewrite holds.
- `data/pine/fiss_xls_{fetch_log,parse_log}.csv`: `path` and `parse_path` are repo-relative (`data/pine/fiss_xls/...`). `knw_fiss_parse_step()` writes `path` as it is given, and 0220 gives it `flog$parse_path`.
- `data/pine/fiss_xls_reconcile.csv`, `data/fiss_evidence_reconcile.csv`, `data/fiss_evidence.csv`, `scripts/logs/fiss/20261120_*.log`: no absolute, temp or home path and no host. `enumerate_db_source`/`clip_polygon_source` (`tunnel`, `fwapg`) are the accepted pre-branch rows.
- `man/knw_fiss_*.Rd`, `scripts/README.md`, the CLAUDE.md section, `research/bt_spawning.md`: no machine content. Commit authors and messages on the branch: none.
- `data/pine/fiss_sites_pine.gpkg` is tracked, and the refetch log says 0220 rewrote it, yet it is not in the diff: it was left at its committed bytes. Its CSV twin is byte-unchanged, so nothing is lost.

Checks the branch adds or relies on, read for whether each can fail on the case it names:
- `site_gradient_raw_above_1_set_na`: `chk()` default `0L == sum(..., na.rm = TRUE)` cannot be NA and fails on any value above 1. Measured today: across the five groups' `fiss_sites_*_all.csv`, 469 gradients are non-blank, none fails `as.numeric()`, none is negative, and the maximum is 0.43.
- `site_gradient_vs_fwa_median_ratio`: the ratio is taken on raw x100 before the NA rule, so it holds when grad_n >= 5. NA under 5 sites is accepted.
- `gradient_pct` readers: `knw_fiss_visits()` (R/fiss_visits.R) never names a gradient, 0310 only hashes the file, and `knw_site_gradient_visits()` divides `visits_link`'s FDIS `gradient_pct`, not the FISS table's. The x100 reaches only 0293's printed block.
- 0220's `parse_log_rows_vs_steps_per_workbook` and `fetch_parseable_vs_parse_log_workbooks` now take `n_steps` from `knw_fiss_columns()$step_pattern` (4). The keyed fetch log's `<report>_<idx>__` names keep `parse_path` unique per row, so neither row can fire on a filename collision. The PINE run reads 308 = 4 x 77 and 77 = 77.
- `knw_fiss_nfc()`'s zero-catch selection `codes$catch_class %in% "zero_catch"` picks the same codes as the old `filter(catch_class == "zero_catch")`, NA classes included, and it stops when there are none.
- Tests: `test-fiss_parse.R` and `test-fiss_nfc.R` under `load_all()`, `NOT_CRAN=true`: 0 failed, 0 errors (57 and 21 passes). No `inst/testdata/fiss` file matches `.Rbuildignore`, so the fixtures reach the installed package for R CMD check. `pkgdown::check_pkgdown()`: no problems. `.data` is imported (`importFrom(rlang,.data)`). `readxl`, `janitor`, `stringr`, `tibble` and `chk` are in Imports, and `withr` is in Suggests.
