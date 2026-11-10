# Progress — Backlog move 3 (#172)

## Session 2026-11-09

- Plan-mode exploration — phases approved by user (gate: #20's data question to wet#5; BDA3 only; #20's rows kept)
- Created branch `172-backlog-move-3-zotero-fix-what-the-group` off origin/main
- Scaffolded PWF baseline from issue #172 with approved phases
- Next: start Phase 1
- Phase 1 (#168): `0153`'s `api_key()` reads `ZOTERO_API_KEY`, else `ZOTERO_API_KEY_FILE`'s first non-blank line.
  Seven branches probed by import (var set; var blank + file; file only; empty file; blank-lines file; missing file;
  neither), 0270 reads the file key through `z.API`, and `data-raw/zotero_copy_check.R` PASS (its child still uses the
  placeholder variable).
- Phase 2: cred 0.1.0 → 0.7.0 (pak). `crd_store_update(store_path, collection | citation_keys, library)` drops any
  document whose source no longer resolves, so `0150 ACTION=update` resolves the same `COLLECTIONS` as a build and
  passes the union; it refuses without `crd_store_update()` in cred or without the local store. Guards probed
  (bad action, missing store, missing COLLECTIONS).
- Plan review (Plan agent) in `review-plan.md`: two blockers on `ACTION=update` (narrow key lists and harvest stores
  wipe documents). `0150` now refuses a store with any `<EXTENT>__<reportId>.pdf` origin (probed on a fake store) and
  prints counts and drops; `api_key()` reads a BOM file and refuses undecodable bytes (probed). Plan reordered: every
  library write in Phase 3–5, then one store pass with Zotero quit (Phase 6). Tredger's scan is replaced, not kept.
- Phase 3 prep: `0275` and `data/zotero_attachment_verdicts.csv` (31 rows: #151's four, #126's 27). Sitting verdicts
  settled by reading the files: banner part-1 copies have identical text (keep 9S2ERUGD); Thompson's 2017 copy
  T7SVJCFC is the fuller; the Alsea scan P9ZV6GDE is George W. Brown's "The Alsea Watershed Study" (OCR). Org-wide
  key search: neither banner key cited (GitHub index + 196 local checkouts); abbott and mccarthy are cited
  (safety_plan_template, fish_passage_skeena_2024_reporting) and keep their report PDFs. Tredger OCR: 49 pp,
  7,531 words. Dry run: 31 rows, all `would`, 0 failed; `download()` checked against WZ896C9Y's md5.
