# Progress — No-fish-captured layers for COTR, UNTH, LNTH and UPCE (#5)

## Session 2026-09-04

- Plan-mode exploration; one Plan reviewer (17 findings, three Blockers, all verified before
  inclusion — the PINE 5-of-77 silent drop reproduced with a sheet-name probe). Phases approved.
- Phase 0: archived #4's PWF as parked on its branch, merged PR #6, corrected #4's body,
  cut `5-no-fish-captured-layers-for-cotr-unth-ln` off main.
- Scaffolded PWF baseline from issue #5 with approved phases.
- Next: Phase 1 — preflight, tunnel positive control, the `WSG_TARGET` fix and the guards.
- Phase 1 done: tunnel measured as the superset (kept primary, local fallback added);
  `WSG_TARGET` guard in all three; reports / keyed fetch log / parse log / reconcile gate;
  PINE regression identical; both restored defects fire the gate.
- COTR run started in the background (`scripts/logs/fiss/20260904_fiss_run_cotr.log`).
- COTR ran (first attempt tripped the 0200 guard on three HTTP 403 pages; guard taught to
  record HTTP status), then UNTH/LNTH/UPCE in one batch. Code-check round 1: 6 findings, all
  fixed (typed zero-row steps, stage A/B reconcile, set-based manifest check, stale-manifest
  unlink, character report_id). `"11U"` zone strings found dropping 116 sites per North
  Thompson group; fixed with `zone_num()`; 0220 re-run on all five groups.
- Code-check rounds 2-4 (5 + 2 + 1 findings, all fixed; 0210 moved to curl for an explicit HTTP
  status). Re-fetched UNTH/LNTH, re-ran the gate on all five groups: all pass. Committed the
  scripts + PINE control, then one commit per group, then docs and planning.
- Filed #7 (pkg graduation) and #8 (skill). Next: archive, PR.
