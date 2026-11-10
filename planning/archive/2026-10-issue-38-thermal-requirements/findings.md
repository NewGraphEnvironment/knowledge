# Findings — Thermal requirements by species and life stage (#38)

## Issue context

**If we do it:** GSDD from wet (NewGraphEnvironment/wet#40), and per-segment temperature later, have cited thresholds to be compared against, by species and life stage, WCT included. **If we never do:** thresholds stay in issue text (NewGraphEnvironment/fish_passage_template_reporting#214, `fish_passage_elk_2022_reporting#55`), and NewGraphEnvironment/link#21 has nothing to read.

## Problem

`data/literature_evidence.csv` has 56 temperature rows (BT, CH, CO, ST). Each is a single °C value, mostly an upper limit, with no `parameter` mapping and nothing for WCT. The vocabulary has two gaps:

- **No thermal-energy variable.** `temperature` accepts only `degC`, so degree-days and thermal units (WCT emergence at 570–600; 800–900 °C-days for recruitment) cannot be recorded.
- **No way to say which metric a value is.** A daily maximum, MWMT, 7DADM, weekly mean and August mean are not interchangeable.

## Proposed solution

1. **Vocabulary and schema** (decided 2026-10-06):
   - a `degree_days` variable, unit `degC-day`;
   - a new **`metric` column** in `literature_evidence.csv`, blank on non-temperature rows and validated against a short vocabulary (daily max, daily mean, MWMT, 7DADM, weekly mean, monthly or August mean, season total);
   - `knw_literature_read()` and its tests updated for the new column;
   - each of the 56 existing temperature rows assigned its metric from its quote.
2. **Sources:**
   - attach the PDFs to the two stream-temperature memos (`hill_etal2024Spatialstream`, `hill_etal2025Spatialstream`; both are URL stubs now);
   - the `Fisheries/temperature` collection (22 items);
   - Coleman & Fausch 2007, Thorley et al. 2022 (Upper Fording), and the references `gsdd` cites;
   - a `temperature` store, built the way `0270`/`0150` build `habitat_modelling`.
3. **Rows**, gated by `0280`, for **BT, WCT, CH, CO, ST** (decided 2026-10-06):
   - thermal energy: emergence, first-summer growth, overwinter size;
   - upper and lower limits, each with its metric.
4. **`research/thermal_requirements.md`:** what is known per species and stage, what has no source, and which values link#21, template#214 and wet#40 should use. Technical background on the models is in `research/stream_temperature.md`.

Relates to #19, #20, #36, an internal issue


## Exploration (2026-10-06)

- `pkg/R/literature.R`: `knw_literature_vocab()` + `.literature_check()` with a `fits` variable→unit map;
  19 hard-coded columns in `knw_literature_read()`; tests in `pkg/tests/testthat/test-literature.R`.
- **About 12 of the 56 rows are air temperature** (Agrawal LMAT, Boughton/Burnett mean August air,
  Spence/Agrawal max air 21.5). Decided at the gate: new variable `air_temperature`.
- **Degree-days need their window.** Decided at the gate: the metric names the window
  (`growing_season`, `to_hatch`, `to_emergence`, `annual`, `unstated`), base temperature in the note.
- `Fisheries/temperature` (group key `SW2RXUJC`) holds Coleman & Fausch 2007 a/b, Chezik 2014,
  Lusardi 2020, Weller 2024, Iacarella 2024 and others with PDFs. The two Hill memos (`QYU2YFFZ`,
  `F4Y3AQZH`) have no PDF. The memos are HTML pages, not PDFs.
- `thorley_etal2022UpperFording` (`84VRXIII`) has a PDF but is not in the collection. `bear_etal2007ComparativeThermal`
  (WCT thermal tolerance) is in the group with **no PDF**.
- `gsdd` cites only Coleman & Fausch 2007 (README and roxygen, `poissonconsulting/gsdd`).
- `scripts/0270-habitat-collection-build.py` hard-codes `GROUP_LIB_NAME = "habitat_modelling"`, its tag,
  and the members/additions paths; `0150 ACTION=build` takes `COLLECTIONS=<key>`.
- `0280` checks values against quotes (`value_in_quote`, `SCALE` per unit) and coverage per
  species × `parameter` only.


## Errors Encountered

| Error | Resolution |
|-------|------------|

## Phase 1–2: metric assignments (2026-10-06)

- `0280` needed no change: a unit without a `SCALE` entry reads at scale 1, which is right for `degC` and
  `degC-day`; the registry link is keyed on model_id × species × stage × form, not variable, so moving
  rows to `air_temperature` leaves every link intact (gate: 0 unlinked either way).
- Two statistics in the sources were not in the issue's list and were added: `mwat` (Eaton & Scheller
  1996, maximum weekly mean, FTDMS) and `7dec` (Iacarella et al. 2024: the 7-day equivalent constant,
  "the median value between 7DADM and MWAT", the BC exceedance threshold of 24 °C).
- Checked against the PDF text where the note did not settle it: Richter & Kolmes Table 1 is 7-DAM then
  weekly mean (text: "propose 7-DAM temperatures ... and also weekly mean temperature criteria"); the
  Olson & Foster spawning range is daily average ("spawning temperature ranges in daily average
  temperatures (DAT)"); Raleigh's juvenile HSI variable V2 is "Maximum temperature during warmest
  periods" (→ `daily_max`, noted on the row); Dunham & Chandler Figure 4 is maximum daily temperature;
  Cooney & Holzer's WMAT is a weekly mean.
- 14 rows moved to `air_temperature`: Agrawal LMAT (3), Sheer on Spence/Agrawal (1), Bjorkstedt (2),
  Lindley (2), Boughton & Goslin (4: two August means, two annual means), and the two qualitative Sheer
  rows on Weiss (242, 245; Sheer p. 8: "30-year air temperature mean"; found by code-check round 1).
  Busch rows 220/226 stay `temperature`: Sheer does not state Busch's medium.
- 21 water rows are `unstated`: the source gives a range or threshold without a statistic.
- 7 qualitative rows carry no value and no metric (5 `temperature`, 2 `air_temperature`); a cited row
  with no value is refused a metric, a `none` row may name the one it searched for.
