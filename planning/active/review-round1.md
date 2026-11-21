# Code-check round 1 — branch 179-backlog-move-10-report-corpus-one-librar (base 33f4ae2e)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, with table rows and evidence blocks skipped. I read no other heading in full; the 28 headings outside Mechanisms I took from the index only.
- code-check-r.md: "Read-back shape must match write-back shape" and "Copy a live SQLite database with its `-wal`". The other ~150 headings I took from the index only, since the diff's R change is a comment.
- code-check-shell.md: no heading read. The diff adds no shell code. I took all of it from the index.
- code-check-spatial.md: no heading read. The diff has no spatial code. I took all of it from the index.

## Verified clean (no finding)

- research/zotero_libraries.md matches data/zotero_library_triage.csv as committed on every number: 168, 113 (111 + 2), 51/4, the table for each group, 44/27/40/0/57, 26 eDNA, 16 passage, 2 merges with no PDF, and the 4 discards.
- planning/backlog.md names none of #14, #16 or #251 (`grep -nE '#(14|16|251)\b'` gives rc 1).
- The 12 new `replace` rows are consistent with the local Zotero database. Each item's citation key matches. Each `attachments` key is a child of its item and is now trashed. Each item holds a live `<key>_ocr.pdf`. Each `file` exists, so 0275 reads them as done.
- The tracked diff carries no satellite group name and no item title. I grepped for every 4+-letter word of the five group names; the one that names a client appears 0 times. The run logs carry only `~/Zotero/...` paths, the public `s3://fresh-bc/rag/` prefix and truncated `/User…` columns.
- The CLAUDE.md, 0150 and README sentences on cred naming match cred 0.8.0: `.crd_origin_id()` keeps the `storage/<key>/<file>` tail, and `.crd_zot_key_from_path()` resolves the key.

## Findings

- **[severity: bug]** data-raw/zotero_library_triage.py:158-165 (and data/zotero_library_triage.csv, research/zotero_libraries.md:10-38) — An unmatched row inherits whatever verdict, reason and library9_key the prior file holds. That includes the script's own automatic `present` / "matched by <kind>" rows. So an item that loses its match keeps `present`, now with `match_kind=none` and a false reason, and it no longer counts as unmatched or undecided. A match is lost when its central copy is trashed, replaced or retitled, which is what 0275 and the merges do.
  - This already happened on this branch. The CSV was committed at 01:42, before 655f3d19's live `0275` replace runs trashed the original scans. Satellite 2796581/UKZVACL9 had matched YDHYE9V9 through the pdf_md5 of the old Bjornn & Reiser scan (KUGT5HMG, now trashed).
  - `env -u ZOTERO_API_KEY python3 data-raw/zotero_library_triage.py --check` now exits 1 ("out of date", 58 unmatched).
  - A regeneration into a scratch copy writes `2796581,UKZVACL9,attachment,1,none,YDHYE9V9,present,matched by pdf_md5`. That row is self-contradictory, and the carried key is accepted without checking that YDHYE9V9 still holds that work.
  - The tracked CSV and the research file's 44 / 57 are stale against the database the branch leaves.
  - Hand `present` rows have the same gap: nothing checks that their library9_key still names a live central item.
  - Fix: carry a prior verdict only when the prior row was unmatched (prior `match_kind == "none"`, or the reason does not start with "matched by"). Otherwise leave the row undecided. Check that a carried library9_key is a live central key. Re-run and update the research numbers.
  - **Rule:** code-check.md "Written data outlives the fix" ; code-check.md "A guard that fails toward pass"

- **[severity: bug]** data-raw/zotero_library_triage.py:159-160, CLAUDE.md:281, research/zotero_libraries.md:12 and :58-62 — A `present` verdict means only that the central library holds a record of the work. It does not mean the central library holds the satellite's PDF. Yet CLAUDE.md and the research file say the libraries are retired once every `merge` is done, and retiring a library deletes its files.
  - Measured on the current database: in 12 items marked `present`, the satellite holds a PDF whose bytes are nowhere in the central library, and no central key matching it (by DOI, title or the hand key) holds any PDF. The 12 are 2517476 BVRYYCHN, GKMY89IQ, H5D92CD7; 2796596 3PUAWZVK, 6NXW4DAQ, 9GNNGI8U, JR4N7733, NS9A74MU, PAZXB8D7, WPJ6LBJN; 4573988 DPXC2LCC (the hand `present`; central TA5U6Y6V has no PDF) and KYJLYNT8.
  - There is also one present-by-title item, 2796596 XILGZYL7, whose .docx is absent from the central library.
  - Retiring the groups as the docs now state would delete the organisation's only copy of those files.
  - Fix: the script should record that the central copy lacks the PDF, and the retirement condition should include carrying those PDFs over, not just the 51 merges. For example, use a verdict or column for "present, PDF to carry", or match only `pdf_md5` as fully held.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** data-raw/zotero_library_triage.py:45 — `os.environ.setdefault("ZOTERO_API_KEY", ...)` leaves a key that is set but empty unchanged. 0153's `api_key()` strips the value and treats empty as no key, so the script exits at load before reading anything. Reproduced: `ZOTERO_API_KEY= python3 data-raw/zotero_library_triage.py --check` exits with "ZOTERO_API_KEY is unset or empty and ZOTERO_API_KEY_FILE is unset…". The placeholder is meant to stand in "where no key is set", and an exported empty variable is no key.
  - Fix: `if not os.environ.get("ZOTERO_API_KEY", "").strip(): os.environ["ZOTERO_API_KEY"] = "<placeholder>"`.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things"

- **[severity: security]** planning/active/task_plan.md:31, :87, :89 and planning/active/review-179.md:19, :32 — These lines name a machine of ours by its host name in a public repo's tracked `planning/`. The user's global rule says host names in a public repo go to memory, "never to the repo's code, comments, commits, issues, PRs or planning/". `origin/main` carries no such host name in tracked text (`git grep -w` for it finds only a SQL alias). The repo CLAUDE.md lets `planning/` "name what was removed, hosts … included". These lines are not about something removed: they are operational notes on which machine still needs cred 0.8.0. Reword them as "the database's host" or "every machine that updates stores", or move them to memory before they are archived.
  - **Rule:** feature-workflow.md "Public-repo text describes the package, and points nowhere private" (none of the code-check files covers it)
