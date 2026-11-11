## Outcome

The group collection `species/westslope_cutthroat` (`TIDR3PNN`) was filed through `0270` from
`data/westslope_cutthroat_{members,additions}.csv` and the `westslope_cutthroat` store built from it alone, queried
and pushed. The additions are the federal management plan (Part 1) and its 2017–2021 progress report, the EDF Elk Valley
pages, call guide and KNC newsletter, the CWF Elk River connectivity restoration plan, Upper Fording monitoring 2022,
the Upper Fording and Harmer Creek Evaluation of Cause syntheses with their expert reports, Grave and Harmer Creek
monitoring, the calcite series and five FWCP Upper Kootenay reports; six group items filed elsewhere became members.
Eleven members' PDFs need a hand download (#191, which adds them in place with `0150 ACTION=update`); Hagen & Baxter
2009 has no copy anywhere. Learned: cred 0.7.0 updates a store in place, and CLAUDE.md still said it could not
(corrected). The branch review found eleven rows whose author, title form, place or report type came from a sibling
row, a cover sheet or the preparer's address rather than the row's own title page or citation line; it ended on an
enumeration of every field against a verbatim snippet of its own document (`review-round3-evidence.tsv`).

## Measurement

| `TIDR3PNN` | before (2026-11-10) | after (2026-11-11) |
|---|---|---|
| live top items | 30 | 85 |
| with a Better BibTeX key | 30 | 85 |
| with a PDF on disk | 9 | 73 |

PDFs: 242.4 MB uploaded, 438.5 MB registered without sending (Zotero storage already held the file's md5). Store:
73 documents, 17,700 chunks, 243,019,776 bytes, md5 `de28293cc29d614f392ca0812971150d`; the bucket object's multipart
ETag recomputed from the local file (8 MiB parts, 29) matched. Build 10.5 min. Of four queries with expectations
written first, thermal limits and restoration in the Elk hit; hybridization in the upper Kootenay and EDF monitoring
requirements hit partly (Muhlfeld et al. 2016 and KNC's newsletter outside the top results). Review: round 1 one wrong
author, round 2 ten more fields of the same kind (one inside round 1's fix), round 3 one, across 290 fields and 9
member PDFs; 12 PATCHes over 11 Zotero items, each round followed by a no-op dry run.

## Evidence

`scripts/logs/rag/20261111_*westslope_cutthroat*` (dry runs 1 and 2, the live run, build, queries, push).

Closed by: PR for #190
