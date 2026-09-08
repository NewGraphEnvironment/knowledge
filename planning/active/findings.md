# Findings — Quick read of the North Thompson fish-passage reports (#11)

## Issue context

## Problem

There is no past-report knowledge for the North Thompson. No ragnar store covers LNTH or UNTH
(S3 holds `fraser`, `peace`, `pine`, `vca_refs` only), the Zotero group library has no
collection for either group, and the full report track (`0100` → harvest workflow → `0152`
ingest → Zotero filing → farm) is the expensive half of the pipeline and parked with #4's
blockers B2–B6 unfixed. What is wanted right now is much smaller: **a general summary of what
the fish-passage reports for the region say**, produced quickly and without a chain of
permission prompts.

## Scale, measured 2026-09-08 (local `fwapg`)

Distinct report links across all four PSCIS layers, clipped to the group:

| group | assessment | habitat confirmation | design | remediation | distinct across layers |
|---|---|---|---|---|---|
| LNTH | 15 | 3 | 2 | 4 | **21** |
| UNTH | 7 | 0 | 0 | 1 | **8** |
| STHM (South Thompson) | 3 | 0 | 1 | 2 | 6 |
| LTHO (Lower Thompson) | 0 | 0 | 0 | 0 | 0 |

LNTH + UNTH together: **24 distinct reports** (5 shared). More than the handful guessed, but
several will be one consultant's regional PSCIS reports linked from many crossings, and an
EcoCat "fish passage" keyword search for the region should add only a few.

**Hazard found while counting:** the habitat-confirmation layer names its link
`habconf_ecocat_url`, not `ecocat_url`. `knw_pscis_reports()` in `pkg/` documents that layers
without an `ecocat_url` column are skipped, so on this database confirmations would vanish
silently. Check the tunnel's column name too before trusting any pull.

## Proposed Solution — the simple version, about half an hour

1. **Links, not a harvest workflow.** One query on whichever database is up: distinct report
   URLs from all four layers for LNTH and UNTH (STHM optional), with the layer and crossing
   count per URL. Plus one EcoCat keyword search ("fish passage" + Thompson) to catch reports
   PSCIS does not link.
2. **Fetch the PDFs locally** into a gitignored directory (`data/lnth/reports_pdf/` or similar;
   `**/*.pdf` is already ignored). Skip Zotero filing entirely for this pass; it can be done
   later from the same files. Each EcoCat page carries several documents — take the main
   report, not the first attachment.
3. **Read them, do not build first.** ~24 reports is small enough to `pdftotext` and read
   directly; a ragnar store is optional and only if the reading needs search. Produce one
   markdown summary per group (`data/<wsg>/reports_summary.md`): who did what, when, where,
   what they recommended, and which crossings or streams they name — assessments, habitat
   confirmations, designs and remediations all included.
4. Record the link table (`data/<wsg>/reports.csv` from `0100` if it runs cleanly; otherwise
   the query output) so the summary is traceable to its sources.

**Constraints.** Unattended: no step may block on a permission prompt if it can be avoided —
prefer `curl` from a script over ad hoc network calls, and keep everything under `data/`. No
LLM farm, no rag store push, no Zotero writes.

## Acceptance

- [ ] Link table for LNTH and UNTH from all four PSCIS layers, with the `habconf_ecocat_url`
      case handled, plus the EcoCat keyword hits
- [ ] The report PDFs on local disk (ignored), one per distinct report
- [ ] `reports_summary.md` per group: a general account of what the reports say, citing each
      report by EcoCat id
- [ ] Anything the pull surfaces about the pipeline (the column-name hazard, others) recorded

## Out of scope

