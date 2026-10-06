# Task: Thermal requirements by species and life stage: degree-days and temperature limits in the evidence table (#38)

## Problem

`data/literature_evidence.csv` has 56 temperature rows (BT, CH, CO, ST). Each is a single °C value, mostly an upper limit, with no `parameter` mapping and nothing for WCT. The vocabulary has two gaps:

- **No thermal-energy variable.** `temperature` accepts only `degC`, so degree-days and thermal units (WCT emergence at 570–600; 800–900 °C-days for recruitment) cannot be recorded.
- **No way to say which metric a value is.** A daily maximum, MWMT, 7DADM, weekly mean and August mean are not interchangeable.

## Decisions at the plan gate (2026-10-06)

- Air-temperature rows (IP-model water proxies) move to a new variable `air_temperature`.
- A degree-day row names its accumulation window in `metric` (`growing_season`, `to_hatch`, `to_emergence`, `annual`, `unstated`); the base temperature goes in the note.

## Phase 1: Vocabulary and schema (tests first)
- [x] Tests in `test-literature.R`: `metric` outside vocabulary refused; `metric` on a non-temperature row
      refused; a `temperature`, `air_temperature` or `degree_days` row with a value and no `metric` refused;
      a degree-day window on a temperature row (and the reverse) refused; `degC-day` fits only `degree_days`;
      a cited `degree_days` row needs a note (its base temperature); fixture gains a `metric` column,
      and the degree-day cases set rows inside the tests.
- [x] `knw_literature_vocab()`: variables `degree_days`, `air_temperature`; unit `degC-day`; `metric` =
      temperature metrics `daily_max`, `daily_mean`, `mwmt`, `7dadm`, `weekly_mean`, `monthly_mean`,
      `august_mean`, `summer_mean`, `annual_mean`, `constant` (lab exposure), `unstated` + windows
      `growing_season`, `to_hatch`, `to_emergence`, `annual`. Which metric fits which variable sits in
      `.literature_check()` beside `fits`.
- [x] `knw_literature_read()`: twentieth column `metric` (after `unit`); roxygen text, example, `devtools::document()`.
- [x] `0280`: any column list or `SCALE` entry that needs `metric`/`degC-day`; nothing else changes.
- [x] `devtools::test()` green in `pkg/`.

## Phase 2: Migrate the 56 existing rows
- [x] Add the blank `metric` column to the CSV (written with `na = ""`, read-back shape = write shape).
- [x] Move the air-temperature rows to `air_temperature`.
- [x] Assign each row's metric from its quote and page context; `unstated` where the source does not say.
      Audit meaning on every row, not a sample (CLAUDE.md, #29 lesson).
- [x] `0280` passes; commit its log.

## Phase 3: Sources and the `temperature` store
- [x] `0270`: a `--collection` argument (default `habitat_modelling`) from which the tag and the default
      members/additions paths derive, and an optional member `pdf` (URL or repo path) for an item no local
      library holds a PDF of; default dry run identical to main (checked before any upload).
- [x] `data/temperature_members.csv`: the keyed members of the collection, the memos, Thorley 2021/2022,
      Cope 2020, Bear 2005/2007, Hasnain et al., Brett 1971, the WCT recovery documents, McMahon 2007,
      NorWeST, and every source a temperature row cites.
- [x] Memo PDFs printed from the rendered analytic appendices (`/analyses/fish-passage-22b/`,
      `/analyses/skeena-stream-temp-25/`; the `/f/` links in Zotero now serve an empty page).
- [x] Bear 2005/2007: paywalled or ResearchGate only; flagged to the user, recorded as a gap.
- [x] `0270 --collection temperature` dry run prints `exists` for `SW2RXUJC`; live run; both memos end
      `pdf present`; wait for Zotero sync and keys.
- [x] `0150 ACTION=build STORE=temperature COLLECTIONS=SW2RXUJC`, then push; log the build and push.
- [x] Rebuild and push `habitat_modelling` (its inputs include `temperature` and the memos).

## Phase 4: Rows for BT, WCT, CH, CO, ST
- [x] `literature.R`: a `none` row may carry `bound` (the bound searched) and `metric`; tests.
- [x] `0280`: a temperature grid, species × cell, in the exit condition and printed. A cell is met by a
      valued row of that variable and stage whose bound reaches it (`max` or `range` for an upper limit,
      `min` or `range` for a lower; `optimum` does not count), or a `none` row with that bound. Cells:
      `temperature` upper and lower for spawning, incubation, rearing; `degree_days` `to_hatch` or
      `to_emergence` for incubation/emergence; `degree_days` `growing_season` for rearing (first-summer
      growth) and overwintering (overwinter size). `air_temperature` never meets a cell. `metric` added to
      the gate log.
- [x] Draft rows from the `temperature` store (`ragnar::ragnar_retrieve()`) and the PDFs. `species_code`
      is the species studied (Colorado River cutthroat values are not WCT rows). `none` notes name what was
      searched. Append only; never re-sort.
- [x] `0280` gate green; a meaning audit of every new row, two rounds at least; commit the gate log.

## Phase 5: `research/thermal_requirements.md` and docs
- [x] What is known per species and stage, what has no source (the `none` cells), and which values
      link#21, template#214 and wet#40 should use; header per `planning.md`.
- [x] `research/README.md` row; `research/stream_temperature.md` evidence and Zotero bullets revised;
      `CLAUDE.md` data line and drafting conventions (metric, air, base in note); `scripts/README.md`
      (evidence columns, grid, `0270 --collection`, the store).
- [x] `pkg/NEWS.md` and `DESCRIPTION` version (a required column is a breaking change).
- [x] Issue #38 body edited to what landed (air variable, window metrics, `mwat`/`7dec`, qualitative rows
      blank, the overwintering cell, Bear gap).

## Validation
- [x] Tests pass
- [x] `/code-check` clean on each commit
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then `/gh-pr-push`

