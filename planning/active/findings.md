# Findings — Zotero's database is now WAL: the guarded copies and the immutable reads miss uncheckpointed writes (#127)

## Issue context

## Problem

Zotero's `zotero.sqlite` is now in WAL mode. Its header's bytes 18-19 read `02 02`. The `.bak` Zotero wrote on 2026-10-28 read `01 01` (rollback journal), and the one it wrote on 2026-10-30 reads `02 02`. A Zotero update between those dates is the likely cause; that is not confirmed.

Three readers here assume a rollback journal:

- `0270`'s `db()` and `0280`'s `snapshot()` copy only the main file. Their "no transaction open" guard checks `zotero.sqlite-journal`, which a WAL database never writes. A write that has not yet been checkpointed sits in `zotero.sqlite-wal`, so the copy can miss it while every guard passes.
- `0150`'s `collection_keys()` (and cred) open the file with `immutable=1`. That read ignores the WAL entirely.
- CLAUDE.md ("Read `zotero.sqlite` from a guarded copy") describes exclusive locking with a rollback journal.

Measured 2026-10-31 (#122):
- The main file's mtime stayed fixed while Zotero synced new items into the WAL. That made a sync look stalled when it had finished.
- A copy of the main file alone failed to open (`unable to open database file`).
- A copy of the main file plus its `-wal` opened, read `journal_mode = wal`, and passed `quick_check`.

## Plan

- [ ] The guarded copy takes `zotero.sqlite` and `zotero.sqlite-wal` together. It accepts the pair only when both files' mtime and size are unchanged across the copy, and the copy passes `PRAGMA quick_check`. This applies to `0270` `db()` and `0280` `snapshot()`.
- [ ] `0150` reads from the same guarded copy instead of `immutable=1`.
- [ ] cred's `immutable=1` reads have the same blind spot. Raise it in cred with a reprex.
- [ ] Rewrite the CLAUDE.md section.

## Errors Encountered

| Error | Resolution |
|-------|------------|
