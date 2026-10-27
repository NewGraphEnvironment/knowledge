# Findings — A stepwise methodology article (#93)

## Issue context

## Problem

The method is spread over scripts, package functions in four repos and long research files, and it is hard to follow
end to end. Asking one step at a time "which function, which setting, why that value?" has already found three
problems: the article misdescribes how FDIS sites reach the network and where the flows come from (#89), sites are
placed nearest-then-reject when candidate snapping would keep good placements (#91), and the rules are tuned on the
Freshwater Atlas line's gradient while link applies its own segment gradient (#92). A stepwise account written to
answer those questions at every step is an audit as much as documentation, and there are likely more to find.

## Proposed

A pkgdown article, "How the thresholds are tuned", that walks the pipeline in order, as plainly as possible.

**Each step, the same block:** what it does, in one or two plain sentences; the script and the functions, linked to
their reference pages (knowledge's, fresh's, link's, fwapg's); what goes in and what comes out, with the run's own
counts (in, kept, dropped and why), read from the evidence ledger and the run logs so they stay current; and the
settings it depends on, with the open issue where one exists.

**The steps:**

| # | step | where |
|---|---|---|
| 1 | the FDIS electrofishing export | `scripts/0230` |
| 2 | site placement on the Freshwater Atlas | `scripts/0230`, `fwa_indexpoint()` (#91) |
| 3 | link's segments, access and `default` flags | link's province-wide run |
| 4 | flows on segments: PCIC routed through the fwapg fork's crosswalk, wet's balance elsewhere | wet, NewGraphEnvironment/fwapg (#89) |
| 5 | the evidence build: species range, walks to rivers | `scripts/0310` |
| 6 | the candidate rules | the grid, `scripts/0320` |
| 7 | held-out scoring, the region and the pick | `knw_tune_score()` (#92 for the gradient) |
| 8 | the stability checks | seeds, nested selection, bootstrap |
| 9 | the curve, its prior and the grade gate | `knw_tune_curve()`, `knw_grade_species()` |
| 10 | the comparison on link's segments: predicate, user-habitat overlay, connectivity | `scripts/0330`, fresh |
| 11 | publishing | `scripts/0325` |

**Visuals:**
- A flow chart of the whole pipeline, one box per step, coloured by the package doing the work (Mermaid on the site,
  a static SVG for the markdown copy).
- A record funnel: 51,587 FDIS visits narrowing to placed, kept, in range and modelled per species, each drop labelled
  with its reason, so where the evidence is lost shows at a glance.
- A data-lineage diagram: which source feeds which table (FDIS, the Freshwater Atlas through fwapg, PCIC, wet, link,
  bcfishobs), from which the citations follow.
- Small worked examples at the hard steps: one site snapped (its point, the candidate streams, the one chosen and
  why), and one rule taken through predicate, overlay and connectivity on a few segments.

**A settings register.** One table of every number that shapes a result: the snap search (500 m) and limit (100 m),
the 1:50k check, wet's `pick` ratio (0.2), the prior SD (2.5), the one-SE rule and the 1.96 reading, five folds and
four extra seeds, the connectivity bridge (10 km, 5 %), the walk's river sizes, the grade's 95th-percentile reference.
Each row says where the value came from (a source, a convention, inherited, or measured) and whether it has been
tested. The untested and inherited rows are the to-do list; today it starts with the snap limit and the gradient
source.

The funnel and the register are generated from the ledger and the run's settings, as #90 generates the species
pages, so they cannot go stale.

## How it fits

- #89's corrections are its first content; #89 itself stays small and fixes the chinook article now.
- It replaces the long Method section of `research/habitat_thresholds_tuned.md`; #90's `research/tuning/README.md`
  links to it rather than restating it.
- Drafted after #89 and before #91 and #92, so the fixes it surfaces join the same retune.

## Depends on

#89.


## Plan (parked 2026-10-27, from a discussion with Al; verify each phase against the code at `/planning-init`)

**Concept: two CSVs are the controller and the documentation.**
- `pipeline.csv`: one row per step (step, label, package, scripts, functions, inputs, outputs, issue). It describes
  the pipeline; it does not run it.
- `settings.csv`: one row per number that shapes a result (key, step, value, unit, where, source, tested, issue). It
  documents; the code keeps its values, and a test holds the two together (below). `source` and `tested` make the
  register the audit: the inherited, untested rows are the to-do list. Where a run record already holds the value the
  run used (the score cache's `spec`: prior, seeds, folds, distance floor; the flow build in the table comment), the
  article prints it from the record, which says what ran rather than what is configured.
- A `data-raw/` render script builds, from the two CSVs and the evidence ledger: the flow chart (DiagrammeR /
  Graphviz, one box per step, coloured by package with its hex sticker, saved as a static SVG); the record funnel
  (51,587 FDIS visits narrowing to modelled per species, each drop labelled with its reason); the data-lineage
  diagram; and each step's block (what it does, linked functions, counts in and out, settings).
- A later change (#91, #92, a retune) updates the article by rerunning the render script and knitting: no prose holds
  a count.
- #89's corrections are the first content, and fix the chinook article in the same PR.

**Phases (draft):**
1. #89: the chinook article's evidence paragraph and `research/habitat_thresholds_tuned.md`'s Evidence and Method;
   `research/modelled_discharge.md` refreshed to the loaded build (`94deeb5`); `0310`'s ledger records the loaded flow
   build from the table comment.
2. `pipeline.csv` and `settings.csv` under `inst/` (installed, so the article reads them), and the register test.
   A script literal the register names (the 500 m search, the 100 m limit) is lifted to a named constant at the top of
   its script, value unchanged, so the test can find it.
3. The render script and diagrams; prototype stickers inside Graphviz boxes first.
4. The article, "How the thresholds are tuned": step blocks, funnel, lineage and register.
5. `research/habitat_thresholds_tuned.md`'s long Method section replaced by a link to the article.

**The register test** (`tests/testthat/test-settings-register.R`). Each `settings.csv` row names where its value lives,
in `where`:
- `fn:knw_tune_curve:prior_sd`, an exported function's default, read with `formals()`;
- `script:scripts/0230-....R:SNAP_LIMIT`, a top-level assignment in a script, found by parsing the file (no run);
- `record:spec$prior_sd`, a value a run records, checked by the render script against the run, not by the test.

The test fails when a `fn` or `script` value differs from the CSV, or when a `where` names nothing. So changing a
setting in code without the register, or the register without the code, breaks the build. It cannot see a new number
added to code with no row; that is what the article's step-by-step review finds. `scripts/` is not in the built
package, so `script` rows are checked by `devtools::test()` locally (skipped under `R CMD check`); `fn` rows are
checked everywhere, CI included once #98 lands.

## Decisions

- Scope is #89 and this issue. #91, #92, the retune and #90 are separate and follow #87; they appear in the register
  as pointers (the snap limit: inherited, untested, #91; the gradient source: #92), and each changes its rows when it
  lands (Al, 2026-10-27).
- The CSVs document; the scripts keep their values, and the register test holds the two together. Scripts reading
  `settings.csv` was weighed and dropped: it rewires five scripts and the exported defaults, touches the run records'
  keep-checks that #87 is also changing, and any slip forces a full regrade, for a benefit the test gives at a tenth of
  the cost. `targets` (link's `data-raw/_targets.R` is the precedent) is a separate question after #87 (Al, 2026-10-27).
- **Counts wait for the retune.** The methodology article publishes with the counts of the #91 / #92 retune, not
  #73's: it is built and reviewed on today's run, and goes on the site once the retune has run and the render script
  has redrawn it. #89's corrections to the chinook article do not wait; they ship in the first PR (Al, 2026-10-27).
- **Clarity first, branding second.** The purpose is a methodology a reader can follow step by step; every design
  choice is judged on that. The hex stickers (all black and white) sit inside the flow chart's boxes only if they do
  not crowd the step labels; package is shown by box colour either way, and the stickers are dropped if they get in
  the way of reading the chart (Al, 2026-10-27).
- The article documents the pipeline as it runs today (`fwa_indexpoint()` placement, the Atlas line's gradient), not
  as #91 and #92 will change it (Al, 2026-10-27).

## Plan-mode exploration (2026-10-27)

- `scripts/0230-fdis-load.R:54-55` already names `snap_tol_m <- 500` and `snap_flag_m <- 100`; the comment on 55 says far snaps are "flagged, not dropped", but `knw_fdis_quality()` (`R/fdis_quality.R:42`) drops them: 5,242 in `scripts/logs/habitat/20261022_evidence_build_ledger.csv`.
- The connectivity bridge (10 km, 0.05) is per species in link's `inst/extdata/configs/default/parameters_fresh.csv`; fresh's `frs_cluster()` defaults match. wet's `far_low` has no default (`wet_source_pick()`); wet's `scripts/pcic_routed_lib.R` sets `routed_far_low`.
- pkgdown 2.2.0 skips vignettes whose names start with `_` (`pkgdown:::package_vignettes`).
- DiagrammeR, DiagrammeRsvg, rsvg not installed; no `dot` on PATH. magick is installed.
- The 2026-10-22 evidence ledger (tracked) holds the funnel: 51,587 in; drops not_placed 1,563, far_snap 5,242, ws50_mismatch 1,088, junk_date 23, effort 1,353, catch_unknown 275, no_link_segment 1,491; per-species presence and in-range counts.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `op read` → "1Password CLI couldn't connect to the 1Password desktop app" (2026-10-27 05:07 UTC) | Zotero write deferred; asked Al to open/unlock 1Password |

## Phase 1 measurements (2026-10-27)

- Flow source of the 40,552 placed visits (`data/fdis/derived/visits_link.csv`, `pick_source`): pcic_routed 86.3 %,
  wet_balance 13.7 %.
- Loaded flow build: table comment `wet_db_load(): … (built 2026-10-19T06:08:31Z, wet 94deeb5)`; picked routed 3,154,131,
  balance 1,378,712 (222,906 under the cut); period 1981-2010 both sources. Live manifest now built 2026-10-24T12:23:01Z.
- At 94deeb5 (`data/checks/pcic_routed_compare_20260717.txt`): annual MAE routed 24.2 %, balance 27.6 % (medians 13.1,
  18.0), pick 23.0 % at the 290 gauges.
- `fwa_gradient` is `fwa_stream_networks_sp.gradient` (`R/link_flow.R:36`); link's segment gradient is fresh's
  generated column, `(Z(end) - Z(start)) / length` (`fresh/R/frs_col_generate.R:27`).
- The chinook article's check uses FDIS visits (`fdis_visits`), not `bcfishobs_outside`, so the article does not report
  the bcfishobs check; the rewritten sentence says bcfishobs scores no rule rather than pointing at a section.
- The group library holds no PCIC, VIC-GL or Raven item; the fork has none either.

## Phase 3 (2026-10-27)

- Hex stickers: tried inside Graphviz (viz.js) via post-processed SVG `<image>` beside the legend entries; at ~700 px
  the four stickers are identical black hexes with unreadable names, and fwapg has none. Dropped per the gate's
  "clarity first"; package is box colour (Okabe-Ito hexes).
- The lineage chart read worse left to right (long edges across the page); top to bottom with 1.5 in boxes is 904 pt
  wide, about 0.78 scale in an article column.
- `summarise()` trap met: drops computed after `across()` summed the flags read 0; reordered and the stage counts are
  now checked to add up.

## Enumeration of the `code:` rows (2026-10-27, after round 2)

Every occurrence, outside a comment, of each `code:` row's value as a token in the files its wheres name: 42, of
which 31 a where covers. The 11 others: `0230:213` 2022 in a file path; `ch_dist_profile.sql:98` 1400, 1450 in the
bank rule's connector test (a different rule); `thresholds_table.R` 113, 120 the `1` inside `1.96`, 159-160 `[1]`
indexing; `tune_run.R:124` 2004 inside the era labels; `grade.R:43` 0.2 a grade class break (its own row);
`tune_curve.R:59` `q_default = 10` (its own row); `grade_species.R:86` `seg$gradient` choosing segments to walk.
None is a second copy of a row's setting.
