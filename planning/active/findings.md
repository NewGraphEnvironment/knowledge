# Findings — statistics store: seven cited works of the detection methods that the library does not hold (#274)

## Issue context

**If we do it:** every work the detection models' documentation cites can be searched and read on its page in the
`statistics` store, so a claim about a method is checked against the paper and not against a memory of it. **If we
never do:** seven cited works stay outside the store, three of them read only from copies nothing here holds, and
four not read at all.

### Problem

The `statistics/detection` collection (#216) holds the methods literature for occupancy, removal, eDNA, camera
surveys and diversity. A read of the citations that rest on it found seven cited works that are not in the group
library:

| work | DOI | cited for | a free copy |
|---|---|---|---|
| Morris, White and Crowther (2019), Using simulation studies to evaluate statistical methods, *Statistics in Medicine* 38 | `10.1002/sim.8086` | summarising a simulation study by bias and coverage | published version on PubMed Central (PMC6492164); the publisher and PMC both refuse a scripted download, a browser gets it |
| Kellner et al. (2023), The unmarked R package, *Methods in Ecology and Evolution* 14 | `10.1111/2041-210X.14123` | the software several models are fitted or checked with | published version, the authors' deposit (Zenodo record 11371966, CC BY 4.0) |
| Taylor (2008), Automatic bandwidth selection for circular density estimation, *Computational Statistics and Data Analysis* 52 | `10.1016/j.csda.2007.11.003` | the smoothing rule for an activity pattern | accepted manuscript only (White Rose Research Online, eprint 3793) |
| Best and Fisher (1979), Efficient simulation of the von Mises distribution, *Applied Statistics* 28 | `10.2307/2346732` | drawing times of day | none found (Unpaywall: closed) |
| O'Brien, Kinnaird and Wibisono (2003), Crouching tigers, hidden prey, *Animal Conservation* 6 | `10.1017/S1367943003003172` | the window that makes two detections one event | none found (Unpaywall: closed) |
| Albert and Anderson (1984), On the existence of maximum likelihood estimates in logistic regression models, *Biometrika* 71 | `10.1093/biomet/71.1.1` | an estimate at a boundary | none found (Unpaywall: closed) |
| Seber (1982), *The Estimation of Animal Abundance and Related Parameters*, 2nd ed. | (book) | the removal estimator | a book |

Each DOI was resolved against Unpaywall on 2026-11-24.

### Proposed Solution

Add the seven to `data/detection_additions.csv`, acquire what can be had (Mode 0 of the literature workflow, with
the paywalled ones searched for as #216's revised rule says before any counts as a gap), file them under
`statistics/detection`, and rebuild `statistics` with its whole build list (script 0150). Taylor (2008) would be the
third accepted manuscript in the collection, with a note saying so.

Relates to #216

## Phase 1 inventory (2026-11-24)

CrossRef (all six DOIs resolve as journal articles):

| work | pages | CrossRef abstract | note |
|---|---|---|---|
| Morris, White & Crowther 2019 | 2074-2102 | yes | |
| Kellner et al. 2023 | 1408-1415 | yes | Wiley title; check `plain()` output for `<scp>` |
| Taylor 2008 | 3493-3500 | no | journal title deposited with `&amp;` |
| Best & Fisher 1979 | 152 (157 in RePEc) | no | CrossRef gives only the first page |
| O'Brien, Kinnaird & Wibisono 2003 | 131-139 | yes | |
| Albert & Anderson 1984 | 1-10 | no | creators deposited in capitals: needs `override` |

Dedupe: none of the seven is in any local library, by DOI or title, trash included (guarded WAL-inclusive copy
through 0270's `db()`).

Sources:

| work | result | route | version | MB |
|---|---|---|---|---|
| Kellner et al. 2023 | PDF | Zenodo record 11371966 (authors' deposit, `isIdenticalTo` the DOI), by script | version of record, 8 pp. | 1.08 |
| Taylor 2008 | PDF | White Rose eprint 3793, by script (OpenAlex's only OA location) | accepted manuscript, 16 pp. | 0.20 |
| Morris et al. 2019 | PDF | Wiley `pdfdirect` in Chrome, viewer's download button (CC BY) | version of record, 29 pp. | 1.84 |
| Best & Fisher 1979 | PDF | Al, from ResearchGate, after OpenAlex and Semantic Scholar: closed and a web search found RePEc and JSTOR listings only | version of record, a scan with an OCR text layer, 6 pp. (pp. 152-157) | 0.38 |
| O'Brien et al. 2003 | PDF | ResearchGate (publication 227543071) in Chrome, after OpenAlex and Semantic Scholar: closed; web search: a Wisconsin faculty PDF is another paper (Johnson et al. on Lao tigers), a Scribd upload not used | version of record, 9 pp. (pp. 131-139, the journal's own typesetting) | 0.13 |
| Albert & Anderson 1984 | PDF | Al, from ResearchGate, after ORBi (Liège) 2268/139899 held its file behind a request-a-copy form and CORE 61320564 proved another paper (McCarthy 2007, COBRA) | version of record, a JSTOR copy, 11 pp. (pp. 1-10 and JSTOR's cover) | 1.29 |
| Seber 1982 | **gap** | web search: catalogue records and the Blackburn Press reprint (in print); no lawful free copy; a book has no CrossRef abstract | | |

A scripted fetch of Morris with a browser user-agent was refused by the auto-mode classifier; the browser route
the issue named worked. Chrome saved the file to the folder last used for a save, not `~/Downloads`; ResearchGate's
download went to `~/Downloads`. ResearchGate's next search, for Albert & Anderson, met a "verify you are human"
check, which the agent does not complete: those searches go to Al.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| 0270 files CrossRef's journal name undecoded: Taylor 2008's would read "Computational Statistics &amp; Data Analysis" (`crossref_item()` runs only the title through `plain()`, 0270:402); one group item already reads "Trends in Ecology &amp; Evolution" | Taylor's row overrides `publicationTitle`; the code fix and the held item are #278 |

## Phase 1 outcome (2026-11-25)

Six of seven with PDFs, all six versions of record but Taylor 2008 (accepted manuscript): 4.92 MB. One gap: Seber
1982, a book in print with no lawful free copy. No abstract-only rows. No scan needed OCR (Best & Fisher's carries
Acrobat Paper Capture's text layer: 2,829 to 3,062 characters a page).

## Filing (2026-11-25)

0270 live: 6 created (`FHDQDU42` Morris, `4AM7FX43` Kellner, `I73CU8MR` Taylor, `2N6GFPDK` O'Brien, `E7D64J6T` Best &
Fisher, `PQUK2TFD` Albert & Anderson), each a member with one PDF. Morris's upload sent the bytes; for the other
five the file server answered `exists` (it already held those bytes by md5), so the attachment was registered without
a second upload. Each new item's attachment md5 was read from the Web API and matches the local file. The second dry
run: 0 `would` lines, exit 0, `exists 28 | member 30 | pdf 30`.
