# Review: #44 Phase 1 staged diff, round 1

## Clean

No issues found.

## What was checked (evidence, not findings)

- Tests: in a `git checkout-index` copy of the staged tree, `devtools::test("pkg", filter = "literature|ip")`
  gave FAIL 0, PASS 152. The staged `data/literature_evidence.csv` reads through `knw_literature_read()`:
  44 `discharge` rows and 1 `instream_flow` row (m3/s, `unstated`, min 1).
- Rd: `devtools::document()` in the copy regenerated `pkg/man/` byte-identical to the staged Rd files.
- Guards fire: adding `"percent MAD"` to `fits$discharge` turned `test-literature.R:419` red. (Removing a
  single flow metric such as `7day_low` is not caught by any test. That is a coverage gap, not a bug.)
- Consumers:
  - `.ip_check()` (`pkg/R/ip.R:121`) takes only `life_stage`, `life_history_form` and `quote_source` from
    `knw_literature_vocab()`, so the additions do not reach it.
  - `0280`: `value_in_quote()` looks up `SCALE[[r$unit]]`. `[[` matches exactly, so `percent MAD` cannot
    partial-match `percent` and pick up its x100 rescale. It falls through to scale 1, which fails closed.
  - `0280`: THERMAL `meets()` filters on `variable == "temperature"`/`"degree_days"`, so the new metric
    names (`daily_mean`, `monthly_mean`, `annual_mean`, which `instream_flow` shares with temperature)
    cannot leak into a thermal cell.
  - `0280`: COVERAGE counts by `parameter`, and the moved row has none.
- Data/log agreement: CSV file line 122 is data row 121, and that matches the changed log row 121. Both
  files have 687 lines. `research/modelled_discharge.md:93` cites "evidence data row 121" for Gottesfeld &
  Rabnett, and that row number still holds.
- The metric vocabulary has no duplicates (`unique()`), and the existing vocab test still asserts that.

## Notes, not defects

- `scripts/README.md:342` and the `CLAUDE.md` data line still list only the temperature and degree-day
  metrics. The plan already covers both in Phase 5. A drafter who follows the stale text and leaves an
  `instream_flow` metric blank is stopped by the gate.
- Boughton & Goslin 2006 "Summer Discharge" HSI rows (ST rearing) stay `discharge`, as stream size. That is
  a call about meaning, and `progress.md` records the reasoning. Nothing in the code depends on it.
