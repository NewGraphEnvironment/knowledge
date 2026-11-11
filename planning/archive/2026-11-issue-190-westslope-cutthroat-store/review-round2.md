# Code-check round 2: #190 branch (reviewer, 2026-11-11)

## Checklist read

- `code-check-python.md`: read in full.
- `code-check.md`, read by heading: the prose of every H3 under `## Mechanisms` that the section dump reached (A guard that
  fails toward pass; A fixture that cannot reach the failure mode; A proxy is not the property, including "A
  verbatim-quote gate certifies the words, not the meaning of the row built around them, so audit meaning row by row and
  end on an enumeration"; Verification that reads its own output, opening). The rest of the Mechanisms H3s by their
  index lines. Of `## Spreadsheets and PDFs`, the index lines (Extracted PDF text carries corrupted glyphs…; Verify PDF
  links from the annotations…).
- `code-check-r.md`, `code-check-shell.md`, `code-check-spatial.md`: index lines scanned. The diff has no R, shell or
  spatial code, so no section applies and none was read in full.
- The repo's `CLAUDE.md`, including "One discipline: everything here is public", and `scripts/0270-habitat-collection-build.py`
  (`same_work()`, `group_copy()`, the fields `item` takes from a row).

## Method

- I ran `pdftotext -f 1 -l 6` on every additions row's stored PDF (49/49, matched to `_pdfmap.csv` by normalised title;
  row 28 by its storage key). For the image covers I rendered the cover (cyanobacteria, selenium) and read it. Where a
  title page lacked a field I read further into the document: the synthesis's reference lists, signature pages, and the
  "Preferred/Suggested Citation" lines.
- I checked each shared field (creators, institution, reportType, place, date) against that row's own title page or
  citation line. I did not check it against its siblings.
- For Zotero item `CQZTEEXK` I read a guarded copy of `zotero.sqlite` (main file plus `-wal`, `quick_check` ok, in the
  scratchpad). I made no Web API call: the group is not public, and I did not read the key.

## Findings

- **[bug (data)]** `data/westslope_cutthroat_additions.csv:48-50` (additions rows 47-49, calcite 2018/2019/2020) give
  `place` `Sparwood, BC`. Each report's own title page reads "Prepared for: Teck Coal Limited, Suite 1000 – 205 9th
  Street, Calgary, AB, T2G 0R3". Sparwood comes from the Teck "Technical Report Overview" sheet that Teck put in front
  of the report. Rows 9, 10 and 20 have the same "Prepared for" block and give Calgary, AB, and every other Teck row
  takes `place` from its own "Prepared for" line (rows 13-16, 18, 24, 34-37 from "421 Pine Avenue, Sparwood"; rows 7
  and 44-46 from "Teck Coal Ltd., Sparwood, BC"). Under the rule the rest of the file follows, these three rows should
  read `Calgary, AB`. Fix the rows and PATCH the three items (`P2GHCV5J`, `59BE3NV8`, `JU8AQHJ6`).
  - **Rule:** code-check.md "A proxy is not the property" (a verbatim gate certifies the words, not the row built
    around them: audit meaning row by row)

- **[bug (data)]** `data/westslope_cutthroat_additions.csv:31` (row 30, Upper Kootenay Stream Crossing Remediation,
  `PG4EHFX6`) gives `place` `Cranbrook, BC` and `institution` Fish and Wildlife Compensation Program. Its title page
  puts the FWCP at "601-18th Street, Castlegar, BC V1N 2N1". Cranbrook is the address of the preparer, VAST. Rows 31
  and 32 (lines 32-33, `5R269XNJ`, `RXT26MR2`) follow the same preparer-place rule: on each title page the only place
  is the preparer's (VAST's footer; "Columbia Outdoor School, Box 759, Cranbrook"), and neither names an FWCP place.
  Their FWCP siblings, rows 28 and 29, leave `place` blank. In Zotero, `place` is read with `institution`, so these
  rows put the FWCP in Cranbrook. Row 30's own document contradicts that, and rows 31-32 have no support for it. Set row 30 to
  `Castlegar, BC` and leave rows 31-32 blank (as rows 28-29 are), with matching PATCHes.
  - **Rule:** code-check.md "A proxy is not the property"

