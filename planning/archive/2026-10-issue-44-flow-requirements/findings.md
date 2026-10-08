# Findings — Flow needs by species and life stage: literature into the evidence table (CH, CO, SK, BT, GR, WCT) (#44)

## Issue context

**If we do it:** each species and life stage gets cited flow needs: a minimum, an optimum, or a fraction of mean annual discharge (MAD) by month. Those can be set against the monthly flows from #42 and the stage windows in `life_history_timing.csv`. Where species share a stream, the comparison shows which stage is short of water in which month. **If we never do:** flow stays an annual stream-size filter, and the evidence table has no answer to "is there enough water for this stage, then".

## Problem

Species: Chinook, coho, sockeye, bull trout, Arctic grayling, westslope cutthroat, and steelhead/rainbow where the sources cover them.

The evidence table's discharge rows are annual IP-model MAD thresholds plus one salmon migration low-flow statement (Gottesfeld & Rabnett, upper Bulkley). No row ties a life stage to a seasonal flow. The literature that does is either undrafted or missing from the library:

- **In the group library, not drafted as flow evidence:**
  - `raleigh_etal1986HabitatSuitablility`: Chinook HSI and instream flow suitability curves, depth and velocity by life stage.
  - `bjornn_reiser1991HabitatRequirements`: depth and velocity criteria.
  - `warkentin_etal2022Lowsummer`: summer low flow and Chinook productivity.
  - `eclipsegeomaticsltd_2016Upperbulkley`: Upper Bulkley thresholds.
  - `macisaac2010SalmonidsHydrologic`
  - `northwesthydraulicconsultantsltd_hamiltonr_1993FinalReport`
  - `woelfle-erskine_etal2017Abiotichabitat`
  - `amecenvironment&infrastructure2015Appendix5126D`
- **Not in the library (from memory, to verify):**
  - BC Instream Flow Thresholds for Fish and Fish Habitat (Hatfield, Lewis, Ohlson & Bradford 2003).
  - Ptolemy & Lewis 2002, rationale for BC instream flow standards.
  - Hatfield & Bruce 2000: western North America PHABSIM results pooled into regressions of optimum flow on MAD, by species and stage.
  - Bradford & Heinonen 2008, low flows and instream flow needs in small streams.
  - DFO 2013 ecological flow framework.
  - Tennant 1976.
  - USFWS HSI/instream flow models for the other species: coho, cutthroat, Arctic grayling (Hubert et al. 1985).
  - Washington Ecology instream flow studies.
  - Central Valley Chinook flow–habitat (WUA) reports.

## Proposed solution

1. **Acquire with the least hand work.**
   - Use `0270-habitat-collection-build.py --collection flow`, with `data/flow_members.csv` (keys already held) and `data/flow_additions.csv` (DOI or metadata, plus a PDF URL).
   - Government and open-access PDFs come by URL.
   - For paywalled or ResearchGate-only items, open the links in Chrome so Al can download them in one batch. Then one copy from `~/Downloads` into the repo (the agent cannot read `~/Downloads`), with each `pdf` set to that repo path.
   - The `lit-search` and `zotero-api` skills cover the search and any write 0270 does not.
2. **Build a `flow` store** with `0150` (and push it), for searching the full text.
3. **Decide the vocabulary at the plan gate.**
   - A unit for a fraction of MAD (`percent` is gradient-only).
   - Whether `metric` gains flow statistics, like temperature's: monthly mean, 7-day low, percent of MAD.
   - Depth and velocity already exist.
4. **Draft rows** by species × stage, through the `0280` gate, with the meaning audit CLAUDE.md requires.
5. **Write it up** in `research/flow_requirements.md`: what is cited, by species and stage, and what has no source.

Relates to #42, #20, #36

## Plan-mode exploration (2026-10-07)

What exploration found:
- **In the group, with PDF:** raleigh 1986 (CH HSI and flow curves), bjornn_reiser 1991 (a scan; OCR),
  warkentin 2022, eclipse 2016, macisaac 2010, NHC 1993, woelfle-erskine 2017, plus grayling sources (hagen,
  stamford, stewart 2007 NWT grayling life history, cutting 2018 beaver dams and grayling passage).
- **In the group, no PDF:** `amecenvironment&infrastructure2015Appendix5126D` (instream flow study) and
  `raleigh_etal1984Habitatsuitability` (rainbow trout HSI).
- **Not in any library:** Hatfield et al. 2003, Ptolemy & Lewis 2002, Hatfield & Bruce 2000, Bradford &
  Heinonen 2008, Tennant 1976, Hubert et al. 1985 (grayling HSI), the coho and cutthroat HSI models (McMahon
  1983; Hickman & Raleigh 1982). `dfo2013ScienceAdvice` is the offsetting advice, **not** the 2013
  ecological-flow framework, so the framework also has to be added.
- `species_code` is not a controlled vocabulary, and `GR` is the FDIS code for Arctic grayling.
- `percent` fits only `gradient`. `depth` (`m`) and `velocity` (`m/s`) exist and carry no metric.
- `0280` already has the THERMAL species × cell grid and `meets()` (scripts/0280-literature-verify.R:72, :474).
  A FLOW grid reuses both.
- `0270 --collection <name>` reads `data/<name>_members.csv` and `_additions.csv`. `0150 ACTION=build
  STORE=<name> COLLECTIONS=<key>`, then `ACTION=push`.

## Errors Encountered

| Error | Resolution |
|-------|------------|
