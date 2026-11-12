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
