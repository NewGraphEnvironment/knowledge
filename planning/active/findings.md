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
