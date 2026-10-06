# Code-check round 1: `metric` column, `air_temperature`, `degree_days` (#38)

Scope: staged diff (pkg/R/literature.R, man, tests, planning, logs) plus the CSV migration
(`git show HEAD:` vs index of data/literature_evidence.csv), and the readers 0280, pkg/R/ip.R, scripts/029*.R.

## Findings

- **[severity: fragile (row meaning)]** data/literature_evidence.csv data row 242 (CO rearing, `qual`,
  sheer_etal2009DevelopmentManagement p. 8, quote "Temperature (Spence/Agrawal, Weiss") is an
  air-temperature row and was left as variable `temperature`. Sheer p. 8 reads in full: "Temperature
  (Spence/Agrawal, Weiss [mean January minimum temperature, mean July maximum temperature, 30-year air
  temperature mean])" (pdftotext of the group PDF). Both models it names use air temperature:
  Spence/Agrawal is the LMAT air mask (the value row from the same document, row 288, was moved to
  `air_temperature` here), and Weiss's inputs are "30-year air temperature" normals. So
  `knw_literature_read(variable = "temperature")` still returns a water-temperature claim about two air
  models, which is the mix-up the new variable exists to prevent. The row's note also says only "mean
  January minimum and mean July maximum", without "air". Fix: move row 242 to `air_temperature` (it has
  no value, so it needs no metric) and say "air" in the note. Rows 220, 226 and 245 (p. 12, "Temperature
  (Busch, Cooney and Holzer, Weiss [mean January min, mean July max])") are mixed lists: Cooney & Holzer
  is modelled water WMAT (row 408), so leaving those three as `temperature` is defensible.

## Checked and found sound

- CSV migration: 510 rows before and after. Field by field, the only changes are the inserted `metric`
  field (461 blank + 49 filled + header), 12 `variable` changes (rows 282-284, 288, 302, 303, 306, 309,
  316, 317, 324, 325), and 3 note appends (rows 144, 145, 159). Each append is the old note plus a
  leading-space sentence. The word diff shows no other bytes changed: no BOM, LF only, trailing newline
  kept, and quoting unchanged except row 145's note, which is now quoted because the appended text has
  a comma. The staged copy matches the working copy byte for byte.
- Metric assignments spot-checked against the PDFs: Richter & Kolmes Table 1 ("7-Day-average maximum
  daily" then "Weekly mean") gives 7dadm on 134-137; Eaton & Scheller's "maximum weekly mean" gives mwat
  on 147; Raleigh V2 "Maximum temperature during warmest periods" gives daily_max on 144-145; Hicks
  "daily maximum temperatures" gives daily_max on 133; Iacarella gives 7dec on 148. The `unstated` rows
  I read (139, 140, 131, 132) give no statistic in the source sentence.
- literature.R: the vocabulary loop checks `metric` as an optional column (blank allowed, otherwise in
  the union). The window/statistic cross-checks refuse `annual` on temperature and `7dadm` on
  degree_days. The `stray` check runs before `misfit`, and `[[` on a list does not partial-match, so
  `mfits[[v]]` is NULL for a non-metric variable and NA metrics are masked. `degC-day` is added in both
  the vocabulary and `fits`. `bare` uses `has_value`, so qual and none rows are exempt.
- A zero-row table fails at `!mapply(...)` (mapply returns `list()`). This is not new: the
  unit-fit mapply above it already fails the same way.
- 0280: no column list to update. `degC`/`degC-day` have no SCALE entry, so they read at scale 1,
  which is correct. The model link key does not involve `variable`. The committed 20261006 log shows
  510 rows all passing, 12 of them `air_temperature`, and 117/117 registry quotes passing.
- ip.R takes named subsets of `knw_literature_vocab()` (life_stage, life_history_form,
  quote_source), so the new `metric` entry does not reach it. scripts/029*.R do not read the
  evidence table, and no other local repo reads it.
- `devtools::test()` in pkg/: FAIL 0, PASS 196.
- research/stream_temperature.md:120 still says "56 temperature rows". Phase 5 of the plan already
  revises that bullet, so I have not raised it as a finding.
