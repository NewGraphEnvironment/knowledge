# Plan review: #19 (Plan agent, 2026-09-29)

The agent that wrote this review had no write access, so these findings were copied from its reply. The review
arrived after Phase 1 was committed and after the live `0270` run. The disposition column records what was done
with each finding.

| # | Finding | Disposition |
|---|---|---|
| B1 | `0270` could not resolve the `D:\...\storage\...` linked-file paths. 158 of library 1's 177 linked files use them; 12 members depend on it. | Fixed before the live run: the paths are rebased onto `baseAttachmentPath`. |
| B2 | A half-finished `upload()` leaves an attachment with no file. `has_pdf()` checked only contentType, so it read that as done. The tally also hid `pdf s3-403`. A network exception aborted the run with no per-member try/except. | The tally was already fixed before the run (non-OK results are upper-case `PDF-FAIL`). `has_pdf()` now requires a server md5. Each member is wrapped in try/except, and a server-side audit ran after the live run (findings.md). |
| G1 | `cred::crd_zot_src_lookup()` has four problems: it ignores which library an item is in, keeps the highest-itemID attachment per key, does not exclude trash, and dedups before checking the file exists. Wrong-paper keys (e.g. coleman_fausch2007) exist across libraries. | Upstream defect in cred, filed there. `0280` resolves each PDF inside the group library itself and excludes trash. |
| G2 | Re-parenting standalone PDFs changes collection membership (a child item cannot sit in a collection), and there was no dry-run. | Changed to non-destructive: a new parent item gets its own copy of the PDF uploaded; the standalone is left untouched. Zotero dedups the file by md5. |
| G3 | Porting link's review needs rules. Rows transcribed from tables have no prose quote; some quotes are a few characters; some sources are not in Zotero. | Added a `quote_source` column (text / table / ocr) and a minimum quote length. A row whose source is not in the group library is not ported; it is listed in findings.md. |
| G4 | A key can change when an item is copied into the group. | The gate requires every evidence key to exist in the group library. |
| G5 | `local_pdf()` walks every same-key item in every library, so it can upload one paper's PDF onto another item. | The 25 uploads were audited by title after the live run (findings.md). |
| Ord1 | Wait for sync before building, then check membership and on-disk files locally. | Added to Phase 3. |
| Ord2 | Gap-fill lands after the push. | A final rebuild and push was added to Phase 4. |
| Ord3 | Require a dry run before the live run. | Done in practice (dry run, then live). Recorded. |
| Ord4 | Write `0280` before porting rows. | Reordered. |
| A1 | An immutable read sees a mid-transaction state while Zotero runs. | Verification reads a copy of `zotero.sqlite`. |
| A2 | **link is PUBLIC.** The link#284 comment must not paste rows or quotes from unpublished or culturally sensitive sources. | The comment carries aggregate counts and a pointer only. |
| A3 | Image-only PDFs (neuman_newcombe1977, bjornn_reiser1991) have no text layer. | OCR (tesseract/ocrmypdf) is used for the gate only, and rows are marked `quote_source = ocr`. |
| (4) | Schema gaps: variable/unit and bound/value consistency; `scale`; `cited_source`; gradient in percent against link's proportion. | Cross-column checks added, plus `scale` and `cited_source` columns. The percent/proportion conversion is documented. |
| Scope | `0150` now resolves `fraser` to the group collection where it used to be refused. | README line. |
| Acc | Coverage should be asserted per species × parameter. `0280` should also check the timing sources. | Added to `0280`. |
