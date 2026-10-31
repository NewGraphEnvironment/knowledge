# Progress — White Sturgeon store (#124)

## Session 2026-10-31

- Plan-mode exploration; phases approved by Al with three gate decisions (order behind #127, one curated collection,
  every NWSRI report with a PDF)
- Created branch `124-white-sturgeon-store-gather-the-recovery` off origin/main (`9e10a19`, after #128's merge)
- Scaffolded PWF baseline from issue #124 with approved phases
- Next: start Phase 1 (no Zotero writes); Plan review runs concurrently
- Baseline `9c10882`. Plan review ran concurrently (`review-plan.md`); its two blockers were confirmed and folded in
- Phase 1: 61 NWSRI PDFs, the recovery plan, CSAS 2007/014, DFO's 1987 geomorphology volume and Hay & Co 2000
  (OCRed) gathered. `data/sturgeon_members.csv` (15, every key one live group item) and
  `data/sturgeon_additions.csv` (64). #124's body corrected, with "blocked by #127" in its plan
- Waiting on: Al's browser downloads (three publications.gc.ca PDFs; optionally McAdam 2005 and Babey 2022), and #127
- Next: parked 2026-10-31 on Al's three browser downloads and #127; paste the block under ### Resume into a fresh session

### Resume

```
Continue knowledge#124 from its parked PWF baseline. Repo ~/Projects/repo/knowledge, branch `124-white-sturgeon-store-gather-the-recovery`,
parked 2026-10-31 after Phase 1, waiting on #127, branched from origin/main at 9e10a19.
Run these in order, and stop at the first that fails; each failure means what it says:

cd ~/Projects/repo/knowledge && git fetch -q origin
git worktree list | grep -F '[124-white-sturgeon-store-gather-the-recovery]' || echo none   # a path printed: that tree holds the branch; cd to it and skip the checkout
git branch --show-current; git status --porcelain --untracked-files=no   # another branch with changes, or one another session may be on: do not check out here; git worktree add ../knowledge-124 124-white-sturgeon-store-gather-the-recovery and cd there
git checkout 124-white-sturgeon-store-gather-the-recovery   # fails: the branch is not on origin
git pull --ff-only   # fails: this machine has commits origin lacks; resume where they were made
git merge origin/main   # a conflict: main moved meanwhile; resolve it, commit, and go on

Then read planning/active/task_plan.md, findings.md, progress.md and review-plan.md if present.
The gate decisions, the measurements and the Plan-agent review are already folded in:
do not re-plan and do not re-ask them.
Phase 1 is done except the rows for Al's browser downloads (saved in data/rag/pdf/sturgeon/).
Phases 2-3 start only once #127 has merged and the Phase 2 gate holds; if it has not merged, stop and say so.
Otherwise run every phase to the PR (/code-check branch, /planning-archive,
/gh-pr-push). This message is the resume instruction that starts the run-to-PR
mandate; the merge stays with me.
```
