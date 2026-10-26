# Code-check round 1: #94 (unpin runners, add job timeouts)

## Checklist read

- `soul/conventions/ci-monitoring.md`: in full.
- `code-check-python.md` (7,237 B): in full.
- `code-check.md` (330,698 B): every H3 under `## Mechanisms` in prose, table rows and evidence blocks skipped (14 sections). None of the 34 index headings outside Mechanisms names CI, workflows, timeouts or runner images, so none of them was read.
- `code-check-shell.md` (125,440 B): "A `git push` can land and still report failure", the neighbours that print with it, and "`timeout` is GNU coreutils" (index line only; it is about a local `timeout`, not Actions). The other ~95 headings were not read.
- `code-check-r.md` (177,187 B): "pak Behavior" (PPM binaries lag new releases) and "Reproducibility". The other ~105 headings were not read.
- `code-check-spatial.md` (155,517 B): no heading names CI, Actions, runners or timeouts. None was read.

## Verdict

Clean.

## Probes behind the verdict (2026-10-26, about 21:30 UTC)

- **The premise for unpinning holds now.** Posit Package Manager's `__api__/status` lists `resolute` (Ubuntu 26.04) with `binaries: True` and `sysReqs: True`. A HEAD on `cran/__linux__/resolute/latest/src/contrib/duckdb_2.0.0.tar.gz` with an R 4.6.1 user agent returns `x-package-type: binary` and `x-package-binary-tag: 4.6-resolute`. 4.6.1 is the R version the failed 26.04 runs used (run 40256692841). That run's log shows `setup-r` already pointed RSPM at `.../__linux__/resolute/latest` and that pak's sysreqs install worked on 26.04. Its only problem was the 143 source builds, so nothing else in the steps depends on the 24.04 image.
- **Job-level `timeout-minutes` bounds every step, setup and post-steps included.** Queue time is not counted. In pkgdown the `concurrency` group has no `cancel-in-progress`, so a hung run now gives up the group after 30 min instead of 6 h. Note: run 40400891471 (the e3a07d8 merge push, on the still-pinned ubuntu-24.04) had been in `setup-r-dependencies` since 21:02:14Z, 31 min at 21:33Z, with run 40404388481 pending behind it. That is the hang this change bounds, and it happened on the pinned image too.
- **A timeout during a write leaves no half state.** The JamesIves deploy pushes one commit to `gh-pages`, and a git ref update is atomic. The citation job commits and pushes on an ephemeral runner, so a kill before the push loses only an unpushed commit, which the next DESCRIPTION push regenerates.

## Not a finding, worth knowing

- Check how a timed-out job reports its conclusion before relying on it. If the API reports `cancelled`, `/gh-pr-merge` step 10 would read a run killed by the timeout as "superseded", not as a failure. I did not verify which conclusion GitHub sets for a `timeout-minutes` kill.
