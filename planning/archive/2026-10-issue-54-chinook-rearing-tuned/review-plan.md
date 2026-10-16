# Plan review (#54)

A Plan agent reviewed the plan on 2026-10-16, reading the plan, 0290/0294/0295, `ch_dist_large.sql`, link and fresh,
and probing local fwapg read-only. It returned its review as reply text, and the lead transcribed it here. A
disposition follows each finding.

## Blockers

**B1. The Phase 1 control fails by construction.** link's `default` CH rearing is `accessible AND predicate`, then
the user-habitat overlay (1,949 CH rows in `configs/default/overrides/user_habitat_classification.csv`), then
`cluster_rearing` (both, bridge 0.05, 10 km). On accessible segments the predicate holds where `rearing` is false on
8,126 segments, mostly cluster removals. `rearing` holds where no branch does on 2,664 segments (2,270 on edge 1050,
235 on 1000 with a NULL width). The 31 CH groups have no `fresh_default.log` rows, so their vintage is unknown.
Fix: explained-mismatch accounting, not a stop.
→ **Taken.** Already corrected in Phase 1 (cluster pass, mixed versions). The overlay is added to the side by side:
it is applied to both rules, and capture outside it is reported.

**B2. One rule coefficient pooled across branches biases the optimum.** Of the 978 analysed CH, 702 are on
river-polygon edges, where the rule is constant "in". The stream branch has 15,417 visits, 266 CH and 47 WSGs with
both outcomes. A single β lets the ~22 % river-polygon rate (Nechako-dominated) set the in-rate, which pushes the
floors stricter. Also, the plan contradicts itself on whether the R branch's gradient changes.
→ **Taken.** The scoring population is stream-branch visits: stream edges not in a river polygon, a wetland of at
least 1 ha, or a lake of at least 100 ha, which are the only places size, gradient and the exception act. In the side
by side, g applies to the R branch as well, as link's CSV would apply it; the scoring cannot see that, and the
write-up states it (0 of 156 river-polygon visits above 5.49 % caught CH).

**B3. Access is confounded with size and gradient.** 2,889 of 6,520 covered stream-branch visits (44 %) have a
natural CH barrier downstream (pre-override), and 21 of them caught CH. link applies the rule behind the access gate,
so a rule scored without access learns barriers. Pre-override natural barriers are not observation-circular.
→ **Taken.** 0296 attaches the pre-override natural CH barrier test (0294's) from `fresh_default.barriers`, or from
`fresh.barriers` (bcfishpass config, 98 groups) where `fresh_default` lacks the group. That is 51 of the 103 visit
groups. The primary population is stream-branch visits with a known status and no natural barrier downstream; all
stream-branch visits form a sensitivity. link's gradient barriers block CH only from class 15 %
(`lnk_barriers_unify()`), so the test is species-aware.

## Gaps

- **G1.** A NULL width marks first-order streams (fwapg models width only where `stream_order > 1`), so `default` never
  rears CH on unmeasured order-1 streams. → **Taken**: stated. A NULL width fails the size test, and the exception can
  still admit the segment.
- **G2.** The wetland branch is unhandled at visits. → **Taken**: 0296 attaches `wb_wetland`, and wetland visits sit
  outside the scoring population.
- **G3.** 7,342 stream-branch visits sit on FIELD_MEASURMENT segments: their own width. A floor tuned on measured
  widths is then applied to modelled ones. Reproduce the width model. → **Taken**: 0296 recomputes fwapg's model
  (`extras/channel_width/sql/channel_width_modelled.sql`, Thorley and Irvine 2021b) at every visit. The primary
  width is the one link would see with no field measurement: modelled where `stream_order > 1`, else NULL. The
  control checks the formula against stored MODELLED widths. Field width becomes a sensitivity.
- **G4.** 2,852 of 11,627 walks end on a lake. → **Taken**: the spec says the exception means the first segment of
  flow ≥ Q of any kind, the rule link would carry; lake targets out is a sensitivity.
- **G5.** Ambiguous placement depends on Q. → **Limit stated**: the sensitivity uses 0294's flag (Q = 10).
- **G6.** Flow-source runs need a common population. → **Already in the spec** (pick on the same visits).
- **G7.** Outside check: 1,344 records, 278 spawning-staged, 129 match type C/D/E, 1,144 distinct locations.
  Use `lnk_habitat_validate()` conventions and a lift criterion fixed in advance. → **Taken**, moved to 0298:
  types A/B, one per blue line × metre, spawning and holding stages out, capture outside the overlay, and lift
  (capture share ÷ km share) with a bootstrap by location.
- **G8.** The side by side compared post-cluster with pre-cluster, and D on a segment needs a definition. →
  **Taken**: cluster both. D is measured from the segment's downstream end, where its walk starts.
- **G9.** The issue asks for detection rates in the side by side. → **Taken**: FDIS raw CH rate on rearing and
  non-rearing segments under each rule.
- **G10.** The MAD cap of 100. → **Already in the spec** (open), stated.
- **G11.** A `none` walk fails the exception, which matters for coastal fish. → **Taken**: stated.

## Statistical design

- **Refitting held-out intercepts is sound.** Report the WSGs where a rule varies. "All in" is the null model. →
  **Taken.**
- **Stratify folds by CH.** → **Taken**: WSGs are ranked by stream-branch CH and dealt to folds in shuffled blocks.
- **The bootstrap unit differs from the SE unit, and the bootstrap ignores fold variance.** → **Taken**: a WSG
  cluster bootstrap of the per-WSG held-out deviances, plus the main grid repeated on 4 more fold seeds, with each
  seed's pick reported.
- **Selection optimism.** → **Taken**: nested selection. The pick is chosen on 4 folds' held-out deviance and scored
  on the 5th, and the result is reported against `default`.
- **Report each component as a profile, not a marginal range, and say whether `default` is in the region.** →
  **Taken.**
- **Define departures.** → **Taken**: a size test that differs in variable or value is 1; a gradient that differs is
  1; an exception is 1.

## Link application

The compiled predicate was confirmed: `BETWEEN` is inclusive, a NULL width fails in R too, and negative gradients
fail (link's segments carry 7,164 negative gradients; FWA carries 7). The grid's gradient values follow the issue's
(3, 4, 5.49, 7, 9 %). Tuning g on FWA segments that link applies to its finer segments is reported through the
link-inputs reading and stated.

## Ordering, scope, acceptance

- O1: the outside check moves to 0298. → Taken.
- O2: settle the population decisions before any fit. → Taken: 0297's spec is revised and committed before its first
  run.
- O3: 0296 attaches the wetland flag and the barrier status. → Taken.
- Keep to the 27 groups: agreed.
- Record the zone zip's URL and checksum. → Taken: the md5 is logged.
- Commit a decision rule: if `default` is in the region, the headline is "no distinguishable improvement". → Taken.
- "Tests pass" is undefined (no test suite). → Taken: Validation names the positive controls instead.
- Feasibility: one training fit takes 0.26 s; the grid is about 10–12 min on 6 workers. Duplicate patterns are
  removed and `glm.fit` is used. → Already done.
