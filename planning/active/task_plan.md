# Task: Zotero's database is now WAL: the guarded copies and the immutable reads miss uncheckpointed writes (#127)

Zotero's `zotero.sqlite` is now in WAL mode. Its header's bytes 18-19 read `02 02`. The `.bak` Zotero wrote on 2026-10-28 read `01 01` (rollback journal), and the one it wrote on 2026-10-30 reads `02 02`. A Zotero update between those dates is the likely cause; that is not confirmed.

Three readers here assume a rollback journal:

- `0270`'s `db()` and `0280`'s `snapshot()` copy only the main file. Their "no transaction open" guard checks `zotero.sqlite-journal`, which a WAL database never writes. A write that has not yet been checkpointed sits in `zotero.sqlite-wal`, so the copy can miss it while every guard passes.
- `0150`'s `collection_keys()` (and cred) open the file with `immutable=1`. That read ignores the WAL entirely.
- CLAUDE.md ("Read `zotero.sqlite` from a guarded copy") describes exclusive locking with a rollback journal.

Measured 2026-10-31 (#122):
- The main file's mtime stayed fixed while Zotero synced new items into the WAL. That made a sync look stalled when it had finished.
- A copy of the main file alone failed to open (`unable to open database file`).
- A copy of the main file plus its `-wal` opened, read `journal_mode = wal`, and passed `quick_check`.

## Context (from the gate)

Zotero 10.0.7 runs `zotero.sqlite` in WAL mode (header bytes 18-19 `02 02`, measured on m1 and m4 in soul#590 item 7,
which settles the cause the issue left open). A commit sits in `zotero.sqlite-wal` until a checkpoint folds it into the
main file. Every reader here assumes a rollback journal:

- `scripts/0270-habitat-collection-build.py` `db()` (line 65) and `scripts/0280-literature-verify.R` `snapshot()`
  (line 118) copy only the main file and guard on `zotero.sqlite-journal`, which a WAL database never writes.
- `scripts/0150-store.R` `collection_keys()` (line 55) and cred (`R/zotero.R` lines 24, 439) open the live file with
  `immutable=1`, which ignores the WAL.

State on this machine, read at the gate (2026-10-31): the main file's mtime is Oct 30 17:57 PDT and the `-wal`'s is
Oct 31 16:02 PDT (795 KB, checkpoint sequence 20), so the WAL is live and newer than the main file. The `-shm` was
last written Oct 30 11:21 PDT.

A hypothesis to test, not a finding: the issue's "unable to open database file" for a copy of the main file alone came
from opening it `mode=ro`, which can't create the `-wal` it needs. `0270` opens its copy read-write, so on that path a
main-only copy should open, pass `quick_check`, and silently read stale data, which is the dangerous case. Phase 1
measures this before anything is fixed.

## Decided at the gate

- **Where the guard lives** (Al, 2026-10-31): in the scripts now. Fix `0270` and `0280` in place and give `0150` the
  same R function as `0280`, so there are three copies (one in Python, two in R). File a cred issue proposing that
  cred own a guarded copy; the scripts switch to it when it ships.
- **Both journal modes** (a conventional default, so stated rather than asked): the guard reads the header's mode
  bytes. In WAL mode it copies the `-wal` when one exists; in rollback mode it keeps today's journal check. The mode
  changed once without warning, so it can change again.
- **`-shm` is not copied**: SQLite rebuilds the wal-index when it opens a pair that no other process holds. soul#590
  suggests copying all three files, so Phase 1 measures that a pair without the `-shm` reads the WAL's frames.

## Phase 1: Reproduce and measure, before any fix

- [x] `data-raw/zotero_copy_check.R`. A fixture built in a tempdir with RSQLite: a WAL database with
  `wal_autocheckpoint = 0`, rows committed after the copy point, and the main file and `-wal` copied while the writer
  is still open. So the main file lacks the rows and the `-wal` holds them. Also a rollback-mode fixture, and a
  WAL-mode database with no `-wal` (as after Zotero quits).
- [x] On the fixture, measure a main-only copy opened read-write (opens? `quick_check`? row count) against a main-only
  copy opened `mode=ro`, and against the main file plus `-wal` with no `-shm`. This tests the hypothesis above and the
  `-shm` decision.
- [x] On the live database, the same three reads plus `immutable=1` on the live file: item count and
  `max(clientDateModified)` from each. Record whether today's WAL holds writes the main file lacks.
- [x] Record everything in `findings.md`. If the live comparison shows no difference, say so; the fixture is what the
  guards are tested on.

## Phase 2: `0280` `snapshot()`, WAL-aware

- [x] `snapshot(live = path.expand("~/Zotero/zotero.sqlite"), ...)`. The argument exists so the check can point it at
  the fixture.
- [x] `state()` holds the mtime and size of the main file and of the `-wal` (`NA` when absent), the mode bytes 18-19,
  and the rollback-journal flag.
- [x] Each try deletes the copy's `-wal` and `-shm` before copying. Otherwise, if Zotero quits between tries and its
  `-wal` disappears, a stale `-wal` from the previous try would sit beside a new main file. Then copy the main file,
  then the `-wal` if it exists. Accept the pair only when `state()` is identical before and after, no journal
  transaction is open, and `quick_check` returns `ok`.
- [x] Rewrite the comment above it: the WAL replaces the journal as the thing a copy can miss.
- [x] The check script passes `0280`'s `snapshot()` (taken from the script by `parse()`, never retyped) on all three
  fixtures.

## Phase 3: `0270` `db()`, the same in Python

- [x] The same state, deletion, copy order and acceptance as Phase 2; `live` is an argument defaulting to
  `os.path.join(ZDIR, "zotero.sqlite")`. Rewrite the docstring.
- [x] The check script runs `db()` on the three fixtures through `python3`, loading 0270 with `importlib`. If importing
  it has side effects (the API-key exit), that leg moves to a sibling `data-raw/zotero_copy_check.py`.

## Phase 4: `0150` `collection_keys()` reads a guarded copy

- [ ] Add `0280`'s `snapshot()` to `0150` and have `collection_keys()` read from it instead of `immutable=1`
  (`zotero_dir` builds `live`).
- [ ] Fix the header comment at line 19: cred still reads the live file immutable, so `ACTION=build` misses writes
  that have not been checkpointed until cred is fixed.
- [ ] The check script runs `0150`'s `snapshot()` on the fixtures, the same way as `0280`'s.

## Phase 5: Docs

- [ ] Rewrite CLAUDE.md, "Read `zotero.sqlite` from a guarded copy while Zotero runs": WAL since Zotero 10, what the
  guard holds, and that `0150 ACTION=build` through cred is blind to the WAL until the cred issue lands. Also rewrite
  the "Zotero's database is in WAL mode since about 2026-10-30 … (#127)" line under it.
- [ ] `scripts/README.md` line 418, the "checked copy" sentence.
- [ ] After the edits, grep tracked files outside the archive for `-journal`, `immutable` and `rollback`, and fix
  every hit that describes a reader.

## Phase 6: Issues

- [ ] File a cred issue: `immutable=1` reads miss a WAL database's uncheckpointed commits. A general reprex built from
  the fixture (cred is public, so no machine names), and the offer that cred own a guarded copy.
- [ ] Edit the #127 body: the cause is Zotero 10.0.7 (soul#590), the plan ticked as landed, and the cred issue linked.
- [ ] Edit the soul#590 body, item 7: what Phase 1 measured about the `-shm`, and that knowledge's readers are fixed
  (the soul side stays soul#590's).

## Owed at the end (reported, done after merge)

- [ ] cred's fix, and `0150 ACTION=build` switching to it (the cred issue; the cred floor raised in 0150 when it ships).

## Validation

- [ ] Tests pass (`devtools::test()`; the scripts have no testthat tests, so the check script is the test)
- [ ] `/code-check` clean, once over the branch with `/code-check branch`
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- **The check script is the test.** Each guard returns the fixture's full row count, and in WAL mode the guard's
  copy holds the `-wal`'s rows.
- **Restore the bug:** in a scratch copy of each script, drop the `-wal` copy line and show the check fails.
- **Live:** `0280` runs end to end against the running Zotero, and `0270 --dry-run` runs (reads only, no writes).
  Both report the item count Phase 1 read from the main file plus `-wal`.
- **Not covered:** a file changing in the middle of a copy can't be fixed in a fixture, so the stability guard is held
  by reading it, as today.
