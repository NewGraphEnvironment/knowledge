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
  Assessment of Coho Salmon from the Interior Fraser River". (Corrected in code-check round 1: the issue's fifth, Swift
  River in COTR, survey id 7503424, is a 2004 entry too. It lies on a Fraser side channel at the Cottonwood's mouth
  whose watershed code is the Fraser's, and the first version of the cut, which placed a bare `100` code by its
  measure on the mainstem, dropped it. The cut now places such a point by its local code: 25 bcfishobs records.)
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

## Phase 3: the live run (2026-11-27)

- Live run (`scripts/logs/rag/20261127_0270_coho_live.log`): 25 members added, 21 additions created, one PDF upload
  failed with a server 500 (Irvine et al. 2000, `VEQWXGMB`). The rerun (`..._live2.log`, exit 0) attached it. The
  dry run after both (`..._dryrun2.log`) printed no `would` line and exited 0.
- **Correction: `49HFCT96` had a file.** It is a standalone attachment (`imported_url` from coastcoho.org) whose file
  is the same Sandercock scan, byte for byte (md5 `fbc454da42fc8b8e363373b17e12dbaa`), which is why the new
  Sandercock item's upload registered without sending. The measure called it NOPDF because `0270`'s `local_pdf()`
  looks only at child attachments. The issue's premise ("no PDF attached") and Phase 2's were both wrong about the
  file and right that no store could take it: a standalone attachment has no citation key. Trashed through the Web
  API (204) after checking that `XJ6VCFEM`'s attachment holds the same md5.

| `ZPUIT73I` | before (2026-11-26) | after (2026-11-27) |
|---|---|---|
| live items | 16 | 62 (61 after the trash) |
| with a Better BibTeX key | 15 | 61 |
| with a PDF on disk (child attachment) | 15 | 55 |
| MB on disk | 25.0 | 271.1 |

The six keyed items without a PDF: Holtby 1988, Bramblett et al. 2002, Swales et al. 1986, Brakensiek & Hankin 2007
(members, no PDF anywhere in the group), and Peterson 1982 (immigration) and Bradford & Irvine 2000 (abstract only).

## What the Interior Fraser documents say about the upper limit (2026-11-27, read in the PDFs; for Phase 5)

- Irvine et al. 2000 (Res. Doc. 2000/125): coho "are found well upstream of the northern boundary shown on Fig. 1
  although generally in limited numbers; for example they have been documented in the Nechako River drainage, west of
  Prince George."
- Irvine et al. 2001 (Res. Doc. 2001/083): "Coho are prevalent throughout the Thompson watershed but their
  distribution in non-Thompson Fraser systems is not well known. They are recorded as far upstream as the Nechako
  drainage"; and "Coho are confirmed in the Seton, Bridge, Chilcotin, Westroad, and Nechako rivers, and are suspected
  of being in the several other non-Thompson systems."
- COSEWIC 2002 and Decker & Irvine 2013: at least as far upstream as the Nechako; Bowron suspected, not confirmed.
- Arbeider et al. 2020 (Res. Doc. 2020/025), Figure 7's caption: "Coho Salmon have been observed in some of these
  systems, such as Westroad River and tributaries, Nechako River, Kuzkwa River, Kazchek Creek, and Bowron River
  (unconfirmed); however, there is no regular or formal surveys of most streams." Kuzkwa River and Kazchek Creek are
  Stuart system streams, Kuzkwa River in LTRE (Trembleur Lake) and Kazchek Creek in MIDR (Middle River), checked
  against the Freshwater Atlas. Neither has a coho record in bcfishobs, FDIS or NuSEDS: a lead for the check, not a
  record.

## Phase 4: the `coho` store (2026-11-27)

Build (`scripts/logs/rag/20261127_build_coho.log`, cred 0.8.1, ragnar 0.4.0, nomic-embed-text, Zotero quit with a
0-byte `-wal`; 15:00 to about 15:07 UTC): 61 members, 6 left out (no live PDF), exactly the recorded gap (4 members
with no PDF, 2 abstract only); 55 keys; 2 PDFs with no text skipped (`departmentoffisheriesandoceans1996Fraserriver`,
already a member, and `donas_newman2007BulkleyRiver`); **53 documents, 10,059 chunks, 139,735,040 bytes (133.2 MiB,
0 free blocks), md5 `ff810881567f0c4dfcab9488ee873608`**. Every one of the 53 origins is a live group attachment of
a live `ZPUIT73I` member.