- **[fragile (data)]** `data/westslope_cutthroat_additions.csv:34,42,44` (rows 33, 41, 43: the Harmer synthesis, the
  selenium SME report and the telemetry memo) give `place` `Sparwood, BC`, but none of the three documents gives a
  place for Teck on its title page or citation line:
  - The synthesis has "Report prepared for Teck Coal Limited by Evaluation of Cause Team" and a cite line with no place.
  - The selenium cover has "Submitted to: Teck Coal Limited" with no address.
  - The memo has "TO: Teck Coal Limited".

  Their Upper Fording counterparts with the same lack leave `place` blank (rows 8, 17, 22, 23, 26, 27). The value was
  copied from the Harmer Ecofish and Minnow siblings, whose title pages do print Sparwood. Teck Coal is in Sparwood,
  so the value is not shown wrong, but no document supports it. Row 33 is round 1's corrected row, and the fix left
  this field as it was.
  - **Rule:** code-check.md "A proxy is not the property"

- **[fragile (data)]** `data/westslope_cutthroat_additions.csv:27` (row 26, Larratt & Self, cyanobacteria) has
  `reportType` "Report prepared for Teck Coal **Limited** by Larratt Aquatic Consulting Ltd.". The document gives the
  client two ways: the cover reads "Prepared for: Teck Coal", which the row's own `institution` (`Teck Coal`) follows,
  and the document's "Preferred Citation" reads "Consultant's report prepared for Teck Coal Fording River Operations,
  Prepared by Larratt Aquatic Consulting Ltd.". The row uses neither: its wording is the Upper Fording SME siblings'
  form. Its `institution` and `reportType` therefore name the client differently within one row.
  - **Rule:** code-check.md "A proxy is not the property"

- **[fragile (planning record)]** `planning/active/findings.md:206` still reads "the March 2023 synthesis
  (Evaluation of Cause Team)". After round 1's fix the row, and the document's cite line, say "Harmer Creek Evaluation
  of Cause Team". `progress.md:61-62` records the fix; findings.md was not updated.
  - **Rule:** none

## Task 1: round 1's fix (row 33, `CQZTEEXK`)

| field | row now | document (`ocr_harmer_eoc.pdf`, title page and "When citing" line) | verdict |
|---|---|---|---|
| title | Evaluation of Cause — Reduced Recruitment in the Harmer Creek Westslope Cutthroat Trout Population | cite line: same, with the em dash | OK |
| creators | {Harmer Creek Evaluation of Cause Team} | "Harmer Creek Evaluation of Cause Team. (2023)" | OK |
| date | 2023 | title page "March 2023"; cite line 2023 | OK |
| institution | Teck Coal Limited | "prepared for Teck Coal Limited" | OK |
| reportType | Report prepared for Teck Coal Limited by Evaluation of Cause Team | title page, verbatim | OK |
| place | Sparwood, BC | none given | unsupported (finding 3) |
| url | teck.com/media/Harmer-Creek-Evaluation-of-Cause%20-Report-March-2023.pdf | n/a | not checked online |

Around the fix:
- The local `zotero.sqlite` still holds `CQZTEEXK` with the old title ("Evaluation of Cause: Reduced…") and creator
  "Evaluation of Cause Team", at item version 11388, last modified 04:12 UTC. Zotero is not running, so the PATCH
  (version 11444, per progress.md) has not synced down. I could not confirm it read-only. The indirect evidence is
  progress.md's post-fix dry run: `group_copy()` matches only on the same first creator, so had the PATCH not landed,
  that dry run would have reported "would create", not a no-op. Before any `0150` build or update that should carry
  the new metadata, sync Zotero and check the local item.
