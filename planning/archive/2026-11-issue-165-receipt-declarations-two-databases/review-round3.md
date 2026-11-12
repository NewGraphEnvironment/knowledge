# Code-check branch review, round 3 (#165)

Diff: `89ee4d3a...78d5adb5`, without `scripts/logs/` and `planning/`. Read-only: no file edited but this one, no
database, nothing committed.

## Checklist read

- `code-check-python.md`: read in full. No Python in the diff, so no rule applies.
- `code-check.md`: read the prose of every H3 under `## Mechanisms`. The ones this diff touches are "A guard's scope,
  escape hatches, and remedies" (terminate by enumeration; "compression runs both ways": an attribution widened, a
  quantifier gained), "A proxy is not the property" (a sentence describing a figure is a claim about the criterion),
  "One fact derived twice" (a line number or count derived at one commit), "Verification that reads its own output",
  and "A fixture that cannot reach the failure mode" (a finding produced by one fixture describes only that fixture).
- `code-check-r.md`, read by heading: "A `data-raw/` script must load the source tree, not the installed package";
  "`tolerance` in testthat is RELATIVE, so it pins a published figure far more loosely than it looks"; "`paste()`
  with a zero-length argument returns length ONE, not zero"; "`identical()` on two reader results tests the reader,
  not the file". None is violated: `grade_receipt_compare.R` and `grade_tolerance_try.R` call `pkgload::load_all()`,
  `grade_order_bound.R` uses no package code, and the test's `expect_equal()` values are exact powers of ten.
