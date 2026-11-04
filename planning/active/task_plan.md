# Task: Retune every species on link's new provincial default build, on the minimal run's flows and range (#145)

## Problem

The published tables were tuned on link 0.66.0's provincial build (run `20261017_004619-3f4c713b`) and wet's 2026-10-19 flow load. #120's province branch tuned every key on the minimal network (candidate `20261103_0838`), but its picks differ from the published ones in three ways at once: the network, the flow load (2026-10-24) and each species' range (link's presence review, link#402). The new full `default` build sits in the same database as `fresh_default_minimal` and reads the same flow load (table comment: built 2026-10-24T12:23:01Z, wet `b4bbc50`), so a tuning on it separates the network from the other two.

One thing stops the chain today: `knw_build_record()` refuses the schema, `schema fresh_default: 242 of 483 log rows carry no cut token: not one build`. `log_recompute` holds only the new run (241 rows), but `log` keeps the 2026-10-23 run's 242 rows (link 0.68.0, no output tokens) beside the new run's 241. The record reads the tokens over every `log` row by design, because link's four-group proofs carry different run ids in `log` and `log_recompute`; naming the run does not help, so `0310`, `0320` and `0330` all refuse the build.

## Plan context (from the gate, 2026-11-04 UTC)

The published rules were tuned on link 0.66.0's build and wet's 2026-10-19 flows. #120's minimal-network candidate
(`20261103_0838`) differs from them in three ways at once: the network, the flow load and each species' range. link's
new full `default` build (run `20261103_163715-269b585a`, link 0.78.2, 241 groups) sits in m4's database beside
`fresh_default_minimal`, on the same flow load (comment: built 2026-10-24T12:23:01Z, wet `b4bbc50`). Tuning on it
leaves the network as the only difference from the minimal run.

Measured on m4 (`PGSERVICE=fresh_local`, 2026-11-04 03:00 UTC):
- `fresh_default.log_recompute`: 241 rows, all of the new run.
- `fresh_default.log`: 242 rows of run `20261023_074321-24d85e8c` (link 0.68.0, no tokens) beside 241 of the new
  run (0.78.2, `cut-full-top.acc-v5.grad-seg.q-fwapg` on every row). `fresh_default_minimal.log` holds one run.
- Both builds model the same nine species in the same groups (BT 158, CH 136, CM 63, CO 113, GR 81, PK 89, SK 114,
  ST 93, WCT 16). **Rainbow trout is not modelled, so RB rearing stays paused** (and KO).
- `fresh_default.streams_parent` exists (5.55 M rows, 241 groups); that is #120's, not this issue's.
- No other session is active on the database.

