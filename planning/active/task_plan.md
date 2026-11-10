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
- [ ] `scripts/0153`: replace the import-time guard (line 49) with one helper: `ZOTERO_API_KEY` when set and
      non-empty, else the first non-blank line of the file `ZOTERO_API_KEY_FILE` names (stripped); exit naming both
      variables when neither gives a key, and when the file is named but unreadable or empty. `0270` keeps reading
      `z.API` through its existing load of `0153`, so the two cannot drift.
- [ ] Docstrings of `0153` and `0270`, `scripts/README.md`, and CLAUDE.md ("Credentials come from the environment",
      "Zotero access is local, except for filing") name `ZOTERO_API_KEY_FILE`.
- [ ] Prove each branch with `python3 -c` imports of `0153` (variable set; unset + file; unset + empty file; unset +
      missing file; neither) and that `data-raw/zotero_copy_check.R`'s `ZOTERO_API_KEY=check-only` child still runs.

## Phase 2: `0150 ACTION=update`, then the sturgeon follow-ups (#151)
- [ ] Upgrade cred to 0.7.0; `0150` refuses `ACTION=update` below the first cred that exports `crd_store_update()`.
- [ ] `scripts/0150-store.R`: `ACTION=update STORE= KEYS=` (or `COLLECTIONS=`) calling `crd_store_update()` on the
      group library, then the same push reminder as a build; `scripts/README.md` row.
- [ ] OCR Tredger 1984 (`ocrmypdf --deskew`) and attach it to `AHE9BFQQ` as a second PDF (keeping the scan).
- [ ] Merge the strategy: `B2UZ32FE` into `Nechako - NECR`, `dc:replaces` `VS4P4TG6`, trash `VS4P4TG6`.
- [ ] PATCH `KSCZP9JS`'s title and `QPIC5D8X`'s date to `data/sturgeon_additions.csv`'s values; confirm
      `0270 --collection sturgeon --parent 9U54XAND --dry-run` prints no `would` line.
- [ ] Remove the "not live until #151" line under `0270` in `scripts/README.md`.
- [ ] With Zotero quit (cred#45), `0150 ACTION=update STORE=sturgeon` for the three items, check Tredger 1984 is a
      document, push.

## Phase 3: Items with several PDFs (#126, group library)
- [ ] `scripts/0275-zotero-attachments-tidy.py` (loads `0153` as `0270` does, `--dry-run` first): reads
      `data/zotero_attachment_verdicts.csv` (citation key, action, attachment keys in reading order, new-item
      metadata where split) and does `merge` (download each part via the Web API, `qpdf --empty --pages`, upload the
      merged PDF to the item, trash the parts), `keep` (trash the rest), `split` (create an item, re-parent the
      attachment), `relabel`, and `merge-items` (the CLAUDE.md duplicate recipe). A copy with no stored file on the
      server (no `md5`) is trashed only after the Web API confirms it holds none. Idempotent: a re-run prints nothing
      to do. Prints the changed item keys.
- [ ] Before trashing `banner_etal1993fieldguidea`'s item, search the org for that key
      (`gh api search/code`, then clone-and-grep the report repos it covers): a cited key must not vanish.
- [ ] Dry run, Al reads it, live run, dry run again shows nothing to do.
- [ ] Record the verdicts in #126's body; write the 11 personal-library items into #13's body (owed there) and close
      #126 with this PR.
- [ ] `0150 ACTION=update` each store whose manifest holds a changed item, or list in #126 the stores that wait for
      their next build.

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

## Phase 4: The DFO threat-layer document (#20)
- [ ] `data/flow_additions.csv`: Iacarella et al. 2025 (CSAS 2025/013, PDF from waves-vagues), FLNRORD 2022 EFN
      framework and Schnorbus 2020 where the library lacks them; `0270 --collection flow` dry run then live; add the
      document to `hydrology` (`X29BX4U8`) and `species/salmon` (`W4425VK5`), which feed `habitat_modelling`, and as
      a `temperature_members.csv` row once BBT has keyed it.
- [ ] Append `literature_evidence.csv` rows: the low-flow (minimum August %MAD) and high-flow (maximum May %MAD)
      metrics and the August mean temperature metric, `instream_flow`/`temperature` with their `metric` per the
      CLAUDE.md conventions; `0280` gate; audit every row's meaning against the PDF, repeating until a round finds
      nothing.
- [ ] Write the data question into wet#5's body; file a wet issue with step 4's method differences
      (precipitation scaling vs area-weighted sampling, dam corrections, weak Aug/Sep minima, 86-gauge metrics).

## Phase 5: The statistics store (#95)
- [ ] `0270`: `--parent top` finds or creates a top-level collection (`/collections/top`).
- [ ] `data/statistics_members.csv` (the collection's current members) and `data/statistics_additions.csv` (BDA3, PDF
      from the authors' site); `0270 --collection statistics --parent top` dry run then live.
- [ ] `0150 ACTION=build STORE=statistics COLLECTIONS=LP4R4VYR`, check McElreath, Hill and BDA3 are documents, push.
- [ ] File the alignment review and the partially pooled curve as issues, each naming move 3 (#172) as where it was
      split from, left out of `planning/backlog.md`; move #139's pointer for priors and pooling to the curve issue.

## Phase 6: Stores and docs
- [ ] With Zotero quit: rebuild or update `flow`, `habitat_modelling` and `temperature` for Phase 4's items; push each.
- [ ] CLAUDE.md data list gains `statistics_{members,additions}.csv`, `zotero_attachment_verdicts.csv` and the
      `statistics` store; `scripts/README.md` gains `0275` and the statistics build line.
- [ ] Tick move 3's boxes in `planning/backlog.md` (batches 4 and 5).

## Validation
- [ ] Phase 1's branch checks pass; `data-raw/zotero_copy_check.R` passes
- [ ] Every `0270`/`0275` live run followed by a dry run that prints nothing to do
- [ ] Each store connects md5-verified after its push, and holds the documents named above
- [ ] `0280` passes after the new evidence rows; the meaning audit's rounds are recorded in findings
- [ ] `devtools::test()` passes (registers, vignette data untouched)
- [ ] `/code-check branch` clean (three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

## Owed at the end (reported, done after merge)
- [ ] #13 carries the 11 personal-library multi-PDF items

