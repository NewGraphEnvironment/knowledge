# Progress — An article on how link's cut points move the tuned rules, shown on our own data (#149)

## Session 2026-11-05

- Plan-mode exploration on m4 (the database's host) — phases approved by user; per-key table narrowed to chinook
  rearing on its four setups, and this session stops after phase 2 (both Al's, at the gate)
- Created branch `149-an-article-on-how-link-s-cut-points-move` off origin/main (28cf368)
- Scaffolded PWF baseline from issue #149 with approved phases
- Phase 1: `data-raw/cut_points_stage.R` (e2b4f47) staged 37 files (540 MB) into `data/stage/cut_points/` on m4,
  held to each run's md5s; log `scripts/logs/habitat/20261105_cut_points_stage.txt`. The issue's "a few hundred
  streams" was wrong: 1,215 population sites cross 9/11/13 % between two setups, but only 24 with fish, on 22 lines in
  14 groups, so only those lines are staged (±3 km).
- Plan review (`review-plan.md`): two blockers taken (maps' water and background; the profile's elevations), the
  pinning moved off the promotable tables onto logs written once and the stage; one finding wrong (#92's evidence is
  on the host). Staging rerun (8efc641): 22 files, every run file held to `setup_compare.R`'s logged md5s, log
  `20261105_cut_points_stage-2.txt` (the first log describes a stage overwritten minutes later).
- Phase 2: `data-raw/vignette_cut_points.R` wrote `inst/vignette-data/cut_points.rds` (1.32 MB). Every check held:
  premise equals the three segment gradient check logs (86.2/10.2, 44.2/6.6, 3.4/3.0 %), the four setups equal
  setup_compare's csv, the transfer equals the minimal and parent km, four of seven keys moved and three sit outside.
  Concept: UFRA `101349_1_1`; examples KLUM `48274_602_1` (Taylor Creek), LNAR `40144_1_1`, LSKE `142532_2_1`; map MORK.
  `inst/NOTICE.md` names the new rds.
