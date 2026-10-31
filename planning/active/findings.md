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

## Phase 1: what each read sees (2026-10-31, `data-raw/zotero_copy_check.R`)

Fixtures (RSQLite 3.53.3; rows expected: `wal_pending` 8, `wal_closed` 5, `rollback` 5):

| fixture | main_rw | main_ro | pair_rw | pair_ro | immutable |
|---|---|---|---|---|---|
| wal_pending (`02 02`, -wal holds 3 rows) | 5 | 5 | 8 | 8 | 5 |
| wal_closed (`02 02`, no -wal) | 5 | 5 | 5 | 5 | 5 |
| rollback (`01 01`) | 5 | 5 | 5 | 5 | 5 |

Every read opened and every `quick_check` returned `ok`.

- **A main-only copy is silently stale**, read-write or `mode=ro`: it opens, passes `quick_check` and reads 5 of 8.
  `immutable=1` likewise. `quick_check` cannot tell, so it is no acceptance test for a missed WAL.
- **The gate's hypothesis is disproved**: `mode=ro` on a main-only copy opens fine (in a writable directory). The
  "unable to open database file" #122 met is unexplained here; it is not what a main-only copy does.
- **No `-shm` needed**: the main file and `-wal` alone read all 8, read-write and `mode=ro`. So the guard copies two
  files, and soul#590's "copy all three" is more than needed (the copy's wal-index is rebuilt).
- **Live** (6,781 items, newest `clientDateModified` 2026-10-31 19:49:47): every read agrees. Zotero checkpointed
  at 23:10:26 UTC, after the gate read the `-wal` at 795 KB; it is now 0 bytes (Zotero truncates it), so today's
  WAL held nothing the main file lacked. The fixture is what the guards are tested on.
- `0270` imports `0153`, which exits at import without `ZOTERO_API_KEY`; the check's Python leg sets a dummy key for
  the import alone (no API call), so no sibling `.py` is needed.

## Errors Encountered

| Error | Resolution |
|-------|------------|
