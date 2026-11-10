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
  files, and an internal issue's "copy all three" is more than needed (the copy's wal-index is rebuilt).
- **Live** (6,781 items, newest `clientDateModified` 2026-10-31 19:49:47): every read agrees. Zotero checkpointed
  at 23:10:26 UTC, after the gate read the `-wal` at 795 KB; it is now 0 bytes (Zotero truncates it), so today's
  WAL held nothing the main file lacked. The fixture is what the guards are tested on.
- `0270` imports `0153`, which exits at import without `ZOTERO_API_KEY`; the check's Python leg sets a dummy key for
  the import alone (no API call), so no sibling `.py` is needed.

## Stress and interference (2026-10-31)

Stress (`STRESS_SECS=90`, a writer committing 20 one-row transactions per burst with random gaps up to 0.2 s, and a
checkpoint every 8 pages; frozen copies in a scratch dir):

| run | copies accepted | not a committed state |
|---|---|---|
| guarded | 2,493 | 0 |
| stability check removed | 2,862 | 6 |

Every bad copy passed `quick_check`. At the unguarded rate (0.21 %) about 5 bad copies were expected in the guarded
run; seeing none by chance has odds of about 0.6 %. So the stability guard, not `quick_check`, is what rejects torn
pairs. But at that rate a 20 s stress run usually passes without the guard (code-check round 1 saw 204 of 204
accepted with it removed), so the stress measures rather than pins.

Interference (deterministic; each guard's file copies hooked):
- A write to the main file or to the `-wal` during a copy: every guard refuses the try. With the stability check
  removed, every guard accepts it (9 of 9 cases fail).
- A checkpoint between two tries (the main file replaced by a later 10-row state, the `-wal` deleted): every guard
  reads 10. With the clearing of the earlier try's `-wal` removed, every guard reads **8**. The stale `-wal`
  replays old pages over the newer main file, passes `quick_check`, and reads silently stale.

## Branch review: how it ended (2026-11-01)

Rounds 2 and 3 each found a defect inside the previous round's fix, so the loop ended on an enumeration, not on a
quiet round. The mechanism (round 3's naming): **the check scored a value without establishing its cause, and the
value had more than one cause.** In round 1 a stress PASS came from a working guard or from rare tears. In round 2,
NA came from the guard refusing or from any error on the hooked path. In round 3, a substring sentinel matched a
"hook never fired" message that quoted the child's REFUSED line.

The candidate set is every place the check or a guard turns an outcome into a scored value: `grep -nE
"tryCatch|try:|except|grepl|startsWith|is\.na|%in%|stop\(|sys\.exit|return con"` over the check, 0280, 0150's
`snapshot()` and 0270's `db()`. Each site now has one cause, or fails toward fail:
- **`read_way()`'s catch:** feeds the fixture precondition (opened, `quick_check` ok, rows as expected). The live
  table only prints.
- **`r_guard`:** a non-refusal error re-raises. A refusal counts only when its message starts "no consistent copy",
  and only once the hook has fired.
- **`py_guard`:** FIRED is checked first, and its message is not a refusal under the anchored match. REFUSED counts only
  when SystemExit's text starts with the sentinel. The result is an exact `ROWS n m` line, or the check stops.
- **`guard_rows()`:** the anchored match; anything else stops.
- **`gt$ok`, `it$ok`, `st$ok` and the final stops:** NA fails `gt` and `it` unless refusal is expected. In `st` a
  refusal is ok by design, and each guard must accept at least one copy. The stops run before PASS.
- **The guards:** `return(con)` / `return con` only after a stable state and `quick_check` = ok. An NA
  `quick_check` aborts (`if (NA)`).
- **Residual:** an NA-expected interference case cannot tell a refusal the interference caused from one an
  environmental failure caused at the same moment (a failed copy). The restore-the-bug runs show the stability
  check is what refuses under normal conditions.
- **Outside the set:** 0270's other `try`/`except` blocks predate the branch and are not in the diff.

Round 3 also found that each R guard call left its tempfile copy behind, about 249 MB in a 15 s stress. A full disk
would have turned copies into refusals that the stress scores ok. `r_guard` now deletes each copy once read.

The live `-wal` grew to 20,632 B at 00:05:29 UTC. Every read still gave 6,781 items with the same newest
`clientDateModified`, so that write held no item change the reads could see.

## cred

cred#45 filed 2026-10-31: `immutable=1` (`R/zotero.R:24`, `:439`) misses commits still in the `-wal`; reprex reads 1
row where 2 are committed. knowledge is private, so the issue names no knowledge issue; it offers a guarded copy for
cred to own. "Zotero checkpoints when it closes" is stated there as not yet measured.

## Errors Encountered

| Error | Resolution |
|-------|------------|
