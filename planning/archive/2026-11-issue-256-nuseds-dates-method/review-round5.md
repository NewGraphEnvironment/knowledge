# Code-check round 5 (#256): is the mechanism closed?

## Checklist read

- `code-check-python.md` in full (no Python in the diff; nothing applies).
- `code-check.md`: the index in full, and the prose (tables skipped) of every H3 under `## Mechanisms`, with
  "One fact derived twice", "A proxy is not the property", "Written data outlives the fix", "A fix lands in one of
  two callers that share a harness" and "A guard that fails toward pass" read closely.
- `code-check-r.md`: index in full; sections read for the shapes the diff uses: "`ifelse()` with an all-NA test
  returns a logical vector, whatever `yes` and `no` are" (nuseds_season, nuseds_mid, mid(), edge_*_day: every test is
  non-NA, and an all-NA nuseds_mid returns NA_integer_), "`match()` treats NA as a matchable VALUE" (nuseds_place:
  both callers drop NA codes first), "A `data-raw/` script must load the source tree" (both scripts `load_all()`),
  "`$` on a list partial-matches" (every column read exists), "`sort()` and `order()` collate by `LC_COLLATE`".
- `code-check-shell.md`: index in full; the RUN lines' `set -o pipefail`/`tee`/`cp` shape is right.
- `code-check-spatial.md`: index in full; "A relation between FWA watershed codes is not a place" (the apart rule
  already answers it).

Abbreviations: C = `scripts/logs/timing/20261124_nuseds_dates_check.txt`, T = `20261124_timing_nuseds.txt`,
W = `20261124_timing_nuseds_windows.csv`, P = a probe on the published Parquet (read-only; `nuseds_survey()` sourced
from the branch, no database).

## 1. Sets each script still defines itself

