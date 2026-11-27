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

## Phase 1: the upper Fraser coho records (2026-11-27, `data-raw/coho_upper_fraser_records.R`)

Log: `scripts/logs/coho/20261127_coho_upper_fraser_records.{txt,csv}` (30 records).

- **The population is set by the network, not a latitude.** #284's body counted 36 bcfishobs records in 12 groups
  "north of about Quesnel's latitude"; no single latitude gives that (41 north of 52.7°, 31 north of 52.8°), and its
  12 groups include CARR and QUES, which lie in the Quesnel system. The script takes the Fraser upstream of the
  Quesnel River's mouth (tributary code above `100.458399`, or the mainstem above measure 645,065 m): 24 records in
  10 groups (BLAR, BOWR, CHES, COTR, FRAN, LCHL, NECR, STUL, STUR, WILL). The Quesnel system holds well over a hundred
  coho records and is not in question.
- **No `bcdata` join is needed.** bcfishobs carries the Province's layer's own fields (`source`, `source_ref`,
  `agency_name`, `fish_observation_point_id`, `observation_key`), so the plan's join and its join rate (review finding
  11) fall away. The log keeps those fields only (decision 4).
- **The five 2004 entries rest on one compilation.** BLAR, BOWR, LCHL and STUR's 2004-01-01 records (survey ids
  7501690, 7501691, 7503425, 7503426) cite "National recovery strategy for coho salmon (Oncorhynchus kisutch) in the
  Interior Fraser watershed, British Columbia, Consultative Draft" (2004), two of them also "2001 Stock Status
  Assessment of Coho Salmon from the Interior Fraser River". The issue's fifth (Swift, COTR) is a 1986 personal
  communication from the Quesnel River Hatchery manager, not a 2004 entry; inside the network cut, four 2004 entries
  remain.
