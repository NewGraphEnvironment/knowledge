# Code-check round 2: `metric` column, `air_temperature`, `degree_days` (#38)

Scope: the round-1 fix (data rows 242 and 245 moved to `air_temperature`) and a full re-audit of the
water/air split and of every `metric` on the valued `temperature` rows. Staged copies only
(`git show :path`); tests run in a copy of `pkg/` in the scratchpad.

## Findings

- **[severity: fragile (wrong count in the record)]** planning/active/findings.md:73 and
  planning/active/progress.md:10 say "12 rows moved to `air_temperature`" ("56 rows migrated (12 to
  air)"). After the round-1 fix the staged CSV has **14** `air_temperature` rows, and so does the staged
  0280 log (`scripts/logs/habitat/20261006_literature_verify.csv`, 14 matches). The findings bullet's
  breakdown (Agrawal 3, Sheer on Spence/Agrawal 1, Bjorkstedt 2, Lindley 2, Boughton & Goslin 4) is
  missing the two Sheer-on-Weiss qualitative rows (242, 245). Phase 5 rewrites
  research/stream_temperature.md's counts, and this is where it will take them from. Fix: 14, plus
  "Sheer on Weiss (2, qualitative)". The other counts in that block are still right: 56 rows in all,
  21 water `unstated`, 7 qualitative with no metric (5 water, 2 air).

- **[severity: fragile (guard narrower than its doc)]** pkg/R/literature.R, `.literature_check()` metric
  block, against the roxygen at `knw_literature_read()` ("every other row leaves `metric` blank"). The
  code refuses a metric only on a variable outside `names(.knw_metric_fits())`. So a `kind = "none"`
  row, or a qualitative row with no value, on `temperature`/`air_temperature`/`degree_days` can still
  carry a metric. I probed both on a fixture copy: `none` row with `variable = temperature,
  metric = mwmt` is ACCEPTED; `qual` temperature row with no value and `metric = 7dadm` is ACCEPTED.
  The `none` case does not match how the rest of the function treats those rows: a `none` row is
  refused a value, unit, key, quote, quote_source and model_id, so a metric there is a statistic for
  a search that found nothing. No current row hits this (all 49 filled metrics are on valued
  `temperature`/`air_temperature` rows). Fix: refuse a metric on `none` rows, and either refuse it on
  value-less rows too or narrow the doc sentence to say what the code does.

## The round-1 fix: right and complete

- **242 (CO, herger2003, Sheer p. 8)** and **245 (CH, herger2003, Sheer p. 12)** are now
  `air_temperature`. Sheer p. 8 (pdftotext of the group PDF) reads "Temperature (Spence/Agrawal, Weiss
  [mean January minimum temperature, mean July maximum temperature, 30-year air temperature mean])". Of
  Weiss's three items, only the third is literally called air. Herger et al. 2003 is not in the group
  library, so the first two cannot be checked against the primary. They are climate-normal statistics
  and are not stream measurements, so reading all three as air is the best available reading. The
  appended notes quote "30-year air temperature mean" verbatim and do not overstate it.
