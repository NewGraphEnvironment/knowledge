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

## Federal, provincial and EDF Elk Valley (search agent B, verified here 2026-11-11)

- **Federal plan (DFO 2017, SARA management plan series, En3-5/75-2016E-PDF).** It adopts the 2014 BC plan: Part 1 is
  the federal addition, Part 2 the provincial plan (plan review's assumption, confirmed from the registry page's
  headings). publications.gc.ca serves its archived-content interstitial, so it is printed from the registry's HTML,
  front matter and Part 1 only (7 pp, 21,110 characters): Part 2 is the member `b_c_ministryofenvironment2014...`,
  whose PDF the store already gets, and a second copy would double every hit on it.
- **Federal progress report 2017–2021 (DFO 2023, En3-5/75-1-2023E-PDF).** Printed from the registry's HTML (15 pp).
  The first print lost the preface: canada.ca keeps it in a closed `<details>`, which Chrome does not print; every
  `<details>` is now opened before printing.
- **No federal action plan** exists for the BC population (Special Concern: a management plan only). **No provincial
  progress report** on the 2014 plan was found; the federal report covers its actions.
- **EDF Elk Valley:** the LOI applicant guide (ECCC 2025, En14-566/2025E-PDF, 17 pp, a `%PDF` URL) and three web
  pages printed to PDF as `report`: ECCC's Elk Valley funds page, the 2025-03-13 news release, KNC's EDF Newsletter 1
  (2026-08-25).
- **CWF's Elk River (Qukin ʔamakʔis) connectivity restoration plan** (Mazany-Wright et al. 2026, EDF- and
  FWCP-funded): a Quarto web book with no PDF. Its 12 pages (from its `search.json`) printed to one PDF, 25 pp,
  95,768 characters.
- **Left out:** KNC's 2026 annual report (68 pp, 15 MB, mostly other business; the EDF is one page of it); ECCC's EDF
  project map (a national list; the Elk Valley projects are recorded below).
- **Funded projects (2021 Teck Coal penalty, $58M):** Ktunaxa Capacity Funds; the Upper Kootenay Burbot Recovery
  Initiative (KNC); Shuswap Band's Upper Columbia native species assessment and its territorial stewardship plan;
  Okanagan Nation Alliance's Columbia River fish and habitat caretaking; a $16M competitive call with no awards
  published as of 2026-11-10. **None has a public plan, monitoring or final report yet** (projects began 2025–26),
  so the store cannot answer "what each project reports" until they publish: a gap, not a miss.

Every print is checked block by block: each paragraph's, list item's, heading's and table cell's first and last 50
alphanumerics are in the PDF's `pdftotext -raw` text (0 missing, except three long URLs in the CWF references that
wrap across lines).
- Dedupe of B's rows (every library, trash included): the LOI applicant guide is already a group item with its PDF
  (`IEIBEYEJ`, filed in another collection), so it is a **member row**, not an addition. The federal plan and progress
  report only resemble the 2014 BC plan (`YQE6M3TZ`, a different document). The rest: no copy anywhere.

## Elk and Kootenay series (search agent C, verified here 2026-11-11)

29 rows, each with a `%PDF` URL; dedupe, a mechanical title/first-author/year check against each PDF's first five
pages (through `0153`'s `fetch`, the live run's fetcher), and OCR of the image covers here:
- **Upper Fording monitoring:** 2019 (Cope 2020) and 2020 (Thorley et al. 2021) are group items already, members;
  2022 (Thorley et al. 2023) is new. There was no 2018 survey; no 2023 or later report is public.
- **Upper Fording Evaluation of Cause:** the December 2021 synthesis, 19 subject-matter-expert (SME) reports and Korman
  & Branton's handling review. Channel dewatering (Faulkner et al. 2021) is a group item, member. The industrial
  chemicals SME report (Van Geest et al. 2021), cited by the synthesis, is not public: gap.
