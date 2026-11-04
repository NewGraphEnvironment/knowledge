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


## Errors Encountered

| Error | Resolution |
|-------|------------|
