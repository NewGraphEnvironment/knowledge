# Task: Backlog move 3: Zotero: fix what the group library holds, and bring new sources into the stores (#172)

**If we do it:** the Zotero scripts run with the key in a file, the library's duplicates, mistitled items and multi-PDF items are settled in one sitting, and the DFO threat-layer document and a statistics store reach the stores. **If we never do:** `0270 --collection sturgeon` stays unsafe to re-run, the citation audit keeps reading map sheets, and the method has no statistics store to be read against.

Members: #168, #151, #126 (batch 4, library writes); #20, #95 (batch 5, new sources). One phase per batch piece, one PR.

## Context

Move 3 carries backlog batches 4 (library writes: #168, #151, #126) and 5 (new sources: #20, #95) in one Zotero
sitting and one PR. Today `0270 --collection sturgeon` is unsafe to re-run (a mistitled item), the citation audit reads
whichever PDF Zotero ranks first (a map sheet for `finsconsultingltd_2001Reconnaissance1`), the DFO threat-layer
document is not in the library, and there is no `statistics` store. Every library write goes through the Web API and
needs Al present (auto mode refused #124's merge): the plan runs dry first, then live with Al approving.

Measured during planning (2026-11-09):
- `cred` installed here is **0.1.0**; 0.7.0 is released and `0150 ACTION=build` needs ≥ 0.5.0. 0.7.0 exports
  `crd_store_update()` (cred#44 closed), which #151 asks for; `0150` has no `ACTION=update` yet.
- `statistics` is a **top-level** group collection (`LP4R4VYR`, 8 items, 2 with PDFs: McElreath 2020, Hill 2025).
  `0270`'s `find_collection()` only looks under `--parent`, so it needs a top-level option.
- #20's document (Iacarella et al. 2025, CSAS 2025/013) is not in the library. Tennant 1976, Ptolemy & Lewis 2002,
  Weller 2024, Isaak 2015/2017 already are. `literature_evidence.csv` has 0 Weller rows.
- #126's 25 group items hold 67 PDFs; 13 of those PDFs have no file on this machine (fileless copies).
- `bcgov/nr-bcwat` is public and active (pushed 2026-11-09); wet#5 tracks the transfer.

## Decided at the gate

- #20's data question goes to wet#5's body (Al, 2026-11-09); #20 closes on its document, sources and evidence rows.
- #95 adds BDA3 only, with its free author PDF; Wood (GAM) and MacKenzie (occupancy) are named in the store's
  README row as wanted once a PDF is in hand (Al, 2026-11-09).
- #20's evidence rows stay in this PR, audited row by row for meaning (Al, 2026-11-09). #20's step 4 (method note for
  wet) is filed as a wet issue carrying the method differences, not written into wet here.
- Upgrade `cred` 0.1.0 → 0.7.0 (`pak::pak("NewGraphEnvironment/cred")`) before any store work.
- `#126` verdicts as in the table under Phase 3 (approved with this plan; the three marked *sitting* are settled by
  opening the file during the sitting, and recorded in #126's body).

## Phase 1: Key from a file (#168)
- [x] `scripts/0153`: replace the import-time guard (line 49) with one helper: `ZOTERO_API_KEY` when set and
      non-empty, else the first non-blank line of the file `ZOTERO_API_KEY_FILE` names (stripped); exit naming both
      variables when neither gives a key, and when the file is named but unreadable or empty. `0270` keeps reading
      `z.API` through its existing load of `0153`, so the two cannot drift.
- [x] Docstrings of `0153` and `0270`, `scripts/README.md`, and CLAUDE.md ("Credentials come from the environment",
      "Zotero access is local, except for filing") name `ZOTERO_API_KEY_FILE`.
- [x] Prove each branch with `python3 -c` imports of `0153` (variable set; unset + file; unset + empty file; unset +
      missing file; neither) and that `data-raw/zotero_copy_check.R`'s `ZOTERO_API_KEY=check-only` child still runs.

## Phase 2: `0150 ACTION=update` (store tooling)
- [x] Upgrade cred to 0.7.0; `0150` refuses `ACTION=update` below the first cred that exports `crd_store_update()`.
- [x] `scripts/0150-store.R`: `ACTION=update STORE= COLLECTIONS=` resolves the store's whole build list as a build does
      and passes the union to `crd_store_update()` (a narrower list drops documents); `scripts/README.md` row.
- [x] Refuse a harvest store (any `<EXTENT>__<reportId>.pdf` origin), print document counts and drops (review #2, #19).

## Phase 3: Library writes (Zotero running; dry run, Al reads it, live, dry run again shows nothing)
Order from the plan review: every write lands here, then Phase 6 quits Zotero and updates each store once.

**#151, sturgeon follow-ups**
- [ ] OCR Tredger 1984 (`ocrmypdf --deskew`) and replace the scan on `AHE9BFQQ` (`XETIXEM2`) with it, so the audit
      and the store both read text (review #12).
- [ ] Merge the strategy: `B2UZ32FE` into `Nechako - NECR` (`977GE58E`), `dc:replaces` `VS4P4TG6`, trash `VS4P4TG6`.
- [ ] PATCH `KSCZP9JS`'s title and `QPIC5D8X`'s date to `data/sturgeon_additions.csv`'s values; check both keep their
      citation keys; `0270 --collection sturgeon --parent 9U54XAND --dry-run` prints no `would` line.
- [ ] Remove the "not live until #151" line under `0270` in `scripts/README.md`.

**#126, items with several PDFs (group library)**
- [x] `scripts/0275-zotero-attachments-tidy.py` (loads `0153` as `0270` does; `--dry-run`): reads
      `data/zotero_attachment_verdicts.csv` (item key, citation key, action, attachment keys in reading order, merged
      file name, split metadata) and does `merge` (download each part, check its md5, `qpdf --deterministic-id --empty
      --pages`, upload, trash the parts), `keep`, `split` (new item in the parent's collections, re-parent the
      attachment), `relabel`, `replace`, `patch` and `merge-items` (collections and relations merged, `dc:replaces` as
      a group item URI). Done means the end state holds (every part trashed, one live merged PDF), so a re-run after a
      crash finishes rather than duplicates. Prints the changed attachment keys. #151's writes are rows of the same file.
- [x] Before any item loses or changes its PDF, search the org for its citation key (`gh api search/code`, then
      clone-and-grep the report repos it covers): banner `…fieldguidea`, hall, abbott, Skeena, mccarthy first.
- [ ] Dry run, Al reads it, live run, dry run again shows nothing to do.
- [ ] Record the verdicts in #126's body; write the 11 personal-library items into #13's body and close #126 with this PR.

| item | PDFs | verdict |
|---|---|---|
| `lewis_etal1998TritonEnvironmental` | report 36 pp + 4 one-page maps | merge, report first |
| `finsconsultingltd_2001Reconnaissance1` | report 332 pp + 9 map sheets | merge, report then maps 1–9 |
| `bottoms_etal2023Criticalhabitats` | report + Appendix 1 | merge |
| `mackay_etal1998MidBulkleyDetailed` | report 355 pp + appendices 84 pp + photos 12 pp | merge |
| `hooft2015Fishpassage` | report + project maps | merge |
| `lloyd2005Fishpassage` | report 129 pp + 1-page map | merge |
| `davidbustardandassociatesltd_1997StreamInventory` | Vol. 1 + Vol. 2 (survey cards) | merge parts |
| `ministryofenvironment2001SiteCard` | 3 one-page scans | merge parts |
| `banner_etal1993fieldguide` + `…fieldguidea` | two items, each part 1 (281 pp) + part 2 (253 pp, same md5) | merge items, keep `…fieldguide`; one PDF of part 1 + part 2 (*sitting*: which part-1 copy) |
| `perrin_korman1997PhosphorusBudget` | same 128 pp, one searchable | keep the searchable copy |
| `thompson2013AssessingFish` | two 10 pp versions | keep one (*sitting*: compare) |
| `sloat`, `rapp_abbe`, `tran`, `garnett`, `rahr`, `ban_frid`, `zhang_west`, `polfus` | one stored PDF + fileless copies | keep the stored one, trash the fileless |
| `abbott_etal2021Guidanceuse` | guidance + eDNA reporting template | split the template to its own item |
| `SkeenaWatershedEcosystemValuationProjectPlan` | 2013 project plan + 2006 wild salmon economy valuation | split the 2006 valuation to its own item |
| `hall_stednick2008AlseaWatershed` | 1961 Alsea summary (Misc. Paper 110), USGS Circular 490, a 6 pp scan | split each to its own item (*sitting*: identify the scan) |
| `mccarthy2000ComeauCreek` | report + a 2016 crossing map | split the map to its own item |
| `viveiros2010FishPassage` | report PDF + a maps `.zip` labelled PDF | relabel the zip |

## Phase 4: The DFO threat-layer document (#20) — writes, rows, hand-offs
- [ ] `data/flow_additions.csv`: Iacarella et al. 2025 (CSAS 2025/013, PDF from waves-vagues), and FLNRORD 2022's EFN
      framework and Schnorbus 2020 where the library lacks them (check the document's own reference list, review #14);
      `0270 --collection flow` dry run then live; once BBT keys it, a `data/temperature_members.csv` row puts the
      document in `Fisheries/temperature`, which feeds `habitat_modelling` (review #8).
- [ ] Append `literature_evidence.csv` rows, each naming the key it cites: Iacarella 2025's low-flow (minimum August
      %MAD) and high-flow (maximum May %MAD) metrics and its August mean temperature metric, and the EFN framework's
      monthly-sensitivity basis; `0280` gate; audit every row's meaning against the PDF, repeating until a round finds
      nothing.
- [ ] Write the data question into wet#5's body; file a wet issue with step 4's method differences
      (precipitation scaling vs area-weighted sampling, dam corrections, weak Aug/Sep minima, 86-gauge metrics).

## Phase 5: The statistics collection (#95) — writes and split-offs
- [ ] `0270`: `--parent top` finds or creates a top-level collection (`/collections/top`); the "elsewhere" exit
      suggests it; docstring and comments stop assuming Fisheries (review #16).
- [ ] `data/statistics_members.csv` (the collection's current members) and `data/statistics_additions.csv` (BDA3, PDF
      from the authors' site); `0270 --collection statistics --parent top` dry run (watch for personal-library PDF
      uploads) then live.
- [ ] File the alignment review and the partially pooled curve as issues, each naming move 3 (#172) as where it was
      split from, left out of `planning/backlog.md`; move #139's pointer for priors and pooling to the curve issue.

## Phase 6: Stores, once, with Zotero quit (cred#45)
- [ ] Confirm Zotero has synced every write, downloaded every new file, and keyed every new item; then quit it.
- [ ] Find the cred-built stores holding a changed attachment (`documents.origin` under `storage/<key>/`); harvest
      stores (`fraser`, `peace`, `pine`) are left for their next 0152 build and named in #126.
- [ ] `0150 ACTION=update` with each store's whole build list (`scripts/README.md`): `sturgeon` (Tredger is a document,
      the strategy once), `flow`, `temperature`, `habitat_modelling`, and each other store found above; read the counts
      and drops; push; reconnect md5-verified.
- [ ] `0150 ACTION=build STORE=statistics COLLECTIONS=LP4R4VYR`: McElreath, Hill, Toffolon & Piccolroaz and BDA3 are
      documents; push.
- [ ] CLAUDE.md data list gains `statistics_{members,additions}.csv`, `zotero_attachment_verdicts.csv` and the
      `statistics` store; `scripts/README.md` gains `0275` and the statistics build line (Wood and MacKenzie named as
      wanted once a PDF is in hand).
- [ ] Tick move 3's boxes in `planning/backlog.md` (batches 4 and 5).

## Validation
- [ ] Phase 1's branch checks pass; `data-raw/zotero_copy_check.R` passes
- [ ] Every `0270`/`0275` live run followed by a dry run that prints nothing to do
- [ ] Each store connects md5-verified after its push, holds the documents named above, and its update printed no
      unexplained drop
- [ ] `0280` passes after the new evidence rows; the meaning audit's rounds are recorded in findings
- [ ] `devtools::test()` passes (registers, vignette data untouched)
- [ ] `/code-check branch` clean (three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

## Owed at the end (reported, done after merge)
- [ ] #13 carries the 11 personal-library multi-PDF items

