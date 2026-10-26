# Findings — CI: unpin the runners and add timeouts after duckdb 2.0.0's binary gap (#94)

## Issue context

## What happened (corrected 2026-10-26)

Every pkgdown run on PR #88 from 2026-10-25 failed at `r-lib/actions/setup-r-dependencies`: `duckdb` 2.0.0 failed
to compile from source after 32 min. `duckdb` 2.0.0 reached CRAN on 2026-10-23, and the runs fell back to source
because Posit Public Package Manager had not yet built its binaries. By 2026-10-26 it serves `duckdb` 2.0.0 as a
binary for R 4.5 and 4.6 on both Ubuntu 24.04 (`noble`) and 26.04 (`resolute`), and a run on 24.04 installed it as a
binary. So the cause was the binary gap after a release, not the 26.04 runner image (this issue first said the image).

## Done, and to undo

Both workflows that install R packages, `pkgdown.yaml` and `update-citation-cff.yaml`, were pinned to
`ubuntu-24.04` on PR #88 with a comment naming this issue. The pin probably fixed nothing. Unpin (back to
`ubuntu-latest`) once a run on it is green.

## Still owed

- A `timeout-minutes` on both jobs. On 2026-10-26 runs on 24.04 were slow and stalled independently of `duckdb`:
  one stuck mid-download from the Ubuntu apt mirror for 15–30 min, another finished installing every package and
  then printed nothing for 24 min before it was cancelled, and `setup-r` took 11–24 min where it had taken under a
  minute. With no timeout a stalled job holds for up to 6 h. PR #88 was merged on the local checks (954 tests pass,
  the article renders) while those runs stalled.
- The same changes are being planned for every NGE R repo from one place in the organisation's conventions repo;
  this issue is knowledge's instance of it.

## Run durations before the change (measured 2026-10-26 21:27Z, `gh run list --status success`)

- pkgdown, green runs 2026-10-21 to 10-22 on main and branches: 2–5 min (created to updated).
- pkgdown 40353103033 (PR #88, 24.04, attempt 3): job 17:53:40Z to 19:34:06Z, about 100 min, green.
- Update CITATION.cff green runs 2026-10-20 to 10-26: 3–5 min.

## `ubuntu-latest` is mid-migration (checked 2026-10-26 21:37Z)

actions/runner-images#14748: the label moves to Ubuntu 26.04 over several weeks from 2026-10-19, to finish by
2026-11-19. Run logs print the image: 40256692841 (unpinned, 2026-10-26 01:57Z) ran on `ubuntu-26.04`, 40353103033
(pinned) on `ubuntu-24.04`, both runner version 20261021.618. So a green `ubuntu-latest` run proves 26.04 only if its
log says `Image: ubuntu-26.04`.

## A `timeout-minutes` kill reports `cancelled` (code-check round 3, verified 2026-10-26 21:43Z)

drift 38592249287 and fly 37670553822 (6 h default kills): run and job conclusion `cancelled`; the check run's
annotations carry "The job has exceeded the maximum execution time of 6h0m0s". So a kill at 30 or 15 min is invisible
to a `conclusion == "failure"` filter and reads as superseded in `/gh-pr-merge` step 10. Not a defect of this diff
(the 6 h kill was the same), but the gate's "a stall fails" was wrong; routed to soul#541.

## Errors Encountered

| Error | Resolution |
|-------|------------|