- The store pushed in `30b89ce8` was built before the fix. Its document is named by the unchanged citation key, so
  nothing in the store points at a wrong item.
- The 0270 logs (dryrun1/2, live) show the old title. They record those runs as they happened, so this is not a defect.
- findings.md:206 is stale (finding 5).

## Task 2: series fields, per row (data row N = file line N + 1)

Federal and EDF
1 OK. Recommended citation: DFO 2017, SAR Management Plan Series, Ottawa.
2 OK. Recommended citation: DFO 2023, Report Series, Ottawa.
3 OK (accepted: page metadata)
4 OK. Dateline "March 13, 2025 – Vancouver, British Columbia"; from ECCC.
5 OK (accepted: page metadata). Title and date from the masthead.
6 OK. Recommended Citation: seven authors in order, 2026, CWF, Ottawa, Ontario.

Upper Fording monitoring
7 OK. Title page: Thorley, Kortello A.D., Brooks; June 09 2023; "Prepared for: Teck Coal Ltd., Sparwood, BC".

Upper Fording Evaluation of Cause (synthesis, SME reports, review)
8 OK. Cite line: Evaluation of Cause Team, 2021, "prepared for Teck Coal Limited by Evaluation of Cause Team". Place
  blank, none given.
9 OK. Citation: Bollinger 2021, prepared by TKB. "Prepared for" Calgary.
10 OK. Same as row 9; August 4 2021.
11 OK. Suggested citation: Dean, D. 2021, VAST. "Prepared For: TECK Coal Limited, Sparwood, BC". Title page March 2021.
12 OK. "Prepared For … Sparwood, BC". Title page February 2021. No cite line; title page authors Denis Dean.
13 OK. Citation: Healey, Little, Hatfield; "Prepared for" Sparwood; March 25 2021.
14 OK. Citation: Hatfield & Whelan; Sparwood; March 15 2021.
15 OK. Citation: five authors; Ecofish and Lotic; Sparwood; title page "June, 2021" (row gives year only).
16 OK. Citation: five authors; Sparwood; April 19 2021.
17 OK. Suggested citation: DiMauro, Branton, Franz; Azimuth. No Teck address, so place blank.
18 OK. Citation: four authors; Sparwood; April 16 2021.
19 OK. Citation: six authors; three firms; Sparwood; 2021.
20 OK. Citation: Harwood, Suzanne, Whelan, Hatfield; "Prepared for" Calgary; March 25 2021.
21 OK. Suggested citation: "Report Prepared for Teck Coal Limited, Sparwood, BC … Westslope Fisheries Ltd."; Sept 2020.
22 OK. Suggested citation: Costa & de Bruyn 2021, "prepared for Teck Coal Limited by Golder"; 19136042/R03. No Teck
   place, so blank.
