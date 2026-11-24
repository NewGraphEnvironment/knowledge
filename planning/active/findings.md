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