| script:line | set or quantity | also defined where | can they disagree? |
|---|---|---|---|
| check:64 `dated` (start from or to, or end) | the check's population | timing:104 `dated` (#240's) | by design (accepted); both printed and labelled |
| check:79-84 `form()` single start = from, else to | start forms (C:7-15) | check:111 day-of-month table reads `start_spawn_dt_from` only | **yes, today**: the 15th holds 42,491 single starts by the form table's definition, 42,489 by line 111's (P). Finding 2 |
| check:97-99 `width()`/`cls()` | bins over 31 days, reversed | nuseds_mid()'s `w` | no: same season-year arithmetic, same > 31 cut |
| check:121-123 `wb` (written-year backwards) | 165 / 98 / 67 | none | n/a |
| check:131-135 survey_started, survey_ended, start/end_before/after_survey, survey_dated | denominators | none in timing | n/a |
| check:162-166 fence, exact, auc, bracket, `whole` | rules a2-a5, b, c, d | none in timing | n/a |
| check:227 `"all: dated records (a start or an end), present"` = `x$method` | pooled-group "all" row | nuseds_survey() `method` = present **and not backwards** | label omits "not backwards" (98 records, C:54); not quoted anywhere. Finding 6 |
| check:233 `k >= 5` | "groups with 5 or more" | timing:93 `edge_min <- 5L` | only while both are 5; agree today (W g5: CH 19/19 = C:191, C:197). Finding 5 |
| timing:117-118 has_start/has_end | the bulk's printed counts | — | by design (accepted) |
| timing:171-179, 198, 202, 209 `has_date`/keys/pop rows = as-recorded `start_day`/`end_day` | which windows exist | nuseds_survey() `method`/`start_mid` (the bulk's records); check's `dated` | **can**: a key or population whose only present start is a `start_spawn_dt_to` with no end gets no window; agree today (P: the 7 such records' 6 populations all appear in W; check "all" groups_1 sums to 356 = W groups with any bulk 356; a3s/a3e pooled sums per species equal C:191-202). Finding 5 |

## 2. Every quantitative or quantified claim

### research/nuseds_timing.md, "What a NuSEDS spawning date is"

| line | claim | source | set named = set counted? |
|---|---|---|---|
| 16 | 102,807 dated records (start or end) | C:4 | yes |
| 16 | #240's 102,800 count a start only as `_from` | T:3; 102,807 − C:3's 7 | yes |
| 20 | grid start on 91 to 94 % of starts before 1990 | C:9-11: 31271/33950 = 92.1, 17684/19418 = 91.1, 19375/20595 = 94.1 | yes (starts) |
| 20 | the 15th alone holds 42,489 single starts | C:51 | **no**: line 111 counts `_from` singles; single starts by the form table's definition on the 15th are 42,491 (P). Finding 2 |
| 21 | ten-day bins 1-10, 11-20, 21-end | C:47 15,652 of 15,678 | yes |
| 21-22 | 3,009 of 12,086 starts in the 1990s; 7,157 of 7,455 from 2010 | C:12 (12542 − 456), C:14 (8175 − 720) | yes |
| 22 | 15,678 start bins, 15,005 of 10-11 days, 664 longer, 2 backwards | C:15, C:41-45 (654 + 10) | yes |
| 23 | 372 set aside | C:53 | yes |
| 24-25 | start precedes survey on 10,249 of 21,773 before 1970, 1,341 of 7,117 from 2010 | C:63, C:68 | yes (records with a start and a compared first day) |
| 25-26 | 21 records before 1980 give a visit count | C:63-64 (16 + 5) | yes |
| 27 | 3,725 NONE OBSERVED | C:81 | yes |
| 27-28 | of 2,479 with both survey dates, 1,910 overlap; none gives a count above 0 | C:91 | yes |
| 29 | 332 NOT INSPECTED; #240's windows count both | C:93; timing rec_ reads every record | yes |
| 30 | Unknown Estimate Method on 82,437 | C:73 | yes |
| 34 | upper Bulkley 40 dated records | C:447 | yes |
| 34-35 | 1953-1991, 27 records; most often 15 Aug and 15 Sep; no visit count; mostly no survey dates; Unknown method | C:366-385, 399-405, 407-426, 440-446 (17 of 27 starts on 15 Aug; 13 ends on 15 Sep; all visits NA; 9 of 27 with any survey date) | yes |
| 35-36 | Buck Creek 1977, 1978, 1983 NONE OBSERVED, full window | C:449, C:400-403 | yes |
| 36-37 | 2008-2020, 13 records, ten-day bins, 1 to 4 visits, mostly Peak Live + Dead | C:386-398, C:427-439 (11 of 13) | yes |
| 37-39 | start precedes survey on five: 2009 (one visit, 10 Sep), 2016 (from 28 Aug), 2017 (from 30 Sep), each 11-20 Aug, and 2018, 2019 | C:448, C:387, 394, 395, 396, 397 | yes |
| 39-40 | also mainstem 1986-1988 and Buck Creek 1982, 1988 | C:448 | yes |
| 41 | no record shows a visit that found no spawners | NuSEDS has no per-visit count (by construction) | yes |
| 41-42 | 2020 survey 20 Oct 2008 to 20 Sep 2030 | C:398; nuseds_date() centuries | yes |
| 42-43 | 372: 98 off-year, 309 reversed, 35 both | C:53 (98 + 309 − 35) | yes |
| 46 | to 1991: 34 of 39 Morice, 19 of 21 Nanika on the grid | C:361-362 | yes |
| 46 | median 2 visits | C:361-362 | yes |
| 47 | start before survey on 15 of 24 Morice, 9 of 15 Nanika with a first day | C:361-362 | yes |
| 48 | from 1995, 24 of 25 starts in each are bins | C:359-360 (grid 1 + bin 24 = records 25) | yes |
| 48 | median 4 visits | C:359-360 | yes |
| 48-49 | 16 Morice, 12 Nanika AUC | C:359-360 | yes |
| 49-50 | 5 Morice, 4 Nanika with a 3+-visit survey before the start | C:359-360 (`edge_start`); P: `start_bracket3` 5 and 4, all present | yes |
| 51 | start precedes survey on 8 of 20 Morice, 10 of 19 Nanika | C:359-360 | yes |

### "Which records can bound an edge"

| line | claim | source | set? |
|---|---|---|---|
| 55-56 | ten rules over present records: a3s over those giving a start, a3e an end, the others both | check:167-182 | a3s/a3e admit only starts/ends with a midpoint (`edge_start` needs `start_mid`); see finding 3 |
| 56-57 | six shown; a2, a4, a5 vary a3; a fourth joins a3 and c | C:105-115 | yes |
| 61-66 | a3 2,076 / 12; a3s 7,023 / 19; a3e 3,849 / 19; b 560 / 1; c 1,605 / 15; d 3,679 / 13 | C:107-114 (`all`), C:173, 191, 197, 203, 209, 215 (`groups_5`) | yes (records province-wide incl. uncoded, accepted; groups pooled) |
| 68-70 | the test: under half the present rate over the rule's base; at most half on the grid | check:194-207 | yes |
| 70 | every rule but b passes | C:119-128 | yes |
| 71 | NONE OBSERVED at 0.14 of the present rate or less | C:119-128 max 0.14 | yes |
| 71-72 | 1990s separation holds; a3 5.8 % vs 0.4 % | C:135 and its continuation C:142, 149 (every rule under half) | yes (base `whole`) |
| 73 | fence fails on the grid, 63 % | C:125 grid_share | yes |
| 73-74 | start a median 20 days after arrival | C:153 | yes |
| 77 | three visits the fewest for before, during, after | reasoning | — |
| 79-80 | d's records with 3+ visits beyond an edge are counted in a3s or a3e | none printed; P: 2 of 2,812 are in neither | **UNSUPPORTED and false**. Finding 3 |
| 81 | edge only where 5 or more qualify | timing:93, 137, 159-160 | yes |

### "The window: bulk, peak and edges"

| line | claim | source | set? |
|---|---|---|---|
| 90 | every one of 6,112 rows equals #240's | W vs 20261121 W: 6,112 rows each, 0 cells differ (rec_ vs #240's columns) | yes |
| 92-93 | 98,698 PRESENT, 43 UNKNOWN, 2 nothing | C:59 prints **98,705** | **no**: 98,698 is #240's 102,800-record set (98,698 + 43 + 2 + 3,725 + 332 = 102,800), the file's dated records are 102,807. Finding 1 |
| 95-96 | a start given only as `_to` enters the bulk | nuseds_survey() start_mid; W UFRA bulk_n_start 124 vs rec 123 | yes (holds while finding 5 holds) |
| 97 | four or five days for a ten-day bin | nuseds_mid() `%/% 2` | yes |
| 97 | 664 start and 1,573 end bins longer than 11 days | C:44-45 (654 + 10; 1562 + 11) | yes |
| 98 | 21 longer than 31 days give no midpoint | C:45 (10 + 11); nuseds_mid() `w > 31` | yes |
| 100-101 | UFRA peaks to 2014, bulk to 2008, as-recorded to 2000 | W UFRA CH group: peak_last_year 2014, bulk_last_year 2008, last_year 2000 | yes |
| 103 | 162 of 357 with a start edge, 124 an end edge; chinook 24 of 81 | T:10; W | yes |

### "What a NuSEDS window may claim beside a cited row"

Template only; its slots are filled in the UFRA and COTR notes (below). No number.

### "Spawning past the new year"

| line | claim | source | set? |
|---|---|---|---|
| 141 | about 3,000 coho and chum ends in January-March (coho 2,512, chum 540) | no log line (unchanged from #240, and no #240 log prints it); P: 2,512 and 540 by the end's month | true, **UNSUPPORTED** by any printed line. Finding 4 |
| 143 | season year 1 April, 1 September for steelhead | nuseds_season_start | yes |
| 146-147 | 165 present end before start on written years; 98 forward (76 coho); 67 backwards either way, leave the bulk | C:55; 165 − 98 = 67; `method` excludes `backwards` | yes |
| 147-148 | a survey opening before the season start stays in its season | nuseds_survey() `early` | yes |
| 148-149 | a bin is halved after both ends are on the season year | nuseds_mid() | yes |

### "The four groups' rows beside NuSEDS"

| line | claim | source | set? |
|---|---|---|---|
| 159-172 | all 14 rows: row, bulk, peak, edges (with n), start, end, middle | T:14202-14229 (row and bulk/peak columns; d_start, d_end, d_mid, d_edge_*); W edge_n_start/edge_n_end (MORR CH end 9; MORR CO start 8; MORR SK 6 and 11; UFRA start 11) | yes, every cell |
| 174 | BULK chinook peak 1.5 days off the middle | T d_mid 1.5 | yes |
| 175-176 | BULK sockeye's bulk rests on 4 records | W bulk_n_start 4, bulk_n_end 4 | yes |
| 176 | MORR chinook end edge 09-25 on 9 records, 12 days before the row's end | W; T d_edge_end −12 | yes |
| 176-177 | MORR coho peak 23 days before the row's middle | T d_mid −23.0 | yes |
| 177-178 | MORR chinook migration differs by 37 days | T −37 | yes |
| 178-179 | BULK chinook pools seven tributary populations; the Bulkley's two reaches and the Morice apart | T:1246 (7 pooled, 3 apart), T:1247-1258 | yes |
| 182-183 | UFRA as-recorded 1967 to 2000, bulk to 2008 | W | yes |
| 183 | 20 of UFRA's 124 starts are bins; 6 of COTR's 35 | C:312-318 (start_bin, all forms summed), C:296-298 | yes (all starts; UFRA's and COTR's are all present: W bulk_n_start 124 and 35) |
| 183-184 | UFRA bulk 08-12 to 09-05, peak 08-24 over 172, 1967-2014; start edge 08-15 on 11 | W; C:264 | yes |
| 184 | COTR bulk 08-10 to 09-05, peak 08-24, no edge | W (edge_n 0 and 0) | yes |
| 185 | 83 of UFRA's 124 and 19 of COTR's 35 starts on the grid | C:312-318 start_grid; C:296-298 | yes |
| 186 | 28 of UFRA's 76 and 12 of COTR's 32 starts with a first day precede it | C:349-355 and C:333-335 (survey_started, start_before_survey) | yes |

### data/life_history_timing.csv, the four UFRA and COTR chinook notes

| row | sentence | source | set? |
|---|---|---|---|
| UFRA migration | #96's sentences (Bradford and Taylor; 08-11; arrival 08-01, 125 population-years, 1967-2000) | unchanged by the branch; #96's | out of scope |
| UFRA migration | start is an estimate; bulk start 08-12; 11 records of a 3+-visit survey before it put it at 08-15 | W UFRA CH bulk_start_median, edge_n_start 11, edge_start_median 08-15 | yes |
| UFRA spawning | #96's sentences (123 and 126, 1967-2000; Swift Creek 08-09 to 09-05, 27; mainstem 09-20, 15; Candy) | 20261118 log; unchanged | out of scope |
| UFRA spawning | no START_SPAWN_DT_FROM or end of spawning after 2000; peaks to 2014 | W last_year 2000 (from start_day/end_day), peak_last_year 2014 | yes |
| UFRA spawning | 83 of the 124 starts, one only as a bin's last day, on the grid; 28 of the 76 with a first day precede it | C:312-318, C:349-355; W rec_n_start 123 vs 124 | yes |
| UFRA spawning | bulk 08-12 to 09-05 over 124 and 126 (1967-2008), peak 08-24 (172, 1967-2014), start 08-15 on 11 records | W | yes |
| COTR migration | #96's sentences (Candy; 08-10; arrival 08-01, 23) | unchanged | out of scope |
| COTR migration | bulk start the same day, 08-10; no record has the survey for an edge | W bulk_start_median 08-10, edge_n_start 0, edge_n_end 0; C:333-335 a3s/a3e 0 | yes |
| COTR spawning | #96's sentences (35 and 36, 1953-2009; three populations and their windows; Cottonwood; before 1975; Candy) | 20261118 log; unchanged | out of scope |
| COTR spawning | 19 of these 35 starts on the grid; 12 of the 32 with a first day precede it | C:296-298, C:333-335 | yes |
| COTR spawning | bulk 08-10 to 09-05 over 35 and 36 (1953-2009), peak 08-24 (40, 1953-2008); no edge | W | yes |

## Findings

- **[severity: bug]** research/nuseds_timing.md:92-93 — "98,698 dated records say PRESENT, 43 UNKNOWN and 2 nothing":
  the check log at HEAD prints PRESENT **98,705** (C:59). 98,698 is the count over #240's 102,800 dated records (round
  4 read it from the earlier log's C:58, before round 4 widened the check's population by the 7 records that give a
  start only as `start_spawn_dt_to`, all PRESENT); the file names 102,807 dated records at line 16, and 98,698 + 43 +
  2 + 3,725 + 332 = 102,800, not 102,807. Write 98,705.
  - **Rule:** code-check.md "Written data outlives the fix" ; code-check.md "One fact derived twice"

- **[severity: bug]** research/nuseds_timing.md:20 with data-raw/nuseds_dates_check.R:111 — "the 15th alone holds
  42,489 single starts": the check defines a single start twice. Its form table (check:79-84, C:7-15) reads a start as
  `start_spawn_dt_from`, else `start_spawn_dt_to`; its day-of-month table (check:111, C:51) reads
  `start_spawn_dt_from` only. On the Parquet, single starts on the 15th by the form table's definition are 42,491
  (two are given only as `_to`). Off by two, but the same mechanism: the sentence's set (the dated records' single
  starts) is not the set line 111 counts. Read `one` (from, else to) at line 111.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: bug]** research/nuseds_timing.md:79-80 — "d needs repeated counts but no visit beyond either edge (its
  records with 3 or more visits beyond an edge are counted in a3s or a3e)": no log prints this, and it is false. Of
  the 2,812 records rule d admits whose survey stands beyond an edge with 3+ visits (`start_bracket3 | end_bracket3`),
  2 are in neither a3s nor a3e (P): their start is bracketed but has no midpoint (a start bin over 31 days or running
  backwards), and `edge_start` requires `!is.na(start_mid)` (nuseds_dates_read.R, `edge_start`). The same gap makes
  line 55's "a3s over those giving a start" wider than the code's set (a3s admits starts with a midpoint). Either
  narrow the sentences to the code's definition ("with a start midpoint") or have the check print the count.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "One fact derived twice"

