# Task: Flow needs by species and life stage: literature into the evidence table (CH, CO, SK, BT, GR, WCT) (#44)

## Problem

Species: Chinook, coho, sockeye, bull trout, Arctic grayling, westslope cutthroat, and steelhead/rainbow where the sources cover them.

The evidence table's discharge rows are annual IP-model MAD thresholds plus one salmon migration low-flow statement (Gottesfeld & Rabnett, upper Bulkley). No row ties a life stage to a seasonal flow. The literature that does is either undrafted or missing from the library:

- **In the group library, not drafted as flow evidence:**
  - `raleigh_etal1986HabitatSuitablility`: Chinook HSI and instream flow suitability curves, depth and velocity by life stage.
  - `bjornn_reiser1991HabitatRequirements`: depth and velocity criteria.
  - `warkentin_etal2022Lowsummer`: summer low flow and Chinook productivity.
  - `eclipsegeomaticsltd_2016Upperbulkley`: Upper Bulkley thresholds.
  - `macisaac2010SalmonidsHydrologic`
  - `northwesthydraulicconsultantsltd_hamiltonr_1993FinalReport`
  - `woelfle-erskine_etal2017Abiotichabitat`
  - `amecenvironment&infrastructure2015Appendix5126D`
- **Not in the library (from memory, to verify):**
  - BC Instream Flow Thresholds for Fish and Fish Habitat (Hatfield, Lewis, Ohlson & Bradford 2003).
  - Ptolemy & Lewis 2002, rationale for BC instream flow standards.
  - Hatfield & Bruce 2000: western North America PHABSIM results pooled into regressions of optimum flow on MAD, by species and stage.
  - Bradford & Heinonen 2008, low flows and instream flow needs in small streams.
  - DFO 2013 ecological flow framework.
  - Tennant 1976.
  - USFWS HSI/instream flow models for the other species: coho, cutthroat, Arctic grayling (Hubert et al. 1985).
  - Washington Ecology instream flow studies.
  - Central Valley Chinook flow–habitat (WUA) reports.

## Decisions at the plan gate (2026-10-07, Al)

1. A new variable `instream_flow` for flow needs, kept apart from `discharge` (stream size).
2. Months: no new column. The stage window comes from `life_history_timing.csv`, and the note names any
   months a source gives.
3. Grid species: CH, CO, SK, BT, GR, WCT **and ST**. RB gets rows where sources give them, and no grid
   cells.

## Phase 1: Vocabulary (tests first)
- [x] Tests in `pkg/tests/testthat/test-literature.R`: `instream_flow` accepted with `m3/s`, `cfs` or
      `percent MAD`; `percent MAD` refused on any other variable (`discharge` included); an `instream_flow`
      value with no `metric` refused; a `discharge` row with a metric still refused.
- [x] `knw_literature_vocab()`: variable `instream_flow`; unit `percent MAD`; `.knw_metric_fits()` gains
      `instream_flow = c("instantaneous", "daily_mean", "7day_low", "monthly_mean", "monthly_median",
      "seasonal_mean", "annual_mean", "unstated")`. Roxygen explains stream size vs flow need. A fraction
      of MAD is `percent MAD`, and its metric is the statistic the flow is held to.
- [x] `fits` in `.literature_check()` updated; `devtools::document()`; `devtools::test()` green.
- [x] Audit all 45 `discharge` rows. Move the flow needs (Gottesfeld CH migration; any other one found) to
      `instream_flow` with a metric (`unstated` if the source does not say). The stream-size rows stay.
- [x] Plan-review fixes (`review-plan.md`): `annual_mean` dropped from the flow metrics; `depth` takes `cm`,
      `ft`, `m bankfull` and `velocity` `cm/s`, `ft/s` (units as the source wrote them); the Sloat bankfull
      depths (rows 250, 257, 264) move to `m bankfull`; an `instream_flow` row carries no `parameter` or
      `model_id`, and `*_mad_*` parameters sit on `discharge` only. Tests for each, and a mutation run.
- [x] `0280` passes on the migrated table; commit its log.

## Phase 2: Sources, the `flow` collection and store
- [x] `data/flow_members.csv`: the eight keys from the issue, plus the grayling, flow and HSI items in the
      group (raleigh 1984, stewart 2007, cutting 2018, hagen 2015 and others found by the search).
- [x] `data/flow_additions.csv`, holding only items whose PDF is reachable now (review O1): Hatfield et al. 2003, Ptolemy & Lewis 2002, DFO 2013 flow framework
      (CSAS SAR 2013/017), Hubert et al. 1985, McMahon 1983, Hickman & Raleigh 1982, Hatfield & Bruce 2000,
      Bradford & Heinonen 2008, Tennant 1976, and one Washington Ecology and one Central Valley WUA report.
      Government and open-access items get a PDF URL; each URL is checked for a `%PDF` body before it goes in.
