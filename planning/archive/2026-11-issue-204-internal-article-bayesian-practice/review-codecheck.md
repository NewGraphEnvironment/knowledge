# /code-check branch (2026-11-13)

| Round | Findings | Fixed | Accepted | Inside previous fix? |
|-------|----------|-------|----------|----------------------|
| 1 | 1 (settings guard `==` passes on character(0)) | 1 | 0 | — |
| 2 | 1 (navbar test always skips under R CMD check; no job ran it) | 1 | 0 | n |
| 3 | 1 (scope test held to fitted keys only, so WCT rearing unguarded) | 1 | 0 | y: the plan review's fix that removed the WCT literal |

Mechanism (round 3): each guard's verdict was read where it was written (a local render, a local devtools::test()),
not where it runs, and "could not be evaluated" folded into "pass". Round 3 enumerated every guard the branch adds
(38 rows: article load chunk, both tests, the workflow step, vignette_method.R's scope block, the quote check) with
where it runs and whether it fails there; the only "no" rows were the WCT gap, fixed in 9de2fca8 and measured in a
worktree (the scope test and the article's setequal() guard both fail on a bundle missing WCT rearing). The loop
ended on that enumeration.
