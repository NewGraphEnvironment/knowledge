# Findings — Revise the receipt declarations from #158's verdicts, and test knowledge's grade receipt on a second database's regrade (#165)

## Issue context

**If we do it:** the tolerances in `inst/receipt/*.yaml` rest on a measured rebuild rather than on the one precedent #154 had, and knowledge's own `knw_grade_receipt_write()` is tested end to end: two databases' grade tables, receipts written by knowledge, verdicts from `crate::crt_receipt_compare()`, checked against verdicts already known. **If we never do:** the declarations stay marked provisional, and the first time a grade receipt is compared across rebuilds is a promotion, where a wrong tolerance either refuses a sound rebuild or passes a moved grade.

## Problem

#154 declared the grade, published-grade and thresholds receipts (`inst/receipt/grade.yaml`, `habitat_grade.yaml`, `thresholds.yaml`) as provisional until #158 measured a rebuild. Its archive owes the revision: "identical becomes exact; equivalent gets the rounding it was held to". #158 has since measured one (`scripts/logs/habitat/database_second/`, `research/database_builds.md`, "A second database"):

- every key's tuning tables and its grade record are identical; the pick never moved
- grade tables: BT spawning identical; GR equivalent (one rate on a 5-significant-digit rounding edge); BT and CH rearing, CO, ST and WCT different in segment size on 40 to 441 segments, through #161's parent-flow tie, which moved up to 276 grades on BT, CH and ST and none on CO and WCT
- #158's own comparison found a tolerance must not be finer than its writer's rounding: a one-unit flip at the stored precision fails an exact or finer tolerance in floating point. So "identical becomes exact" holds only where the writer does not round

#158 checked crate's comparison with receipts its own script wrote (`data-raw/database_receipts.R`), not with knowledge's writer, which landed after it.

Since #160 (PR #167): `inst/receipt/evidence.yaml` (every table exact but `access_check`'s km at 1e-6 km, set from #158's evidence verdicts) and `fdis.yaml` are declared too, and a grade receipt names the evidence as one input, `evidence`: the evidence build's receipt's `recipe_id`, or its visit tables' md5s for a build from before evidence receipts (`grade.yaml`'s inputs are `[link_build, flow, evidence]`). A regrade on an evidence directory without a receipt is named by the md5s; two evidence builds of the published build on one database already compared `equivalent` (`research/run_archive.md`).

## Proposed

**Scope (Al, 2026-11-06): chinook rearing only, on both databases, plus the evidence pair.** About 45 min of database time, enough to set the grade tolerances; every key would be about two hours. #161 (PR #166, knowledge 0.4.32) has merged, so the published grade tables, graded before it, differ from any regrade on the tied segments because of the fix itself, not the database. So both sides are regraded with the current code rather than one compared against the published table.

