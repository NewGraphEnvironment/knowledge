# Progress — statistics store: seven cited works of the detection methods that the library does not hold (#274)

## Session 2026-11-24

- Plan-mode exploration — phases approved by user
- Created branch `274-statistics-store-seven-cited-works-of-th` off origin/main
- Scaffolded PWF baseline from issue #274 with approved phases
- Next: start Phase 1

## Phase 1 (in progress), 2026-11-24

- Plan review ran beside Phase 1 (`review-plan.md`); its findings are folded into `task_plan.md`, and the plan's
  decision 4 is withdrawn into an Open decision for Al (review A1)
- CrossRef resolved for all six DOIs; none of the seven is in any local library
- PDFs in hand: Kellner 2023 and Morris 2019 (versions of record), Taylor 2008 (accepted manuscript)
- Next: open-copy routes for Best & Fisher 1979, O'Brien 2003, Albert & Anderson 1984 that need Al's clicks
  (ResearchGate, ORBi's request form), then the Open decision
- O'Brien 2003 found on ResearchGate (version of record); the abstract-only question became moot
- Four rows appended (Morris, Kellner, Taylor, O'Brien), enumerated from 0270's own `addition_item()` against the
  title pages; filed #278 for 0270's undecoded journal names, worked around here with Taylor's `override`
- Waiting on Al's ResearchGate search for Albert & Anderson 1984 and Best & Fisher 1979
- 2026-11-25: Al found Best & Fisher 1979 and Albert & Anderson 1984 on ResearchGate (versions of record); their
  rows appended with `override` for pages and creators. Phase 1 done: six of seven filed with PDFs, Seber 1982 the gap
- Next: Phase 2, measure the four collections, then 0270's dry run

## Phase 2, 2026-11-25

- Measured the four collections before and after (`scripts/logs/rag/20261125_0270_detection_measure_*.log`):
  detection 24 -> 30 items, all keyed with PDFs; the other three unchanged
- 0270 dry run (6 would create), live run (6 created, each PDF's md5 confirmed through the Web API), second dry
  run a no-op
- Next: Phase 3

## Phase 3, 2026-11-25

- In a worktree of this branch with a real `data/rag/`: before-queries on the verified pull
  (32 documents), the rebuild (38 documents, 6 added, 0 dropped, held to the expected file), after-queries (all three
  expected works hit), every origin a live group attachment
- Pushed at 17:22 UTC from head `1e89da92`; the bucket's ETag matches the file at 8 MiB parts
- Next: Phase 4, the README line and #274's body

## Phase 4 and validation, 2026-11-25

- `scripts/README.md`'s statistics line names the works the detection documentation cites and Seber 1982's gap;
  #274's body carries the outcome per work and #278
- Build worktree removed. Tests: 466, 0 failed, 1 error raised by the database server, not by R code (findings)
- `/code-check branch`: round 1 clean; rounds 2, 3 and 4 found facts learned about a machine in the planning files and
  the review files' quotes of them; restated as requirements or references, and the unpushed commits that carried
  them folded into one before the push
- Public sweep: no hits in this branch's files or commit messages
