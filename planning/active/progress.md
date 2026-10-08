# Progress — Flow needs by species and life stage: literature into the evidence table (CH, CO, SK, BT, GR, WCT) (#44)

## Session 2026-10-07

- Plan-mode exploration; phases approved by Al. Gate decisions: new variable `instream_flow`; months via stage + timing table; grid species CH, CO, SK, BT, GR, WCT, ST
- Created branch `44-flow-needs-by-species-and-life-stage-lit` off main
- Scaffolded PWF baseline from issue #44 with approved phases
- Next: start Phase 1
- Phase 1: tests first (2 new blocks, red), then `instream_flow`, `percent MAD` and the flow metrics in
  `knw_literature_vocab()`; 221 tests pass. Audited all 45 `discharge` rows: only Gottesfeld & Rabnett's CH
  migration low flow (data row 121) is a flow need, moved to `instream_flow` with metric `unstated` (the
  quote names no statistic; the old note's "instantaneous" was an inference). Isaak 2015 (August flow) and
  Boughton & Goslin 2006 (Aug-Sep flow) are summer statistics used to size streams, so they stay `discharge`;
  the roxygen says so. `0280` green: 686 rows, coverage 48/48, thermal 50/50.
- Plan review (Plan agent) returned 2 blockers and 9 gaps (`review-plan.md`). Fixed in Phase 1 before
  committing: units as written for depth/velocity, `m bankfull` for the Sloat bankfull depths (rows 250,
  257, 264), the parameter/model_id guard, `annual_mean` dropped. Gottesfeld's note now names Figure 4
  (September mean flow) and the next paragraph's coho/sockeye statement; the metric stays `unstated`.
  238 tests pass; each new guard goes red under mutation. `task_plan.md` Phases 2–5 corrected (60-cell
  grid with optima counting for flow needs, a vocabulary checkpoint, and the G2 species-coding question
  for Al at the start of Phase 4).
- Code-check on Phase 1: round 1 clean, round 2 clean (notes taken: Figure 4 context, roxygen wording).
- Code-check round 3 found a defect inside the plan-review fix: BT velocity rows 497/498 stored 0.14–0.52 and
  0.65 m/s from a quote in cm/s, and 0280's `m/s = c(1, 0.01)` rescale let the conversion pass, while the
  new rule says depth and velocity stay as written (depth in cm would have failed: the rule lived in two
  places that disagreed). Recoded both rows to `cm/s` (14, 52, 65) and set `m/s` to scale 1; roxygen names
  `ft/s` among the US units. Ended by enumeration: a frozen 0280 with every rescale at 1 fails exactly 4 of
  686 rows (row 29 gradient from a proportion; rows 162–164 substrate mm from cm), each a documented
  rescale on a variable outside the as-written rule. Accepted, pre-existing: 0280's `m = c(1, 1e3)`
  rescale (for bridge distance) also applies to depth in m; no row uses it.

| Round | Findings | Fixed | Accepted | Inside previous fix? |
|---|---|---|---|---|
| 1 | 0 | 0 | 0 | — |
| 2 | 0 (2 notes) | 2 notes | 0 | n |
| 3 | 1 fragile (+3 notes) | 1 (+1 note) | 1 note | y (plan-review unit fix) |
| enumeration | 4 rescaled rows of 686, all documented | — | — | terminal |
