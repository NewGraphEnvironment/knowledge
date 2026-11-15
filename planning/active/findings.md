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
| `crd_store_update()` left `habitat_modelling` 3.6 GiB with 0.9 GiB used (76 % free blocks; `bull_trout_grayling` 71 %, `bull_trout` 32 %) | Filed NewGraphEnvironment/cred#48; rebuilt all three with `OVERWRITE=TRUE` before any push (Al, 2026-11-15) |
| The rebuild's warning names 6 of `habitat_modelling`'s 10 skipped no-text PDFs (R truncates the warning) | Named all ten from the store diff and a guarded copy; filed #217 to OCR them |
| The `bull_trout` build skipped two members' PDFs as no text: `Bib77170.pdf` (Rare Freshwater Fish, 255 pages of 300 dpi page images) and HYSNCHBC (Metolius 1983–94, 48 pages, an Acrobat image conversion). #122's build log reads HYSNCHBC as ingested, but its PDF has no text layer | OCR copies (`ocrmypdf --deskew`) filed over each scan by two `0275` `replace` rows; auto mode refused the live run, so it waits for Al |
| Chrome's scripted downloads from a page reached `~/Downloads` minutes late or not at all | Chrome holds a site's second and later downloads for "download multiple files"; Al allowed bchydro.com, publications.gc.ca, web.archive.org and rex.libraries.wsu.edu under automatic downloads, and saved the T&F, UBC and ResearchGate files by hand |
| `CDP Runtime.evaluate timed out after 45000ms` on an 11-file batch | The script kept running in the page; waited on the files instead of re-running |
| Search A called three Baxter papers paywalled from OpenAlex alone | A ResearchGate title search found author copies of two (Baxter & Hauer 2000; Baxter, Frissell & Hauer 1999): run it for every no-PDF row before calling it paywalled |
| The live run (`20261112_0270_bull_trout_live.log`) stopped after 120 of 144 additions when its session ended, with no summary line | `0270` finds a previous run's copy through the Web API (`group_copy()`), so a dry run first (118 `exists`), then a plain re-run resumed it with no duplicate |
| `CREATE-FAIL 400 'reportType' is not a valid field` for Hammond 2004: audit round 1 had put its series in `reportType` on a `document` | `itemType` set to `report` (as the BC Hydro rows carry theirs); every row's filled columns then checked against `zotero.sqlite`'s fields for its type (0 invalid; the check finds the old row) |
| `URLError [Errno 60] Operation timed out` on single calls to the Web API and CrossRef, a different row each pass | Re-run: 0270 has no retry, and each pass reaches what the last missed. A create that timed out had succeeded (Fraley & Shepard), and the next pass found it |
| `PDF-FAIL auth-fail 500` on Sheep Creek's upload left an attachment with no file (`M6I48R5K`) | The next pass uploaded the PDF to a second attachment; the empty one was trashed (`deleted: 1`) after checking the stored sibling |
| The scratchpad was emptied when the session ended: the draft, merge, OCR and audit working files cited below are gone | The PDFs are in the ignored `data/rag/pdf/bull_trout/`, and the rows, drops and audit TSVs are tracked; a check that needs a working file regenerates it from those |

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

## Search A: federal, provincial, US and Baxter (agent, verified here 2026-11-12)

Scratchpad `search_A/`. 37 rows: 18 `pdf_ok` (each file starts `%PDF`, 68 MB in all), 7 `not_found`, 5
`needs_browser`, 4 `web_page`, 3 `paywalled`.
- **Federal management plans: none exists.** Both units were listed Special Concern by SOR/2019-287, so plans are owed
  but none has been posted, and no progress report can exist. COSEWIC re-assessed bull trout in May 2025: its
  assessment results PDF is `pdf_ok`, and the 2025 status report needs a browser.
- **US core:** the 2015 recovery plan (corrected version) and all six Recovery Unit Implementation Plans are
  `pdf_ok`. The plan and the 2010 critical habitat rule are already in the group with PDFs, so they become member
  rows. Fraley & Shepard 1989 is an open PDF on WSU's JS-only repository: needs a browser.
