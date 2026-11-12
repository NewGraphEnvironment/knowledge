# Task: Revise the receipt declarations from #158's verdicts, and test knowledge's grade receipt on a second database's regrade (#165)

## Problem

#154 declared the grade, published-grade and thresholds receipts (`inst/receipt/grade.yaml`, `habitat_grade.yaml`, `thresholds.yaml`) as provisional until #158 measured a rebuild. Its archive owes the revision: "identical becomes exact; equivalent gets the rounding it was held to". #158 has since measured one (`scripts/logs/habitat/database_second/`, `research/database_builds.md`, "A second database"):

- every key's tuning tables and its grade record are identical; the pick never moved
- grade tables: BT spawning identical; GR equivalent (one rate on a 5-significant-digit rounding edge); BT and CH rearing, CO, ST and WCT different in segment size on 40 to 441 segments, through #161's parent-flow tie, which moved up to 276 grades on BT, CH and ST and none on CO and WCT
- #158's own comparison found a tolerance must not be finer than its writer's rounding: a one-unit flip at the stored precision fails an exact or finer tolerance in floating point. So "identical becomes exact" holds only where the writer does not round

#158 checked crate's comparison with receipts its own script wrote (`data-raw/database_receipts.R`), not with knowledge's writer, which landed after it.

Since #160 (PR #167): `inst/receipt/evidence.yaml` (every table exact but `access_check`'s km at 1e-6 km, set from #158's evidence verdicts) and `fdis.yaml` are declared too, and a grade receipt names the evidence as one input, `evidence`: the evidence build's receipt's `recipe_id`, or its visit tables' md5s for a build from before evidence receipts (`grade.yaml`'s inputs are `[link_build, flow, evidence]`). A regrade on an evidence directory without a receipt is named by the md5s; two evidence builds of the published build on one database already compared `equivalent` (`research/run_archive.md`).



## Context

#154 declared the grade, published-grade and thresholds receipts (`inst/receipt/{grade,habitat_grade,thresholds}.yaml`)
as provisional until a rebuild was measured; #160 added `evidence.yaml` and `fdis.yaml`, also provisional. #158 measured
one rebuild, but with receipts its own script wrote (`data-raw/database_receipts.R`), not with knowledge's writer, and
before #161's parent-flow tie fix. This issue regrades **chinook rearing only** on both databases with the current code
(Al, 2026-11-06), builds the evidence on each, compares the receipts that knowledge's own writers produce, and sets the
tolerances from that measurement rather than from the single precedent #154 had.

State found while exploring (2026-11-11):
- Host database = m4's (`PGSERVICE=fresh_local`); second = m1's default `PG*`. Both hold link run
  `20261103_163715-269b585a` (memory; re-checked in Phase 1 with `knw_build_record()`).
- The published FDIS inputs (`sites.rds`, `catch.rds`, `fish.rds`, `reconcile.csv`, `MANIFEST.md5`) match the
  20261103 ledger's md5s in this worktree's ignored `data/fdis/` (m1) and in m4's main checkout.
- link 0.78.1 on both. crate 0.16.0 on m1, **0.15.1 on m4**: matched before anything runs.
- m4's main checkout sits at an older main (`333441a9`) with the published build in its `data/`: left untouched; m4's half
  runs in a fresh worktree.
- #158's own second-database outputs (`derived_second`, candidate `20261106_0423`) no longer exist on m1, so
  `database_receipts.R` cannot be re-run end to end; its `IDate` change is checked by a probe instead.
- No receipt JSON is tracked yet, so revising a tolerance strands no earlier receipt.
- `0320` writes `<key>_grades_receipt.json` itself (`knw_grade_receipt_write()`, `R/grade_receipt.R:109-111`:
  `rows`, `graded_rows`, `km_graded`, `grade_sum`); `data-raw/database_compare.R` already gives hand verdicts for
  tune and grade tables (grades keyed on `watershed_group_code;id_segment`, 1e-5); `data-raw/evidence_receipt_compare.R`
  gives the evidence pair's crate verdict.

## Decided at the gate

- Scope is chinook rearing on both databases plus the evidence pair (Al, 2026-11-06, in the issue body). The other six
  keys' regrade is out of scope: a tolerance set from chinook holds for them only as far as their grades behave alike;
  BT and ST are the ones to check first if a later promotion compares their receipts.
- Both halves run at one commit, the pushed branch tip after the baseline commit, from clean trees (the receipts record
  the commit and a dirty flag, so the two recipes match only then). On m4 that means a worktree of its own
  (`~/Projects/repo/knowledge-165`) with the five FDIS inputs copied from m4's checkout; m4's checkout is not touched.
- Evidence directories are `data/fdis/derived_165_host` (m4) and `data/fdis/derived_165_second` (m1); logs and
  verdicts are committed under `scripts/logs/habitat/receipt_165/`. No machine names in tracked text (the repo's rule):
  "host" and "second" as #158 wrote them.
- m4's crate is brought up to m1's 0.16.0 (`pak::pak("NewGraphEnvironment/crate")`), so both sides write receipts
  under one crate register.
- How each summary tolerance is set: the smallest power of ten that is at or above both the measured move and the
  float error a sum of that size can carry when summed in another order (n × machine epsilon × Σ|x|), and never finer
  than the writer's own rounding (#158's rule). Exact only where the value is a count, or is copied, not summed.

