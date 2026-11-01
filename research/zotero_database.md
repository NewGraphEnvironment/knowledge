# Reading Zotero's local database while Zotero runs

**Verified:** 2026-10-31 · **Issues:** #127 (built here), #122 (where WAL mode was met), NewGraphEnvironment/cred#45
(cred's reads) · **Produced by:** `data-raw/zotero_copy_check.R` (fixtures, interference, stress, live reads), on
SQLite 3.53.3 through RSQLite and Python's `sqlite3`

## What is known

Zotero 10 keeps `~/Zotero/zotero.sqlite` in WAL mode: header bytes 18-19 read `02 02`, where earlier versions used a
rollback journal (`01 01`). A commit sits in `zotero.sqlite-wal` until a checkpoint copies it into the main file.
Zotero truncates the `-wal` to 0 bytes after a checkpoint, so a sync moves the `-wal`'s mtime while the main file's
stays put.

**A copy of the main file alone is silently stale.** On a fixture whose `-wal` held 3 of 8 rows, the main file alone
opened, read-write or `mode=ro`, passed `PRAGMA quick_check`, and read 5 rows. An `immutable=1` read of the live
file reads 5 too, which is cred's blind spot (cred#45). `quick_check` cannot tell, so it is no test for a missed WAL.

**The main file and its `-wal`, copied together, read every committed row.** No `-shm` is needed: SQLite rebuilds the
wal-index from the pair, read-write or `mode=ro`, and from a writer in exclusive locking mode too.

**A plain read-only connection to the live file did not block** with Zotero 10 running (2026-10-31). Under the
rollback journal it did, because Zotero held an exclusive lock. The readers here still copy, which keeps them off the
live files in either mode.

## What a guarded copy needs

The guard is in `0270`'s `db()`, `0280`'s `snapshot()`, and `0150`'s copy of it. Each piece below was measured by
removing it:

- **Copy the `-wal` with the main file.** Without it, the copy reads 5 rows of 8.
- **Check stability.** Compare both files' mtime and size before and after the copy, and refuse the try if they
  moved. Removing the check, against a writer committing in bursts with a checkpoint every 8 pages, let 6 of 2,862
  accepted copies through that were not a committed state, in 90 s. Every one passed `quick_check`. With the check in
  place it was 0 of 2,493. A write to either file during the copy is refused every time, in deterministic cases.
- **Clear the previous try's `-wal` before each copy.** Suppose Zotero checkpoints between two tries and deletes its
  `-wal`. A stale `-wal` from the first try, left beside the newer main file, replays old pages over it and reads 8
  rows where the database holds 10, still passing `quick_check`.
- **The header change counter is no guard:** SQLite did not bump it per commit in Zotero's exclusive mode, and need
  not in WAL mode.

## What a guarded copy cannot see

- A rewrite that leaves both files' mtime and size unchanged (within the clock's resolution).
- An environmental failure (a failed copy) coinciding with a refusal the check expects. The check's interference
  cases cannot tell the two apart.
