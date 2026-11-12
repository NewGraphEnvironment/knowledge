# Branch review, round 2 (#165)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check-r.md: by heading. Read: "A `data-raw/` script must load the source tree, not the installed package", "`tolerance` in testthat is RELATIVE, so it pins a published figure far more loosely than it looks", "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a presence check can each depend on it". The other headings name tools or shapes this diff does not use, so I did not read them.
- code-check-shell.md: no heading names a tool or shape this diff uses (there is no shell in it), so I read none.
- code-check-spatial.md: no heading applies (no spatial code), so I read none.
- code-check.md: the prose of every H3 under `## Mechanisms`, skipping the `|` table rows and the evidence blocks. I read in full "A guard that fails toward pass", "A proxy is not the property", "Verification that reads its own output", "A guard's scope, escape hatches, and remedies", "Written data outlives the fix", "Serialization loses meaning silently" and "One fact derived twice", and skimmed the rest. I read none of the headings under "Rules that stand alone".

## Findings

- **[severity: bug]** inst/receipt/thresholds.yaml:2-5; research/run_archive.md:113-114 ("The thresholds set stays exact on #158's evidence (every key's tuning tables identical ...)"); research/database_builds.md:259-260 ("One new difference surfaced, in bytes only"). The claim that thresholds can stay exact does not hold across databases, and the evidence given for it does not support it.
  - **The tables carry provenance columns.** "Every value in them is a pick or a count" is false. `data/thresholds.csv` carries `evidence_md5`, `link_sha`, `link_run_uid`, `evidence_version` and `config`. `knw_publish()` fingerprints the whole CSV (`R/publish.R:192-206`, through `.knw_receipt_csv_tables()`), and the declaration drops no column.
  - **`evidence_md5` changes on the other database.** Its first md5 is `visits_link.csv`'s. This branch measured that md5 as different on the two databases: `389942d4…` on the host, `ea6514ce…` on the second (`receipt_165/20261112_tune_run-*.txt`). The cause is #197's column order. The same column is why the grade tables "differ only in `evidence_md5`" (run_archive.md:101) and why the summaries' context differs (`20261112_database_compare-tune.csv`).
  - **So the table's fingerprint reads `different`.** A thresholds set rebuilt from a run on the other database carries a different `evidence_md5` cell, and that alone is enough.
  - **The recipe differs too, for both published sets.** `scripts/0325-publish.R:139-145` (`recipe_of()`) names the evidence by that same md5 string (`evidence = list(version_id = evidence)`), not by the evidence receipt's `recipe_id` as a grade receipt does. So both the thresholds receipt and the habitat_grade receipt get another `recipe_id` on the other database, and crate reads "another recipe" as `different` (`crt_receipt_compare.R`, the doc line for `different`). That happens before habitat_grade's newly widened 1e-2 band on the totals is ever consulted.
  - **#158's own data does not support it either.** In #158, `mad_pick` moved on 3 visits, so `visits_link`'s md5 (and with it `evidence_md5`) differed there too. Its tune comparison also read every smoke table and the pick report `different` (`database_second/20261106_database_compare-tune.csv`), so "every key's tuning tables identical" is wider than the table the claim cites ("tuning scores, fold seeds, nested selection, curves, groups").
  - **"In bytes only" is too narrow.** database_builds.md says #197's difference is "in bytes only". It also moves every downstream `evidence_md5` and, through `recipe_of()`, the published sets' recipe ids.
  - **Why it matters.** A provenance declaration states a verdict ("so exact holds") that a cross-database rebuild of the thresholds set will contradict, and nothing has measured that verdict. Either say that the thresholds and habitat_grade receipts read `different` across databases until #197 is fixed and while 0325 names the evidence by md5, or make `recipe_of()` name the evidence by the evidence build's receipt `recipe_id` and drop or `record` the provenance columns from the thresholds fingerprint.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** research/run_archive.md:114-116. The evidence section opens: "The two measured rebuilds moved `access_check`'s km by 9.5e-11 and 6.0e-11 km per value (#158's second database)". Round 1's fix edited this line and left its count and numbers as they were. The same section goes on to record #160's pair at 1.0e-10 (line 121, which matches `evidence_receipt_160/20261106_evidence_receipt_compare.txt`: 1.018634e-10) and #165's at 5.3e-11. So there are at least four measured rebuilds, not two, and the largest move is 1.0e-10, not 9.5e-11. `inst/receipt/evidence.yaml` (rewritten on this branch) now lists #160, #158 and #165 and no longer mentions the 9.5e-11 rebuild. The two files therefore give different rebuild sets for the one rule.
  - **Rule:** none

No defects found in the data-raw scripts:
- `grade_order_bound.R`, `grade_receipt_compare.R` and `grade_tolerance_try.R` are read-only.
- Their bound n·eps·Σ|x| is conservative: it is above (n−1)·eps·Σ|x|, which bounds the difference between any two summation orders.
- `km_graded` and `grade_sum` there are computed as `R/grade_receipt.R:109-111` and `scripts/0325-publish.R:193-196` compute them.
- Removing `database_receipts.R`'s IDate step is backed by crate 0.14.0's NEWS entry (crate#49).

I checked these numbers against the committed logs, and they match: 2.7e-4 and 2.1 million; 1.07e-3, 1.20e-3 and 4.2 million; 8.1e-8 and 8.7e-7; 5.3e-11 and 1.5e-9; ten identical outputs plus smoke at 2.27e-13; tables of 0.29 to 2.50 GB, taken from the records' `grades_bytes`.

The crate claims also match `crt_receipt_compare.R:160` (a summary is compared as a band) and `crt_table_fingerprint.R` (columns sorted by name, cells rounded to the tolerance's decimals). `null_heldout_curve` is written to four decimals (`0320:604`).
