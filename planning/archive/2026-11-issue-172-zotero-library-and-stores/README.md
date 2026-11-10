# Backlog move 3 (#172): fix what the group library holds, bring new sources into the stores

## Outcome

One Zotero sitting carried backlog batches 4 and 5:

- **The Zotero scripts take the key from a file (#168).** `0153`'s `api_key()` reads `ZOTERO_API_KEY`, else the first non-blank line of the file `ZOTERO_API_KEY_FILE` names; `0270` reaches it through its load of `0153`.
- **The group library's items are put right by a recorded verdict file (#151, #126).** `scripts/0275-zotero-attachments-tidy.py` carries out `data/zotero_attachment_verdicts.csv`, one decided row per item, idempotently by end state. It covers the four sturgeon fixes, #126's 27 group-library items and the EFN Policy's creator fix.
  - Tredger 1984's scan was replaced by an OCR copy.
  - The duplicate Nechako strategy and the duplicate Banner field guide were merged into their keyed items.
  - Report parts and appendices were merged into one PDF each.
  - Fileless copies were trashed.
  - Six separate documents moved to their own items.
  - The 11 personal-library items went to #13's body.
- **The DFO threat-layer document and its sources are in the library and the stores (#20).** The document (CSAS 2025/013), the 2022 EFN Policy and Schnorbus 2020 are in `Fisheries/flow`, and the document also in `Fisheries/temperature`.
  - Evidence rows 1146-1151 hold the EFN flow-sensitivity class edges and DFO's metrics (qualitative: the document sets no thresholds).
  - The data question went to wet#5's body, and the method comparison to wet#162.
- **A `statistics` store exists (#95).** It holds McElreath 2020, BDA3, Hill 2025 and Toffolon & Piccolroaz 2015; its items 2 and 3 were filed as #185 and #186.
- **`0150` gained `ACTION=update` (cred 0.7.0's `crd_store_update()`).** It resolves a store's whole build list and refuses a store with any document outside Zotero storage (all of `fraser`, `peace` and `pine`).
- **`0270` gained new inputs.** It now takes `--parent top`, a book's fields, braced one-field organization names, and a `.pdf` name for a `/content` URL.

What was learned:

- **`crd_store_update()` drops every document outside the keys it is given.** A store must be updated with its whole build list, and never with a harvest store's documents (the plan review's two blockers).
- **The first code-check rounds kept finding defects inside earlier fixes.** One mechanism produced them: `0275` judged the copy left behind by a different handle (filename, list position) from the keys it trashed. That class was closed in one place, `trash_all()`, and the loop ended on the enumeration of every trash site.
- **Each meaning-audit round of the evidence rows found wording that said more than the source.** Placement was read as a stated link, and an example as the grounding. None found a wrong value or page.
- **A verified reconnect after a failed push silently replaced an updated store with the bucket's older copy** (CLAUDE.md now says so beside `ACTION=update`).

## Measurement

- **`0275`:** 31 live rows, 0 failed, then a 32nd (KE758PAG's creator). Every dry run afterwards reads 32 of 32 done.
  - The ten merged or OCR'd PDFs each pass `qpdf --check` and hold exactly their parts' pages: Lewis 36+4=40, Fins 332+9=341, Bottoms 72+56=128, MacKay 355+84+12=451, Hooft 22+13=35, Lloyd 129+1=130, Bustard 66+533=599, site card 3, Banner 281+253=534, Tredger OCR 49 pp and 7,531 words.
- **Stores after update, pushed and reconnected md5-verified:**

  | store | documents | change | why |
  |---|---|---|---|
  | sturgeon | 84 | +1 | Tredger 1984 |
  | flow | 43 | +4 −1 | the three #20 items and the merged Bottoms PDF in; the Bottoms appendix out |
  | temperature | 53 | +2 −1 | the DFO document and the live copy of Martins 2022 in; a duplicate #122 had trashed out, the store having been built 2026-10-15, before that |
  | bull_trout_grayling | 35 | +1 −2 | the merged Bottoms PDF for its two parts |
  | habitat_modelling | 264 | +3 −2 | |
  | statistics | 4 | new | |

  Every drop was accounted for before the push.
- **`0280`:** 1151 rows verified; coverage 48/48, thermal 50/50, flow 60/60.
- **Meaning audit of rows 1146-1151:** a self-audit and three subagent rounds (table in `findings.md`). It ended by grep-checking every phrase the last fix introduced on its page (10 of 10).
- **Code check:** three rounds, 4, 1 and 2 findings, all fixed. Rounds 2 and 3 found defects inside earlier fixes. The loop ended on an enumeration: `trash(` is called only from `trash_all()` and merge-items, both guarded.
- **Tests:** `devtools::test()` 2214 passed, 0 failed, 12 skipped (no database, no ignored local data).
- **Wrong turns:**
  - The first harvest guard matched names. It refused a real Zotero attachment named `PINE__56963.pdf` and missed lowercase harvest names; it now uses cred's own origin test.
  - The EFN class edges were first coded on the wrong sides.
  - I edited `0150` while a push of it ran (harmless, logged in `findings.md`).
  - The commit messages were rewritten before the first push to drop session-link trailers, which this public repo does not carry; the planning files cite the rewritten SHAs.

## Evidence

- `scripts/logs/habitat/20261110_literature_verify*`: the `0280` gate on the new rows.
- `review-plan.md` and `review-round*.md` in this directory.

## Owed

- Tick move 3 in `planning/backlog.md` (the moves table and batches 4 and 5) with the PR's link, after the merge, as move 1's was (`Tick move #170 in planning/backlog.md` on main).
- Reported, outside this diff: `0153`'s `existing_report_ids` counts an attachment left without a file by a stopped upload as filed (round 3's reach table).

Closed by: the PR for #172.
