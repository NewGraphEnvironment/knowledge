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
- Phase 6: cred#45 filed (earlier); #127 body: cause Zotero 10.0.7, plan ticked, measurements; soul#590 item 7: -shm not needed (measured), immutable bullet, knowledge#127 and cred#45 named
- Live: 0280 end to end in 52 s, both logs byte-identical to 2026-10-30's (deleted, nothing new); 0150 collection_keys(temperature, flow) -> 85 keys
- Plan review folded in (review-plan.md): build warning, docs, two fixtures, connect retried, comments (a plain ro read did not block), precondition asserts, stress test, live guards; fixtures 15/15, stress 630/630 committed, live guards 6781 = pair; stability check removed -> 1 of 984 accepted copies not committed
- 90 s stress: guarded 0 of 2,493 bad, unguarded 6 of 2,862
- code-check round 1 (review-round1.md): the stress cannot pin the stability guard. Fixed with deterministic interference cases (touch main, touch -wal, checkpoint between tries) through a hooked file copy; restoring each bug fails them (stability removed 9/9; clearing removed: the checkpoint case reads 8 of 10); per-guard stress liveness
