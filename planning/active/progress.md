# Progress — Backlog move 9: Access gradients and gradient on the ground (#178)

## Session 2026-11-18

- Plan-mode exploration — phases approved by user (two tracks and two moves, a `fish_passage` store, gradient rows with their leap and speed basis)
- Created branch `178-backlog-move-9-access-gradients-and-grad` off origin/main; claimed #178
- Scaffolded PWF baseline from issue #178 with approved phases
- Next: start Phase 1
- Phase 1: filed #234 (fish-passage literature, this branch) and #235 (PSCIS stream slope against link's gradient); #132 is the `track:access` umbrella and #70 the `track:gradient` umbrella; move 15 is #236 (batch 24); #178 narrowed to batch 14; backlog rewritten, lanes rechecked (move 9 and move 15 free of each other; move 10 waits on 9 over `CLAUDE.md`), every open move ticks cleanly on a copy
- Found: the PSCIS habitat-confirmation layer has no gradient field; #235 reads the assessment layer's `STREAM_SLOPE`
- Phase 4, vocabulary: `leap_height` (m, cm, ft; no metric) and `swim_speed` (m/s, cm/s, ft/s; metric burst, prolonged, sustained, critical, unstated) in `knw_literature_vocab()` and its unit and metric fits; `0280` reads them through `knw_literature_read()`. Two tests written red first; 47 pass
