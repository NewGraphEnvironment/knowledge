# Code-check round 2: branch 172 (b470bfd5...HEAD, planning/ excluded)

## Checklist read

- code-check-python.md: read in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`. Table rows were skipped.
- code-check-r.md, code-check-shell.md, code-check-spatial.md: judged from their `.index` files. The R lines are DBI/duckdb read-only calls inside a function, with `on.exit` inside that function. No shell or spatial code changed.

## Method

- Read the full diff, and the full text of 0275 and of the changed regions of 0150, 0153 and 0270. For 0270 that included `has_pdf`, `_first_last`, `group_copy`, `ensure`, `addition_pdf` and `find_collection`.
- Read the installed cred 0.7.0's `crd_store_update()` and `.crd_origin_id()`.
- Took a copy of `zotero.sqlite` plus its `-wal` into the scratchpad (`quick_check` ok). In it:
  - Every merge, replace and keep row's end state holds. In each merge, the merged file has a name that no part shares.
  - KE758PAG's creator is already one field (fieldMode 1).
  - LP4R4VYR is a live top-level `statistics` collection.
- All three Python scripts parse under 3.9, 3.10, 3.11 and 3.14.
- Checked the additions CSVs. No row sets publisher, edition or ISBN on an item type that lacks the field. Every organization creator either has no comma or is braced.
- Checked the new rows of `literature_evidence.csv`. Their data-row numbers (1146 to 1151) and the cross-references in their notes match file line minus one. All rows have 20 columns.
- Mocked 0275's `do_keep`. Only the module's `get`, `patch` and `z.api` were replaced, and `z.api` raises on any call; nothing touched the network.

## Round 1's fixes

- **`stored()`** refuses a fileless attachment with the target name before every branch of `do_merge` and `do_replace`, dry runs included. The remedy it prints ("trash it and re-run") leads to a fresh merge or upload. Holds.
- **Braced organizations.** These now reach Zotero as one field in both 0270 and 0275. `_first_last` reads `lastName` or `name`, so `group_copy` still matches items created before the change. The KE758PAG patch row compares equal to what the API returns, so it reads `done`. Holds.
- **0150 update guard.** The regex `/storage/[A-Z0-9]{8}/[^/]+$` is the same test as cred's `.crd_origin_id()` (the grandparent directory is `storage`, the parent an 8-character key) for any absolute or `~` origin. A missing key or an empty build list stops inside cred ("would leave the store with no documents") and does not empty the store. Holds.
- **Merged PDF check.** `qpdf --check` runs with `check=True`, which also raises on exit 3 (warnings), and the page count must equal the sum of the parts. Both run before the upload, and both fail toward abort. Holds.

## Findings

- **[fragile]** scripts/0275-zotero-attachments-tidy.py:179-189 (`do_keep`). The copy to keep is checked only for being live (`live(atts[0])`), not for holding a file. A keep row whose first attachment has no file on the server therefore trashes the only stored copy, and the item is left with no PDF. A later `0150 ACTION=update` would then drop it from the store.
  - **Reproduced** with a mock. Kept attachment A has no `md5`, and B holds the file. `do_keep` returns "kept A, trashed B", and B gets `deleted: 1`.
  - **This is round 1's defect in the sibling action.** The fix put the file check in `merge` and `replace` (`stored()`), but `keep` is the action whose rows exist precisely because "the other copy has no file on the server". A row with its keys swapped is the likeliest input error, and nothing refuses it.
  - **Today's rows are safe.** The database copy shows every kept attachment (VE7JF7CF, T7SVJCFC, GSID2JNR, DCU5FHHU, QUQIJKSN, 7X5PF692, G5544GD3, Q7BVI3PX, TQXKRA5H, 48CICX6G) with a `storageHash`. All rows already read `done`.
  - **Fix.** Refuse when `get(atts[0])` has no `md5`, the same test as `stored()`.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness" ; code-check.md "A proxy is not the property"

No other issues found.
