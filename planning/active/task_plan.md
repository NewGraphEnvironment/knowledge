# Task: A method for reading NuSEDS spawning dates: what a record can bound (#256)

## The assumption to replace

`data-raw/timing_nuseds.R` (#240) takes each record's start of spawning (`start_spawn_dt_from`) and end (`end_spawn_dt_to`, else `end_spawn_dt_from`) as given and takes their medians per group. `research/nuseds_timing.md` then sets each cited row beside them as a difference in days (for example +14 at the start of the Bulkley chinook row). Both read the dates as observations. The script reads none of the fields that say how a date was made: `no_inspections_used`, `estimate_method`, `enumeration_methods`, `accuracy`, `precision`, `reliability`, or the survey dates `start_dtt` and `end_dtt`.

## Context

`data-raw/timing_nuseds.R` (#240) takes each record's `start_spawn_dt_from` and `end_spawn_dt_to` (else `end_spawn_dt_from`) as observed dates, takes medians per group, and `research/nuseds_timing.md` sets cited rows beside them as differences in days. #241's reading of the upper Bulkley chinook showed the dates are estimates: round dates before 1991, ten-day bins after, a start often earlier than the first survey, and no record bracketing spawning with an empty visit. #241 and #242 revise no row against NuSEDS until this issue sets what a NuSEDS date can show.

What exploration found (2026-11-23, the published `knowledge/nuseds/v1`, release 20260601, 102,803 dated records):
- **The script ignores the peak.** `peak_spawn_dt_from` is filled on 93,847 dated records and `peak_spawn_dt_to` on 15,686; neither is read.
- **Ten-day bins arrive about 1995.** `start_spawn_dt_to` is filled on 0 records before 1990, 3,527 of 12,087 in the 1990s, and over 90 % from 2000. The script reads a bin's first day for the start and its last day for the end, which widens the window by up to 9 days at each edge.
- **Round dates dominate before 2000.** 91 to 94 % of start dates before 1990 fall on the 1st, 5th, 10th, 15th, 20th, 25th or 30th (15th alone: 42,492 records).
- **How a date was made is mostly unrecorded.** `estimate_method` is "Unknown Estimate Method" on 82,437 records; `no_inspections_used` is filled on 21,569; `enumeration_methods` on 23,809; survey dates `start_dtt` on 70,847, `end_dtt` on 63,004; `reliability` on 3,297; `accuracy` is UNK on 84,505 and `precision` UNK on 102,409.
- **Fences exist but are few:** "Fixed Site Census" on 290 dated records, mark-recapture 115. These are the records most likely to see an edge.
- **3,701 dated records say NONE OBSERVED** for adult presence: a date on a record with no spawners seen is to be explained before any window counts it.

## Decided at the gate

- **UFRA and COTR chinook rows: keep the dates, rewrite the notes** in the method's wording (start and end are estimated dates; the window speaks to the middle). Any date change is #242's; wet#182 needs no rerun (Al, 2026-11-24).
- **The edge rule is measured and decided here**, for every group: candidate rules measured, one chosen or none, and edge-qualified windows added to the script where a rule admits records (Al, 2026-11-24).

Decided in the plan (mechanism, one line of why each):
- The measurement is a new script, `data-raw/nuseds_dates_check.R`, not more code in `timing_nuseds.R`: it profiles records, the other writes windows, and each has its own log.
- A bin enters as an interval and its midpoint is the record's day for a median; a single date stays itself. Taking the first day of a start bin and the last of an end bin biases both edges outward by construction.
- `timing_nuseds.R` keeps its current start-to-end window as `as_recorded` columns, so its checks of #96's UFRA and COTR windows and #240's BULK window still reproduce, and adds the method's columns beside them. The tracked log of 2026-11-21 stays as written; the rerun writes a new dated log.
- The threshold is set before the results (review finding 13): a rule's edge window is written for a group and species only where it admits at least 5 records (5 population-years), and the rule is adopted only if it leaves at least one group and species with 5. Otherwise NuSEDS bounds no edge here, and the window speaks to the middle only.
- A count is necessary and not sufficient: a rule must also separate dates someone saw from dates written regardless. Added 2026-11-24 after Phase 1's first run showed 1,910 NONE OBSERVED records whose survey fell inside the spawning window they give, and before the test below was run. The test: apply the rule's survey and date-form conditions to records of every adult presence. The rule fails if dated NONE OBSERVED records meet those conditions at half or more of the rate present records do, because then the dates it admits are written whatever was seen. It also fails if most of its admitted records (over half) carry a start or end on the five-day grid, because those are estimates of the season.
- The script and the windows share one reader, `data-raw/nuseds_dates_read.R` (the fetch and sha256 check, the calendar, the placement), so the two cannot read the set two ways; `timing_nuseds.R` moves onto it in Phase 3 under its own reproduction checks.

## Phase 1: Measure what each NuSEDS date is made of

- [x] `data-raw/nuseds_dates_check.R`: read the published set (sha256 checked against the manifest, as `timing_nuseds.R` does) and classify every dated record by: era; date form (a single date on the five-day grid, a single date elsewhere, a bin), bins by width with reversed bins counted (review finding 2); inspections (`no_inspections_used`); `estimate_method`; `enumeration_methods`; survey dates against spawning dates, the start edge and the end edge apart (a start before the first survey day, an end after the last; review finding 1); whether a peak is given; adult presence. Province-wide counts, then by group and population for BULK, MORR, KISP, UFRA and COTR.
- [x] Read the Morice and Nanika records population by population as #241 read the upper Bulkley (#241 asks for it before any MORR row is revised).
- [x] Explain the 3,701 dated NONE OBSERVED and 327 NOT INSPECTED records (what dates they carry and whether any window should count them; review finding 6).
- [x] Read the Morice and Nanika as #241's companion example, so #241 does not repeat it (review finding 16).
- [x] Candidate rules for a record that can bound an edge, each measured as records passing per group and the windows those records alone give: (a) a survey that began before the recorded start and ended after the recorded end, with at least N inspections, counted for each edge apart and both; (b) `estimate_method` "Fixed Site Census" or a Fence in `enumeration_methods`, with its dates set beside `stream_arrival_dt_*` (a fence dates passage, not spawning; finding 4); (c) a start and end off the five-day grid (one exact day may be one visit; finding 5); (d) `estimate_method` "Area Under the Curve", which needs repeated counts (finding 3). Report the count of groups each rule leaves with any edge evidence.
- [x] Log the run to `scripts/logs/timing/<date>_nuseds_dates_check.txt` (written outside the repo and copied in after a run that succeeded, as the script header's RUN line for `timing_nuseds.R` does).

## Phase 2: Set the method from the measurement

- [ ] Write the method into `research/nuseds_timing.md` as a new opening section, "What a NuSEDS spawning date is", with the upper Bulkley as the worked example (#241's records, read again through Phase 1's script) and the Morice and Nanika beside it.
- [ ] Which records can bound an edge, if any: the rule chosen among Phase 1's candidates and why, with the records and groups it admits. Wording: a bracketing survey is consistent with an edge, never proof of one, because NuSEDS keeps no per-visit counts (finding 1). Under the threshold decided above, if no rule passes, say so: NuSEDS bounds no edge, and a window speaks to the middle of the season only.
- [ ] What the window is built from: the bulk of spawning (median start to median end, bins as midpoints), the peak (median peak, with its spread), or both, and which one a cited row's start and end are set beside.
- [ ] What a NuSEDS window may claim beside a cited row, and the sentence a row's `note` uses for it (BULK chinook's annotation in #241's Decisions is the model: NuSEDS supports the middle, its start and end are estimates, not first and last fish seen).

## Phase 3: Rerun the windows under the method

- [x] `data-raw/timing_nuseds.R`: read the bins' second dates, the peak dates and the fields the edge rule needs; compute per window the bulk (bins as midpoints) and the peak (median, 10th and 90th percentiles, n), and the edge-qualified window with its record count where the rule admits any; keep the `as_recorded` columns (from `start_day` and `end_day` as today, over the same records) and point the three reproduction checks at them. A bin's midpoint is taken after `season()` converts both ends, by integer halving; a reversed bin, a bin over 31 days or one straddling the season start gives no midpoint and is counted (findings 2, 9, 10). Whether the method's columns drop NONE OBSERVED and NOT INSPECTED records is Phase 2's; `x` keeps them for `as_recorded`. Move the script onto `data-raw/nuseds_dates_read.R`. Header's WHY and OUTPUT rewritten to say what each column claims.
- [x] The comparison labels each difference as estimate against estimate: a row's start and end beside NuSEDS's bulk, and the row's middle beside NuSEDS's peak; a migration row's end is set beside the day before the bulk's median start, named in the header (finding 7).
- [x] Full run, log and windows CSV copied into `scripts/logs/timing/` under the run's date (`<date>_timing_nuseds.txt`, `<date>_timing_nuseds_windows.csv`).
- [ ] `research/nuseds_timing.md`: the four groups' comparison table relabelled and refilled from the rerun; the `**Verified:**` line names the new logs and #256. `research/README.md`'s row, `scripts/README.md`'s entry and `scripts/logs/timing/README.md` say what the new script and columns are.

## Phase 4: Recheck UFRA and COTR, and hand the method to the reviews

- [ ] UFRA and COTR chinook (#96, which wet's run of Swift and Naver creeks reads, NewGraphEnvironment/wet#182): their spawning windows under the method beside the published rows, with what moved, in `research/nuseds_timing.md` (UFRA's records run 1967-2000, before bins, so the bin rule should move it little; finding 11).
- [ ] Rewrite the UFRA and COTR chinook spawning and migration notes in `data/life_history_timing.csv` in the method's wording, citing the new log beside `20261118_timing_nuseds.txt` (finding 15); dates unchanged. `knw_timing_read()` reads the table cleanly after the edit.
- [ ] Edit #241's and #242's "Waits on #256" lines to say the method is in this PR (linked) and that the Morice and Nanika are read here; the final wording follows the merge (finding 14).

## Owed at the end (reported, done after merge)

- [ ] Tick #256 in #243's members table once the PR merges (if `/gh-pr-merge` does not).
- [ ] After the merge: #241's and #242's "Waits on #256" lines name `research/nuseds_timing.md`'s method section and the note wording, and wet#182's body says the UFRA and COTR dates are unchanged and their notes now say what NuSEDS shows.

## Validation

- [ ] Tests pass (`devtools::test()`; no test reads these scripts today, so this checks nothing broke)
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- Phase 1's counts are re-derived from the parquet by the script, never by hand; the upper Bulkley figures it prints are checked against #241's body (27 records 1953–1991, 13 records 2008–2020, the 2009, 2016 and 2017 starts before the survey).
- `timing_nuseds.R`'s three checks (UFRA 08-11 to 09-05, COTR 08-10 to 09-06, BULK 08-15 to 09-10, with their n) still pass on the `as_recorded` columns, and every `as_recorded` value of the new windows CSV equals `20261121_timing_nuseds_windows.csv`'s on every row (finding 12): the refactor moved no old number.
- A run with `WSG=BULK SPECIES=CH` prints the bulk, peak and edge columns, and the bin midpoint is checked as a numeric day on one hand-read record (11-20 August: day 224 to 233, midpoint 228 by integer halving, 15 August; finding 10).
- Every number in the revised `research/nuseds_timing.md` is read from the new logs; the prose is checked sentence by sentence against them before the PR.

