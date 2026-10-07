# Code-check review, round 1 (#36, groundwater variable)

## Clean

No issues found.

What was checked:

- `.literature_check()`: a groundwater row cannot carry a value. A value needs a unit
  (`no_unit`), and any unit on a groundwater row fails `misfit`, because
  `u %in% character(0)` is FALSE. `mapply` returns one logical per row whatever the
  length of `fits[[v]]`, so the zero-length entry does not change the shape. `[[` on the
  list matches names exactly, so no partial match is possible.
- `bound` min, max and range all require their value, so they need a unit too, which is
  refused. `optimum` on a qual row with no value is allowed, but that was already true
  for every variable, so this diff did not introduce it.
- `none` rows: still refuse any value or unit. `metric` on a groundwater row is refused
  as `stray`, because groundwater is not in `.knw_metric_fits()`.
- Test: the second and third assertions reach `misfit`, and each expects that message
  specifically (the fixture's row 1 has `value_min` NA, `metric` NA and a quote of 20
  characters or more). Changing `fits` to `c("m/s")` turns both red, as the author reported.
- Consumers: `pkg/R/ip.R` takes only `life_stage` and `life_history_form` from the
  literature vocab. `scripts/0280` returns TRUE from `value_in_quote()` before it looks
  anything up for a row with no value, and its THERMAL cells name only `temperature` and
  `degree_days`. A new variable breaks neither.
- Ran `test-literature.R` (all pass) and the full `tests/testthat` suite (no failures),
  against the source tree via `load_all`. The committed `data/literature_evidence.csv`
  still validates.
