## Outcome

CH and BT habitat thresholds now have a recorded, checked literature basis. The work has four parts.

- **Zotero collection.** The group library has a curated `Fisheries/habitat_modelling` collection (`U9ZCZ6RN`,
  88 items), built by `scripts/0270`. It adds:
  - PDFs for group copies that lacked them, taken from linked files on the old Windows machine;
  - 7 works no library held;
  - parent items for 3 standalone PDFs.
- **Store.** A `habitat_modelling` ragnar store (202 documents) is built from that collection and the
  species/temperature/hydrology collections, and pushed to the bucket.
- **Evidence table.** `data/literature_evidence.csv` holds 190 cited values, read by `knw_literature_read()`.
  Every row carries a group-library key, a page and a verbatim quote, and `scripts/0280` checks each quote against
  its PDF.
- **Supporting changes:**
  - `0150` now resolves collections inside the group library;
  - both table readers refuse non-UTF-8 files;
  - one truncated timing-table key was corrected.

The substantive results are in `research/habitat_literature.md`:
- the CH spawning MAD and the 1.5 m rearing width have no source;
- the rearing 5 % attributed to Porter 2008 and Woll 2017 is in neither;
- the rearing bridge is a design rule;
- reach-scale BT spawning gradients exist in BC reports (1–4 %).

What was learned about the machinery:
- **Zotero:**
  - citation keys are not unique across libraries;
  - Zotero's exclusive lock makes both an `immutable` read and the header change counter unreliable while a sync
    is running;
  - a key-built store silently drops keys.
- **cred:** two defects, drafted as issues for the public cred repo in `cred-issue-draft.md`, not filed:
  - `crd_zot_src_lookup()` picks an attachment from any library;
  - `crd_search()` fails on every store under ragnar 0.3.0.
- **The gate:** a verification gate built on normalized strings passes fabrications. It took two review rounds
  and a rewrite to token-sequence matching.

## Measurement

- **Collection.**
  - 24 of 35 group copies of the personal habitat-modelling items had no PDF, and 25 PDFs were uploaded. No upload
    came from a differently titled item (all 25 checked).
  - 158 of the personal library's 177 linked files are old `D:\` paths, and 152 of those resolve once rebased
    onto `baseAttachmentPath`.
  - The collection ends at 88 items, 73 of them with a stored PDF.
- **Store.**
  - 205 keys produced 202 PDFs, 202 documents and 33,746 chunks (`nomic-embed-text`, about 40 minutes on m1).
  - 3 keys were dropped by `cred`'s lookup; all 202 ingested PDFs came from the group library.
  - Manifest md5 `039363d0…`, confirmed by a verified connect.
- **Evidence table.**
  - 190 rows: 108 CH and 82 BT, from 47 sources, all of them in the store.
  - By variable: gradient 78 (the bridge gradient among them), temperature 31, channel width 28, timing 20,
    stream order 13, discharge 8, substrate 6, bridge distance 2, lake and wetland area 4.
  - The gate verifies 140 text, 24 table and 12 OCR rows, plus 14 `none` rows. All 24 CH/BT × parameter cells
    are covered.
- **Gate review rounds** (the wrong turns, kept):
  - Round 1 built 8 fabricated rows and all 8 passed the first gate.
  - The first fix added boundaries, gaps and a bag-of-tokens table check. It carried its own defect: a lookbehind
    that rejected "interest.25%".
  - Round 2 built 13 more fabrications that passed. It named the mechanism: lossy claim against lossy page.
  - The token rewrite made all 25 fabrications and the 4 whole-table mutations fail, with the real table green.
    A table hop of 12 still let one fabrication through; a hop of 0 closed it.
  - The loop ended on an enumeration of every equating step (`findings.md`), not on a quiet round.
- **Other code-check rounds:**
  - Phase 1 (2 rounds): a UTF-8 truncation bug in both readers, and a line-number claim fixed inside its own fix.
  - Phase 2 (2 rounds): 5 latent `0270` issues, then a snapshot guard that was blind under exclusive locking.
    The fix was proved by a raced copy.
- **Subagent spend:** 10 in total: 1 plan review, 6 code-check rounds (2 per phase) and 3 evidence drafters.

## Evidence

- `scripts/logs/habitat/20260929_*`: collection builds, store build and push, and the gate's per-row log.
- The review files in this directory: `review-*.md`.

Closed by: PR (see branch `19-habitat-thresholds-literature-store-and`)
