# Findings — Retune every species on link's new provincial default build (#145)

## Issue context

**If done:** every species and stage is tuned on link's new provincial `default` build (run `20261103_163715-269b585a`, link 0.78.2, 241 groups) with the evidence, flows and range the minimal-network run read, so the published rules, the minimal network's picks (#120) and the anchoring check (#141) are compared on one footing, and a candidate is ready to promote on Al's word. **If never:** the published rules stay on link 0.66.0's build and wet's 2026-10-19 flows, and every comparison with the minimal network changes the network, the flows and each species' range at once.

## Problem

The published tables were tuned on link 0.66.0's provincial build (run `20261017_004619-3f4c713b`) and wet's 2026-10-19 flow load. #120's province branch tuned every key on the minimal network (candidate `20261103_0838`), but its picks differ from the published ones in three ways at once: the network, the flow load (2026-10-24) and each species' range (link's presence review, link#402). The new full `default` build sits in the same database as `fresh_default_minimal` and reads the same flow load (table comment: built 2026-10-24T12:23:01Z, wet `b4bbc50`), so a tuning on it separates the network from the other two.

One thing stops the chain today: `knw_build_record()` refuses the schema, `schema fresh_default: 242 of 483 log rows carry no cut token: not one build`. `log_recompute` holds only the new run (241 rows), but `log` keeps the 2026-10-23 run's 242 rows (link 0.68.0, no output tokens) beside the new run's 241. The record reads the tokens over every `log` row by design, because link's four-group proofs carry different run ids in `log` and `log_recompute`; naming the run does not help, so `0310`, `0320` and `0330` all refuse the build.

## Proposed

- [ ] Decide how the record reads a `log` that holds an earlier run's rows: read the tokens over the `log` rows of the runs `log_recompute` names, falling back to every row where those runs are absent from `log` (the proofs' case); or ask link whether a provincial run should clear or rename its schema's `log` (an upstream question, drafted, not posted). A test with a two-run `log` either way.
- [ ] `0300` settle check on the new run, then `0310` into a tagged `EVIDENCE_DIR` (`data/fdis/derived_default_<date>`), so the published evidence in `data/fdis/derived` stays the default readers' until a promotion. Compare its visits with the minimal build's: the same visits, stream and measure expected.
- [ ] `DEV=1 0320` on the new evidence, and its pick report: each key's pick beside the published one and beside the minimal network's, with #141's anchoring columns. Rainbow trout rearing is back if the build models it.
- [ ] Report it: what moved and why (network only, now that flows and range match the minimal run), in `research/habitat_thresholds_tuned.md` or a new topic file.
- [ ] On Al's word: the full candidate `0320` (grades) and `0330` (comparison) on the database's own host, then `RUN=<run> 0335` to promote, the bundles and articles after it, as `CLAUDE.md` describes.

#120's chinook-on-every-setup table reads its "published" row (full network, segment gradient) from this run rather than scoring it again, and its "full, parent gradient" row is unblocked: link#444 is done, so `fresh_default.streams_parent` is the parent table.

Relates to #120 (the minimal-network tuning), #139 and #141 (the baselines and the anchoring check, whose "after" this gives on the full network), #119 (archiving the run).


## Phase 1: the scoped `log` read, live (2026-11-04 UTC, m4's database)

- `fresh_default`: `log_recompute` names run `20261103_163715-269b585a`; the record reads its 241 `log` rows, tokens
  `cut-full-top.acc-v5.grad-seg.q-fwapg`, and its line names `20261023_074321-24d85e8c` as set aside.