**Before starting, on each machine that runs a half.** Each database's half runs on that database's own host (a remote link makes `0310` and grading refuse without `REMOTE=TRUE`, and runs them far slower: 104 ms a round trip against 1.6 ms, #158). Either machine can drive the plan; neither runs the other's half.
- The checkout at `main` (0.4.36 or later: before it the receipt writers break under crate 0.16, #195), on a branch or in a worktree of its own; the tree clean.
- crate at or above the floor `DESCRIPTION` names (`pak::pak("NewGraphEnvironment/crate")`; `load_all()` refuses an older one). The same link version on both machines (0.78.1 built the published evidence), since link's installed default configs are part of the evidence recipe.
- The published FDIS build's inputs in `data/fdis/`: `build/sites.rds` and `build/reconcile.csv`, whose md5s are the published ledger's `md5_sites` (`scripts/logs/habitat/20261103_evidence_build_ledger.csv`; `PULL=TRUE scripts/0336-archive.R` restores both), `build/catch.rds` and `build/fish.rds` at the ledger's `md5_catch` and `md5_fish` (the archive does not hold these two: copy them from a checkout whose md5s match), and `MANIFEST.md5`, the FDIS extract's (0230 syncs it).
- The database holds the published build: `knw_build_record()` reads link run `20261103_163715-269b585a` and wet's 2026-10-24 flow load, and `pg_stat_activity` is quiet before anything is timed.
- Each evidence build into its own tagged directory (`EVIDENCE_DIR=data/fdis/derived_<name>`), so the default directory and its ledger stay the published build's; an evidence build from before 0.4.32 is not reused, since the tie fix moves `mad_pick` on the tied visits.

- [ ] Regrade chinook rearing on each database with the current code: `RUN=<stamp> 0320` against the published pick (11 min for the key on the second database), once on the host's database and once on the second, each on that database's own evidence build (next task)
- [ ] Compare two evidence builds' receipts on one recipe: `0310` on each database (about 12 min each), then `crt_receipt_compare(tables =)` with `knw_receipt_keys("evidence")`, as `data-raw/evidence_receipt_compare.R` does. #160 declares `visits_link` exact, and #161's tie was the only `different` #158 found in it, so expect `identical` or `equivalent`; record it in `research/run_archive.md` (moved here from #161)
- [ ] Measure, on the two chinook rearing grade tables, the summaries the grade declaration reads (`rows`, `graded_rows`, `km_graded`, `grade_sum`) and how far they move; write both receipts with `knw_grade_receipt_write()` and compare them with `crt_receipt_compare()`. Expected after #161: identical, since grading reads the parent flow live. Record the verdict beside #158's
- [ ] Revise each declaration from #158's verdicts, its writers' rounding and the measurement above. Keep the grade record's `null_heldout_curve` at 1.0e-4, the four decimals `0320` writes, rather than making it exact. Set `km_graded` and `grade_sum` from the chinook measurement, not from a guess, and keep or remove the "provisional" note in each file to match
- [ ] Drop the `IDate` → `Date` conversion in `data-raw/database_receipts.R` (lines 68–69, "crate … refuses data.table's IDate"): crate 0.14.0 fingerprints an `IDate` as the `Date` it is, to the same bytes ([crate#49](https://github.com/NewGraphEnvironment/crate/issues/49)). Needs crate ≥ 0.14.0 installed on each host first
- [ ] Out of scope here: the other keys' regrade on both databases (about 50 min per database). A tolerance set from chinook alone holds for them only as far as their grades behave alike; #158 found BT and ST moved by the same tie, so they are the keys to check first if a later promotion compares their receipts

Relates to #154 (its owed item, which also asked for this task in #158's body; #158 is closed, so it lives here), #158, #161, #160 (the evidence build's receipt)

## Phase 1: the two hosts (2026-11-12)

Both databases answer `knw_build_record(con, "fresh_default")` with run `20261103_163715-269b585a`, wet's
2026-10-24 load (`wet b4bbc50`), walk md5 `c3f7bdbecff1d55107f28afa59d7f532`, fresh 0.52.0, tokens
`cut-full-top.acc-v5.grad-seg.q-fwapg`. Both checkouts at `89b7a32` (clean), crate 0.16.0 (the host's raised from
0.15.1 at the gate), link 0.78.1, R 4.5.2. The five FDIS inputs carry the 20261103 ledger's md5s on both.

`pg_stat_activity` at launch: the host's database quiet; the second's had another session's link test run
(`lnk_test_export_*` schemas, short queries). It writes its own schemas, not `fresh_default`, so it cannot move a
result, but timings taken on the second database overlap it.

**HEAD stays at `89b7a32` on the second's checkout until both regrades finish**: every receipt records the knowledge
commit, so a commit on the branch between the two halves (even a planning-only one) would make the two recipes differ
for a reason that is not the database.

## Phase 5 probe: crate 0.16.0 and data.table's IDate (2026-11-12)

A three-row table read back by `fread()` (date column as `IDate`) and the same table with the column converted to
`Date`, each written with `crt_receipt_write()`: the table fingerprints are the same sha256 (`d6192eb2…`) and
`crt_receipt_compare()` reads `identical`; the same table with one date moved by a day reads `different`, so the probe
can fail. The conversion in `data-raw/database_receipts.R` is no longer needed (crate#49, fixed from 0.14.0).

Session info (`scripts/logs/habitat/receipt_165/20261112_sessioninfo-{host,second}.txt`): same knowledge commit, R,
mgcv 1.9-3, Matrix 1.7-4, Accelerate BLAS and R's LAPACK 3.12.1 on both. Two differences, neither in code: crate 0.16.0
from `8d5b679` on the host and `fdfe64d` (the release) on the second, which differ only in `CITATION.cff` and a planning
archive; link 0.78.1 from `fd91d1b` (v0.78.1) on the host and a local install with no RemoteSha on the second, which the
evidence recipe's `link_configs` (sha256 of link's installed default configs) will compare. The host runs macOS 26.6,
the second 15.6.

Plan review (`review-plan.md`) folded into task_plan.md; its claim that crate compares summaries as a band and rounds
only table cells was read in crate origin/main 0.16.0 (`R/crt_receipt_compare.R:160`).

## Phase 2: the evidence pair across two databases (2026-11-12)

`0310` at `89b7a32` on each database: the host's 19.3 min (06:27-06:46 UTC), the second's 11.9 min (06:27-06:39, with
another session's link tests on that database). Both placed 45,529 visits, 775,488 walk rows; the hydrologic-zones zip
downloaded by each had one md5 (`f369d684…`).

- One `recipe_id` (`6ee82a79…`): link's installed configs hash the same on both, so the link installs (one from the
  v0.78.1 tag, one local) carry the same default bundle.
- crate (`data-raw/evidence_receipt_compare.R`): `equivalent` on the receipts alone and with the tables re-read
  (2.2 min). Result fields that moved: `access_check`'s bytes and sha256 (table agrees within 1e-6 km),
  `visits_link`'s and `workbook_sites`' sha256 (tables agree), `access_km` 6937234.1350527825 against
  6937234.135052781 (within 1e-3). A grade receipt written against the host's build names its `recipe_id`.
- Hand (`data-raw/database_compare.R`): six tables `identical`, `access_check` `equivalent` at 5.28e-11 km at most over
  2,193 rows. `bcfishobs_fdis_match`, `visits_species`, `walks`, `workbook_species` byte-identical.
- `visits_link` and `workbook_sites` differ in bytes only: the species column groups come out in another order on each
  database (`pk, sk, st, wct, gr, ko, rb` on the host; alphabetical on the second), because `knw_link_place()` reads the
  species from `information_schema.columns` with no `ORDER BY` (`R/link_place.R:50-57`). Filed as #197.
  crate fingerprints a table independent of column order, so no verdict moves.
- `visits_link`'s `mad_pick`, which differed on 3 visits in #158 through #161's tie, is identical: the tie fix holds
  across the two databases on the evidence as it did on the parent-flow lines.

So the evidence declaration's rule (every table exact but `access_check`'s km at 1e-6 km) held across two databases
with knowledge's writer: `access_check` moved 5.3e-11 km, four orders inside its rounding, and `access_km` 1.5e-9 km.

## Phase 3: chinook rearing regraded on each database (2026-11-12)

`SPECIES=CH 0320` at `89b7a32`, each on its own evidence build: the host's run `20261112_0648` 14.1 min (scoring on 14
workers), the second's `20261112_0647` 17.4 min (scoring 15.1 min on 8 workers, overlapping another session's link
tests). Every walk came from each database's cache (876,268 hits, 0 misses), so #162's cold walks were not exercised.

- **Grade receipts (knowledge's writer, `data-raw/grade_receipt_compare.R`): `identical`.** One `recipe_id`
  (`23294262…`), whose evidence input is the evidence builds' shared `recipe_id`; the same pick; `rows` 3,016,042,
  `graded_rows` 872,418, `km_graded` 232,928.75963606851, `grade_sum` 253,887.60172207703 on both, bit for bit. The
  only result field listed is the table's sha256 (`warn`, as declared).
- **The tables:** every segment's grade and length the same, in the same row order. They differ in bytes only through
  `evidence_md5`, whose first md5 is `visits_link.csv`'s, the table #197's column order changes.
- **Hand comparison of every tune output (`database_compare.R`, `LABEL=tune165`):** ten identical (curves, groups,
  honest, seeds, tune, summaries, pick report, grade table and record, context columns aside); the smoke table
  `equivalent` at 2.27e-13 (a score summed with another worker count; no decision reads it).
- So after #161 the grade comparison #158 read `different` on chinook (segment sizes on the tied segments) reads
  `identical`, as expected: grading reads each segment's parent flow live.

**How far the order of summing can move the sums** (`data-raw/grade_order_bound.R` over the published grade tables,
read-only on the host's checkout; `receipt_165/20261112_grade_order_bound.txt`). Seen over four orders and bounded by
n × eps × Σ|x|:

| output | graded rows | km_graded: seen / bound | grade_sum: seen / bound |
|---|---|---|---|
| BT rearing (largest) | 2,120,275 | 8.1e-8 / 2.7e-4 | 4.2e-8 / 2.7e-4 |
| CH rearing | 872,418 | 3.1e-8 / 4.5e-5 | 2.9e-9 / 4.9e-5 |
| ST rearing | 753,056 | 2.8e-8 / 3.0e-5 | 2.3e-8 / 3.5e-5 |
| GR rearing | 492,971 | 4.2e-9 / 1.6e-5 | 4.1e-9 / 2.6e-5 |
| published set | 4,238,720 | 8.7e-7 / 1.07e-3 | 3.4e-7 / 1.20e-3 |

BT spawning, CO and WCT have no graded rows (their grades are withheld). By the gate's rule: `grade.yaml`'s
`km_graded` and `grade_sum` stay at 1e-3 (strictly above BT's 2.7e-4 and grade_sum's writer unit 1e-5), now on a
measured basis; `habitat_grade.yaml`'s become 1e-2 (strictly above the set's 1.07e-3 and 1.20e-3).

## Phase 4: the declarations revised (2026-11-12)

| declaration | tolerance before | after | rests on |
|---|---|---|---|
| grade | km_graded, grade_sum 1e-3; pick gate 1e-4 | unchanged | BT rearing's order bound 2.7e-4; chinook identical on two databases |
| habitat_grade | km_graded, grade_sum 1e-3 | **1e-2** | the published set's order bound 1.07e-3 and 1.20e-3 |
| thresholds | exact | exact | #158's identical tune tables (no thresholds receipts compared yet) |
| evidence | access_check km 1e-6, access_km 1e-3 | unchanged | #160, #158 and #165's pair (5.3e-11 km) |
| fdis | access_check km 1e-6 | unchanged | the evidence build's |

"Provisional" is gone from every header; each says what it rests on. Tried on the real chinook receipts
(`data-raw/grade_tolerance_try.R`, `receipt_165/20261112_grade_tolerance_try.txt`): as measured `identical`; each total
moved by half its tolerance `equivalent`, by three times `different`; a count moved by one `different`. Restoring 1e-3 on
`habitat_grade`'s km in a scratch copy turns `test-receipt.R`'s pin red. The receipt test files pass (test-receipt 93,
test-grade_receipt 50, test-evidence_receipt 29, test-publish 30).

crate checks: a total is compared as a band (`crt_receipt_compare.R:160`); a table's columns and rows are sorted (by
name, by canonical row) and its cells rounded to the tolerance's decimals before hashing (`crt_table_fingerprint.R`).
