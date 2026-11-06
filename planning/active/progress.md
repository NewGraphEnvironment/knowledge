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
- Phase 5 test: each declaration's overrides name crate register fields, each tolerance holds within and refuses past, the declared values pinned
- Docs: CLAUDE.md paragraph and research/run_archive.md section on receipts; pkgdown index; follow-up #160 filed for the evidence build and the published visit tables
- Branch /code-check round 1: crate floor admits a crate without `file =` (capability check added at 0320's start and in the writer); a kept table's receipt named the current commit (now the record's, resolved, or none); a failed `git status` read as clean (now stops)
- Branch /code-check round 2: the kept-path receipt mixed the record's commit with today's settings and spec (now: a kept table without a receipt naming its record is regraded; the commit resolver is gone); the crate check ran on runs that do not grade; 0325 did not hold tables to records; the archive stored a receipt naming another table. All fixed; the field-by-field enumeration is in findings.md
