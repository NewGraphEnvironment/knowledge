# Code-check branch review, round 5 (#165): the terminating enumeration, re-run on the current tree

Diff: `89ee4d3a...3a6d06a6`, without `scripts/logs/` and `planning/`, plus the body of #197 as it reads now. This round
was read-only. It edited no file but this one, used no database and committed nothing. It ran
`tests/testthat/test-receipt.R` once (0 failed, 0 errors, 11 tests), and `git status` was clean afterwards.

## Checklist read

- `code-check-python.md`: read in full. The diff has no Python, so no rule applies.
- `code-check.md`: read the prose of every H3 under `## Mechanisms`. The ones that bear on this diff:
  - "A guard's scope, escape hatches, and remedies":
    - Terminate by enumeration.
    - A restatement names its population six ways.
    - "Compression runs both ways": a sentence that gained a quantifier is unsupported until its source is checked.
    - A time qualifier means do not re-point.
  - "Written data outlives the fix": when a derived value changes, enumerate every artifact quoting it.
  - "One fact derived twice".
  - "A proxy is not the property": a sentence describing a figure is a claim about its criterion.
  - "The probe is broken before the world is": write the numbers last, against the final tree.
- `code-check-r.md`, read by heading:
  - "A `data-raw/` script must load the source tree…": met. `grade_receipt_compare.R` and `grade_tolerance_try.R` call
    `pkgload::load_all()`. `grade_order_bound.R` uses no package code.
  - "Postgres row order is never fixed…": the reason for the summing-order bound.
  - "`identical()` on two reader results tests the reader, not the file".
  - "`tolerance` in testthat is RELATIVE…", its last paragraph: the grade's 1e-3 is 100 writer units, so a flip
    passes.
  - "A range total taken as the difference of two large running totals…".
