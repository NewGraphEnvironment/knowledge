# Code-check round 1 — #190 branch (reviewer, 2026-11-11)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md` (read by heading): every H3 under `## Mechanisms` (prose, `|` rows skipped): A guard that fails
  toward pass; A fixture that cannot reach the failure mode; A proxy is not the property; Verification that reads its
  own output; A guard's scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness
  (opening); Restore the bug and prove the guard fires (opening); A wrapper's exit is not the work; Zero-length,
  empty, and unset are three different things; Written data outlives the fix; Serialization loses meaning silently;
  One fact derived twice. Also: Percent-encode a URL at construction, not at consumption; all four of `## Spreadsheets
  and PDFs` (A stored value is not wrong…; Verify PDF links from the annotations…; Extracted PDF text carries corrupted
  glyphs…; Merge PDFs with `qpdf`…). Not read: the other 26 H3s (none names a tool or shape this data-only diff uses);
  of the Mechanisms, "A shared working tree…" and "The probe is broken before the world is" skimmed only.
- `code-check-r.md` (read by heading): index lines scanned for CSV/serialization/PDF; none applies (no R changed, the
  CSVs are read by Python's `csv.DictReader`). 0 sections read in full; ~118 not read.
- `code-check-shell.md` (read by heading): index scanned for log/sed/pdf; none applies to a diff with no shell code.
  0 read; ~85 not read.
- `code-check-spatial.md`: index scanned; nothing spatial in the diff. 0 read.

## Method

- Every additions row (49): its Zotero item from `_pdfmap.csv` matched by title (49/49 matched), `pdftotext -f 1 -l 6`
  of the stored PDF, the title page and the "citation / cite / when citing" line read; image covers rendered
  (cyanobacteria, selenium) and read. Authors given "from the synthesis's reference list" checked against the Harmer
  synthesis text (de Bruyn, Bollinger & Luoma; Warner & Lancaster) and the UFR synthesis (Henry & Humphries).
- Every members row with a `pdf` (9): the stored PDF's first pages against the citation key's work.
- CSV shape: both files parse with `csv.DictReader` (36 × 3, 49 × 14, no ragged rows); every local `pdf` path exists
  (3 members, 14 additions) and sits under the ignored `data/rag/`.
- Counts in findings/progress recomputed from the logs and files: 36 members, 49 additions (35 URL + 14 local,
  217 MB local), 32 + 17 rows, 20 UFR EoC rows (synthesis + 18 SME additions + review; the 19th SME is the member
  Faulkner), dry run 1 `would 64` = 6 + 9 + 49, `pdf 15` = 9 + 6, live `58` PDFs = 9 + 49, 242.4 MB uploaded /
  438.5 MB `exists` (recomputed from the stored files' sizes per the live log: 242.4 / 438.5 MB), 85 − 12 = 73
  documents, 243,019,776 B / 8 MiB = 29 parts, query-log chunk counts (4; 1 + 4 = 5; 2 and 2; 5 and 2).
- Leak grep over every added line (home paths, user name, host names, credential paths, library ids, "personal
  library", private): no hit. The query log's truncated `/User…` origin column carries no user name.
- `cred#44` closed 2026-10-31, cred tag v0.7.0, and `0150` has `ACTION=update`: the CLAUDE.md edit holds.

## Findings

- **[bug (data)]** `data/westslope_cutthroat_additions.csv:34` (additions row 33, Harmer Creek synthesis, item
  `CQZTEEXK`) — `creators` is `{Evaluation of Cause Team}`, but the report's own "When citing the Evaluation of Cause
  Report use:" line reads "**Harmer Creek** Evaluation of Cause Team. (2023)…", and every Harmer SME report's
  "Citations for Evaluation of Cause Team Reports" section (selenium, calcite) and the synthesis's own reference
  list cite it the same way. The row copied the UFR synthesis's author (row 8, whose cite line does say "Evaluation of
  Cause Team"), i.e. a sibling, not its own cite line. The Zotero item carries the wrong corporate author (its key
  stays as is). Fix the row and PATCH the item's creator.
  - **Rule:** none

- **[fragile (data, record only)]** `data/westslope_cutthroat_members.csv:35-36` (members rows 34-35,
  `hocking_etal2022SubjectMatter`, `thorley_branton2022SubjectMatter`) — `source` says "group item outside the
  collection (**Upper Fording** series, with its PDF)", but both are Harmer Creek Evaluation of Cause SME reports
  ("Water Temperature and Ice. … Harmer Creek …", "Energetic Status … Harmer Creek …"; findings.md's decision-3 section
  says so). `0270` does not read `source`, so nothing filed is wrong; the tracked record is.
  - **Rule:** none

- **[fragile (planning record)]** `planning/active/task_plan.md:72` — "Write `data/westslope_cutthroat_members.csv`
  … and `data/westslope_cutthroat_additions.csv`; record per-source counts and MB in findings" is still `- [ ]`
  though both CSVs are committed and findings.md has the per-source table; likewise `:78` ("Al's hand downloads … (or
  those rows' `pdf` empty)") is unchecked though its stated alternative holds and the downloads moved to #191, and
  `:48` (members' PDFs) is open with its remainder owed in #191 without saying so. Reboot-test answers from the plan
  are wrong until flipped/annotated (the Validation box "PWF checkboxes match landed work" will catch it, but it is
  wrong now).
  - **Rule:** none

## Notes (checked, not findings)

- Additions row 1 `reportNumber` `En3-5/75-2016E-PDF` is not in the PDF (the registry print says "Catalogue no. to be
  included by SARA Responsible Agency"); the same series pattern as row 2's printed `En3-5/75-1-2023E-PDF`, so it
  comes from the catalogue. Unverifiable from the document, not shown wrong.
- Additions rows 3 (date `2025-07-24`, place Gatineau) and 5 (place Cranbrook): not on the printed pages (findings
  says the footer was dropped). Unverifiable, not shown wrong.
- Additions rows 47-49 `place` `Sparwood, BC`: the Ecofish title page's "Prepared for" block names Teck's Calgary
  address, which rows 9, 10 and 20 took for the same block; the Teck overview page in the same PDFs gives Sparwood.
  An inconsistency of rule between rows, both places are on each document.
- Additions row 26 institution `Teck Coal` (not "Limited"): matches its cover. Row 20 `Suzanne, C.` matches the
  citation line, the signature page ("C. Suzanne, MSc") and the synthesis.

## Per-row verdicts

### Additions (data row N = file line N + 1)

1 OK (title/creator/2017/series/Ottawa per recommended citation; reportNumber from catalogue, see notes)
2 OK (recommended citation; catalogue no. En3-5/75-1-2023E-PDF printed)
3 OK (title; date/place not on print, see notes)
4 OK (title, 2025-03-13, Vancouver)
5 OK (title, 2026-08-25)
6 OK (recommended citation: 7 authors in order, 2026, CWF, Ottawa)
7 OK (title page and suggested citation: Thorley, Kortello A.D., Brooks; 2023-06-09; Teck Coal Ltd.; Sparwood)
8 OK (cite line: Evaluation of Cause Team, 2021, prepared for Teck Coal Limited)
9 OK (Bollinger 2021-07-27, TKB, Calgary)
10 OK (Bollinger 2021-08-04, TKB, Calgary)
11 OK (Dean, March 2021, VAST, Sparwood)
12 OK (Dean, February 2021, VAST)
13 OK (Healey, Little, Hatfield; 2021-03-25; Ecofish)
14 OK (Hatfield & Whelan; 2021-03-15)
15 OK (Hocking, Ammerlaan, Healey, Akaoka, Hatfield; June 2021; Ecofish and Lotic)
16 OK (Faulkner, Sparling, Nicholl, Carter, Hatfield; 2021-04-19)
17 OK (DiMauro, Branton, Franz; June 2021; Azimuth)
18 OK (Durston, Greenacre, Ganshorn, Hatfield; 2021-04-16)
19 OK (Hocking, Tamminga, Arnett, Robinson, Larratt, Hatfield; 2021; three firms)
20 OK (Harwood, Suzanne, Whelan, Hatfield; 2021-03-25; Calgary)
21 OK (Cope; September 2020; Westslope Fisheries; Sparwood)
22 OK (Costa & de Bruyn; 2021-04-22; Golder 19136042/R03; pages 1-343)
23 OK (Henry & Humphries per UFR synthesis and qualifications section; 2021-12-07; SNC-Lavalin)
24 OK (Wright, Greenacre, Hatfield; 2021-12-09)
25 OK (Orr & Ings; March 2021; Minnow; Sparwood)
26 OK (cover image: title, Teck Coal, Larratt & Self, May 10 2021)
27 OK (Korman & Branton; August 2021; three firms)
28 OK (Lamson; UF-F16-105; 2015/16 report)
29 OK (Lamson; UKE-F18-F-2461; Project Year 2 (2017/18))
30 OK (VAST Resource Solutions Inc.; UF-F16-106; March 2016; Cranbrook)
31 OK (VAST Resource Solutions; UKE-F19-F-2746; 2019-08-07; FWCP and CBT)
32 OK (Columbia Outdoor School; COL-F20-F-3119; Draft Final; March 2020; Cranbrook)
33 WRONG creator: document's cite line names "Harmer Creek Evaluation of Cause Team" (finding 1); title, 2023, Teck OK
34 OK (Wright, Little, Hatfield; 2022-12-01)
35 OK (Abell, Yu, Braga, Hatfield; 2022-12-01)
36 OK (Hocking, Cloutier, Braga, Hatfield; 2022-12-01)
37 OK (Durston & Hatfield; 2022-12-01)
38 OK (Wiebe, Orr, Ings; November 2022; Minnow)
39 OK (Wiebe, Orr, Ings; November 2022; Minnow)
40 OK (Thorley, Hussein, Amish; 2022-11-23; Poisson and CGC)
41 OK (cover image: title, three submitting firms, 9 December 2022; authors per synthesis reference list)
42 OK (Golder 21452261-003-R-Rev1; 6 December 2022; Warner & Lancaster per synthesis reference list)
43 OK (memo: Akaoka & Hatfield; 2022-12-01)
44 OK (Thorley, Kortello A.K., Robinson; 2021-07-12; title page)
45 OK (Thorley, Kortello, Brooks, Robinson; 2022-06-19)
46 OK (Thorley, Branton, Brooks; 2023-06-09)
47 OK (title page title; Hocking, Vogt, Buren, Akaoka, Hatfield; 2019-08-01; place see notes)
48 OK (Hocking, Akaoka, Buren, Vogt, MacAdams, Hatfield; 2020-07-27; place see notes)
49 OK (Hocking, Braga, Buren, Vogt, Row, Ings, Hatfield; 2021-09-10; Ecofish and Minnow; place see notes)

### Members (data row N = file line N + 1)

1 b_c_ministryofenvironment2014ManagementPlan — pdf OK (BC MoE WCT management plan, Dec 2013 updated Aug 2014, 108 pp)
2 bcspecies&ecosystemexplorer2020Oncorhynchusclarkii — no pdf (gap, #191)
3 bear_etal2005ThermalRequirements — no pdf column; PDF already held
4 bear_etal2007ComparativeThermal — held
5 blackburn2017TrendsDistribution — no pdf (gap, #191)
6 blank_etal2020SwimmingPerformance — no pdf (gap, #191)
7 boyer_etal2008Rainbowtrout — no pdf (gap, #191)
8 brown1998Fallearly — pdf OK (Brown, Env. Biol. Fishes 55, 1999; the item's 1998 is a recorded gap)
9 brown_mackay1995Spawningecology — no pdf (gap, #191)
10 canada_departmentoffisheriesandoceans2019Recoverystrategy — held
11 cleator_etal2009InformationRelevant — held
12 cope_etal2016UpperFording — pdf OK (UFR population assessment and telemetry, final report Dec 2016)
13 cope_etal2017UpperFording — pdf OK (UFR population monitoring project: 2017)
14 dangelo_muhlfeld2011FactorsInfluencing — no pdf (gap, #191)
15 elkriveralliance2020ElkRiver — pdf OK (ERA WCT Research Initiative 2019 report, 28-06-2020)
16 hagen_baxter20092008Westslope — no pdf (no copy found; gap)
17 janowicz_etal2018Agegrowth — no pdf (gap, #191)
18 lamson2020EvaluationCurrent — pdf OK (Final Report UKE-F19-F-2682)
19 mayhood2014Conceptualframework — no pdf (gap, #191)
20 mayhood2019Comments2019 — no pdf (gap, #191)
21 muhlfeld_etal2012ASSESSINGIMPACTS — no pdf (gap, #191)
22 muhlfeld_etal2016GeneticStatus — pdf OK (TAFS 145:1093-1109, doi 10.1080/00028487.2016.1173587)
23 pierce_etal2014WestslopeCutthroat — no pdf (gap, #191)
24 schmetterling2001SeasonalMovements — held
25 schwarz_etal2013Integratingbatch — held
26 schweigert_etal2017COSEWICassessment — pdf OK (COSEWIC 2016 report; the item's 2017 is a recorded gap)
27 taylor_mochnacz2013ProtocolNative — pdf OK (Banff protocol, December 2013)
28 thorley_etal2022UpperFording — held
29 WESTSLOPECUTTHROATTROUTOncorhynchusclarkilewisi2004 — held
30 young_etal2017phylogeographywestslope — held
31 cope2020UpperFording — OK (UFR monitoring 2019, held)
32 thorley_etal2021UpperFording — OK (UFR monitoring 2020, held)
33 faulkner_etal2021SubjectMatter — OK (UFR channel dewatering SME, held)
34 hocking_etal2022SubjectMatter — `source` wrong: a Harmer Creek SME (water temperature and ice), not Upper Fording (finding 2)
35 thorley_branton2022SubjectMatter — `source` wrong: a Harmer Creek SME (energetic status), not Upper Fording (finding 2)
36 EnvironmentaldamagesfundcalllettersintentQukin?amak?is… — OK (EDF LOI applicant guide, held)

## Verdict

One wrong field against its own document (additions row 33's creator), one mislabelled record-only `source` on two
member rows, and stale checkboxes in task_plan.md. No public-repo leak; logs and planning counts agree.
