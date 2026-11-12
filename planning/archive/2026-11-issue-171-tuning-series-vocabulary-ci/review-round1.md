# Code review, round 1: branch diff 89ee4d3a...HEAD (planning/ excluded)

## Checklist read
- code-check-python.md: index only. The diff touches no Python, so I did not read its full text.
- code-check-r.md (by heading): I used these headings from the index: "A `data-raw/` script must load the source tree, not the installed package", "Under `R CMD check`, tests run from a temp dir against the INSTALLED package", "A `skip_if_not()` skips only its own `test_that()` block", "Tests that silently do not run", "`identical()` on two reader results tests the reader, not the file", "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests" and "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent". I did not open the full text of these sections. The other ~110 headings were not read.
- code-check-shell.md and code-check-spatial.md: index headings only. None applied to this diff, which has no shell scripts beyond one `echo | tee` workflow line and no spatial code changes beyond label strings.
- code-check.md: I read the `## Mechanisms` prose of "A guard that fails toward pass" and "A fixture that cannot reach the failure mode" in full, and the index sentences of the other twelve mechanisms. I did not read the remaining mechanism prose (about 50 KB) or the "Rules that stand alone" sections.

## How I checked
These checks ran in a scratch worktree at HEAD, since removed. The repo itself was not modified.
- I ran `test-vignette-data.R`, `test-compare_map.R` and `test-settings-register.R` under `load_all`. All pass: no failures and no errors. The only skips are the data/stage checks for ignored files.
- I tested the new register test by changing values in `settings.csv`:
  - Changing `junk_year_min`'s value to 1951 makes the test fail, as it should.
  - Changing only its `note` leaves the test green, as intended.
- mapgl 0.4.6 `add_layers_control()` takes a named character vector and builds `layers_config` labels from the names, so `c(Habitat = "rules", Grade = "grade")` works.
- Cross-article anchors: every `tuning-method.html#…` link the other two articles use exists (`thresholds`, `steps`, `snap`, `se`, `lost`, `cuts`, `limits`).
- No tracked code, test or script outside `NEWS.md` history and `_pkgdown.yml` redirects still names `chinook_rearing.Rmd`, `habitat_thresholds.Rmd` or `stream_splits.Rmd`. The `code:` phrases in the register resolve in the renamed chinook article.
- The `settings.csv` `where` edits also change the bytes the grade, evidence and publish receipts hash (`.knw_receipt_config_files("settings")`). No code path refuses on a recipe difference, and the recipe already carries the commit, so this is not a finding.
- The `kirsch_etal2014Fishinventory` key exists in group library 9 (item 5LJMT4AX), so `vignette_bib.R` will find it.

## Findings

- **[severity: bug]** vignettes/tuning-chinook-rearing.Rmd:141-143. The new opening sentence states as established biology that young chinook "rear not only in the streams they hatched in: they also move into the lower reaches of small tributaries to large rivers [@kirsch_etal2014Fishinventory, p. 42]". The cited page does not say this at that strength.
  - Kirsch et al. 2014's printed page 42 (PDF page 50) is the report's **Recommendations**. The passage reads: "2. Based on prior AFFI findings, additional Chinook salmon rearing areas **may be found** in the lower reaches of small (less than 50 km2 upstream drainage) non-natal tributaries to large rivers … Small tributaries such as those described above **were not targeted** … during this project, but **may indeed provide** important rearing habitat."
  - So the page is a hedged recommendation for further sampling in Alaska's Susitna, Matanuska and Knik basins. It rests on earlier findings that the report does not present, and the study did not sample these streams.
  - The article turns it into a general statement of chinook life history and places it as the premise the BC records then "show the same" for. A reader would take the citation as evidence the source does not give.
  - Fix:
    - Either word the sentence to what the page says: for example, that a 2014 Alaska inventory recommended looking for chinook rearing in the lower reaches of small non-natal tributaries to large rivers, based on earlier findings.
    - Or cite the primary study behind "prior AFFI findings" (references.md, "Cite primary sources").
  - **Rule:** none

## Notes (not findings, for the caller)
- The `.bib` regeneration you deferred must also cover `tuning-stream-splits.Rmd`. It now cites `@wet` and `@norris_irvine2026NewGraphEnvironmentfwapg`, and neither is in `vignettes/tuning-stream-splits.bib`, so until the regeneration pandoc prints both with a "?".
  - `vignette_bib.R` will write them: `wet` through `bib_package()` (it is in `run_ver`), and the fork through `key_for()` (`required = FALSE`), at the fork commit.
  - `tuning-method.Rmd` cites nothing outside its `.bib`.
- The accepted decision that upstream fwapg carries no version is only in the **uncommitted** working-tree change to `data-raw/vignette_bib.R`. At HEAD the script still writes `version = short_sha(v$fwapg_sha)` for upstream fwapg. If the bibliographies are regenerated before that change is committed, or the branch is pushed without it, they get the old behaviour.
- `pkgdown/favicon/` is untracked, so a CI build will not have it.
