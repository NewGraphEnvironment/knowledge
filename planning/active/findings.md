# Findings — Backlog move 10: Report corpus: one library, stable keys, and our own prose indexed (#179)

## Issue context

**If we do it:** one central Zotero library, store documents keyed on parent item and library, and our own research and archive READMEs searchable beside other people's reports. **If we never do:** 331 citation keys keep warning wherever no library is named, store documents join three incompatible ways, and our own findings stay greppable one repo at a time.

### Batch 16. Library, keys, own prose
- **Why here:** #14 depends on #13's single-library decision, and #16's one-store-or-two question is the same keying decision; one store rebuild serves all three.
- **Touches:** `data/zotero_key_map.csv`, `scripts/0150`–`0156`, `CLAUDE.md`'s store sentences, new store manifests.
- **Decided at the gate:** the single-library policy; one store or a separate one for our own prose; whether triage of the 290 personal-library items is in scope.

| issue | title |
|---|---|
| #13 | Triage what the dormant Zotero libraries hold that the central one does not, then retire them |
| #14 | Key the ragnar corpus on stable Zotero identity: parent item key, library, version |
| #16 | Index our own prose: report bodies, method notes, research/, PWF archive READMEs |

### Batch 22. OCR of the scanned PDFs (added 2026-11-18)
- **Why here:** #14 rebuilds every store when it changes their keys, so the ten OCRed scans ride that rebuild.
- **Touches:** `data/zotero_attachment_verdicts.csv`, `scripts/0275-zotero-attachments-tidy.py`, `scripts/0150-store.R`.

| issue | title |
|---|---|
| #217 | OCR ten scanned PDFs that every store skips as no text (Bjornn & Reiser 1991, Ford et al. 1995 among them) |

---

Backlog: `planning/backlog.md`, move 10. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.






## Exploration (2026-11-21)

- cred names a store document by its attachment path; `.crd_origin_id()` keeps `storage/<attachment key>/<file>`, and `crd_search()` resolves a citation key from the attachment key (`.crd_zot_key_from_path()`). #14's parent-item identity is therefore a cred change first.
- #13 re-measured (title prefix to the first colon, normalised, plus DOI, against library 9): lib 1 634 titled / 280 unmatched; lib 2 41/32; lib 5 20/1; lib 6 22/1; lib 7 49/16; lib 8 19/7. Satellite group names include a client-named one, so the tracked triage record carries group ids and keys, not names or titles.
- The ten scans of #217 sit in five stores by direct collection membership: habitat_modelling (all), temperature (YDHYE9V9, 87BDWWBH), flow (YDHYE9V9, BYBWUKUG, I44TTT4S, 6JK88BUF), fish_passage (YDHYE9V9), bull_trout_grayling (6JK88BUF). #217's body named three.
- cred 0.7.0 installed, 0.8.0 released (ragnar >= 0.4.0; ragnar 0.4.0 upgrades an older store on a read-write open).

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `ocrmypdf`: tesseract "image file not found: /tmp/ocrmypdf.io.*/000001_rasterize.png", every file failed | The sandbox keeps tesseract from reading ocrmypdf's temp files under `/tmp`; run with `TMPDIR` in the session scratchpad |
| Importing `0270` from a read-only script exits: 0153 reads a Web API key at load | `data-raw/zotero_library_triage.py` sets a placeholder `ZOTERO_API_KEY` before the load; it makes no Web API call |
