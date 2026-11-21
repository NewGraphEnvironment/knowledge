# Code-check round 2: branch 179-backlog-move-10-report-corpus-one-librar (base 33f4ae2e, HEAD 6edb5877)

## Checklist read

- code-check-python.md: in full.
- code-check.md: every H3 under `## Mechanisms` in full (table rows skipped). Rules-that-stand-alone headings: none read (none names a tool or shape this diff uses beyond the mechanisms).
- code-check-r.md: read "Read-back shape must match write-back shape", "Copy a live SQLite database with its `-wal`", "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests"; the rest not read (the diff's R change is one comment).
- code-check-shell.md: no headings read (no shell in the diff).
- code-check-spatial.md: no headings read (nothing spatial in the diff).

## What was run

All in a detached worktree in the scratchpad (since removed; the repo tree stayed clean), TMPDIR in the scratchpad:
- `data-raw/zotero_library_triage.py --check`: "data/zotero_library_triage.csv is current" (168 items, 58 unmatched, 0 undecided); also with `ZOTERO_API_KEY="  "` (round-1 fix 3 holds).
- Round-1 fix 1, by mutation of the worktree CSV: a hand `present` whose library9_key is not a live central key exits ("is not a live item of the central library"); a hand `present` with library9_key blanked exits ("names no library9_key").
- A probe over the live database listing, per satellite item, every stored file (hash, content type) not held anywhere in the central library, beside its `central_file`.
- The 12 new `replace` rows in `data/zotero_attachment_verdicts.csv`: each `attachments` key is a child of its item and is trashed, and each item holds one live attachment named the row's file whose storageHash equals the local file's md5.
- Every number in `research/zotero_libraries.md` recounted from the CSV: 168/113/55/51/4, the per-group table, the evidence table (43/27/40/0/58), 110 + 3 by hand, 77 present items with a file split 51/13/13, merge themes 26 + 16 + 1 + 8 = 51, two PDF-less merges, four discards. All match except the Word-file sentence below.
- `planning/backlog.md`: `grep -nE '#(14|16|251)\b'` finds nothing.
- Added lines and the `scripts/logs/rag/20261121_*` logs: no home path, host name or credential.
- CLAUDE.md's claim about cred's document naming checked against installed cred 0.8.0 (`.crd_origin_id()` in `crd_store_build`, `.crd_zot_key_from_path()` in `crd_search`): holds.

## Findings

- **[severity: bug]** data-raw/zotero_library_triage.py:146 — `central_file()` returns `same` when **any** of the satellite item's stored files is in the central library, so an item holding several files reads `same` while one of them has no central copy. Live instance: group 2796596 item `9D8YUVWD` holds two PDFs (`afe30b79…`, `dc227110…`); only the first is in the central library, yet the row reads `central_file = same`. The retirement condition in CLAUDE.md ("every file a `present` item's central copy lacks (`central_file` `none`) is attached to it"), research step 1 and the script's summary line ("13 `present` items hold a file the central library lacks") all key on `none`, so retiring the library as written deletes `dc227110…`, the only copy, and nothing in the CSV says it was there. Fix: `same` only when every file is held (`all(...)`), with partial coverage reading `none` (or its own value), then recount the research and summary numbers (13 becomes 14).
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** data-raw/zotero_library_triage.py:185-191 — a hand decision on a row the script matched cannot be recorded: any edit to such a row (verdict, reason, even `match_kind` set to `none`) is overwritten with `present` / "matched by <kind>" on the next run, without an error. Reproduced: on `2517476,2F4NB3UZ` (matched by title) a hand `merge` with `match_kind=none` came back `title,C6T4RPBK,other,present,matched by title`. `research/zotero_libraries.md` says a title match joining two works "reopens that row" when a merge finds it out, and the 40 title matches were not read; that reopening is exactly the edit the script silently reverts, after which retirement deletes the satellite item (its PDF reads `other`, so it is not carried over). Either keep a hand verdict on a matched row (e.g. honour a non-`present` verdict with a reason other than "matched by …"), or exit when a matched row's prior verdict differs from `present`, so the reversal is never silent.
  - **Rule:** code-check.md "Written data outlives the fix"

- **[severity: bug]** research/zotero_libraries.md:56-57 — "Those 13 (one of them a Word file) are carried over before retirement." All 13 `present` / `central_file = none` items hold only PDFs (database probe: every file is `application/pdf`). The Word file is `XILGZYL7`, which is among the 13 `other` rows (its central copy holds a different .docx), so under the stated retirement condition it is **not** carried over. The sentence misplaces it in the group that is kept. Fix: drop the parenthesis, or move it to the `other` count.
  - **Rule:** none
