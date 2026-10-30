# Progress — Arctic grayling and bull trout store: clean the two species collections, build it, and add grayling to habitat_modelling (#122)

## Session 2026-10-30

- Plan-mode exploration — phases approved by user (after two rounds: cred work moved upstream and concurrent;
  package versions checked against latest)
- Created branch `122-arctic-grayling-and-bull-trout-store-cle` off origin/main
- Scaffolded PWF baseline from issue #122 with approved phases
- Next: start Phase 1

### Phase 1 (2026-10-30)

- `0270 --parent`; `find_collection()` refuses a name that exists elsewhere in the group. Dry runs:
  `--collection grayling|bull_trout --parent 9U54XAND` print `exists` with GELFSUTU / VHWEK6RE; without `--parent`
  both refuse and name the key; an unused name still says `would create`.
- `0270 --dry-run` on habitat_modelling: output byte-identical to the script at HEAD. Both report one `MISSING`,
  `hagen_weber2019Limitingfactorsa`: today's merge re-keyed the survivor (Phase 2 rekeys the repo's rows).
- Filed cred#40 (the three attachment-pick defects), at Al's request.
- Plan review (Plan agent) landed; findings folded in, see findings.md "Plan review".

### Phase 2: the Hagen & Weber rekey (2026-10-30)

- `hagen_weber2019Limitingfactorsa` -> `hagen_weber2019Limitingfactors` in 22 rows of `literature_evidence.csv` and the
  habitat_modelling, temperature and flow members (byte-level replace; line endings kept).
- `0280`: 1,145 rows (649 text, 288 table, 145 OCR, 6 abstract, 57 none rows), registry 81 rows / 117 quotes, all
  verified; coverage, thermal and flow grids full. 13.4 min. Logs `scripts/logs/habitat/20261030_literature_verify*.csv`.

### Phases 2, 3 and 6 (2026-10-30)

- Phase 2 cleanup live 22:27 UTC; re-run a no-op; re-measured (findings.md, "Phase 2: the cleanup"). Three PDFs wait on
  Al's browser (COSEWIC 2012, Carr et al. 2020, the Metolius report).
- Phase 3: `0150` names what a build leaves out (findings.md). Al is working cred#40 in a cred session; the cred#35
  re-check on ragnar 0.3.1 is for that session, since ragnar moves here only with the cred tag.
- Phase 6: `ACTION=query STORE=pine` returns hybrid results under cred 0.4.0 (22:32 UTC); CLAUDE.md note rewritten
  (cred#27 fixed, cred#40 open); `0150` refuses `ACTION=query` below cred 0.4.0 (fires with the floor raised to 0.5.0).

### Resume

Waiting on: Al's three browser PDFs (paths in task_plan.md, Phase 2) and the cred#40 tag (Phases 4-5).

```
Continue knowledge#122 mid-run. Repo ~/Projects/repo/knowledge, branch `122-arctic-grayling-and-bull-trout-store-cle`, last commit dab028c
on 2026-10-30.
Run these in order, and stop at the first that fails; each failure means what it says:

cd ~/Projects/repo/knowledge && git fetch -q origin
git worktree list | grep -F '[122-arctic-grayling-and-bull-trout-store-cle]' || echo none   # a path printed: that tree holds the branch; cd to it and skip the checkout
git branch --show-current; git status --porcelain --untracked-files=no   # another branch with changes, or one another session may be on: do not check out here; git worktree add ../knowledge-122 122-arctic-grayling-and-bull-trout-store-cle and cd there
git checkout 122-arctic-grayling-and-bull-trout-store-cle   # fails: the branch is not on origin
git pull --ff-only   # fails: this machine has commits origin lacks; resume where they were made
git merge origin/main   # a conflict: main moved meanwhile; resolve it, commit, and go on
git merge-base --is-ancestor dab028c HEAD && echo RESUME-OK   # no RESUME-OK: dab028c was never pushed; resume on the machine that made it

Then read planning/active/task_plan.md, findings.md, progress.md and review-plan.md if present.
The gate decisions, the measurements and the Plan-agent review are already folded in:
do not re-plan and do not re-ask them.
Continue at the first unticked task in task_plan.md; the run-to-PR mandate is already
running. The merge stays with me.
```
