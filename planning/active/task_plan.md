# Task: Tune chinook rearing on minimal segments and map how the cuts move the result (#120), second branch: the province

## Problem

From #92 the tuning reads link's segment gradient. link cuts a segment at fish records of the species it models, so the gradient at a site that caught fish is averaged over a stretch that starts there: on the tuning's stream branch 86 % of visits with a catch start a segment of their own against 10 % of empty ones (median 113 m against 305 m; link 0.66.0's build, every observation a break). Crossings and habitat end points cut segments too: not at catches, but at places unrelated to the stream's form. Chinook rearing's rule moved when the gradient source changed (#92), so the tuning is sensitive to how segments are cut.

Tuning on segments cut only at barriers and access gradients removes the catch from the predictor. But link deploys a rule on its full network, where segments are shorter and their gradients differ, so a rule tuned on the minimal network does not transfer cleanly unless each full segment carries its minimal parent's gradient. That is link's half: NewGraphEnvironment/link#415, with outputs named from NewGraphEnvironment/link#414. The minimal network still cuts at access gradients, and those cuts depend on which species link models and at which classes (0.15, 0.20, 0.25), so pausing a species (NewGraphEnvironment/link#432, NewGraphEnvironment/link#433) or changing a class moves the segments a minimal-network tuning reads; #132 reviews the classes themselves.