23 OK. Signature page and synthesis: Henry & Humphries; December 7 2021; no place.
24 OK. Citation: Wright, Greenacre, Hatfield; Sparwood; December 9 2021.
25 OK. Title page: "Prepared for: Teck Coal Limited, Sparwood, British Columbia"; Minnow; March 2021.
26 reportType does not match its document (finding 4). Date 2021-05-10 is from the cover; the Preferred Citation says
   "2020 … November 9 2020" (a draft's date). The cover is the issued title page, so the date stands.
27 OK. Suggested citation: Korman & Branton 2021; the three firms; no place.

FWCP
28 OK. "Prepared for: FWCP; Prepared by: Heather M Lamson"; UF-F16-105; place blank.
29 OK. Same as row 28; UKE-F18-F-2461; Project Year 2 (2017/18).
30 Place is wrong: the title page puts the FWCP in Castlegar (finding 2). Creators, number and date (March 2016) OK.
31 Place is the preparer's, not the FWCP's (finding 2). Rest OK: VAST Resource Solutions; August 7 2019; FWCP and CBT.
32 Place is the preparer's (finding 2). Rest OK: Columbia Outdoor School; Draft Final Report; March 2020.

Harmer Creek Evaluation of Cause (synthesis, SME reports, telemetry memo)
33 Fixed fields OK (Task 1). Place unsupported (finding 3).
34 OK. Citation: Wright, Little, Hatfield; "Consultant's report prepared for Teck Coal Limited by Ecofish"; Sparwood;
   December 1 2022.
35 OK. Citation: Abell, Yu, Braga, Hatfield; same series form; Sparwood.
36 OK. Citation: Hocking, Cloutier, Braga, Hatfield; same series form; Sparwood.
37 OK. Citation: Durston & Hatfield; same series form; Sparwood.
38 OK. Suggested citation: Wiebe, Orr, Ings 2022, "Report prepared for Teck Coal Limited. Prepared by Minnow";
   "Sparwood, British Columbia"; November 2022.
39 OK. Same as row 38 (Sediment Quality).
40 OK. Title page: Thorley, Hussein, Amish; "Prepared for: Teck Coal Ltd., Sparwood, BC"; November 23 2022.
   `institution` normalised to Limited, the same entity.
41 Authors OK (signature page de Bruyn, Bollinger, Luoma, in the synthesis's order). reportType matches the cover
   ("Submitted to … Submitted by …"); 9 December 2022. Place unsupported (finding 3).
42 OK. Signature page Warner & Lancaster; cover "Submitted to: Teck Coal Limited, 603 Pine Avenue, Sparwood, BC";
   21452261-003-R-Rev1; 6 December 2022.
43 Authors, date and memo form OK (FROM Akaoka & Hatfield; December 1 2022). Place unsupported (finding 3).

Grave and Harmer monitoring
44 OK. Title page: Thorley, Kortello A.K., Robinson; July 12 2021; "Prepared for: Teck Coal Ltd., Sparwood, BC"; the
   three firms from the overview sheet.
45 OK. Suggested citation: four authors; "A Poisson Consulting and Lotic Environmental report"; June 19 2022. The
   synthesis's reference list adds Grylloblatta. The row follows its own document, which is correct.
46 OK. Title page: Thorley, Branton, Brooks; three firms; June 09 2023; Sparwood.

Calcite 2018-2020
47 Place is wrong (finding 1). Authors, date (August 1 2019) and reportType ("Consultant's report prepared for Teck
   Coal by Ecofish") OK against the citation.
48 Place is wrong (finding 1). Authors (six), July 27 2020 and reportType OK.
49 Place is wrong (finding 1). Authors (seven), September 10 2021 and reportType ("… Ecofish Research Ltd. and Minnow
   Environmental Ltd.", as the citation prints it) OK.

Does any expert report's own citation line name its series team, or authors other than the row's? No. Every SME
report's citation or signature page names the row's authors in the row's order. The "Citations for Evaluation of Cause
Team Reports" sections cite the team only for the synthesis, as "Harmer Creek Evaluation of Cause Team (2023)" (the
small-population and surface-water reports, among others).

## Task 3: the rest of the diff

- Leak grep over every added line of `_diff.txt` (home paths, user and host names, credential files, library ids):
  no hit.
- The CLAUDE.md edit ("joins a store at its next `0150 ACTION=update` with the store's whole build list (cred 0.7.0,
  cred#44)") agrees with `scripts/README.md:24` and `0150`'s `update` action. No other line still says a full build
  is needed.
- The `scripts/README.md` lines (`--collection westslope_cutthroat --parent 9U54XAND`, `COLLECTIONS=TIDR3PNN`) agree
  with the logs.
- Members CSV: after round 1's fix, both Harmer members' `source` reads correctly. No new issue.

## Verdict

Two field errors against their own documents: place on rows 47-49 (Calgary) and row 30 (Castlegar). Rows 31-32 follow
the same wrong rule (the preparer's place). Two rows carry sibling-copied values their documents do not support: place
on rows 33/41/43, and row 26's reportType. One planning line is stale. Round 1's fix is right in every field it
touched. The local Zotero database has not yet synced the PATCH.
