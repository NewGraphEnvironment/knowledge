# Progress — Backlog pass: batch the open issues into moves with umbrellas (#169)

## Session 2026-11-09

- Read every open issue body and its comments, probed premises against origin/main and peer issue states (before #169 was filed; the read is parked in `findings.md`, the umbrella drafts in `umbrellas.md`)
- Filed #169 for the pass, as the sweep asks above about 50 open issues
- Plan-mode gate: phases approved by Al, with the closures, transfer and moves; a phase handing link its own pass issue added at the gate
- Created branch `169-backlog-pass-batch-the-open-issues-into` off origin/main (b69365b)
- Next: Phase 2, freeze
- Phase 2: froze 59 open issues; the one new since the read is #169, this pass's own issue
- Phase 3: wrote `planning/backlog.md` (umbrella cells as placeholders `#U<n>` until Phase 5); coverage: all 59 placed
- Phase 4: split the drafts into 11 bodies in the git directory, each ending with the backlog pointer; `public_leak_scan` clean on them and the file. Only formatting changed from the drafts Al read (a blank line before each table, cross-repo references written `NewGraphEnvironment/<repo>#N` so they link)
