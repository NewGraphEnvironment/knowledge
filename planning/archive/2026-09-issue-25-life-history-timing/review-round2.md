# Code-check round 2 — knw_timing_read (#25)

Both round-1 fixes are correct for the cases they target. `outer(tail_i, head_i, "!=")`
returns a 0-length matrix when either side is empty, so `any()` is FALSE. A single
`01-01`..`12-31` row gives `tail_i == head_i`, so it is FALSE there too. A real two-row split
is still caught, and a full-year row next to a `12-31`..`01-01` row is caught as an overlap
before the split check runs. The blank-key check works for both NA and `""`, because
`na.strings = ""` turns a quoted empty into NA as well.

## Findings

- **[bug, minor]** pkg/R/timing.R:101-104,113-114. The split check only sees rows where both
  ends are present (`full`), and a key is only visited if it has at least one full row. So a
  split pair where either half is a half window is not refused, even though the roxygen says
  "a window ending `12-31` beside one starting `01-01` is refused". Probed (both read 2 rows,
  no error):
  - `11-01..12-31` + `01-01..NA`
  - `NA..12-31` + `01-01..03-01`

  This is the likeliest shape of the case the check exists for: the seed converts a 1900/1901
  source into year-split rows, and one side of a split can easily have an open end. Fix:
  compute `tail_i`/`head_i` over all rows of the key (`end == "12-31"` with `start` possibly
  NA, `start == "01-01"` with `end` possibly NA). Use `%in%` or `!is.na()` so NA does not
  propagate into `i[...]`, and iterate over `unique(key)` rather than `unique(key[full])` for
  that check. Keep the overlap check on `full` rows only. Add a test with a half-window half.

- **[low]** pkg/R/timing.R:56. The blank-key check misses a whitespace-only `wsg_code` or
  `species_code`. Probed: `species_code = " "` reads without error, and a filter then drops
  that row silently, which is the failure round 1 flagged. Only relevant if the CSV is
  hand-edited. `trimws()` before the NA test would close it.

Otherwise clean. I checked `get(arg)` with NULL filters, the zero-row result, the order of
the overlap and split checks, the 02-29 leap-year DOY, and the wrap `c(a:366, 1:b)`.