- **Provincial:** the 2023 plan (member), Hammond's 2004 IWMS account (`pdf_ok`), the Rare Freshwater Fish
  bull trout excerpt (the member `cannings_ptolemy1998RareFreshwater` holds the whole book, so the excerpt is
  dropped). Hagen & Decker 2011, the provincial status synthesis, is EcoCat only. Haas 1998 was not found. Rodtka
  2009 is Alberta's status update.
- **Baxter:**
  - Baxter & Hauer 2000, Baxter & McPhail 1999 and Baxter et al. 1999 are paywalled; Baxter & McPhail 1999 is
    Chowade River, NE BC.
  - The two 1997 theses behind them need a browser.
  - Three Baxter Environmental Skookumchuck reports are `pdf_ok`, probably the same three as search C's.
  - The other Baxter reports (Wigwam HCTF 1999, the Kaslo/Hamill kelt fence 2018, the Wild Horse) are EcoCat only.
- **Members:** McMahon et al. 2007 is `pdf_ok` (the TAFS article, author-hosted at Montana State), so it becomes a
  member row with a `pdf`. The Metolius migration report (Thiesfeld et al. 1996, ODFW 96-1) was not found anywhere.
  The three web pages are to be printed from the browser.

## Dedupe of every candidate (guarded copy, 2026-11-12 ~08:00 UTC)

Scratchpad `bt_dedupe.py` over all three `candidates.tsv`, matching titles (case and punctuation dropped) and DOIs
against every library, trash included. Eight matched, all group items:
- with a PDF, so they become member rows: `mcphail_baxter1996reviewbull`,
  `u_s_fishandwildlifeservice2010Endangeredthreatened`, `u_s_fishandwildlifeservice2015Recoveryplan` and
  `cope_morris2001WigwamRiver`; `b_c_ministryofwaterlandandresourcestewardship2023ManagementPlan` is already a member;
