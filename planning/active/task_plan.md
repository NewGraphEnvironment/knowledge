# Task: CI: unpin the runners and add timeouts after duckdb 2.0.0's binary gap (#94)

## What happened (corrected 2026-10-26)

Every pkgdown run on PR #88 from 2026-10-25 failed at `r-lib/actions/setup-r-dependencies`: `duckdb` 2.0.0 failed
to compile from source after 32 min. `duckdb` 2.0.0 reached CRAN on 2026-10-23, and the runs fell back to source
because Posit Public Package Manager had not yet built its binaries. By 2026-10-26 it serves `duckdb` 2.0.0 as a
binary for R 4.5 and 4.6 on both Ubuntu 24.04 (`noble`) and 26.04 (`resolute`), and a run on 24.04 installed it as a
binary. So the cause was the binary gap after a release, not the 26.04 runner image (this issue first said the image).

## Decided at the gate

- Timeouts: `pkgdown` job 30 min, `update-citation` job 15 min (Al, 2026-10-26). Normal green runs take 2–5 min; a
  stall ends within half an hour and is rerun by hand. Corrected by code-check round 3: a
  `timeout-minutes` kill ends the run as `cancelled`, not `failure` (measured on drift 38592249287 and fly 37670553822,
  6 h kills; the only marker is the annotation "The job has exceeded the maximum execution time"), so it does not
  "fail": the session-start scan (`conclusion == "failure"`) misses it and `/gh-pr-merge` step 10 reads it as
  superseded. That was true of the 6 h kill too; the detection fix is org-wide and goes to soul#541's body, not here. Accepted cost: a slow-but-progressing run like #88's 100-minute attempt
  is killed too.
- Unpin to `ubuntu-latest` in this PR, verified by the PR's own pkgdown run (the `pull_request` trigger), not left
  pinned waiting for an outside probe.
- Done locally, not waiting for soul#541's shared mechanism; if soul#541 moves the workflows to a shared one later,
  knowledge migrates then.

- **Revised 2026-10-26 22:30Z** after the PR run timed out (findings): every package came from CRAN source on both
  images, because the repo's `.Rprofile` replaced the `~/.Rprofile` where `setup-r` writes the Posit repository. Al
  first approved re-pinning to 24.04 with a 120-min pkgdown timeout and a root-cause issue in soul; the cause then
  proved to be knowledge's own, so the fix is `.Rprofile` sourcing `~/.Rprofile` (Phase 3), and the unpin and 30 / 15
  stand if the PR's next 26.04 run gets binaries. If it does not, fall back to Al's approved re-pin + 120 min.

## Phase 1: Unpin and add timeouts

- [x] `.github/workflows/pkgdown.yaml`: `runs-on: ubuntu-latest`, drop the two-line #94 pin comment, add
      `timeout-minutes: 30` to the `pkgdown` job with a one-line comment (why: a stalled setup otherwise holds 6 h; #94)
- [x] `.github/workflows/update-citation-cff.yaml`: same, `timeout-minutes: 15` on `update-citation`
- [x] `/code-check` on the diff, commit with the checkbox flips

## Phase 2: Verify on the PR, then open it

- [x] Push the branch, open the PR (`/gh-pr-push`), and watch its pkgdown run on `ubuntu-latest` sparsely
      (`gh run view <id> --json status,conclusion`, never `gh run watch`)
- [x] Read the job log for the image (`gh run view <id> --log | grep -m1 'Image: '`): `ubuntu-latest` moves to 26.04
      over 2026-10-19 to 11-19 (actions/runner-images#14748), so a run can still land on 24.04 and then says nothing
      about 26.04; rerun until a run shows `ubuntu-26.04` (code-check round 2)
- [x] Confirm the image is 26.04 and `duckdb` installed as a binary (not "installing from source"),
      and record the setup durations in `findings.md`
- [x] Dispatch the citation workflow on the branch (`gh workflow run update-citation-cff.yaml --ref <branch>`), which
      runs the branch's YAML on `ubuntu-latest`; confirm green and that it pushed nothing (plan review)
- [x] Read the **first** attempt's log of each: the R library cache is keyed on the OS version, so only the first
      26.04 run installs packages; a rerun restores the cache and shows no duckdb install (plan review)
- [x] Write into soul#541's body that a `timeout-minutes` kill reports `cancelled`, so the convention's scan and
      `/gh-pr-merge` step 10 need to read the annotation (code-check round 3)
- [ ] Record the probe result on soul#541 (this PR's run is its "one probe run on `ubuntu-latest`")
- [x] If the run fails, stalls or ends `cancelled`: read which step from `gh run view <id> --json jobs` and the job's
      annotations (`--log-failed` prints nothing for a timeout kill; code-check round 3), rerun once if it is setup/mirror; if
      duckdb (or anything) is building from source on 26.04, stop, restore the pin and keep the timeouts, and say so
- [ ] `/planning-archive`, with the measured run as the archive README's Measurement

## Phase 3: Fix the repository the install reads (added 2026-10-26)

- [x] `.Rprofile` sources `~/.Rprofile` first; tested locally (repo root now sees `rbbt.default.library_id`; with a
      setup-r-like `~/.Rprofile` under a temp `HOME`, `getOption("repos")` leads with RSPM); CLAUDE.md says why
- [x] PR run on 26.04: 134 packages as 26.04 binaries from the RSPM URL, green in 5 min (run 40413562090)
- [ ] `/code-check` on the `.Rprofile` and CLAUDE.md change
- [ ] Correct #94's and soul#541's bodies (the 24.04 run compiled duckdb in 57 min; the cause was the project
      `.Rprofile`, so it is knowledge's, not org-wide, apart from a convention line)

## Owed at the end (reported, done after merge)

- [ ] After merge and `/gh-pr-merge`'s release commit, confirm the citation run that the `DESCRIPTION` bump triggers on
      main is green on `ubuntu-latest` (replaces a manual dispatch; plan review)
- [ ] Confirm the `gh-pages` deploy provenance names the newest non-bot main SHA (the merge's own run may be cancelled
      by a newer pending one in the `pkgdown-true` group), and so that deploy works on 26.04, which the PR run skips

## Validation

- [ ] Tests pass (no R code changes; `devtools::test()` not needed beyond the CI build)
- [ ] `/code-check` clean
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: the PR's pkgdown run and a branch dispatch of the citation workflow, both green on `ubuntu-latest`, with
duckdb as a binary in pkgdown's first-attempt log; both YAMLs parse (each run starting proves its own file); deploy
on 26.04 only after merge (owed).

## Noted, not in scope

- At 21:28Z on 2026-10-26, main's pkgdown run 40400891471 (merge commit e3a07d8, on 24.04) had sat in
  `setup-r-dependencies` since 21:09Z, with run 40404388481 (aa0398b) pending behind it: the stall shape this issue
  describes. Reported to Al; cancelling it is Al's call. It holds the `pkgdown-true` group, so post-merge runs queue
  behind it until it ends: settle it before merging (plan review).
