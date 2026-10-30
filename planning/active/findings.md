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
  (grayling migrations, interior and Arctic Alaska), `P3TMRWQX` Gill 2006 bull trout guide (Forsite). **Corrected by the
  plan review:** Gill already has a keyed parent, `8B95AXD2` `gill2006Bulltrout` (from
  `habitat_modelling_additions.csv` row 9, `zotero:P3TMRWQX`), whose stored PDF is `KXDGTBTA`; I misread that attachment
  as an empty parent. So three standalones need a parent, all in grayling.
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

## Today's merge re-keyed Hagen & Weber (2019)

The keyed survivor `YC3EQ8T8` carried `hagen_weber2019Limitingfactorsa` while `PT7KYXRX` held the unsuffixed key; with
`PT7KYXRX` merged into it and trashed, Better BibTeX re-derived the survivor as `hagen_weber2019Limitingfactors`
(both now read that key in the local database). The repo cites the old key in 22 rows of `literature_evidence.csv`
and in `habitat_modelling_members.csv`, `temperature_members.csv` and `flow_members.csv`; `0270 --dry-run` reports it
`MISSING` (identically before and after Phase 1's change). No vignette, `research/` or `R/` file cites it.

## Plan review (Plan agent, 2026-10-30; full text in `review-plan.md`)

Taken: Gill is a member, not an addition (verified: `KXDGTBTA`'s parent is `8B95AXD2`, `gill2006Bulltrout`); a
`--parent` guard against a second collection (done in Phase 1); check every `exists` gkey before the live run;
`0150`'s left-out report is unconditional, because 0150 passes keys and cred never sees a keyless member; ragnar moves
with the cred tag; Phase 6 lands now; Phase 5 diffs document origins against the pulled store; `test-data-dir.R`
does not cover CSVs, so that claim is dropped. Noted: `0270` tags created items with the collection name, beside the
human tags `Arctic grayling` / `bull trout`; no script reads Zotero tags. Unpinned auto keys (`App78_…`,
`selong_etal…`, the Metolius key) change if their metadata is edited: Phase 2 edits no metadata.

## Phase 2: the cleanup (2026-10-30)

`0270 --collection bull_trout|grayling --parent 9U54XAND` live at 22:27 UTC, then a second dry run of each with no
`would` step (exit 0).

- bull_trout: added `hagen_weber2019Limitingfactors` (`YC3EQ8T8`) and `gill2006Bulltrout` (`8B95AXD2`); uploaded
  Cannings & Ptolemy 1998 (BC forests library) and the NW Council brochure.
- grayling: added `beaudry2014Assessmentassignment` (`IWJYZFS6`); uploaded the Finlay genetics report (ACAT) and
  Whyte et al. 1997, chapter 5 only: pp. 81-93 of `Slaney_PA1997_A.pdf` (the item's URL, 313 pp., chapters 1-15 of the
  book), cut with qpdf to `data/rag/pdf/grayling/whyte_etal1997_ch5.pdf` (ignored). Created parents for the three
  standalones: `mcpherson2020Habitatuse` (`BQKF3I37`), `house2021Interdisciplinaryapproaches` (`VGBXX55C`),
  `tack1980Migrationsdistributions` (`B27KD9SC`; ADF&G F-9-12, vol. 21, study R-I, the 1971-1980 completion report).
  The standalones stay in the collection, as 0270 leaves them.
- Out of grayling by collection PATCH (204), not trashed: `YQVI79FL` (Beaudry 2014 without its PDF; now in no
  collection) and `WVTFGPUT` (`fishandwildlifecompensationprogram2017ArcticGrayling`, imported 2026-07-11: the same FWCP
  2017 synthesis as `stamford_etal2017FWCPArctic`, same title, authors, 148 pp. and creation date; still in `B5XW948R`).
  Neither key is cited in the repo. Both are library-level duplicates a Zotero merge could fold.

| | items (not standalones) | keyed | keyed, PDF on disk |
|---|---|---|---|
| bull_trout before | 15 | 15 | 6 |
| bull_trout after | 16 | 16 | 10 |
| grayling before | 24 | 24 | 19 |
| grayling after | 24 | 24 | 22 |

Still without a PDF, and why: COSEWIC 2012 (publications.gc.ca answers a scripted request with 202/HTML; canada.ca has
it as HTML chapters) and Carr et al. 2020 (PMC and the publisher 403): browser, with Al. The Metolius adult migration
report: the item's ODFW URL is 404 and no other copy found. McMahon et al. 2007: paywalled; Unpaywall's "open" copy is an
Intermountain Journal of Sciences conference abstract, not the paper. Williamson & Zimmerman 2005: no copy found; ACAT's
PWFWCP report 337 is Ballard & Shrimpton (2009), an Omineca grayling synopsis, a candidate addition. Three web pages
(species registry, BC species explorer twice).

## Phase 3: `0150` names what a build leaves out

`collection_keys()` lists every live, non-note member it does not hand cred: no citation key, no live PDF, or a
standalone PDF whose `storageHash` no live PDF of a keyed item in the library shares (0270's parents carry the
standalone's bytes, so their hashes pair). Measured 2026-10-30 from the local database:

- `VHWEK6RE,GELFSUTU`: 32 keys; 8 of 44 members left out, all `no live PDF` (the misses above). The four
  standalones are covered and not listed. Mutation: with the covered check replaced by an empty set, the four appear.
- The `habitat_modelling` set (10 collections, grayling added): 260 keys; 88 of 353 members left out, 82 with no live
  PDF and 6 standalone PDFs no keyed item holds.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `habitat_modelling_members.csv` rewritten whole (CRLF lost) by a text-mode replace | Byte-level replace (`rb`/`wb`) |
| `sed -i` failed (`extra characters at the end of p command`): the shell's `sed` is BSD, and `-i` takes a suffix; a later `sed -i ''` ran but missed a CSV-quoted field | Edit planning files and CSVs with Python (csv module for CSVs) |