## Phase 1: Prepare both hosts
- [ ] m1: confirm `knw_build_record()` names run `20261103_163715-269b585a` and wet's 2026-10-24 load; read `pg_stat_activity`
- [ ] m4: update crate to 0.16.0; create worktree `~/Projects/repo/knowledge-165` at the pushed branch tip (detached);
      copy `data/fdis/build/{sites,catch,fish}.rds`, `reconcile.csv`, `data/fdis/MANIFEST.md5` from m4's checkout and
      check their md5s against the 20261103 ledger; same `knw_build_record()` and `pg_stat_activity` checks with
      `PGSERVICE=fresh_local`
- [ ] Record both hosts' versions (knowledge commit, crate, link, R) in `scripts/logs/habitat/receipt_165/`

## Phase 2: Evidence build on each database
- [ ] `EVIDENCE_DIR=data/fdis/derived_165_host Rscript scripts/0310-evidence-build.R` on m4 and
      `EVIDENCE_DIR=data/fdis/derived_165_second ...` on m1, at the same time (about 12 min each); verify each finished
      by its `evidence_receipt.json` and a non-refused tagged ledger, not by ssh's exit status
- [ ] Copy m4's evidence directory to m1 (`scp`, about 200 MB); run
      `data-raw/evidence_receipt_compare.R <host> <second>` (crate verdict, receipts alone and with tables re-read) and
      `REF=… NEW=… LABEL=evidence data-raw/database_compare.R` (hand verdict); expect one `recipe_id` and
      `identical` or `equivalent`, now that #161 is fixed. A `different` is traced to its rows before going further
- [ ] Commit the ledgers, logs and verdicts under `receipt_165/`; record the pair in `research/run_archive.md`
      ("The evidence build"), beside #160's same-database pair

## Phase 3: Chinook rearing regrade on each database
- [ ] `SPECIES=CH RUN=<stamp> EVIDENCE_DIR=<that host's build> Rscript scripts/0320-tune-run.R` on each host (about
      11 min each), smoke gates first as `0320` does; note each log's walk-cache misses (a cold walk can differ by #162)
- [ ] md5 the two `CH_rear_grades.csv` on their hosts; copy m4's candidate (grade table about 1.9 GB) to m1; run
      `database_compare.R` over the two candidates (`LABEL=tune165`) for every tune output and the grade table
- [ ] Compare the two `CH_rear_grades_receipt.json` with
      `crate::crt_receipt_compare(keys = knw_receipt_keys("grade"))`; measure how far `rows`, `graded_rows`,
      `km_graded`, `grade_sum` move, and the float error bound for each sum. Expected: identical (grading reads the parent
      flow live since #161). Script: `data-raw/grade_receipt_compare.R`, written to `receipt_165/`
- [ ] Record the verdict in `research/database_builds.md` beside #158's table

## Phase 4: Revise the declarations
- [ ] `grade.yaml`: keep `pick.null_heldout_curve` at 1.0e-4 (`0320` writes four decimals); `rows` and `graded_rows`
      exact; `km_graded` and `grade_sum` set by the rule above from Phase 3; rewrite the header comment to say what
      they rest on; drop "provisional" if the measurement supports it
- [ ] `habitat_grade.yaml`: the same summaries over the published set's sum of keys, scaled by the same rule
- [ ] `thresholds.yaml`: exact (#158 found every tune table identical), "Provisional until #158" removed
- [ ] `evidence.yaml`, `fdis.yaml`: tolerances from #158's and Phase 2's verdicts; the `visits_link` comment updated
      now that #161 is fixed; "provisional" kept or removed to match
- [ ] Update `tests/testthat/test-receipt.R`'s pinned tolerances; `research/run_archive.md`'s table and "These
      roundings are provisional" paragraph; `CLAUDE.md`'s "provisional until #158"; NEWS line

## Phase 5: database_receipts.R
- [ ] Remove the `IDate` → `Date` conversion (`data-raw/database_receipts.R:68-69`) and its comment; probe first that
      crate 0.16.0 writes the same receipt for a table with an `IDate` column as with the `Date` it is (crate#49), and
      that the script still parses; record the probe in `progress.md`

## Owed at the end (reported, done after merge)

- [ ] Remove the m4 worktree `~/Projects/repo/knowledge-165` and the scratch copies (m4's evidence and candidate on
      m1), on Al's word

## Validation

- [ ] Tests pass (`devtools::test()`, `test-receipt.R` in particular)
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: each verdict is reproduced by two independent routes (crate's comparison of knowledge's receipts, and
`database_compare.R`'s hand comparison of the same files); each revised tolerance is pinned by `test-receipt.R`'s
"holds a value moved within it and refuses one moved past it" test, so a tolerance edit that the test does not see
fails; restoring the old tolerance in a scratch copy must turn the pin test red.

