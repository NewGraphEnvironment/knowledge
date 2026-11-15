# Code-check branch review, round 4 (#165): the terminating enumeration

Diff: `89ee4d3a...ed02a7ae`, without `scripts/logs/` and `planning/`, plus the edited body of #197. This round was
read-only: it edited no file but this one, used no database and committed nothing.

## Checklist read

- `code-check-python.md`: read in full. The diff has no Python, so no rule applies.
- `code-check.md`: read the prose of every H3 under `## Mechanisms`. The ones this diff touches:
  - "A guard's scope, escape hatches, and remedies": terminate by enumeration; a restatement names its population six
    ways; "compression runs both ways"; when one instance is stale, grep for the sentence.
  - "A proxy is not the property": a sentence describing a figure is a claim about the criterion behind it.
  - "One fact derived twice": derive a number from the artifact it names.
  - "A fixture that cannot reach the failure mode": a finding describes only the fixture that produced it.
  - "Written data outlives the fix": when a derived value changes, list every artifact that quotes it.
- `code-check-r.md`, read by heading:
  - "A `data-raw/` script must load the source tree, not the installed package": met. `grade_receipt_compare.R` and
    `grade_tolerance_try.R` call `pkgload::load_all()`, and `grade_order_bound.R` uses no package code.
  - "Postgres row order is never fixed unless the query fixes it…": the reason the grade totals need a band. The bound
    the branch uses, n x eps x sum|x|, is a valid limit on how far two summation orders can differ.
  - "`identical()` on two reader results tests the reader, not the file".
  - "`tolerance` in testthat is RELATIVE…": its last paragraph says a tolerance equal to the writer's unit does not pass
    a flip. grade.yaml's 1e-3 is 100 units of 1e-5, so the rule is not violated.
  - "A range total taken as the difference of two large running totals…".
