# Task: Score rules on the gradient link applies: its segment gradient, not the Freshwater Atlas line's (#92)

## Problem

The tuning scores each visit on the gradient of the whole Freshwater Atlas line it snapped to (`fwa_gradient`, read in
`scripts/0230` from `fwa_stream_networks_sp`). link applies the rule on its own segments, which are those lines cut at
breakpoints, each with its gradient recomputed from the elevations of its own geometry (`fresh::frs_col_generate()`
makes `gradient` a generated column, as bcfishpass's streams table does). A visit on a 1 km line whose lower half is
3 % and upper half 12 % is scored at about 7.5 %; link judges 3 % and 12 %. So a rule is tuned on one gradient and
applied on another.

Every placed visit already carries its link segment's gradient (`segment_gradient` in `visits_link`), but the
province-wide runs (#57, #73) never scored on it. #54 tested it as a sensitivity on 16 groups of the old build: chinook's
one-SE region was 7–9 % on link's gradient against 5.49–9 % on the Atlas gradient
(`research/chinook_rearing_tuned.md`, "link's own gradient").

## Context (from the approved plan)

The tuning scores each visit on the gradient of the whole Freshwater Atlas line it snapped to (`fwa_gradient`), while
link applies a rule on its own segments, each with its gradient worked out from that segment alone. The grade already
reads link's segment `gradient`, so the curve is fitted on one gradient and graded on another
(`inst/method/settings.csv` rows `gradient_col`, `grade_grad_col`). #91 rebuilt the evidence (2026-10-27,
`fresh_default_20261017`, 45,529 visits) and stopped short of the retune. This branch switches the gradient, retunes on
#91's evidence, and clears the article and register work both issues owe.

## What exploration found (plan-mode probes on `data/fdis/derived/visits_link.csv`, 2026-10-27)

- **Issue step 1, the segment at a visit.** 22,876 of 45,529 visits sit on a segment that starts within 5 m of the
  visit, because link breaks streams at bcfishobs observations, and these visits are the observations. **Which visits get
  such a segment depends on the outcome**: 85 % of visits that caught fish, against 11 % of empty ones (stream branch),
  and their median segment length is 110 m, against 298 m. Short segments read noisy gradients: of segments 10 m or
  shorter, 14 % read 0 and 3 % read over 30 %, and the median gap from the Atlas line's gradient falls from 0.015–0.023
  under 100 m to 0.0016 over 500 m. The gradient class at a cut-off flips on 7–9 % of visits.
- **Issue step 3, link's breaks.** `default` breaks at observations, gradient barriers, falls, definite barriers,
  habitat endpoints and crossings. Its gradient breaks come only from the access classes (15, 20, 25 and 30 %,
  `link/R/lnk_pipeline_prepare.R` `.lnk_classes_bcfp`), never from the rearing or spawning cut-offs. At the visits, segment
  gradients do not bunch at `default`'s cut-offs (0.0449: 1,255 visits in the 0.5-point band below, 1,152 above; 0.0549:
  1,087 against 1,018; 0.1049: 553 against 524).
- Every tune function reads the gradient through `cols[["grad"]]`, which defaults to `fwa_gradient` in `knw_rule_in()`
  (`R/rule_in.R:61`) and `knw_tune_curve()` (`R/tune_curve.R:58`). `knw_tune_run()` (`R/tune_run.R:128`, `:247`) passes
  neither, and `check_names()` requires `fwa_gradient`. No frozen script calls these functions. `0322` and
  `data-raw/snap_limit_sensitivity.R` call `knw_tune_run()` with the default.