Branch `120-minimal-network-province` (the slug collides with the merged first branch, PR #135).

## Context

The first PR (#135) landed the mechanics and the four-group test. link#441 then built `default_minimal` into
`fresh_default_minimal` for all 241 groups (run `20261102_203300-60ab009d`, link 0.78.1 `193cb8aa`, fresh 0.52.0,
tokens `cut-min acc-v5 grad-seg q-fwapg`, 4,987,761 segments). It lives on **m4's local database**
(`PGSERVICE=fresh_local`, 1.7 ms round trip; the published builds are on m1, 137 ms, where `fresh_default_minimal`
exists but is empty). m4's flow table is wet's 2026-10-15 load; the published grades name m1's 2026-10-19 load; wet's
current build is 2026-10-24 (`b4bbc50`) and the public prefix keeps no older manifest. link#444 (the parent table,
`streams_parent`) is open, so the "full, parent gradient" setup and the transfer cost in km wait on it. KO and RB are
paused in `default` and therefore in `default_minimal`: the species list is BT, CH, CM, CO, GR, PK, SK, ST, WCT.

Tonight's question is Al's: *did the tuning's numbers move on the minimal network, and by how much* — the pick report
for every species, then every fitted key graded and compared on the minimal schema as an unpromoted candidate, with
no GeoPackages (the grade pass is where the segments are walked, and the comparison cannot apply a near-river rule
without those walks, so the grade is a dependency of the km, not an extra). Tomorrow link runs the full province
`default` and link#444; the all-species retune on that build and any promotion are a follow-up issue filed once that
build exists.

## Decided at the gate (Al, 2026-11-02)

- Flow load: load wet's current build (2026-10-24) on m4 with `wet_db_load(conn, wet_catalog())`. Every
  minimal-network setup reads one load; the published setup stays on its 2026-10-19 load, picks compared in each
  run's own units (`knw_tune_pick_report()` does). m4's `knw.walk_cache` rows under the old load are never read.
- Species: the nine link models on the minimal network; KO and RB are paused and cannot be tuned.
- Grade and compare every fitted key on the minimal schema as one unpromoted candidate (Al, "DEV, then every species
  graded and compared, GPKG=FALSE"), after the pick report is read; no GeoPackages (`STAGE=gpkg` writes them later
  from the saved segments if wanted); nothing tracked changes, promotion stays on Al's word. A promotion onto the
  minimal network could only move every key together, which is why the candidate holds every key.
- Maps, the methodology article's section and the every-setup table's "full, parent gradient" row wait on link#444:
  owed, not this branch. The all-species retune on tomorrow's full `default` build is a new issue, filed tomorrow.
- Runs are on m4, the database's own host (`knw_db_latency_check()` refuses m1 from here). Check `pg_stat_activity`
  before each timed step. link stays at the installed 0.78.1 (0.78.2 is records only).

## Phase 1: Flow load on m4

- [x] `PGSERVICE=fresh_local Rscript -e 'wet::wet_db_load(DBI::dbConnect(RPostgres::Postgres()), wet::wet_catalog())'`
      from the repo root; before it, read the table comment and `pg_stat_activity`; after it, `knw_discharge_load()`
      returns a comment naming `scenario historical` and `built 2026-10-24T12:23:01Z`
- [x] Record the load (before/after comment, rows per source, minutes) in `findings.md`

## Phase 2: Settle and evidence on `fresh_default_minimal`

- [x] `PGSERVICE=fresh_local SCHEMA=fresh_default_minimal POLL_MIN=1 Rscript scripts/0300-link-settle-wait.R` →
      `scripts/logs/habitat/<date>_link_settle-fresh_default_minimal.csv`, released on run `20261102_203300-60ab009d`
- [x] `PGSERVICE=fresh_local SCHEMA=fresh_default_minimal EVIDENCE_DIR=data/fdis/derived_minimal
      SETTLE=scripts/logs/habitat/<date>_link_settle-fresh_default_minimal.csv Rscript scripts/0310-evidence-build.R`
      (`SETTLE=` is the exact path: 0310's default pattern `_link_settle\.csv$` never matches a tagged log; no
      `PARENT_DIR`: link#444 is open) → `data/fdis/derived_minimal/` and `<date>_evidence_build_ledger-derived_minimal.csv`;
      the ledger's build record names the run and the four tokens `cut-min.acc-v5.grad-seg.q-fwapg`, the new flow load
      and the round trip. Its `schema_species` row shows 11 species built on 9 access columns (KO and RB paused):
      that is the four-group test's state too, not an error
- [x] Placement against the published build: `FULL_DIR=data/fdis/derived MIN_DIR=data/fdis/derived_minimal
      Rscript data-raw/minimal_network_check.R` (`data/fdis/derived` here is the published evidence, md5s equal to
      `data/thresholds.csv`'s). It stops at step 3, because the published `access_check.csv` predates #120's per-group
      columns, and writes its log only at the end, so steps 1 and 2 (the same visits on both at one stream and
      measure; the walks, which differ by flow load) are read from the console and recorded in `findings.md`. Steps
      3 to 5 (access per group, stored habitat) need the published evidence rebuilt per group and the published
      schema, both on m1: say so in the write-up, do not run them here
- [x] The premise on the province: `PGSERVICE=fresh_local SCHEMA=fresh_default_minimal
      EVIDENCE_DIR=data/fdis/derived_minimal Rscript data-raw/segment_gradient_check.R` — the share of stream-branch
      visits with a catch that start their own segment, beside the published build's 2026-10-27 figure
- [x] #121's measured-gradient check on the minimal build: `EVIDENCE_CHECK=FALSE EVIDENCE_DIR=data/fdis/derived_minimal
      Rscript data-raw/site_gradient_check.R`, beside `scripts/logs/habitat/20261030_site_gradient_check.txt`

## Phase 3: DEV tuning, every species — the pick report

- [x] `DEV=1 SCHEMA=fresh_default_minimal EVIDENCE_DIR=data/fdis/derived_minimal DEV_DIR=data/tune/dev_minimal
      SPECIES=BT,CH,CM,CO,GR,PK,SK,ST,WCT WORKERS=14 Rscript scripts/0320-tune-run.R` (floors 5 and 5; no database:
      `SCHEMA` is only echoed in the log under `DEV=1`) → `data/tune/dev_minimal/pick_report.csv` and the log
- [x] Every key's four smoke gates pass or the key says `too_few_groups` / `no_response` / `no_stream_rule`; a
      failed gate stops here (CLAUDE.md: never chain past a failed gate)
- [x] The pick report, one row per key, in `findings.md` and the issue body: the run's pick beside the published
      one, whether the published rule is still in the region, how far behind the best it sits, and the number of
      visits; the Atlas-line setup is the tracked `data/tune/grad_fwa/CH_rear_tune.csv`, no new run

## Phase 4: Every fitted key graded and compared on the minimal schema (candidate, overnight, no GeoPackages)

Runs only after Phase 3's pick report is read and every key's gates passed. `pg_stat_activity` idle at launch;
tomorrow's full `default` run launches from m4 only after `0330` has exited.

- [x] `PGSERVICE=fresh_local SCHEMA=fresh_default_minimal EVIDENCE_DIR=data/fdis/derived_minimal
      SPECIES=BT,CH,CM,CO,GR,PK,SK,ST,WCT RUN=<UTC stamp> WORKERS=14 Rscript scripts/0320-tune-run.R` →
      `data/tune/candidate/<run>/` (every key's tune, curves, summary, grades and grade record; the grade walks cold on
      the new load, about an hour for every key on the published run's host; the walks run on at most 8 workers
      whatever `WORKERS` says); its log names the minutes per key. The smoke gate scores the committed
      `data/tune/<key>_tune.csv` picks on the new evidence; a failed gate ends the run before anything is scored
- [x] `PGSERVICE=fresh_local SCHEMA=fresh_default_minimal TUNE_DIR=data/tune/candidate/<run> CONFIG_SHA=193cb8aa
      GPKG=FALSE WORKERS=6 Rscript scripts/0330-compare.R` → `data/compare/candidate/<run>/` (per key `compare`,
      `change`, `checks`, `segments.rds`; the combined tables); about 2.7 h for every key on the published run's host.
      `CONFIG_SHA` pins `default`'s configs to the build's link commit (0.78.1) rather than `../link`'s `origin/main`
      (0.78.2, records only; the two commits' `configs/default/` are identical, so only the recorded baseline differs).
      It reads the evidence directory the summaries name and refuses one whose md5s are not the curves'; no wet
      reload between `0320` and `0330`, or every grade table reads stale
- [x] The issue's check: regenerated `default` equals link's stored km in every group for chinook rearing (**not exactly**: within 0.011 % per key, all in the connectivity stage, cause not established; findings, Phase 4)
      (`stored_vs_default_differ_km` in `CH_rear_compare.csv`, 0 in every group), and the same read for every other
      key; where it does not, know why before anything else
- [x] km drawn and graded under `default` and the tuned rule, per key, group and total, from the candidate's
      `compare.csv`. The published `data/compare/compare.csv` is another network, build (link 0.66.0's cuts) and flow
      load, so the like-for-like figure is each run's own `default` against its tuned rule; the published numbers
      are shown beside it only with that bracket
- [x] `cp data/fdis/derived/fdis_sites.csv data/fdis/derived_minimal/` first: the archive stores 0240's placement table
      beside an evidence build, 0310 does not write it to a tagged directory, and it is build-independent (0230's
      placement of the visits on the Atlas); then `RUN=<run> EVIDENCE_DIR=data/fdis/derived_minimal DRY=1 Rscript
      scripts/0336-archive.R` lists `tune/<key>/cut-min.acc-v5.grad-seg.q-fwapg/` per key and the evidence under
      its MANIFEST md5 (`EVIDENCE_DIR` is required: 0336 defaults to the published build and refuses grades scored
      elsewhere); then the archive itself (unpromoted; the folders are new, so nothing published is overwritten)

## Phase 5: Write-up

- [x] `research/minimal_network_tuning.md`: a province section (the answer first: the pick table; the premise and
      measured-gradient figures on 241 groups; km per key, each run's own `default` against its tuned rule, the
      published run bracketed as another network, build and load; which of `minimal_network_check.R`'s steps ran
      here and which wait on m1; what each break source does, stated as the checks show it; what waits on
      link#444), header revised, status line
- [x] Issue #120 body: the province checkboxes ticked with their results, the every-setup table marked per row
      (done / waits on link#444 / #132 / #70), the follow-up issue named once filed
- [x] `CLAUDE.md` working notes: where `fresh_default_minimal` lives and the flow loads per database, one paragraph;
      `scripts/README.md` only if a switch changed
- [x] Logs under `scripts/logs/habitat/` (the settle log, the tagged ledger, the checks) and
      `scripts/logs/habitat/minimal_network_120/` (the DEV, grade and compare logs), committed

## Owed at the end (reported, done after merge)

- [ ] File the follow-up issue once tomorrow's full `default` build and link#444 exist: every species retuned on it and
      on the minimal build, the "full, parent gradient" setup, the transfer-cost map, the article's section, the
      promotion decision
- [ ] Maps of where the habitat drawn differs (the issue's static figure, from the candidate's saved segments for the
      most interesting groups; `STAGE=gpkg` for QGIS if wanted) and the methodology article's section: with the
      follow-up, since the transfer cost needs the parent table
- [ ] "Minimal, other access classes" (#132) and "fixed window" (#70): their own issues

## Plan review

`planning/active/review-plan.md` (Plan agent, 2026-11-03 UTC, before the baseline): three blockers (0336's
`EVIDENCE_DIR` and `fdis_sites.csv`; `minimal_network_check.R` against the pre-#120 published `access_check.csv`),
four gaps and the assumptions above, each verified in the code and folded into the phases; no code change needed.

## Validation

- [x] Tests pass (`devtools::test()`; no package code is planned, so this is the floor): 1,853 pass, 0 fail, 1 skip (2026-11-03, after the archive's index rows)
- [x] `/code-check branch` clean once over the branch (four rounds: 4, 2, 4, 0 findings; rounds 2 and 3 each found one inside the previous fix; ended on round 3's enumeration of every quantified claim, re-verified by round 4) (scripts untouched unless a run exposes a defect; the research
      and CLAUDE.md prose reviewed)
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved: every run's log and ledger is committed and quoted by path; the build record on the
ledger names the schema, run, tokens, flow load and walk md5; `0320`'s smoke gates and `0330`'s `default`-equals-stored
check are the run's own guards; the pick report's numbers in prose are copied from `pick_report.csv`, not retyped from
memory; the archive's dry run lists the setup folder before anything is sent. Any refused run leaves a `_refused` log,
and the next step is not started on it.
