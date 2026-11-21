# Closing enumeration — #179 code-check (2026-11-21)

Mechanism (rounds 3-5): the triage CSV kept derived values and human decisions in the same columns and a re-run guessed
which was which from content; one stored value stood in for a set; public text leaked through planning notes and a
dumped manifest. Round 4 replaced the guess with `decided_by`. Round 5 enumerated the set below by code reading and by
running the script on mutated CSVs in a worktree; its two findings are fixed in the commit that adds this file and
checked here by mutation.

| member | verdict | how checked |
|---|---|---|
| 10 columns on script rows | holds | round 5: edits to key, central_file, match_kind overwritten; edited verdict/reason refused |
| columns on hand rows | holds | round 5: verdict/reason kept; hand `present` key kept and must be live; hand merge key reset |
| read-back: no `decided_by` column, blank `decided_by`, changed match, item gone | holds | round 5 |
| read-back: duplicate key | fixed here | mutated CSV with a second MX2FFKM8 row: exits 1 "has two rows" |
| guards: edited script row, hand without verdict, hand present without key, dead key, bad decided_by, bad verdict, missing group | hold | round 5 triggered each; round 4's table here |
| guard: central group absent | holds by reading | exits before any read (needs another database to trigger) |
| every number in `research/zotero_libraries.md`, `research/README.md`, `CLAUDE.md` | holds | round 5 recounted from the CSV and the database |
| `CLAUDE.md`'s description of `decided_by` | fixed here | now says what the code refuses and keeps (verdict/reason; a hand `present`'s key) |
| public text in every branch commit and message | holds | round 5: 79 private repo names, `public_sweep.py` patterns, home paths, host names |
| push logs' `head_sha` | holds | all five `c75c804a`, an ancestor of HEAD; md5s match local stores and the bucket's `log.json` |
| 12 new `replace` rows | hold | round 5 against the database |

`--check` reports the tracked CSV current after the fixes (168 rows, 0 undecided).