- **Trap.** Neither the score cache's `spec` nor the grade table's record names the gradient. Under the same evidence,
  run and rule, a table scored or graded on the Atlas gradient would be read back as a segment-gradient one
  (`0320`'s keep-check, `0325`, `0330`, `data-raw/vignette_chinook.R`).
- Fixed-window gradients, which would remove the outcome-linked segment length, are #70's step 2 and wait on fresh#257.

## Decided at the gate

- **The main reading is link's segment gradient** (`segment_gradient`). The Atlas line's gradient is scored as a
  sensitivity on every key, and both regions are reported. The method says that link cuts a segment at a catch, so the
  segment's length and noise depend on the outcome. That goes into #70, where fixed windows can test whether it moves a
  threshold. (Al, 2026-10-27, after the step 1 measurement above.)
- Mechanism (mine): the sensitivity scores on the main fold seed only (`extra = FALSE`) and writes no grades. The
  one-SE region and the pick come from the main seed, so the regions compare like for like. It goes to
  `data/tune/grad_fwa/`, which `0325`, `0330` and `knw_thresholds_table()` never read (they list `data/tune/` without
  recursing, as with `grad_ext/`). `0310` does not rerun: #91's build already carries `segment_gradient`.

## Phase 1: Measure the segment at a visit and link's breaks (issue steps 1 and 3)
- [x] `data-raw/segment_gradient_check.R`. From the derived tables: segment lengths, start offsets, the share starting at
      the visit by outcome (catch status and per species), and the Atlas-to-segment gap by length band. Class flips at
      each `default` cut-off. From `SCHEMA`'s `streams`, one aggregate query: whether segment gradients bunch at
      `default`'s cut-offs and the 15–30 % access classes. Log to `scripts/logs/habitat/<date>_segment_gradient_check.txt`.
- [x] `research/habitat_thresholds_tuned.md`: a short "Which gradient is scored" section giving the verdict, the
      producing script, and the log.
- [x] Issue bodies: #92 records the step 1 finding and the decision; #70 gets a task line saying fixed windows test the
      outcome-linked segment length.

## Phase 2: Name the gradient in the tune functions and in every record (tests first)
- [ ] Tests (fail first). `knw_tune_run(cols = )` reaches the rule and the curve. The default reads `segment_gradient`.
      A score cache made on another gradient column is rescored, not read back (restore the old spec and watch the test
      go red). The curve records its `cols`.
- [ ] `knw_tune_run()` takes
      `cols = c(grad = "segment_gradient", width = "cw_deploy", mad = "mad_pick")`. It passes them to its `rule_in`
      closure and to `knw_tune_curve()`, checks the named columns instead of `fwa_gradient`, and adds the gradient
      column to the cache `spec`. The defaults of `knw_rule_in()` and `knw_tune_curve()` move to `segment_gradient`,
      and the curve object keeps `cols`.
- [ ] Update `tests/testthat/helper-tune_sim.R` and the fixtures in `test-rule_in.R`, `test-tune_curve.R` and
      `test-grade_species.R` that build `fwa_gradient`.
- [ ] `0322` and `data-raw/snap_limit_sensitivity.R` pass `cols` with `fwa_gradient`, so they keep reproducing their
      records.
- [ ] The record. `0320` writes `curve_grad` (the curve's `cols[["grad"]]`) to `<key>_summary.csv` and to
      `<key>_grades.csv`. `0320`'s keep-check, `0325`, `0330` and `data-raw/vignette_chinook.R` compare it with the
      run's value and refuse a table without it.
- [ ] `0320` reads `GRADIENT` (default `segment_gradient`). Any other value scores on the main seed, writes no grades,
      writes to `data/tune/grad_<name>/`, and its log names it. Update the header's ANALYSIS SPEC and RUN lines.
- [ ] Register: `gradient_col` becomes `segment_gradient`, its `fn:` pointers move to `knw_tune_run:cols[grad]` (and
      to the two functions' defaults), and its note says why. Close the gap the `grade_grad_col` note names. Run
      `devtools::document()`, `lintr`, `devtools::test()`.

## Phase 3: Retune on #91's evidence (`SCHEMA=fresh_default_20261017`)
- [ ] `0320` full run: smoke gates for every key first. The chain stops on any failure, and nothing downstream runs
      until every key passes (#84).
- [ ] `GRADIENT=fwa_gradient 0320`: the Atlas sensitivity on every key.
- [ ] `0325` publish, then `0330` compare. `0330` is database-bound: run it here if the timing allows, otherwise hand
      over the command for the database's host.
- [ ] Record the regions under both gradients, per key, in `research/habitat_thresholds_tuned.md` from the tables. Drop
      #91's note above its Evidence paragraph.

## Phase 4: Articles and bundles (owed by #91 and #93)
- [ ] `data-raw/vignette_method.R` bundles the two gradients' regions per key from `data/tune/grad_fwa/`; rerun it,
      `data-raw/vignette_chinook.R`, and `data-raw/vignette_bib.R` (Zotero running).
- [ ] `vignettes/habitat_thresholds.Rmd`: step 2 (each site takes its segment's gradient, and why), the `#snap` section
      (other streams in reach are now weighed; show `examples$moved`), and the limits' prose (`snap_limit` 200 m
      unconfirmed, `snap_limit_code` 500 m confirmed, `snap_edges_excluded`). Line 336's limit becomes the
      outcome-linked segment length, and the Atlas sensitivity's result goes in a sentence or a small table.
- [ ] `vignettes/chinook_rearing.Rmd`: the placement sentence ("stream lay within 100 m") and the gradient sentence
      (line 135). Restore `snap_limit`'s `code:` pointer in `inst/method/settings.csv`.
- [ ] `research/habitat_thresholds_tuned.md`: replace its long Method section with a link to the methodology article.
- [ ] `test-vignette-data.R`'s "every tracked source" and "every ignored source" tests pass. Build both articles with
      the branch installed and check every inline number renders.
- [ ] `CLAUDE.md`: drop the "Until #92's retune…" sentence and say the scoring reads link's segment gradient.

## Owed at the end (reported, done after merge)

- [ ] Publish the evidence as `knowledge/fdis/v3` (`0299`) if the merge does not already cover it; check what #91 left.

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch, `/code-check branch`, three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- Gradient switch: the new tests, each shown red against the old default or spec, then green. A DEV=1 `0320` on CH
  before the full run shows the population is unchanged and the pick read on `segment_gradient`.
- Record: each reader refuses a grade table with `curve_grad` removed or changed (a mutation check on a copy).
- Retune: every key's smoke gates pass. The `0325` and `0330` logs name `fresh_default_20261017`, #91's evidence md5s
  and `curve_grad = segment_gradient`.
- Articles: `devtools::test()` is green including `test-vignette-data.R` and `test-settings-register.R`. Both articles
  build under pkgdown with the branch installed, and their quoted numbers come from the new bundle.