- **Every model_id carrying a temperature-family row**, tabulated: agrawal2005 6, lindley2006 2,
  boughton_goslin2006 4 and herger2003 2 are all `air_temperature`, with none left as `temperature`.
  busch_nwfsc 2 (220, 226) and cooney_holzer2006 1 (408) are `temperature`.
  - 220/226: the medium is unstated in Sheer, and busch_etal2011 (the group's published model, in the
    library) has no temperature variable at all. Leaving them as `temperature` is the accepted call,
    and nothing contradicts it.
  - 408: Cooney & Holzer App. C (C-9) builds a **water**-temperature model ("a water temperature model
    was used", "modeling water temperatures") that predicts exceeding a WMAT of 22 C from NCDC July air
    temperature, forest cover and elevation. Sheer p. 21 paraphrases this as "weekly mean annual air
    temperature in July >= 22 C", but the primary's variable is modelled water WMAT. `temperature` and
    `weekly_mean` are right.
- **I grepped the whole CSV, every variable, for air/temperat/LMAT/PRISM/climat/thermal/degC in quote
  and note.** Air mentions outside temperature-family rows: the companion value rows of the same models
  (285-289 Sheer/Agrawal gradient and discharge, 304-308 Lindley, 326 Boughton substrate) and the
  herger2003 gradient/substrate rows (241, 243, 244, 246). None of these is a temperature value under
  the wrong variable. Roberge rows 32/33 quote "average maximum summer temperature of 19.6 C" inside a
  gradient/width claim, and no temperature row was made from it. Rows 484, 493 and 503 (qual) are about
  stream temperature: water.

## Metric assignments re-verified against the PDFs

- 133 Hicks "daily maximum temperatures": `daily_max`.
- 134-137 Richter & Kolmes Table 1, "7-Day-average maximum daily | Weekly mean", first column: `7dadm`.
- 138 Olson & Foster daily average (per findings): `daily_mean`.
- 139 (McCullough "maintained below 12 C"), 140 (Hicks optimal 12.2-14.8), 131/132 (Bell/Spence ranges):
  the sentence gives no statistic, so `unstated`.
- 144/145 Raleigh: the p. 11 text gives a tolerance range from lab work with no statistic. The
  `daily_max` comes from HSI variable V2, "Maximum temperature during warmest periods when adults or
  juveniles are present" (curve page), and the note says so.
- 147 Eaton & Scheller Table 1, "maximum weekly average temperature tolerance", with methods "maximum
  weekly mean temperature was calculated for each USGS station": `mwat`.
- 148 Iacarella, the median between 7DADM and MWAT: `7dec`.
- 154 Selong, lab growth at constant temperatures: `constant`.
- 155 Isaak, "mean August temperature": `august_mean`. 156 "mean summer temperatures": `summer_mean`.
- 157 Dunham & Chandler Fig. 4, "Maximum daily temperature" (p. 13: "maximum daily temperature
  (warmest temperature of the year)"): `daily_max`.
- 158 Sauter p. 15 ">55.4 (13 C) reportedly block migratory behavior", no statistic: `unstated`.
  159 Sauter Table 2, "42.8-48.2 (6-9) AWAT": `weekly_mean`, and the note names AWAT. Sauter does not
  define AWAT, and the Rieman & Chandler 1999 primary was not checked.
- 141-143 Bjornn & Reiser, 146/160 Roberge, 149-153 McPhail & Baxter and Rieman & McIntyre, 161
  Bustard ("did not exceed 9 C at any time ... less than 8 C during the spawning period"), and
  492/504/508-510: none of them states a statistic, so `unstated`.
- Air rows: Agrawal/Bjorkstedt "lowest mean August air temperature" (Bjorkstedt p. 54 checked) and
  Lindley "mean August air temperature" are `august_mean`. Boughton Table 5 "Mean August Temp." is
  `august_mean` and "Mean Annual Temp." is `annual_mean`.

## Code: checked and sound

- CSV diff, field by field against HEAD: changes only in `variable` (rows 242, 245, 282-284, 288, 302,
  303, 306, 309, 316, 317, 324, 325) and `note` (144, 145, 159, 242, 245), plus the new column.
- `knw_literature_read()` reads the staged CSV: 42 `temperature`, 14 `air_temperature`.
- `devtools::test(filter = "literature")` on a copy of `pkg/`: all pass.
- The `bare`, `stray`, `misfit` and `dd_bare` checks run in the right order for the test regexes. The
  `[[` on a list does not partial-match, so `mfits[[v]]` is NULL for a non-metric variable.
- No R, Python or JS in the repo filters on `variable == "temperature"`, so the move to
  `air_temperature` reaches no consumer other than 0280. The staged 0280 log was regenerated after
  the fix (14 air rows).