- [ ] Paywalled or ResearchGate-only items, plus the amec 2015 and raleigh 1984 PDFs: open them in Chrome,
      then send Al one phone-answerable checkpoint: a list, and a single `cp` command from `~/Downloads`
      into `data/<repo path>`. Work continues on everything else while that is outstanding. An item never
      obtained is recorded as a gap, as Bear 2005/2007 was in #38. When the copies land: add their rows, re-run
      `0270`, rebuild and re-push the store, re-extract text.
- [x] `Fisheries/flow` is not a `habitat_modelling` input, so that store is not rebuilt (review G7).
- [x] `0270 --collection flow --dry-run`, then a live run; wait for Zotero sync and BBT keys.
- [x] `0150 ACTION=build STORE=flow COLLECTIONS=<key>`, then `ACTION=push`. Log both under
      `scripts/logs/habitat/`.

## Phase 3: The FLOW grid in `0280`
- [x] `FLOW` list next to `THERMAL`, with species CH, CO, SK, BT, GR, WCT, ST. Cells: an `instream_flow`
      need for spawning, incubation, rearing, overwintering and migration, met by `min`, `range` or `optimum`
      (review G1); `depth` lower for spawning and migration (`min` or `range`; not `m bankfull`); `velocity`
      upper for spawning and rearing (`max` or `range`). SK has no instream-flow rearing or overwintering cell
      and no velocity rearing cell, because it rears in lakes (review A5). That makes 7 × 9 − 3 = 60 cells.
      A `none` row meets a cell by the same bound. The grid is printed and joins the exit condition.
- [x] `SCALE` gains `percent MAD = c(1, 100)`, as `percent` has (review G9).
- [x] Record the grid baseline before drafting (2 of 60: CH migration flow need, BT spawning velocity), and
      enumerate `meets_flow()` over variable × kind × bound × unit (review AC1).
- [x] Once the grid is full, a frozen-copy negative run: one `none` row removed → exit 1.
- [x] Header comment and the `scripts/README.md` gate description updated.
- [x] Vocabulary checkpoint after reading Hatfield 2003, Ptolemy & Lewis 2002 and DFO 2013: add the flow
      metrics they use before the brief is written; a `7day_low` row gives its return period in the note
      (review G4). Added units `percentile` and `percent exceedance` (Hatfield 2003's monthly percentiles
      of mean daily flows; Ptolemy & Lewis's Q95), and the `7day_low` note rule.

## Phase 4: Draft rows, then the gate and the meaning audit
- [x] Ask Al how a standard that names no species is coded (review G2): group codes `FISH`, `SALMON`,
      `SALMONIDS`, filling no cell (2026-10-07); row 121 recoded `SALMON`.
- [x] Drafter brief in `planning/active/` (adapted from the #38 brief; this session's copies of the #29
      `scratch_keytext.py`/`scratch_merge_drafts.py`) and text extraction of every
      collection PDF. Two drafters (unnamed; `general-purpose`; told not to spawn): salmon and steelhead (CH, CO,
      SK, ST) and trout, char and grayling (BT, GR, WCT, plus RB). Each writes `draft-<tag>-evidence.csv` and
      `-notes.md`.
- [x] Conventions the brief carries: append only. A PHABSIM optimum is `bound = optimum`. An HSI breakpoint
      that is not an edge has a blank `bound`. A regression on MAD with no tabulated value is a `qual` row
      with the equation in the note. A BC or Tennant standard is `expert`. Months a source names go in the
      note. A `none` row names what was searched. An optimum span (Tennant's 60–100 %, a WUA band) is
      `optimum`, never `range`. Hickman & Raleigh 1982 is `CT` and Raleigh 1984 is `RB` unless the text
      names WCT or steelhead (review A1).
- [x] Merge the drafts and run `0280`: 0 failing quotes, coverage, thermal and flow grids full. Commit the
      log.
- [ ] Meaning audit of **every** new row, two rounds at least, ending by enumeration (each same-source,
      same-page group with mixed kind, bound or metric is explained by its own sentences).

## Phase 5: Write-up and docs
- [ ] `research/flow_requirements.md`: what is cited by species × stage, what has no source (the `none`
      cells), and how a row joins #42's monthly flows (which metric matches which flow statistic), with the
      timing table's gaps (no rearing rows, no GR, `CT` vs `WCT`; review G6) and a cross-reference to the
      Boughton & Goslin over-summer envelope (review A4). Header per `planning.md`.
- [ ] `research/README.md` row; the `CLAUDE.md` data line and drafting conventions (stream size vs flow
      need, `percent MAD`, metric); `scripts/README.md` (0270 `--collection flow`, the store, the grid).
- [ ] `pkg/NEWS.md` and `DESCRIPTION` 0.3.1 → 0.4.0. NEWS names the new variable, units and metrics, and the
      rows that changed variable or unit: row 121 to `instream_flow`, rows 250/257/264 to `m bankfull`
      (review S3).
- [ ] Issue #44 body edited to what landed: vocabulary chosen, sources obtained and gaps.

## Validation
- [ ] Tests pass
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then `/gh-pr-push`