- **Water quality SME (Costa & de Bruyn 2021, Golder 19136042/R03):** 1,751 pp and 110 MB, of which pages 344–1,751
  are per-station temporal plots (about 3.3 million characters of axis labels). Filed as pages 1–343 (`qpdf`; the
  body, Appendices A–E, Appendix F's introduction and its three summary tables; 54.6 MB, 687,684 characters), the
  row's `why` says so, and its `url` keeps the whole report. Its first three pages are image-only; OCR confirms the
  cover and the suggested citation the row follows.
- **Cyanobacteria SME:** image cover; OCR confirms Larratt & Self, May 10 2021, the title as rowed.
- **FWCP Columbia:** Lamson's 2015/16 and 2017/18 hybridization reports (same title as the 2020 final, a different
  year, so `0270`'s `group_copy` does not match them to it), the Upper Kootenay stream crossing remediation (2016) and
  two Joseph Creek reports (2019, 2020). Two more FWCP WCT reports are listed but EcoCat serves an empty page ("information
  sensitive, contact MOE"): UKE-F17-F-1183 (hybridization 2016/17) and UKE-F18-F-2440 (trout habitat, East Kootenay):
  gap. One FWCP Elk fish passage report is one of our own and is left to the report repos (CLAUDE.md).
- **Elk River Alliance:** no WCT report beyond the 2019 one held; its riparian and cottonwood projects name WCT only as
  a beneficiary: left out.
- **teck.com drops large transfers partway** (`IncompleteRead` on the synthesis and the hydrogeology SME; each fetched
  whole on a retry). `0270` creates an addition's item before fetching its PDF, so a dropped fetch leaves the item
  without one, and a re-run finds the item (`exists`) and fetches again.
- Found beyond the decided breadth, not added (for Al): the Grave and Harmer Creek WCT monitoring series (2020–2022),
  the Harmer Creek Evaluation of Cause (2023) and its SME reports (two of which the group holds and are members), the
  calcite-effects-on-WCT-spawning reports (2018–2020), a June 2023 Upper Fording recovery update, and a 2013 interim
  Upper Fording assessment.

`data/westslope_cutthroat_additions.csv`: 32 rows (6 federal/EDF/CWF, 26 series). Members: 36 (30 + 5 group items +
the EDF applicant guide). No other library's name or key appears in either file.

## Row check through the live run's fetcher (2026-11-11 ~01:20 UTC)

All 32 additions fetch whole and start `%PDF` (435.4 MB in all). Six rows are flagged by the mechanical check and each
is explained: the Elk Valley funds page's year sits in the page footer the print drops (its date is the page's date
modified); the CWF plan's authors and the hydrogeology SME's preparer appear after page 5; the water quality and
cyanobacteria covers are images (OCR above); the synthesis has no cover (its title is the one the SME Reader's Notes
cite). The hydrogeology SME's preparer comes from the synthesis's reference list and the report's qualifications
section, since the signature page cannot be read: a lower-confidence author list.

Three member URLs that answer curl fail under `0153`'s `fetch` (`User-Agent: Mozilla/5.0`): the two canada.ca hosts
answer **404** (Brown 1998 on `iaac-aeic.gc.ca`, COSEWIC on `wildlife-species.canada.ca`) and the NWT portal fails
the TLS handshake (Taylor & Mochnacz). Their checked PDFs go in as repo paths under `data/rag/pdf/westslope_cutthroat/`.

## Scope check before filing (per source)

| source | additions | MB |
|---|---|---|
| Federal (plan Part 1, progress report) | 2 | 0.5 |
| EDF Elk Valley (funds page, news release, KNC newsletter) and CWF's Elk River plan | 4 | 1.5 |
| Upper Fording monitoring (2022) | 1 | 2.3 |
| Upper Fording Evaluation of Cause (synthesis, 18 SME reports, handling review) | 20 | 416.6 |
| FWCP Columbia, Kootenay WCT | 5 | 14.6 |
| **total** | **32** | **435.4** |

Members: 36, of which 9 take a PDF from this branch (about 23 MB), 11 wait on Al's hand downloads and 1 has none.
The Evaluation of Cause set is the bulk; it was added under "Upper Fording monitoring" by this session, not by the
gate's wording, so Al confirms it before filing (issue body says so).

## Series added at Al's word (decision 3), 2026-11-11

17 rows, each fetched through `0153`'s `fetch` and read against its title page or its own citation line (OCR where the
cover is an image):
- **Harmer Creek Evaluation of Cause:** the March 2023 synthesis (Harmer Creek Evaluation of Cause Team) and the SME reports its
  reference list names that the group lacks: streamflow and inferred habitat availability, dissolved oxygen, calcite,
  total suspended solids, food availability, sediment quality, small population size, selenium, surface water quality,
  and the telemetry memo. Water temperature and ice (Hocking et al. 2022) and energetic status (Thorley & Branton 2022)
  are group items, already members. Selenium and surface water quality print no authors on their covers; theirs are
  the synthesis's reference list's (de Bruyn, Bollinger & Luoma; Warner & Lancaster), said in each row.
- **Surface water quality (Golder 21452261-003-R-Rev1):** 2,522 pp and 571 MB, the report's own pages being 1–163 and
  2,511–2,522 (each carries its report number); pages 164–2,510 are embedded laboratory toxicity reports and another
  report's chronic-toxicity appendices. Filed as those 175 pages, and its body (pages 6–79) is scanned, so OCRed:
  412,041 characters.
- **Grave and Harmer Creek WCT monitoring:** 2020, 2021, 2022 (Thorley et al.).
- **Calcite effects on WCT spawning habitat suitability:** 2018 (title from the title page; its citation line says
  "of Salmonids"), 2019, 2020 (Hocking et al., Ecofish).
- curl's first fetch of the Harmer food availability and sediment quality reports was cut short (22 of 36.6 MB, with
  no error from curl); `0153`'s `fetch` raises `IncompleteRead` instead, so a short read cannot be filed.

## OCR of pages with no text

Counting pages with under 30 characters of text found scanned pages in seven filed PDFs. `ocrmypdf --skip-text`
(OCRs only those pages) gained: Upper Fording food availability SME 45,245 → 242,755 characters (130 of 172 pages
were scans), the Upper Fording synthesis 489,091 → 602,843, hydrogeology 594,626 → 720,169, climate 191,022 →
244,771, habitat availability 156,663 → 208,064, the Harmer synthesis 290,244 → 352,230, and the Upper Fording water
quality cut 579,376 → 767,818. Sampled pages show real text (acknowledgements, reader's notes, citations,
abbreviations), so all seven rows take the OCRed copy as a repo path.

**Additions: 49** (35 by URL, 14 by repo path under the ignored `data/rag/pdf/westslope_cutthroat/`, 220 MB there).

## The collection before and after the live `0270` run (guarded copy, 2026-11-11 04:23 UTC)

| | before (2026-11-10) | after |
|---|---|---|
| live top items | 30 | 85 |
| with a Better BibTeX key | 30 | 85 |
| with a PDF on disk | 9 | 73 |
| PDF sent to Zotero storage | | 242.4 MB uploaded; 438.5 MB registered without sending (`exists`) |

`exists` is the Web API's answer when its storage already holds a file of the same md5 (`0153`'s `upload()`): the
attachment is registered and nothing is sent. Most of the Teck Evaluation of Cause and monitoring PDFs came back so.
The 12 without a PDF are the 11 hand downloads and Hagen & Baxter 2009.
