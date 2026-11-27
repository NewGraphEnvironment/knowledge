# Code-check round 3, #284 (HEAD 9267a555)

## Checklist read

- `code-check-python.md`: in full.
- `code-check-r.md`: 13 headings read (Read-back shape must match write-back shape; A `data-raw/` script must load the
  source tree; A database driver's value is not a base R type; A value compared as `::text`; `nzchar(NA)`; `paste()`
  with a zero-length argument; `strsplit()` drops a trailing empty field; CSV whitespace; `vapply(..., USE.NAMES =
  FALSE)`; `match()` treats NA; Postgres row order; Rscript reads a script as it runs; `ifelse()` with an all-NA
  test). 119 not read.
- `code-check-shell.md`: 3 headings read (Quoting; `a && b || c`; `pipefail` fails `cmd | head -N | grep -q`). 72 not
  read.
- `code-check-spatial.md`: 6 headings read (A name is not a key; A Freshwater Atlas main stem's downstream end; FWA
  `upstream_route_measure`; FWA main flow is not edge type 1000 alone; FWA lookup area follows watershed codes; A
  relation between FWA watershed codes is not a place). 92 not read.
- `code-check.md`: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped). The rules
  outside Mechanisms not read.

## The mechanism

Every summary sentence about the records (In brief, "What this means", Gaps, the README row, the `why` column of
`data/coho_additions.csv`, the script header) is written by hand from the writer's reading of the records, not derived
from the per-record table at the commit it is printed against. The table and each summary are two lists that agree only
where the writer's reading matched the table's. Three readings have diverged from the table so far:

1. **A group's evidence is the records that carry its group code** (round 2: NAZR missed, its NuSEDS population has no
   group).
2. **"Survey" means an unqualified survey.** The verdict scheme (lines 30-32) and the count of 15 include "survey,
   report not held" and "survey, report not named"; the In brief's place list and its "leaves out two with surveys"
   count only the unqualified ones, without saying so. STUL's Ocock Lake survey falls in the gap (finding 1).
3. **A count written before round 1 moved the population was not re-derived after it.** Round 1's local-code fix added
   the Swift River 2004 entry (25 bcfishobs records, not 24); the `why` written on 2026-11-26 still counts four 2004
   entries citing the draft (finding 2), and the script header still dates the counts 2026-11-26.

A fourth instance of the same family is an inferred cause stated as fact: why the FRAN collections are absent from the
FDIS evidence (finding 3).

## Claims checked

Sources: CSV = `scripts/logs/coho/20261127_coho_upper_fraser_records.csv`; DB = `fwapg` (bcfishobs.observations,
whse_basemapping), read-only, 2026-11-27; link = `link::lnk_load_overrides(link::lnk_config("default"))$wsg_species_presence`
(link 0.78.1); PDF = the scratchpad copies, pages found with `pdftotext` per page; gate = `scripts/logs/habitat/20261127_literature_verify_research.csv`.

