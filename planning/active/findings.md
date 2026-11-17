# Findings — statistics store: the methods literature for detection and occupancy (#216)

## Issue context

**If we do it:** occupancy, detection and removal methods can be searched and cited from their sources in the same store as the Bayesian texts. **If we never do:** each analysis re-finds them, and cites what it remembers.

## Problem

The `statistics` store (`data/rag/statistics.duckdb`) holds four general texts: McElreath 2020, BDA3, Hill 2025, and Toffolon & Piccolroaz 2015. It has nothing on imperfect detection, the base of any survey that can miss what is there.

## Proposed Solution

Acquire (Mode 0), file in the group library under a `Statistics/detection` collection, and rebuild `statistics` with its whole build list (script 0150, `ACTION=update`):

- **Occupancy:** MacKenzie et al. 2002 and the 2018 book, Royle & Nichols 2003, Tyre et al. 2003, Kéry & Royle (*Applied Hierarchical Modeling*).
  - Goodness of fit: MacKenzie & Bailey 2004 (`10.1198/108571104X3361`).
  - The closure assumption: Rota et al. 2009 (`10.1111/j.1365-2664.2009.01734.x`).
  - Survey design, and what low detection does to the estimate: MacKenzie & Royle 2005 (`10.1111/j.1365-2664.2005.01098.x`), Guillera-Arroita et al. 2010 (`10.1111/j.2041-210X.2010.00017.x`).
- **Removal:** Zippin 1958, Carle & Strub 1978, Hedger et al. 2013.
  - The likelihood: Moran 1951 (`10.1093/biomet/38.3-4.307`).
  - The multinomial model across sites: Royle 2004 (`10.32800/abc.2004.27.0375`), Dorazio et al. 2005 (`10.1111/j.1541-0420.2005.00360.x`).
  - Capture probability that falls across passes: Riley & Fausch 1992 (`10.1577/1548-8675(1992)012<0768:UOTPSB>2.3.CO;2`), Peterson et al. 2004 (`10.1577/03-044`).
- **eDNA occupancy:** Schmidt et al. 2013, Dorazio & Erickson 2018.
  - The multi-scale model they build on: Nichols et al. 2008 (`10.1111/j.1365-2664.2008.01509.x`).
- **Camera surveys:** Rowcliffe et al. 2014 and Ridout & Linkie 2009 (activity), Burton et al. 2015, the BC RISC wildlife camera standard.
- **Diversity:** Chao et al. 2014 and Hsieh et al. 2016 (iNEXT).
  - The incidence-based richness estimator: Chao 1987 (`10.2307/2531532`).
  - Sample coverage and extrapolation: Chao & Jost 2012 (`10.1890/11-1952.1`), Colwell et al. 2012 (`10.1093/jpe/rtr044`).

Each item is checked by DOI before it is filed. Anything paywalled is noted, not chased.

The indented items were added on 2026-11-15, each resolved against Crossref that day. They are the sources that a fit's diagnostics and its known failures rest on: goodness of fit, closure, low detection, unequal catchability, and a richness estimate that is a lower bound. Models for single-season occupancy, multi-scale occupancy, removal, activity overlap and richness are being tested against simulated surveys, and their documentation is checked against this store once it holds these.



## Exploration (2026-11-16, immutable read of the local zotero.sqlite)

- Group library: `statistics` (LP4R4VYR) has two subcollections, `survey_design` (Z7JP8UN2, 11 items, 0 PDFs, filed 2026-11-11/12) and `model_selection` (K2P7XGFG, 5 items, 4 PDFs, filed 2026-10-20). Neither is in any store.
- MacKenzie & Royle 2005 (CC22PHBQ) and Guillera-Arroita et al. 2010 (BC9RR2NP) sit in `survey_design`, no PDF.
- No other named author (Royle, Kéry, Zippin, Carle, Dorazio, Chao, Rowcliffe, Hedger, Tyre, Rota, Moran, Ridout, Colwell) has a matching work in any local library.
- `~/Downloads` is unreadable by the agent process (probed 2026-11-16): browser downloads need a copy by Al.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Sourcing, round 1 (scripts and web search, 2026-11-16)

Scripts get 403 from Wiley `pdfdirect`, OUP, Zenodo, DOAJ and core.ac.uk, and 202 (a JS challenge) from typeset.io.
The two Zenodo records OpenAlex lists (MacKenzie & Royle 2005, Ridout & Linkie 2009) are metadata only.

Version of record, fetchable by script:

