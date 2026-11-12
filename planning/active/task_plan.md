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
  **Freeze (plan review):** no commit, no staging under `R/`, `scripts/` or `inst/`, and no edit under `inst/` in m1's
  worktree until both `0320` runs have written their receipts: `knw_receipt_keys()` reads `inst/receipt/*.yaml` from
  the source tree when the receipt is written, and the dirty flag counts staged files. Work in between stays
  uncommitted in `planning/` and `data-raw/`.
- Evidence directories are `data/fdis/derived_165_host` (m4) and `data/fdis/derived_165_second` (m1); verdicts and logs
  are committed under `scripts/logs/habitat/receipt_165/`, while each evidence ledger stays where `0310` writes it
  (`scripts/logs/habitat/`), because `.knw_evidence_ledger()` does not look in subfolders. No machine names in tracked
  text (the repo's rule): "host" and "second" as #158 wrote them.
- m4's crate is brought up to m1's 0.16.0 (`pak::pak("NewGraphEnvironment/crate")`), so both sides write receipts
  under one crate register.
- How each summary tolerance is set. crate compares a summary as a band, `abs(a - b) <= tol`
  (`crt_receipt_compare.R:160`), and rounds only a table's cells to the tolerance's decimals. A summary's tolerance is
  the smallest power of ten strictly above each of: the move measured across the two databases; the float error a sum
  can carry when summed in another order (n × machine epsilon × Σ|x|), computed for the **largest** key's published
  grade table (one declaration serves every key) and for the published grade set; and, where a writer rounds the
  values summed, one unit of that rounding (one flipped grade moves `grade_sum` by up to 1e-5). Exact only for counts.
- "Provisional" leaves a declaration's header when its output has been compared across two databases with knowledge's
  own writer (grade, evidence) or follows from one that has (fdis from evidence, `habitat_grade` from grade), or from
  #158's verdicts on what it binds (thresholds from the identical tune tables); each header names what it rests on and
  that the grade tolerances come from chinook alone, with #162's cold walks not exercised while walks come from cache.

## Phase 1: Prepare both hosts
- [x] m1: confirm `knw_build_record()` names run `20261103_163715-269b585a` and wet's 2026-10-24 load; read `pg_stat_activity`
- [x] m4: update crate to 0.16.0; create worktree `~/Projects/repo/knowledge-165` at the pushed branch tip (detached);
      copy `data/fdis/build/{sites,catch,fish}.rds`, `reconcile.csv`, `data/fdis/MANIFEST.md5` from m4's checkout and
      check their md5s against the 20261103 ledger (the three .rds) and m1's copies (`reconcile.csv`, `MANIFEST.md5`);
      same `knw_build_record()` and `pg_stat_activity` checks with `PGSERVICE=fresh_local`; `../link` holds `4dfbfa49`
      on both
- [x] Record both hosts' versions (knowledge commit, crate, link, R) and `sessionInfo()` (mgcv, Matrix, BLAS) in
      `scripts/logs/habitat/receipt_165/`

## Phase 2: Evidence build on each database
- [x] `EVIDENCE_DIR=data/fdis/derived_165_host Rscript scripts/0310-evidence-build.R` on m4 and
      `EVIDENCE_DIR=data/fdis/derived_165_second ...` on m1, at the same time (about 12 min each); verify each finished
      by its `evidence_receipt.json` and a non-refused tagged ledger, not by ssh's exit status
- [x] Compare the two ledgers' `zone_zip` md5 (downloaded fresh by each run) and the two receipts' recipe fields
      (`link_configs` included) before reading any verdict
- [x] Copy m4's evidence directory and its ledger to m1 (`scp`, about 200 MB); run
      `data-raw/evidence_receipt_compare.R <host> <second>` (crate verdict, receipts alone and with tables re-read) and
      `REF=… NEW=… LABEL=evidence OUT=scripts/logs/habitat/receipt_165/… data-raw/database_compare.R` (hand verdict);
      expect one `recipe_id` and `identical` or `equivalent`, now that #161 is fixed. A `different` is traced to its
      rows before going further
- [x] After both regrades: commit the verdicts and logs under `receipt_165/` (ledgers where `0310` wrote them); record
      the pair in `research/run_archive.md` ("The evidence build"), beside #160's same-database pair

## Phase 3: Chinook rearing regrade on each database
- [x] `SPECIES=CH RUN=<stamp> EVIDENCE_DIR=<that host's build> Rscript scripts/0320-tune-run.R` on each host (about
      11 min each), with **different stamps** on the two hosts; smoke gates first as `0320` does; note each log's
      walk-cache misses (a cold walk can differ by #162)
- [x] md5 the two `CH_rear_grades.csv` on their hosts; copy m4's candidate (grade table about 1.9 GB) into scratch on
      m1, never into m1's `data/tune/candidate/`; run `database_compare.R` over the two candidates (`LABEL=tune165`,
      `OUT=` under `receipt_165/`) for every tune output and the grade table
- [x] Compare the two `CH_rear_grades_receipt.json` with
      `crate::crt_receipt_compare(keys = knw_receipt_keys("grade"))`; measure how far `rows`, `graded_rows`,
      `km_graded`, `grade_sum` move, and how far the order of summing moves each sum. Expected: identical (grading reads
      the parent flow live since #161). A `different` is traced to its segments and its cause (#162's walks, a tie)
      before any tolerance is set from it. Script: `data-raw/grade_receipt_compare.R`, output to `receipt_165/`
- [x] Compute the order bound for every published key's grade table and for the published set (read-only, from the
      host's checkout, which holds the published tables)
- [x] Record the verdict in `research/database_builds.md` beside #158's table

## Phase 4: Revise the declarations
- [x] `grade.yaml`: keep `pick.null_heldout_curve` at 1.0e-4 (`0320` writes four decimals; the header says a change in
      the fourth decimal reads `different`, since a table's cells are rounded to that decimal); `rows` and `graded_rows`
      exact; `km_graded` and `grade_sum` by the rule above; header rewritten to say what they rest on, with the table
      sizes the records give (0.29 to 2.5 GB); "provisional" by the criterion above
- [x] `habitat_grade.yaml`: the same summaries, by the same rule over the published set
- [x] `thresholds.yaml`: exact, resting on #158's identical tune tables (said in the header)
- [x] `evidence.yaml`, `fdis.yaml`: tolerances from #158's and Phase 2's verdicts; the `visits_link` comment updated
      now that #161 is fixed; "provisional" by the criterion above
- [x] Try the revised declarations on both chinook receipts (grade's values are unchanged, so in memory, as read;
      `data-raw/grade_tolerance_try.R`): each measured
      move falls within its new tolerance, and a move three times the tolerance is refused; recorded beside the verdict
- [x] Update what pins or restates the tolerances: `test-receipt.R` (the pin at 119-134, its title and the 1 mm
      comment), `test-grade_receipt.R:73-82`, `test-evidence_receipt.R:72-73`, `test-publish.R:149-150`;
      `research/run_archive.md` (the table, "about a metre of graded km", "These roundings are provisional", and the
      rounding-edge text, which holds for tables, not summaries); `CLAUDE.md` (459, and 478-480 likewise). NEWS: written by `/gh-pr-merge`'s release commit, as every
      entry since 0.4.31 was, so the line goes in the PR body (corrected during Phase 4)

## Phase 5: database_receipts.R
- [x] Probe that crate 0.16.0 gives a table with an `IDate` column the same fingerprint as the `Date` it is (crate#49)
      and that a moved date is caught (findings.md)
- [x] Remove the `IDate` → `Date` conversion (`data-raw/database_receipts.R:68-69`) and its comment; check the script
      still parses

## Owed at the end (reported, done after merge)

- [ ] Remove the m4 worktree `~/Projects/repo/knowledge-165` and the scratch copies (m4's evidence and candidate on
      m1), on Al's word

## Validation

- [x] Tests pass (`devtools::test()`, `test-receipt.R` in particular)
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: each verdict is reproduced by two independent routes (crate's comparison of knowledge's receipts, and
`database_compare.R`'s hand comparison of the same files); the revised tolerances are pinned by `test-receipt.R:119-134`
("the declared tolerances are the ones written down"), and restoring an old tolerance in a scratch copy must turn that
test red; the revised declarations are tried on the real chinook receipts (Phase 4).