| # | claim (file:line) | source | verdict |
|---|---|---|---|
| 1 | coho_upper_fraser.md:5-7 log path, "31 records", "complete for the 31 records" | CSV: 31 rows | holds |
| 2 | :6-7 every quote checked by 0280, file in `QUOTED` | `QUOTED_DEFAULT`; gate: 5 rows `verified_text`, all 5 quotes still in the file | holds (gate line numbers 42-102 are from 7a8f47a5, before rounds 1-2 moved them; quotes unchanged) |
| 3 | :10 pages printed, Westworth's the PDF's | PDF: Irvine 2001 PDF 13 = p. 12; Decker & Irvine PDF 31 = p. 21; Arbeider PDF 36 = p. 25, PDF 39 = p. 28; Westworth PDF 40 | holds |
| 4 | :14 confirmed by survey through the Nechako system, no further up the Fraser | CSV + DB codes: no survey with second part > 567134 outside 100.567134 | holds |
| 5 | :15-16 "Fish were caught or counted in" Nechako, Dahl, FRAN, Ahbau, West Road, Nazko | table verdicts | **fails as a list**: omits three survey records the file's own scheme counts (Fraser mainstem EEM 1996, COTR; Greer Creek 1978, NECR; Ocock Lake 1976, STUL). Finding 1 |
| 6 | :16 every one at or below the Nechako confluence | DB: all ≤ 567134 | holds |
| 7 | :17 above the Nechako confluence two records | DB: WILL 100.594120, BOWR 100.654493; no NuSEDS or FDIS row above | holds |
| 8 | :17-19 Bowron 2004 draft entry, DFO calls unconfirmed; Willow, Slade Creek 1995, community advisor | CSV source_ref; Decker p. 21, Arbeider p. 28 | holds |
| 9 | :20 "takes in two groups on compilations alone" | table: BOWR's record is `doubtful`, WILL's `compilation` | loose (BOWR's verdict is doubtful); part of finding 1 |
| 10 | :20 "leaves out two with surveys" | table + link: NAZR (survey), FRAN (survey), STUL (`obs:7a98d34717`, survey, report not held) all outside | **fails**: three. Finding 1 |
| 11 | :21-22 NAZR spawners, FRAN fry 2018 | CSV nuseds:44756, obs:026afad5a5 | holds |
| 12 | :22 "STUL and STUR, where DFO names coho seen in the Stuart system" | DB: Kuzkwa River 67/67 lines LTRE, Kazchek Creek 30/30 MIDR; line 56 says so | **fails**: DFO's named streams are in neither group. Finding 1 |
| 13 | :22, :118 BOWR, WILL in; CHES, FRAN, NAZR, STUL, STUR out | link: BOWR t, WILL t, others blank | holds |
| 14 | :26-28 three record sets, upstream of the Quesnel's mouth | script; DB: Quesnel River = 100.458399 | holds |
| 15 | :38 15 surveys, 13 compilations, 2 doubtful, 1 no observation | table, tallied row by row | holds |
| 16 | :42-56 quotes and attributions (Irvine 2001, Decker & Irvine 2013, Arbeider 2020 ×2) | PDF + gate | holds |
| 17 | :54 two Stuart system streams no record holds | DB: Kuzkwa 100.567134.179319.815989.290384, Kazchek …815989.532920.067591; no table row | holds |
| 18 | :56 Kuzkwa in LTRE, Kazchek in MIDR | DB line counts | holds |
| 19 | :61-63 order up the Fraser (Fraser, Cottonwood, West Road, Naver, Nechako, Willow, Bowron) | DB codes 461605 < 478686 < 500560 < 520500 < 567134 < 594120 < 654493 | holds |
| 20 | :67-97 each row's group, place, date, source | CSV, all 31 rows | holds |
| 21 | :73, :79, :80, :91, :70 NuSEDS summaries (6 spawners peak live expanded; 100/present/none; present/6; present unknown; not inspected) | CSV detail | holds |
| 22 | :72 FDIS one coho, measured | CSV n_caught 1, measured 1 | holds |
| 23 | :101 the five 2004 entries cite the consultative draft | CSV source_ref, 5 of 5 | holds |
| 24 | :102-103 two also cite Irvine 2001; each dated 1 January 2004 | CSV | holds |
| 25 | :104 West Road and Nechako entries agree with surveys; Swift River and Stuart entries stand alone | table | Swift holds; Stuart holds only for the Stuart River itself: Ocock Lake (100.567134.179319.…) is a Stuart system survey. Part of finding 1 |
| 26 | :105-106 Swift entry on a Fraser side channel at the Cottonwood's mouth, Fraser's code | DB: wscode 100, localcode 100.478686, edge 1350/1450, unnamed | holds |
| 27 | :107 Bowron doubtful, 2013 and 2020 call it unconfirmed | PDF | holds |
| 28 | :108-110 Dahl lowest reach, quote p. 40, Province dates Dec 1998, sampling 1996 | PDF p. 40 ("RSS #1 ... near the mouth", "sampled in September, 1996"); CSV 1998-12-01 | holds |
| 29 | :111 FRAN one site and date, two ids | DB: same blue line and measure (356325596, 436 m), CSV same date | holds |
| 30 | :111-112 neither in the published FDIS evidence | `data/fdis/derived/visits_link.csv`: no 233885_ or 245547_ visit | holds |
| 31 | :112 "because the extract it was built from holds electrofishing only" | raw extracts: max collection id 237837 (2020-11-16), 243935 (2022-03-22 Details) | **fails**: 245547 is past every id in both extracts. Finding 3 |
| 32 | :113 Ocock Lake 1.26 km from a mapped stream | DB distance_to_stream 1255.8 m, match type D | holds |
| 33 | :114 Slade record lands on Tregillus Creek, which Slade flows into | DB: blue line is Tregillus Creek; Slade Creek 100.594120.845867.799925 | holds |
| 34 | :118-119 "the five groups here that hold coho records and are outside it" | link + DB | holds as scoped (NuSEDS placed by majority of lines). The Nechako and West Road NuSEDS rivers also run through LEUT, LNRS, UNRS and EUCL, all outside the range, which by the reach-group convention join no group |
| 35 | :121-128 per-group bullets (BOWR doubtful; WILL compilation; NAZR present 1999, 6 in 2001, 370 of 371 lines; FRAN most recent survey 2018; CHES 1994 compilation; STUL/STUR 1976 survey + 2004 compilation) | CSV, DB (Nazko: NAZR 370, BLAR 1) | holds |
| 36 | :131-133 conclusion | table | holds |
| 37 | :137-139 four survey records on a citation or bare entry | table: c3caf22396, c1262aeb8a, 7a98d34717, bb1787d1bf | holds |
| 38 | :139-142 five on FDIS field records; Triton 2010 not retrieved | table: 94e4f8d30d, fdis:172649_1_1, 026afad5a5, 785aff6b11, 02652e805d; scratchpad `triton2010_fry.pdf` is an HTML page | holds |
| 39 | research/README.md coho row (verdict set, reach, Bowron/Willow, in/out lists, 0280) | as rows 4, 8, 13, 2 | holds |
| 40 | data-raw/coho_upper_fraser_records.R:46-52 cut at Quesnel's 458399; 36 between 52.7 and 52.8 | DB; log txt 41 and 31 | holds |
| 41 | :62-65 stops unless 25 in 10 groups, one FDIS visit, five NuSEDS; "(2026-11-26 ...)"; #284's body named three | log txt; issue body | counts hold; the date is the FDIS and NuSEDS counts', the 25 is 2026-11-27's (the stop message at :127 says so). Not material |
| 42 | CLAUDE.md coho row (sole input of `coho`, one of `habitat_modelling`'s; contents) | scripts/README build lists; additions/members | holds |
| 43 | CLAUDE.md, scripts/README.md, 0150 cred 0.8.1 text (fresh file, size of a fresh build; 0150 refuses older) | cred 0.8.1 NEWS; 0150:225; update log 49 added 0 dropped | holds |
| 44 | scripts/README.md coho paragraph (ZPUIT73I alone; Sandercock; DFO assessments 2000-2021; COSEWIC 2002 and 2016; ZPUIT73I in habitat_modelling) | additions (11 DFO documents 2000-2021), members; build log 55 keys, 1 collection; update log 466 keys, 11 collections | holds |
| 45 | inst/NOTICE.md Known BC Fish Observations under OGL-BC; paths | BC catalogue API: "Open Government Licence - British Columbia"; glob matches the CSV | holds |
| 46 | data/coho_additions.csv Irvine 2001 `why`: two 2004 records | CSV: 93f8af4399, f1f6bf3008 | holds |
| 47 | data/coho_additions.csv Bradford & Wood 2004 `why`: "four 2004 upper Fraser records" | CSV: five cite the draft | **fails**. Finding 2 |
| 48 | data/coho_additions.csv Bradford et al. 1997 `why` (stream length, latitude, 86 streams) | PDF abstract | holds |
| 49 | Script code: `upstream()` NA handling, NuSEDS rows with no code or a bare Fraser code | NuSEDS v1: 1,985 coho rows with no code, none in the upper Fraser (areas 1-29K); bare-Fraser-coded coho are Maria and Nicomen sloughs | holds |

## Findings

- **[severity: bug]** research/coho_upper_fraser.md:20-22 (In brief, third bullet), with :15-16 and :104 — "leaves out
  two with surveys" is wrong under the file's own verdicts: STUL holds `obs:7a98d34717`, verdict "survey, report not
  held" (line 95), and is outside link's range, so three excluded groups hold a survey (NAZR, FRAN, STUL); "What this
  means" (line 128) says STUL holds "a 1976 lake survey", so the two sections contradict. The same bullet places DFO's
  Stuart system sightings in STUL and STUR ("STUL and STUR, where DFO names coho seen in the Stuart system"), but the
  two streams DFO names lie in LTRE and MIDR (line 56; DB: Kuzkwa 67/67 lines LTRE, Kazchek 30/30 MIDR). The first
  bullet's list of where fish were "caught or counted" leaves out the same qualified surveys (Fraser mainstem EEM 1996,
  Greer Creek 1978, Ocock Lake 1976), and line 104's "the Stuart entries stand alone" ignores that Ocock Lake is a
  Stuart system survey. The bullet is the one a reader takes to decide which groups link's coho range should gain, so
  under-counting by one group is a decision-level error. Either count every survey verdict (three groups; Ocock Lake in
  the list) or say the In brief counts only surveys whose report or field record is held and keep that criterion in
  every summary. The issue #284 body's Outcome repeats "leaves out NAZR ... and FRAN" and "the reports behind six survey
  records" (the research file's Gaps give four plus five), so it follows whichever fix lands.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ; code-check.md "One fact derived twice"
- **[severity: bug]** data/coho_additions.csv:5 (Bradford & Wood 2004, `why`) — "which the Province's observations
  cite for four 2004 upper Fraser records": five cite the consultative draft (`obs:c51f92359e`, `obs:93f8af4399`,
  `obs:f1f6bf3008`, `obs:d578bf599c`, `obs:59bce25800`), as research/coho_upper_fraser.md:101 lists. The `why` was
  written on 2026-11-26 against the 24-record cut; round 1's local-code fix added the Swift River 2004 entry and the
  count was not re-derived. The research file's 2004 note and this row now disagree.
  - **Rule:** code-check.md "Written data outlives the fix" ; code-check.md "One fact derived twice"
- **[severity: bug]** research/coho_upper_fraser.md:111-112 — "Neither is in the published FDIS evidence, because the
  extract it was built from holds electrofishing only" states a cause the evidence does not establish, and the
  sentence's own clause says the observation records no method. Collection 245547 lies past every collection id in
  both extracts (highest 237837 in `data/fdis/2020-11-16/visits.csv`, 243935 in `data/fdis/2022-03-22-ef-export/Details4_3.csv`),
  so it was loaded after them and would be absent whatever its method; only 233885 falls inside the 2020 extract's
  range. A reader takes the sentence to mean the 2018 fry were caught by another method than electrofishing. Say that
  neither collection is in the extracts (one was loaded after them), without the method as the cause.
  - **Rule:** code-check.md "The probe is broken before the world is"

index, diff and changed files read from file
