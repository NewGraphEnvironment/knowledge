# Code-check round 2 (#158): database_compare.R, database_walk_check.R, database_receipts.R, CLAUDE.md, research/database_builds.md

## Checklist read

- code-check-python.md: not applicable (no Python in the diff); not read.
- code-check.md: `## Mechanisms`, the prose of "A guard that fails toward pass", "A fixture that cannot reach the failure mode" and "A proxy is not the property" read; the other eleven H3s read by heading only.
- code-check-r.md: by heading only. None of its sections read in full (the traps that bear on this code, NA/NaN, ifelse, sort collation and float formatting, were checked by running the code instead).
- code-check-shell.md, code-check-spatial.md: no shell or spatial code in the diff; not read.

## What I ran (on copies in the scratchpad; the repo was not touched)

- `SELFTEST_ONLY` path: 21 verdicts as expected.
- Evidence (REF=data/fdis/derived, NEW=derived_second), compare (data/compare against candidate 20261106_0423), the tune tables other than grades, and the five grade tables CH/CO/GR/ST/WCT: every verdict, row count, max_diff and "rows differing" count matches the committed CSVs. The only extra rows were `fdis_sites.csv` (from 0240) and `floodplain.csv` (from 0330 STAGE=maps), which 0310 and this 0330 run do not write. The run exits with status 1 on STOP, as intended.
- The repeated-key guard covers both the keyed path and the blank-key path, because it sits after the key is resolved and before the sort. The bytes-identical short-circuit needs no key. Checked for duplicates: none on the blank-key tables (workbook_species, bcfishobs_fdis_match), none on checks.csv's resolved key, and none on the walk check's grade sample (876,268 starts, 0 duplicated on blue_line_key+measure, 0 in the seed-158 draw).
- The receipts CSV's hand_verdict column agrees with the current hand CSVs on all 109 rows: 85 agree, 22 are equivalent by hand but identical to crate, and 2 errored.

## Findings

- **[severity: bug]** scripts/logs/habitat/database_second/20261106_database_compare-tune.csv (ST_rear_smoke row) and research/database_builds.md ("Three kinds of `different` were expected… Every other `different` traces to one of two ties"). Both misattribute the cause. ST's smoke note says "expected: the previous row reads the tracked tune table…". Yet ST's `previous` row is identical on both sides (`mad>=1|g<=0.0849|Q1@D250`, same dev_heldout, same coef_max). The one value that differs is the **no_rule** row's `coef_max_term`: `data_setFDS` in the reference, `era2005on` in the new run, with `coef_max` 2.127217 on both. So the largest coefficient is a near-tie between two terms, settled by float noise. That is a third kind of tie, in 0320's smoke reporting, and neither expected `previous`-row change nor #161 or #162 covers it. The research sentence is therefore unsupported for this output, and the cause note on the row is wrong. The verdict itself (`different`, not decision-read) is right.
  - **Rule:** none

- **[severity: fragile]** data-raw/database_compare.R:54 (and :65-67). Each tolerance equals the stored resolution, so a one-unit rounding flip does not reliably pass. The grade table stores rate and grade to 5 significant digits. In [0.1, 1) that is a step of 1e-5, and the declared tolerance is the same 1e-5. In double arithmetic `abs(a - b)` for a one-unit flip exceeds 1e-5 in 55 % of cases: measured over every 5-digit value from 0.10000 to 0.99998, 49,686 of 89,999 (`0.91635 - 0.91634` happens to pass). The comment's stated intent, admitting a rate on a rounding edge, holds only for small rates such as GR's 0.0081783. A summing-order flip on a rate or grade ≥ 0.1 would read `different` on a decision-read output and STOP the chain. The bound `compare.csv`, `change.csv` and `checks.csv` have the same shape: they store km to 3 decimals (and change_pct to 2), but are held to 1e-6. One float-order flip across a 0.0005 edge gives a 0.001 difference, which reads `different` and STOPs, even though the per-key tables at full precision are equivalent. No verdict in this run is wrong, because every table it touches is identical or already differs for #161, but the next equivalent run can STOP falsely. Fix: a tolerance a little above the resolution (e.g. 1.5e-5, 1.5e-3).
  - **Rule:** none

- **[severity: fragile]** data-raw/database_compare.R:19, data-raw/database_walk_check.R:10-11, data-raw/database_receipts.R:19-20. The tolerance rests on "walks.csv stores distances rounded to the centimetre" and "the stored tables round them to the centimetre", which is false. `data/fdis/derived/walks.csv` stores full doubles: `dist_m` 7.54848538676276, `bank_m` 20.45151461323724, and 179,284 of the first 200,000 `dist_m` values carry more than 2 decimals. `data/tune/CH_rear_grades.csv` `dist_m` is 2.3839063942432404e-5. So 0.005 m is a chosen tolerance, not the storage's resolution. A cold walk that moves a distance by up to 5 mm reads as equivalent. The research and CLAUDE.md counts at that tolerance (412 visit rows, "0.05 %"; 23 grade starts, "0.12 %"; "about one cold walk's distance in a thousand") count only moves over 5 mm, not every move. The brief's accepted tradeoff ("walks.csv stores centimetres") inherits the same false premise. Either state 0.005 m as a deliberate choice, or hold walks to a float tolerance (1e-6).
  - **Rule:** code-check.md "A guard that fails toward pass" (a comment stating a property is an unexecuted claim)

- **[severity: fragile]** research/database_builds.md, verdict table row "grade tables | different in segment size on 40 to 441 segments per key; 0 to 282 grades and 0 to 9 grade classes move". The row reads as covering every grade table, but `BT_spawn_grades.csv` is `identical` and `GR_rear_grades.csv` is `equivalent`, with 0 sizes moved. The 40-441 range holds for the five keys that differ, not "per key". Either name those five, or write 0 to 441.
  - **Rule:** none

- **[severity: fragile]** data-raw/database_compare.R:158, :166, :176. Counts and the `column` field can misreport; no verdict is affected.
  - (a) On the miss() path (NA placement differs), the numeric count for the remaining cells uses a bare `abs(x - y) > tol`. The same Inf on both sides gives `NaN > tol`, so the count for that column is `NA`. This is the round-1 Inf defect surviving in the count.
  - (b) On the non-finite path (:166), `n_bad` counts only non-finite cells, and `worst` skips the column, so finite past-tolerance rows in the same column go uncounted.
  - (c) When any column lands in `bad`, the returned `column` lists only the `bad` columns and `max_diff` is NA. The committed BT/CH/ST grade rows therefore say `column = grade_class`, while `size`, `rate` and `grade` also moved past the tolerance (the note's counts carry them). The header's "max_diff and its column say how far" does not hold on that path. Latent for (a) and (b): no compared table holds Inf.
  - **Rule:** none

/Users/airvine/Projects/repo/knowledge-retune/planning/active/review-round2.md
