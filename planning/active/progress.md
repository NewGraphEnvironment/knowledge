# Progress — FDIS site visits include surveys loaded twice under different collection ids (#35)

## Session 2026-10-17

- Plan-mode exploration and a read-only probe of the build — phases approved by user, with: drop and
  map in 0230, the issue's signature without fishing time, the full chain including CH, publish v2
  ("go all phases and publish to v2").
- Created branch `35-fdis-site-visits-include-surveys-loaded` off main
- Scaffolded PWF baseline from issue #35 with approved phases
- Next: Phase 1 (baseline reproduction)
- Phase 2: repeat-survey block in 0230 (signature, keep rule, map, ledger rows, guards). Dry check of
  0230 up to placement: 1,286 groups, 1,413 visits dropped (657 fish, 660 zero, 96 unknown), 4,370 fish
  rows and 1,487 passes with them; 12 single-collection groups left alone; fish differ in 132 groups,
  habitat in 112, fishing time in 47; the kept copy is not the lowest id in 117.
- Phase 3: 0293's first_copy and 0294's dup_of removed, with their consumers in 0295-0298; 0299 to v2; READMEs, CLAUDE.md and data/fdis_README.md point at v2.
