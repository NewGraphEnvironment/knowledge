# Task: Thermal requirements by species and life stage: degree-days and temperature limits in the evidence table (#38)

## Problem

`data/literature_evidence.csv` has 56 temperature rows (BT, CH, CO, ST). Each is a single °C value, mostly an upper limit, with no `parameter` mapping and nothing for WCT. The vocabulary has two gaps:

- **No thermal-energy variable.** `temperature` accepts only `degC`, so degree-days and thermal units (WCT emergence at 570–600; 800–900 °C-days for recruitment) cannot be recorded.
- **No way to say which metric a value is.** A daily maximum, MWMT, 7DADM, weekly mean and August mean are not interchangeable.

## Decisions at the plan gate (2026-10-06)

- Air-temperature rows (IP-model water proxies) move to a new variable `air_temperature`.
- A degree-day row names its accumulation window in `metric` (`growing_season`, `to_hatch`, `to_emergence`, `annual`, `unstated`); the base temperature goes in the note.

## Phase 1: Vocabulary and schema (tests first)
- [ ] Tests in `test-literature.R`: `metric` outside vocabulary refused; `metric` on a non-temperature row
      refused; a `temperature`, `air_temperature` or `degree_days` row with a value and no `metric` refused;
      a degree-day window on a temperature row (and the reverse) refused; `degC-day` fits only `degree_days`;
      fixture gains a `metric` column and a degree-day row.
- [ ] `knw_literature_vocab()`: variables `degree_days`, `air_temperature`; unit `degC-day`; `metric` =
      temperature metrics `daily_max`, `daily_mean`, `mwmt`, `7dadm`, `weekly_mean`, `monthly_mean`,
      `august_mean`, `summer_mean`, `annual_mean`, `constant` (lab exposure), `unstated` + windows
      `growing_season`, `to_hatch`, `to_emergence`, `annual`. Which metric fits which variable sits in
      `.literature_check()` beside `fits`.
- [ ] `knw_literature_read()`: twentieth column `metric` (after `unit`); roxygen text, example, `devtools::document()`.
- [ ] `0280`: any column list or `SCALE` entry that needs `metric`/`degC-day`; nothing else changes.
- [ ] `devtools::test()` green in `pkg/`.

## Phase 2: Migrate the 56 existing rows
- [ ] Add the blank `metric` column to the CSV (written with `na = ""`, read-back shape = write shape).
- [ ] Move the air-temperature rows to `air_temperature`.
- [ ] Assign each row's metric from its quote and page context; `unstated` where the source does not say.
      Audit meaning on every row, not a sample (CLAUDE.md, #29 lesson).
- [ ] `0280` passes; commit its log.

## Phase 3: Sources and the `temperature` store
- [ ] `0270`: a `--collection` argument (default `habitat_modelling`) from which the tag and the default
      members/additions paths derive; habitat_modelling behaviour unchanged (dry run identical).
- [ ] `data/temperature_{members,additions}.csv`: the current collection, `thorley_etal2022UpperFording`,
      `bear_etal2007ComparativeThermal`, and the two memos.
- [ ] Memo PDFs: print each rendered memo to PDF with headless Chrome; attach through `0270`.
- [ ] Bear et al. 2007 PDF through the PDF fallback chain; if paywalled, flag it and record the gap.
- [ ] `0270 --collection temperature` dry run, then live; wait for Zotero sync and keys.
- [ ] `ACTION=build STORE=temperature COLLECTIONS=SW2RXUJC` with `0150`, then `ACTION=push`.

## Phase 4: Rows for BT, WCT, CH, CO, ST
- [ ] `0280`: a temperature coverage grid, species × cell, each met by a value or a `none` row:
      `degree_days` to_hatch/to_emergence (incubation, emergence); `degree_days` growing_season (rearing:
      first-summer growth, overwinter size); `temperature` max and min for spawning, incubation, rearing.
- [ ] Draft rows from the store and the PDFs, each with its metric (a drafter brief like #29's if it fans out).
- [ ] `0280` gate green; a meaning audit of every new row; commit the gate log.

## Phase 5: `research/thermal_requirements.md` and docs
- [ ] What is known per species and stage, what has no source (the `none` cells), and which values
      link#21, template#214 and wet#40 should use; header per `planning.md`.
- [ ] `research/README.md` row; `research/stream_temperature.md` evidence bullet revised;
      `CLAUDE.md` data line for `literature_evidence.csv` (metric column) and the new store;
      `scripts/README.md` for `0270 --collection`.
- [ ] Issue #38 body edited to the decisions taken (air variable, window metrics).

## Validation
- [ ] Tests pass
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then `/gh-pr-push`