The build warned "Taking several PDFs for 1 item(s): irvine_etal2000StockStatus (2)" and "Skipping 1 missing file":
the failed upload of the live run had left an attachment with no file (`MQZIH4Z7`) beside the retry's (`8P4S4IXH`).
The store took the good one; `MQZIH4Z7` was trashed through the Web API (204). Filed as #286.

Queries (`scripts/logs/rag/20261127_query_coho.log`, expectations written before each, all `hybrid`):
1. how far upstream coho occur: hit (Decker & Irvine 2013, COSEWIC 2002, the 2007 strategy, COSEWIC 2017, Arbeider
   et al. 2020);
2. overwinter habitat: partial (Nickelson et al. 1992, Swales & Levings 1989 hit; Bustard & Narver, Peterson,
   Solazzi, Quinn & Peterson missed; Roni et al. 2002, Rosenfeld et al. 2008 and Ebersole et al. 2006 instead);
3. causes of the Interior Fraser decline: partial (COSEWIC 2002, the strategy, COSEWIC 2017 hit; the Irvine et al.
   reports and Arbeider et al. missed; the Coho Response Team's Skeena report came in);
4. temperature limits: partial (Richter & Kolmes, Lusardi et al. hit; Sandercock, Holtby & Scrivener and McMahon
   missed; Reeves et al. 1989 came in).

OCR owed: the two no-text scans above (as #124 owed Tredger).

## Phase 4: `habitat_modelling` with `ZPUIT73I` (2026-11-27, cred 0.8.1)

Pulled and verified first (md5 matched the manifest: 414 documents, 903.5 MiB, 0 free blocks). `ACTION=update` over
its whole list plus `ZPUIT73I` (`scripts/logs/rag/20261127_update_habitat_modelling.log`, 15:09 to 15:18 UTC): 49
added, 0 replaced, 0 dropped, 414 kept: **463 documents, 78,529 chunks, 1,239,429,120 bytes (1.1 GiB), 0 free blocks**,
md5 `96c88c454c83309908361c1b3206a14d`. cred#48's fix holds: the updated file has no free blocks, against 32 to 76 %
after #194's updates on cred 0.7.0. The run warned about Irvine et al. 2000's two PDFs because the local database
still held `MQZIH4Z7` (trashed through the Web API with Zotero quit); its file was missing, so the update skipped it.

## Phase 4: the pushes (2026-11-27)

`coho` uploaded 15:18:47 UTC (`scripts/logs/rag/20261127_push_coho.log`): the bucket object is 139,735,040 bytes,
and its multipart ETag `3c735e8f…-17` matches the local file recomputed at 8 MiB parts. `habitat_modelling` uploaded
15:19:38 UTC (`..._push_habitat_modelling.log`): 1,239,429,120 bytes, ETag `97ca9e75…-148` matched the same way. Both
manifest entries name this branch and head `57c458bd`. The merged manifest now holds 14 stores, `coho` the newest.
Zotero was reopened after the pushes.

## Phase 5: the judgement (2026-11-27)

`research/coho_upper_fraser.md`: 31 records (30 before round 1's fix), 15 survey, 13 compilation, 2 doubtful (the Bowron 2004 entry, which DFO
still calls unconfirmed, and Micks Creek's RAB record with no date or source), 1 no observation (Swift River, not
inspected). The verdicts gained a fourth, "no observation", for that NuSEDS record. Placing each record on the network:
every survey lies at or below the Nechako confluence (`100.567134`); the only two records above it on the Fraser are
BOWR (2004, doubtful) and WILL (Slade Creek, 1995, a compilation; it lands on Tregillus Creek, which Slade Creek joins).
FRAN is the Francois Lake group, in the Nechako system. The full `0280` run verifies the file's 5 quotes; it exits 1 on
#282's 42 OCR evidence rows, the same counts as the committed 2026-11-26 log. No `data/nuseds_reach_groups.csv` row was
added: a row moves `timing_nuseds.R`'s coho windows.

## Code-check rounds 1 and 2 (2026-11-27)

Round 1 (`review-round1.md`): the cut dropped a Fraser side-channel record (fixed: localcode); the two push logs held
the bucket's whole manifest, naming a private repository and a project repository (trimmed to their own entry, and the
two unpushed commits folded, so no commit holds them); log path, qualifier, row order, Gaps and a `why` corrected.
Round 2 (`review-round2.md`): the round 1 fixes hold over every input; NAZR is also outside link's coho range and holds
the Nazko River's NuSEDS survey, so the range section now names CHES, FRAN, NAZR, STUL and STUR; the Gaps count of
FDIS-based records was four and is five. Neither round 2 finding sits inside a round 1 fix. The private name the
round 1 reviewer quoted was removed from its findings file.
