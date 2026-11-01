## Outcome

Zotero 10 keeps `zotero.sqlite` in WAL mode. The three readers here (`0270`'s `db()`, `0280`'s `snapshot()` and a copy
of it in `0150`, read by `collection_keys()`) used to copy only the main file, or open the live file `immutable=1`.
They now copy the main file with its `-wal` under a stability guard: both files' mtime and size, the header's mode
bytes and the rollback-journal flag, unchanged across the copy; each try clears the previous copy's `-wal`; the copy
must open and pass `quick_check`, and a failed connect is retried. `0150 ACTION=build` warns while cred still reads
the live file immutable (cred#45, filed here). `data-raw/zotero_copy_check.R` is the test: fixtures, deterministic
interference through a hooked file copy, a stress test against a writer, and live reads. The durable verdict is
`research/zotero_database.md`.

Learned:
- **A copy of the main file alone is silently stale.** It opens, passes `quick_check` and misses the `-wal`'s rows.
- **The gate's hypothesis was wrong.** It held that the "unable to open database file" #122 met came from `mode=ro`;
  measurement disproved it, and that error is still unexplained.
- **A plain read-only connection to the live file no longer blocks** under Zotero 10. The copy was kept anyway.
- **soul#590's advice to copy the `-shm` is unnecessary.** Its body was revised from the measurement.
- **The branch review went three rounds.** Rounds 2 and 3 each found a defect inside the previous round's fix, of one
  mechanism: the check scored a value without establishing its cause. The loop ended on an enumeration of every
  site where an outcome becomes a scored value (`findings.md`, "Branch review: how it ended").

## Measurement

Fixtures (`wal_pending`: 5 rows in the main file, 3 more in the `-wal`):

| read | rows |
|---|---|
| main file alone, read-write or `mode=ro` | 5 (and `quick_check` ok) |
| `immutable=1` | 5 |
| main file + `-wal`, no `-shm` | 8 |

What each part of the guard is for, shown by removing it:
- **The stability check.** Stress, 90 s against a writer committing in bursts with a checkpoint every 8 pages:
  guarded, 0 of 2,493 accepted copies were not a committed state; without the check, 6 of 2,862 (0.21 %), every one
  passing `quick_check`. Deterministic interference (a write to the main file or the `-wal` mid-copy): refused every
  time with the check, accepted 9 of 9 without it.
- **Clearing the earlier try's `-wal`.** Without it, a checkpoint between tries reads 8 rows where the database holds 10.

Live (6,781 items): every read agreed both times measured: once with the `-wal` at 0 bytes after Zotero checkpointed
at 23:10 UTC, and once with it at 20,632 B, a write that changed no item. So no live stale read was observed on the
branch.

`0280` ran end to end in 52 s, its logs byte-identical to 2026-10-30's. `0150`'s `collection_keys()` gave 85 keys for
`temperature` and `flow` through the copy. `devtools::test()`: 1,797 pass, 0 fail.

## Evidence

`data-raw/zotero_copy_check.R` reproduces every number above: `STRESS_SECS=90` for the stress, and a scratch copy with
a guard edited out for the removal runs. Those edits are listed in `findings.md`.

## Owed

- cred's fix, and `0150 ACTION=build` switching to it (the cred issue; the cred floor raised in 0150 when it ships).

Closed by: PR (this branch, 127-zotero-s-database-is-now-wal-the-guarded)
