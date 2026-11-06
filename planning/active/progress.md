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
- crate round 3 (a symlink at the target name; NFC/NFD folding) fixed by resolving the target through the filesystem;
  the loop ended on an enumeration (`receipt_file_sha256()`'s three callers, all guarded); crate PR #48 opened
  (merge and release need Al's word)
- Phase 3: 0320 writes each grade table's receipt (fresh and kept paths), promotion checks and carries it, the
  archive takes it when present; tests with mutation checks on the promotion guard
- Phase 4: `knw_publish(receipt =)` writes and uploads each set's receipt (tables, receipt, manifest), aws calls through mockable wrappers; 0325 passes both sets' recipes and summaries