- `fresh_default_minimal`: one run in both tables, nothing set aside, `cut-min.acc-v5.grad-seg.q-fwapg`.
- `zz415_default`, `zz415_minimal` (link's proofs): `log_recompute` runs `415_recompute_*`, `log` runs `415_*`, so
  the fallback reads every row; tokens as before.
- The only readers of `<schema>.log` in `R/`, `scripts/`, `data-raw/` are `knw_build_record()`, `0300`'s `shas()` and
  `0310`'s species note; all three use `.knw_build_log_runs()`.
- `tests/testthat/test-link_place.R:39` (a live test against the `PG*` database's `fresh_default`) fails on `main`
  as on the branch: that schema has no BULK bull trout rearing segment longer than 20 m now. Unrelated to #145.

## The tightened rule, on every link schema (2026-11-04 UTC)

Probed every schema holding both `log` and `log_recompute` on both databases (records by `knw_build_record()`):
`fresh_default` reads run `20261103_163715-269b585a` and sets the 0.68.0 run aside; `fresh_default_minimal`,
`zz415_*`, `zz440_default` read as before; the published `fresh_default_20261017` (m1) reads its run's 241 rows and
names 5 rows with no run id (2026-08-06 to 2026-10-12) as set aside, tokens none, as before. Refused: `zz432_pre`
(`432_clear` logged after the build) and `fresh_default_dev_20261103` (two `log` runs, neither the recompute's).
Mutation check: disabling either new refusal turns its test red (lines 105 and 113).

## Phase 2: settle, evidence and placement (2026-11-04 UTC)

- Settle: released 03:12:53Z after three equal polls, 241/241 groups, one `link_sha` (`4dfbfa49`, v0.78.2), fresh
  0.52.0 (`245c8d8`), fwapg `9a62b0c`. Log `20261103_link_settle-default_20261103.csv` (file dates are local, PDT).
- Evidence (`0310`, 03:13 to 03:32Z, 19 min): 45,529 visits, `species_pooling_md5` `31ca5df…` and `visits_kept` as
  the minimal ledger; build record names run `20261103_163715-269b585a`, the 2026-10-24 load, walk `c3f7bdbe…`,
  tokens `cut-full-top.acc-v5.grad-seg.q-fwapg`, the 0.68.0 run set aside. fresh 0.52.0 against the minimal ledger's
  0.53.0: 0310 calls no fresh function.
- Placement (`minimal_network_check.R`): the same 45,529 visits on both; 45,463 at one blue line, measure and Atlas
  line (66 sit on a segment carrying another line's id). `walks.csv` and `visits_species.csv` byte-identical.
  Segments starting at the visit: full 31.4 % of visits with fish against 7.4 % of empty ones (medians 344 m and
  432 m); minimal 3.9 % against 3.7 % (638 m, 643 m).
- Access codes differ at 4,156 visit x species pairs, almost all full 1 against minimal 2 (an observation upstream
  on the minimal network); 58 cross zero. Province access km match to within 1.5 km per species.
- Stored km, minimal against full: rearing +0.5 to +1.8 % for six species (chinook +1.75 %) and −0.1 % for sockeye;
  spawning −0.01 to −2.8 % (sockeye the most).

## Phase 3: the DEV tuning on the full network (2026-11-04 UTC)

- `DEV=1 0320` first ran every species (9.8 min) and scored rainbow trout rearing too: the evidence has no
  `access_rb` (link does not model RB in either build), so that row had no access gate. Rerun with
  `SPECIES=BT,CH,CM,CO,GR,PK,SK,ST,WCT`, the minimal run's set (5.3 min, 14 workers); every column of the seven
  shared keys identical to the first run. Every smoke gate passed.
- Picks: full network `BT_rear mad>=0.1|g<=0.25|none`, `BT_spawn width>=2|g<=0.11|none`,
  `CH_rear mad>=0.75|g<=0.13|Q3@D1000`, `GR_rear width>=1.5|g<=0.0549|none`; CO, ST, WCT the published rule.
- Network alone (minimal against the new full): 3 of 7 keys the same pick; BT_rear differs in size and gradient,
  BT_spawn in gradient and exception, CH_rear in gradient (9 % against 13 %), ST_rear in size (0.5 against 1).
- Every published pick is in both new tunings' regions. The minimal network's BT_rear pick is outside the full
  network's region (80.8 behind, SE 73.2); the full network's BT_spawn (7.1 / 5.1) and CH_rear (10.4 / 7.3) picks are
  outside the minimal network's.
- `data-raw/pick_network_compare.R` writes the table: `scripts/logs/habitat/20261104_pick_network_compare.{csv,txt}`.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `DEV=1 0320` without `SPECIES=` scored RB rearing with no access column | Rerun on the minimal run's nine species |
