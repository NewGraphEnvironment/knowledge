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
- Next: Phase 2, the bundle
