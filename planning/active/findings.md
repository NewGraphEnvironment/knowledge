# Findings — Westslope cutthroat store (#190)

## Issue context

**What changes if we do it:** the westslope cutthroat management and recovery documents and the East Kootenay monitoring reports can be searched in one store and quoted verbatim, for habitat, floodplain and restoration-effectiveness work in the Kootenay and the Elk. **If we never do:** that reading is done one PDF at a time, and quotes from it go unchecked against their source.

## Problem

Measured 2026-11-10 (an `immutable` read of the local Zotero database): group collection `species/westslope_cutthroat` (`TIDR3PNN`) holds 30 items, 9 of them with a PDF. It is in no store; `habitat_modelling`'s build list does not include it.

- Without a PDF: the 2014 BC management plan, the 2017 COSEWIC assessment and status report, the 2008 East Kootenay abundance monitoring of classified waters, the Upper Fording River assessments (2016, 2017), the 2020 evaluation of hybridization in the upper Kootenay, and the Elk River WCT Research Initiative's 2019 report.
- Not in the collection, to search for: the federal management plan for the BC population and any progress report on it, the provincial plan's progress reporting, and recent Elk and Kootenay monitoring and restoration reports where they are public.
- The Environmental Damages Fund's Elk Valley (Qukin ʔamakʔis) projects: the call and applicant guides, and the plans, monitoring and final reports of funded projects where they are public. ECCC administers the fund and Ktunaxa Nation Council reviews the competitive call with it; what each project reports, and against what baseline, is part of what the store should let us read.

## Plan

The same steps as the sturgeon store (#124).

- [ ] Gather PDFs for the members without one, and write `data/westslope_cutthroat_members.csv` and `data/westslope_cutthroat_additions.csv`
- [ ] Search for the absent documents above and file what is found into the collection, the EDF Elk Valley documents included (ECCC's Elk Valley funds page and applicant guides, KNC's EDF newsletters, and any project reports they link)
- [ ] Build and push: `ACTION=build STORE=westslope_cutthroat COLLECTIONS=TIDR3PNN`, then `ACTION=push`, with the line in `scripts/README.md`
- [ ] Smoke-test four queries (thermal limits, hybridization with rainbow trout in the upper Kootenay, restoration effectiveness in the Elk, monitoring required of EDF-funded projects) and record each one's top citation keys in the build log
- [ ] List what has no PDF anywhere, so the gap is on record

Out of scope: threshold tuning; the WCT rearing curve is #186.

Relates to #124.


## Exploration (2026-11-10, immutable read of the local zotero.sqlite)

- `TIDR3PNN` (`westslope_cutthroat`, under `species` `9U54XAND`, library 9): 30 items, 9 with a live PDF child,
  all 30 with a Better BibTeX key. The `-wal` was 2.1 MB, so this misses unflushed commits; re-measured in Phase 1.
- 21 without a PDF: the 7 the issue names, plus journal articles (Brown & Mackay 1995, Brown 1998, Boyer et al. 2008,
  Muhlfeld et al. 2012, 2016, Pierce et al. 2014, Janowicz et al. 2018, Blank et al. 2020), D'Angelo & Muhlfeld 2011,
  Taylor & Mochnacz 2013 (Banff protocol), Mayhood 2014 and 2019, Blackburn 2017, and the BC Species and Ecosystems
  Explorer page.
- One key has no author stem: `WESTSLOPECUTTHROATTROUTOncorhynchusclarkilewisi2004` (keys never move; kept).
- cred 0.7.0 / ragnar 0.3.1 installed; cred#45 (immutable reads) open.
- Auto mode refused #124's Web API merge (#172 plan), so the live `0270` run and the push wait for Al.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Re-measure from a guarded copy (2026-11-11 00:50 UTC)

`0270`'s `db()` (main file plus `-wal`, guarded), then `local_pdf()` per item: **30 live items, 30 keyed, 9 with a live
PDF child, 9 with the PDF on disk**, the same as the immutable read. No other item carrying a member's citation key
(any library) holds a PDF on disk for one of the 21 without.

## PDF sources for members (first probes)

- `%PDF` at the item's own URL: the 2014 BC management plan (EIRS `subdocumentId=9781`, 4.3 MB), Cope et al. 2016
  (5.8 MB) and 2017 (0.8 MB, title page to check), the Elk River Alliance 2019 report (7.9 MB).
- Lamson 2020: the item URL is EcoCat's report page (HTML); its PDF is `acat/documents/r58888/UKE_F19_F_2682_...pdf`
  (1.2 MB, `%PDF`).
- COSEWIC 2017: publications.gc.ca answers with an "archived content" interstitial, not the PDF. A retry with a
  cookie jar was refused by auto mode as bot-check circumvention, and is not to be retried: another host, or Al.
- OpenAlex: closed for Muhlfeld et al. 2012, Janowicz et al. 2018, Pierce et al. 2014, Brown & Mackay 1995, Boyer et
  al. 2008 and both Mayhood DOIs (ResearchGate); Blank et al. 2020 diamond OA but its publisher answered 403; Muhlfeld
  et al. 2016 green (figshare).

## Group items outside `TIDR3PNN` that become members (immutable read, 2026-11-11)

Live in the group, each with a PDF, filed only in other collections (temperature `SW2RXUJC` and two others):
`cope2020UpperFording` (2019 monitoring), `thorley_etal2021UpperFording` (2020 monitoring),
`faulkner_etal2021SubjectMatter`, `hocking_etal2022SubjectMatter`, `thorley_branton2022SubjectMatter` (the Evaluation
of Cause subject-matter-expert reports). Members: 30 + 5 = 35 before the search agents' results. (A first query also
listed `WBGNP2EZ`, `SKFPH72Z`, `MYABAICN` with no collection: they are the PDF attachments of Cope 2020, Thorley et al.
2022 and 2021, matched by attachment title; same md5 as each parent's PDF, so not separate items.)

## Members' PDFs (search agent A, verified here 2026-11-11)

21 members had no PDF. **9 have a URL that returns `%PDF`**, each title page read against its item: the 2014 BC
management plan (108 pp), Lamson 2020 (EcoCat, 27 pp), Cope et al. 2016 (288 pp) and 2017 (53 pp; the small file is
the whole report), the ERA 2019 report (176 pp), and four new hosts checked here:
- Taylor & Mochnacz 2013: NWT Discovery Portal, the "final draft" of December 2013 (22 pp).
- COSEWIC: the SARA registry's PDF of the same report (99 pp). It prints **2016**; the item says 2017 (the
  publications.gc.ca catalogue edition). Item metadata left as is.
