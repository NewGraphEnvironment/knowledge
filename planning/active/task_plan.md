# Task: CI: unpin the runners and add timeouts after duckdb 2.0.0's binary gap (#94)

## What happened (corrected 2026-10-26)

Every pkgdown run on PR #88 from 2026-10-25 failed at `r-lib/actions/setup-r-dependencies`: `duckdb` 2.0.0 failed
to compile from source after 32 min. `duckdb` 2.0.0 reached CRAN on 2026-10-23, and the runs fell back to source
because Posit Public Package Manager had not yet built its binaries. By 2026-10-26 it serves `duckdb` 2.0.0 as a
binary for R 4.5 and 4.6 on both Ubuntu 24.04 (`noble`) and 26.04 (`resolute`), and a run on 24.04 installed it as a
binary. So the cause was the binary gap after a release, not the 26.04 runner image (this issue first said the image).

## Decided at the gate

- Timeouts: `pkgdown` job 30 min, `update-citation` job 15 min (Al, 2026-10-26). Normal green runs take 2–5 min; a
  stall fails within half an hour and is rerun. Accepted cost: a slow-but-progressing run like #88's 100-minute attempt
  is killed too.
- Unpin to `ubuntu-latest` in this PR, verified by the PR's own pkgdown run (the `pull_request` trigger), not left
  pinned waiting for an outside probe.
- Done locally, not waiting for soul#541's shared mechanism; if soul#541 moves the workflows to a shared one later,
  knowledge migrates then.

## Phase 1: Unpin and add timeouts

- [ ] `.github/workflows/pkgdown.yaml`: `runs-on: ubuntu-latest`, drop the two-line #94 pin comment, add
      `timeout-minutes: 30` to the `pkgdown` job with a one-line comment (why: a stalled setup otherwise holds 6 h; #94)
- [ ] `.github/workflows/update-citation-cff.yaml`: same, `timeout-minutes: 15` on `update-citation`
- [ ] `/code-check` on the diff, commit with the checkbox flips

## Phase 2: Verify on the PR, then open it

- [ ] Push the branch, open the PR (`/gh-pr-push`), and watch its pkgdown run on `ubuntu-latest` sparsely
      (`gh run view <id> --json status,conclusion`, never `gh run watch`)
- [ ] Read the job log to confirm the image is 26.04 and `duckdb` installed as a binary (not "installing from source"),
      and record the setup durations in `findings.md`
- [ ] If the run fails or stalls: read which step (`gh run view --log-failed`), rerun once if it is setup/mirror; if
      duckdb (or anything) is building from source on 26.04, stop, restore the pin and keep the timeouts, and say so
- [ ] `/planning-archive`, with the measured run as the archive README's Measurement

## Owed at the end (reported, done after merge)

- [ ] `update-citation-cff.yaml` runs only on `main` (push with a `DESCRIPTION` change, or dispatch), so its unpin is
      verified after merge: `gh workflow run update-citation-cff.yaml --ref main` once the merge's runs settle, then
      confirm green and the image in its log
- [ ] Confirm the post-merge pkgdown deploy provenance on `gh-pages` names the merge SHA

## Validation

- [ ] Tests pass (no R code changes; `devtools::test()` not needed beyond the CI build)
- [ ] `/code-check` clean
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: the PR's pkgdown run green on `ubuntu-latest` with duckdb as a binary (log), YAML parses (the run
starting at all proves it), and `timeout-minutes` visible in each job's definition.

## Noted, not in scope

- At 21:28Z on 2026-10-26, main's pkgdown run 40400891471 (merge commit e3a07d8, on 24.04) had sat in
  `setup-r-dependencies` since 21:09Z, with run 40404388481 (aa0398b) pending behind it: the stall shape this issue
  describes. Reported to Al; cancelling it is Al's call.