- `code-check-shell.md` and `code-check-spatial.md`: no heading names a tool or pattern this diff uses.
- Also checked against crate origin/main 0.16.0: `R/crt_receipt_compare.R` (a summary is compared as a band at
  :160; every recipe field refuses; nothing short-circuits on the recipe) and `R/crt_table_fingerprint.R` (columns
  sorted by name, rows sorted, double cells rounded to the tolerance's decimals).

## Mechanism

Earlier rounds found five false claims. All five come from one assumption: **a claim about what an output or
declaration covers, or about what differs between two builds, was written from the one measurement or difference
the author had in mind, and not from a list of the artifact's own members.** Those members are the declaration's
recipe fields, the set's tables, the record's rebuilds, the tolerances actually exercised, and the copies of the
same sentence elsewhere. Round 2's thresholds finding is the plainest case. The prose named `visits_link`'s md5
(#197) as the reason a cross-database rebuild reads `different`. Nobody walked the recipe's fields, and walking them
finds a second reason that #197 will not fix (finding 1).

Where the mechanism still reaches on this branch:

1. **Recipe fields that move on any rebuild.** The `thresholds`/`habitat_grade` recipe holds `settings.tune_run`,
   so the "until #197" conditional in three files, and #197's own body, is incomplete. See finding 1.
2. **What was exercised compared with what is claimed.** "The revised tolerances, tried on the two real chinook
   receipts": the tolerance that was tried did not change, and the one that changed was never tried. See finding 2.
3. **Attribution of the rebuilds listed.** The 9.5e-11 km rebuild is called "#154's", but it was #145's. See
   finding 3.
4. **Provenance of the six fdis tables.** `fdis_sites` is said to be 0230's, but 0240 writes it. See finding 4.
5. **One sentence fixed where it has copies.** The grade table size is now "0.3 to 2.5 GB" in two places, while
   the same file's line 12, `R/grade_record.R:22` and `scripts/0336-archive.R:4` still say 0.7 to 5.6 GB. See
   finding 5.
6. **How crate's rounding is described.** `evidence.yaml` still says "crate rounds a value". The other files were
   corrected to "a table's value" because this declaration also holds a summary (`access_km`), which crate compares
   as a band. Separately, `habitat_grade.yaml` says crate stops at the recipe "before any total is compared", which
   it does not. See finding 6.
7. **Numbers copied from a summary instead of the committed log.** The `0320` times are 14.1 and 17.4 min in the
   prose and 14.0 and 17.2 min in the logs. See finding 7.
8. **"New".** #158's own record already shows `workbook_sites` with identical values and different bytes. See
   finding 8.

## Enumeration (table)

Every quantified or scoped claim the branch adds or changes in prose and comments. Verdicts: true, false, or
unverifiable (no committed source).

| # | where | claim | verdict | evidence |
|---|---|---|---|---|
| 1 | CLAUDE.md 459-461 | #165 set the grade and grade-set totals from chinook on two databases and each total's summing-order bound, and checked the evidence build's across the same two | true | `receipt_165/20261112_grade_order_bound.txt`, `_grade_receipt_compare.txt`, `_evidence_receipt_compare.txt` |
| 2 | CLAUDE.md 480-481 | crate rounds a table's values to the tolerance's decimals and compares a total as a band | true | crate `crt_table_fingerprint.R` `table_decimals()`/`receipt_decimals()`; `crt_receipt_compare.R:160` |
| 3 | database_receipts.R 37,51 | crate >= 0.14.0 fingerprints IDate as Date (crate#49) | true | crate NEWS 0.14.0 |
| 4 | grade_order_bound.R header | max move over four orders, and the bound n x eps x sum\|x\| on any order's move | true | standard recursive-summation bound, (n-1)u sum\|x\| per order with u = eps/2; the code matches |
| 5 | grade_order_bound.R header | grade.yaml and habitat_grade.yaml set their tolerances above the bound of the largest key and of the set | true | 1e-3 > 2.72e-4; 1e-2 > 1.20e-3 |
| 6 | grade_receipt_compare.R header | the verdict comes from the two receipts and grade.yaml: pick, rows, graded_rows, km_graded, grade_sum | true | `knw_receipt_keys("grade")`; the parts are `warn` |
| 7 | grade_tolerance_try.R header | half a tolerance gives equivalent, three times gives different, a count moved by one gives different; nothing is written | true | `_grade_tolerance_try.txt`; edits are made in memory only |
| 8 | evidence.yaml 6-7 | each km is a sum over up to tens of thousands of segments (72,617 at most) | true | `data/fdis/derived_165_host/access_check.csv`: max `n_segments` 72617 |
| 9 | evidence.yaml 7-8 | the rounding is 1e-6 km, the tolerance #158's hand comparison used | true | `database_second/20261106_database_compare-evidence.csv`, access_check tolerance 1e-06 |
| 10 | evidence.yaml 8-9; run_archive 118 | 9.5e-11 km was "#154's, on one database" | **false** | the rebuild was #145's: `planning/archive/2026-11-issue-145-promote-retune/progress.md:8`; #154's task_plan.md:7 only cites it |
| 11 | evidence.yaml 9 | 1.0e-10 km at most from #160's two builds on one database | true | `evidence_receipt_160/..._compare.txt`: 1.018634e-10 |
| 12 | evidence.yaml 9 | 6.0e-11 km on #158's second database | true | `database_second/..._compare-evidence.csv`: 6.0027e-11 |
| 13 | evidence.yaml 9-11 | 5.3e-11 km on #165's pair, every other table with the same values, one recipe_id, `equivalent` on receipts alone and on re-read tables | true | `receipt_165/..._compare-evidence.csv` 5.275e-11; `_evidence_receipt_compare.txt` |
| 14 | evidence.yaml 11-12 | `visits_link`'s mad_pick, moved on 3 visits in #158, came back the same | true | `receipt_165` evidence csv: visits_link identical, 45529 rows |
| 15 | evidence.yaml 12-13 | two tables' bytes still differ through the species column order | true | `workbook_sites` headers differ between `derived_165_host` and `_second`; #197 body |
| 16 | evidence.yaml 13 | crate fingerprints a table by column name, so the verdict does not move | true | `table_canonical()` orders by `cols` |
| 17 | evidence.yaml 14 | "crate rounds a value to the tolerance's decimals" | **false** (for this declaration) | `access_km` is a summary, compared as a band (`crt_receipt_compare.R:160`); only table cells are rounded |
| 18 | fdis.yaml 5-6 | five tables are the evidence build's, which #165 found exact but access_check's km | true | 0299:98-100; receipt_165 evidence csv |
| 19 | fdis.yaml 6 | "0230's fdis_sites" | **false** | 0240 writes it (`scripts/0240-fdis-evidence.R:28,156`; 0299's INPUT line: "scripts/0240, 0290, 0294, 0296"); 0230 writes `fdis_repeat_surveys` (0230:604) |
| 20 | fdis.yaml 6-7 | the other six are 0230's two plus the tables 0290, 0294 and 0296 build from the evidence | true for the count and for the 0290/0294/0296 tables | 0299:78-81: bt_use_visits, ch_mad_visits, ch_rule_visits, ch_rule_walks |
| 21 | fdis.yaml 7-8 | the six have not been compared across databases | unverifiable | no committed comparison of them exists |
| 22 | grade.yaml 4-5 | one recipe_id and "identical receipts" | true for the verdict; the receipts themselves are not identical | `_grade_receipt_compare.txt`: verdict identical, but sha256 (warn) and context differ |
| 23 | grade.yaml 5-6 | every summary equal bit for bit | true | `_grade_receipt_compare.txt`, diff 0 on all four |
| 24 | grade.yaml 6 | #158's `different` was #161's tie | true | database_builds.md #158 table, grade tables row |
| 25 | grade.yaml 6-7; run_archive 92; database_builds 258 | every walk came from the cache | true | tune logs line 409: walk_cache_miss=0 on both |
| 26 | grade.yaml 8 | crate compares a summary as a band | true | `crt_receipt_compare.R:160` |
| 27 | grade.yaml 10 | 2.7e-4 for the largest key (BT rearing, 2.1 million graded) | true | bound 2.719e-4 / 2.726e-4; 2,120,275 graded |
| 28 | grade.yaml 10-11 | 8e-8 seen over four orders | true | max 8.056e-8 |
| 29 | grade.yaml 11-12 | only chinook was regraded on both; the counts are exact | true | yaml: rows and graded_rows carry no tolerance |
| 30 | grade.yaml pick comment | written to four decimals, and a change in the fourth decimal reads `different` | true | 0320:604 `round(..., 4)`; a 1e-4 tolerance rounds to 4 decimals |
| 31 | grade.yaml summary comment | five significant figures, so one grade moves the sum by up to 1e-5 | true | 0320:669 `signif(.x, 5)`; the receipt sums the written frame (0320:662-673); grades are in 0 to 1 |
| 32 | grade.yaml register; run_archive 75 | the grade table is 0.3 to 2.5 GB | true | tracked records' `grades_bytes`: 290,024,926 to 2,504,130,957 |
| 33 | habitat_grade.yaml 4 | its summaries are each grade table's summed over the keys | true in meaning | 0325 sums the bound table once; mathematically the same total |
| 34 | habitat_grade.yaml 6-7; run_archive table | 1.07e-3 and 1.20e-3 over 4.2 million graded; 9e-7 (8.7e-7) seen | true | `_grade_order_bound.txt` rows 15-16 |
| 35 | habitat_grade.yaml 8-9 | the recipe names the evidence by evidence_md5, which carries visits_link's md5 | true | 0325:110,145 |
| 36 | habitat_grade.yaml 9 | until #197, a rebuild on another database reads `different` on its recipe | **false (incomplete)** | the recipe's `settings.tune_run` (0325:140-143) moves on every regrade on any database: `database_compare-tune.csv` record note "context differs: …tune_run…", runs 20261112_0647 against _0648 |
| 37 | habitat_grade.yaml 9 | "before any total is compared" | **false** | crate compares every result field whatever the recipe (`crt_receipt_compare.R` 75-170); there is no short-circuit |
| 38 | thresholds.yaml 3-4; run_archive 105 | #158 gave every pick, score, curve and group the same | true | database_builds.md #158 table, rows 1-2 |
| 39 | thresholds.yaml 4-6; run_archive 107-109 | evidence_md5 and the recipe's evidence id carry visits_link's md5, so until #197 a rebuild on another database reads `different` | **false (incomplete)** | as row 36: `tune_run` in the recipe; also not specific to "another database" |
| 40 | thresholds.yaml 6-7; run_archive 109-110 | no two thresholds or published-set receipts have been compared | unverifiable | none committed |
| 41 | database_builds.md 4-6 | header dates and issues | true | |
| 42 | database_builds.md 254-255 | evidence: one recipe, `equivalent`, 5.3e-11, mad_pick the same on all 45,529 | true | receipt_165 logs |
| 43 | database_builds.md 255-257 | chinook `identical`, the pick and four totals bit for bit, every segment's grade and length agreed | true | `_grade_receipt_compare.txt` bottom |
| 44 | database_builds.md 257-258 | the `different` recorded for chinook's grade table was the tie | true | #158 table |
| 45 | database_builds.md 259-260 | "one new difference surfaced": the column order of visits_link and workbook_sites | **unverifiable / likely false ("new")** | `database_second/20261106_database_compare-evidence.csv`: workbook_sites `identical`, bytes_match FALSE, nothing added, the same signature in #158 |
| 46 | database_builds.md 260-262 | so neither does every evidence_md5 downstream, nor the evidence id 0325 gives | true | 0325:110 |
| 47 | database_builds.md 262 | `0310` 19.3 min on the host and 11.9 on the second | unverifiable | no time in the committed build logs or ledgers; only `planning/active/findings.md:73` |
| 48 | database_builds.md 263 | `0320` 14.1 min (14 workers) and 17.4 min (8 workers) | **false against the logs** | `20261112_tune_run-…0648….txt:418` "Done in 14.0 min"; `…0647….txt:418` "Done in 17.2 min" |
| 49 | run_archive 77-80 | a table's cells are rounded before hashing; a total is a band | true | crate code |
| 50 | run_archive 83-90 | each grade total's rounding is the smallest power of ten strictly above the bound for the largest table, and above one writer unit | true | rows 27, 31, 34 |
| 51 | run_archive 89-90 | the other declarations' roundings rest on the rebuilds and #158's | true (evidence, fdis) | |
| 52 | run_archive 98 | one recipe_id; identical; all four totals bit for bit | true | |
| 53 | run_archive 99 | every segment the same, in the same order; bytes differ only in evidence_md5 | true | `database_compare-tune.csv` grades note; `_grade_receipt_compare.txt` "same row order: TRUE" |
| 54 | run_archive 100 | "every tune output": ten identical, smoke equivalent at 2.27e-13 | true for the 11 CSVs; "every" overreaches | `database_compare.R:313` lists `*.csv` only; `CH_rear_curve.rds`, `CH_rear_score.rds` and `CH_spawn_curve.rds` were not compared |
| 55 | run_archive 101-102 | 8.1e-8 per key, 8.7e-7 over the set; 2.7e-4 BT 2.1 M; 1.07e-3 and 1.20e-3 over 4.2 M | true | `_grade_order_bound.txt` |
| 56 | run_archive 104-106 | "The revised tolerances, tried on the two real chinook receipts" | **false** | the tolerance tried is grade.yaml's 1e-3, unchanged ("keeps 1e-3"), read from the receipts themselves (`crt_receipt_compare` takes the receipts' tolerances, `receipt_summary_tolerance`); the one revised, habitat_grade's 1e-2, was never tried: `_grade_tolerance_try.txt` lines 1-2 show 0.001 |
| 57 | run_archive 106-108 | #158 found BT and ST moved by the tie | true | #158 progress: "BT, CH, ST … differ only in graded km (#161)" |
| 58 | run_archive 117-120 | first two rebuilds 9.5e-11 and 6.0e-11; up to 72,617 segments; every other table the same values | true except the #154 attribution (row 10) | |
| 59 | run_archive 122-123 | visits_link exact; the tie fixed; the pair came back unchanged | true | |
| 60 | run_archive 131-135 | 19.3 and 11.9 min; one recipe_id (link configs hash the same); four byte-identical; 5.3e-11 at most over 2,193; sum 1.5e-9; `equivalent` both ways (2.2 min); hand: six identical, access_check equivalent | true, except the minutes, which are unverifiable (row 47) | `receipt_165` evidence csv and compare txt |
| 61 | run_archive 135-137 | visits_link and workbook_sites column order through `knw_link_place()` reading the catalog unordered; crate sorts columns by name, so no verdict moves | true | `R/link_place.R:50-57`; 0310:253,438; crate `table_canonical()` |
| 62 | run_archive 139-140 | crate rounds a table's value rather than a band, a total as a band | true | |
| 63 | test-receipt.R 125 | the float bound over 4.2 million graded is 1.2e-3 | true (the larger of the two) | |

## Findings

- **[severity: fragile]** inst/receipt/habitat_grade.yaml:8-9, inst/receipt/thresholds.yaml:4-7,
  research/run_archive.md:106-110 (and #197's body, "So a published set rebuilt on another database reads
  `different` … though every value agrees"). Each says a rebuild on another database reads `different` "until #197
  orders its columns". That is false as a conditional, and too narrow in scope. Both published sets' recipe carries
  `config.settings.tune_run` (`scripts/0325-publish.R:139-143`, `recipe_of()`, from the grade records' `tune_run`),
  and every recipe field refuses in crate. A rebuild means a regrade, on this database or another, and a regrade
  writes a new candidate run id: #165's two runs were `20261112_0647` and `20261112_0648`, and
  `receipt_165/20261112_database_compare-tune.csv` lists the record's `tune_run` among the context that differs. So
  the published sets' `recipe_id` differs on every rebuild, whatever #197 does. Neither of #197's proposed fixes
  (sorting the columns, or naming the evidence by `recipe_id`) makes a published-set rebuild comparable. A reader
  who fixes #197 on the strength of these sentences will still get `different`. The prose should name `tune_run` as
  a second cause, or the recipe should stop carrying it (it is the grade tables' run, which the grade receipts
  already identify). This is the round-2 mechanism, left one field over.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (terminate by enumeration; enumerate
    every claim a diff makes about behaviour elsewhere and execute each); writing.md "State each claim by the code's
    definition".

- **[severity: fragile]** research/run_archive.md:104-106. "The revised tolerances, tried on the two real chinook
  receipts (`data-raw/grade_tolerance_try.R`), read half a tolerance as `equivalent` …". The tolerance tried is the
  grade declaration's 1e-3, which this branch left unchanged (line 103: "a grade table keeps 1e-3"). It comes from
  the receipts as written (`_grade_tolerance_try.txt`: "receipts declare: grade_sum 0.001 km_graded 0.001"), because
  crate takes each summary's tolerance from the receipts (`receipt_summary_tolerance()`), not from `keys`. The only
  tolerance that was revised, the grade set's 1e-2, has never been exercised on any receipt. The sentence certifies
  a revision that was never tested.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ("Compression runs both ways": an
    attribution widened to a second instance); "A fixture that cannot reach the failure mode" (a finding produced by
    one fixture describes that fixture).

- **[severity: fragile]** inst/receipt/evidence.yaml:8-9 and research/run_archive.md:118. "9.5e-11 km (#154's, on
  one database)". The rebuild was made in #145's promotion: `planning/archive/2026-11-issue-145-promote-retune/progress.md:6-8`,
  "Plain `0310` into `data/fdis/derived` … `access_check.csv` differs only in float summation order (max 9.5e-11
  km)". #154 only cites it as precedent (`planning/archive/2026-11-issue-154-provenance-receipts/task_plan.md:7`, "A
  rebuild … once gave"). The earlier text named no issue. This branch added the attribution, and it is wrong, in a
  provenance declaration that lists the measured rebuilds by issue.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ("Compression runs both ways": an
    attribution widened); agent-operations §3 "Documents that share an ancestor corroborate nothing" (read the
    source, not the restatement).

- **[severity: fragile]** inst/receipt/fdis.yaml:6. "0230's fdis_sites and fdis_repeat_surveys". `fdis_sites.csv`
  is written by `scripts/0240-fdis-evidence.R` (header OUTPUT line 28, `write_csv` at 156). `scripts/0299`'s INPUT
  names "scripts/0240, 0290, 0294, 0296" and says "fdis_sites (0240)". 0230 writes `fdis_repeat_surveys`
  (0230:604) and does the placement 0240 carries. A declaration that lists which scripts its unmeasured tables come
  from points the next comparison at the wrong script.
  - **Rule:** writing.md "State each claim by the code's definition".

- **[severity: fragile]** research/run_archive.md:12 (not in this diff), `R/grade_record.R:22` and
  `scripts/0336-archive.R:4`. The branch corrected the grade table's size to "0.3 to 2.5 GB" in `grade.yaml`'s
  register and in run_archive.md:75. The same claim still reads "0.7 to 5.6 GB each, about 26 GB a run" at
  run_archive.md:12, in roxygen, and in the archive script's header. The tracked records sum to 11.2 GB (290 MB to
  2.50 GB). run_archive.md now contradicts itself.
  - **Rule:** code-check.md "Documentation Staleness"; agent-operations §3 "Documents that share an ancestor
    corroborate nothing" ("when one instance is stale, grep for the sentence, not the file").

- **[severity: fragile]** inst/receipt/evidence.yaml:14-15. "crate rounds a value to the tolerance's decimals, so a
  comparison of receipts alone can read a value on either side of a rounding edge as different." This declaration
  holds a summary, `access_km` at 1e-3, and crate compares that as a band (`crt_receipt_compare.R:160`), so the
  sentence is false for it. CLAUDE.md:480 and run_archive.md:139 were corrected to "a table's value … (a total it
  compares as a band)" on this branch, and this copy was not. Separately, inst/receipt/habitat_grade.yaml:9 says the
  rebuild reads `different` on its recipe "before any total is compared". crate does not short-circuit on the
  recipe: it compares and lists every result field (`crt_receipt_compare.R` 75-170). The verdict is `different` in
  either case, but the sentence misdescribes what the comparison reports.
  - **Rule:** writing.md "State each claim by the code's definition"; agent-operations §3 "Documents that share an
    ancestor corroborate nothing".

- **[severity: fragile]** research/database_builds.md:262-263. "`0320` for chinook rearing 14.1 min (14 workers)
  and 17.4 min (8 workers …)". The committed logs this section cites say "Done in 14.0 min"
  (`receipt_165/20261112_tune_run-20261112_0648-p20261112064658-ch.txt:418`, the host) and "Done in 17.2 min"
  (`…0647….txt:418`, the second). The figures were copied from `planning/active/findings.md:97-98`, not the logs.
  The `0310` minutes (19.3, 11.9) appear in no committed log or ledger. They come only from findings.md, so they
  cannot be checked from the cited record.
  - **Rule:** code-check.md "One fact derived twice" (derive a number from the artifact it names).

- **[severity: fragile]** research/database_builds.md:259-260. "One new difference surfaced: the species columns of
  `visits_link` and `workbook_sites`". #158's committed comparison already shows `workbook_sites.csv` `identical` in
  values with `bytes_match` FALSE and no added column
  (`database_second/20261106_database_compare-evidence.csv`, row 7). That is the same signature #165 traced to the
  column order. The difference was explained on #165, not new, unless something else made #158's bytes differ, and
  nothing records that.
  - **Rule:** agent-operations §3 "Presence is not provenance"; code-check.md "A guard's scope, escape hatches, and
    remedies" (an addition: a sentence that gained a temporal claim is unsupported until the source is checked).

Code in the four data-raw scripts and the test: no defect found. The arithmetic in `grade_order_bound.R` and
`grade_receipt_compare.R` reproduces the logged numbers. The bound n x eps x sum|x| is a valid upper bound on the
difference between any two summation orders. `grade_tolerance_try.R` writes nothing. Lowering
`database_receipts.R`'s crate floor to 0.14.0 matches crate#49, and the script uses no API newer than that.