- Muhlfeld et al. 2016: the TAFS article hosted by the Crown Managers Partnership (17 pp); figshare's copy is the
  7-page supplement only.
- Brown 1998: the same path on `iaac-aeic.gc.ca` (the item's `ceaa-acee` host no longer resolves). The article is
  Environmental Biology of Fishes 55 (**1999**); the item says 1998. Left as is.

**For Al to download by hand (11)** into `data/rag/pdf/westslope_cutthroat/<citation_key>.pdf`:
| key | where | why not scripted |
|---|---|---|
| `muhlfeld_etal2012ASSESSINGIMPACTS` | doi:10.1002/rra.1494 | closed; also in `habitat_modelling` |
| `dangelo_muhlfeld2011FactorsInfluencing` | scholarworks.umt.edu/etd/426 (D'Angelo's MS thesis, same title) | Cloudflare check; also in `habitat_modelling` |
| `blank_etal2020SwimmingPerformance` | doi:10.3996/052019-JFWM-040 (gold OA) | publisher 403, repository 429 |
| `janowicz_etal2018Agegrowth` | doi:10.1111/jfb.13792 | closed |
| `pierce_etal2014WestslopeCutthroat` | doi:10.1080/00028487.2013.839959 | closed |
| `brown_mackay1995Spawningecology` | doi:10.1139/f95-097 | closed |
| `boyer_etal2008Rainbowtrout` | doi:10.1139/f08-001 | closed |
| `mayhood2014Conceptualframework` | doi:10.13140/2.1.1931.6809 (FWR Technical Report 2014/03-1) | ResearchGate only |
| `mayhood2019Comments2019` | doi:10.13140/RG.2.2.17310.48967 (FWR Technical Note 2019/07-1) | ResearchGate only |
| `blackburn2017TrendsDistribution` | Alberta Conservation Association report series | Cloudflare check; filename unknown |
| `bcspecies&ecosystemexplorer2020Oncorhynchusclarkii` | a100.gov.bc.ca/pub/eswp/reports.do?elcode=AFCHA02088 | a web page: print to PDF |

**No copy anywhere found (1):** Hagen & Baxter 2009 (2008 WCT abundance monitoring of classified waters, East
Kootenay): cited by the Species and Ecosystems Explorer; not in EcoCat, env.gov.bc.ca or FWCP by search.

`data/westslope_cutthroat_members.csv` drafted: 35 rows, 9 with a `pdf` URL; the hand-download rows take their path
when the files land (an empty `pdf` until then, so a dry run does not fail on a missing path).
