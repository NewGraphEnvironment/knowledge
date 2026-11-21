# Code-check round 3 (#13, branch 179-backlog-move-10-report-corpus-one-librar, base 33f4ae2e)

## Checklist read

- `code-check-python.md`: read in full.
- `code-check.md`: the prose of every H3 under `## Mechanisms`; the sections that bear on this diff are "A proxy is not the
  property", "Written data outlives the fix", "One fact derived twice" and "A guard that fails toward pass".
- `code-check-r.md`: "Copy a live SQLite database with its `-wal`", "Read-back shape must match write-back shape".
- `code-check-shell.md`, `code-check-spatial.md`: no heading names a tool or pattern this diff uses. The diff has no
  shell, spatial or R logic; `0150-store.R` changes only a comment.
- I ran the script in a detached worktree under the scratchpad, with `TMPDIR` set (`--check`: current; 168 items,
  27 `present` not `same`). I probed the guarded copy of `zotero.sqlite` read-only. I simulated one hand row, then
  removed the worktree.

## Mechanism

In every finding so far, one stored value stood for something it does not cover. Two forms recur.

1. **Columns that mix kinds of value.** The CSV has one set of columns for what the script works out from the
   evidence and what a person decided. The next run reads them back with a rule that guesses where each value came
   from. R1's stale `present` and R2's overwritten hand verdict were both this guess failing for `verdict`/`reason`.
2. **A stand-in.** One value is taken for the whole set it was picked from. R1 read `present` as "the central library
   holds the file". R2 counted `central_file = same` when any file was held, not every file. Round 2's fix gave
   `verdict` an origin rule, but `library9_key` still has none. `central_file`'s `other`/`none` still depends on a
   single stand-in for the central copy.

## Enumeration

Each value the script writes, each place a run reads what an earlier run wrote, and each number the docs state from
the CSV:

