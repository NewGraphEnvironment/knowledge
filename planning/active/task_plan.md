# Task: Growing-season degree-day thresholds for BC salmonids: search beyond the temperature collection (#47)

## Problem

#38 and #40 searched only `Fisheries/temperature`. The growing-season cells (`degree_days` × `rearing`/`overwintering`, metric `growing_season`) are `none` for WCT, BT, CH, CO and ST. The only values in the table are CRCT (Coleman & Fausch 2007a p. 1231; Coleman & Fausch 2007 p. 652; `research/thermal_requirements.md`).

## Context

#38 and #40 searched only `Fisheries/temperature`. Ten growing-season cells (`degree_days` ×
`rearing`/`overwintering`, metric `growing_season`, for WCT, BT, CH, CO and ST) are `none`. They are data rows
532–533, 554–555, 662–663, 666–667 and 670–671 (file lines one higher). The only values are CRCT, Coleman & Fausch
2007a/b (data rows 557–559). Consumers are wet#40, link#21 and template#214. They currently either borrow
800/900/900–1,200 or have no threshold.

**Plan-gate decision (answered): size thresholds get rows.** Add a new variable, `fish_length`, in `mm`, with a
`metric` of `fork_length`, `total_length` or `unstated`. Its rows file under `overwintering` (size at winter
onset) or `rearing` (end-of-summer size). It fills no degree-day grid cell. One in-collection source already
qualifies: Thorley et al. 2022 says age-0 WCT under 30 mm survive the winter poorly (citing Coleman & Fausch).

A first web scan found these leads:
- Coleman's CSU dissertation: ≥800–900 GSDD gives fry ≥30–35 mm at season end.
- Teck's Harmer Creek "Evaluation of Cause" SME reports (Energetic Status; Water, Air Temp and Ice). These are BC
  WCT recruitment failure work.
- Isaak's USFS stream-temp blog, which is secondary and only a pointer for chasing citations.
- Beamish & Mahnken 2001, the marine critical-size hypothesis (out of scope: marine).
- Hartman et al. 1998, the coastal BC overwintering handbook.

From the literature as I know it, these are worth checking: Holtby 1988 (Carnation Creek coho), Quinn & Peterson
1996 (coho fall size and overwinter survival), Smith & Griffith 1994 (age-0 rainbow size and winter survival),
Harig & Fausch 2002 and Roberts et al. 2013 (cutthroat translocation thermal criteria), and northern bull trout
work (Mochnacz).

## Phase 1: `fish_length` variable
- [x] `pkg/R/literature.R`:
  - add `fish_length` to `variable`;
  - add `fish_length = "mm"` to the unit fits;
  - add `fish_length = c("fork_length", "total_length", "unstated")` to `.knw_metric_fits()`, so a valued row
    must name its length type;
  - write a roxygen paragraph saying what it is: a body length a source ties to survival or recruitment, not a
    habitat dimension.
- [x] `pkg/tests/testthat/test-literature.R`:
  - a valued `fish_length` row needs a metric;
  - `degC` does not fit it;
  - `fork_length` does not fit `temperature`;
  - the metric vocabulary includes the length types.
  Restore-the-bug check on each new guard.
- [x] `devtools::document()`, then tests pass. Run `0280` against the unchanged table: still passes, 50/50.

## Phase 2: Search outside the collection
- [x] Two background `general-purpose` searchers, unnamed, told to spawn no subagents and write nothing but their
  file. One takes trout and char (WCT, BT, RB, other cutthroat); the other takes Pacific salmon and steelhead (CO,
  CH, ST). Each writes `planning/active/search-<tag>.md` listing per candidate:
  - citation and DOI;
  - what the threshold claim is, from the abstract or text, with the page if read;
  - species and region;
  - how to get the PDF (`direct URL` / `browser` / `paywalled`).

  Methods: web search, forward citations of Coleman & Fausch 2007a/b (Semantic Scholar API, Scholar "cited by"),
  and back-chasing from the reference lists of Hill et al. 2024/2025, Thorley et al. 2021/2022 and the Teck SME
  reports. Run BC, AB, MT and PNW sources first. No Zotero writes.
- [x] While they run: back-chase Thorley 2021/2022 and Hill 2024/2025 references myself from the extracted text
  (`#38 archive scratch_keytext.py`).
- [x] Merge into one candidate list in `findings.md` with a search log of queries, sources and date. The `none`
  notes will cite that log.
  - **Keep** a candidate that states a degree-day or fish-size threshold, or a quantitative size–survival or
    GSDD–recruitment relation, for age-0 or first-winter freshwater salmonids.
  - **Drop** marine-phase and non-salmonid work.
  - Aim for about 15 items or fewer, and record why each dropped one was dropped.

## Phase 3: PDFs into Zotero and the store
- [x] Rows in `data/temperature_members.csv`: `pdf` is the direct URL where one exists.
- [ ] Browser-only hits: open them all in Chrome tabs in one handoff. Al saves each into `data/rag/pdf/`
  (`~/Downloads` is unreadable to the agent), and its row's `pdf` is set to that path. Paywalled with no copy is
  recorded in `findings.md` and not added.
- [ ] `0270 --collection temperature --dry-run`, then live. Log to `scripts/logs/habitat/20261013_temperature_*`.
  Confirm `has_pdf` through the Web API, then in a guarded `zotero.sqlite` copy after sync.
- [ ] Rebuild the `temperature` store (`OVERWRITE=TRUE`), push it (`CONFIRM=TRUE`), and verify on a fresh
  connect. Rebuild `habitat_modelling` only if new items land in its input collections.

## Phase 4: Draft rows
- [ ] Re-read the #38 drafter brief and the CLAUDE.md drafting conventions. Check each convention against the
  sources (#44's lesson).
  - Species is what was measured: RB rows for rainbow; ST only where the source says steelhead or anadromous; a
    new cutthroat subspecies gets its own code, never WCT.
  - Degree-day notes give the base temperature and the window. A GSDD computed on another window is `annual` or
    `unstated`, not `growing_season`.
- [ ] Draft rows from each new PDF, plus Thorley 2022's 30 mm statement as `fish_length`. Draft myself if there
  are 20 rows or fewer; otherwise use the #38 two-family drafter split.
- [ ] Append, never insert. A value that fills a growing-season cell replaces that cell's `none` row. Every
  remaining `none` row's note is revised to name the wider search (the `findings.md` log) and never to claim the
  literature has none.

## Phase 5: Meaning audit and gate
- [ ] Audit every new or changed row against its PDF with a blind `Plan`/`Explore` reader (canary first). Findings
  go to `planning/active/audit-*.md`.
- [ ] Fix, then audit the fixes. End by enumeration: every note sentence checked against its page.
- [ ] `0280`: 0 failing quotes, thermal 50/50. Log `scripts/logs/habitat/20261013_literature_verify*`.

## Phase 6: Write-up
- [ ] `research/thermal_requirements.md`: add the new rows to the degree-day table and a size table. Revise the
  "no BC species" paragraph and the consumer guidance for wet#40, link#21 and template#214 to say what threshold
  each can now apply, and with what transfer caveat. Update the provenance line.
- [ ] `CLAUDE.md` above the marker: name `fish_length` in the `literature_evidence.csv` description, and add a
  drafting-convention line on length type and stage.

## Validation

- [ ] pkg tests pass; `0280` passes
- [ ] `/code-check branch` clean (pkg code, tests, members csv)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then `/gh-pr-push`
