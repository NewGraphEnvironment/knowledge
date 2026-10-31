# Progress — Zotero's database is now WAL: the guarded copies and the immutable reads miss uncheckpointed writes (#127)

## Session 2026-10-31

- Plan-mode exploration — phases approved by user
- Created branch `127-zotero-s-database-is-now-wal-the-guarded` off origin/main
- Scaffolded PWF baseline from issue #127 with approved phases
- Next: start Phase 1
- Phase 1 (b213967): fixture + live measurement; main-only copies read 5 of 8, the pair 8 with no -shm; live checkpointed at 23:10:26 UTC, no difference today
- Phase 2: 0280 snapshot() copies the -wal; check passes 3/3 fixtures; restoring the bug (no -wal copy) fails wal_pending 5 of 8
