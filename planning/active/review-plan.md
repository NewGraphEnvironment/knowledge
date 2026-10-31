# Plan review (Plan agent, spawned 2026-10-31 23:27 UTC, delivered after Phases 1–6 landed)

The reviewer read the plan and the landed code. No blockers. Its findings, condensed, with what was done about each.
Every claim was probed before acting.

## SQLite answers it gave

- A pair of main file and `-wal` copied with no write between them is crash-consistent. The first connection rebuilds
  the wal-index from the `-wal`'s frames (sqlite.org/wal.html, walformat.html "Recovery"), and SQLite opens any `-wal`
  beside a database whatever the header says (`pagerOpenWalIfPresent()`). So copying any `-wal` that exists is right.
- Copy order matters only if the stability guard is bypassed. Copying main then `-wal` is the safer order: a mix fails
  only if a checkpoint and a WAL restart both fall between the two copies. Every such event moves an mtime or size.
- If exclusive mode is set before WAL, the wal-index lives in heap memory and the `-shm` is unused. The live `-shm`
  being written again at 16:10 suggested Zotero 10 is not in exclusive mode.

## Findings and dispositions

| ID | Finding | Done |
|---|---|---|
| G1 | `0150 ACTION=build`: `collection_keys()` reads a fresh copy while cred reads immutable, so the two views can differ | `0150` warns when the live `-wal` is not empty (cred#45 named). Not refused: a non-empty `-wal` may hold nothing pending. The symlinked-`storage` idea was declined, as the reviewer advised (`src_path` would name tempdir paths). |
| G2 | Doc lines the grep can't see: CLAUDE.md "Zotero access is local" (`0270 → 0150 build → 0280` in one sitting) and scripts/README's build line | Both now carry the cred#45 caveat. CLAUDE.md:136 states only that cred reads the local file, which is still true. Nothing below the soul marker was touched. |
| G3 | No fixture for a 0-byte `-wal` (today's live state) or for a writer in exclusive mode | Added `wal_empty` and `wal_exclusive`. All three guards pass both. |
| G4 | The connect call sits outside the retry | All three guards connect inside the `tryCatch`/`try` and retry on failure. |
| O1, S1 | Plan text drift: the guard was said to branch on the mode bytes, Phase 1's fixture wording, and cred#45 listed under Phase 6 | `task_plan.md` corrected (marked "corrected after the plan review"). |
| O2 | The live measurement came after Zotero checkpointed | Can't be recovered. `findings.md` already says so. |
| A1 | "A normal read-only connection blocks" was not re-measured under WAL | Measured: with Zotero running, a plain `mode=ro` read of the live file returned 6,781 items without blocking. The comments in all three scripts and CLAUDE.md now say so. The copy is kept as approved (it never touches the live files and works in either mode); the alternative goes to Al in the report. |
| A2 | The change counter is no guard in WAL mode either (fileformat.html) | Added to the three comments and CLAUDE.md. |
| A3 | mtime granularity and no mmap writes are unstated assumptions | Recorded here. The stress test (AC3) is the measured check of the guard on APFS. |
| S2 | `integrity_check`, or a Web API version comparison in 0270 | Not taken: the stress test shows the stability guard, not `quick_check`, is what rejects mixed pairs. A stricter check could also fail forever on a long-standing index problem in Zotero's own database. |
| S3 | The 0150/0280 drift check is good | Kept. |
| AC1 | `quick_check` cannot detect a missed WAL | Agreed and measured (Phase 1). The defence is structural, and fixture-tested. |
| AC2 | The fixtures' precondition is never asserted, so a fixture that stopped reproducing the bug would let every guard pass | The check now stops unless main-only and `immutable=1` reads give `N_MAIN` and pair reads give each fixture's rows. |
| AC3 | The stability guard and the stale-`-wal` clearing never run in the check | Added a stress test: a writer committing in bursts with checkpoints every 8 pages, each guard copying again and again. Run with the stability check removed, it accepted a copy that was not a committed state (1 of 984 in 30 s) and the check failed; with the check in place, 0 of 630. Longer runs are in findings.md. |
| AC4 | The live validation as written could not be met (neither script prints an item count, and the count moves) | Replaced: the check runs each guard on the live database beside a pair read taken at the same moment (6,781 = 6,781 for all three). A live run cannot tell fixed from broken while the `-wal` is 0 bytes; the fixtures and the stress test do. |