- **[severity: fragile]** research/nuseds_timing.md:141 — "coho 2,512, chum 540" is printed by no log line, the
  hand-probe half of the mechanism (round 4's fifth finding, not acted on or recorded as declined in findings.md). It
  is true on the Parquet (ends, `_to` else `_from`, in January to March over the 102,807: CO 2,512, CM 540). The
  sentence is #240's and unchanged by the branch, but #240's own logs do not print it either, so it is not in the
  out-of-scope class. Have the check print it, or record the decision to leave it.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: fragile]** data-raw/timing_nuseds.R:171-179, 198, 202, 209 against nuseds_survey()'s `method` and
  `start_mid` — which windows exist (group × species keys, run types, population rows, apart keys) is still decided
  by #240's as-recorded dates (`start_day`/`end_day`), while the bulk and edges count the records nuseds_survey()
  admits, which include a start given only as `start_spawn_dt_to`. A key or population whose only present start is
  such a record, with no end, gets no window, so its bulk and any edge vanish from W and from every group count
  quoted (357, 162, 124, 24 of 81) while the check's "all", a3s and a3e pooled counts include it; the check's
  `out_edge` guard (check:65-69) covers only records outside the check's dated set, not these. It agrees today: the 7
  such records' six populations all appear in W, the check's "all" groups_1 sums to 356 and W's group windows with any
  bulk record are 356, and W's a3s/a3e sums per species equal C:191-202. Separately, "5 or more" is two literals that
  agree only while both are 5: the check's `k >= 5` (check:233, the table's "chinook groups with 5 or more") and the
  windows' `edge_min` (timing:93). Key `has_date` on the bulk's records (or start from or to, or end), and read the
  check's 5 from one constant.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness" ; code-check.md "One fact derived twice"

- **[severity: fragile]** data-raw/nuseds_dates_check.R:227 — the pooled-groups row is labelled "all: dated records
  (a start or an end), present" but counts `x$method`, which also drops the 98 records that end before they start
  (C:54). Nothing quotes the row, but it is committed evidence naming a set the code does not count.
  - **Rule:** code-check.md "One fact derived twice"

Mechanism verdict: the record sets the two scripts share (bulk, peak, edges, survey slips) are defined once in
`nuseds_survey()`, and every number in the six sections and the four notes but the four above traces to a printed
line or a CSV cell over the set its sentence names. Still open: one stale number from before round 4's widening
(finding 1), one set defined twice inside the check (finding 2), one claim no line prints that is false (finding 3),
one inherited claim no line prints (finding 4), and the window-existence set that agrees with the bulk's only on
today's data (finding 5).
