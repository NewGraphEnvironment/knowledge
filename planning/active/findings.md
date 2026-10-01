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


## Plan review (2026-10-01)

`review-plan.md`. Every finding was checked before acting on it:
- **B3 confirmed.** `shallinbusch_etal2013…` (library 6) carries the same DOI as the group's
  `busch_etal2011LandscapeLevelModel`.
- **B1 and B2 were already avoided** in the working tree before the review landed.
- **G2, G3, G4, G8 and G11 changed the schema or the code** (see `task_plan.md`).

## Tagging rule for `model_id` (review G7)

Tag a row only when it states a value or variable the model itself uses: `param`, `hsi`, `expert`, or a
`qual` row naming one of the model's variables. Do not tag:
- data summaries (`dist`, `max_obs`), for example Cooney & Holzer's density distribution (row 18);
- literature the model cites but did not adopt, for example WDFW's 16 % in Rebellato (row 8).

The join is on `model_id` × species × life stage, ignoring life-history form. An access threshold needs
an `access` registry row.

## Seed models: how they size streams (verified quotes)

- **Rebellato 2024 p. 5.** "Modelled discharge was available for watersheds in the Fraser Basin … Modelled
  channel width was used for the remainder of the study area as a surrogate for discharge". Not validated
  (p. 14).
- **Cooney & Holzer 2006 C-7.** "Stream width is predominantly a function of stream discharge, which can
  be estimated from a combination of drainage area and precipitation". Their widths come from a regression
  of field widths on upstream drainage area and accumulated mean annual precipitation: wetted width for CH,
  bankfull for ST. That is the same construction as our width model (Thorley et al. 2021). Validation
  (C-3): results were "Compared … against specific measures of relative abundance of spawning adults". Redd
  counts were used to set minimum widths, which is calibration, not validation (C-6).

## Phase 2: candidates (Sheer 2009 Table A1, pp. 33-34, plus post-2009 work)

| Model / work | Status before | Action | Group key after |
|---|---|---|---|
| Burnett 2007 (CLAMS, CO/ST) | library 6 only | copied by `0270` members | `burnett_etal2007DISTRIBUTIONSALMONHABITAT` (Q5393JVX) |
| Burnett 2003 (CLAMS protected areas) | none | **skipped**: conference chapter, no PDF found on treesearch or the web; Burnett 2007 is the same model | - |
| Agrawal 2005 (SWFSC-379) | group, PDF | already a member | `agrawal_etalPREDICTINGPOTENTIAL` |
| Bjorkstedt 2005 (SWFSC-382) | none | web (SWFSC storage; repository.library.noaa.gov returns 403 to curl) | `bjorkstedt_etal2005analysishistorical` (JGWC6RCK) |
| Lindley 2006 (Central Valley ST) | none | web, DOI 10.15447/sfews.2006v4iss1art3, PDF from CDFW | `lindley_etal2006HistoricalPopulation` (WUJDKFCC) |
| Boughton & Goslin 2006 (SWFSC-391) | none | web (SWFSC storage) | `boughton_goslin2006Potentialsteelhead` (XPR8CJ7K) |
| Cooney & Holzer 2006 (ICTRT) | group, PDF | member | `cooney_holzer2006AppendixInterior` |
| Busch 2011 / "2013" | group, PDF | member; library 6's 2013 item is the same DOI (review B3) | `busch_etal2011LandscapeLevelModel` |
| Woll 2015, 2017 (Mat-Su) | group, PDF | members | as before |
| Bidlack 2014 (Copper River CH) | group, links only, no PDF in any library | **skipped**: no local PDF; not chased | - |
| Holzer (ICTRT web page) | group, HTML snapshot | **skipped**: Cooney & Holzer appendix C carries the method | - |
| BLM 2008 WOPR, ODFW coastal coho, NOAA Lower Columbia/Willamette/Puget Sound IP | no standalone document | covered through Sheer 2009 appendices C-E (`cited_source`) | - |
| ODFW IP methods (`ODFW_841_3_ipmethods_v2.doc`) | none | **skipped**: a .doc, and 0270 accepts PDFs only; it documents the Burnett method | - |
| NOAA NWFSC-128 (Myers 2015, Puget Sound ST populations) | none | **skipped**: IP used at basin scale for population delineation (80 km2 basin size), not reach thresholds | - |
| NetMap (Benda 2007), Zimmerman & Reeves 2000, Mills 2008 | none | **skipped**: a tool, a life-history paper, a thesis-level IP-like model (review S1) | - |
| Agency layers (ODFW, WDFW, NOAA NWFSC, CDFW) | - | **not documents**: PSMFC's StreamNet holds the ICTRT layer (sddt.psmfc.org dataset 24, method = Cooney & Holzer); the ODFW layer is Burnett's model; CDFW and NOAA SWFSC layers are Agrawal's | - |

`0270` live (log `scripts/logs/habitat/20261001_habitat_collection_build.txt`):
- copied 1, created 3, collection now 92 members (77 with PDF);
- every new item synced with a BBT key and a PDF on disk within about 2 minutes, with no Zotero restart.

## Machine notes

- `pgrep -l Zotero` misses the process (it is named `zotero`), so use `pgrep -il zotero`.
- About 35 `zotero-mcp` processes are running on m1, left over from earlier sessions. Not touched.
- A zeroed `zotero.sqlite-journal` sits beside the database between transactions (persistent journal).
  0280's snapshot rule (a zeroed header means no open transaction) handles it; a bare "journal exists"
  check refuses every copy.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| Scratch `keytext.py`: "no consistent snapshot" on every try | Zotero keeps a zeroed persistent journal; test the header bytes, as 0280 does, not the file's existence |