**The block reaches further than the issue says.** Three readers take every `log` row:
1. `knw_build_record()` (`R/build_record.R`): the token read refuses the schema (the issue's error).
2. `0300`'s `shas()` (`scripts/0300-link-settle-wait.R`): the settle record would carry `link_version` `0.68.0;0.78.2`
   and two `link_sha`s. `0320` (lines 248–264) then compares link's thresholds between both commits and reads the
   configs at `shas[1]`, the first in alphabetical order, which can be the 0.68.0 commit. `0330` takes the first too.
3. `0310`'s `schema_species` record (a ledger note only, but mixed).

## Decided at the gate

Approved by Al at the plan gate, 2026-11-04 (UTC).

- **The record reads the `log` rows of the runs `log_recompute` names**, and every row where none of those runs is in
  `log` (link's four-group proofs). One package helper decides it, and all three readers use it. Recommended over
  asking link to clear `log`: the record must read the schemas that exist now, and the fix does not depend on link.
  link is our repo, so a short issue there notes that a provincial run leaves the earlier run's `log` rows in place
  (for link's readers, not blocking this one).
- **Installed link stays 0.78.1** (0.78.2 has no code change, so the range `0310` reads from the installed `default`
  presence table is the minimal run's). Not upgraded to 0.79.0 during this comparison. fresh is 0.52.0 on this
  machine (the build's own); nothing in `0310` or `DEV=1 0320` regenerates through fresh.
- **Evidence goes to `EVIDENCE_DIR=data/fdis/derived_default_20261103`** (named for the build's run date); the DEV run to
  `DEV_DIR=data/tune/dev_default_20261103`. `data/fdis/derived` and `data/tune/dev` stay untouched.
- **The write-up is a new section of `research/minimal_network_tuning.md`**, whose status line says the separation
  waits on this build. `habitat_thresholds_tuned.md` does not change until a promotion.
- **The full candidate (`0320` grades, `0330`) and `0335` wait on Al's word** and are not in this PR (CLAUDE.md).

## Phase 1: Which `log` rows describe the build
- [x] Failing tests in `tests/testthat/test-build_record.R`: a two-run `log` (an earlier run with no tokens beside
      the recompute's run with tokens) reads the recompute run's tokens; the proofs' case (no `log_recompute` run in
      `log`) still reads every row; a recompute run whose own rows are mixed is still refused. Mock with rows by run.
- [x] `R/build_record.R`: a helper `.knw_build_log_runs(conn, schema)` returning the runs whose `log` rows describe
      the build. `knw_build_record()` reads the tokens over those rows only (`WHERE run_uid = ANY($1)`), returns them as
      `log_run_uid`, and its line names any runs set aside. Roxygen updated (the "every row" sentence).
- [x] `scripts/0300-link-settle-wait.R`'s `shas()` and `0310`'s `schema_species` read the same rows (load the package
      in 0300); grep every other `FROM %s.log` reader in `R/`, `scripts/` and `data-raw/` and decide each.
- [x] `devtools::document()`, tests, lintr.

## Phase 2: Settle and evidence on the new build (m4, local database)
- [ ] `PGSERVICE=fresh_local SCHEMA=fresh_default POLL_MIN=1 Rscript scripts/0300-link-settle-wait.R`: released, one
      `link_sha` and `link_version 0.78.2` in the record.
- [ ] `PGSERVICE=fresh_local SCHEMA=fresh_default EVIDENCE_DIR=data/fdis/derived_default_20261103 SETTLE=<that log>
      Rscript scripts/0310-evidence-build.R`: the build record names run `20261103_163715-269b585a`, the 2026-10-24
      load and tokens `cut-full-top.acc-v5.grad-seg.q-fwapg`; visits placed beside the minimal build's 45,529.
- [ ] `FULL_DIR=data/fdis/derived_default_20261103 MIN_DIR=data/fdis/derived_minimal STORED=TRUE PGSERVICE=fresh_local
      Rscript data-raw/minimal_network_check.R`: steps 1–3 and 5 (placement, walks and species, access per group,
      stored km); step 4 (parent) is #120's and reports "not checked".
- [ ] Commit the logs (settle, ledger, check) under `scripts/logs/habitat/`.

## Phase 3: The DEV tuning and the three-way pick table
- [ ] `PGSERVICE=fresh_local SCHEMA=fresh_default EVIDENCE_DIR=data/fdis/derived_default_20261103 DEV=1
      DEV_DIR=data/tune/dev_default_20261103 Rscript scripts/0320-tune-run.R`: smoke gates, picks, `pick_report.csv`
      (published side and #141's anchoring columns). Copy the pick report to `scripts/logs/habitat/`.
- [ ] `TUNE_DIR=data/tune/dev_default_20261103 Rscript data-raw/tune_anchor_check.R`, beside #141's published and
      minimal logs (`scripts/logs/habitat/20261104_tune_anchor_check-*`).
- [ ] `data-raw/pick_network_compare.R` (new, no database): per key, the published pick, the minimal network's
      (candidate `20261103_0838`) and the full network's (this run), each one's anchoring, `n_visits` on each; writes
      `scripts/logs/habitat/<date>_pick_network_compare.{csv,txt}`.

## Phase 4: Report
- [ ] `research/minimal_network_tuning.md`: a section "The full network on the same flows and range" — plain-language
      walk first (what changed between the two builds, what moved, what that says the network does), the three-way
      table, then the placement and stored-km checks; header and status line revised. `research/README.md` row if its
      description moves.
- [ ] Issue #145's body: tick what landed, link the research section; #120's body gets the pointer its chinook row
      reads ("published row from #145's run").
- [ ] File the link issue on the two-run `log` (own repo; backticked cross-repo numbers).

## Owed at the end (reported, done after merge)
- [ ] On Al's word: the full candidate `0320` (grades) and `0330 TUNE_DIR=` on the database's host, then
      `RUN=<run> 0335`, the bundles and articles after it, as CLAUDE.md describes.

## Validation
- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved: the new tests fail on `main`'s `knw_build_record()` and pass after (restore the every-row
read and watch them go red); the live record on `fresh_default` names one run and the 0.78.2 tokens; the settle record
names one `link_sha`; the evidence ledger's visit count and `minimal_network_check.R` step 1 match the minimal build's
placement; the pick report's published columns agree with `data/tune/<key>_tune.csv`.

