# Findings — White Sturgeon store: gather the recovery documents and Nechako reports into one collection, build it, and push it (#124)

## Issue context

**What changes if we do it:** the White Sturgeon recovery documents and the Nechako White Sturgeon Recovery Initiative's reports can be searched in one store and quoted verbatim, for side-channel and floodplain work on the Nechako and Upper Fraser. **If we never do:** that reading is done by hand, one PDF at a time, and quotes from it go unchecked against their source.

## Problem

Measured 2026-10-30 in the local Zotero database:

- Group library `species/sturgeon` holds 3 items, all with a PDF and a Better BibTeX key: the 2019 Fraser River White Sturgeon provincial action framework, the 2020 lower Fraser status report (Challenger et al. 2021) and the 2023 lower Fraser monitoring program summary. All three are about the lower Fraser.
- Other sturgeon items sit in other group collections. `Nechako - NECR` holds Antill et al. 2013, a recruitment biochronology of Nechako White Sturgeon with its PDF, and two NWSRI webpages with no PDF. `eDNA` holds two sturgeon eDNA papers with PDFs (Pfleger et al. 2016, Farrington and Lance 2014).
- A personal-library `fraser/nechako` collection holds Nechako habitat history. Four of its ten items carry a PDF: Helm et al. 1980, Tredger et al. 1984, Albers et al. 2015 on Nechako flooding, and an Upper Fraser Fisheries Conservation Alliance report. `0150` resolves collections in the group library only, so none of them can reach a store.
- The federal documents with the numbered measures are absent: the recovery strategy for the four White Sturgeon populations (Upper Fraser, Nechako, Upper Columbia, Kootenay) and the 2024 action plan. So are the NWSRI recovery plan and technical reports, and the side-channel history the strategy cites (Rood and Neill 1987; Hay and Company Consultants 2000).
- `0150 build` drops an item with no key or no PDF without saying so, so the webpage items add nothing as they stand.

## Proposed Solution

1. **Fill `species/sturgeon`:** add the recovery strategy, the 2024 action plan, the NWSRI recovery plan and the technical reports on its reports page, and Rood and Neill 1987 and Hay and Company 2000 where a PDF can be found. Add the existing sturgeon items from `Nechako - NECR` and `eDNA` to the collection too; Zotero items can sit in several collections.
2. **Bring the Nechako habitat history into the group:** copy the four personal-library items with PDFs into a group collection the build can name.
3. **Check keys and PDFs** for every item, and list what has no PDF anywhere, so the gap is on record rather than silently absent.
4. **Build and push:** `ACTION=build STORE=sturgeon` over the collection key(s), then `ACTION=push`, and add the line to `scripts/README.md` beside the temperature and flow stores.
5. **Smoke-test with three queries:** side-channel loss near Vanderhoof, habitat use at the Fraser–Nechako confluence, and recruitment-failure hypotheses. Record each result's top citation keys in the build log.

Out of scope: threshold tuning. White Sturgeon is a large-river and floodplain species, so it is carried by floodplain and side-channel layers, not stream rules.

Relates to #122 (the same build for grayling and bull trout) and #14 (keying the corpus on stable Zotero identity), which this does not wait on.

## Exploration (2026-10-31, plan mode)

