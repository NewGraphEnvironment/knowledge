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
- Stopped after phase 2 as decided at the gate: phases 3–5 (the draft article, tests and pins, render and review) run
  on the other machine from `inst/vignette-data/cut_points.rds`, which needs no database and no `data/`. The stage
  stays on the database's host; a figure needing anything outside the bundle means rerunning phases 1–2 there.
- Next: Phase 3, `vignettes/_cut_points.Rmd`

### Resume

```
Continue knowledge#149 mid-run. Repo ~/Projects/repo/knowledge, branch `149-an-article-on-how-link-s-cut-points-move`, last commit b4f50a2
on 2026-11-05.
Run these in order, and stop at the first that fails; each failure means what it says:

cd ~/Projects/repo/knowledge && git fetch -q origin
git worktree list | grep -F '[149-an-article-on-how-link-s-cut-points-move]' || echo none   # a path printed: that tree holds the branch; cd to it and skip the checkout
git branch --show-current; git status --porcelain --untracked-files=no   # another branch with changes, or one another session may be on: do not check out here; git worktree add ../knowledge-149 149-an-article-on-how-link-s-cut-points-move and cd there
git checkout 149-an-article-on-how-link-s-cut-points-move   # fails: the branch is not on origin
git pull --ff-only   # fails: this machine has commits origin lacks; resume where they were made
git merge origin/main   # a conflict: main moved meanwhile; resolve it, commit, and go on
git merge-base --is-ancestor b4f50a2 HEAD && echo RESUME-OK   # no RESUME-OK: b4f50a2 was never pushed; resume on the machine that made it

Then read planning/active/task_plan.md, findings.md, progress.md and review-plan.md if present.
The gate decisions, the measurements and the Plan-agent review are already folded in:
do not re-plan and do not re-ask them.
Continue at the first unticked task in task_plan.md; the run-to-PR mandate is already
running. The merge stays with me.
```