| place | verdict |
|---|---|
| `verdict`/`reason` on automatic rows (worked out again each run; a match that has gone comes back undecided) | holds |
| `verdict`/`reason` on hand rows (carried over, matched or not) | holds (accepted design) |
| `library9_key` on hand rows (py:197-201, read back from the earlier run) | **finding 1** |
| `library9_key` on automatic rows (`sorted(...)[0]` of the matched candidates, py:141) | holds as an id; feeds finding 2 |
| `match_kind` (worked out again on every row, hand rows included) | holds |
| `central_file` `same`/`part` (each file's hash against every live central file) | holds: bytes held anywhere in the central library are what retirement needs |
| `central_file` `other`/`none` (judged on the one `k9` only, py:154) | **finding 2** |
| `central_file` blank (stand-in: `storageHash IS NOT NULL` means a stored file) | holds: measured, every live linkMode 0/1 attachment in all six libraries has a `storageHash`; only linked URLs (mode 3) lack one |
| `pdfs` (distinct PDF hashes, not attachments: 6NXW4DAQ and JR4N7733 have two identical PDFs, `pdfs=1`) | holds: the docs use only zero versus nonzero (2 merges and 1 discard with no PDF, verified) |
| trashed items: 97 live central attachments under trashed parents, 1 in group 4573988 | holds: the per-parent dicts are read only through the live top-level rows |
| prior rows whose item has gone (drop out) | holds (stated) |
| prior rows whose whole group is missing from this database | **finding 3** |
| `--check` (compares the rendered output with the file) | holds |
| empty `ZOTERO_API_KEY` | holds |
| research: 168 / 113 / 110 + 3 / 55 = 51 + 4 / per-group table / evidence table 43, 27, 40, 0, 58 | holds (every cell recounted from the CSV) |
| research: 77 `present` with a file; 50 `same`, 1 `part`, 13 `other`, 13 `none`; 27 | holds as counted; the 13/13 split rests on finding 2 (one row moves) |
| research: the Word file is one of the `other` rows (XILGZYL7, docx against docx) | holds |
| research: merge themes 26 + 16, two merges with no PDF, one truncated title; discards: an image, two out of scope, a duplicate with no PDF (PIW5QNI3 is `merge`) | holds |
| CLAUDE.md retirement condition (`central_file` other than `same`) | holds: a blank row holds no file, so the condition has nothing to cover there |
| summary line py:224 (27) and undecided count | holds |
| `zotero_attachment_verdicts.csv`: 12 new rows, 7 columns each, each item key new | holds |
| `planning/backlog.md` names #14, #16 or #251 | holds: none |
| new `scripts/logs/rag/*` home paths, host names, credentials | holds (`~/Zotero/...` only); see finding 4 for a private repository name |

## Findings

- **[severity: fragile]** `data-raw/zotero_library_triage.py:195-201`. On a hand row, the script reads
  `library9_key` back as if a person set it. That value can be the script's own automatic match. When a hand row has
  no `library9_key` but matches now, line 141 fills in `k9`, and line 212 writes it out. The next run takes that key as
  hand-set. It never works it out again, and it stops the whole run (`sys.exit`, "decide the row again") once that
  central item is trashed.
  - Reproduced in a scratch worktree: I set MX2FFKM8 (DOI match) to `merge` with an empty `library9_key`. The run wrote
    `...,doi,3MDQERTJ,none,merge,hand decision`.
  - Two things will reach this path:
    - **The planned merges.** Each merged satellite row then matches its new central copy and keeps `merge`, so the
      key becomes "hand-set".
    - **Removing central duplicates.** 3MDQERTJ and XT8HKKYW share a DOI, and removing either one through `0275
      merge-items` trashes it.
  - Writing the automatic key out is not wrong in itself. It is R2's mechanism in another column. The origin rule
    covers `verdict`/`reason` only, so a value the script derived outlives its evidence and blocks every later run.
  - **Rule:** `code-check.md`, "Written data outlives the fix" (and "A proxy is not the property").

- **[severity: fragile]** `data-raw/zotero_library_triage.py:141,154`. `match()` keeps the first key in sorted order
  among all the central items holding the evidence. `central_file()` then decides `other` against `none` from that one
  key's files.
  - Where the central library holds duplicates, the category depends on the key alphabet. Measured: 2796581 MX2FFKM8
    matches by DOI two central items, 3MDQERTJ (no file) and XT8HKKYW (a file with other bytes). It reads `none`, and
    would read `other` under the other copy.
  - So research/zotero_libraries.md:55-56 ("13 have a central copy holding another file … and 13 a central copy
    holding none") could as well be 14/12.
  - The retirement step for a `none` row ("each file attached to its central copy") would attach the PDF to the empty
    duplicate, while a copy with a file exists.
  - The 27 total holds, because `other` and `none` are counted together. The split and the action for this row do not.
    No other multi-candidate match changes category (measured over all 11 such rows).
  - **Rule:** CLAUDE.md agent-operations §3, "A share is not robust to an unresolved definition until you measure the
    spread"; `code-check.md`, "A proxy is not the property".

- **[severity: fragile]** `data-raw/zotero_library_triage.py:171-186,239-241`. A group missing from the database
  silently erases its hand decisions.
  - Prior verdicts are read from the CSV, but rows are written only for the groups present in this machine's
    `groups` table. A database that lacks a satellite group drops all of that group's hand verdicts and reasons. This
    happens on a machine where the group is not synced (Zotero lets a library be left out of sync), or after the group
    is left. The run reports only "wrote data/zotero_library_triage.csv".
  - The stated rule is that "a row no longer in the libraries drops out". That rule is about an item that has gone, but
    the code cannot tell that apart from a library this database never held. The script already refuses when the
    central group is missing (py:180), and the same guard is needed for every `group_id` in the prior file.
  - **Rule:** `code-check.md`, "A guard that fails toward pass"; "Written data outlives the fix".

- **[severity: security]** `scripts/logs/rag/20261121_push_{flow,temperature,habitat_modelling,fish_passage,bull_trout_grayling}.log`.
  Each log dumps the bucket's manifest, which names the private repository
  a private repository of ours (`"repo":`, with its branch and head SHA, three times per
  file).
  - CLAUDE.md's "One discipline" forbids links to private repositories in anything tracked. Only logs written before
    2026-10-16 are exempt, and these are dated 2026-11-21.
  - No tracked file outside `planning/archive/` and pre-cutoff logs names this repository at base 33f4ae2e. The earlier
    rag push logs did not dump the manifest.
  - `public_sweep.py` skips `scripts/logs/`, so nothing would catch this. (The brief limited the log check to home
    paths, host names and credentials. This is reported because the repo's rule covers it.)
  - **Rule:** CLAUDE.md, "One discipline: everything here is public"; `feature-workflow.md`, "Public-repo text
    describes the package, and points nowhere private".
