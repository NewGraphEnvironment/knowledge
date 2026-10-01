# Findings — Intrinsic-potential model registry from the PNW literature, to seed every species' thresholds (#29)

## Issue context

**If we do it:** every species we classify next (coho, steelhead, sockeye, rainbow, westslope cutthroat, grayling) starts from the models Washington, Oregon, California, Idaho and Alaska already built: their variables, thresholds, flow metric and whether they were validated. It also answers whether others needed modelled discharge or got by on a width or drainage-area surrogate. **If we never do:** each species is reviewed from scratch, and we decide whether to build discharge for the Skeena and coast without knowing what the field settled on.

## Problem

CH and BT thresholds now have a gated evidence table (#19). The rest of the species do not. The Pacific Northwest has about 25 years of intrinsic-potential (IP) modelling that defines species × life-stage suitability on gradient, flow or width, and valley confinement. Sheer et al. 2009 (*State of the IP 2008*, in the group library) synthesizes it. Burnett et al. 2007, the original Oregon coast coho/steelhead IP model, is in a dormant library only (#13). Rebellato et al. 2024 is a thin BC descendant of this line. Its channel widths are a discharge surrogate built on our width model.

Modelled MAD covers 104 of 246 watershed groups (the Fraser, Columbia and Peace), and none of the Skeena, Nass, Stikine or coast. Upstream precipitation, the width model's input, covers 89–95 % everywhere. Which flow representation other IP models used is therefore the question that decides our discharge work.

## Proposed Solution

1. **Collect.** Bring Sheer 2009's covered models into `Fisheries/habitat_modelling`:
   - Burnett 2007, Agrawal 2005, Busch, Cooney & Holzer, Woll, and NetMap/CLAMS where it applies;
   - the state agency IP layers (ODFW, WDFW, NOAA NWFSC, CDFW).

   Search the group library first, then the dormant libraries (#13), then the web. Rebuild and push the store.
2. **Registry.** Write `data/ip_model_registry.csv`, one row per model × species × life stage, with these columns:
   - region;
   - variables used;
   - thresholds or curve breakpoints;
   - flow metric (MAD, summer low flow, bankfull width, drainage area) and how it was obtained (gauged, modelled or surrogate);
   - valley confinement;
   - validation (none, observations, redd surveys) and its result;
   - citation key and page.

   Gated against the PDFs, like the evidence table.
3. **Seed species.** Port each model's thresholds into `data/literature_evidence.csv` rows for CO and ST first (both in Rebellato with MAD values, and the core of the Oregon and California models), extending `0280`'s coverage list to those species.
4. **Flow finding.** A section in `research/habitat_literature.md` (or a new `research/ip_models.md`) on how the PNW handled flow, written as the input to the width-vs-MAD decision (link#286).

Relates to #19, #13, #28, NewGraphEnvironment/link#286


## Errors Encountered

| Error | Resolution |
|-------|------------|
