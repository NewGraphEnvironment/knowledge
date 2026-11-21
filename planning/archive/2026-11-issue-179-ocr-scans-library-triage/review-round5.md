# Code-check round 5 (#179 branch, base 33f4ae2e, HEAD 5b688aa0)

## Checklist read

- `code-check-python.md`: read in full (the script is Python; `re.fullmatch` rule applies to `AUTO`, the 3.12 f-string
  rule checked by parsing the script under system Python 3.9.6: parses).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (evidence blocks and `|` rows skipped): a guard that
  fails toward pass; a fixture that cannot reach the failure mode; a proxy is not the property; verification that reads
  its own output; a guard's scope, escape hatches and remedies; a fix lands in one of two callers; restore the bug and
  prove the guard fires; a shared working tree; a wrapper's exit; zero-length/empty/unset; the probe is broken before
  the world is; written data outlives the fix; serialization loses meaning silently; one fact derived twice.
- `code-check-r.md` by heading: "Read-back shape must match write-back shape" (the script rewrites its own input
  CSV), "Copy a live SQLite database with its `-wal`" (the script reads through 0270's guarded copy). The only R change
  is a comment in `scripts/0150-store.R`.
- `code-check-shell.md`, `code-check-spatial.md`: no heading names a tool or shape this diff uses.

## Enumeration

Mutations were run in a detached worktree at HEAD (removed after), each on a copy of the tracked CSV, running the real
script against the live Zotero database through its guarded copy; baseline run and `--check` report the tracked file
current (168 rows, 0 undecided).

### Columns

| member | verdict | how checked |
|---|---|---|
| script row: group_id, item_key, item_type, pdfs, match_kind, library9_key, central_file | holds | all derived each run; edits to library9_key, central_file, match_kind each rewritten to base (mutations 04, 07c, 07d) |
| script row: decided_by | holds | written `script`; blank reads as script and is rewritten (02) |
| script row: verdict, reason | holds | rewritten from the match; an edit refused (05, 06, 06b, 06c trailing newline via `fullmatch`, 07b); blank pair accepted and rewritten (07) |
| hand row: derived columns | holds | rewritten each run (16: a hand merge's edited library9_key reset to the script's match, as the docstring says) |
| hand row: verdict, reason | holds | kept as written (15, 18 blank reason kept) |
| hand `present` library9_key | holds | kept; must be live (09, 10, 10b refused); central_file judged over match candidates plus the hand key (17) |

### Read-back cases of the prior file

| member | verdict | how checked |
|---|---|---|
| old file with no `decided_by` column | holds | every row reads as script; first hand row refused, rc 1 (01) |
| blank `decided_by` | holds | script row rewritten (02); hand merge refused as an edited script row (03) |
| script row with only library9_key edited | holds (documented: overwritten) | 04 |
| hand row whose match changes | holds | script row turned hand merge keeps merge with the script's key and kind (15); hand present keeps its own key while match_kind shows the script's (17) |
| row whose item left the library | holds (documented: drops out) | 14, a hand row dropped silently |
| rows for the central group | holds | dropped (20) |
| duplicate key in the prior file | finding 2 | 19 |

### Guards (each proven to fire)

| guard | verdict | mutation |
|---|---|---|
| edited script row | fires | 05, 06, 06b, 06c, 07b |
| hand without verdict | fires | 08 |
| hand present without key | fires | 09 |
| hand present dead key | fires | 10, 10b (trailing space) |
| bad decided_by | fires | 11 (`Hand`) |
| bad verdict | fires | 12 (`keep`), 12b (`Present`) |
| missing group | fires | 13 (group 999); a git conflict-marker line would also read as a missing group |
| central group absent | not mutated (needs another database); code read: `sys.exit` before any write |

### Numbers and conditions stated from the CSV

| claim | verdict |
|---|---|
| 168 items; per-group 46/20/24/59/19 and present/merge/discard split | holds (recounted) |
| 113 present = 110 by evidence + 3 by hand; 55 others = 51 merge + 4 discard | holds |
| evidence 43 pdf_md5, 27 doi, 40 title, 0 title_prefix, 58 none | holds |
| 77 present with a file: 50 same, 1 part, 14 other, 12 none; 27 not same | holds |
| "one is a Word file" | holds (XILGZYL7, the only non-PDF among the 14 `other`) |
| merges: 26 detection, 16 fish passage (14 + truncated-title + data-analysis report), 2 with no PDF | holds |
| discards: image file, two out-of-scope papers, PDF-less duplicate of 2796581 PIW5QNI3 (a merge row) | holds |
| three hand presents (typo title, project number, Bjornn and Reiser scan named YDHYE9V9) | holds |
| "none of the 168 rows rested on a prefix" | holds |
| personal library "about 280" | holds approximately (findings.md: 280 by prefix+DOI; 286 non-attachment items by full title+DOI today) |
| research/README row "51 to merge, 4 to let go" | holds |
| CLAUDE.md "keeps a hand row as written, and refuses a script row someone edited" | finding 1 |
| CLAUDE.md, scripts/README.md, 0150 comment: cred names a document by `storage/<attachment key>/<file>` | holds (`cred:::.crd_origin_id`, cred 0.8.0) |

### Public text, every branch commit (15, `git rev-list 33f4ae2e..HEAD`) and commit messages

| check | verdict |
|---|---|
| 79 private org repository names (gh, whole word) over every added line and message | holds: only "logic" as an English word |
| `public_sweep.py`'s patterns (db, key_path, password_manager, host, private_repo, project_repo, internal_ref, local_path, template_name) over every added line, logs and planning included | holds: one hit, "tailnet" in round 4's record listing what it checked |
| home paths | holds: rebuild logs show only tibble-truncated `/User…` |
| push/rebuild log manifests | holds: only `repo: NewGraphEnvironment/knowledge` and this branch |
| CSV / research / reasons carry no titles or group names | holds |

### Push logs and the verdicts CSV

| check | verdict |
|---|---|
| each push log's head_sha (all `c75c804a`) is an ancestor of HEAD | holds |
| push log md5 = local store md5, and = bucket `log.json` md5 and head_sha, for all five stores | holds |
| 12 new `zotero_attachment_verdicts.csv` rows: item in the group library, citation key matches, named attachment is the item's and trashed, the one live PDF's md5 equals the OCR file's | holds for all 12 |

## Findings

1. **CLAUDE.md overstates what the triage script refuses and keeps (low).** `CLAUDE.md` line ~137-141: "the script
   rewrites its own rows every run, keeps a `hand` row as written, and refuses a script row someone edited". The
   script refuses only an edit to a script row's `verdict` or `reason`; an edit to its `library9_key`, `central_file`
   or `match_kind` is overwritten silently (mutations 04, 07c, 07d, rc 0), and a hand `merge`/`discard` row's
   `library9_key` is reset to the script's match, not kept as written (16). The code and docstring are right and the
   overwrite is the accepted contract; the CLAUDE.md sentence is a claim wider than the guard, so a reader who points
   a script row at the right copy by editing its key trusts a refusal that does not come, and the edit is lost.
   Reword to what it does: refuses a script row whose verdict or reason was edited; a hand row keeps its verdict and
   reason, and a hand `present` its key. Rule: `code-check.md`, "A guard's scope, escape hatches, and remedies"
   (a restatement wider than the guard); `writing.md`, "Check that each guard covers the set its sentence names".

2. **A duplicated key in the prior CSV silently drops one row's decision (low).** `data-raw/zotero_library_triage.py`,
   `prior[(r["group_id"], r["item_key"])] = r`: the last duplicate wins with no message. Mutation 19 (a hand `merge`
   row followed by a script copy of the same key, as a resolved merge conflict keeping both lines would leave) exits 0
   and rewrites the row undecided, losing the hand verdict and reason. Conflict markers themselves are refused (they
   read as a missing group), so the trigger is a hand resolution that keeps both lines. One line refusing a key seen
   twice closes it. Rule: `code-check.md`, "A guard that fails toward pass" (a malformed input taking the
   nothing-to-do path).

Neither finding is in the mechanism round 4 fixed: no row's ownership is guessed from content any more, every guard
fires, and every stated number holds.
