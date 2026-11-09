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
- Phase 5: filed the umbrellas, #170 to #180 (moves 1 to 11, label `umbrella`), and wrote them into the file; every open move ticks cleanly on a copy; `next` prints `/planning-init #170`
- Phase 5: #80's open item (who sets link's flow numbers) added to #139's "To file when reached"; closed #68, #72, #48, #80 and #3 with their reasons; transferred #8 to the skills repository; ticked #120's answered premise box
- Phase 6: Al read the link body and approved it; filed as link#468; its number is written into the backlog header; the body is kept as `link_pass.md`
- Code-check round 1: one finding (#72's line references taken from a stale checkout); fixed in the planning files and in #72's closure comment
- Code-check round 2: four findings, all fixed. #72 was closed with the readers' half undone, so it was reopened and placed in batch 13 (with #177's body updated); link#468 said three moves wait on link where two do; #70's step 1 still owes PSCIS and FISS; the most-named list missed #13 and #115