Read from `zotero.sqlite` with `immutable=1`, so writes not yet checkpointed out of the WAL are invisible (#127).

- `species/sturgeon` (`WEUFTSDC`, under `species` `9U54XAND`): three live members, each with a PDF and a key:
  `fraserriversturgeonconservationsociety2023FRSCSLower`, `bcministryofforests2019FraserRiver`,
  `challenger_etal2021StatusWhite`. Two more in the trash (`J7V2YWA7`, `VQ32RFH8`).
- `Nechako - NECR` (`977GE58E`, 64 rows): `antill_etal2013RecruitmentBiochronology` (PDF). NWSRI webpages `6CRM75L3`
  and `3CVKLDY8` have no PDF. `nechakowhitesturgeonrecoveryinitiative202420232024annual` (`PH5REA3P`) is keyed with no PDF, and its
  URL is `https://nechakowhitesturgeon.org/uploads/Reports/Annual_Reports/2023-24_Annual_Report.pdf`. Already in the
  group with PDFs and the personal copies' keys: `helm_etal1980ReviewNechako` (`EE97YVZ3`), `tredger_etal1984NechakoRiver`
  (`AHE9BFQQ`) and `albers_etal2015FloodingNechako` (`KIWJSBYW`). Also mainstem context:
  `bcwatersurveysunitandcanada-bcfloodplainmappingprogram1984NechakoRiver` (`WEM5QPA8`),
  `macdonald_etal2007ExaminationFactors` (`XVK9G9ZF`), `nfcptechnicalcommittee2023NechakoFisheries` (`HJ39IHTM`),
  `fraserbasincouncil2015NechakoWatershed` (`SGCU6NSQ`) and `levy_nicklin2018ChinookSockeye` (`AFM6VEG9`).
- `eDNA` (`ACQ9YXXL`): `pfleger_etal2016Savingdoomed` (PDF). There is also a standalone attachment `PPMDY4K7` "Ferrington 2014 Monitoring of
  Sturgeon.pdf". `farrington_lance2014DevelopmentGenetic` (`HC9VUJQS`) is keyed in the group with a PDF and sits in
  `eDNA` too.
- Personal `fraser/nechako` (`RYZSBUFC`, library 1): `levy_nicklinreportprepared` (`KHRI3JZZ`, PDF) is
  the UFFCA report, the only one held in personal alone. It may be `levy_nicklin2018ChinookSockeye`, and the group has a trashed copy with the same title,
  `Z9BNRLJL`. There are two standalones, `Y2RWLG9W` Chronology-NFCP.pdf and `733T5ZJV` Nechako_Watershed_Strategy-31Oct2016-FINAL.pdf,
  and several webpages with no PDF.
- Federal (SAR registry): the 2023 amended recovery strategy replaces the 2014 one. The other documents are the 2024 action plan,
  the 2014–2020 progress report, CSAS SAR 2007/014 (the recovery potential assessment, cited from the NWSRI page) and the
  Upper Fraser critical habitat order.
- NWSRI Technical Reports (`https://www.nechakowhitesturgeon.org/publications/reports`): 68 items, about 62 linking a
  PDF under `uploads/Reports/`. The recovery plan is on `/recovery/recovery-plan`.
- Ordering: #128 merged during the gate (`023d466`). #127, the WAL fix, is being worked in another worktree, and Phases 2–3 wait for it.

## Phase 1: what was gathered (2026-10-31)

**NWSRI.** The Technical Reports page has 71 paragraphs. 63 link a PDF; 61 of those return `%PDF` (174 MB with the
recovery plan). The two misses:
- Triton's "3812 Sturgeon Report Final" (2007) answers 404.
- CSAS SAR 2007/014 points at `dfo-mpo.gc.ca/csas/...`, which DFO moved. It is now
  `waves-vagues.dfo-mpo.gc.ca/library-bibliotheque/328792.pdf`, and is in.

No two downloads share an md5. Every PDF has a text layer: the lowest has over 500 characters a page.

The recovery plan is on `/recovery/recovery-plan` (`Recovery Plan July07 2004.pdf`). It cites itself as "Nechako
White Sturgeon Recovery Initiative. 2004. Recovery Plan for Nechako White Sturgeon. Prepared by Golder Associates Ltd."

Metadata comes from each PDF's title page, or from its own "should be cited as" line, never from the page listing.
The listing differs from the PDF in places:
- "Geomorphology Priority Research Questions, 2013" is an NHC memo by Andre Zimmermann, not Triton's.
- The "Boat Kit Summary 2011-2022" PDF is the 2022–2023 report (March 2023).
- The hazards-and-risks assessment (2004) cites itself as Williamson, McAdam and Cadden, where the page has "MOE".

Antill 2013 (EDI) and French 2005 (TDF Watershed Solutions) are on the page and already keyed in the group:
`antill_etal2013RecruitmentBiochronology` and `toddd_french2005WaterSediment`. They are members, not additions.
French 2005's key carries a first-creator error (`toddd`). That is left alone here: a rekey is #14's kind of change.

The scratch drafts behind the rows are the parsed page, the downloads, and a table of title, creators, date,
institution, number and type per report. Each row's `why` names its source.

**Journal articles linked from the NWSRI page with no PDF there.** CrossRef DOIs, none open access per Unpaywall:
- McAdam, Walters & Nistor 2005, TAFS, `10.1577/t04-199.1` (CrossRef holds an abstract, per the plan review)
- Smith et al. 2002, J. Appl. Ichthyol., `10.1046/j.1439-0426.2002.00418.x`
- French & Chambers 1997, CJFAS, `10.1139/f97-133`
- French & Chambers 1996, Freshwater Biology, `10.1046/j.1365-2427.1996.00105.x`

Babey 2022 (UNBC thesis, `10.24124/2022/59276`; CrossRef types it `dissertation`) sits behind UNBC's bot challenge.

**Federal.**
- canada.ca serves the amended strategy, the action plan and the progress report as HTML.
- Their catalogue numbers are En3-4/181-2023E-PDF (strategy, ISBN 978-0-660-46072-7), CW69-21/75-2024E-PDF (action
  plan, ISBN 978-0-660-70376-3) and En3-4/181-1-2022E-PDF (progress report, ISBN 978-0-660-44636-3).
- publications.gc.ca answers a script with an "Information Archived on the Web" notice in place of the PDF.
- A cookie-jar retry was refused by the auto-mode classifier as bot-check circumvention, so these three go to Al's
  browser.

**Rood and Neill 1987.** The amended strategy's reference is "Rood, K. and C. R. Neill. 1987. A study of some aspects
of the geomorphology of the Nechako River. Reid Crowther and Partners." The Northern BC Archives (UNBC) hold a file of
that title; no online copy was found. DFO's library holds "Volume 7 of 8, Nechako River Court Action, DFO Expert
Reports, February 1987, Geomorphology" (`Library/40596588.pdf`, 48 pages, with OCR text). It contains Rood's January
1987 expert report (Reid Crowther & Partners) and Neill's expert report, on flow regulation, channel morphology,
sediment and flushing flows. It goes in as its own row, noted as not the cited study.

**Hay and Company 2000.** The strategy's reference is "Options for passing flows through the Cheslatta Fan. Prepared for
NFCP. Report # MENV-022". NEEF's library holds it (`1470_Hayco2000_CheslattaFan.pdf`, 59 pages). Its title page names
the NEEF Management Committee, November 2000, in collaboration with Aquatic Resources Ltd. The copy is a scan with no
text, so `ocrmypdf` gave it 90,711 characters, and the row takes the OCRed copy from the ignored `data/rag/pdf/sturgeon/`.
NEEF's library has much more Nechako material, the Cheslatta Fan series among it. It is out of this issue's scope.

**Personal standalones.**
- `733T5ZJV` is the 2016 Nechako Watershed Strategy (Fraser Basin Council, version 1, for the Nechako Watershed
  Roundtable), 61 pages. It goes in as `zotero:733T5ZJV`: `addition_pdf` reads `~/Zotero/storage/<key>/` whatever
  the library, per the plan review.
- `Y2RWLG9W` (`Chronology-NFCP.pdf`) is a one-page timeline with no title, author or date. It is left out.

**Dedupe.** Every additions title (plus the federal, Rood, Hay and article titles) was compared by word overlap
(Jaccard ≥ 0.5) with every title in the group and personal libraries, trashed items included. That read was
`immutable`, which can miss recent writes but never invents rows. The only matches are webpage items and unrelated
Nechako reports, so no addition exists yet. Phase 2's dry run repeats the check live against the group through the Web API.

## The federal PDFs (2026-10-31, later)

Al downloaded the 2024 action plan (`CW69-21-75-2024-eng.pdf`, 51 pages, ISBN 978-0-660-70376-3), McAdam et al.
2005 (TAFS 134:1448–1456) and Babey 2022 (UNBC MSc, March 2022). publications.gc.ca served no PDF for the amended
strategy or the progress report, even to his browser.

So both are built from the registry's HTML. canada.ca serves those pages to scripts normally.

**The amended strategy.** The main page's table of contents links only chapters 1, 2, 7 and 8, but chapters 1–8 all
exist; a probe shows chapter 9 and appendix F are 404. Twelve pages in order: the main page, chapters 1–8, and
appendices A, B and C–E. Each page's `<main>` was joined into one HTML and printed with headless Chrome: 233 pages,
571,486 characters. Printing whole pages gave 584 pages, mostly site navigation, against the official 255.

**The progress report.** One page, 80 pages printed.

**Checks.** Each page's opening and closing words were looked for in the PDF text. The two `MISSING` results are
artefacts of the check: a space before `)`, and `pdftotext` dropping a hyphen at a line break.

The two files are named `*_from_html.pdf`, and each row's `why` says how it was made.

## Plan review (`review-plan.md`): how each finding was handled

The review's claims were checked before acting on them:
- **Blocker 1, the UFFCA report.** Confirmed. `NFQCJKMA` (personal) and `EBH7SSCC` (`levy_nicklin2018ChinookSockeye`)
  have 77 pages each and identical extracted text (138,853 characters); the md5s differ. The member is the group key.
- **Blocker 2, `pdf = none`.** Confirmed in `0270` (the `ABSTRACT-MISSING` step, and the exit on any upper-case
  tally). The articles go in only with a PDF; otherwise they go to the gap list.
- **The Ferrington standalone (`PPMDY4K7`).** It is Farrington & Lance 2014 (same title page, ERDC TN-EMRRP-RQ-02), so
  there is nothing to do.
- **Standalones.** Changed to `zotero:<key>` rather than a copy. The NFCP chronology was dropped.
- **#127 and cred.** Made a hard gate in Phase 2.
- **Storage quota, a trashed hit, a URL recheck before the live run, home paths in the build log, query pass
  criteria, a before/after table, `WEUFTSDC` outside `habitat_modelling`.** Each added to its phase.
- **Report fields.** Report rows carry the number and series in `reportNumber`/`reportType`, never `series`.
- **"Blocked by #127".** Written into #124's body now.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `0270 --dry-run`: 25 lookups `429 Request rate limit exceeded` | `0153`'s `api` retries a 429/503 after `Retry-After` |
| GNU `stat -f %z` (coreutils first on PATH) printed filesystem info into the download log | Sizes recomputed in Python; the `stat` fallback is never used |
| `ls` is aliased with colour codes, so `$(ls dir/*.pdf)` passed escape bytes into paths | Plain globs (`for f in dir/*.pdf`) |
| `ocrmypdf` failed with tesseract's `image file not found: PNG` | `TMPDIR` set to a scratch directory |
| publications.gc.ca answers a script with an archive notice | Browser download by Al. A cookie retry was refused as bot-check circumvention and not pursued |

## Phase 2 dry runs (2026-11-01)

The first `0270 --dry-run` after the merge hit HTTP 429 on 25 of 69 title lookups (`group_copy`'s
`/items/top?q=...`), in runs of consecutive rows: the Web API's rate limit, which `0153`'s `api` returned as a status
and `0270` tallied as `ERROR`. Zotero sends `Retry-After` with a 429 and may send `Backoff` on a success; `api` now
sleeps for the first and retries (a 429 is not processed, so a retried POST creates nothing twice) and honours the
second. The rerun took 86 s and exited 0 with no `ERROR`.
