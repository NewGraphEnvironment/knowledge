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
- [ ] Tests in `pkg/tests/testthat/test-literature.R`: `instream_flow` accepted with `m3/s`, `cfs` or
      `percent MAD`; `percent MAD` refused on any other variable (`discharge` included); an `instream_flow`
      value with no `metric` refused; a `discharge` row with a metric still refused.
- [ ] `knw_literature_vocab()`: variable `instream_flow`; unit `percent MAD`; `.knw_metric_fits()` gains
      `instream_flow = c("instantaneous", "daily_mean", "7day_low", "monthly_mean", "monthly_median",
      "seasonal_mean", "annual_mean", "unstated")`. Roxygen explains stream size vs flow need. A fraction
      of MAD is `percent MAD`, and its metric is the statistic the flow is held to.
- [ ] `fits` in `.literature_check()` updated; `devtools::document()`; `devtools::test()` green.
- [ ] Audit all 45 `discharge` rows. Move the flow needs (Gottesfeld CH migration; any other one found) to
      `instream_flow` with a metric (`unstated` if the source does not say). The stream-size rows stay.
- [ ] `0280` passes on the migrated table; commit its log.

## Phase 2: Sources, the `flow` collection and store
- [ ] `data/flow_members.csv`: the eight keys from the issue, plus the grayling, flow and HSI items in the
      group (raleigh 1984, stewart 2007, cutting 2018, hagen 2015 and others found by the search).
- [ ] `data/flow_additions.csv`: Hatfield et al. 2003, Ptolemy & Lewis 2002, DFO 2013 flow framework
      (CSAS SAR 2013/017), Hubert et al. 1985, McMahon 1983, Hickman & Raleigh 1982, Hatfield & Bruce 2000,
      Bradford & Heinonen 2008, Tennant 1976, and one Washington Ecology and one Central Valley WUA report.
      Government and open-access items get a PDF URL; each URL is checked for a `%PDF` body before it goes in.
- [ ] Paywalled or ResearchGate-only items, plus the amec 2015 and raleigh 1984 PDFs: open them in Chrome,
      then send Al one phone-answerable checkpoint: a list, and a single `cp` command from `~/Downloads`
      into `data/<repo path>`. Work continues on everything else while that is outstanding. An item never
      obtained is recorded as a gap, as Bear 2005/2007 was in #38.
- [ ] `0270 --collection flow --dry-run`, then a live run; wait for Zotero sync and BBT keys.
- [ ] `0150 ACTION=build STORE=flow COLLECTIONS=<key>`, then `ACTION=push`. Log both under
      `scripts/logs/habitat/`.

## Phase 3: The FLOW grid in `0280`
- [ ] `FLOW` list next to `THERMAL`, with species CH, CO, SK, BT, GR, WCT, ST. Cells:
      `instream_flow` minimum for spawning, incubation, rearing, overwintering and migration (`min` or
      `range`); `depth` lower for spawning; `velocity` upper for spawning and rearing (`max` or `range`).
      That is 8 cells × 7 species = 56. `meets()` is reused, and a `none` row meets a cell by its bound. The
      grid is printed and joins the exit condition.
- [ ] Header comment and the `scripts/README.md` gate description updated.

## Phase 4: Draft rows, then the gate and the meaning audit
- [ ] Drafter brief in `planning/active/` (adapted from the #38 brief) and text extraction of every
      collection PDF. Two drafters (unnamed; `general-purpose`; told not to spawn): salmon and steelhead (CH, CO,
      SK, ST) and trout, char and grayling (BT, GR, WCT, plus RB). Each writes `draft-<tag>-evidence.csv` and
      `-notes.md`.
- [ ] Conventions the brief carries: append only. A PHABSIM optimum is `bound = optimum`. An HSI breakpoint
      that is not an edge has a blank `bound`. A regression on MAD with no tabulated value is a `qual` row
      with the equation in the note. A BC or Tennant standard is `expert`. Months a source names go in the
      note. A `none` row names what was searched.
- [ ] Merge the drafts and run `0280`: 0 failing quotes, coverage, thermal and flow grids full. Commit the
      log.
- [ ] Meaning audit of **every** new row, two rounds at least, ending by enumeration (each same-source,
      same-page group with mixed kind, bound or metric is explained by its own sentences).

## Phase 5: Write-up and docs
- [ ] `research/flow_requirements.md`: what is cited by species × stage, what has no source (the `none`
      cells), and how a row joins #42's monthly flows (which metric matches which flow statistic). Header per
      `planning.md`.
- [ ] `research/README.md` row; the `CLAUDE.md` data line and drafting conventions (stream size vs flow
      need, `percent MAD`, metric); `scripts/README.md` (0270 `--collection flow`, the store, the grid).
- [ ] `pkg/NEWS.md` and `DESCRIPTION` 0.3.1 → 0.4.0 (new variable, unit and metrics).
- [ ] Issue #44 body edited to what landed: vocabulary chosen, sources obtained and gaps.

## Validation
- [ ] Tests pass
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then `/gh-pr-push`
