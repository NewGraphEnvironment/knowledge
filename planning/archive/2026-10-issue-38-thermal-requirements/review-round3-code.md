# Code review, round 3 (round 2 on this code): 0270 --collection, literature.R none-bound, 0280 THERMAL

## Findings

- **[severity: fragile]** scripts/0280-literature-verify.R:474-476 (`meets()`), with pkg/R/literature.R `.literature_check()`.
  The THERMAL rule says "a qual row never meets a cell". `meets()` only gets that
  by keeping valued rows (`valued | kind == "none"`), and the comment at lines 66-71 assumes
  "a qualitative row, which has no value". Nothing enforces that. `knw_literature_read()` accepts
  `kind = "qual"` with `bound = "min"`, `value_min = "4"`, `unit = "degC"`, `metric = "unstated"`
  (probe: it reads back without error). A row like that meets a lower limit cell, so an empty cell
  could pass on a qualitative row. Every qual row in the current CSV (94) is valueless, so the gate
  gives the right answer today. This is a guard that fails toward pass on a future row, and the
  drafter workflow (CLAUDE.md, "the gate checks words, not meaning") is how such a row would arrive.
  Fix: either refuse a value on a qual row in `.literature_check()`, or add `& ev$kind != "qual"` to `hit`.

## Verified, no issue

- `meets()` enumerated against the rule. Valued/none/qual × bound {min, max, range, optimum, NA} ×
  variable {temperature, air_temperature, degree_days} × metric {window, other, NA}: upper takes
  max or range, lower takes min or range, optimum and NA bound never count, degree-day cells check
  only `metric %in% window`, and air_temperature fails on `variable ==`. The CO rearing-lower cell
  is met only by its `none` row with bound min, which is the intended path.
- NA handling. `species_code`, `life_stage`, `variable` and `kind` are required non-NA by
  `.literature_check()`, so `==` in `hit` never yields NA. `bound` and `metric` go through `%in%`.
  `cell$side` is NA only on degree-day cells, which return before it is read. `sum()` of a logical
  gives an integer, so `vapply(integer(1))` holds.
- Cross join: `merge(by = NULL)` gives 5 × 10 = 50 rows. I reproduced the grid independently and
  it matches the script's output (50 of 50).
- Restoring the bug: in a copy of the CSV I deleted the CO rearing temperature `none` row and set
  the WCT incubation degree-day `none` metric to `annual`, then ran the frozen 0280 with
  EVIDENCE=copy and LOG=temp. Output: "thermal: 48 of 50", both cells printed, **exit 1**. Every
  other gate passed in that run, so thermal alone made it fail. The baseline run exits 0, and its
  log is byte-identical to the modified `scripts/logs/habitat/20261006_literature_verify.csv`.
- literature.R: skipping `none` rows in the `need`/`range` checks opens nothing, because a valued
  `none` row is still refused earlier ("a 'none' row carries no value or unit"). The new test fails
  if `!none &` is reverted ("bound max needs value_max"). Literature tests: 79 pass.
- 0270: `COLLECTION` is rebound in `main()` before any use. `item_json`, `do_addition` and
  `find_collection` read the global when called. The member `pdf` is consulted only after
  `has_pdf()` is false. A missing named PDF reports `PDF-MISSING` (upper-case, so it is counted as
  a failure). `re` is imported at module level. An absolute path in `pdf` survives `os.path.join`.
  The existing `habitat_modelling` defaults resolve as before.

## Observation (data, not code)

- One `pref` row (BT spawning temperature, "Preferred ... 5 to 9 degrees Celsius") is coded
  `bound = range`. The other 19 temperature `pref` rows use `optimum`. As coded, it counts toward
  the BT spawning upper and lower cells. It is never the only row in either cell (9 and 4 rows
  remain without it), so the gate's result does not depend on it.
