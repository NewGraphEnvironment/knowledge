# Findings — statistics store: the methods literature for detection and occupancy (#216)

## Issue context

**If we do it:** occupancy, detection and removal methods can be searched and cited from their sources in the same store as the Bayesian texts. **If we never do:** each analysis re-finds them, and cites what it remembers.

## Problem

The `statistics` store (`data/rag/statistics.duckdb`) holds four general texts: McElreath 2020, BDA3, Hill 2025, and Toffolon & Piccolroaz 2015. It has nothing on imperfect detection, the base of any survey that can miss what is there.

## Proposed Solution

Acquire (Mode 0), file in the group library under a `Statistics/detection` collection, and rebuild `statistics` with its whole build list (script 0150, `ACTION=update`):

- **Occupancy:** MacKenzie et al. 2002 and the 2018 book, Royle & Nichols 2003, Tyre et al. 2003, Kéry & Royle (*Applied Hierarchical Modeling*).
  - Goodness of fit: MacKenzie & Bailey 2004 (`10.1198/108571104X3361`).
  - The closure assumption: Rota et al. 2009 (`10.1111/j.1365-2664.2009.01734.x`).
  - Survey design, and what low detection does to the estimate: MacKenzie & Royle 2005 (`10.1111/j.1365-2664.2005.01098.x`), Guillera-Arroita et al. 2010 (`10.1111/j.2041-210X.2010.00017.x`).
- **Removal:** Zippin 1958, Carle & Strub 1978, Hedger et al. 2013.
  - The likelihood: Moran 1951 (`10.1093/biomet/38.3-4.307`).
  - The multinomial model across sites: Royle 2004 (`10.32800/abc.2004.27.0375`), Dorazio et al. 2005 (`10.1111/j.1541-0420.2005.00360.x`).
  - Capture probability that falls across passes: Riley & Fausch 1992 (`10.1577/1548-8675(1992)012<0768:UOTPSB>2.3.CO;2`), Peterson et al. 2004 (`10.1577/03-044`).
- **eDNA occupancy:** Schmidt et al. 2013, Dorazio & Erickson 2018.
  - The multi-scale model they build on: Nichols et al. 2008 (`10.1111/j.1365-2664.2008.01509.x`).
- **Camera surveys:** Rowcliffe et al. 2014 and Ridout & Linkie 2009 (activity), Burton et al. 2015, the BC RISC wildlife camera standard.
- **Diversity:** Chao et al. 2014 and Hsieh et al. 2016 (iNEXT).
  - The incidence-based richness estimator: Chao 1987 (`10.2307/2531532`).
  - Sample coverage and extrapolation: Chao & Jost 2012 (`10.1890/11-1952.1`), Colwell et al. 2012 (`10.1093/jpe/rtr044`).

Each item is checked by DOI before it is filed. Anything paywalled is noted, not chased.

The indented items were added on 2026-11-15, each resolved against Crossref that day. They are the sources that a fit's diagnostics and its known failures rest on: goodness of fit, closure, low detection, unequal catchability, and a richness estimate that is a lower bound. Models for single-season occupancy, multi-scale occupancy, removal, activity overlap and richness are being tested against simulated surveys, and their documentation is checked against this store once it holds these.



## Exploration (2026-11-16, immutable read of the local zotero.sqlite)

- Group library: `statistics` (LP4R4VYR) has two subcollections, `survey_design` (Z7JP8UN2, 11 items, 0 PDFs, filed 2026-11-11/12) and `model_selection` (K2P7XGFG, 5 items, 4 PDFs, filed 2026-10-20). Neither is in any store.
- MacKenzie & Royle 2005 (CC22PHBQ) and Guillera-Arroita et al. 2010 (BC9RR2NP) sit in `survey_design`, no PDF.
- No other named author (Royle, Kéry, Zippin, Carle, Dorazio, Chao, Rowcliffe, Hedger, Tyre, Rota, Moran, Ridout, Colwell) has a matching work in any local library.
- `~/Downloads` is unreadable by the agent process (probed 2026-11-16): browser downloads need a copy by Al.

## Errors Encountered

| Error | Resolution |
|-------|------------|
