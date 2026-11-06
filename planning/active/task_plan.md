# Task: Run a retune on the second database: chinook rearing first, then every key, against the published run (#158)

## Problem

A second database now holds the build the published retune (#145, run `20261104_0543`) read: link's `fresh_default` (run `20261103_163715-269b585a`) and `fresh_default_minimal` (run `20261102_203300-60ab009d`), wet's 2026-10-24 segment flows, and the walk cache, loaded as `research/database_builds.md`, "A second database", describes. The FWA, bcfishobs, CABD and PSCIS loads already matched the host's.

What has been checked there (2026-11-06):

- link's `data-raw/logs/provincial_246/verify_extra.sql` passes for both builds (241 groups each)
- `knw_build_record()` (0.4.29) reads both builds with the 2026-10-24 flow load and refuses neither
- the flow table holds the manifest's 102,790,688 rows, and exact row counts of every table read agree with the host's
- `0310`'s settle gate would pass: the newest `scripts/logs/habitat/<date>_link_settle.csv` ends `released` on run `20261103_163715-269b585a`, the run the second database's `fresh_default` holds

What has not: anything that queries the build. `knw_build_record()` passing means the build is recognised, not that `0310`, `0320`'s grading or `0330` complete there, or that they produce what the host produced.

Two facts that shape the test:

- `0310` has no `SPECIES`: one evidence build covers every species, so the evidence half of the test is the whole build, even for one key.
- The evidence build (`data/fdis/derived`) is untracked, so the second machine's copy is not the host's. The published run's outputs in `data/tune/` are tracked and are the reference for `0320`.


## Context

The second database is this machine's own, reached with the default `PG*` values R reads (round trip 1.7 ms). Checked read-only on 2026-11-06:
`fresh_default` holds run `20261103_163715-269b585a` (241 groups), `fresh_default_minimal` holds `20261102_203300-60ab009d`, the flow comment is
wet's 2026-10-24 build (`b4bbc50`), `knw.walk_cache` holds 6,532,230 rows, and no other session was active.

The reference is the published run `20261104_0543`: tracked `data/tune/*` and `data/compare/*`, plus its ignored files in the bucket archive
(batch `20261104T073508Z-de09068f`). Exploration found five things the issue's steps don't cover:

1. **This worktree has no `data/fdis/`.** The main checkout's `build/fish.rds` and `catch.rds` match the published ledger's md5s, but its
   `sites.rds` does not (98d4… against 39f7…), and its `derived/` is the 2026-10-25 build. So `PULL=TRUE GRADES=TRUE scripts/0336-archive.R` restores
   the host's evidence, `build/sites.rds`, curves, grade tables and segments into this worktree as the reference. 284 GB of disk is free.
2. **The installed link is 0.68.0, and `0310` needs ≥ 0.78.1.** The published evidence was built with link **0.78.1** installed (the ledger's
   `link_version`), and `0310` reads each species' range from the installed link, so I install exactly `v0.78.1` to reproduce `in_range`.
   fresh stays at 0.52.0, the run's version (`PKGSTALE` lists 0.53.0; not upgraded).
3. **`DEV=1 0320` grades nothing** (its header says so), and grading is the step the issue most wants tested. So the tuning step is a full
   candidate run: `SPECIES=CH RUN=<stamp>`, then the same `RUN=<stamp>` with no `SPECIES`. The second run reuses CH's score cache and grades only
   the keys still missing. The output is an ignored candidate under `data/tune/candidate/<stamp>/` and is never promoted. I'll correct the
   issue body to match.
4. **The restored walk cache would hide the walk.** Every walk the published run made sits in the cache, so `0310` and the grade would read
   walks without computing any on this database. I add a cold check: `knw_link_walks(cache = FALSE)` over every visit start (all 3 sources and
   7 sizes), compared with the host's `walks.csv`, plus a random sample of CH grade starts compared with the cached rows.
5. **The code has moved since the published run.** That run's commit was `2aacd1f`; since then #120's setups changed `R/grade_species.R`,
   `R/link_segments.R`, `0310`, `0320` and `0330`, meant to leave a `segment_gradient` run as it was.

## Decided at the gate (for approval)

- **Code version: run at main (4060cb2)**, so a run here afterwards is an ordinary run. If a step gives a `different` in something a decision
  reads, I rerun only that step from a worktree at `2aacd1f`, which tells a code change from a database difference. *Alternative:* run everything
  at `2aacd1f`. That is a cleaner reproduction, but it says nothing about current code here.
- **link `v0.78.1` installed** (`pak::pak("NewGraphEnvironment/link@v0.78.1")`); fresh stays at 0.52.0.
- **The scratch evidence directory is `data/fdis/derived_second`** (ledger `-derived_second`). No host name appears in tracked files.
- **`0330` runs with `GPKG=FALSE`**: the GeoPackages are a QGIS view, not something a decision reads.
- **Al's word for the full `0320`/`0330`:** this issue and this approval are that word. Neither run is promoted, and `0335`/`0336` are not run on
  the candidate.
- **crate (owner, 2026-11-06):** record the verdicts by hand. Once crate PR #44 merges, install it and run the issue's last provenance task in
  this branch, not later. PR #44 was still open at planning time; installed crate is 0.8.0.

## Phase 1: Inputs and reference

- [x] Install link `v0.78.1`. Confirm `packageVersion("link") == "0.78.1"` and fresh 0.52.0
- [x] `PULL=TRUE GRADES=TRUE Rscript scripts/0336-archive.R` into this worktree. Check every md5 against the records and the published ledger
      (`visits_link` db5ca99a…, `visits_species` 6a2e28f1…, `walks` 2e0f0f41…; `sites.rds` 39f751b1…)
- [x] Copy `fish.rds` and `catch.rds` from the main checkout's `data/fdis/build/`, after checking their md5s against the ledger
- [x] The archive holds 4 of the 8 evidence tables; the other four (`bcfishobs_fdis_match`, `access_check`, `workbook_sites`, `workbook_species`) copied from the host's checkout, whose 3 archived tables match the ledger md5s and were written with them (2026-11-03 22:42)
- [x] `SCHEMA=fresh_default Rscript scripts/0336-archive.R` (read-only mode): does this database still hold the run's build, flows and walk?
- [ ] Read `pg_stat_activity` before each timed step

## Phase 2: The comparison tool, then chinook rearing

- [x] `data-raw/database_compare.R`: given a reference and a candidate (directories or files), write one row per output in the receipt shape:
      `output, verdict (identical|equivalent|different), bytes_match, rows_ref, rows_new, max_diff, column, tolerance, decision_read, note`.
      Content is compared after sorting rows on each table's key and matching columns by name, with floats compared to a declared tolerance.
      Context (paths, timestamps, ledger lines naming the host or the time, `knowledge_commit`) is reported and never fails the comparison.
      Tests: identical, equivalent and different on fixtures, and a planted 1e-6 km change goes `different` at a 1e-9 tolerance
- [x] `EVIDENCE_DIR=data/fdis/derived_second Rscript scripts/0310-evidence-build.R`, logging its wall time. Compare against the restored
      `data/fdis/derived` (visits, placements, walks, flows), and its ledger against the published one, line by line, context aside
- [x] Cold walk check (`data-raw/database_walk_check.R`): every visit start, uncached, against the host's `walks.csv`; and 20,000 sampled CH grade
      starts (fixed seed), uncached, against the cache. Write the verdict rows and the minutes
- [x] `SPECIES=CH RUN=<stamp> EVIDENCE_DIR=data/fdis/derived_second Rscript scripts/0320-tune-run.R`. Compare the smoke results, tune, seeds,
      honest, curves, summary and pick (`mad>=0.75|g<=0.13|Q3@D1000`) against `data/tune/CH_rear_*`. Compare the grade record, and the grade
      table by md5 first and by content where the md5 differs, against the restored `CH_rear_grades.csv`
- [x] `TUNE_DIR=data/tune/candidate/<stamp> SPECIES=CH CONFIG_SHA=e2a85938… GPKG=FALSE Rscript scripts/0330-compare.R`. Compare km drawn and graded, plus change,
      checks and compare, against `data/compare/CH_rear_*`
- [x] ~~Machine control (review G4)~~ not run: tune, seeds, honest and curves came out byte-identical, so the machine does not move scoring, and the grade differences trace to segment sizes (#161), which the evidence does not set. Was: `SPECIES=CH RUN=<stamp2> WORKERS=8 Rscript scripts/0320-tune-run.R` on the restored host evidence
      (default `data/fdis/derived`). Its tables test the machine; its grade table differs from the published one only through this
      database, with `evidence_md5` equal
- [x] Copy pass 1's CH outputs aside before Phase 3 (review O3), and record each step's `sessionInfo()`, workers and grade cache counts
- [x] A `different` in something a decision reads stops the run (each traced to its cause by probe instead: #161 for mad_pick and grade sizes, #162 for cold walks; neither is the database, and `R/link_flow.R` and the walk SQL are unchanged since 2aacd1f, so no rerun there). Rerun that step at `2aacd1f` and record which cause it was

## Phase 3: Every key

- [x] `RUN=<stamp> WORKERS=8 EVIDENCE_DIR=data/fdis/derived_second Rscript scripts/0320-tune-run.R` (every species); CH's pass-2 outputs against pass 1 are a free repeat check. Each key's pick, tables and grades
      compared against run `20261104_0543`
- [x] `TUNE_DIR=data/tune/candidate/<stamp> SPECIES=BT,CO,GR,ST,WCT CONFIG_SHA=e2a85938… GPKG=FALSE Rscript scripts/0330-compare.R`, compared against `data/compare/`
- [x] Minutes per step beside the host's (from `20261103_evidence_build_ledger.csv`, `20261104_tune_run-…txt` and `20261104_compare-…txt`)

## Phase 4: crate's comparison (once crate PR #44 merges)

- [x] Check that PR #44 has merged (merged 2026-11-06 02:30 UTC; crate 0.12.0 with `crt_receipt_compare()` already installed)
- [ ] `pak::pak("NewGraphEnvironment/crate", ask = FALSE)`, then write receipts for the reference and new outputs through `crt_receipt_write()`
      with the tolerances recorded by hand. Check that `crt_receipt_compare()`'s verdict on each output matches the hand-recorded one, and record
      any disagreement. Disagreements go to a crate issue, not a workaround (drafted for crate, which is our repo)
- [ ] Tick the issue's provenance task. In #154's body, propose each tolerance used as the declaration beside its writer, and each identical
      table as exact

## Phase 5: Record

- [ ] Commit the logs under `scripts/logs/habitat/database_second/` (review G8: 0325 lists `_tune_run*.txt` at the top of `scripts/logs/habitat/`), the 0310 ledger where 0310 writes it, the verdict CSVs
- [ ] `research/database_builds.md`, "A second database": the measured load (about 71 GB moved as 8 GB of dumps plus one 14-minute flow load,
      66 min of moving, 2026-11-05), what was reproduced and with which verdicts, the minutes per step against the host's, and that a run there
      is now ordinary. Update the header's Verified/Issues/Produced-by line
- [ ] Edit #158's body: `DEV=1` replaced by the full candidate run, the cold walk check added, and each task ticked with its verdict
- [ ] CLAUDE.md "Database access": one line that a second database holding the build has been proved (no host names)

## Out of scope (review G5)

`data/tune/grad_fwa/` (the separate fwa_gradient pass), `grad_ext/`, `data/compare/floodplain.csv`, the GeoPackages and the figures are not
reproduced. Expected differences, not stops: visits_link's added `segment_fwa_gradient` (#120, after the published run), and with it
`evidence_md5` in every grade table, record and summary; the smoke tables' `previous` row; the 0310 ledger's new and context rows.

## Owed at the end (reported, done after merge)

- [ ] Delete the candidate (`data/tune/candidate/<stamp>/`, `data/compare/candidate/<stamp>/`) and the restored reference copies, on Al's word

## Validation

- [ ] Tests pass (`devtools::test()`, including the new comparison script's fixtures)
- [ ] `/code-check branch` clean
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, with Measurement and Evidence sections

**Verification:** each published output gets a verdict row from `database_compare.R`, and the tool is proved on planted differences before it
is trusted. The cold walk check runs the walk itself on this database. If a `different` appears, the rerun at `2aacd1f` attributes it to code or
to the database. When crate lands, its verdicts are checked against the hand-recorded ones, which tests crate on a case whose answer is known.

