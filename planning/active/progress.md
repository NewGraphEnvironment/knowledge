# Progress: Tune chinook rearing on minimal segments and map how the cuts move the result (#120)

## Session 2026-11-04

- Plan-mode exploration; phases approved by Al. Gate decisions: grade each setup rather than carry the parent's grade,
  and the Atlas line drawn, graded and given a link token.
- Created branch `120-chinook-rearing-every-setup` off origin/main (`6f4499e`)
- Scaffolded PWF baseline from issue #120 with approved phases
- Next: start Phase 1

## Session 2026-11-05 (UTC)

- Plan review spawned 03:47Z (Plan agent), returned; findings and verdicts in `review-plan.md`, folded into the plan
  (`6504ba2`). B1 was already avoided in the code; G1 (promotion had no gradient guard) was real.
- Phase 1 code `ef527dc`: `knw_parent_read()` (13 s live; four guards each shown to fire by mutation), `0310 PARENT=TRUE`.
- `0310 SCHEMA=fresh_default PARENT=TRUE EVIDENCE_DIR=data/fdis/derived_parent` launched 03:50Z on m4 (copy of the
  script in the scratchpad), log `scripts/logs/habitat/every_setup_120/20261105_evidence_build-derived_parent.log`.
- Phase 2 code `bd2c7d0`: gradient sources in `knw_link_segments()` (BULK: 42,458 segments, identical but for the
  gradient; parent differs on 10,053, Atlas on 18,509), grading on the curve's gradient, `knw_compare_rules(gradient=)`,
  `0320 SETUP=1`, `0330` on the run's gradient, the archive's token check, and promotion's refusal of a setup (shown
  to fire by mutation). link#460 filed for the Atlas token (`grad-fwa`); soul#725 filed for the skill's bash 3.2 parse.
- Full test suite launched after `bd2c7d0`.
