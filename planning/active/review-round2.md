# Code-check round 2 (#256), branch diff f1e9ed7c...c0115e3a

## Checklist read

- code-check-python.md: in full.
- code-check-r.md: by heading. Read: "`ifelse()` with an all-NA test returns a logical vector, whatever `yes` and
  `no` are"; "`$` on a list partial-matches, so a longer sibling key answers for a missing one"; "`match()` treats NA
  as a matchable VALUE, so two unknowns join to each other"; "A `data-raw/` script must load the source tree, not the
  installed package"; "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent".
  5 read, 125 not read (index lines read for all 130).
- code-check-shell.md: by heading. 0 read in full (the diff's only shell is the RUN comments' `set -o pipefail ... |
  tee ... && cp`, covered by the mechanism "A wrapper's exit is not the work"); 73 not read (index read).
- code-check-spatial.md: by heading. Read: "A relation between FWA watershed codes is not a place" (the placement
  query moved here from timing_nuseds.R unchanged). 1 read, 95 not read (index read).
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows and evidence blocks skipped), and the index.

Method: read the four changed scripts, research/nuseds_timing.md, the four notes, the two 20261124 logs and the
windows CSV; recomputed from the published Parquet (scratch copy, `nuseds_survey()` sourced from the branch) and the
CSV. Nothing in the repo was run or edited but this file.

## Findings

- **[severity: bug]** data-raw/nuseds_dates_check.R:107-110, research/nuseds_timing.md:40-41 (and
  planning/active/findings.md:96) — the survey-slip split is wrong, and the log's example sits in the other bin.
  `off_year` is `survey_slip & !(raw season reversal)`: it tests reversal on the raw season days, before the
  `early` adjustment `nuseds_survey()` applies, and gives reversal precedence over an off year. Recounted on the
  published set: 98 slips give a survey year over a year from the record's, 35 of which also reverse; 308 reverse
  on the season year after the `early` rule (273 alone). The script prints 62 and 309: the 35 that are both go to
  "reversed", and one `early` survey with an off year (not reversed once adjusted) is counted as reversed. The upper
  Bulkley's 2020 record (20-OCT-08 to 20-SEP-30), which the log line names as its example of the off-year group, is
  off-year *and* reversed on the season year (s0 Oct 20 > s1 Sep 20), so the script counts it in the 309, not the
  62. research/nuseds_timing.md publishes "62 give a survey year over a year from the record's own, and 309 a survey
  that ends before it starts even on the season year". Either print disjoint classes that name the overlap (98
  off-year, 308 reversed, 35 both; total 371) or define the order and reword, and test reversal on the adjusted
  s0/s1, not on raw `sday()`. This is round 1's fix 5 reproducing the defect one axis over: the reversal test in the
  check script is a second derivation of `nuseds_survey()`'s, without its `early` step.
  - **Rule:** code-check.md "One fact derived twice" ; code-check.md "A fix lands in one of two callers that share a harness"

- **[severity: bug]** research/nuseds_timing.md:93 — "162 of 357 group windows have a start edge and 123 an end
  edge". `scripts/logs/timing/20261124_timing_nuseds_windows.csv`, scope `group`: 357 rows, 162 with
  `edge_start_median`, **124** with `edge_end_median` (chinook 81, 24 with either: correct). Published count
  disagrees with the log it cites.
  - **Rule:** code-check.md "The probe is broken before the world is"

- **[severity: bug]** research/nuseds_timing.md:171-172 — "Under the method they barely move: UFRA's starts and
  ends run 1967 to 2000, before bins were used". UFRA's chinook starts include 20 ten-day bins (1996, 1998, 1999,
  2000; Holmes 4, Swift Creek 3, Nevin 3, Horsey 3, Fraser above Tete Jaune 3, Small 3, Robson 1, the `start_bin`
  column of the dates-check log's population table) and 20 end bins, of 123 starts; COTR has 6 (1998-2000). The
  windows do barely move (08-11 to 08-12), but the reason given is false: bins are used, they are a sixth of UFRA's
  starts. A reader of #96's rows (wet#182) is told the UFRA dates are all single dates.
  - **Rule:** none

- **[severity: bug]** research/nuseds_timing.md:86-88 — "Reading a start bin's first day and an end bin's last day
  ... moves each edge outward by half the bin: four or five days for a ten-day bin, more for the 664 wider ones."
  664 is the start bins wider than 11 days only (654 of 12-31 days + 10 over 31); the sentence is about each edge,
  and the end has 1,573 (1,562 + 11). The 21 over 31 days are not moved by half a bin at all: `nuseds_mid()` gives
  them no midpoint, so they leave the bulk.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** data-raw/nuseds_dates_read.R:106-109 — the `early` rule reads month and day only, so it
  cannot tell a survey that opened before the season start from a reversed one whose start falls in January-March of
  the next year. Measured: 406 surveys take the rule; 404 give a start written in the record's own year (the
  whole-year and steelhead cases the comment names, placed correctly, including the two steelhead edge records
  checked, Burman 1998 and Tahsish 1996), one has a 15-year typo (caught as off-year), and one is reversed by its
  written years: chum, Belcharton Creek (pop_id 48043), 2015, survey 10-JAN-16 to 30-DEC-15, 12 visits. The rule
  turns it into a survey from 10 January to 30 December and admits it as an end edge (`edge_end` TRUE), where round
  1's reversal test would have made it a slip. One record, so it moves a published edge only if that group's chum end
  edge sits at the 5-record threshold; but the prose (research/nuseds_timing.md:136-137, the function's comment)
  says the rule keeps a survey "in the season it opened", which the written year here contradicts. Gating `early`
  on the start's written year being the record's own (or earlier) would keep every case the comment names and slip
  this one. (Separately, 26 surveys lie wholly in January-March; 25 are written with the record's own year and are
  placed after the season, 10 of them counted in `brackets_end`; none has 3 visits, so no edge rests on them.)
  - **Rule:** code-check.md "A proxy is not the property"

Checked and holding: every other number in research/nuseds_timing.md's new sections and the four UFRA/COTR notes
against the 20261124 logs and CSV (form and era counts, 10,249/21,773 and 1,341/7,115, 2,479/1,910, the rules table
and its group counts, the separation rates, Morice/Nanika by period, the upper Bulkley's start-before-survey list
(1986-1988, 2009, 2016-2019, Buck Creek 1982 and 1988) and NONE OBSERVED years (1977, 1978, 1983), the comparison
table, UFRA 82/123, 28/75, 124/126, 172 peaks 1967-2014, COTR 19/35, 12/32, 35/36, 40 peaks 1953-2008, edges and
their n); "98 present records read that way would run backwards" (full dates give 165 backwards, season days 98,
and 98 resolved: the two 98s coincide); "neither group holds a NONE OBSERVED record" (UFRA 128 and COTR 37 dated
chinook records, all PRESENT); `precision`/`reliability` unknown or blank on 99.6 % and 96.8 % of dated records (not
printed by any log, but true).
