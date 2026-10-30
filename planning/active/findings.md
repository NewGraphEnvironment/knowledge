# Findings — Arctic grayling and bull trout store: clean the two species collections, build it, and add grayling to habitat_modelling (#122)

## Issue context

**What changes if we do it:** the Arctic grayling and bull trout literature can be searched in one store, and the `habitat_modelling` store sees grayling, so habitat modelling for both species draws on the full syntheses. **If we never do:** a search misses most of the bull trout literature, the 2019 bull trout synthesis among it, and grayling stays out of the modelling evidence.

## Problem

Measured 2026-10-30 in the group library:

- `species/grayling`: 19 of 30 items carry a PDF. FWCP's 2026 Upper Peace synthesis (Hagen et al.) and its summary were added that day with their PDFs.
- `species/bull_trout`: 6 of 18 items carry a PDF, and several have no Better BibTeX key. They include both copies of Hagen and Weber (2019), the Williston bull trout synthesis. Its keyed copies, under `hagen_weber2019Limitingfactors`, sit in other collections, and they are two items sharing one key.
- `0150 build` drops an item with no key or no PDF without saying so, so a store built today would leave out the bull trout synthesis.
- The recorded `habitat_modelling` build takes `bull_trout`, `chinook`, `species` and others, but not `grayling`.
- CLAUDE.md says `0150 ACTION=query` is broken until cred is fixed. NewGraphEnvironment/cred#27 was fixed on 2026-09-04, and under cred 0.4.0 `ACTION=query STORE=peace` returns hybrid results.

## Proposed Solution

1. Clean the two collections: attach a PDF wherever one is available, merge the duplicate Hagen and Weber items so one keyed copy with its PDF sits in `bull_trout`, and confirm the new grayling items have keys.
2. Build one store from both collections, then push it. One store, because questions about the Williston and Peace basins usually span both species.
3. Rebuild `habitat_modelling` with `grayling` added, then push it.
4. Correct the CLAUDE.md note on `ACTION=query`, and say that it needs cred 0.4.0 or later.

Relates to #14 (keying the corpus on stable Zotero identity), which this does not wait on.


## Exploration (2026-10-30, guarded copy of `zotero.sqlite`)

Collections (group 4733734): `species` 9U54XAND (under Fisheries TRXPJHQE); `bull_trout` VHWEK6RE; `grayling` GELFSUTU;
`chinook` RXNFPBPH; `habitat_modelling` U9ZCZ6RN; `temperature` SW2RXUJC; `wedzin_kwa_chinook` DQP29KU7; `hydrology`
X29BX4U8; `salmon` W4425VK5 (species) and 545K8HP4 (aquatic).

- Live (not trashed) membership: bull_trout 15 items, 6 with a PDF; grayling 27, 19 with a PDF. The issue's 18 and 30
  include trashed items.
- Hagen & Weber (2019): the bull_trout copies `ITH37Y53` and `WH4T2SLW` (no key) have been in the trash since
  2026-06-13; keyed `PT7KYXRX` (no PDF) was trashed 2026-10-30 16:49, a merge into `YC3EQ8T8`
  (`hagen_weber2019Limitingfactors`, PDF `JQPBUZAS`), which sits in references, habitat_modelling, temperature and
  flow but not bull_trout.
- Beaudry 2014: grayling's `YQVI79FL` (`…c`) has no PDF; `IWJYZFS6` (`beaudry2014Assessmentassignment`, in `parsnip`)
  has one; `TUPPMGTM` (`…d`, references) none.
- Standalone PDFs (no parent, so no key): `NNS8U574` McPherson 2020 MSc (U Alberta, Little Nahanni grayling habitat),
  `GGDPSJFE` House 2021 MSc (TRU, grayling spawning behaviour), `QPMK23EN` Tack, ADF&G annual performance report
  (grayling migrations, interior and Arctic Alaska), `P3TMRWQX` Gill 2006 bull trout guide (Forsite). `KXDGTBTA` is an
  empty, keyless parent titled `bulltroutguide.pdf` in no collection.
- No-PDF members with a public PDF URL on the item: COSEWIC 2012 (publications.gc.ca), Cannings & Ptolemy 1998
  (for.gov.bc.ca), NW Council brochure, Metolius migration report (ODFW), Whyte et al. 1997 (for.gov.bc.ca), Finlay
  genetics 2012 (ACAT), Carr et al. 2020 (PMC). Web pages: species registry, BC species explorer (two).

### cred's PDF pick (cred 0.4.0 = latest tag; `main` has no `R/` change since; `R/zotero.R:73`, `:85` on main)

`crd_zot_src_lookup()` selects attachments by citation key with no library and no trash filter, ordered
`ia.itemID DESC`, then keeps the first row per key:

| key | picks | should pick |
|---|---|---|
| `hagen_etal2019TrendAbundance` | personal library `4HQRGIK4` (itemID 4064) | group `78C3PSF7` (3702); same size, 1,463,342 B |
| `martins_etal2022SpatialEcology` | trashed `HKTCPDVJ` (4697) | live `KZU26QII` (3496); same size, 13,918,311 B |
| `bottoms_etal2023Criticalhabitats` | Appendix 1 `YJZLRJ5I` (4689), 11.4 MB | the report `EPPHL4VG` (4687), 3.4 MB |

`crd_store_build()` 0.4.0 calls `ragnar::ragnar_store_ingest(store, src$src_path, progress = TRUE)` with default
chunking, so cred#35 still applies. ragnar: 0.3.0 installed from CRAN, 0.3.1 on CRAN (ingest moved to mirai's new
`race_mirai()` API), 0.3.1.9000 on GitHub `main`.

## Errors Encountered

| Error | Resolution |
|-------|------------|
