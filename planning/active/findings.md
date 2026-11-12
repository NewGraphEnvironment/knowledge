# Findings — Bull trout: build a store, research its life history, and find the datasets (#194)

## Issue context

**What changes if we do it:** bull trout gets the same footing as cutthroat and sturgeon: one store holding the recovery and management documents and the monitoring reports, quotable verbatim, plus a record of its life history forms and of which datasets exist, who holds them and whether they're open. That feeds the habitat definitions (spawning and rearing) and species-at-risk work on both listed units. **If we never do:** each proposal and each tuning pass reads bull trout one PDF at a time. Life history gets restated from memory, and datasets we never looked for stay unused.

## Problem

Measured 2026-11-11 by a read-only query of the local Zotero database:
- The group collection `species/bull_trout` (`VHWEK6RE`) holds 20 items, 11 of them with a PDF.
- It is in no store. The local stores are flow, fraser, habitat_modelling, peace, pine, sturgeon and temperature.

Bull trout already shows up in several places:
- Its spawning evidence is #33 and `research/bt_spawning.md`.
- Its age-0 growth is part of #51.
- Two bull trout units are listed under SARA: South Coast and Western Arctic, both Special Concern. Their management plans have not been read here.
- #33's literature track names the Hagen redd-count and critical-habitat series, Baxter's spawning-site work, and the US redd-survey and critical-habitat literature as under-read or missing.

## Proposed Solution

1. **Gather and build the store.** Bring every member of the collection up to a PDF. Then add:
   - the federal management plans for both units, and their COSEWIC assessments;
   - provincial status and management documents;
   - the Hagen Williston series and Baxter's work;
   - FWCP Peace and Columbia bull trout reports;
   - Kootenay and Arrow Lakes monitoring.

   Then build the `bull_trout` store and push it, as for #190.
2. **Life history.** One `research/` file covering:
   - forms: resident, fluvial and adfluvial;
   - migration and spawning timing;
   - redd and spawning-site selection;
   - thermal limits;
   - juvenile rearing;
   - how the forms are split across BC.

   Every claim is quoted from the store with its citation key.
3. **The dataset hunt.** A table of every bull trout dataset found, with who holds it, where it is, its years, whether it's open, and its format. Candidates:
   - redd counts and critical spawning segments (including the Williston layer still pending in #33);
   - telemetry and migration studies;
   - FWCP and HCTF project data;
   - provincial monitoring;
   - US datasets across the border.

   Include what is known to exist but couldn't be found.

Relates to #33 and #51.

## Exploration at the gate (2026-11-12)

- The issue's premise "It is in no store" is wrong in part. `bull_trout_grayling` (#122) is built from
  `VHWEK6RE,GELFSUTU`: 36 documents, 99,627,008 bytes in `s3://fresh-bc/rag/`, last pushed 2026-11-10.
  `habitat_modelling`'s build list (`scripts/README.md`) includes `VHWEK6RE`.
- After #122, `species/bull_trout` held 16 live items, 11 with a PDF (`planning/archive/2026-10-issue-122-*`). The
  issue measured 20 and 11 on 2026-11-11; Phase 1 re-measures.
- `data/bull_trout_members.csv` exists with 16 rows from #122. There is no additions file yet. `0270` reads
  `data/<collection>_additions.csv` when it exists (`scripts/0270-habitat-collection-build.py:510`).
- Nothing in the repo reads `bull_trout_grayling` other than its build line and CLAUDE.md's layout entry.
- #33 (open) lists as under-read or missing: Baxter & Hauer 2000, Baxter & McPhail 1999, the Hagen series, Fraley &
  Shepard 1989, Montana FWP redd counts, and the USFWS recovery plan and critical habitat documents.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Re-measure from a guarded copy (2026-11-12 07:20 UTC)

`0270`'s `db()` (main file plus `-wal`, guarded; the `-wal` was 2.45 MB), then `local_pdf()` per item (scratchpad
`bt_measure.py`): **16 live items, 16 keyed, 11 with the PDF on disk**, the same as #122's outcome. The issue's 20
probably counted trashed items, as #122's first counts did. The five without a PDF are #122's remaining misses:
- three web pages (`speciesregistrycanada2020BullTrout`, `bcspeciesecosystemexplorer2020Salvelinusconfluentus`,
  `bcspecies&ecosystemexplorer2020Salvelinusconfluentusa`);
- `mcmahon_etal2007TemperatureCompetition` (paywalled);
- the Metolius migration report (`MigrationPatternsAdultBullTroutMetoliusRiverLakeBillyChinookOregon`; its ODFW URL
  was 404).

## Group items about bull trout outside `VHWEK6RE` (guarded copy, 2026-11-12 07:25 UTC)

Scratchpad `bt_group_scan.py`: every group item whose title names bull trout or *Salvelinus confluentus*. These are
live, hold a PDF on disk, and are filed only in other collections, so they become **member rows**:
- US core, already in the group: `u_s_fishandwildlifeservice2010Endangeredthreatened` (the 2010 critical habitat
  rule) and `u_s_fishandwildlifeservice2015Recoveryplan`.
