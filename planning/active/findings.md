# Findings — Coho store: grow species/coho, build and push it, and judge the upper Fraser coho records with it (#284)

## Issue context

**If we do it:** coho literature can be searched like bull trout, sturgeon and cutthroat literature. Its first use is answering how far coho reach up the Fraser, and how far each upper Fraser record can be trusted. **If we never do:** the group library's coho papers stay out of every store, and questions about upper Fraser coho get answered by hand from whichever PDFs someone remembers.

## Where it stands (measured 2026-11-26)

- The group library has `species/coho` (`ZPUIT73I`, under `species`). It holds 16 live items, 15 with a PDF, among them:
  - the Interior Fraser coho conservation strategy (2007);
  - COSEWIC's 2017 assessment of the interior Fraser population;
  - the Interior Fraser coho status summary;
  - Blackwater species distribution models (2000);
  - Pacific Northwest habitat and movement papers.
- The item titled `Life-History-of-Coho-Salmon.pdf` has no PDF attached and is named after a file.
- No store is built from the collection, and it is not in `habitat_modelling`'s build list (`scripts/README.md`). Chinook's collection (`RXNFPBPH`) is in that list.

**The question this store would answer first.** The conservation strategy says coho are "known to occur as far upstream as the Nechako River". It adds that in several major upper Fraser watersheds their presence "is probable but has not been confirmed", and calls the lack of records there "a major knowledge gap". COSEWIC (2017) says coho "may also occur in tributaries upstream of the Nechako (e.g., Bowron River), but their presence has not been confirmed", citing Decker and Irvine (2013). Records north of about Quesnel's latitude in the Fraser drainage:

- **FDIS electrofishing (the published evidence):** coho were caught on 1 of 7,030 visits in 33 groups: one fish in Ahbau Creek (COTR) in 2014.
- **NuSEDS (`knowledge/nuseds/v1`):** three coho populations.
  - Ahbau Creek: 6 spawners in 2001.
  - West Road (Blackwater) River: 100 in 1996, present on a 1999 survey, none observed in 2001.
  - Nechako River: present in 2004, presence and absence only.
- **bcfishobs:** 36 coho records in 12 groups (BLAR, BOWR, CARR, CHES, COTR, FRAN, LCHL, NECR, QUES, STUL, STUR, WILL).
  - 23 are FISS entries from 1986 to 1998 dated to a year or month, with no life stage.
  - Five FISS entries from 2004, all dated 1 January (survey ids 7501690 to 7503426), place coho on the Bowron, Swift, Stuart, Nechako and Blackwater mainstems.
  - Ocock Lake (1976, lakes database) is placed 1.26 km from a stream.
  - Two 2018 FDIS collections record coho fry in FRAN, which the published FDIS evidence does not hold.
- **link's `default` coho range** takes in BOWR, WILL, NECR, LCHL and COTR, and leaves out STUR, STUL, FRAN, TABR, MORK, MCGR and UFRA.

## Plan

- [ ] Grow `species/coho` with `0270 --collection coho --parent 9U54XAND` (`data/coho_{members,additions}.csv`).
  - Add Decker and Irvine (2013) and DFO's stock assessment and recovery documents for Interior Fraser coho.
  - Add the sources the 2018 FRAN collections and the 2004 FISS entries came from, where they can be found.
  - Give the file-named item its PDF or remove it.
- [ ] Build `coho` from `species/coho` alone (`0150 ACTION=build STORE=coho COLLECTIONS=ZPUIT73I`), then push. Add its build line to `scripts/README.md` and its files to `CLAUDE.md`'s data list.
- [ ] Decide at the gate whether `ZPUIT73I` also joins `habitat_modelling`'s build list, as chinook's collection does.
- [ ] As the check, judge each upper Fraser coho record above by its source: which rest on a survey, which on a compilation, and which are doubtful. Say in `research/` how far up the Fraser coho are confirmed, and what that means for BOWR and WILL being in link's range.

Relates to #124 and #190 (the sturgeon and cutthroat stores this follows), #228 (salmon records per stream) and #285 (NuSEDS beside the Pacific Salmon Foundation's corrections, whose Fraser coho flags feed the check above).



## Errors Encountered

| Error | Resolution |
|-------|------------|

## `ZPUIT73I` before filing (2026-11-26, guarded copy through `0270`'s `db()`)

live 16, keyed 15, PDF on disk 15 (25.0 MB). The one unkeyed item is `49HFCT96`, a standalone attachment titled
`Life-History-of-Coho-Salmon.pdf` with no file. Members (citation keys): the IFC Recovery Team's 2007 conservation
strategy, `irvineInteriorFraser`, `ebersole_etal2006JuvenileCoho`, `porter_etal2000PredictiveModels`,
`schweigert_etal2017COSEWICassessmenta`, `reeves_etal1989Identificationphysical`, `sheffieldREARINGCOHO`,
`parkinson_etal2017EvidenceFreshwater`, `wigington_etal2006CohoSalmon`, `lusardi_etal2020Oversummergrowth`,
`anderson_etal2013Dispersaltributary`, `zoellick_etalAdultCoho`, `mull_wilzbach2007SelectionSpawning`,
`pess_etal2011InfluencesBody`, `departmentoffisheriesandoceans1996Fraserriver`.

## Core coho freshwater literature against the group library (2026-11-26, title match over a guarded copy)

Held in the group, outside `species/coho` (member candidates, keyed copy with a PDF):
- Nickelson et al. 1992, seasonal habitat use (`nickelson_etal1992SeasonalChanges`)
- Quinn & Peterson 1996, habitat complexity and over-winter survival (`quinn_peterson1996influencehabitat`)
- Swales & Levings 1989, off-channel ponds, Coldwater River: three group copies, only
  `swales_levings1989RoleOffChannela` has a PDF
- McMahon 1983 HSI model (`mcmahon1983Habitatsuitability`)
- Rosenfeld et al. 2000, habitat factors, cutthroat and coho (`rosenfeld_etal2000Habitatfactors`)
- Rosenfeld et al. 2008, side-channel structure (`rosenfeld_etal2008EffectsSide`)
- Roni et al. 2002, restoration review: two copies, `roni_etal2002ReviewStreama` has the PDF
- Holtby 1988, Carnation Creek logging and temperature (`holtby1988EffectsLogging`, no PDF)
- Also coho-specific, from the earlier title sweep: Bramblett et al. 2002, Pollock et al. 2004, Wigington et al. 2006
  (a second copy), Richter & Kolmes 2005 (two copies), the Bulkley overwintering series, Coho Response Team 1998

Not held (search and file, or list for download): Sandercock 1991 (the file-named item; Groot & Margolis's book is
not held either), Bustard & Narver 1975 (winter ecology), Peterson 1982 (immigration to ponds; wall-base channels),
Solazzi et al. 2000 (winter habitat), Bisson et al. 1988 (channel units), Beechie et al. 1994 (Skagit rearing habitat),
Sharma & Hilborn 2001, Pess et al. 2002, Brett 1952, Konecki et al. 1995, Bradford & Irvine 2000 (interior Fraser
decline), Irvine et al. 2002 (status), COSEWIC 2002, Decker & Irvine 2013, a recovery potential assessment for IFC,
Burnett et al. 2007 (intrinsic potential; the group holds other IP work but not this paper).

Group items with a file name for a title and no metadata (`HZ7U2NDV`, `2V3CHLXQ`, `MAZGC7MB`, `EP3EXP7M`,
`VXSD95DA`) sit beside keyed copies of the same works; they are left as they are (the #126 attachment cleanup is the
place for them).
