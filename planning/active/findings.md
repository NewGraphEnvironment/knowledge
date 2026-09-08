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