- Williston: `hagenj_spendlowi_2019BullTrout` (2018 redd counts) and `hagen_etal2015Criticalhabitats` (Parsnip and
  Pack).
- Kootenay and Columbia: `cope_morris2001WigwamRiver` and `obrien1999Duncanbull`.
- Reviews and models:
  - `mcphail_baxter1996reviewbull`;
  - `rieman_mcintyre1993Demographichabitat`;
  - `dunham_chandler2001Modelspredict`;
  - `mochnacz2021Thermalecology`;
  - `macpherson_etal2024Prioritizingbull`;
  - `RockyCreekbulltroutcumulativeeffectsmodelthreatsummary`;
  - `dangelo_muhlfeld2011FactorsInfluencing`;
  - `muhlfeld_etal2012ASSESSINGIMPACTS`.

Live but with no PDF, and not taken as members:
- Duplicate items of members already held: `cosewic2012COSEWICassessment`,
  `comitteeonthestatusofendangeredwildlifeincanada2012COSEWICassessment`, `hagen_etal2015Criticalhabitatsa`,
  `hagen_etal2020CriticalSpawninga`, `speciesregistrycanada2020BullTrouta` and
  `bcspecies&ecosystemexplorer2020Salvelinusconfluentusb`. All six are in `references`. Merging duplicates is
  #126 and #151's work, not this branch's.
- `pearce_etal2019FirstNations` and `pearce2019FirstNations`, the Tse'khene First Nations information gathering on
  kokanee, bull trout and grayling. They are two items for perhaps one report, and a PDF is to be searched for.

Six trashed copies (Hagen & Weber 2019 ×3, COSEWIC 2012, Hagen et al. 2015, Pearce 2019) are trash; nothing is
restored from them.

## Search B: Williston and Peace (agent, verified here 2026-11-12)

Scratchpad `search_B/` (`candidates.tsv`, `notes.md`, `pdf/`). Each of the 12 kept files starts `%PDF` (59 KB to
4.6 MB):
- the BC Hydro Site C Mon-1b Task 2b "Peace River Bull Trout Spawning Assessment" series, 2016–2024 (11 reports, by
  InStream Fisheries Research for BC Hydro, from sitecproject.com);
- the 2008 Upper Halfway River bull trout spawning survey (Mainstream Aquatics).

**The Hagen series is blocked as the gate stands.** Every Hagen or FWCP Peace bull trout report found is served from
EcoCat (out at the gate) or from fwcp.ca, which answers 403 to scripted downloads, as bchydro.com does. Neither block
was worked around. Found to exist (titles from search snippets, not opened):
- O'Connor, Ferraro & Hagen 2024 (PEA-F24-F-3848, EcoCat r63074) and its 2025 edition (r63274);
- the 2019 aerial redd survey of 28 Williston tributaries (r58761);
- Peace Reach tributaries spawning (PEA-F25-F-3986);
- Andrusak et al. 2012, redd counts 2001–2010 (r38265);
- Langston & Cubberley 2008, Misinchinka telemetry (r40104);
- Langston 2008, Gething Creek (r40147);
- Hagen & Decker 2011, *The Status of Bull Trout in British Columbia* (r36019).

FWCP's Peace project report list (an `.xlsx` on fwcp.ca) needs a browser download; it would enumerate the series.
Held items: Hagen & Weber 2019 is on fwcp.ca (403) and EcoCat r57250. No URL was found for Hagen et al. 2020 or for
Hagen & Sary 2023, both of which already have a PDF here.

## Search C: Columbia, Kootenay and Arrow (agent, verified here 2026-11-12)

Scratchpad `search_C/`. 63 rows: 26 `pdf_ok` (each file starts `%PDF`, 58 MB in all), 36 `needs_browser`, 1
`paywalled`.

`pdf_ok`:
- 15 reports from BPA project 2000-004-00 on the upper Kootenay (Wigwam, Skookumchuck, the White River and its
  Middlefork; enumeration, juvenile monitoring, telemetry and McNeil substrate, 2001–2006), from OSTI and UNT;
- Kinbasket and Revelstoke: three papers (Aquatic Biology 2013, River Res. Appl. 2014, Can. J. Zool. 2016) and the
  Kinbasket telemetry thesis (2014);
- Kootenay Lake: the Action Plan (2016), the 2018 workshop summary, and three short bulletins;
- the 2015 Salmo scoping report, which has no title page;
- McPhail & Baxter 1996, already in the group.

Marginal by the agent's own call: the three bulletins, the McNeil substrate report, and Gutowsky et al. 2016
(watermarked "for personal use only").

`needs_browser`:
- 19 BC Hydro reports: DDMMON-5 (7), DDMMON-6 (3), CLBMON-6 (5) and SEVMON-2 (4);
- 11 Streamkeepers reports, held only by the Wayback Machine;
- two UBC theses;
- two Cloudflare-blocked papers;
- one ResearchGate item;
- one set of slides.

These rows carry no title or creators, because their title pages were not read.

FWCP Columbia bull trout reports are EcoCat only, the same block as search B's.
