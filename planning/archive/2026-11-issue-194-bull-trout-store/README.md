# #194: bull trout store

## Outcome

`species/bull_trout` (`VHWEK6RE`) went from 16 items, 11 of them with a PDF, to 174 items, 173 with a PDF.
- **Gathered:** the federal documents for both SARA units (the COSEWIC assessments of 2012 and 2025, and the registry
  pages; neither unit has a federal management plan, which corrected the issue's premise), BC's 2023 plan, Alberta's
  status report, the Hagen Williston series, Baxter's work, the FWCP and BC Hydro Peace, Columbia, Kootenay and Arrow
  monitoring reports, and the US core.
- **How:** 145 additions rows were drawn from each document's title page and audited against it, then filed through
  `0270`. The live run stopped partway, was resumed, and ended with a no-op dry run.
- **OCR:** two image-only scans were OCRed and swapped in through `0275`: the Metolius 1983–94 distribution report and
  Cannings & Ptolemy 1998.
- **Stores:** a new `bull_trout` store, built from `VHWEK6RE` alone, and `bull_trout_grayling` and `habitat_modelling`
  brought up to date. All three were pushed on 2026-11-15.

Learned:
- `crd_store_update()` leaves the space it frees inside the duckdb file (NewGraphEnvironment/cred#48). The fix was to
  rebuild before the push.
- A rebuild re-reads every PDF, so it drops image-only scans that older builds held as one-chunk documents (#217).
  `0150` now lists the documents a rebuild drops from the store it replaces.
- Six code-check rounds went mostly into the wording of that rebuild-before-push rule. Each round's fix restated the
  rule for a set of stores or passages wider than the case it was written from. Two things ended the loop: the rule
  is now carried by the code, and an enumeration showed nothing was left.

## Measurement

| store | documents | chunks | file after rebuild | after the in-place update (free blocks) |
|---|---|---|---|---|
| `bull_trout` | 173 (new) | 28,215 | 366 MiB | 541 MiB (32 %) |
| `bull_trout_grayling` | 35 → 196 | 32,204 | 418 MiB | 1.3 GiB (71 %) |
| `habitat_modelling` | 266 → 404 | 71,571 | 924 MiB | 3.6 GiB (76 %) |

- The updates matched the expectations written in their logs beforehand: 2 added; 164 added and 2 dropped; 150 added
  and 2 dropped.
- Each rebuild was then compared document by document with its updated store:
  - `bull_trout` came out identical;
  - the other two dropped 1 and 10 scans with no text;
  - 24 and 167 documents chunked by older builds now have different chunk counts.
- That size gap moved the plan from pushing the updates to rebuilding (Al, 2026-11-15). The pushed files are a third or
  less of the updated ones.
- Each push's multipart ETag matched its file at 8 MiB parts.
- Query checks on `bull_trout`, with expectations written first: critical habitat hit; thermal limits 3 of 4; South Coast
  management 2 of 3; Williston spawning partial (four expected Hagen-series reports did not return).

## Evidence

`scripts/logs/rag/2026111[2-5]_*` (0270 dry runs and live runs, OCR, 0275, build, updates, rebuilds, queries, pushes);
`enumeration_round0.tsv` and `audit_round1_*.tsv` (title-page audits); `review-round*.md` and `enumeration_round3.md`
(code-check).

## Owed

- Pieces 2 and 3: #198 (life history, blocked by this store) and #199 (datasets), filed in Phase 0

Also open: #209 (restricted EcoCat reports and Metolius 1996), #217 (OCR of ten scans), NewGraphEnvironment/cred#48.

Closed by: the PR for #194
