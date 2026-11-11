# Findings — Westslope cutthroat store (#190)

## Issue context

**What changes if we do it:** the westslope cutthroat management and recovery documents and the East Kootenay monitoring reports can be searched in one store and quoted verbatim, for habitat, floodplain and restoration-effectiveness work in the Kootenay and the Elk. **If we never do:** that reading is done one PDF at a time, and quotes from it go unchecked against their source.

## Problem

Measured 2026-11-10 (an `immutable` read of the local Zotero database): group collection `species/westslope_cutthroat` (`TIDR3PNN`) holds 30 items, 9 of them with a PDF. It is in no store; `habitat_modelling`'s build list does not include it.

- Without a PDF: the 2014 BC management plan, the 2017 COSEWIC assessment and status report, the 2008 East Kootenay abundance monitoring of classified waters, the Upper Fording River assessments (2016, 2017), the 2020 evaluation of hybridization in the upper Kootenay, and the Elk River WCT Research Initiative's 2019 report.
- Not in the collection, to search for: the federal management plan for the BC population and any progress report on it, the provincial plan's progress reporting, and recent Elk and Kootenay monitoring and restoration reports where they are public.
- The Environmental Damages Fund's Elk Valley (Qukin ʔamakʔis) projects: the call and applicant guides, and the plans, monitoring and final reports of funded projects where they are public. ECCC administers the fund and Ktunaxa Nation Council reviews the competitive call with it; what each project reports, and against what baseline, is part of what the store should let us read.

## Plan

The same steps as the sturgeon store (#124).

- [ ] Gather PDFs for the members without one, and write `data/westslope_cutthroat_members.csv` and `data/westslope_cutthroat_additions.csv`
- [ ] Search for the absent documents above and file what is found into the collection, the EDF Elk Valley documents included (ECCC's Elk Valley funds page and applicant guides, KNC's EDF newsletters, and any project reports they link)
- [ ] Build and push: `ACTION=build STORE=westslope_cutthroat COLLECTIONS=TIDR3PNN`, then `ACTION=push`, with the line in `scripts/README.md`
- [ ] Smoke-test four queries (thermal limits, hybridization with rainbow trout in the upper Kootenay, restoration effectiveness in the Elk, monitoring required of EDF-funded projects) and record each one's top citation keys in the build log
- [ ] List what has no PDF anywhere, so the gap is on record

Out of scope: threshold tuning; the WCT rearing curve is #186.

Relates to #124.


## Exploration (2026-11-10, immutable read of the local zotero.sqlite)

- `TIDR3PNN` (`westslope_cutthroat`, under `species` `9U54XAND`, library 9): 30 items, 9 with a live PDF child,
  all 30 with a Better BibTeX key. The `-wal` was 2.1 MB, so this misses unflushed commits; re-measured in Phase 1.
- 21 without a PDF: the 7 the issue names, plus journal articles (Brown & Mackay 1995, Brown 1998, Boyer et al. 2008,
  Muhlfeld et al. 2012, 2016, Pierce et al. 2014, Janowicz et al. 2018, Blank et al. 2020), D'Angelo & Muhlfeld 2011,
  Taylor & Mochnacz 2013 (Banff protocol), Mayhood 2014 and 2019, Blackburn 2017, and the BC Species and Ecosystems
  Explorer page.
- One key has no author stem: `WESTSLOPECUTTHROATTROUTOncorhynchusclarkilewisi2004` (keys never move; kept).
- cred 0.7.0 / ragnar 0.3.1 installed; cred#45 (immutable reads) open.
- Auto mode refused #124's Web API merge (#172 plan), so the live `0270` run and the push wait for Al.

## Errors Encountered

| Error | Resolution |
|-------|------------|