Zotero filing, ragnar store build and push, the priority farm and reconcile. Those are the
full track (#4) and can consume these files later.

Relates to #4, #5



## Exploration, 2026-09-08 (plan mode)

What exploration established (read-only, this session):

- **All 24 distinct LNTH/UNTH links are `advancedSearch.do?keywords=[PSCISnn]` search URLs**,
  not report ids (the README's axis 4). Each resolves by fetching that search page and
  parsing the `viewReport.do?reportId=N` hits whose title carries the `[PSCISnn]` tag. The
  endpoint is up (200) and hits come back as `reportId` + title in one page.
- **The habitat-confirmation layer's link column is `habconf_ecocat_url`** on the local
  `fwapg`. `knw_pscis_reports()` (`pkg/R/pscis.R:84`) skips any layer without `ecocat_url`,
  so confirmations vanish silently. LNTH has 3 confirmation reports; the tunnel is down right
  now, so its column name is unverified.
- `0100` hardcodes the tunnel and defaults `WSG_TARGET` to `PCEA` (`0100:32-33`): the same
  two hazards #5 fixed in the FISS scripts. The local `fwapg` carries all four PSCIS layers.
- The PDF is found the way `wf_report_harvest.js:69-72` does it (fetch `viewReport.do`, take
  the first `/pub/acat/documents/rN/*.pdf`) with `0153`'s main-report rule
  (`0153:61-79`: prefer a filename saying report/final, exclude appendix/attach/map/plate).
  Fetch with `curl` + `-A "Mozilla/5.0"`, HTTP status read explicitly (the #5 lesson).
- Keyword hits need a geo-filter: "fish passage thompson" returns Pennask Creek and TFL 18
  side by side. A title regex (`thompson|clearwater|barri[eè]re|kamloops|avola|blue river|
  mahood|wells gray|TFL ?18|LNT|UNT|north thompson`) does what the harvest agents do by hand.
- `**/*.pdf` is already gitignored, so the PDFs stay local without any change.
- Don't harvest NGE's own reports (README gotcha); none expected here.

Scale: 24 PSCIS-linked reports (LNTH 21, UNTH 8, 5 shared) plus a few keyword hits. Two
dozen PDFs is too many to read into one context; the reading is farmed to three or four
unnamed reader subagents (within the ~5-per-task bound), each writing structured notes per
report, and the group summaries are written from those notes.


## Errors Encountered

| Error | Resolution |
|-------|------------|

## Phase 1–2 — links resolved, and what does not resolve (2026-09-08)

- `knw_pscis_reports()` now takes any column ending in `ecocat_url`; the red-then-green test
  uses a confirmation layer named `habconf_ecocat_url`. `0100` no longer defaults to PCEA and
  falls back to the local `fwapg` when the tunnel is down (it was down; both runs used the
  local copy, `db_source` printed).
- `0100` LNTH: 25 report rows (all four layers, confirmations included now), UNTH: 9.
- **Every one of the 24 distinct links is an `advancedSearch.do?keywords=[PSCISnn]` search**;
  none is a report id. The bracket encoding is fine (`%5BPSCIS5%5D` → 24097). **Only 3 tags
  resolve** ([PSCIS5] → 24097 Trumbley 2008 FPCI on TFL 18; [PSCIS8] → 24103 Adams Lake FPCI;
  [PSCIS40] → 24146 Louis Creek 2009). The other 21 return no EcoCat hit at all.
- Who is behind the unresolved tags, by crossings: Fisheries and Oceans 2021–22 ([PSCIS4740],
  152 crossings across both groups), Braumandl 2018–2020 ([PSCIS3400/3740/3940], 82, assessments
  **and** the LNTH habitat confirmations), untagged 2010 ([PSCIS77], 43), Cornice 2025
  ([PSCIS6300/6301], 18), Canadian Wildlife Federation 2019–2023 ([PSCIS4500/4521/4522]:
  assessment, confirmation, design, remediation), Integrated ProAction 2007 remediations,
  Snowy River 2005–06, Secwepemc Fisheries Commission 2003, MoTI 2024. **The largest and most
  recent PSCIS campaigns in the North Thompson have no EcoCat report behind their tag.** The
  data is in PSCIS; the narrative, if one exists, is not catalogued under the tag.
- Keyword search (7 thematic queries): 61 hits, 19–20 in region per group after the title
  filter, 24 off region (Pennask, Trepanier, Vancouver Island …). One false positive caught
  by hand and now excluded by rule: "Clearwater Lake 00332PCEA" is in the Peace Arm.
- Fetch: 22 (LNTH) / 20 (UNTH) reports, 17 / 15 with text. Five have no PDF document (fish
  salvage permit returns carry `.xls`/`.zip` only: 58437, 58812, 42636, 64523, 64642); three
  are scanned with no text layer (369 steelhead telemetry, 54400 the 1974 inventory, 4825).
