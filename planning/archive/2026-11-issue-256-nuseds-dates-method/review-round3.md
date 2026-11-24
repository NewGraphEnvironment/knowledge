# Code-check round 3 (#256): branch f1e9ed7c...43755809

## Checklist read

- `code-check-python.md`: in full (no Python in the diff).
- `code-check.md`: all 14 H3 prose under `## Mechanisms` (tables and evidence skipped). Of "Rules that stand
  alone", Security and Spreadsheets/PDFs: 0 read (none names a tool or shape this diff uses).
- `code-check-r.md`: 21 headings read: Read-back shape; `download.file(quiet = TRUE)`; A URL handed to a reader (60 s);
  `on.exit()` at top level; A `data-raw/` script must load the source tree; `$` partial-matches; A database driver's
  value; `nzchar(NA)`; `paste()` zero-length; `strsplit()` trailing empty; `identical()` on two reader results; CSV
  whitespace; `sort()`/`order()` collate; `match()` treats NA; `unlist()` prefixes `split()` names; `data.frame()`
  recycles a scalar; `tempfile()` session tempdir; Postgres row order; Rscript reads a script as it runs; `c()`
  dispatches on first argument (Date); `ifelse()` with an all-NA test. Not read: the remaining ~104.
- `code-check-shell.md`: 3 headings read (Paths, Quoting, A Python CLI redirected to a log; the RUN lines' `tee` /
  `pipefail` pattern checked against code-check.md "A wrapper's exit is not the work"). Not read: ~107.
- `code-check-spatial.md`: 2 headings read (A relation between FWA watershed codes is not a place; A name is not a
  key). Not read: ~120.

## The mechanism

