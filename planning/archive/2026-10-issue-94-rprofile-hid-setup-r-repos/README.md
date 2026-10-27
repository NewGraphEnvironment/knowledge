## Outcome

knowledge's CI installed every R package from CRAN source because the repo's own `.Rprofile` replaced the
`~/.Rprofile` into which `r-lib/actions/setup-r` writes the Posit binary repository: R reads one user profile, and
a project one wins. A saved package library hid it on 24.04 until `duckdb` 2.0.0 changed, and 26.04, which had no
saved library, resolved all 143 to source (#88's runs built 110, then `duckdb` failed to compile at 32 min). #94 had blamed first the 26.04 image, then `duckdb`'s binary gap at Posit; both
were wrong, and the "green" 24.04 run it cited as installing a binary had compiled `duckdb` for 57 min. The fix makes
`.Rprofile` source `~/.Rprofile` once per session (an option flag, after code-check round 2 found the first guard,
a `normalizePath()` comparison, recursed when R started outside the checkout). Both workflows are back on
`ubuntu-latest`, with `timeout-minutes` 30 (pkgdown) and 15 (citation). Wrong turns kept: the plan's premise came
from the issue; the stuck main run 40400891471 that was cancelled as "stalled" was compiling `duckdb` and would
likely have finished. A run killed by `timeout-minutes` ends `cancelled`, not `failure`, with only an annotation to
tell it apart.

## Measurement

- Before the fix, PR run 40406663722 (`ubuntu-26.04`, no cache): 143 packages from `cran.rstudio.com/src/contrib`,
  killed at 30 min (`setup-r` 19 min on a slow apt mirror, then system requirements).
- After, PR run 40413562090 (`ubuntu-26.04`, no cache): 134 packages as Posit 26.04 binaries from
  `__linux__/resolute/latest`, `setup-r-dependencies` 3 min 24 s, green in 5 min. So the 30-min limit is about 6x a
  cold run, not a rebuild budget.
- Earlier 24.04 run 40353103033: `Built duckdb 2.0.0 (57m 5.6s)` from CRAN source.
- Remaining stall: the Ubuntu apt mirror. Run 40414769800 attempt 1 spent 19.5 min in `setup-r` (4–5 min waits on
  single files) and was killed at 30 min; attempt 2 green in 2.5 min (`setup-r` 33 s).
- Timeout conclusion: `cancelled` at run and job level, annotation "The job has exceeded the maximum execution time of
  30m0s" (run 40406663722), matching the 6 h kills on drift 38592249287 and fly 37670553822.

## Evidence

GitHub Actions runs `4040666*`, `4040667*`, `40413562090`, `40414769800` on branch
`94-ci-unpin-the-runners-and-add-timeouts-af`; reviews `review-*.md` in this directory.

## Owed

- After merge and `/gh-pr-merge`'s release commit, confirm the citation run that the `DESCRIPTION` bump triggers on
  main is green on `ubuntu-latest` (replaces a manual dispatch; plan review)
- Confirm the `gh-pages` deploy provenance names the newest non-bot main SHA (the merge's own run may be cancelled
  by a newer pending one in the `pkgdown-true` group), and so that deploy works on 26.04, which the PR run skips

Closed by: PR #97
