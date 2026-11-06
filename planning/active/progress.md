# Progress: Write the shared provenance receipt for published tables and grades through crate, with declared tolerances (#154)

## Session 2026-11-05

- Plan-mode exploration; gate decisions by Al (crate #44 merging now; tolerances declared now, revised after #158;
  `file =` argument in crate for per-key grade receipts; receipts beside the existing records)
- Created branch `154-write-the-shared-provenance-receipt-for` off origin/main (4060cb2)
- Scaffolded PWF baseline from issue #154 with approved phases
- Next: start Phase 1

## Session 2026-11-06 (UTC)

- Plan review (Plan agent) landed: `planning/active/review-plan.md`, folded into the plan (3da7c99)
- crate#47 filed; crate branch `47-receipt-file-name` adds `file =`; code-check round 1 (a `file` naming a part
  overwrote it) and round 2 (the string guard missed `.//`; config files and lockfile unguarded) fixed by a
  resolved-path check over every hashed file; round 3 running
- Phase 2 declarations and helpers, and the grade receipt writer, with tests (installed crate from the branch)
