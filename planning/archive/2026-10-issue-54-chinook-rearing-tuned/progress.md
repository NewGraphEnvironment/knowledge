# Progress — Tuned Chinook rearing rule: size, gradient and distance to a large river, set beside link's default (#54)

## Session 2026-10-15

- Plan-mode exploration — phases approved by user
- Created branch `54-tuned-chinook-rearing-rule-size-gradient` off main
- Scaffolded PWF baseline from issue #54 with approved phases
- Next: start Phase 1
- Phase 1: walk profile SQL + positive control (exact on 12,932 starts); default CH predicate generated from fresh, cluster pass found; plan corrected for Phase 1 item 3 and Phase 5
- Plan review returned (review-plan.md): B1-B3 taken (stream-branch population, natural barrier status, cluster
  pass in the side by side); width model recomputed after finding order-1 widths exist only where measured
- 0296 run: 21,862 visits, walk control exact, width model 96.2 % within 5 %, barrier status on 13,085
- 0297 committed (47cbfb9) before its first fit; running
- 0297 run (23 min, 6 workers); re-run byte-identical on the rule outputs; figure redrawn
- 0298 run; then, at the user's question, default's MAD bounds added as a third rule; then a gained/lost breakdown
- research/chinook_rearing_tuned.md drafted; link issue drafted (planning/active/link-issue-draft.md, link is public)
- Code-check round 1 (review-round1.md): 17 findings, all real; fixed in e273731 (code) and aff2a28 (outputs,
  prose). River test kept for every rule (636 km of river-polygon lines had been dropped); lift on stream edges.
  0296/0297/0298 re-run: 0296 and 0297 outputs byte-identical, 0298 changed (tuned -18.3 %).
- Code-check round 2 spawned 04:18 UTC
- Code-check rounds 2-4 and a closing enumeration (review-round*.md); 0298 re-run after rounds 1 and 2
- Archived to planning/archive/2026-10-issue-54-chinook-rearing-tuned
