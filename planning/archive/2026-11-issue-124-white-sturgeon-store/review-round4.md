# Code-check round 4 (#124)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of every H3 under `## Mechanisms` (all fourteen; `|` rows and evidence blocks skipped).
  From the rest, by index line: "Extracted PDF text carries corrupted glyphs..." and "Verify PDF links from the
  annotations, not the extracted text" (this round reads PDF text).
- `code-check-r.md`, `code-check-shell.md`, `code-check-spatial.md`: no heading read. The fixes under review change
  only a CSV and planning prose. The one code change on the branch, `0153`'s `api()`, was not changed after round 3.

## The round-3 fixes

- **Correct against the source.**
  - `data/sturgeon_additions.csv:34`: the 2008 Lheidli T'enneh title now matches the PDF filed in
    `~/Zotero/storage/7SJG9IZD/2008AFSAR1090.pdf`. Its title page and running header both read "2008 Assessment of
    Upper Fraser White Sturgeon; Critical Habitat Identification and Refinement of Population Status".
  - `:48`: `2006-04` matches the cover and title page of `DEVU4XUT/Final_Report_0506_HSP_Final.pdf`, which both read
    "April 2006".
  - The 174.5 MB figure re-derives from the filed copies: rows 3-61 come to 172.51 MB, plus Antill (0.81) and French
    (1.22). The recovery plan adds 0.94.
- **Complete.**
  - `git grep` finds the old 2008 title only on line 36, the 2007 row, where it is correct, and in
    `review-round3.md`, which quotes it. The old HSP date and "168 MB" appear only where a review quotes them.
  - No credential path is left in the tracked tree outside `planning/archive/` and `scripts/logs/`: searched for
    `.config/newgraph`, `zotero-api-key` and `newgraph/zotero`.
  - The bodies of #124 and #151 carry none of the old values and no credential path, and neither issue has comments.
    #151 describes the filed state accurately: `KSCZP9JS` carries the 2007 title and `QPIC5D8X` is dated 2006-03.
- **The Better BibTeX keys do not move when #151 PATCHes the items.** `KSCZP9JS` is
  `lheidlitennehfirstnation20092008assessment` and `QPIC5D8X` is `carriersekanitribalcouncil2006Workingharm`. Read
  from a copy of `zotero.sqlite`. Neither key takes a word that the corrections change, so the key-named `sturgeon`
  store keeps resolving after the PATCH.
- **What a re-run does.**
  - The HSP row is safe. `group_copy()` compares years only, so the 2006-03 item still matches the 2006-04 row and
    shows as `exists`.
  - The 2008 row is not safe. Its finding is below.

## Findings

- **[severity: fragile]** `data/sturgeon_additions.csv:34` with `scripts/README.md:139`: a live
  `0270 --collection sturgeon --parent 9U54XAND` run before #151's PATCH creates a second 2008 Lheidli T'enneh item in
  the public group library.
  - `group_copy()` (`0270:291-319`) searches on the corrected title's words. "refinement" and "status" are not in
    `KSCZP9JS`'s title, and `same_work()` fails on the normalized titles in any case. So `do_addition()` POSTs a new
    item.
  - The upload of the same PDF then reports `pdf exists`, because the server already holds that md5.
  - The run tallies `created` and exits 0. Nothing in it reads as a problem: the duplicate is a success state.
  - The only control is the warning in #151's body. The tracked command line people run from (README:139, added on
    this branch) does not point to it. A dry run does print `would create report: 2008 assessment of Upper Fraser…`,
    but only a reader who expects no `would` line will notice it.
  - The fix is one clause on README:139, until #151 lands, for example: "(do not run live until #151 has corrected
    `KSCZP9JS`; a dry run must print no `would` line)". Another option is to keep that warning beside the 2008 row's
    `why` field.
  - **Rule:** code-check.md "Written data outlives the fix" (the CSV changed and the filed record did not, so the
    next run joins on the corrected value and misses the record). Also code-check.md "A guard that fails toward pass":
    `group_copy()` returning None reads the same as "not filed yet".

No other finding.

## The mechanism behind round 3's (a) and (b), and the rows it could reach

**The shared assumption:** a row in a recurring series (same author or funder program, consecutive years,
near-identical titles) equals its sibling except for the year. So it was drafted by copying the sibling and changing
the year, not read from its own title page.
- In (a), the Lheidli T'enneh critical-habitat series renamed its project between 2007 and 2008, so copying the
  2007 title was wrong.
- In (b), the Habitat Stewardship Program reports in 2005 and 2007 are dated March and 2006's is April, so the
  inherited month was wrong.

**Rows that assumption could reach, by series.** Each was checked against its title page (pdftotext of the filed
copy). Row 33's cover is an image, so it was rendered and read. The fields checked were title, creators, date,
institution, report number and report type.

| Series | Rows | Errors |
|---|---|---|
| CSTC juvenile assessment, 2004-2008 | 53, 47, 35, 33 | none (33's cover rendered: "2008 Assessment of Juvenile White Sturgeon (*Acipenser transmontanus*) Abundance and Distribution in the Nechako River; Development of an Index of Juvenile Recruitment", May 2009) |
| CSTC juvenile, later | 15, 13, 9 | none |
| Lheidli T'enneh critical habitat | 36, 34 | none, after the fix |
| CSTC harm-reduction HSP | 49, 48, 44 | none, after the fix (March 2005, April 2006, March 2007) |
| Triton adult monitoring and database | 55, 50, 42, 39, 32, 30 | none. Row 30's cover names Greg Sykes at a Kamloops address, but every page footer reads Triton |
| Other Triton | 26, 40, 43, 45 | none |
| Golder | 46, 51 not checked, 56 | none |
| NHC sediment transport | 22, 19, 17 | none. Report numbers: 300252, 300357, 3000854 |
| NHC freeze-core substrate | 25, 24 | none. 35762 and 300115; row 20's memo is also project 300115 |
| NHC substrate, restoration and planning | 3, 4, 5, 10, 14 | none |
| NHC other | 20, 21, 38, 57, 58 | none |
| BCCF (Courtier), March 2010 | 27, 28, 29 | none |
| Boat kit | 16, 8 | none |
| Predation, 2022 | 6, 7 | none |
| NWSRI plans | 2, 31, 37, 41, 52 | none |
| Beardsall and Williamson | 11, 12, 18, 54 | none |
| DFO SARA set | 62, 66, 67, 68 | none. 66's and 68's catalogue numbers are not in the HTML-printed PDFs; read from the registry pages by GET: `En3-4/181-2023E-PDF` and `En3-4/181-1-2022E-PDF`, with ISBNs matching findings.md |
| Single works | 23, 59, 60, 61, 64 | none |

**Count:** 64 of the 69 additions rows checked against their source. Rows 2-50, 52-62 and 64-68: 54 by title page,
four (62, 66-68) by their registry or SAR pages. Rows 51, 63, 65, 69 and 70 were not re-read: they are single works
with no sibling for the mechanism to copy from. Round 3 read all 69. **No further row carries a wrong value.**

Imprecise but not wrong, so not reported as findings:
- Rows 18 (`2016`) and 56 (`2003`) carry the year where the cover gives March 2016 and May 2003.
- Rows 3 and 56 leave `reportNumber` blank where the cover prints NHC Reference 3007818 and 022-7020.
- Row 12's `2017` and its NWSRI institution are printed nowhere in its PDF. They come from the page listing and the
  filename, so they cannot be checked against the PDF, but nothing contradicts them.
