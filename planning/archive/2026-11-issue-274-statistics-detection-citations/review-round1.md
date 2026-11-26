# Code-check round 1, #274 branch (f0a6cbd0...HEAD)

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.md` (read by heading): "Copy a live SQLite database with its `-wal`", "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests". The other headings were not read (none names a tool, shape or pattern this diff uses: the diff adds no R code).
- `code-check-shell.md` (read by heading): "An S3 multipart ETag depends on the uploader's part size, so try every size that gives its part count". The other headings were not read.
- `code-check-spatial.md` (read by heading): no heading applies (no spatial code or data in the diff); none read.
- `code-check.md` (read by heading): the prose of every H3 under `## Mechanisms` (all fourteen, table rows and evidence blocks skipped). No heading outside Mechanisms read.

## What was checked

- **CSV rows.** `data/detection_additions.csv` parsed with `csv.reader`: every row has 17 fields, matching the header. The six new rows, read through `override_fields()` and `addition_item()`: each `override` names only fields in `OVERRIDABLE` that the row fills (Taylor `publicationTitle`, Best & Fisher `pages` with an en dash as `crossref_item()` writes, Albert & Anderson `creators` as `Albert, A.; Anderson, J. A.`, which `row_creators()` splits into two last/first creators). Rows with no `override` take CrossRef's fields alone.
- **What was filed, against the title pages.** Read the six group items (`FHDQDU42`, `4AM7FX43`, `I73CU8MR`, `2N6GFPDK`, `E7D64J6T`, `PQUK2TFD`) from a copy of `zotero.sqlite` taken with its `-wal`: titles, journals, volume, issue, pages and creators all match the title pages the brief gives (Morris 38:2074–2102; Kellner 14(6):1408–1415, `unmarked` with no `<scp>` residue; Taylor 52(7):3493–3500 with `&` decoded; O'Brien 6(2):131–139; Best & Fisher 28(2):152–157; Albert & Anderson 71(1):1–10, creators `Albert, A.` and `Anderson, J. A.`). This also re-checks `enumeration_round0.tsv` against the filed items; it agrees row for row.
- **Claims against the logs.** Dry run `exists 22 | would 6` and 28 additions = 22 + 6; second dry run `exists 28 | member 30 | pdf 30`; live run `created 6`. Measures: 9+30+11+5 = 55 items, minus the 2 in two collections = 53 members; PDFs on disk 4+30+2+4 = 40 − 2 = 38 keys; 53 − 38 = 15 left out, per collection 5 (statistics), 9 (survey_design), 1 (model_selection), 0 (detection), matching the left-out list. The 15 left-out keys are identical in the 2026-11-16, 2026-11-21 and 2026-11-25 build logs, and the Hastie split (2) and Bates pdftools read appear in all three, as `findings.md` says. 4.92 MB = the six files' sizes summed; detection 19.9 → 24.9 MB. Build 17:08:29 → 17:20:04 = 11.6 min. Push: 159,133,696 bytes / 8 MiB = 18.97 → 19 parts, matching `-19`; manifest `head_sha` 1e89da92 is the "statistics rebuilt" commit, as `progress.md` says. Query before/after hits in `findings.md` match the two query logs.
- **Public-text rule.** Ran the #56 `public_sweep.py` patterns over every added line of the diff: no hits. No home-directory path, host name, credential path, private repo or satellite-library identifier in any added line; `vca_refs` in the push log's manifest list already appears in many tracked push logs.

## Clean

No issues found.