| work | source |
|---|---|
| Royle & Nichols 2003 | uvm.edu/~tdonovan course copy |
| MacKenzie & Bailey 2004 | uvm.edu/~tdonovan course copy |
| MacKenzie & Royle 2005 | uvm.edu/~tdonovan course copy |
| Royle 2004 | journal (museucienciesjournals.cat) |
| Peterson et al. 2004 | USDA Treesearch 8354 |
| Rowcliffe et al. 2014 | KOPS Konstanz repository |
| Nichols et al. 2008 | uvm.edu/~tdonovan course copy |
| Burton et al. 2015 | ABMI publications 379 |
| Chao 1987 | gwern.net scan with a text layer |
| Chao et al. 2014 | uvm.edu/~ngotelli author copy |
| Colwell et al. 2012 | uvm.edu/~ngotelli author copy |
| RISC 2019, Wildlife Camera Metadata Protocol No. 44 | gov.bc.ca `wcmp_v1.pdf` |

- Preprint only: Ridout & Linkie 2009 (the author's 2008 manuscript on the Kent site). The version of record is sought
  in the browser.
- Rejected: the Kent KAR document for Guillera-Arroita 2010 is her 2012 thesis; KAR 22873 is the overlap package
  vignette.
- Books (MacKenzie et al. 2018; Kéry & Royle 2016, 2021): no author-hosted copy. Pirate mirrors are out, since the
  copies must be legitimate.
- Left for the browser: MacKenzie 2002, Tyre 2003 (core 15006539), Rota 2009, Guillera-Arroita 2010, Zippin 1958,
  Carle & Strub 1978, Hedger 2013 (core 71429212, an author manuscript), Moran 1951, Dorazio 2005, Riley & Fausch
  1992, Schmidt & Kéry 2013, Dorazio & Erickson 2018, Ridout & Linkie 2009 (version of record), Hsieh 2016, and
  Chao & Jost 2012.

## Sourcing, round 2 (Claude in Chrome, 2026-11-16)

In-page `fetch()` of Wiley PDFs returns 403 (a bot check), but opening a PDF by navigation works where the article
is free. A free article opens in Chrome's PDF viewer; a paywalled one redirects to `/doi/abs/`.

Downloaded with the viewer's download button into `~/Downloads`, which this process cannot read:
- Guillera-Arroita et al. 2010: MEE, version of record (free)
- Chao & Jost 2012: Ecology, version of record (free)
- Schmidt et al. 2013: MEE, version of record (free)
- Tyre et al. 2003: version of record via CORE (UQ eSpace; `15006539.pdf`)
- Hedger et al. 2013: author's accepted manuscript via CORE (Marine Institute OAR; `71429212.pdf`; line-numbered).
  Fisheries Research is paywalled, so `why` must say so
- MacKenzie et al. 2002: JSTOR copy of the version of record via SciSpace (JSTOR cover page first)
- Rota et al. 2009: version of record via SciSpace
- Hsieh et al. 2016: ResearchGate full text (version to check on arrival)

Paywalled on Wiley: MacKenzie 2002 and Tyre 2003 (ESA, redirect to abs), Rota 2009 (BES), Dorazio & Erickson 2018
(MER), and Dorazio 2005 (Biometrics). All but the last two have copies above.

Kent KAR 24237 (Ridout & Linkie 2009) holds no full text, so the 2008 preprint stays unless ResearchGate has the
version of record.

After one download, ResearchGate's search shows an interactive Cloudflare "verify you are human" check. The agent
does not complete such checks, so the remaining ResearchGate pages went to Al: Zippin 1958, Carle & Strub 1978,
Moran 1951, Dorazio et al. 2005, Riley & Fausch 1992, Dorazio & Erickson 2018, and Ridout & Linkie 2009.

## Inventory and CSVs (2026-11-16)

The issue lists 29 works, or 30 counting the second volume of *Applied Hierarchical Modeling* (the plan said 30/31).
- **Filed with a PDF: 23.**
  - 2 members: the group copies in `survey_design`, keys pinned.
  - 21 additions. 18 are versions of record. Three are not, and their `why` says so: Hedger 2013 and Dorazio &
    Erickson 2018 are accepted manuscripts, and Ridout & Linkie 2009 is the authors' 2008 preprint.
  - The files sit in the ignored `data/rag/pdf/detection/`: 23 PDFs, 19 MB, none needing OCR. The RISC protocol's
    2 low-text pages are its cover and a blank.
  - Sources: course and author copies at UVM (6); publisher-free on Wiley (3); USDA, ABMI, KOPS, CORE and the
    journal (Royle 2004); SciSpace (2); m4 browser downloads from ResearchGate (Dorazio 2005, Dorazio & Erickson,
    Hsieh); gwern (the Chao 1987 scan, with a text layer); gov.bc.ca (RISC).
- **No PDF: 7.**
  - 4 papers: Zippin 1958, Carle & Strub 1978, Moran 1951 and Riley & Fausch 1992. Al could not get them from
    ResearchGate, and CrossRef holds no abstract for any of them.
  - 3 books: MacKenzie et al. 2018, and Kéry & Royle 2016 and 2021.
- **OpenAlex abstracts, measured for the no-PDF four:**
  - Zippin 1958's abstract is another paper's text (a marsh fish census after a kill).
  - Carle & Strub's is OCR with misread letters ("eapture", "ehanges").
  - Riley & Fausch's matches the publisher's.
  - Moran has none.
  So an OpenAlex fallback would have filed a wrong abstract for Zippin: plan review A2 holds.
- **CrossRef metadata wrong against the title page:**
  - ALL-CAPS titles: MacKenzie 2002, Royle & Nichols 2003, Tyre 2003. In the group, such titles have produced keys
    like `taylor_etal2013HYDROLOGICCORRELATES`.
  - MacKenzie 2002 splits "J. Andrew Royle" as surname "Andrew Royle".
  - Royle 2004 deposits the USGS centre as an author.
  - Dorazio & Erickson 2018 lowercases eDNA and R, and dates the work to its 2017 online issue. The issue cites
    2018 (18(2), March 2018).
  Fix: 0270's opt-in `override` column (commit 440ebcbf). Rows without it build exactly `crossref_item()`, so the
  existing collections re-run unchanged.
- **Dedupe:** no row matches any library, live or trashed, by DOI or normalized title, from 0270's guarded copy.
- **Enumeration** (`enumeration_round0.tsv`, built through `addition_item()`, i.e. what 0270 will file): every row's
  title words and first author are on its PDF's first two pages. Year and volume are missing only on the three
  manuscript copies. Dorazio & Erickson's title scores 0.71 because the manuscript was titled "Multi-scale Occupancy
  Modeling" before publication.

## Filing (2026-11-16, 16:13Z)

- `0270 --collection detection --parent LP4R4VYR` created `statistics/detection` (`73PNRGJF`): 2 members added and
  21 items created; 7 PDFs uploaded and 16 linked by md5 ("exists"), since the server already held the bytes.
- The second dry run had 0 `would` lines and exited 0, with all 23 members holding a PDF.
- Re-measure from the guarded copy, before → after:

| collection | items | keyed | PDF on disk |
|---|---|---|---|
| statistics `LP4R4VYR` | 9 → 9 | 9 | 4 (95.2 MB) |
| detection `73PNRGJF` | – → 23 | 23 | 23 (18.5 MB) |
| survey_design `Z7JP8UN2` | 11 → 11 | 11 | 0 → 2 (the two shared members) |
| model_selection `K2P7XGFG` | 5 → 5 | 5 | 4 |

- The overrides gave clean keys: `mackenzie_etal2002EstimatingSite`, `royle2004Generalizedestimators`,
  `dorazio_erickson2018eDNAoccupancypackage`.
- Burton et al. 2015's key is `burton_etal2015REVIEWWildlife`, because CrossRef's title carries Wiley's "REVIEW:"
  section label. Once set, a key is kept, so it stays.
- `survey_design` now holds 2 PDFs, so the B1 gate passes and all four collections stay in the build list.

## Added mid-run: Hutchinson et al. 2015 (2026-11-16)

Al added penalised likelihood for occupancy (`unmarked::occuPEN()`) to the issue body after the first filing:
Hutchinson et al. 2015, `10.1111/2041-210X.12368`.
- The PDF is free on MEE and was downloaded through the browser on m4. It is the version of record, 11 pages.
- No copy existed in any library.
- Filed as `CVVUQZR5` (created, member, PDF uploaded). The repeat dry run had 0 `would` lines: 24 members, 24 PDFs.
- The issue now lists 30 works (31 with *AHM* vol. 2): 24 filed with a PDF, 7 gaps.

## Build (2026-11-16 23:48–00:05Z, Zotero quit, WAL empty)

`ACTION=build OVERWRITE=TRUE STORE=statistics COLLECTIONS=LP4R4VYR,73PNRGJF,Z7JP8UN2,K2P7XGFG` held to the
expectations written before it ran (`20261116_build_statistics_expected.txt`):
- 32 keys across 4 collections, as expected.
- The left-out list is the expected 15 items exactly, each "no live PDF".
- 4 documents before and 31 after: 27 added, 0 dropped.
- 11,113 chunks; the smallest document has 48. The 4 old documents rechunked: 2CIVEIL4 went from 56 to 52 chunks.
  #194 saw the same on rebuilds.
- Hedger et al. 2013 was skipped. ragnar 0.3.1's `markdown_chunk()` fails in `snap_nearest()` → `findInterval()`
  ("'vec' must be sorted non-decreasingly and not contain NAs") on the line-numbered accepted manuscript.
  - It reproduces with ragnar alone (`read_as_markdown()` then `markdown_chunk()`).
  - ragnar 0.4.0 (CRAN, `tidyverse/ragnar` v0.4.0), installed in a scratch library, chunks the same markdown into
    69 chunks.
  So upstream has already fixed it, and there is nothing to report there; the local ragnar is one release behind.
- Also logged by cred: Bates et al. 2024 was read with pdftools because of an embedded NUL, and ESL had 2 chunks split
  for the embedder. These are cred#35's handling, both ingested.

Query checks (reported only; expectations in the log before each ran):
- Q1, goodness of fit for occupancy: **miss.** MacKenzie & Bailey 2004 is not in the top 5. The hits are Colwell,
  MacKenzie 2002, Nichols, Tyre, Rota and Dorazio & Erickson.
- Q2, capture probability falling across passes: hit, all Peterson et al. 2004.
- Q3, multi-scale eDNA occupancy: 2 of 3 (Schmidt, Dorazio & Erickson; not Nichols).
- Q4, richness lower bound and coverage: Chao et al. 2014, Chao & Jost 2012 and Hsieh 2016 returned; Chao 1987 and
  Colwell 2012 did not.

## Push (2026-11-17 00:12Z)

`ACTION=push STORE=statistics`: the dry run, then `CONFIRM=TRUE`.
- The manifest entry reads 31 documents, 11,113 chunks, md5 `a607e293…`, branch `216-…` and head `301d43b6`, which
  was pushed to origin first.
- The bucket object's multipart ETag `bf198f36…-19` matches the local file at 8 MiB parts; 153,890,816 bytes.
- `log.json` read back from the bucket holds the same entry.

## Code-check round 2 (2026-11-17)

Two findings, both real and both fixed:
- **Hsieh et al. 2016 title.** It was filed as "(H ill numbers)". CrossRef pretty-prints `(\n <scp>H</scp>\n ill`,
  and `plain()` drops the tag but keeps the gap. A sweep of every DOI row in every `data/*_additions.csv` found no
  other title with the artefact.
  - `plain()` is left as it is: it also prepares the abstracts 0280 matches verbatim, so a whitespace change there
    would move every collection's gate.
  - Fixed instead with a title `override` on the row.
- **The override applied only when 0270 created the item.** An override added to an item already filed changed
  nothing and said nothing. 0270 now patches an existing item's overridden fields, as it already patches a stale
  abstract.
  - An override row also searches by CrossRef's own title, because the Web API title search cannot reach "H ill"
    from "Hill", and a miss would have created a duplicate.
  - The dry run printed `exists, would set title` for Hsieh alone. The live run set it, and the repeat dry run had 0
    `would` lines.
  - Its citation key (`hsieh_etal2016iNEXTpackage`) and the store are unchanged: the store holds no titles.
- **Noted outside the diff, not changed:** `crossref_item()` turns an organisation-only CrossRef author (`name`, no
  `family`) into an empty creator. Royle 2004's creators override avoids it here.

## Code-check round 3 (2026-11-17)

**Mechanism.** 0270 recognised a held item by title, first creator and year, the very fields an `override` changes,
and never by the DOI, which an override cannot touch. Round 2's two findings came from the same assumption. A
reviewer's dry `do_addition()` showed a duplicate created on any edit to Dorazio & Erickson's override: date changed,
override cut to `title`, or override cleared.

**Fix.** `group_copy()` now takes a title-search hit holding the row's DOI, ignoring case, before the title, creator
and year checks. That can only add matches, so no collection gains a duplicate. A hit with a different DOI is not
rejected, because that could stop an existing collection's re-run from finding its own copy.
- All three scenarios now print `exists`; the changed date prints `would set date`. With the DOI match removed in
  memory, the changed date prints `would create journalArticle` again.
- The repeat dry run at the new code has 0 `would` lines.

**Still true, now stated in the docstring, comment and README:**
- Removing an override leaves the held value; it never restores CrossRef's.
- The CrossRef-title fallback is search recall: a held item is found only while some title search reaches it.
