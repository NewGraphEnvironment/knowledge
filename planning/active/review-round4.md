# Code check, round 4: #179 branch (base 33f4ae2e, HEAD 640c4434)

## Checklist read

- `code-check-python.md`: read in full (stdlib shadowing, pystac socket guard, conftest scope, mkdocs strict,
  mkstemp mode, f-string braces, LibreOffice UNO, `re.match` `$`, `urllib.parse`). None reached by the diff: the
  script is named `zotero_library_triage.py` (no stdlib clash), uses no regex validation of whole strings, no
  f-string braces broken over lines, no atomic rewrite.
- `code-check.md`: the prose of every H3 under `## Mechanisms` (evidence blocks and `|` rows skipped); the ones
  this diff reaches are "A proxy is not the property" (title_prefix), "A guard that fails toward pass" (the
  hand-row heuristic, the guards), "Written data outlives the fix" / "Serialization loses meaning silently" (the
  CSV's derived and human columns), "Restore the bug and prove the guard fires" (each guard mutated below), "One
  fact derived twice" (the counts in the research file).
- `code-check-r.md`, by heading: "Read-back shape must match write-back shape", "Copy a live SQLite database with
  its `-wal`" (the script reads through `0270`'s `db()`), "CSV whitespace". `0150-store.R` changes a comment only.
- `code-check-shell.md`, `code-check-spatial.md`: no heading names a tool, shape or pattern this diff uses.

## Enumeration

Mutations were run in a detached worktree of HEAD (`git worktree add --detach`), each from the tracked CSV, with
`TMPDIR` in the scratchpad; the tracked file was restored and `cmp`-checked after. The unmutated run and `--check`
both report the file current (168 items, 5 libraries, 58 unmatched, 0 undecided).

### Columns, automatic rows

| column | verdict | how checked |
|---|---|---|
| group_id, item_key, item_type, pdfs, match_kind | holds | recomputed from the database every run on every row, hand rows included |
| library9_key | holds | from `match()`: a live top-level central key, preferring one holding a file |
| central_file | holds | `same`/`part` over every central stored hash; `other`/`none` over the candidates; on automatic rows `other` iff library9_key's item holds a file (it is preferred) |
| verdict, reason | **finding 1** | automatic iff verdict `present` and reason *starts with* `matched by `; a hand edit that keeps that prefix, or edits only library9_key, is overwritten |

### Columns, hand rows

| column | verdict | how checked |
|---|---|---|
| verdict, reason | holds (unless reason starts `matched by `, finding 1) | mutation K: hand `discard` on a pdf_md5-matched row kept |
| library9_key on hand `present` | holds | carried; dead key refused (mutation F) |
| library9_key on hand `present` with it blank, row matched | **finding 3** | mutation C: the script fills its match, and the next run reads that as hand-chosen |
| library9_key on hand merge/discard | holds | recomputed each run |
| central_file on hand `present` | holds in effect | judged over the match's candidates plus library9_key; the module docstring (line 31) says library9_key's item alone, so where a wrong match is overridden `other` can name a file library9_key's item lacks. No current row: all three hand `present` rows are `match_kind none`, so the candidates are library9_key alone. `other` and `none` lead to the same action. |

### Read-backs of the prior file

| case | result | verdict |
|---|---|---|
| hand row with verdict cleared (merge row) | becomes undecided, reason dropped | holds (un-deciding) |
| hand `present`, key blank, unmatched | exit 1 "a `present` verdict names no library9_key" | holds, guard fires |
| hand `present`, key blank, matched | script's key written; next run carries it as hand | finding 3 |
| automatic pair, reason edited keeping prefix (`matched by title; read, same work`) | reason rewritten to `matched by title`, exit 0 | finding 1 |
| automatic pair, library9_key edited to another live key (C6T4RPBK -> 5TBDTFIZ) | reverted to C6T4RPBK, exit 0 | finding 1 |
| hand `present` whose reason begins `matched by ` (`matched by hand: ...`), unmatched | verdict and reason erased, row undecided, exit 0 | finding 1 |
| hand `merge` row edited to `present` + `matched by doi`, unmatched | undecided | finding 1 (same) |
| central_file edited by hand | recomputed | holds (derived only) |
| reason `matched by doi ` (trailing space) on automatic rows | treated automatic, rewritten | holds |

### Guards (each made to fire)

| guard | mutation | result |
|---|---|---|
| dead key on hand `present` | key `ZZZZZZZZ` | exit 1, names the row |
| missing group | row with group_id 9999999 | exit 1, names the group |
| present without key | blank key on unmatched hand `present` | exit 1 |
| invalid verdict | `Merge` | exit 1 |
| `--check` | trailing space on 27 reasons | exit 1, file unchanged |
| central group absent | not run (needs another database) | code read: exits before reading anything |

All exits happen before the write, so no partial file. Trashed-parent central attachments (97 live attachments under
trashed parents, 95 with a hash) were checked: `items()` keys files by parent and keeps only live top-level rows, so
those hashes never reach `idx["files"]` or `pdf_md5`. Holds.

### Numbers in research/zotero_libraries.md and CLAUDE.md, recomputed from the CSV and the database

168 items; per-group items/present/merge/discard table; 113 present = 110 by evidence + 3 by hand; 55 = 51 merge + 4
discard; pdf_md5 43, doi 27, title 40, title_prefix 0, none 58; 77 present holding a file, 50 same, 1 part, 14 other,
12 none, 27 not same; merge themes 26 + 16 + 1 + 8 = 51; two merges with no PDF; one truncated title; four discards
as described; one `other` item is a Word file (one satellite `.docx` against a central `.docx`). All hold. Not
re-derivable here: #13's first count of 65 and the personal library's "about 280" and "11" (historical), and the 404
on zotero.org.

### Public text, every commit `33f4ae2e..HEAD` (12 commits), added lines and messages

- Home paths, tailnet, credential names, ports: none.
- The 79 private repository names of the org: none (one hit, "logic", is the English word in round 3's review
  record).
- The satellite group names (read from the database, matched word by word): only the generic words
  `fish_passage`/`habitat_modelling` and one generic six-letter word in pre-existing backlog prose.
- The push logs' manifest lists `vca_refs`, which main's push logs have carried since 2026-10-31: not this
  branch's.
- The rewritten push logs hold only their own store's entry; four record head_sha `c2d07c26` and `push_flow_2`
  `70978531`, all ancestors of HEAD (`push_flow.log`'s `a9366adb` is not, and `push_flow_2` supersedes it, as its
  header says).
- A machine's host name: **finding 2**.

## Findings

- **[severity: fragile]** `data-raw/zotero_library_triage.py:205-206` — the hand/automatic split still guesses
  from content: a row is automatic whenever its verdict is `present` and its reason *starts with* `matched by `, and
  an automatic row's verdict, reason and library9_key are then rewritten. Three plausible hand edits are silently
  lost, each exit 0 with "wrote": (a) a hand `present` (or a merge row changed to `present`) whose reason the owner
  writes as "matched by hand: ..." is erased to undecided when the row is unmatched (mutation I, H2); (b) a note
  appended to an automatic reason ("matched by title; read, same work") is rewritten to `matched by title`
  (mutation D); (c) a corrected library9_key on an automatic row, verdict and reason left alone, the natural way to
  point a title match at the right central copy, is reverted to the script's pick (mutation E: 5TBDTFIZ back to
  C6T4RPBK). The docstring's override route (change the verdict, or write any other reason) is the only one that
  survives, and nothing refuses the others. A remedy that keeps the accepted design: treat a row as automatic only
  when its reason `re.fullmatch`es `matched by (pdf_md5|doi|title|title_prefix)` and its library9_key equals the
  key the prior row's own match would give, and refuse (exit) a `present` row whose reason starts `matched by ` but
  fails either test, naming the row, so the owner rewrites the reason as a hand one.
  - **Rule:** `code-check.md`, "A proxy is not the property" (a reason prefix stands in for "a person did not
    decide this"); `code-check-r.md`, "Read-back shape must match write-back shape".

- **[severity: security]** commits `37a7463c` and `84eb2294` (`planning/active/task_plan.md` lines added at
  diff lines 102 and 146; `planning/active/review-179.md` and `task_plan.md` in `84eb2294`, "an a host read", "a host read
  owed after merge", "A read of one rebuilt store on a host"), and `670eef26`'s removal of them — a machine's host
  name stays in the branch's history after round 1 removed it from the tree. The branch is not pushed yet (no
  `origin/179-…`, no PR), so nothing is public; once pushed and merged with history preserved, these lines are.
  The repo's `CLAUDE.md` allows hosts in `planning/`, but the owner's global instruction says host names never go
  into a public repo, `planning/` included, and the brief says they were scrubbed. Rewriting `37a7463c` and
  `84eb2294` changes every later sha, so the four stores pushed at `c2d07c26` and flow pushed at `70978531` would
  each carry a manifest head_sha no commit on the branch holds (as flow's first push did): rewrite and re-push all
  five, or keep the lines under the repo's rule; decide before the first push.
  - **Rule:** `feature-workflow.md`, "Public-repo text describes the package, and points nowhere private" (host
    names); none in the code-check files.

- **[severity: fragile]** `data-raw/zotero_library_triage.py:211-216` — a hand `present` whose library9_key is
  left blank on a matched row is given the script's current match (mutation C), and on the next run that key is
  read back as a hand choice (`verdict == "present" and old.get("library9_key")`), so it no longer follows the
  match: a derived value written into the human column and re-read as human. The dead-key guard still fires if the
  copy is trashed, so the damage is a stale pick, not a silent loss. Either refuse a hand `present` with no key
  (as the unmatched case already does) or leave the key blank in the written row.
  - **Rule:** `code-check.md`, "Written data outlives the fix" (what a persisted entry claims).

- **[severity: fragile]** `data-raw/zotero_library_triage.py:73-74, 141-146` — `title_prefix` marks an item
  `present` automatically on the normalised text before the first colon, cut to 60 characters, with no floor on
  its length. In the central library itself 72 prefixes already join items whose full titles differ, and 65 are 10
  characters or fewer (`1`, `r`, `a1`, `http`, `pdf`, `topic`, ...). A satellite item titled "R: ..." or
  "Appendix 1: ..." would be recorded `present` with no review, and `present` is what retirement deletes without a
  merge. No current row rests on it (0 title_prefix matches), so this bites on a future run, most likely the
  personal library's triage, which reuses the method. A length floor (or reporting prefix matches undecided, for a
  hand verdict) closes it.
  - **Rule:** `code-check.md`, "A proxy is not the property".
