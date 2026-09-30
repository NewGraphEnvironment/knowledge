# Findings — Habitat-thresholds literature store and evidence table (CH, BT first) (#19)

## Issue context

**If we do it:** each gradient, channel-width, discharge and timing cutoff for CH and BT carries a citation and a quote. **If we never do:** the thresholds stay inherited bcfishpass values with no recorded basis, and a tuned value can't be defended except by fit to observations.

## Problem

Habitat thresholds for CH and BT (spawn/rear gradient max, channel width min, MAD, lake/wetland sizes, rearing-to-spawning connection distance) are copied from bcfishpass. Nothing records why each value is what it is. link's research on the evidence for departures (NewGraphEnvironment/link#20) proposes a Zotero + ragnar workflow but has not built one; NewGraphEnvironment/link#2 is a separate store about passage, not habitat.

## Starting material (not comprehensive; needs a lot of work)

- **fish_passage_template_reporting**, `data/inputs_raw/bcfishpass_spawn_rear_model_ref.csv`: cited ranges for spawn/rear gradient max and channel width min/max, for CH, CO, ST and SK. It has **no BT row**. CH examples: spawn gradient 0.03 (Kirsch et al. 2004; Busch et al. 2011; Cooney & Holzer 2006), spawn width ≥ 3.7 m, rear gradient 0.05 (Woll et al. 2017; Porter et al. 2008), rear width ≤ 15 m. These are tighter than the bcfishpass values currently modelled (spawn 0.0449, rear 0.0549).
- Same repo, `0300-methods.Rmd` "Habitat Modelling": the threshold tables and the commented-out references table (`tab-fish-spawning-rearing-references`, `eval = F`), with a note that ST rearing was moved to 8.5 % on professional judgment against a referenced 7.49 %. Also cites channel-width work (Thorley et al. 2021; Thorley & Irvine 2021; Finnegan et al. 2005) and stream temperature (Hill et al. 2024, 2025).
- **Zotero group library** collections, with item counts as of 2026-09-25: `species/chinook` (24), `species/bull_trout` (18), `Fisheries/species` (15), `species/salmon` (9), `Fisheries/temperature` (22), `hydrology` (41 across two collections), `skeena/wedzin_kwa_chinook` (131). Seed the store from these, then fill the gaps: BT habitat use by life-history form, ocean- vs stream-type CH, and anything with measured gradient/width at use sites.

## Proposed Solution

1. A Zotero collection in the group library (seeded from the collections above) for habitat use by life stage: gradient, channel width/stream size, discharge, substrate, thermal limits and life-cycle timing. Start with CH (stream- and ocean-type) and BT (resident, fluvial, adfluvial).
2. A ragnar store `habitat_thresholds` built with `crd_store_build()` and pushed to `s3://fresh-bc/rag/`.
3. An evidence table in `data/`, starting from the template CSV rows and adding a BT row: species, life stage, life-history form, variable, value or range, region, citation key, page, quote.
4. Include life-cycle timing (spawn, incubation, emergence and outmigration windows by region), because tying habitat to seasonal discharge needs it. The timing table itself (start/end windows per watershed group, species and life stage, seeded from the template's Gantt CSV) is #25. This store supplies its citations.

Link the table to link's CH/BT threshold research as an input.

Relates to NewGraphEnvironment/link#284, NewGraphEnvironment/link#20



## Context

The CH and BT habitat thresholds (gradient, channel width, MAD, lake/wetland size, the rearing bridge) are inherited
from bcfishpass, and nothing records the basis for each value. The issue asks for four things:
- a Zotero collection;
- a ragnar store;
- a cited evidence table in `data/`;
- timing citations for #25's table.

**link#284 has already reviewed the literature on CH and BT gradient and channel width.** The issue body says link
has no literature workflow yet, but that is no longer true. The review is at
`link/planning/archive/2026-09-issue-284-ch-bt-habitat-thresholds/literature.md`: ~60 rows, each with a Zotero key,
page, quote and "kind" (param / HSI / max-obs / dist / pref / expert / qual). It already found three things:
- the template CSV's "5 %" (Porter 2008) is not in Porter;
- the 1.5 m rearing widths and the 10 km / 5 % bridge have no literature origin;
- bcfishpass cites no source for BT.

That file is the main seed. The template CSV is secondary: it has prose citations, no keys and no BT row.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Timing table cites a key that resolves nowhere (2026-09-29)

`data/life_history_timing.csv` cites `officeofthewetsuweten2013Wetsuwet`, but no library on m1 has that
citation key. The candidates in the group library are `officeofthewetsuweten2013WetsuwetenTitle` (title and
rights, DFO) and `officeofthewetsuweten_etal2013Moricefish` (Morice fish). The row it sources is a Morice
row, so the second is the likely one. It is settled by reading the source in Phase 4.

## Curated member list

`data/habitat_modelling_members.csv` has 74 keys:
- the personal `habitat_modelling` collection (35);
- link#284's literature review;
- the timing sources;
- 20 items from the group-library title search.

Three are not in the group library and are copied in by `0270`: agrawal_etal (library 6), beamer_etal2013
(library 1) and shallinbusch_etal2013 (library 6). `cooney_holzerAppendixInterior`
(library 6) duplicates `cooney_holzer2006AppendixInterior` and was dropped.

## Code-check round 1 on Phase 1 (2026-09-29)

Four fixes came out of this round:
- **Non-UTF-8 input.** `read.csv(fileEncoding = "UTF-8-BOM")` stops at the first byte that is not UTF-8 and only
  warns. A cp1252 degree sign therefore returned a truncated table, and that table then passed validation.
  `knw_timing_read()` had the same bug. Both readers now go through `.knw_read_csv()`, which refuses a file that
  is not UTF-8.
- **`none` rows.** A `none` row that carries a key or a quote is now refused.
- **Error positions.** Errors now give the file line as well as the data row.
- **Trashed collections.** `0150` now skips collections in the Zotero trash.

The round also showed that `JI7EBZNF` (`aquatic/hydrology`) holds only standalone attachments, so it has no
keyed items. It was dropped from the Phase 3 build list, because `collection_keys()` refuses a collection with no
keyed PDFs.

## Code-check round 2 on Phase 1: a defect inside round 1's fix, closed by enumeration

Round 2 found that round 1's "file line N+1" was wrong whenever blank lines sat above the row, because
`read.csv()` skips them. The claim was dropped rather than computed; errors name the data row only.

Everything else held. `.knw_read_csv()` matched the old reader on all of these:
- BOM;
- CRLF and CR line endings;
- line breaks inside quoted fields;
- no trailing newline;
- a header-only file;
- a BOM-only file;
- non-ASCII text.

The real timing table reads `identical` through the old and new paths.

**How the loop ended.** Once a round had found a defect inside a fix, it could end only on an enumeration. All
23 `stop()` calls in `read.R`, `literature.R` and `timing.R` were walked from the parse data:
- 11 report a position, and all 11 go through `first()`, which states only `which()`'s data row;
- none of the others claims a line.

CSV readers in `pkg/`: `.knw_read_csv()` has 2 callers and nothing else reads a CSV. `scripts/0260` still reads
its template CSV the old way. That code predates this change and is not in this diff. The file is all ASCII
today, and `0260` is not re-run once the table has been hand-edited.