Every finding in rounds 1-3 has one shape: **a sentence names a set in plain words ("records that give the survey's
first day", "a3s records", "present", "its starts", "mostly X") while the number beside it comes from a code set
filtered differently**, and the set is derived twice, once in `nuseds_dates_check.R` (dated records only; every rule
gated on `ok = present & whole`, a start AND an end) and once in `timing_nuseds.R` (every row; `method = present &
!backwards`; edges with no `whole`; years from the as-recorded columns). The two derivations happen to agree in the
groups the prose was checked on (UFRA's 11 start-edge records, MORR's 9 end-edge records, UFRA's 123 starts), which
is why the difference survived two rounds. Hand probes (round 2's 123 vs 124; this round's "98") and a mode read as a
majority (`method = names(sort(table(...)))[1]`) are the same assumption: the printed figure is taken to describe
the population the sentence names.

## Findings

- **[bug]** research/nuseds_timing.md:52-58, 71-75, 93-94 — the edge the windows publish is not rule a3s/a3e as tested.
  The table and the separation test count a3s/a3e "over records whose adults were present and that give a start and
  an end" (`nuseds_dates_check.R:141-163`, `x$whole`), but `timing_nuseds.R`'s edge comes from
  `nuseds_survey()`'s `edge_start`/`edge_end` (`nuseds_dates_read.R:125-126`), which require no end for a start edge
  and no start for an end edge. Province-wide (reviewer probe on the published Parquet, before placement): 7,025
  start-edge records against a3s's 5,678, and 3,851 end-edge against a3e's 3,211, so about 19 % of the start-edge set
  and 17 % of the end-edge set never went through the test that "chose" the rule. It shows in the published numbers:
  chinook groups with a start edge are 19 in the windows CSV against the table's 18 for a3s; MORR chinook's
  `edge_n_start` is 4 (`20261124_timing_nuseds_windows.csv`, MORR CH group) against the check's a3s 2
  (`20261124_nuseds_dates_check.txt:240`); Nanika's 2024 and 2025 records (start bins, 3-visit surveys from 27 August
  and 5 September, no end) are start edges but not a3s. So research line 93 ("the median start over a3s records")
  and line 71 are false as written, and line 46-47 ("2 Nanika records have a survey of 3 or more visits that began
  before the recorded start") undercounts: 4 do. The check's "chinook windows ... all dated, present" rows disagree
  with the published bulk for the same reason (COTR 08-09 / peak 08-23 at `nuseds_dates_check.txt:268` against
  the bulk's 08-10 / 08-24; UFRA peak 08-25 at :257 against 08-24). Either gate the edge on `whole` (and rerun), or
  test the rule on the population the edge uses and restate a3s/a3e and the Nanika count by that definition.
  - **Rule:** code-check.md "One fact derived twice" ; code-check.md "A fix lands in one of two callers that share a harness"

- **[bug]** data/life_history_timing.csv:41 and research/nuseds_timing.md:92, 173-174 — "after 2000 DFO gives only peaks"
  / "its starts and ends to 2000" / "UFRA's starts and ends run 1967 to 2000" are false for the bulk the same
  sentences quote. `bulk_n_start` is 124 against `rec_n_start` 123 because Holmes River (pop 46931) 2008 gives
  `start_spawn_dt_to` 15-AUG-08 and no `_from` and no end: `nuseds_mid()` takes the `_to` alone, so the bulk's start
  median uses a 2008 start, while `first_year`/`last_year` (`timing_nuseds.R:134-137`, `yr()`) are computed from the
  as-recorded `start_day`/`end_day` and print 1967-2000. The note then reads "over 124 and 126 population-years ...
  (after 2000 DFO gives only peaks)", and the research's note template "(<n> population-years, <years>)" fills a bulk
  n with as-recorded years. COMX chinook carries the same mismatch (105 vs 106). The 2008 record is also outside the
  script's own "dated" set (`timing_nuseds.R:102`), so the bulk reads records the window's `records`/years do not.
  - **Rule:** code-check.md "One fact derived twice" ; code-check.md "A proxy is not the property"

- **[bug]** research/nuseds_timing.md:46 — "From 1995 ... mostly 'Area Under the Curve'" is false for the Nanika:
  12 of its 25 records from 1995 are AUC (Expert Opinion 6, Other 3, Peak Live + Dead 3, Unknown 1; Morice 16 of 25).
  The script prints only the most common method (`nuseds_dates_check.R:252`, `names(sort(table(...)))[1]`), a
  plurality, and the prose read it as a majority. The upper Bulkley's "mostly 'Peak Live + Dead'" (11 of 13) and
  "mostly Unknown" (23 of 27) do hold, from the record list.
  - **Rule:** code-check.md "A proxy is not the property"

- **[bug]** research/nuseds_timing.md:74 — "d needs repeated counts but no visit before the start (its records that do
  have one are in a3s and a3e)": 111 admitted AUC records (present, whole) have a survey that began before the start
  but fewer than 3 visits, so are not in a3s; 85 likewise for the end and a3e (reviewer probe). The parenthetical is
  an "all" claim no script prints.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[bug]** research/nuseds_timing.md:137 — "98 present records read that way would run backwards": no script prints
  it (it is round 1's hand probe, `findings.md:93`). Read with the written year, 165 present dated records run
  backwards; 98 of them (76 coho) run backwards only because of the year, and the other 67 run backwards on the
  season year too. The figure is the rescued subset, not what the sentence says, and it coincides with the unrelated
  `98 records end before they start on the season year` (`nuseds_dates_check.txt:53`) and with the 98 off-year
  surveys (:52), which invites a reader to tie them together.
  - **Rule:** code-check.md "One fact derived twice" ; code-check.md "The probe is broken before the world is"

- **[fragile]** research/nuseds_timing.md:22-23, 25-26, 45 — denominators named as "records that give the survey's
  first day" / "the 2,479 that give both survey dates" exclude the 372 slips (`survey_started`, `survey_dated` read
  `s0`/`s1` after `nuseds_survey()` clears them). Records that give them: 21,917 before 1970 (printed 21,773), 7,208
  from 2010 (7,115), NONE OBSERVED with both survey dates 2,482 (2,479). Small, but each printed denominator is a
  different population from the one the sentence names; say "whose survey is compared" or count the slips in.
  - **Rule:** code-check.md "One fact derived twice"

- **[fragile]** research/nuseds_timing.md:52, 85-86, 90 — "records whose adults were present" is the code's
  `!adult_presence %in% c("NONE OBSERVED", "NOT INSPECTED")` (`nuseds_dates_read.R:122`), which also admits 43 UNKNOWN
  and 2 blank dated records (and UNKNOWN records in UFRA's undated set). The script comments say it exactly; the
  research names the set by its main member.
  - **Rule:** code-check.md "A proxy is not the property"

- **[fragile]** research/nuseds_timing.md:173 — "neither group holds a NONE OBSERVED record": the UFRA and COTR chinook
  populations hold 12 and 2 NONE OBSERVED records; none is dated. True only of dated records.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[fragile]** data-raw/nuseds_dates_check.R:41-43 — the header still says NONE OBSERVED records are counted "with
  whether their survey fell inside the window they give"; the code (:132) and round 1's correction count a survey
  overlapping it. The fix landed in the research file only.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness"

## Every quantified claim in the new text

Logs abbreviated: C = `scripts/logs/timing/20261124_nuseds_dates_check.txt`, T = `20261124_timing_nuseds.txt`,
W = `20261124_timing_nuseds_windows.csv` (row by wsg/species/scope). "Probe" = reviewer's run on the published
Parquet in the scratchpad (no database).

### What a NuSEDS spawning date is (lines 9-48)

| claim | source | verdict |
|---|---|---|
| 102,800 dated records of six species | C:3 | ok |
| before 1990 grid starts 89-92 % of records | C:8-10 (91.8, 89.5, 91.7 % of all dated) | ok (bracket) |
| the 15th holds 42,489 single starts | C:50 | ok |
| bins 3,009 of 12,542 (1990s), 7,157 of 8,173 (2010 on) | C:11, C:13 | ok |
| bins are 1-10, 11-20, 21-end | C:46 (15,652 of 15,678 open on 1/11/21) | ok |
| 15,678 start bins, 15,005 10-11 days, 664 longer, 2 backwards | C:14, C:40-44 (654+10) | ok |
| start precedes survey 10,249 of 21,773 (<1970), 1,341 of 7,115 (2010 on) | C:57, C:62 | numbers ok; denominator excludes slips (finding 6) |
| 21 records before 1980 give visits | C:57-58 (16+5) | ok |
| 3,725 NONE OBSERVED; 2,479 both survey dates; 1,910 overlapping; none count > 0 | C:75, C:85 | 2,479 excludes 3 slips (finding 6) |
| 332 NOT INSPECTED | C:87 | ok |
| 82,437 Unknown Estimate Method | C:67 | ok |
| precision and reliability unknown/blank on nearly every one | no log; probe: precision UNK 102,406, reliability blank 99,506 of 102,800 | UNSUPPORTED by log, true by probe |
| upper Bulkley 40 dated; 27 (1953-91); 13 (2008-20) | C:446 (stop() pin) | ok |
| round, mostly 15 Aug / 15 Sep; no visits; mostly no survey dates; mostly Unknown | C:365-404, 406-445 (9 of 27 with survey dates; 23 of 27 Unknown) | ok |
| Buck Creek 1977, 1978, 1983 NONE OBSERVED, full window | C:448, C:399-402 | ok |
| 2008-20 ten-day bins, 1 to 4 visits, mostly PL+D | C:385-397, 426-438 (11 of 13) | ok |
| start precedes survey on five: 2009, 2016, 2017, 2018, 2019; 1986-88; Buck 1982, 1988 | C:447 | ok |
| 2009 one visit 10 Sep; 2016 from 28 Aug; 2017 from 30 Sep; start 11-20 Aug | C:386, 393, 394 | ok |
| 2020 survey 20 Oct 2008 to 20 Sep 2030 | C:397 | ok |
| 372 not compared: 98 off-year, 309 reversed, 35 both | C:52 | ok |
| Morice/Nanika to 1991: 34/39, 19/21 grid; median 2 visits; 15 of 24, 9 of 15 | C:360-361 | ok |
| from 1995: 24 of 25 bins each; median 4 visits | C:358-359 | ok |
| from 1995: mostly AUC | C:358-359 prints the mode only; probe Nanika 12 of 25 | FALSE for Nanika (finding 3) |
| 5 Morice, 2 Nanika a3s | C:358-359 (a3s with `ok`) | as a3s ok; as worded Nanika is 4 (finding 1) |
| 8 of 20 Morice, 10 of 19 Nanika start before survey | C:358-359 | ok |

### Which records can bound an edge (50-75)

| claim | source | verdict |
|---|---|---|
| six rules' records 2,076 / 5,678 / 3,211 / 560 / 1,605 / 3,679 | C:101-108 | ok |
| chinook groups with 5+: 12 / 18 / 19 / 1 / 15 / 13 | C:167, 185, 191, 197, 203, 209 | ok for the check's rule; the published start edges are 19 groups (finding 1) |
| every rule but b passes | C:113-122 | ok |
| NONE OBSERVED at 0.14 of present rate or less | C:113-122 (max 0.14) | ok |
| 1990s a3: 5.8 % vs 0.4 % | C:129 | ok |
| fence fails on grid, 63 % | C:119 | ok |
| fence start a median 20 days after arrival | C:147 | ok |
| edge from a3s / a3e records | `nuseds_dates_read.R:125-126` | FALSE: wider set (finding 1) |
| d's records with a visit before the start are in a3s and a3e | no log; probe 111 and 85 are not | FALSE (finding 4) |
| edge only where 5+ qualify | `timing_nuseds.R:91, 138` | ok |

### The window: bulk, peak and edges (77-94)

| claim | source | verdict |
|---|---|---|
| rec_ equals #240 on all 6,112 rows | T: "wrote 6112 windows"; reviewer compared every rec_/shared column of W with 20261121 CSV: identical | ok |
| ten-day bin moves an edge 4 or 5 days | `nuseds_dates_read.R:138` (midpoint) | ok |
| 664 start, 1,573 end bins longer than 11 days | C:43-44 (654+10, 1562+11) | ok |
| 21 longer than 31 days leave the bulk | C:44 (10+11); T:4 prints 12 and 11 incl. 2 reversed | ok |
| UFRA peaks to 2014, starts and ends to 2000 | W UFRA CH group | FALSE for the bulk's starts (2008, finding 2) |
| 162 of 357 start edge, 124 end; chinook 24 of 81 | T:10 | ok |

### What a NuSEDS window may claim (96-107)

| claim | source | verdict |
|---|---|---|
| template "(<n> population-years, <years>)" | `timing_nuseds.R:134-161` | <years> is as-recorded, <n> bulk (finding 2) |

### Spawning past the new year (130-139, new sentences)

| claim | source | verdict |
|---|---|---|
| 98 present records read that way would run backwards | no log; probe: 165 by written year, 98 rescued (76 coho) | UNSUPPORTED, worded as the wrong set (finding 5) |
| a whole-year survey from 2 January stays in its season | `nuseds_dates_read.R:111-112` | ok |
| a bin is halved after both ends are on the season year | `nuseds_dates_read.R:134-138` | ok |

### The four groups' rows (141-177)

| claim | source | verdict |
|---|---|---|
| all 14 table rows (bulk, peak, edges with n, start, end, middle) | T:14200-14229 and W group rows (edge n: MORR CH end 9, MORR CO start 8, MORR SK 6/11, UFRA start 11) | ok, every cell |
| BULK CH middle 1.5 days off | T comparison | ok |
| BULK SK bulk rests on 4 records | W BULK SK `bulk_n_start` 4 | ok |
| MORR CH end edge 09-25 on 9, 12 days before | W, T `d_edge_end` -12 | ok |
| MORR CO peak 23 days before middle | T `d_mid` -23 | ok |
| MORR CH migration end differs 37 days | T | ok |
| BULK pools seven tributary populations; two reaches and Morice apart | T:1246 | ok |
| UFRA starts and ends 1967-2000 | W rec years | true as recorded, false for the bulk (finding 2) |
| 20 of 123 UFRA starts bins (1996-2000), 6 of COTR's 35 | C:311-317, 295-297; probe bin years 1996, 1998-2000 | ok |
| neither group holds a NONE OBSERVED record | no log; probe 12 and 2 undated | true of dated only (finding 8) |
| UFRA bulk 08-12 to 09-05, peak 08-24, 172 peaks 1967-2014 | W | ok |
| after 2000 only peaks | W `bulk_n_start` 124 vs 123; probe Holmes 2008 | FALSE (finding 2) |
| UFRA start edge 08-15 on 11 | W | ok |
| COTR 08-10 to 09-05, 08-24, no edge | W | ok |
| 82 of 123, 19 of 35 grid; 28 of 75, 12 of 32 precede | C:311-317 (sums), C:295-297 | ok |

### The four UFRA/COTR notes (data/life_history_timing.csv:40-43, new text)

| claim | source | verdict |
|---|---|---|
| UFRA migration: bulk start 08-12; 11 records put it at 08-15 | W | ok |
| UFRA spawning: 82 of 123 grid; 28 of 75 precede | C sums | ok |
| UFRA spawning: 08-12 to 09-05 over 124 and 126 | W | ok |
| UFRA spawning: 172 peaks, 1967-2014 | W | ok |
| UFRA spawning: after 2000 DFO gives only peaks | W, probe | FALSE (finding 2) |
| UFRA spawning: start 08-15 on 11 records | W | ok |
| COTR migration: bulk start 08-10, the same day; no record stands for an edge | W (edge n 0 and 0) | ok |
| COTR spawning: 19 of 35 grid; 12 of 32 precede | C sums | ok |
| COTR spawning: 08-10 to 09-05 over 35 and 36; 08-24, 40 peaks, 1953-2008; no edge | W | ok |

## Every quantity computed twice

| quantity | derivation 1 | derivation 2 | agree? |
|---|---|---|---|
| a3s / start edge | check `conds()` & `ok` (start and end) | `nuseds_survey()$edge_start` (no end needed) | NO: 5,678 vs 7,025; CH groups 18 vs 19; MORR CH 2 vs 4; Nanika 2 vs 4; agree only for UFRA (11) |
| a3e / end edge | check (whole) | `edge_end` | NO: 3,211 vs 3,851; CH groups 19 vs 19; MORR CH 9 vs 9 |
| bulk / peak on present records | check "all dated, present" rows (`ok`, whole) | timing `method` (no whole) | NO: COTR 08-09/08-23 vs 08-10/08-24; UFRA peak 08-25 vs 08-24; BULK 20 vs 22 records |
| a group's starts | check `start_form` (from else to, dated records) | timing rec_ (`_from` only) and bulk (from else to, every row) | rec 123 = check 123; bulk 124 (UFRA), 106 vs 105 (COMX) |
| a window's years | `yr()` over rec_ days | the bulk's records | NO where a start-to-only record enters (UFRA 2008) |
| backwards records | check C:53 (98, all presences) | timing T:4 (98, present, coded) | yes (all 98 present) |
| bins over 31 days | check C:44 (10 start, 11 end, all dated) | timing T:4 (12, 11: present, coded, incl. 2 reversed) | yes once the reversed are added |
| NONE OBSERVED + NOT INSPECTED | check 3,725 + 332 = 4,057 | timing T:4 4,047 (coded, start or end incl. `_to`) | different populations, each labelled |
| survey slips | `nuseds_survey()` (one source since round 2) | — | single source |
| "98 present records ... backwards" | round-1 hand probe | reviewer probe | 98 reproduced as the rescued subset; 165 as worded |
| end-edge total | timing T:10 (124) | round-2 hand probe (123) | fixed in round 2; now printed |
| #241's upper Bulkley counts | check stop() pin | #241's text | yes |
| UFRA/COTR/BULK as-recorded windows | timing check() pins | 20261118 / 20261121 logs | yes |
