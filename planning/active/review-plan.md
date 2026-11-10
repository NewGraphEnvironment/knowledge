# Plan review (Plan agent, 2026-11-10)

Background review of the baseline `task_plan.md`, spawned after the baseline commit; Phase 1 had landed when it
reported. Findings as returned, with what was done with each.

| # | class | finding | disposition |
|---|---|---|---|
| 1 | Blocker | `crd_store_update()` drops every document outside the keys it is given; `KEYS=` or "the three items" would wipe the store | `0150 ACTION=update` resolves the store's whole `COLLECTIONS` as a build does (2bf7c33c); plan names each store's build list |
| 2 | Blocker | harvest stores (`fraser`, `peace`, `pine`) are keyed `EXTENT__reportId.pdf`; an update would drop them all; `log.json` lists no items | `0150` refuses a store holding a harvest-named document; stores to update are found from `documents.origin` (`storage/<attachment key>/`) |
| 3 | Gap | `0275` re-runs not idempotent: `qpdf` writes a fresh `/ID`; a crash between upload and trash duplicates | done = every part trashed and one live merged PDF; `qpdf --deterministic-id` |
| 4 | Gap | no download helper; `api()` follows the S3 redirect | `0275` gets `download()` checked against the attachment md5; every merge part has a server md5 (live read 2026-11-10) |
| 5 | Gap | split items need collections; `hall_stednick2008AlseaWatershed` loses all its PDFs; cite search should cover hall, abbott, Skeena, mccarthy | split items take the parent's collections; org-wide citation search covers every item that loses or changes a PDF; hall's verdict recorded with the 2008 chapter wanted |
| 6 | Gap | merge-items must merge `relations` and `collections`, URIs not keys | PATCH carries the union, `dc:replaces` as `http://zotero.org/groups/4733734/items/<key>` |
| 7 | Gap | update needs the local store and the embedder (Ollama) | `0150` refuses a missing store (2bf7c33c); README says the embedder must answer |
| 8 | Gap | #20 rows: which key each cites; how the document reaches `X29BX4U8`/`W4425VK5` | rows cite `iacarella` 2025 and, for the monthly-sensitivity basis, the EFN framework; the document reaches `habitat_modelling` through `Fisheries/temperature` (a `temperature_members.csv` row), not hydrology/salmon |
| 9 | Gap | `api_key()`: `UnicodeDecodeError`, BOM; stale comment in `zotero_copy_check.R:178` | fixed and probed |
| 10 | Ordering | writes need Zotero running and synced, cred reads need it quit; `habitat_modelling` updated twice | phases reordered: all writes, then confirm sync/files/keys, then quit, one update per store, push |
| 11 | Ordering | cred must precede `0280` | done first (2bf7c33c) |
| 12 | Assumption | keeping the Tredger scan leaves the audit reading the textless scan | replace the scan with the OCR copy (the issue's second option) |
| 13 | Assumption | group storage quota: merged copies add bytes while trashed parts still count | noted; an upload refused for quota stops `0275` with the status |
| 14 | Assumption | #20 names Weller 2023 and Isaak 2016; library holds Weller 2024, Isaak 2015/2017 | checked against the document's reference list in Phase 4 |
| 15 | Assumption | retitling `KSCZP9JS` may change its key | BBT keeps keys (`resetKeyOnChange` off); check after the PATCH |
| 16 | Scope | `--parent top` is small; fix the "elsewhere" message and docstring; watch personal-PDF uploads in the dry run | in Phase 5 |
| 17 | Scope | PR is large; consider splitting #20's rows or `0275` | kept: Al decided at the gate to keep #20's rows; `0275` is #126 itself |
| 18 | Acceptance | Toffolon & Piccolroaz 2015 also has a PDF (three, not two) | statistics store checks three plus BDA3 |
| 19 | Acceptance | add store doc counts before/after, md5 after push, sturgeon dry run clean | `0150` update prints counts and drops; validation lists them |
