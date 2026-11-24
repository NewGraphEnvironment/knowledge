# Findings — A method for reading NuSEDS spawning dates: what a record can bound (#256)

## Issue context

**If we do it:** the NuSEDS timing windows say what the spawner records can support, the bulk and peak of spawning, and stop reading as observed first and last spawning, before the timing reviews (#241, #242) revise any row against them. **If we never do:** cited windows get moved toward NuSEDS medians on the strength of dates that were estimated, and published windows claim edges the records cannot show.

## The assumption to replace

`data-raw/timing_nuseds.R` (#240) takes each record's start of spawning (`start_spawn_dt_from`) and end (`end_spawn_dt_to`, else `end_spawn_dt_from`) as given and takes their medians per group. `research/nuseds_timing.md` then sets each cited row beside them as a difference in days (for example +14 at the start of the Bulkley chinook row). Both read the dates as observations. The script reads none of the fields that say how a date was made: `no_inspections_used`, `estimate_method`, `enumeration_methods`, `accuracy`, `precision`, `reliability`, or the survey dates `start_dtt` and `end_dtt`.

## What the records show (the upper Bulkley chinook, read 2026-11-22)

From the 2026-06-01 release, the upper Bulkley mainstem (`pop_id` 47859) and Buck Creek (49223), 40 dated records:

- **No record brackets spawning with an empty survey.** Nothing shows a visit that found no spawners before the start date or after the end date, so a date cannot say no fish spawned outside it.
- **1953–1991 (27 records):** dates are round, mostly 15 August and 15 September, with no count of inspections, mostly no survey dates and "Unknown Estimate Method". They read as estimates of the season.
- **2008–2020 (13 records):** dates are ten-day bins (`start_spawn_dt_from` to `start_spawn_dt_to`, for example 11 to 20 August), from 1 to 4 inspections a year, mostly "Peak Live + Dead". The recorded start often precedes the survey: 2009 (one visit, on 10 September), 2016 (survey from 28 August) and 2017 (survey from 30 September) all record a start of 11 to 20 August.

The detail and the counts are in #241's body. The Morice, Nanika and other groups' records have not been read this way yet.

## The method to set

- [ ] Which records can bound a window's edge, if any: by number of inspections, estimate method, enumeration method and the date's precision (a bin's two ends). Measure how many records in each group pass, and what the windows become on those alone.
- [ ] Whether a window is built from the start and end of spawning, the peak, or the middle of the season, and whether the bins enter as intervals rather than their first day.
- [ ] What a NuSEDS window may claim beside a cited row: support for its middle, or evidence about its edges, and the wording a row's `note` uses.
- [ ] Revise `research/nuseds_timing.md`: a section on what a NuSEDS date is, with the upper Bulkley as the worked example, and the comparison table labelled as estimate against estimate.
- [ ] Rerun `data-raw/timing_nuseds.R` under the method, and recheck the windows #96 built for UFRA and COTR, which rest on NuSEDS medians and which wet is about to read for Swift and Naver creeks (NewGraphEnvironment/wet#182).

A gate for #241 and #242: neither revises a row against NuSEDS before this sets what NuSEDS can show.

Part of #243 (umbrella). Relates to #240, #244, #96.


## Phase 1: what a NuSEDS date is made of (2026-11-24, `scripts/logs/timing/20261124_nuseds_dates_check.txt`)

Published `knowledge/nuseds/v1` (release 20260601), 102,800 dated records of the six species.

- **Form.** Before 1990 the start is a single date on the five-day grid on 89 to 92 % of records (15th alone: 42,489 of
  all single starts). Bins arrive in the 1990s (3,009 of 12,542 starts) and are nearly every start from 2000 (5,511
  of 7,129; 7,157 of 8,173). Of 15,678 start bins, 15,004 are 10 or 11 days, 654 span 12 to 31, 10 exceed 31 and 3
  run backwards; 15,652 open on the 1st, 11th or 21st. End bins: 12,004 of 10-11 days, 1,562 of 12-31, 30 backwards.
  630 records give an end only as `end_spawn_dt_to`.
- **Survey.** 463 records give survey dates over a year from their own year or ending before they start (the upper
  Bulkley's 2020 record: 20-OCT-08 to 20-SEP-30); 165 end before they start. Visits are recorded from the 1980s on
  (16 records before 1970, 5 in the 1970s). A start recorded before the survey began: 10,377 records before 1970,
  1,345 from 2010.
- **NONE OBSERVED.** 3,725 dated records say NONE OBSERVED; 2,478 give survey dates and 1,908 of those were surveyed
  inside the very window they give; 3,625 give a peak; none gives a spawner count above 0. NOT INSPECTED: 332 dated,
  72 surveyed inside their window, 305 with a peak. Their dates are the stream's expected timing, written whatever
  was seen, so the method drops both presences from its windows (the `as_recorded` window keeps them).
- **Candidate rules** (present records with a start and an end): a3 (survey brackets both edges, 3+ visits) 2,078;
  a3s (the start, 3+) 5,672; a3e (the end, 3+) 3,211; b (fence or fixed-site) 560; c (off the grid) 1,604; d (area
  under the curve) 3,668. Chinook pooled groups with 5+: a3 12, a3s 18, a3e 19, b 1, c 15, d 13.
- **The test set before it ran.** Every rule but b passes: NONE OBSERVED records meet its conditions at 0.01 to
  0.14 of the present rate, and under half its records put an edge on the grid. b fails on the grid (0.63 of its
  records), and its records' recorded start falls a median 20 days after their arrival (quartiles 10 and 37). Within
  eras the separation holds where visits are recorded (1990s, a3: 0.058 present against 0.004 none observed); from
  2000 the NONE OBSERVED samples are 36 and 42 records.
- **The five chinook groups.** BULK has 1 a3s record and 0 a3e; MORR 2 and 9; KISP 2 and 3; UFRA 11 and 4; COTR 0
  and 0. So under the threshold (5) MORR's end and UFRA's start are the only edges any of these groups can be given.
- **Morice and Nanika.** To 1991: 34 of 39 Morice and 19 of 21 Nanika starts on the grid, median 2 visits where
  given, no record passing a3s or a3e. From 1995: 24 of 25 starts bins in each, median 4 visits, mostly "Area Under
  the Curve"; Morice 5 a3s and 4 a3e, Nanika 2 and 9. A start before the survey: Morice 15 of 20 surveyed records to
  1991 and 8 of 20 after; Nanika 9 of 12 and 10 of 19. The same kind of dates as the upper Bulkley before 1992; better
  surveyed after, but still a start recorded before the survey on about half the records.
- **Upper Bulkley** reproduces #241: 40 dated records, 27 from 1953-1991, 13 from 2008-2020; the 2009, 2016 and 2017
  starts precede their surveys. Buck Creek's 1970, 1977 and 1982 records say NONE OBSERVED and carry full windows.

## The method (Phase 2, decided 2026-11-24 from the above)

- The window is the **bulk** (median start to median end; a bin enters as its midpoint) and the **peak** (median
  peak, 10th and 90th percentiles), over records whose adults were present.
- An **edge** is "consistent with an edge someone saw" only on a3s records (start) or a3e records (end): the survey
  began before the recorded start, or ended after the recorded end, with at least 3 visits, the fewest that can put a
  visit before, during and after spawning. Written for a group and species only with 5 or more such records. Never
  "bounds": NuSEDS keeps no count per visit.
- Rejected: b (fails the test; a fence dates passage), c (an off-grid day needs no visit before it), d (repeated
  counts, but no visit before the start is required; its records that do bracket are in a3s and a3e), a3 (both
  edges at once, review finding 1).

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `arrow::read_parquet(col_select = if (is.null(cols)) NULL else ...)` returned 0 columns | `col_select` is tidy-evaluated; branch the call. `nuseds_read()` refuses a read with no columns |
| The separation test passed a rule on low NONE OBSERVED rates that might be era, not separation | The same rates printed within each era; the separation holds in the 1990s, where both samples are large |

## Code-check round 1 corrections (2026-11-24, `review-round1.md`)

Eight findings, all real; the logs were rerun after the fixes and supersede the Phase 1 figures above where they differ.

- **Season year for every date.** DFO writes a January-to-March end, or a survey's last day, with the record's own
  year (start 25-SEP-93, end 25-FEB-93), so full dates read 98 present records as backwards and dropped them (76 coho).
  `nuseds_survey()` now places every date by month and day on the season year, as the windows always did; a survey
  opening before the season start (whole-year surveys from 2 January, steelhead surveys from August) stays in the
  season it opened. Survey slips fell from 463 to 371 (62 off-year, 309 reversed on the season year).
- **Denominators.** A start before the survey is now counted over records giving the survey's first day, an end after
  it over those giving its last. Morice to 1991: 15 of 24; Nanika 9 of 15.
- **Facts misread from the log:** Buck Creek's NONE OBSERVED years are 1977, 1978 and 1983 (not 1970, 1977, 1982);
  the upper Bulkley's starts precede the survey in 1986-1988, 2009, 2016-2019 and Buck Creek's 1982 and 1988; COTR
  has 19 grid starts of 35, not 18. The script now prints both lists.
- **The peak** is read over present records that give one, some with no start or end, and carries its own years
  (UFRA's run to 2014). The as-recorded reading moves each edge outward by half a bin, not nine days. NONE OBSERVED
  surveys overlap the window they give (1,910), not lie inside it.

## Code-check round 2 corrections (2026-11-24, `review-round2.md`)

- Inside round 1's fix: the check script re-derived the survey reversal without `nuseds_survey()`'s `early` step, so
  its split of slips was wrong. `nuseds_survey()` now returns `survey_off_year` and `survey_reversed` and the check
  prints them: 372 slips, 98 off-year, 309 reversed, 35 both. The `early` rule now needs the survey's first day
  written in the record's year or before (Belcharton Creek chum 2015, 10-JAN-16 to 30-DEC-15, is a slip, not a
  whole-year survey; its code places it in no group, so no window moved).
- The end-edge total is 124, not 123: my count was a hand probe, not the script. `timing_nuseds.R` now prints the edge
  totals itself.
- UFRA has 20 start bins of 123 (COTR 6), so "before bins were used" was false; the widening sentence counts end bins
  (1,573 longer than 11 days) and says the 21 over 31 days leave the bulk.
