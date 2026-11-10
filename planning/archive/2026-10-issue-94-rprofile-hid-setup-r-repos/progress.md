# Progress — CI: unpin the runners and add timeouts after duckdb 2.0.0's binary gap (#94)

## Session 2026-10-26

- Plan-mode exploration — phases approved by user (timeouts 30 / 15 chosen at the gate)
- Created branch `94-ci-unpin-the-runners-and-add-timeouts-af` off main
- Scaffolded PWF baseline from issue #94 with approved phases
- Next: start Phase 1
- Plan review (Plan agent) folded in: b7e393b; `planning/active/review-plan.md`
- Phase 1: both workflows on `ubuntu-latest` with job `timeout-minutes` 30 / 15. `/code-check`, three rounds
  (`review-round{1,2,3}.md`): round 1 Clean; round 2 two verification gaps (label mid-migration, citation job not run
  by the PR); round 3 a timeout kill reports `cancelled` (verified on drift and fly). No code change from any round;
  the plan and findings carry each. Ended at round 3: it named the mechanism (a guard that fails toward pass) and
  enumerated where it reaches in the two files (the two `timeout-minutes` lines), and no round found a defect inside
  a fix.
- Pushed, opened PR #97; dispatched the citation workflow on the branch (run 40406671489); PR pkgdown run 40406663722.
- An internal issue's body gained the "a timeout reads as `cancelled`" bullet (`--log-failed` empty on both drift and fly runs).
- Cancelled main's stuck runs 40400891471 and 40404388481 on Al's word (22:05Z).
- Citation dispatch 40406671489: green on `ubuntu-26.04`, pushed nothing (branch still 6092dc9).
- PR pkgdown 40406663722: killed by the 30-min timeout on 26.04; the logs show every package built from CRAN source
  on both images (findings). Escalated to Al: the plan's premise is disproven.
- `.Rprofile` code-check: round 1 (`review-rprofile-round1.md`) found self-sourcing recursion when `~/.Rprofile` is this
  file; the `normalizePath()` guard (291e8af) fixed it only from the checkout. Round 2 (`review-rprofile-round2.md`)
  found that defect inside the fix: started elsewhere, the guard compared against a missing `./.Rprofile` and recursed.
  Replaced with a once-per-process option flag. Ended by enumeration, not a third round: every way R reaches the file
  (project profile; `~/.Rprofile` as a symlink, a hard link, or HOME at the checkout; `R_PROFILE_USER`; a callr
  child), each started in and outside the checkout, 9 cases, all finish; a separate home profile's repos load in the
  project and in the callr child (the option is not inherited).
- Final-commit run 40414769800 timed out on the apt mirror (setup-r 19.5 min); rerun green in 2.5 min (attempt 2).
- #94 and the PR body rewritten to the found cause, without naming private repos; the conventions issue (soul, private)
  gained the corrected cause and the `.Rprofile` lesson.
- Not done: rewording commit 4cc6dad, whose message names the conventions issue by number (an internal issue): auto mode
  refused the history rewrite as destructive. Left for Al, with the edit-history revisions of #94 and the PR body
  that named it.
- Al, 2026-10-26: leave commit 4cc6dad's mention of the conventions issue; no reword, history kept.
