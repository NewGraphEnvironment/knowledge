# Progress — Zotero's database is now WAL: the guarded copies and the immutable reads miss uncheckpointed writes (#127)

## Session 2026-10-31

- Plan-mode exploration — phases approved by user
- Created branch `127-zotero-s-database-is-now-wal-the-guarded` off origin/main
- Scaffolded PWF baseline from issue #127 with approved phases
- Next: start Phase 1
- Phase 1 (b213967): fixture + live measurement; main-only copies read 5 of 8, the pair 8 with no -shm; live checkpointed at 23:10:26 UTC, no difference today
- Phase 2: 0280 snapshot() copies the -wal; check passes 3/3 fixtures; restoring the bug (no -wal copy) fails wal_pending 5 of 8
- Phase 3: 0270 db() the same in Python; check passes 3/3, restored bug fails wal_pending 5 of 8; the import leg sets a placeholder ZOTERO_API_KEY
- Filed cred#45 (immutable=1 misses WAL commits; reprex 1 vs 2 rows) ahead of Phase 4, so 0150's comment cites a real number
- Phase 4: 0150 carries 0280's snapshot(); collection_keys() reads it (live: temperature + flow -> 85 keys); the check also stops when the two copies differ (proved with a drifted copy)
- Phase 5: CLAUDE.md guarded-copy section rewritten (WAL since Zotero 10, the pair, cred#45) and the #127 line dropped; scripts/README.md 418; grep for -journal/immutable/rollback left only reader code and the unrelated GeoPackage rule
