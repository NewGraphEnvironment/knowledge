# Code-check round 1 — knw_timing_read (#25)

## Findings

- **[bug]** pkg/R/timing.R `.timing_check_windows()`, the split-at-1-January check
  (`any(x$end[i] == "12-31") && any(x$start[i] == "01-01")`) — it tests `start` and `end`
  across the group's rows independently, so a **single** row `01-01`–`12-31` (a year-round
  window, e.g. rearing) matches both halves and is refused as "window split at 1 January".
  Probed: a one-row table `MORR CO rearing 01-01 12-31` errors with
  `window split at 1 January for MORR CO rearing; write it as one row with start > end`.
  The message is false (nothing is split) and its remedy cannot express a whole year
  (`start > end` with no gap is impossible). The seed CSV has no such row today, but
  year-round rearing/overwintering is an ordinary life-history entry. Fix: require the two
  halves to come from different rows (`any(end == "12-31" & start != "01-01") &&
  any(start == "01-01" & end != "12-31")`, or compare row indices), and add a test with a
  one-row full-year window.

- **[fragile]** pkg/R/timing.R validation block — `wsg_code` and `species_code` are never
  checked for NA/empty. A row with a blank group or species passes every check (the overlap
  key becomes `"NA CO rearing"`), is returned by an unfiltered read, and is silently dropped
  by any `wsg_code =`/`species_code =` filter with no warning — the filter-absent warning
  fires only for requested codes, not for rows the filter can never reach. Probed: a 2-row
  table with one blank `wsg_code` reads 2 rows unfiltered and 1 with `wsg_code = "MORR"`.
  Since the file is validated "whichever group is asked for", a blank key should be refused
  like a blank `life_stage` is.

Everything else checked clean: MM-DD regex + real-date check (02-29 allowed, 02-30 refused),
start==end refusal, overlap by day-of-year on a leap year including wrapping windows,
BOM handling, `get(arg)` resolving the function arguments, zero-row filter result keeps
columns, `chk_null_or` argument checks.