- `code-check-shell.md` and `code-check-spatial.md`: no heading names a tool or pattern this diff uses.
- Crate behaviour was read from crate's own code, not from the docs:
  - `crt_receipt_compare.R` (origin/main, 0.16.0): every recipe field refuses, a summary is compared as a band
    (:160), and the tolerance comes from the receipts.
  - `crt_table_fingerprint.R`: columns are sorted by name (:74), rows are sorted, and cells are rounded to the
    tolerance's decimals.
  - `crt_receipt_write.R`: `recipe$code` (the commit) enters `recipe_id` (:160, :198).
  - NEWS for 0.14.0: IDate (crate#49).

## Enumeration (table)

Every quantified or scoped claim the branch adds or changes, round 3's fixes included, and the #197 body. A verdict is
true, false or unverifiable.

| # | where | claim | verdict | evidence |
|---|---|---|---|---|
| 1 | CLAUDE.md 459-461 | #165 set the grade and grade-set totals from chinook on two databases and each total's bound, and checked the evidence across the same two | true | `receipt_165/20261112_grade_order_bound.txt`, `_grade_receipt_compare.txt`, `_evidence_receipt_compare.txt` |
| 2 | CLAUDE.md 480-481 | crate rounds a table's values to the tolerance's decimals and compares a total as a band | true | crate `crt_table_fingerprint.R:72-75`, `crt_receipt_compare.R:160` |
| 3 | database_receipts.R 29,37-38 | crate >= 0.14.0 fingerprints IDate as Date (crate#49) | true | crate NEWS 0.14.0 |
| 4 | grade_order_bound.R header | the largest move over four orders, and the bound n x eps x sum\|x\| | true | the code matches; this is the standard recursive-summation bound |
| 5 | grade_order_bound.R header | the union of the directory's tables is the published set's summaries | true | the withheld keys (BT_spawn, CO_rear, WCT_rear) grade 0 rows (`_grade_order_bound.txt` 2,4,7), so the union equals the set 0325 binds (0325:177-182) |
| 6 | grade_order_bound.R header | the two yamls set tolerances above the bound of the largest key and of the set | true | 1e-3 > 2.726e-4; 1e-2 > 1.204e-3 |
| 7 | grade_receipt_compare.R header | the verdict comes from the two receipts and grade.yaml: the pick, rows, graded_rows, km_graded, grade_sum | true | `knw_receipt_keys("grade")`; the parts are `warn` |
| 8 | grade_tolerance_try.R header | half a tolerance gives equivalent, three times gives different, a count moved by one gives different, nothing written | true | `_grade_tolerance_try.txt` 3-9; the moves are made in memory only |
| 9 | evidence.yaml 6-7; run_archive 119 | each km is a sum over up to tens of thousands of segments (72,617 at most) | true | max `n_segments` in `derived_165_host/access_check.csv` (round 1) |
| 10 | evidence.yaml 7-8 | 1e-6 km is the tolerance #158's hand comparison used | true | `database_second/20261106_database_compare-evidence.csv` row 5 |
| 11 | evidence.yaml 8; run_archive 118 | 9.5e-11 km, #145's rebuild on one database | true | `planning/archive/2026-11-issue-145-promote-retune/progress.md:5-7` |
| 12 | evidence.yaml 9 | 1.0e-10 km at most from #160's two builds on one database | true | `evidence_receipt_160/..._compare.txt` (1.0186e-10) |
| 13 | evidence.yaml 9; run_archive 118 | 6.0e-11 km on #158's second database | true | `database_second/..._compare-evidence.csv` row 5: 6.0027e-11 |
| 14 | evidence.yaml 9-11 | 5.3e-11 km on #165's pair; every other table has the same values; one recipe_id; `equivalent` on the receipts alone and with the tables re-read | true | `receipt_165/..._compare-evidence.csv`; `_evidence_receipt_compare.txt` 1-5 |
| 15 | evidence.yaml 11-12; run_archive 122; database_builds 256 | the mad_pick that moved on 3 visits in #158 came back the same, on all 45,529 | true | receipt_165 evidence csv: `visits_link` identical, 45,529 rows |
| 16 | evidence.yaml 12-14 | two tables' bytes differ through the species column order; crate keys by column name, so the verdict does not move; each grade's evidence_md5 does | true | headers of `derived_165_host` and `_second`, columns 105-139 and 160-194; crate `crt_table_fingerprint.R:74`; `_grade_receipt_compare.txt:17` |
| 17 | evidence.yaml 14 | crate rounds a table's value to the tolerance's decimals | true | as row 2 |
| 18 | fdis.yaml 5-6 | five tables are the evidence build's, and #165 found them exact except access_check's km | true | 0299:96-100 (the v3 tables); receipt_165 evidence csv |
| 19 | fdis.yaml 6-7 | the other six: fdis_sites (0240), fdis_repeat_surveys (0230), and the tables from 0290, 0294 and 0296 | true | 0299:78-84 |
| 20 | fdis.yaml 7-8 | the six have not been compared across databases | unverifiable | no comparison is committed |
| 21 | grade.yaml 4-6 | one commit, two databases, each on its own evidence: one recipe_id and identical receipts, every summary equal bit for bit | true (the verdict is identical; context and parts differ, as recorded) | `_grade_receipt_compare.txt` 4-26 |
| 22 | grade.yaml 6 | #158's `different` was #161's tie | true | database_builds.md #158 table and bullet |
| 23 | grade.yaml 6-7; run_archive 92-93; database_builds 258-259 | every walk came from the cache, so #162 was not tested | true | tune logs :409 `walk_cache_miss=0`; evidence logs :8 "0 to walk" on both |
| 24 | grade.yaml 8-9 | the tolerance is the smallest power of ten strictly above the bound | true | 2.7e-4 gives 1e-3 |
| 25 | grade.yaml 10 | 2.7e-4 for the largest key, BT rearing, 2.1 million graded | true | `_grade_order_bound.txt` 1, 26-27 |
| 26 | grade.yaml 10-11 | 8e-8 seen over four orders | true | 8.056e-8 |
| 27 | grade.yaml 11-12 | only chinook was regraded on both; the counts are exact | true | rows and graded_rows carry no tolerance |
| 28 | grade.yaml 30-31; run_archive 67 | written to four decimals; a change in the fourth decimal reads `different` | true | 0320 `round(..., 4)`; crate rounds to 4 decimals at 1e-4 |
| 29 | grade.yaml 37-38 | five significant figures; one flip moves the sum by up to 1e-5 | true | 0320 `signif(.x, 5)` (round 3) |
| 30 | grade.yaml 42; run_archive 12, 76; grade_record.R 22; 0336 4 | 0.3 to 2.5 GB, about 11 GB a run | true | tracked records' `grades_bytes`: 290,024,926 to 2,504,130,957, sum 11.19 GB |
| 31 | habitat_grade.yaml 4 | the summaries are each grade table's summed over the keys | true | 0325:194-196 |
| 32 | habitat_grade.yaml 6-7; run_archive 101 | 1.07e-3 and 1.20e-3 over 4.2 million graded; 9e-7 seen | true | `_grade_order_bound.txt` 15-16, 40-41 |
| 33 | habitat_grade.yaml 8; run_archive 109-111 | the recipe names the tuning run, so these totals are compared between republishes of one run's tables | **incomplete** | the recipe also names the knowledge commit (0325:139 `.knw_receipt_code()`; crate puts `code` into `recipe_id`), so only republishes at one commit compare. See finding 2 |
| 34 | habitat_grade.yaml 9; run_archive 111-112 | the 1e-2 has not been tried on real receipts | true | `_grade_tolerance_try.txt` exercises the grade receipts only |
| 35 | thresholds.yaml 3-4; run_archive 108-109 | #158 gave every pick, score, curve and group the same | true | database_builds.md #158 table (round 3) |
| 36 | thresholds.yaml 4-5 | the recipe names the tuning run and the evidence by the grade tables' evidence_md5 | true | 0325:110, 139-144 |
| 37 | thresholds.yaml 5 | "the provenance columns come from those tables too" (the grade tables) | **false as attribution** | the thresholds table takes `evidence_md5` and `curve_grad` from the tune summaries (R/thresholds_table.R:164-165), `link_run_uid` and `link_sha` from the evidence ledger (0325:41-44), and `evidence_version` and `config` from constants (0325:38, 68). See finding 2 |
| 38 | thresholds.yaml 5-6 | a republish of one run's tables gives the same recipe and table on any database | **true only at one commit** | as row 33 |
| 39 | thresholds.yaml 6-7; run_archive 111 | a regrade is a new run and so a new recipe whatever the database | true by default | 0320:149 names the run by timestamp unless `RUN=` is given |
| 40 | thresholds.yaml 7 | no two thresholds receipts have been compared | unverifiable | none are committed |
| 41 | database_builds.md 4-12 | header dates, issues and producers | true | |
| 42 | database_builds.md 253-256 | at one commit on each database, each grade on its own evidence: one recipe, `equivalent`, 5.3e-11 | true | receipt_165 logs |
| 43 | database_builds.md 256-258 | chinook `identical`, the pick and four totals bit for bit, every segment's grade and length agreed | true | `_grade_receipt_compare.txt` 9-41 |
| 44 | database_builds.md 258 | the `different` recorded for chinook's grade table was the tie | true | #158 table: five keys differ in segment size (#161) |
| 45 | database_builds.md 259-262 | `visits_link` and `workbook_sites` have different bytes and the same values (#158 saw workbook_sites' too), through the catalog order, so every grade and summary evidence_md5 differs | true | `database_second/...-evidence.csv` row 6; header diff; tune logs 3-5 (389942d4… vs ea6514ce…) |
| 46 | database_builds.md 262-264 | `0320` took 14.0 min on the host (14 workers) and 17.2 min on the second (8) | true | `…0648….txt:24,418`; `…0647….txt:24,418` |
| 47 | database_builds.md 264 | the second ran "beside another session's link tests" | unverifiable from the logs | only `planning/active/findings.md:46,98` |
| 48 | run_archive 74-79 | a table's cells are rounded before hashing; a total is a band | true | crate code |
| 49 | run_archive 83-89 | each grade total's rounding is the smallest power of ten above the bound for the largest table, and above one writer unit; the others rest on rebuilds | true | rows 24, 29, 32 |
| 50 | run_archive 96 | one recipe_id; `identical`; all four totals bit for bit | true | |
| 51 | run_archive 97 | every segment the same, in the same order; bytes differ only in evidence_md5 | true | `_compare-tune.csv` grades row note; `_grade_receipt_compare.txt:41` |
| 52 | run_archive 99 | "every tune output": ten identical, smoke equivalent at 2.27e-13 | **false for "every"** | `database_compare.R` specs (:46-67) cover `.csv` only; `CH_rear_curve.rds`, `CH_rear_score.rds` and the receipt JSON were not compared. See finding 4 |
| 53 | run_archive 100-101 | 8.1e-8 per key and 8.7e-7 over the set; 2.7e-4 for BT over 2.1 million; 1.07e-3 and 1.20e-3 over 4.2 million | true | `_grade_order_bound.txt` |
| 54 | run_archive 103-107 | grade 1e-3 kept and set to 1e-2; the grade tolerances tried on the two real chinook receipts | true | `_grade_tolerance_try.txt` |
| 55 | run_archive 107-108 | #158 found BT and ST moved by the tie | true | #158 table |
| 56 | run_archive 117-119 | first two rebuilds: 9.5e-11 (#145) and 6.0e-11 (#158) | true | git dates: #158's evidence committed 2026-11-05 21:12 -0700, #160's 2026-11-06 06:13 |
| 57 | run_archive 119 | "every other table came back with the same values" (over #145's and #158's rebuilds) | **false for #158** | `database_second/20261106_database_compare-evidence.csv` row 1: `visits_link` `different`, mad_pick on 3 rows and an added column. The next sentence says so. See finding 3 |
| 58 | run_archive 121-122 | the tie is fixed, and the cross-database pair came back unchanged | true | row 15 |
| 59 | run_archive 130-134 | one recipe_id (link configs hash the same); four tables byte-identical; 5.3e-11 at most over 2,193; sum 1.5e-9; `equivalent` both ways (2.2 min); hand comparison six identical, access_check equivalent | true | `_evidence_receipt_compare.txt` 1-34; `_compare-evidence.csv` (6 identical, 1 equivalent); access_km 6937234.1350527825 vs …2781 |
| 60 | run_archive 134-136 | column order through `knw_link_place()` reading the catalog unordered; crate sorts columns by name | true | `R/link_place.R:50-56`; crate :74 |
| 61 | run_archive 138-139 | crate rounds a table's value, a total as a band | true | |
| 62 | run_archive 4 (header, untouched) | "#158 (the first rebuild compared)" | **contradicted** | the branch's line 118 names #145's earlier rebuild as the first measured one. See finding 3 |
| 63 | run_archive 6 (header, untouched) | "sizes and costs from #119's measurements of 2026-10-29" | **stale** | the sizes at lines 12, 47 and 76 now come from the current tracked records (#145's run). See finding 5 |
| 64 | test-receipt.R 125 | the set's float bound over 4.2 million is 1.2e-3 | true | |
| 65 | #197 "If we do it" | "byte for byte the same, as the five other tables already are" | **false** | four of the other five are byte-identical. `access_check.csv` differs in bytes (160,463 against 160,508; `_evidence_receipt_compare.txt:16,28`). See finding 1 |
| 66 | #197 Problem | `knw_link_place()` reads `information_schema.columns` with no ORDER BY (`R/link_place.R:50-57`) | true | :50-56 |
| 67 | #197 Problem | species order `pk, sk, st, wct, gr, ko, rb` against `gr, ko, pk, rb, sk, st, wct`, columns 105-139 and 160-194 | true | header diff of the two `visits_link.csv` |
| 68 | #197 Problem | every value agrees; database_compare reads both identical; crate reads them agreeing; one recipe_id | true | receipt_165 logs |
| 69 | #197 new paragraph | visits_link's md5 is the first of the three in every grade table, record and summary's evidence_md5 | true | 0320:250-254, 475, 522, 668 |
| 70 | #197 new paragraph | the two chinook regrades "differ in that column alone" | true for the grade tables | `_compare-tune.csv`: grades "context differs: evidence_md5". The record and summary also differ in tune_run, ledger and dir |
| 71 | #197 new paragraph | a reader that holds a grade or curve to the evidence by those md5s treats the builds as different | true: readers exist | 0330:51, 172 (refuses evidence md5s that are not the curves'); `data-raw/vignette_chinook.R:161, 168`; `data-raw/vignette_method.R:20, 102`; `R/archive.R:239`; `R/receipt.R:112`; 0320:618 keep-check; 0335:77 and `R/tune_promote.R:175, 203`. 0325 holds the grades only to the thresholds rows (0325:96-99), not to the evidence files |
| 72 | #197 new paragraph | a grade receipt is unaffected: it names the evidence by recipe_id | true | `_grade_receipt_compare.txt:7-8`; `R/receipt.R:125` |
| 73 | #197 new paragraph | the published sets are unaffected: their recipes name the run, and a republish reads the same md5s | true (at one commit, row 33) | 0325:139-144 |
| 74 | #197 Problem | `knw_link_access_check()` and `knw_build_record()` test membership with `%in%` | **true in substance** | access_check uses `%in%` (:35-36). build_record selects `IN (...)` in SQL and then `intersect(axes, …)` (:55-60), which keeps `axes`' order. So the claim is right that order does not matter, wrong about the operator |

## Findings

- **[severity: fragile]** Issue #197 body, "If we do it" (row 65). The body says the two tables would be "byte for byte
  the same, as the five other tables already are". Only four are: `visits_species`, `walks`, `bcfishobs_fdis_match`
  and `workbook_species`. `access_check.csv` differs in bytes between the two databases: 160,463 bytes against
  160,508, its km at 5.3e-11 (`receipt_165/20261112_evidence_receipt_compare.txt:16,28`). Fixing #197 will not make
  an evidence build byte-identical across databases, which is how the sentence reads. A minor slip in the same body:
  `knw_build_record()` does not use `%in%`. It filters with SQL `IN (...)` and then `intersect(axes, …)`
  (`R/build_record.R:55-60`). The conclusion stands: its output does not depend on the order.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a restatement's member list; terminate by
    enumeration).

- **[severity: fragile]** inst/receipt/thresholds.yaml:4-7, inst/receipt/habitat_grade.yaml:8 and
  research/run_archive.md:109-111 (rows 33, 37, 38). Round 3 named this mechanism: the recipe's fields were not listed.
  - **The commit.** "A republish of one run's tables gives the same recipe … on any database" holds only at one
    knowledge commit. `recipe_of()` puts `code = .knw_receipt_code(knowledge_git)` (0325:139) and the settings
    register's hash into the recipe. crate hashes `recipe$code` into `recipe_id` (`crt_receipt_write.R:160, 198`),
    and every recipe field refuses. A republish from a later commit, which is the usual case, therefore reads
    `different` on the recipe however its tables compare.
  - **The provenance columns.** thresholds.yaml says they "come from those tables too", meaning the grade tables.
    They do not. `evidence_md5` and `curve_grad` come from the tune summaries (R/thresholds_table.R:164-165),
    `link_run_uid` and `link_sha` from the evidence ledger (0325:41-44), and `evidence_version` and `config` from
    constants. The database-independence conclusion still holds, because all of these are tracked files, but the
    sentence names the wrong source.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (enumerate the recipe's members, not the
    one field in view); writing.md "State each claim by the code's definition".

- **[severity: fragile]** research/run_archive.md:117-119 (row 57). "The first two measured rebuilds moved
  `access_check`'s km by 9.5e-11 … and 6.0e-11 (#158's second database) …; every other table came back with the same
  values." This is false for #158. `database_second/20261106_database_compare-evidence.csv` row 1 has `visits_link`
  `different`: mad_pick moved on 3 visits, and current code added a column. The next sentence of the same paragraph
  says so, so the paragraph contradicts itself in a provenance record. The quantifier was carried over from the
  pre-branch text into an edited sentence. Related (row 62): the header, which this branch left untouched, still calls
  #158 "the first rebuild compared", while the line 118 this branch wrote names #145's earlier rebuild as the first
  measured one.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ("compression runs both ways"; walk the
    per-member evidence behind `every`).

- **[severity: fragile]** research/run_archive.md:99 (row 52). "every tune output (`data-raw/database_compare.R`) | ten
  identical, the smoke table equivalent". `database_compare.R` compares the run's `.csv` files only (specs :46-67). The
  candidate run also writes `CH_rear_curve.rds` (which grading reads), `CH_rear_score.rds`, `CH_spawn_curve.rds` and
  the receipt and record. The receipt and record were compared by other means; the rds files were not. "Every" should
  be "every tune CSV", eleven of them.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a universal quantifier is a population
    claim; check the member list).

- **[severity: fragile]** tests/testthat/test-vignette-data.R:122, research/run_archive.md:6 and R/grade_record.R:42
  (row 63). Round 3's grade-size fix still has copies:
  - test-vignette-data.R:122 says "the published tables are up to 26 GB to md5". The tracked records sum to 11.19 GB.
  - run_archive.md's header still credits the sizes to "#119's measurements of 2026-10-29". The 0.3-2.5 GB and 11 GB
    now on lines 12, 47 and 76 come from the current records (#145's run).
  - grade_record.R:42 still argues from "counting a 5 GB table". The largest is now 2.5 GB, so this is a minor copy of
    the old range.
  - **Rule:** code-check.md "Written data outlives the fix" (when a derived value changes, list every artifact
    quoting it); agent-operations §3 "Documents that share an ancestor corroborate nothing" ("when one instance is
    stale, grep for the sentence, not the file").

No defect was found in the code: the four data-raw scripts, the test, and the crate floor in `database_receipts.R`.
Every number round 3's fixes wrote checks out against its log: thresholds and habitat_grade bounds, the #145
attribution, fdis_sites (0240), the copied sizes, the 14.0 and 17.2 min, and `workbook_sites` already seen in #158.
Round 3's `tune_run` finding is fixed in the yamls, run_archive.md and #197. What remains is the commit field beside it
(finding 2).
