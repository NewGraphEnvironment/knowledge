# Code-check round 3: branch 172 (origin/main...HEAD, planning/ and scripts/logs/ excluded)

## Checklist read

- code-check-python.md: read in full (no rule matches this diff's Python: no stdlib-named script, no mkstemp/replace, no f-string line breaks; the scripts parsed under 3.9+ in round 2).
- code-check.md: the prose of the 14 H3s under `## Mechanisms` (table rows skipped), with "A proxy is not the property", "A guard that fails toward pass", "A fix lands in one of two callers that share a harness" and "One fact derived twice" read closely.
- code-check-r.md, code-check-shell.md, code-check-spatial.md: judged from their `.index` files. The R lines are DBI/duckdb read-only calls with `on.exit` inside a function, and `grepl` over origins (an NA origin reads as non-matching, so it refuses: fails toward refuse). No shell or spatial code changed.

## Method

- Read the full diff, and the full text of 0275. Also read the changed regions of 0150, 0153 and 0270, plus `has_pdf`, `group_copy`, `_first_last`, `ensure`, `addition_pdf`, `find_collection` and 0153's `upload`/`existing_report_ids`.
- Took a copy of `zotero.sqlite` plus its `-wal` into the scratchpad (`quick_check` ok) and read the stored filenames of the replace, merge and merge-items attachments.
- Mocked 0275's `do_replace`, `do_merge` and `do_keep` in a detached worktree. `get`, `children`, `trash` and `upload` were replaced with an in-memory dict, and `z.api` raised on any call. Nothing touched the network, the live library, the bucket or `data/rag/`.

## The mechanism

Every action that trashes something decides "a stored copy survives" by looking at a **survivor named by a different handle from the set it trashes**. Merge and replace name the survivor by **filename**. Keep names it by **list position**. Merge-items names it by "**some** stored PDF on the item". In each case the trash set is named by **attachment key**.

Rounds 1 and 2 hardened the survivor's own attributes:

- does it hold a file (`md5`);
- is it live;
- is the merged PDF sound.

Nothing checks the relation between the survivor and the trash set. Nothing shows that the survivor is **not one of the keys about to be trashed**, nor that it is **a child of `item`**. The filename and key lists "happen to agree" in today's rows only because every merged or replacement file has a name no existing attachment carries, and every keep row lists distinct keys of its own item.

The invariant that would close the class is a check at trash time. After the planned set is trashed, `item` must still hold a live attachment with `md5`, whose key is not in that set. For merge and replace, that attachment's `md5` must also be the bytes just merged or uploaded.

### Reach

| site | closed? |
|---|---|
| 0275 merge | **Open.** A part that already carries the name `file` counts as the merged file (finding 1). |
| 0275 replace | **Open.** An original that already carries the replacement's basename counts as the replacement (finding 1). |
| 0275 keep | **Open for input errors.** The kept key repeated among the rest, or a kept key that belongs to another item, trashes the item's only copy (finding 2). The `md5` check from round 2 holds for what it tests. |
| 0275 merge-items | **Closed.** The survivor test is on `item`'s own children, and `atts[0]` is a different item or standalone attachment. The "stored PDF" test reads `contentType`, which a mislabelled zip passes. No row is such a zip: XYITAWFC/U2HCSH69 is relabelled, not merged. |
| 0275 split, relabel, patch | Trash nothing; the author's enumeration holds. A split deliberately leaves an item without the moved PDF (ZFDF4HXC, by design). |
| 0270 creators | **Closed.** Braces mark a one-field name, and a bare name with no comma is one field. `_first_last` reads `lastName` or `name`, so `group_copy` still matches. |
| 0270 PDF naming | **Closed.** `ensure()` already appends `.pdf`, so `addition_pdf`'s suffix is redundant, not wrong. `has_pdf` tests `md5`. |
| 0150 update guard | **Closed** for what it guards. Origin under `/storage/<8>/` is cred's own resolve test. Documents dropped for not resolving in the group, or in the key list, are listed after the update, before any push. |
| 0153 `api_key()` | **Closed.** A blank or missing key exits. A wrong key fails loudly at the first API call (0275 raises per row, 0270 checks each status). Nothing reads as success. |
| 0153 `existing_report_ids` (not in this diff) | Same mechanism, **open, pre-existing**. `numChildren > 0` counts a fileless attachment left by a stopped upload as "filed", so that report is never re-filed. Out of this diff's scope; noted only for the reach. |

## Findings

- **[bug]** scripts/0275-zotero-attachments-tidy.py:244-257 (`do_replace`) and :146-175 (`do_merge`). `stored()` takes any live child named `file` as the uploaded replacement or merged file, including the attachment(s) the row is about to trash.
  - **Replace.** The natural verdict is "re-upload the OCR'd scan under the original's name". There, `stored()` returns the original itself: it has an `md5`, so round 1's check passes. The upload is skipped and the original is trashed. The item is left with **no live attachment**, and the script prints `replaced X with <name>` and lists nothing under "attachments added".
  - **Merge.** A merged `file` named like one of the parts takes the "merged file present" branch. The script trashes every part, and no merge is ever made. It prints `merged N parts into <file>`.
  - **Mock results.**
    - replace dry run: `would trash X`;
    - replace live run: `replaced X with orig.pdf`, live children of I: `[]`;
    - merge dry run: `would trash 2 parts (merged file present)`;
    - merge live run: `merged 2 parts into orig.pdf`, live children of I: `[]`.

    A re-run then uploads or merges afresh, from the trashed copies. So the state is recoverable until the trash is emptied. In between, an `0150 ACTION=update` (which the script's OUTPUT line points to) would drop the document from the store.
  - **Today's rows are safe.** XETIXEM2 is stored as `tredger_et_al_1984_nechako_river_reconnaissance.pdf` and the replacement is `..._ocr.pdf`. No merge `file` matches a part's filename. Even the banner parts, both named `banner_1993-a_field_guide_to_sit.pdf`, would have raised "2 live attachments named …" and so been safe by accident.
  - **Fix.** Exclude the row's own keys from `named` (`c["key"] not in atts`). Better, for replace, require the named child's `md5` to equal `hashlib.md5` of the local file, and for merge, compare it with the merged bytes when they are at hand.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A fix lands in one of two callers that share a harness"

- **[fragile]** scripts/0275-zotero-attachments-tidy.py:178-192 (`do_keep`). The checks prove `atts[0]` is live and stored, but not that it survives the trash or belongs to `item`.
  - `gone` is built from `atts[1:]` without excluding `atts[0]`. A row `X;X` (or `X;Y;X`) trashes the kept copy. Mock: `kept X, trashed X`, live children `[]`.
  - Nothing checks that `atts[0]`'s `parentItem` is `row["item"]`. A key typo that names another item's stored attachment passes both checks and trashes all of `item`'s copies. Mock: `kept W, trashed X`, live children of I `[]`.
  - This is round 2's case (a keep row whose input is wrong trashes the only copy) by a route the `md5` check does not reach. Today's ten keep rows list distinct keys, and round 2 found each kept attachment stored under its own item.
  - **Fix.** Refuse when `atts[0] in atts[1:]` or `kept.get("parentItem") != row["item"]`. The same parent check belongs on merge parts and on the replace original, which are likewise trashed without checking they are `item`'s.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A guard that fails toward pass"

No other issues found.