- members gaining a PDF: `mcmahon_etal2007TemperatureCompetition` (search A's copy);
- members with no PDF anywhere: the Metolius migration report;
- COSEWIC 2012: a duplicate of the member `post_etal2012COSEWICassessment`.

The other 66 rows matched nothing. A fuzzier check (by report number and the reports shared between searches A and C)
comes with the CSV rows.

## EcoCat for the named series (decision 5, 2026-11-12)

EcoCat's keyword search for "bull trout" (`advancedSearch.do`, scratchpad `ecocat/search_bt.html`) returns 874
reports, 132 of them with bull trout or *Salvelinus* in the title. 76 report ids were selected
(`ecocat/selected_ids.txt`, read with `0153`'s `report_page`, `ecocat/meta.tsv`):
- **Peace, Williston and provincial status (23):**
  - the Hagen and FWCP Peace series: the 2018, 2024, 2025 and 2026 spawner-abundance reports, the population
    structure years 1 and 2, the 2001–2015 redd-count review, Gething Creek, Davis River telemetry;
  - Baxter's Chowade studies (1996–97);
  - the Region 7 status (1992) and the Omineca management strategy (2005);
  - Hagen & Decker 2011–12 and the 2015 provincial status assessment of grayling and bull trout.
- **Columbia, Kootenay and Arrow (53):**
  - FWCP Columbia: North Columbia, Kootenay Lake redd counts and productivity, Wild Horse, St. Mary, Moyie, Salmo;
  - the Arrow Lakes adfluvial series;
  - Revelstoke telemetry;
  - the Wigwam HCTF reports (1996–1999);
  - Kaslo and Hamill;
  - Duncan migration (DDMMON-5 and -6);
  - the Kootenay Lake exploitation study (2010–2014);
  - Seven Mile entrainment (SEVMON).

Left out:
- the 56 other titled reports: coast, Fraser, Thompson and Stikine, plus the Fish Collection Permit returns;
- items already held (`obrien1999Duncanbull`, `cope_morris2001WigwamRiver`);
- the Wigwam 2001 and 2002 data reports, which search C took from OSTI.

No selected report is our own.
- **Wrong id:** 58761 is a kokanee report (search B's id for the 2019 aerial redd survey was wrong).
- **No PDF on the page:** seven reports (64856, 50790, 52775, 44624, 34398, 41092, 61641) list no document or a
  non-PDF one; these are for the gap or the browser.

After about 70 page reads EcoCat answered 403 and timed out (63271, 38265, 40104, 63284, 59883, 57455, 22671). The
download is paced: one page or file at a time with 8 s between, a 60 s wait on a failed page, logged to
`ecocat/fetch.log`.

### EcoCat download (2026-11-12, 14:41–15:14 UTC)

`ecocat/fetch.log`: 69 PDFs from the selected reports (261 MB), each starting `%PDF`. Ten gave none:
- seven list no PDF: 64856, 50790, 52775, 44624, 34398, 41092 and 61641;
- three refused every page read with 403: 38265, 40104 and 63284, the ids search B gave.

Notes on what came down:
- 7296 (Pollard 2001) carries four PDFs: the report, two data appendices and a "combo".
- 655's single PDF is byte-identical to 7296's combo.
- 63079's PDF is named for the 2023 Kaslo River HCTF report, not the Kootenay Lake productivity report its page
  names: check the title page.
- 10078 has the report and a 21 KB appendix.

## No-text check (G3)

Scratchpad `notext.tsv`: for every candidate PDF, its pages and its pages under 30 characters of text. 31 of 125
files have such pages.
- **Wholly scanned:**
  - the 7296 set (report 73/73, Murray data 24/24, Pine data 18/18, combo 206/206);
  - 53714, the 1997 Peace synoptic survey (145/145);
  - 52929, the 1992 Peace status report (37/37);
  - 52324, Chowade 1996 (28/28);
  - the Wigwam HCTF reports 1996 (41/41) and the 1999 creel (11/11).
- **Partly:** 19426 (20/164), 19439 (13/82), the 2018 Kootenay Lake workshop (13/158) and the USFWS 2015 plan
  (7/195).
- **Others:** one to four pages, mostly blanks and figures.

All 30 (655 skipped as a duplicate) go through `ocrmypdf --skip-text` into scratchpad `ocr/`; the rows will point
at the OCR copies.

## Browser downloads (Claude in Chrome and Al, 2026-11-12 16:45–18:05 UTC)

Scratchpad `browser/pdf/`: 49 files, 86 MB, every PDF starting `%PDF`. Each was fetched in a page of its own site
(or saved by Al), no bot check met or passed; ResearchGate's Cloudflare check on a search page stopped me there.
- **BC Hydro, 19:** DDMMON-5 ×7, DDMMON-6 ×3, CLBMON-6 ×5, SEVMON-2 ×4, as listed in search C.
- **Streamkeepers via Wayback, 11:** the `id_` captures search C listed.
- **Printed to PDF with headless Chrome, 8:** the COSEWIC 2025 status report (canada.ca HTML; 374 pages; Catalogue
  No. CW69-14/659-2025E-PDF, ISBN 978-0-660-78432-8 in its text; no PDF edition found, and publications.gc.ca's
  search is JavaScript only); the registry profiles 1202-869 (Western Arctic) and 1201-872 (South Coast); CDC
  species summaries 19659 (species), 28548 (pop. 28, South Coast) and 312190 (pop. 10, Western Arctic, found
  through the Explorer's name search, elcode AFCHA05122; it has no CDC status report); CDC status reports 19659 and
  28548.
- **Single:** the FWCP Peace report list (.xlsx, for enumeration only); Fraley & Shepard 1989 (WSU); Martins et al.
  2014 (Springer, open access); Paragamian & Walters 2011 (T&F, free access); Baxter & Hauer 2000 and Baxter,
  Frissell & Hauer 1999 (ResearchGate author copies); Decker, Hagen & Baxter (Arrow Lakes feasibility; its title page
  names a third author, Jeremy Baxter, whom the listing left out); the Latham, Ladell and J.S. Baxter 1997 UBC theses.
- **Not obtained:**
  - EcoCat 38265 (Andrusak et al. 2012), 40104 (Langston & Cubberley 2008) and 63284 (PEA-F25-F-3986) answer
    403 "You don't have permission to view this report" in a browser too: restricted records, not a bot block.
    Filed as #209 for an access request (Al, 2026-11-12), with Baxter & McPhail 1999; who is asked stays
    out of this public repo. #194's body lists #209.
  - Baxter & McPhail 1999: no full text found; the ResearchGate search met a Cloudflare check.
  - (Obtained after all: the C.V. Baxter 1997 thesis, 177 pages, which Al saved from ScholarWorks after CORE's
    file proved gone; 50 files in all.)
  - The WA-BC AFS 2018 slides: dropped (slides, not a report).
- **Low-text pages:** Salmo BT 1998–99 (18/57) and DDMMON-5 year 2 (20/164) are partly scanned and go to OCR; the
  other seven files with such pages have one to seven (figures, blanks).

## The two CSVs (2026-11-12 ~19:00 UTC)

Rows were drafted from each PDF's own title page or citation line by three agents (scratchpad `draft/BRIEF.md`;
EcoCat in two parts, the browser files in one) and by searches A–C before them, merged in scratchpad
`draft/merge.py` (174 rows) and deduped in `draft/fuzzy.py`: titles at a difflib ratio of 0.8 or more against every
bull trout item in the group (trash included) and 0.85 across the candidates, then read pair by pair (page counts,
text md5). Only four pairs were byte-identical.

**Members, `data/bull_trout_members.csv`: 30 rows.** The 16 from #122 (four now with a PDF: the three web-page items
take the registry and CDC pages printed with headless Chrome, whose URLs they carry, and McMahon 2007 the
montana.edu author copy) and the 14 group items listed above as their own source line (S1). Metolius 1996 still has
none (ODFW's URL is 404); it joins #209. `post_etal2012COSEWICassessment`'s `pdf` path from #122 is not on disk, and is
never read: the item holds its PDF.

**Additions, `data/bull_trout_additions.csv`: 146 rows, 392 MB** (upload time only; storage is unlimited).

| Source | Rows | MB |
|---|---|---|
| EcoCat, named third-party series (decision 5) | 61 | 193 |
| Browser (Claude in Chrome, Al's saves, printed pages) | 42 | 96 |
| Search A (federal, provincial, US) | 10 | 20 |
| Search B (Site C, Peace) | 12 | 29 |
| Search C (Columbia, Kootenay, Arrow) | 21 | 53 |

Item types: 130 report, 9 journalArticle (DOI filled from the source's doi.org link where the PDF did not print it, so
`0270` takes CrossRef's record), 4 thesis, 3 document. 28 candidates dropped, each with its reason in
`drops.tsv`: members already (Hagen & Weber 2019, Hagen & Spendlow 2019 at EcoCat r56963, McPhail & Baxter 1996,
Cope & Morris 2001 at OSTI 786475, the 2023 BC plan, the USFWS plan and rule, Cannings & Ptolemy, McMahon), the
three member PDFs, byte or text duplicates across hosts (BC Hydro's copies kept over EcoCat's for DDMMON-5 years 1
and 2 and the DDMMON-6 memo; EcoCat 10112 over the Streamkeepers fence copy; search C's Skookumchuck titles over
search A's), an earlier edition of a Kootenay Lake exploitation report and a second copy of another, 655 (7296's
bytes), a tag-number appendix, a budget addendum, a rainbow trout telemetry report, and the three Kootenay Lake
bulletins (decision 5).

- The OCRed copies are the rows' PDFs, in `data/rag/pdf/bull_trout/` itself rather than a separate `ocr/` folder
  (G3's intent: the filed PDF carries text), and the row's `why` says "OCR copy".
- Blank by the rules, never inferred: five dates the documents do not print (EcoCat 16907, 36217, 52324, 59883 and
  the pop. 28 summary) and the 1992 Peace status report's authors.
- The group item `hagenj_spendlowi_2019BullTrout` carries a title its PDF does not print ("Bull Trout Redd Counts in
  Tributaries of Williston Reservoir, 2018"; the title page reads "Bull Trout Spawner Abundance within the Williston
  Reservoir Watershed 2018, and Critical Spawning Habitats of the Omineca River Watershed"). A member's metadata is
  not edited on this branch; reported.

**Enumeration, round 0 (mechanical): `enumeration_round0.tsv`.** 789 checks: each row's title, each creator's
surname, the year, and every report number, institution, university and journal field, searched in the first six
pages of its own PDF, with the matched snippet. 31 were not found as written; re-read in the full text, 27 were
there (two-part institutions and numbers checked part by part, values past page 6, titles broken over lines, and
Rodtka 2009, whose PDF sets the species name in a symbol font), and two were wrong and fixed: COSEWIC 2025's detailed
assessments print "COSEWIC", not the committee's full name, and the South Coast registry page prints no "Government
of Canada" (now `{Species at Risk Public Registry}`, no institution). Baxter & Hauer 2000's journal is CrossRef's
(a DOI row). This proves presence, not meaning: the meaning audit per row is the `/code-check` rounds' (#29's lesson).

## Meaning audit, round 1 (two agents, 2026-11-12 18:21–18:26 UTC)

`audit_round1_a.tsv` (rows 1–73) and `audit_round1_b.tsv` (74–146): each row read against its own cover, title page
and citation line for what each field means. 23 rows questioned. Applied:
- Site C: the "Mon-1b" hyphen restored in three titles (lost at a line break in the citation); `place` was BC Hydro's
  Vancouver from the citation line, set to the preparer's Squamish where the cover prints it (2020–2024) and left blank
  where it prints no address for InStream (2016–2019).
- Hammond 2004: the printed title, its series in `reportType`. Columbia Headwaters RUIP: all three preparing offices and
  both cities. Gutowsky 2014: a PhD thesis. The 1996 Wigwam report: the cover's title, the citation's "1996/67" being a
  typo. 28071: "Annual report". 17431: the commission the cover names as lead. Chowade 1996: a library catalogue stamp
  is not a report number. The Salmo 1998–99 draft says so in `reportType`; the Salmo 2015 scoping report and the
  Arrow Lakes proceedings (Manson edited; `0270` files every creator as an author) say where their metadata came from.
- Dropped: EcoCat 16458, the same Seven Mile interim report as BC Hydro's copy; COSEWIC's multi-species May 2025
  summary (the full status report is filed). Now 144 additions.

Kept as drafted, with the reason: the two Kootenay Lake kokanee plans (they set bull trout spawner triggers); report
numbers and creators where the citation line and the cover differ (the citation line rules, as briefed); the blank date
of North Columbia 2021 (the cover's "2021" is the project year); the form heading as the only title of field report
11384.

Dry run 2 (`scripts/logs/rag/20261112_0270_bull_trout_dryrun2.log`, exit 0): 162 would (14 members to add, 4 member
PDFs, 144 creates), no `exists` or `copy exists` hit.


## Live run (2026-11-13)

Four live passes (logs `scripts/logs/rag/2026111[23]_0270_bull_trout_live*.log`):
- The first pass (05:47Z) added the 14 group items and the 4 member PDFs and created 117 additions before its session ended.
- After the Hammond fix, a dry run (`_dryrun_resume`) found 118 `exists` and 27 to do.
- Two re-runs created the other 27 (24, then the three the first pass's timeouts had left) and uploaded the two PDFs left half done (COSEWIC 2025, Alberta 2009).

Of the 144 additions' uploads, 65 came back `exists` (Zotero already held the bytes). Every one of those files is attached to its own new item.
Two of them are also held by standalone attachments with no parent, already in the group (`XWKUK4KJ`, EcoCat 10078; `FS3IC4BS`, EcoCat 63074); they were left as they were.

The no-op proof is `_dryrun3c` (exit 0, `exists 144 | member 174 | no-pdf 1 | pdf 173`, no `would`). Runs `3` and `3b` before it had no `would` line either, but each stopped on network timeouts.

The collection checked through the Web API (scratchpad `coll_audit.py`):
- 175 top-level entries: the 174 rows of the two CSVs, plus `P3TMRWQX`, the standalone Gill guide recorded at the plan review;
- no title and year twice;
- no empty attachment after the trash;
- no stored PDF only on Metolius (#209) and the standalone.

Before and after, from a guarded copy (`bt_measure.py`, 08:30Z):

| | before (2026-11-12) | after (2026-11-13) |
|---|---|---|
| live top-level items | 16 | 174 |
| keyed | 16 | 174 |
| PDF on disk | 11 | 172 |

The two without a PDF on disk are:
- Metolius 1996, which has none (#209);
- `baxter2002SummaryThird` (`TEKF7H3H`), whose attachment `VSQSZNUC` is stored on the server but had not yet synced to the desktop.

Phase 3's gate waits for it.
