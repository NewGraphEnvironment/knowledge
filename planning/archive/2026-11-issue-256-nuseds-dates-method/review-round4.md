# Code-check round 4 (#256): is the "set defined twice" mechanism closed?

Reviewer: fresh round, branch `256-a-method-for-reading-nuseds-spawning-dat` at 1264e397, base f1e9ed7c. Probes ran in a
detached worktree on the published Parquet (read-only); nothing in the repo was written but this file.
Log abbreviations: **C** = `scripts/logs/timing/20261124_nuseds_dates_check.txt`, **T** =
`scripts/logs/timing/20261124_timing_nuseds.txt`, **W** = `scripts/logs/timing/20261124_timing_nuseds_windows.csv`
(the `scope = group` row unless named), **O** = `scripts/logs/timing/20261118_timing_nuseds.txt`.

## Checklist read

- `code-check-python.md`: read in full (no Python in the diff; nothing applies).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (tables and evidence blocks skipped); "One fact derived
  twice" ("Compute a measurand, its weight and any stratum threshold on **one** population ... one column name
  carrying different populations across files is this same defect") is the rule this round turns on.
- Every index (`index_code-check-*.md`) read. Sections read by heading because the diff uses the tool or shape:
  `code-check-r.md` "`ifelse()` with an all-NA test returns a logical vector", "`c()` dispatches on its first
  argument", "`match()` treats NA as a matchable VALUE", "A URL handed to a reader goes through R's 60 s connection
  timeout", "`$` on a list partial-matches", "Postgres row order is never fixed unless the query fixes it", "Rscript
  reads a script as it runs"; `code-check-shell.md` "A wrapper's exit is not the work" (the `pipefail`/`tee`/`cp` RUN
  lines); `code-check-spatial.md` "A relation between FWA watershed codes is not a place" (`nuseds_place()`, unchanged
  in behaviour). None of these yields a finding: `ifelse` tests are never NA, `nuseds_date()` seeds a Date vector,
  watershed codes are filtered for NA before `match()`, the download goes through `curl_fetch_disk()`, the SQL orders
  inside `array_agg`, and the RUN lines set `pipefail` and copy only after success.

## 1. Where a script still defines a record set or per-record quantity itself