- `code-check-shell.md` and `code-check-spatial.md`: no heading names a tool or pattern this diff uses.
- crate was read from its own code at origin/main, with 0.16.0 installed:
  - `crt_table_fingerprint.R`: columns sorted by name with `order(cols, method = "radix")`, rows sorted, cells rounded
    to `table_decimals()`.
  - `crt_receipt_compare.R`: a summary is `within` when `abs(va - vb) <= tol`. Any `within` gives `equivalent`, any
    `refuse` gives `different`.
  - NEWS 0.14.0: IDate is fingerprinted as Date (crate#49).

## Enumeration (table)

The table re-checks round 4's 74 rows against the current text, then adds a row for each sentence 3a6d06a6 changed or
added (rows 75 onward), then the claims round 4 missed. A verdict is true, false or unverifiable.

| # | where (current) | claim | verdict | evidence |
|---|---|---|---|---|
| 1 | CLAUDE.md 459-461 | #165 set the grade and grade-set totals from chinook on two databases and each total's bound, and checked the evidence across the same two | true | `receipt_165/20261112_grade_order_bound.txt`, `_grade_receipt_compare.txt`, `_evidence_receipt_compare.txt` |
| 2 | CLAUDE.md 480-481 | crate rounds a table's values to the tolerance's decimals and compares a total as a band | true | crate `crt_table_fingerprint.R` (`table_decimals`), `crt_receipt_compare.R` (the `abs(va - vb) <= tol` band) |
| 3 | database_receipts.R 29, 36-37 | crate >= 0.14.0 fingerprints IDate as Date (crate#49) | true | crate NEWS 0.14.0 |
| 4 | grade_order_bound.R 5-7 | the largest move over four orders, and the bound n x eps x sum\|x\| | true | code :17-19 |
| 5 | grade_order_bound.R 4 | the union of the directory's tables is the published set's summaries | true | the withheld keys grade 0 rows (`_grade_order_bound.txt` 2, 4, 7), so the union equals what 0325:193-196 sums |
| 6 | grade_order_bound.R 7-8 | the yamls set tolerances above the bound of the largest key and of the set | true | 1e-3 > 2.726e-4; 1e-2 > 1.204e-3 |
| 7 | grade_receipt_compare.R 6-7 | the verdict comes from the two receipts and grade.yaml: the pick and the four summaries | true | `knw_receipt_keys("grade")`; the parts are `warn` |
| 8 | grade_tolerance_try.R 3-5 | half a tolerance gives equivalent, three times gives different, a count moved by one gives different, nothing written | true | `_grade_tolerance_try.txt` 3-8; the moves are made in memory (:57, :62) |
| 9 | evidence.yaml 6-7; run_archive 118 | each km is a sum over up to tens of thousands of segments (72,617 at most) | true | `max(n_segments)` in `data/fdis/derived_165_host/access_check.csv` = 72,617 |
| 10 | evidence.yaml 7-8; run_archive 120 | 1e-6 km is the tolerance #158's hand comparison used | true | `database_second/20261106_database_compare-evidence.csv` access_check row, tolerance 1e-06 |
| 11 | evidence.yaml 8-9; run_archive 117 | 9.5e-11 km, #145's rebuild on one database | true | `planning/archive/2026-11-issue-145-promote-retune/progress.md:6-8` |
| 12 | evidence.yaml 9 | 1.0e-10 km at most from #160's two builds on one database | true | `evidence_receipt_160/..._compare.txt` |
| 13 | evidence.yaml 9; run_archive 117 | 6.0e-11 km on #158's second database | true | 6.00266503170133e-11 |
| 14 | evidence.yaml 9-11 | 5.3e-11 km on #165's pair; every other table has the same values; one recipe_id; `equivalent` on the receipts alone and with the tables re-read | true | `receipt_165/_compare-evidence.csv`; `_evidence_receipt_compare.txt` 1-5 |
| 15 | evidence.yaml 11-12; run_archive 121-122; database_builds 256 | the mad_pick that moved on 3 visits in #158 came back the same, on all 45,529 | true | receipt_165 evidence csv: `visits_link` identical, 45,529 rows |
| 16 | evidence.yaml 12-14 | two tables' bytes differ through the species column order; crate keys by column name, so the verdict does not move, but each grade's evidence_md5 does | true | the two headers have the same columns in another order (checked for both tables); crate `order(cols)`; `_grade_receipt_compare.txt` context.inputs (389942d4… vs ea6514ce…) |
| 17 | evidence.yaml 14 | crate rounds a table's value to the tolerance's decimals | true | as row 2 |
| 18 | fdis.yaml 5-6 | five tables are the evidence build's, and #165 found them exact except access_check's km | true | yaml lists; receipt_165 evidence csv |
| 19 | fdis.yaml 6-7 | the other six: fdis_sites (0240), fdis_repeat_surveys (0230), and the tables from 0290, 0294 and 0296 | true | bt_use_visits, ch_mad_visits, ch_rule_visits and ch_rule_walks make 2 + 4 = 6 |
| 20 | fdis.yaml 7-8 | the six have not been compared across databases | unverifiable (consistent) | none of `database_second/*.csv` or `receipt_165/*.csv` names them |
| 21 | grade.yaml 4-6 | one commit, two databases, each on its own evidence: one recipe_id, identical receipts, every summary bit for bit | true | `_grade_receipt_compare.txt` 2-26 |
| 22 | grade.yaml 6 | #158's `different` there was #161's tie | true | database_builds.md #158 table and the #161 bullet |
| 23 | grade.yaml 6-7; run_archive 92-93; database_builds 256-257 | every walk came from the cache, so #162 was not tested | true | both tune logs :409 `walk_cache_miss=0` |
| 24 | grade.yaml 8-9; run_archive 86-87 | the smallest power of ten strictly above the bound | true | 2.7e-4 gives 1e-3; 1.2e-3 gives 1e-2 |
| 25 | grade.yaml 10 | 2.7e-4 for BT rearing, 2.1 million graded | true | `_grade_order_bound.txt` 1, rows 1-2 of the bound |
| 26 | grade.yaml 10-11 | 8e-8 seen over four orders | true | 8.05594e-08 |
| 27 | grade.yaml 11-12 | only chinook was regraded on both; the counts are exact | true | rows and graded_rows carry no tolerance |
| 28 | grade.yaml 30-31; run_archive 68 | written to four decimals; a change in the fourth decimal reads `different` | true | 0320 rounds to 4 (pick record); crate rounds to 4 decimals at 1e-4 |
| 29 | grade.yaml 37-38; run_archive 103-104 | five significant figures; one flip moves the sum by up to 1e-5 | true | 0320:669 `signif(.x, 5)`; grades are capped at 1 (`R/grade.R:73` `pmin(rate / reference, 1)`) |
| 30 | grade.yaml 42; run_archive 12, 76; grade_record.R 22; Rd 60; 0336 4 | 0.3 to 2.5 GB, about 11 GB a run | true | tracked records' `grades_bytes`: 290,024,926 to 2,504,130,957, summing to 11.19 GB |
| 31 | habitat_grade.yaml 4 | the summaries are each grade table's summed over the keys | true | 0325:193-196 |
| 32 | habitat_grade.yaml 6-7; run_archive 101 | 1.07e-3 and 1.20e-3 over 4.2 million graded; 9e-7 seen | true | `_grade_order_bound.txt` rows 15-16 (8.69e-7) |
| 33 | habitat_grade.yaml 8 (changed) | "The recipe names the knowledge commit and the tuning run" | true (not exhaustive: also link build, flow, evidence, settings file) | 0325:136-143 `recipe_of()`: `code = .knw_receipt_code()` (commit), `settings = list(tune_run)` |
| 34 | habitat_grade.yaml 8-9; run_archive 111-112 | the 1e-2 has not been tried on real receipts | true | `_grade_tolerance_try.txt` reads only the grade receipts |
| 35 | thresholds.yaml 3-4; run_archive 108-110 | #158 gave every pick, score, curve and group the same | true | database_builds.md #158 table: 7 of 7 picks; scores, seeds, nested, curves and groups byte-identical |
| 36 | thresholds.yaml 4-5 (changed) | the recipe names the knowledge commit, the tuning run and the evidence by the grade tables' evidence_md5 | true | 0325:110 (`evidence` from every head), :138-142 |
| 37 | thresholds.yaml (round 4's "provenance columns come from those tables") | removed by 3a6d06a6 | n/a | no longer present |
| 38 | thresholds.yaml (round 4's "same recipe on any database") | removed by 3a6d06a6 | n/a | no longer present |
| 39 | thresholds.yaml (round 4's "a regrade is a new run") | removed by 3a6d06a6 | n/a | no longer present |
| 40 | thresholds.yaml 5 | no two thresholds receipts have been compared | unverifiable (consistent) | none committed |
| 41 | database_builds.md 3-14 | header dates, issues and producers | true | `grade_receipt_compare.R` and `receipt_165/` exist |
| 42 | database_builds.md 253-256 | one commit on each database, each grade on its own evidence: one recipe, `equivalent`, 5.3e-11 | true | receipt_165 logs |
| 43 | database_builds.md 256-258 | chinook `identical`, the pick and four totals bit for bit, every segment's grade and length agreed | true | `_grade_receipt_compare.txt` 9-41 |
| 44 | database_builds.md 258 | the `different` recorded for chinook's grade table was the tie | true | #158 table: "the other five different in segment size (#161)", CH among them |
| 45 | database_builds.md 259-262 | the two tables' bytes differ with the same values (#158 saw workbook_sites' too), so the evidence_md5 every grade table and summary carries differs | true (CH_spawn's no_response summary carries NA, so it carries none) | `database_second/...-evidence.csv` workbook_sites bytes FALSE, identical; `_compare-tune.csv` grades and CH_rear summary "context differs: evidence_md5"; `candidate/20261112_0647/CH_spawn_summary.csv` evidence_md5 NA |
| 46 | database_builds.md 262-264 | `0320` 14.0 min on the host (14 workers), 17.2 min on the second (8) | true | `…0648…ch.txt` "Done in 14.0 min", "14 workers"; `…0647…ch.txt` "Done in 17.2 min", "8 workers" |
| 47 | database_builds.md 264 | "beside another session's link tests" | true (committed record) | `planning/active/findings.md:46, 98` |
| 48 | run_archive 74-77 | a table's cells are rounded before hashing; a total is a band | true | crate code |
| 49 | run_archive 83-89 | each grade total's rounding is the smallest power of ten above its bound and above one writer unit; the others rest on the rebuilds | true | rows 24, 29, 32 |
| 50 | run_archive 97 | one recipe_id; `identical`; all four totals bit for bit | true | |
| 51 | run_archive 98 | every segment the same, in the same order; bytes differ only in evidence_md5 | true | `_compare-tune.csv` grades note; `_grade_receipt_compare.txt` "same row order: TRUE" |
| 52 | run_archive 99 (changed) | "the eleven tune CSVs …; the `.rds` curves and score caches not compared": ten identical, smoke equivalent at 2.27e-13 | true | `_compare-tune.csv` 11 rows, 10 identical, smoke 2.27373675443232e-13; the candidate holds exactly 11 CSVs and three `.rds` (CH_rear_curve, CH_rear_score, CH_spawn_curve) |
| 53 | run_archive 100-101 | 8.1e-8 per key and 8.7e-7 over the set; 2.7e-4 for BT over 2.1 million; 1.07e-3 and 1.20e-3 over 4.2 million | true | `_grade_order_bound.txt` |
| 54 | run_archive 103-107 | the grade's 1e-3 is kept and the set's goes to 1e-2; tried on the two real chinook receipts | true | `_grade_tolerance_try.txt` |
| 55 | run_archive 107-108 | #158 found BT and ST moved by the tie | true | #158 table (CO and WCT also moved; their grades are withheld) |
| 56 | run_archive 116-117 | first two measured rebuilds: #145 (2026-11-04), then #158 (2026-11-06) | true | #145 progress 2026-11-04; #160's build is later on 2026-11-06 |
| 57 | run_archive 119 (changed) | "The other tables came back with the same values, but for `visits_link` in #158 (below)" | true | #145: "byte-identical … but for access_check" (#145 README:19). #158: every other evidence table is identical or equivalent in values, with only visits_link `different` (the ledger is not a table the receipt covers, `R/evidence_receipt.R:56`) |
| 58 | run_archive 121-122 | the tie is fixed, and the cross-database pair came back unchanged | true | row 15 |
| 59 | run_archive 131-135 | one recipe_id; four tables byte-identical; 5.3e-11 over 2,193; sum 1.5e-9; `equivalent` both ways (2.2 min); hand comparison six identical and access_check equivalent | true | `_evidence_receipt_compare.txt`; 6937234.1350527825 − 6937234.135052781 = 1.5e-9 |
| 60 | run_archive 135-137 | another column order through `knw_link_place()` reading the catalog unordered; crate sorts columns by name | true | `R/link_place.R:50-56`; crate |
| 61 | run_archive 139-142 | crate rounds a table's value and compares a total as a band | true | |
| 62 | run_archive 4 (changed) | "#158 (the first rebuild compared across databases)" | true | #145 and #160 rebuilt on one database; #158 is the first second-database run (database_builds.md "The published retune, reproduced there") |
| 63 | run_archive 6-7 (changed) | "costs from #119's measurements of 2026-10-29, grade table sizes from the tracked records" | true as attribution, **but see row 80** | lines 12, 47 and 76 match the records; lines 188-190 are #119's |
| 64 | test-receipt.R 125 | the set's float bound over 4.2 million is 1.2e-3 | true | 1.20422e-03 |
| 65 | #197 "If we do it" | "as four of the other five already are (`access_check.csv` moves by its float sums)" | true | `_evidence_receipt_compare.txt` bytes: visits_species, walks, bcfishobs_fdis_match and workbook_species TRUE; access_check 160,463 vs 160,508 |
| 66 | #197 Problem | `knw_link_place()` reads `information_schema.columns` with no ORDER BY (`R/link_place.R:50-57`) | true | :50-54 |
| 67 | #197 Problem | species order `pk, sk, st, wct, gr, ko, rb` against `gr, ko, pk, rb, sk, st, wct`, columns 105-139 and 160-194 | true | header columns 105, 139, 160 and 194 of both `visits_link.csv` |
| 68 | #197 Problem | every value agrees; database_compare reads both identical; crate reads them agreeing; one recipe_id | true | receipt_165 logs |
| 69 | #197 | visits_link's md5 is the first of the three in every grade table, record and summary's evidence_md5 | true (no_response summaries carry NA) | 0320:250-254; as row 45 |
| 70 | #197 | the two chinook regrades "differ in that column alone" | true for the grade tables | `_compare-tune.csv` grades: "context differs: evidence_md5" |
| 71 | #197 | a reader holding a grade or curve to the evidence by those md5s treats the builds as different | true | 0330:51, 172; `vignette_chinook.R`; `vignette_method.R`; `R/tune_promote.R` |
| 72 | #197 | a grade receipt is unaffected: it names the evidence by recipe_id | true | `_grade_receipt_compare.txt:7-8` |
| 73 | #197 | the published sets are unaffected: their recipes name the tuning run, and a republish reads the same md5s | true for #197's effect (the recipe also names the commit, but the commit is not what #197 moves) | 0325:110, 136-143 |
| 74 | #197 Problem (changed) | access_check and build_record only test membership (`%in%`; SQL `IN` and `intersect()`) | true | `R/link_access_check.R:35-36`; `R/build_record.R:55-60` |
| 75 | test-vignette-data.R 122 (changed) | "the published tables are about 11 GB to md5" | true | records sum to 11.19 GB |
| 76 | grade_record.R 42; Rd 41 (changed) | "counting a 2.5 GB table" | true | largest record 2,504,130,957 |
| 77 | run_archive 110-111 (changed) | both published sets' recipes name the knowledge commit, the tuning run and the evidence by the grade tables' evidence_md5 | true | 0325:136-143; `recipe_of()` serves both sets |
| 78 | run_archive 116 (changed) | "The first two measured rebuilds" | true | row 56 |
| 79 | run_archive 117-119 (changed) | the 9.5e-11 and 6.0e-11 moves are because each value is a sum that a database may take in another order | true | #145 README:19-20 "float summation order" |
| 80 | run_archive 188-190 (untouched; contradicted by the branch's line 12 and its header) | "archiving every run, compressed, with the evidence once per build, comes to about 28 GB and $0.65 a month after a year at 15 runs a year. Restoring one run costs about $0.15" | **false against the branch's own sizes** | #119 derived these from a 26 GB run: `planning/archive/2026-10-issue-119-keep-bundle-inputs/findings.md:17` ("At level 3 a run's grade tables are about 1.5 GB") and :27 (~28 GB, ~$0.65). At the 11.19 GB the branch now states (line 12), with line 22's "about 17× smaller", a run's compressed grades are about 0.66 GB, so 15 runs make about 10 GB, not 22.5 GB. See finding 1 |
| 81 | run_archive 22 (untouched) | zstd -3 is "about 17× smaller" | unverifiable for the current tables | measured once by #119, on the old 3.49 GB CH table (findings.md:17); the current tables are about half the bytes per row |
| 82 | grade.yaml 21-24 | the recipe's inputs: link build, flow, evidence by recipe_id or evidence_md5 | true | `R/receipt.R:112-125` |
| 83 | habitat_grade.yaml 2-3 | the set binds every published key's grade table, millions of rows | true | 0325:180, 4.24 M graded of 11.9 M rows |
| 84 | run_archive 72 | the published visit set: "all 11 tables" | true | fdis.yaml lists 11 |
| 85 | CLAUDE.md 459 | the declarations are pinned by `test-receipt.R` | true | test :119-130, green this round |

## Findings

- **[severity: fragile]** research/run_archive.md:188-190, read against the branch's lines 6-7 and 12 (row 80). The cost
  section says archiving every run comes to "about 28 GB and $0.65 a month after a year at 15 runs a year", and that
  restoring one run costs about $0.15. #119 derived those figures from a 26 GB run, about 1.5 GB of zstd-3 grades per run
  (`planning/archive/2026-10-issue-119-keep-bundle-inputs/findings.md:17, 27`).
  - **What the branch changed.** Line 12 now says about 11 GB a run, from the tracked records. Line 22 still says
    zstd-3 makes a table about 17× smaller.
  - **The contradiction.** At those two figures a run's compressed grades are about 0.66 GB, so 15 runs make about
    10 GB of grades, not 22.5 GB. A reader of the same page cannot get to 28 GB. Restoring one run is about 1 GB, about
    $0.09 at the page's egress price, not $0.15.
  - **The header.** The new header line credits "costs from #119's measurements". That is accurate attribution, but
    the section is written in the present tense and is a size derived from the table sizes the branch replaced.
  - **The fix.** Either recompute the figures from the records, or say beside them that they are #119's projection
    from a 26 GB run. Line 22's 17× was measured only on #119's old chinook table (row 81), so it needs the same note if
    it is kept.
  - **Rule:** code-check.md "Written data outlives the fix" ("When a derived value changes, enumerate every artifact
    quoting it"). Also agent-operations §3, "Documents that share an ancestor corroborate nothing" ("when one instance
    is stale, grep for the sentence"): round 4's size fix reached every copy of the range and the total, but not this
    value derived from them.

All the other rows are true or unverifiable-but-consistent. Every change in 3a6d06a6 checks out against its source:
- the recipe sentences in both yamls and run_archive.md (0325 `recipe_of()`);
- the `visits_link` exception in #158;
- the eleven CSVs and the uncompared `.rds` files;
- the header's "across databases";
- the 11 GB and 2.5 GB copies;
- #197's "four of the other five" and its `IN`/`intersect()` correction.

No defect was found in the code: the four data-raw scripts, the test, and the crate floor.
