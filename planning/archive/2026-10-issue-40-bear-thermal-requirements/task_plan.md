# Task: Get the Bear et al. 2005 and 2007 WCT thermal-requirement PDFs and read them into the evidence table (#40)

## Problem

Both items are in the group library and in `Fisheries/temperature`, with no PDF:

- `bear_etal2007ComparativeThermal`: Bear, McMahon & Zale 2007, TAFS 136:1113–1121, doi:10.1577/T06-072.1. Closed access (Unpaywall and Semantic Scholar both report no open copy).
- `bear_etal2005ThermalRequirements`: the 2005 final report to the Wild Fish Habitat Initiative (Montana State University). Only copy found is ResearchGate (https://www.researchgate.net/publication/239856422_Thermal_Requirements_of_Westslope_Cutthroat_Trout), which blocks scripted download.

#38 left these WCT cells resting on secondary citations or `none`:

- rearing upper limit: rows 521–522 (Cleator, Thorley);
- incubation degree-days to hatch: row 531;
- growing-season degree-days for rearing and overwintering: rows 532–533.

`research/thermal_requirements.md` names Bear 2005 as the likeliest unread source of WCT degree-days.

## Plan context

After #38, the WCT thermal cells rest on secondary citations of Bear et al. 2007. Those are Cleator 19.6 °C
(row 521, file line 522) and Thorley 19 °C (row 522). The WCT degree-day cells (rows 531–533) are `none`, and
their notes say "Bear et al. 2005, 2007 … have none" (no PDF). The issue assumed both PDFs had to be fetched by
hand. Exploration found otherwise:

- **Bear, McMahon & Zale 2007 (TAFS):** there is an author-hosted copy on McMahon's MSU lab site
  (`https://naturefilm.montana.edu/mcmahon/documents/cttxrbt%20temp%20TAFS.pdf`). It is 200 OK, a real PDF,
  and pdftotext confirms the TAFS paper (doi 10.1577/T06-072.1). Its content: the 60-d UUILT for WCT is 19.6 °C
  (CI 19.1–19.9) and for RB 24.3 °C. It also gives 7-d UUILTs, which are 1.7 °C higher. The growth optimum is
  13.6 °C for WCT and 13.1 °C for RB, tested over 8–20 °C. The paper recommends a maximum daily temperature of
  13–15 °C. It reports **no degree-days**.
- **Bear, McMahon & Zale 2005 (WFHI final report):** The user put the ResearchGate copy at
  `data/rag/pdf/Thermal_Requirements_of_Westslope_Cutthroat_Trout.pdf`. It is a 31-page PDF dated January 2005.
  Its content: the WCT UUILT is **19.7 °C** (CI 19.1–20.3) against the paper's 19.6, so the report predates the
  paper's reanalysis. RB is 24.2 °C. The WCT growth optimum is 13.6 °C, with the 95% CI given as the optimal
  growth range (10.3–17.0). It also has the hybrid hatching-failure note and **no degree-days**. (Bear's 2005 MS
  thesis on ScholarWorks covers the same work and is not needed.)
- Neither item has a PDF in Zotero yet (`P9KAE65R`, `HFZES7WC`, group library).

Expected outcome: primary WCT (and RB) lethal, optimum and recommendation rows. The WCT degree-day cells will
most likely stay `none`, with their notes revised to say Bear was read (the abstracts are chronic-exposure work
on juveniles). That is a real result: it retires the "likeliest unread source" caveat.

The 2005 and 2007 values differ (19.7 vs 19.6 °C UUILT, and possibly the CIs). Both get rows, each in its
own source's words, and each note names the other's value. A reader of `meets()` takes either.

## Phase 1: Get the PDFs into Zotero and the temperature store
- [x] `data/temperature_members.csv`: on `bear_etal2007ComparativeThermal`, set `pdf` to the naturefilm URL; on `bear_etal2005ThermalRequirements`, set `pdf` to `data/rag/pdf/Thermal_Requirements_of_Westslope_Cutthroat_Trout.pdf`. Update both `source` texts
- [x] `0270 --collection temperature --dry-run`, then the live run; log to `scripts/logs/habitat/2026101x_temperature_*`
- [x] Confirm both uploads in the Web API (`has_pdf`), and once Zotero syncs, in a guarded copy of `zotero.sqlite`
- [x] Rebuild the `temperature` store (`OVERWRITE=TRUE`) and push it (`CONFIRM=TRUE`); verify on a fresh connect. Rebuild `habitat_modelling` too if the new items fall in its input collections

## Phase 2: Draft rows under the #38 brief
- [x] Re-read `planning/archive/2026-10-issue-38-thermal-requirements/drafter-brief.md` and the CLAUDE.md drafting conventions. Check every convention against the source (#44's lesson)
- [x] Draft from Bear 2007: WCT and RB 60-d UUILT (`lab`, rearing), 7-d UUILT, growth optimum (`bound = optimum`), the tested range in the note, and the 13–15 °C max-daily recommendation (`expert`, `metric` as written). Read the tested life stage and acclimation from Methods
- [x] Draft from the 2005 report on the same pattern (UUILT 19.7, optimum 13.6 with its optimal growth range, RB values). Note the differences from 2007 row by row. Any statement 2007 lacks gets its own row; the hybrid hatching failure gets none (no value, no grid cell)
- [x] Append the rows (never insert). Revise the WCT degree-day `none` notes in rows 531–533 (and any other note saying "Bear … have none") to name what was read. Replace a `none` row only if a value fills it
- [x] Add a cross-reference to the primary row in the notes of the Cleator and Thorley secondaries (rows 521–522)

## Phase 3: Meaning audit and gate
- [x] Audit every new or changed row against the PDF: meaning, stage, kind, metric, bound, unit. Use an Explore/Plan-type reader for a blind second pass; write the findings to `planning/active/audit-*.md`
- [x] Fix, then audit the fixes. End by enumeration (each same-page group with mixed kind or metric is mixed by its own sentences)
- [x] `Rscript scripts/0280-literature-verify.R`: 0 failing quotes, thermal grid 50/50; log `scripts/logs/habitat/2026101x_literature_verify*`

## Phase 4: Write-up
- [x] Revise `research/thermal_requirements.md`: the WCT table rows (primary citation), the "Left out" Bear bullet, the degree-day paragraph and the consumer guidance; update the provenance line
- [x] Grep CLAUDE.md and `research/` for any other "Bear … no PDF" sentence and fix it

## Validation

- [x] Tests pass (`0280` gate)
- [x] `/code-check` clean (each commit, or once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