| where | what it defines | also in the other script? | can it disagree? |
|---|---|---|---|
| check:60-61 | **the population** `nuseds_survey()` runs on: rows with `start_spawn_dt_from` or an end (`end_one`) | timing:104 defines the same "dated" but **does not filter by it**: `nuseds_survey()` (timing:113) runs on every coded row | **YES, and it does (finding 1)**: `method`, `peak_mid`, `start_mid` and the edge sets are one definition over two populations |
| timing:104 vs timing:117-118 | "dated" twice inside the windows script: `start_spawn_dt_from | end` (line 105's 102,800; placement's `dated`) and `has_start | has_end` (the "dated records" of lines 119-123) | — | yes, by the 7 rows carrying only `start_spawn_dt_to` (probe: 7, all coded, none with an end); equal today (4,047 both ways; 372 both ways) — finding 5 |
| check:69-77 | `start_form`/`peak_form`/`end_form` (grid day, other day, bin) | no | no (check only) |
| check:87-93 | bin width on the season year | `nuseds_mid()`'s `w` | no: same `t - f + 1`, same `from != to` |
| check:112-114 | `wb`, written-year backwards | no (`backwards` is `nuseds_survey()`'s) | no; pairs `start_lo`/`end_hi` the same way |
| check:122-126 | `survey_started`, `survey_ended`, `start_before_survey`, `end_after_survey`, `survey_dated` | no | no (check only) |
| check:141-142 | NONE OBSERVED survey overlap | no | no |
| check:153-157 | `fence`, `exact`, `auc`, `bracket`, `whole` | no | `bracket & visits0 >= 3 & whole` equals `start_bracket3 & end_bracket3` with both edges given; no |
| check:186 | `grid_edge` | no | no |
| check:204 | era table's `present_n` / `none_observed_n` = present & `whole` | no | the a3s and a3e rate columns beside it are over their own bases (start given / end given), not `whole`; not cited anywhere, noted only |
| check:211 | arrival-to-start days | no | no |
| timing:110-112 | `start_day`, `end_day`, `arrival_day` (the as-recorded `rec_` reading) | no | separate by design (accepted) |
| timing:115-116 | edge days | reads `edge_start`/`edge_end` and `start_mid`/`end_mid` | no |
| timing:132-136 | `first_year`/`last_year` (rec) and `bulk_`/`peak_` years | no | no |

Every per-record column the two scripts share (`method`, `start_mid`, `end_mid`, `peak_mid`, `start_bracket3`,
`end_bracket3`, `edge_start`, `edge_end`, `survey_off_year`, `survey_reversed`, `survey_slip`) is now read from
`nuseds_survey()`. The population they are computed over is not shared: that is finding 1.

## 2. Claims and their sources

`ok` = the set the sentence names is the set the code counts and the number matches.

### What a NuSEDS spawning date is (research 9-50)

| claim | source | verdict |
|---|---|---|
| 102,800 dated records of the six species | C:3 | ok |
| before 1990 a start is a grid single date on 89 to 92 % of records | C:8-10: 31271/34063 = 91.8 %, 17684/19754 = 89.5 %, 19375/21139 = 91.7 % | ok |
| the 15th holds 42,489 single starts | C:50 | ok |
| bins are 1-10, 11-20, 21-end | C:46, 15,652 of 15,678 open on 1/11/21 | ok |
| "3,009 of 12,542 starts in the 1990s, 7,157 of 8,173 from 2010" | C:11, C:13 — 12,542 and 8,173 are the era's **records** (`Sum`); starts are 12,542 − 456 = 12,086 and 8,173 − 720 = 7,453 | **WRONG set (finding 2)** |
| 15,678 start bins, 15,005 of 10-11 days, 664 longer, 2 backwards | C:14, C:40-44: 654 + 10 = 664 | ok |
| 372 set aside; start before survey 10,249 of 21,773 (to 1969), 1,341 of 7,115 (2010 on) | C:52, C:62, C:67 | ok |
| 21 records before 1980 give a visit count | C:62-63: 16 + 5 | ok |
| 3,725 NONE OBSERVED; 2,479 compared with both dates; 1,910 overlap; none count above 0 | C:80, C:90 | ok |
| 332 NOT INSPECTED; "the windows #240 built count both" | C:92; `rec_` reads every dated record (timing:110-111, 140-142) | ok |
| Unknown Estimate Method on 82,437 | C:72 | ok |
| upper Bulkley 40 records, 27 1953-1991, 13 2008-2020 | C:451 (script stops otherwise, check:276) | ok |
| most often 15 Aug / 15 Sep, no visit counts, mostly no survey dates, mostly Unknown | C:370-389, 403-409, 411-450 (17 of 27 starts 15-AUG; 13 ends 15-SEP; 9 of 27 any survey date; all NA visits) | ok |
| Buck Creek 1977, 1978, 1983 NONE OBSERVED with a full window | C:453, C:404-407 | ok |
| 2008-2020 all ten-day bins, 1 to 4 visits, mostly Peak Live + Dead | C:390-402, C:431-443 (11 of 13) | ok |
| start precedes survey on five: 2009 (1 visit, 10 Sep), 2016 (28 Aug), 2017 (30 Sep), each 11-20 Aug, and 2018, 2019; also 1986-1988 and Buck 1982, 1988 | C:452, C:391, 398-401 | ok |
| 2020 survey 20 Oct 2008 to 20 Sep 2030 | C:402 | ok |
| 372 = 98 off-year, 309 reversed, 35 both | C:52 | ok |
| Morice to 1991: 34 of 39 starts on the grid | C:365 (39 records; Morice's 64 records all carry a start, C:291 35+5+24, and its 25 from 1992 all do, C:363) | ok |
| **Nanika to 1991: 19 of 21 starts on the grid** | C:366 — 21 is records; Nanika's start forms total 20+1+24 = 45 of 46 records (C:315) and its 25 records from 1992 hold 25 starts (C:364, 1+24), so to 1991 has 20 starts; probe: 20 | **WRONG set (finding 3)** |
| median 2 visits; start before survey 15 of 24 Morice, 9 of 15 Nanika | C:365-366 | ok |
| from 1995: 24 of 25 bins each; median 4 visits; AUC 16 and 12; a3s 5 and 4; start before survey 8 of 20, 10 of 19 | C:363-364 (all 25 carry starts: grid + bin = 25) | ok |

### Which records can bound an edge (52-79)

| claim | source | verdict |
|---|---|---|
| "**Six** candidate rules were measured" | C:105-114, C:118-127 measure ten (a2, a3, a4, a5, a3s, a3e, b, c, d, a3 and c) | **WRONG count (finding 4)** |
| a3s over records giving a start, a3e over an end, the rest over both | check:159, 166, 168 | ok |
| table records 2,076 / 7,022 / 3,849 / 560 / 1,605 / 3,679 | C:106, 109-113 | ok |
| chinook groups with 5+: 12 / 19 / 19 / 1 / 15 / 13 | C:172, 190, 196, 202, 208, 214; W: 19 CH windows with `edge_n_start >= 5`, 19 with `edge_n_end >= 5` (same) | ok |
| test: NONE OBSERVED rate under half the present rate, each over the rule's base; grid share at most half | check:187-197 | ok |
| every rule but b passes; ratio 0.14 or less | C:118-127 (max 0.14, a2) | ok (of all ten) |
| 1990s, a3: 5.8 % against 0.4 % | C:134 | ok |
| fence 63 % on the grid; start a median 20 days after arrival | C:124, C:152 | ok |
| three visits the fewest for before/during/after; d's bracketing records are in a3s/a3e | reasoning; check:165-168 (a3s/a3e do not exclude AUC) | ok |
| edge only with 5 or more | timing:93 `edge_min` | ok |

### The window: bulk, peak and edges (81-101)

| claim | source | verdict |
|---|---|---|
| every one of the 6,112 `rec_` rows equals #240's | W vs `20261121_timing_nuseds_windows.csv`: same keys, `n_start…end_q90`, records, years, arrival identical on all 6,112 rows (compared here) | ok |
| 98,698 PRESENT, 43 UNKNOWN, 2 blank | C:58 | ok |
| a start given only as `start_spawn_dt_to` enters the bulk | `nuseds_mid()` from-else-to | ok |
| half a bin: 4 or 5 days for a ten-day bin; 664 start and 1,573 end bins over 11 days | arithmetic (11-20 → 15; 21-31 → 26); C:43-44: 654 + 10, 1,562 + 11 | ok |
| the 21 over 31 days give no midpoint and leave the bulk | C:44 (10 + 11); T:4 (12 starts = 10 + the 2 reversed, 11 ends) so every one is a method record | ok |
| UFRA peaks to 2014, bulk to 2008, as-recorded to 2000 | W UFRA CH `peak_last_year` 2014, `bulk_last_year` 2008, `last_year` 2000 | ok |
| 162 of 357 with a start edge, 124 an end edge; chinook 24 of 81 | T:10 | ok |

### What a NuSEDS window may claim (103-114)

| claim | source | verdict |
|---|---|---|
| "three or more visits" in the template | `nuseds_edge_visits` 3 | ok |

### Spawning past the new year (137-147)

| claim | source | verdict |
|---|---|---|
| about 3,000 coho and chum ends in January-March (coho 2,512, chum 540) | no log line prints it (inherited from #240); probe on the Parquet: CO 2,512, CM 540 by the end's month | true, **UNSUPPORTED by any printed line (finding 5)** |
| season year from 1 April, 1 September for steelhead | `nuseds_season_start` | ok |
| 165 present records backwards on written years; 98 (76 coho) run forward on the season year; the other 67 backwards either way | C:54; 165 − 98 = 67 | ok |
| a survey opening before the season start stays in its season | read.R:113-114 | ok |
| a bin halved after both ends are on the season year | `nuseds_mid()` | ok |

### The four groups' rows (149-186)

| claim | source | verdict |
|---|---|---|
| all 14 table rows (bulk, peak, edges with n, start, end, middle) | T:14201-14215 (`d_start`, `d_end`, `d_mid`, `edges`), W (`edge_n_end` MORR CH 9; `edge_n_start` MORR CO 8; MORR SK 6 and 11; UFRA 11) | ok, every cell |
| BULK CH middle 1.5 days off the peak; BULK SK on 4 records | T `d_mid` 1.5; W `bulk_n_start`/`bulk_n_end` 4/4 | ok |
| MORR CH end edge 09-25 on 9, 12 days before 10-07 | W, T `d_edge_end` −12 | ok |
| MORR CO peak 23 days before the middle | T `d_mid` −23.0 | ok |
| MORR CH migration −37 | T | ok |
| BULK CH pools seven tributary populations; the Bulkley's two reaches and the Morice apart | T:1246-1257 | ok |
| UFRA as-recorded 1967-2000, bulk to 2008 | W | ok |
| 20 of UFRA's 123 starts are bins, 6 of COTR's 35 | C:316-322 (4+3+3+3+3+3+1), C:300-302 (0+3+3); form totals 123 and 35; the 7 start_to-only rows carry no end (probe), so the check's start set is `start_spawn_dt_from`'s | ok |
| **neither group holds a dated NONE OBSERVED record** | not printed. Arithmetic covers only records with an end (W `rec_n_end` = `bulk_n_end`: 126 = 126, 36 = 36); a start-only non-present record is not excluded by any printed number. Probe: UFRA's 168 and COTR's 41 chinook records with a date or peak are all PRESENT | true, **UNSUPPORTED by any printed line (finding 5)** |
| UFRA bulk 08-12 to 09-05, peak 08-24 over 172 peaks 1967-2014, edge 08-15 on 11; COTR 08-10 to 09-05, 08-24, no edge | W | ok |
| 82 of UFRA's 123 and 19 of COTR's 35 starts on the grid; 28 of 75 and 12 of 32 precede the survey | C:316-322 (20+16+17+17+12), C:300-302 (14+4+1); `survey_started` 21+16+17+16+3+2 = 75, 20+9+3 = 32; `start_before_survey` 8+6+6+7+1 = 28, 6+5+1 = 12 | ok |

### data/life_history_timing.csv, UFRA and COTR chinook notes (lines 40-43)

| claim | source | verdict |
|---|---|---|
| 40 UFRA migration: ends the day before the median start (08-11) | O, T check line 14194 | ok |
| 40: median arrival 08-01, **125 population-years, 1967-2000** | O:31 prints 125 and 08-01; no log prints the arrival records' years (1967-2000 is the group's dated years). Probe: arrival years 1967-2000 | true, **UNSUPPORTED (finding 5)** (pre-existing) |
| 40: bulk start 08-12; 11 records with a 3+-visit survey before the start put it at 08-15 | W | ok |
| 41: 123 and 126 population-years, 1967-2000; Swift Creek 08-09 to 09-05 (27); above Tete Jaune ends 09-20 (15) | O:5-9, O:26; T:13497 block | ok |
| 41: no `START_SPAWN_DT_FROM` or end after 2000 (peaks to 2014) | W `last_year` 2000, `peak_last_year` 2014 | ok |
| 41: 82 of 123 on the grid; 28 of 75 precede the survey | as above | ok |
| 41: bulk 08-12 to 09-05 over 124 and 126 (1967-2008); peak 08-24 (172, 1967-2014); start 08-15 on 11 | W | ok |
| 42 COTR migration: ends the day before 08-10; arrival 08-01 (23) | O:52, W `n_arrival` 23 | ok |
| 42: bulk start the same day, 08-10; no record has the survey for an edge | W `bulk_start_median`, `edge_n_start` 0, `edge_n_end` 0 | ok (of the pooled window) |
| 43: 35 and 36, 1953-2009, three populations; Swift River 08-05 to 09-01 (21, 1953-1974); Naver 08-13 to 09-10 (10); second Swift 07-28 to 09-20 (4) | O:47-50; T:2298 block | ok |
| 43: the Cottonwood River's own records carry no spawn dates | O:45-46 (Cottonwood pops 0 years) | ok |
| 43: most dated years before 1975 | 21 of 35 starts are Swift River 1953-1974 (O:44) | ok |
| 43: 19 of 35 on the grid, 12 of 32 precede the survey | as above | ok |
| 43: bulk 08-10 to 09-05 over 35 and 36 (1953-2009); peak 08-24 (40, 1953-2008); no edge | W | ok |
| Candy et al. 2002 and Bradford and Taylor 2023 statements | literature; not checked against the PDFs in this round | — |

## Findings

- **[severity: fragile]** data-raw/nuseds_dates_check.R:60-61, 106, 218, 229-237 against data-raw/timing_nuseds.R:107, 113 —
  the mechanism is not closed. The columns now come from `nuseds_survey()`, but the **population** they are computed on
  is still defined twice: the check filters to rows with `start_spawn_dt_from` or an end before calling
  `nuseds_survey()`, the windows call it on every coded row. So the check's "all: the bulk's records" and its chinook
  windows table (comment at check:229: "as timing_nuseds.R reads") print a different bulk and peak from the windows
  for the same named set: UFRA peak 08-25 over 128 records (C:262) against the windows' 08-24 over 172 peaks (W, T
  UFRA CH); COTR peak 08-22 (C:273) against 08-24 (W). The UFRA bulk start agrees (08-12) only by chance: the windows'
  124 starts include the 2008 record that gives only `start_spawn_dt_to` and no end, which the check drops. The a3s
  and a3e sets agree today (every species' `edge_n_start`/`edge_n_end` summed over W's group windows equals C:190-201;
  19 and 19 chinook groups) only because none of the 7 start_to-only, end-less rows qualifies; check:151-152's "a3s
  and a3e are nuseds_survey()'s edge sets exactly" holds only within the check's population. Nothing in research/
  quotes the diverging rows, but they are committed evidence that contradicts the windows table under one name. Run
  the check's survey, rules and pooled windows over the same rows the windows use (or filter both the same way), and
  rerun.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: bug]** research/nuseds_timing.md:20-21 — "3,009 of 12,542 starts in the 1990s, 7,157 of 8,173 from
  2010": 12,542 and 8,173 are each era's dated **records** (C:11, C:13 `Sum`), not its starts. The starts are 12,086
  (12,542 − 456 with no start) and 7,453 (8,173 − 720). The 2010-on share is 96 % of starts, not the 88 % the
  sentence implies. Either say "records" or use 12,086 and 7,453.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: bug]** research/nuseds_timing.md:45 — "19 of 21 Nanika starts on the grid" (to 1991): 21 is the
  Nanika's to-1991 **records** (C:366); it has 20 starts (one record gives none). From the log: the Nanika's 46
  records carry 20 + 1 + 24 = 45 starts (C:315), and its 25 records from 1992 carry 25 (C:364, 1 + 24), so to 1991 holds
  20 (19 grid, 1 other); the Parquet agrees. "34 of 39 Morice" is right (all 39 carry a start). The check's Morice and
  Nanika table prints no start count, so the sentence borrowed `records`; printing `start_other` or a start total
  there would let both numbers come from one line.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: fragile]** research/nuseds_timing.md:54 — "Six candidate rules were measured": the check measures ten
  (C:105-114, C:118-127: a2, a3, a4, a5, a3s, a3e, b, c, d, "a3 and c"), and "Every rule but b passes" (line 68) is a
  claim over all ten. The table shows six of them; the sentence should say so. (data-raw/nuseds_dates_check.R:4-5
  calls them "three candidate rules" while its own notes list four families and it prints ten.)
  - **Rule:** none

- **[severity: fragile]** Claims true on the Parquet but printed by no log line, the hand-probe half of round 3's
  mechanism: research/nuseds_timing.md:181-182 "neither group holds a dated NONE OBSERVED record" (printed numbers
  exclude only non-present records with an end, via `rec_n_end` = `bulk_n_end`); research/nuseds_timing.md:139 "coho
  2,512, chum 540" (inherited from #240); data/life_history_timing.csv:40 "125 population-years, 1967-2000" for stream
  arrival (O prints the 125, not the arrival years; 1967-2000 is the dated years). And the windows script's own two
  "dated" sets (timing:104 `start_spawn_dt_from | end`, timing:117-118 any of the four date columns, used for the
  "dated records" counts at timing:119-123) differ by the 7 start_to-only rows; they print the same numbers today (4,047;
  372) but can part. Have the scripts print each count the prose quotes, and use one "dated" definition.
  - **Rule:** code-check.md "One fact derived twice"
