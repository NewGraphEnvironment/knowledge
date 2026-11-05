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

## Session 2026-11-05 (second machine, phases 3–5)

- Resumed from the Resume block (RESUME-OK at b4f50a2); merged origin/main (PR #152) cleanly.
- Phase 3: `vignettes/_cut_points.Rmd` drafted from the bundle, every prose number inline and guarded. Forms tried
  at page width: the side-by-side example maps failed the look-alike test (the cut pieces are tens of metres at river
  mouths, invisible in a 1.5 km window), so the examples are a strip diagram of each network's segments along the
  stream; the group map is two rules on link's full network (own slope at 13 % against minimal parent's at 9 %, which
  differ only in the slope read) with a zoom on the 15 km square holding most disagreement.
- Places computed, not dictated: `data-raw/vignette_cut_points_places.R` (Taylor Creek joins the Skeena, not the Kalum
  its group is named for). BC Geographical Names is Access Only in the catalogue, so the file keeps town names only.
- `vignettes/cut_points.bib` written by `data-raw/vignette_bib.R` (Zotero launched here; the other two `.bib` files
  came back unchanged).
- Phase 4: six tests in `test-vignette-data.R` (both rds ship; tracked logs and staged inputs unchanged; places on this
  bundle; premise equals the three segment gradient logs; setups, transfer and other keys equal their logs; examples
  meet the stated criteria). Restore-the-bug: one byte changed in the setup_compare csv failed the tracked-source and
  C2 tests, then restored. The methodology article's ignored-source test fails on this machine's older `data/fdis`
  (pre-existing, not this branch). CLAUDE.md, `data-raw/README.md` and the research file name the article.
- Phase 5: branch installed, draft rendered with every `stopifnot()` passing; no pandoc footnote markers, no
  unresolved `\@ref` or citation, figures and tables numbered once (3 and 2). Body prose 1,503 words, file 462 lines
  (no forecast was set; the five reader questions and their guards set it). Figures checked at page width: profile
  labels moved off the lines, strip labels on a white backing, group map with its zoom. Review copy published as a
  private Artifact (converted by soul's `article_review_copy.py`). The rename and the methodology section wait on
  Al's approval of the rendered page.
- Full suite: 2,026 pass; failures are environmental and outside this branch's files' logic: the methodology
  article's ignored-source md5s (this machine's older `data/fdis`) and `test-link_place.R`'s live-schema test (no rows
  in this machine's database). `pkgdown::check_pkgdown()` clean; lint clean on the changed files.
- `/code-check branch`, five rounds (`review-round1.md` to `review-round5.md`); every finding was in the article's
  claims or captions, none in the scripts' code paths. Mechanism (round 3): sentences written from the research notes,
  each guarded on the number it quotes but not on the words that scope it (sites/visits, fish/chinook, a limit/a rule,
  7,823/4,858 visits, lists read as complete). Rounds 3, 4 and 5 each found defects inside an earlier round's fix, so
  only an enumeration could end it; round 4 changed approach (fewer restated details, a link to the methodology
  article instead of a population list). Round 5 enumerated 76 claims, six failing: the group map's panels were drawn
  on canvases of another shape, so tmap padded them and both scale bars were wrong (fixed by drawing each panel on a
  canvas of its own box's shape; measured on the render: 20 km bar 123 px at 6.17 px/km, outlined box 29.2 km, dashed
  15 km square 540 of 1,050 px, 4 km bar 143 px at 36 px/km), a link to `#steps` where `#lost` names the filters,
  "the only" without "across the province", and a caption that missed "drains into".