- **The 2018 FRAN coho fry** are FDIS collections 233885 and 245547 (Marlim Ecological Consulting, "200 FSR Culvert
  Replacement Inventory - 2018", one site and date under two collection ids). `bcfishobs_fdis_match.csv` marks both
  unmatched: they are not in the 2022 electrofishing extract, which holds electrofishing only, so they were most
  likely caught another way (minnow traps are usual on a culvert inventory). The method is not recorded in bcfishobs.
- **FDIS**: 7,813 visits upstream of the Quesnel's mouth in 32 groups; one caught coho (Ahbau Creek, 2014-09-16, one
  fish, Triton's "Ahbau Creek Compensation - 2014"), which is also bcfishobs record `obs:94e4f8d30d`. The issue's
  7,030 visits in 33 groups was another population.
- **NuSEDS**: five populations, not three. Besides Ahbau Creek, West Road River and Nechako River: Nazko River
  (1999 "0 spawners" with adults present; 2001 six spawners) and Swift River (one record, 2000, not inspected). Ahbau
  Creek's population carries the Cottonwood River's mainstem code (`100-478686`), and the Nechako's and West Road's
  are mainstem codes, so none is placed in a group by its code alone.

Record sources to gather in Phase 2 (each judged record's own report, where public):
- the 2004 consultative draft national recovery strategy for Interior Fraser coho, and the 2001 stock status
  assessment of Interior Fraser coho (Irvine et al., CSAS);
- "Results of reconnaissance sampling for juvenile salmonids in the upper Fraser River and selected tributaries,
  August and October, 1984" (1985);
- "Reconnaissance level fish and fish habitat inventory for portions of the Chilako and Nechako River watershed" (1998);
- "Upper Fraser River Environmental Effects Monitoring (EEM) cycle one interpretive report" (1996);
- "Hydrology and water use for salmon streams in the upper Fraser habitat management area" (draft, 1994);
- "A reconnaissance survey of Ocock Lake" (1976);
- the FDIS projects: Ahbau Creek Compensation 2014 (Triton), Nechako Fry Emergence Project 2010 (Triton), 200 FSR
  Culvert Replacement Inventory 2018 (Marlim);
- not documents: DFO fishery officers' stream files and personal communications (1986, 1989), the Quesnel River
  Hatchery manager (1986), "Untitled" (1994), "SISS map information (source not indicated)" (1995), Community
  Advisors' quarterly reports (1995), and two RAB records with no reference.

## Phase 2: the two CSVs (2026-11-27)

`data/coho_members.csv`: 40 rows. The 15 keyed items already in `ZPUIT73I`; 23 core works held in the group under
other collections (the keyed copy with a PDF where duplicates exist: `swales_levings1989RoleOffChannela`,
`richter_kolmes2005MaximumTemperature`); Burnett et al. 2007 (`burnett_etal2007DISTRIBUTIONSALMONHABITAT`) and the
Westworth 1996 Chilako–Nechako inventory (`westworthassociatesenvironmentalltd_20011996Reconnaissance`), both found
in the group by the dedupe and moved from additions to members. Eight members have no PDF in the group (Holtby 1988,
Bramblett et al. 2002, Donas & Newman 2006, 2007 and 2010, Swales et al. 1986, Brakensiek & Hankin 2007): they join
the collection and stay out of the store until a PDF is attached.

`data/coho_additions.csv`: 21 rows, 19 with a PDF (19 sources, 23.8 MB) and 2 abstract only:
- Sandercock 1991, a `bookSection` (pp. 395–445 per the book's contents page; UBC Press 1991, ISBN 0-7748-0359-2;
  the scan is a California hearing exhibit, its first page numbered 397, after the part title);
- the DFO Interior Fraser coho series: Research Documents 2000/125, 2001/083, 2004/128, 2005/093, 2013/121, 2014/086
  and 2020/025; Science Advisory Reports 2014/032 and 2019/043; Proceedings 2013/040 and 2021/040; metadata from each
  document's "Correct citation" line or title page;
- COSEWIC 2002 (the registry's main page and chapters 1–15 joined and printed, 44 pages, as #124 did; the 2016
  assessment is already a member) and DFO's 2026 SARA management scenarios page (printed, 4 pages);
- journal articles by DOI with open copies: Bustard & Narver 1975, Solazzi et al. 2000, Peterson 1982 (population
  characteristics), Sharma & Hilborn 2001, Bradford et al. 1997;
- abstract only (CrossRef holds an abstract): Peterson 1982 (immigration to ponds), Bradford & Irvine 2000.

Dedupe (title and DOI over every library, trash included): no addition held anywhere except the two moved to members.
The COSEWIC 2002 title normalizes to the 2017 report's (`WRZQU977`), but `0270`'s `group_copy()` also compares the
first creator and year, which differ (Committee 2002 against Schweigert 2017).

**Gap and download list** (no open copy found; for Al, or a later issue):
- Bisson et al. 1988 (TAFS 117:262–273) and Beechie et al. 1994 (NAJFM 14:797–811): no PDF, and CrossRef holds no
  abstract, so they cannot be filed abstract only;
- not yet searched: Brett 1952, Konecki et al. 1995, Pess et al. 2002;
- record sources: the 2004 consultative draft national recovery strategy for Interior Fraser coho (not public; DFO
  Research Document 2004/128 reviews it); "Results of reconnaissance sampling for juvenile salmonids in the upper
  Fraser River and selected tributaries, August and October, 1984" (UNBC archive holds a paper copy only); the 1996
  Upper Fraser EEM cycle one interpretive report; the 1994 draft "Hydrology and water use for salmon streams in the
  upper Fraser habitat management area"; "A reconnaissance survey of Ocock Lake" (1976); Triton's Ahbau Creek
  Compensation 2014 and Marlim's 200 FSR culvert inventory 2018 (FDIS projects, no report found); Triton's Nechako
  fry emergence 2010 report (nfcp.org answers a script with HTML; a browser may get it);
- the eight members without a PDF above.

## Phase 3 before the live run (2026-11-27)

- `%PDF` check through `0153`'s `fetch`: 17 of 17 URL sources return a PDF (the two printed files are local).
- Dry run (`scripts/logs/rag/20261127_0270_coho_dryrun.log`, exit 0): 15 members already in, 25 would be added, 21
  additions would be created, and no `exists` or `copy exists` hit. Three Bulkley overwintering members (Donas &
  Newman 2006, 2007, 2010) would get a PDF from a local copy of the same work, so 4 members stay without one: Holtby
  1988, Bramblett et al. 2002, Swales et al. 1986, Brakensiek & Hankin 2007.
