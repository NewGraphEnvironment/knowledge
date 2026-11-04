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

## Errors Encountered

| Error | Resolution |
|-------|------------|
