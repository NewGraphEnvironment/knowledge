# Task: Measured site gradient against link's segment and Atlas-line gradients at FDIS visits (#121)

## Problem

From #92 the tuning reads `segment_gradient`, with `fwa_gradient` as its sensitivity. Both come from the Freshwater Atlas, averaged over a segment or a whole line. FDIS surveyors measured gradient at many of the same visits, and `research/fdis_export.md` compares measured with modelled **width** (log correlation 0.54 over 3,637 sites), but not gradient: it says only that the comparison against the segment gradient the model uses has to come first. The link research that was to make it closed without doing so.

The data is already built. In the evidence build the published grades name (`data/fdis/derived/visits_link.csv`, md5 `1bd35829`), 18,759 of 45,529 visits carry a measured `gradient_pct` (from the form's `GRADIENT11`/`GRADIENT12`, sentinels over 100 % dropped by `0230`) beside `segment_gradient` and `fwa_gradient`; 9,397 also carry `gradient2_pct` (`GRADIENT21`/`GRADIENT22`). 55 visits have a negative `segment_gradient` (counted 2026-10-30). The 2026-10-25 build (md5 `d3a434e2`), which a checkout may still hold in its ignored `data/`, has 17,705 of 40,552 and 32 negative, so check the md5 before reading any count.

## Plan context (from the gate, 2026-10-30)


Every gradient limit the tuning publishes (CH rearing 0.11, BT rearing 0.30, BT spawning 0.13, …) is a limit on
`segment_gradient`, a Freshwater Atlas average over link's segment; `fwa_gradient` (the whole line) is the
sensitivity. FDIS crews measured gradient at 18,759 of the 45,529 visits in the published evidence build, and nobody
has compared the two. `research/fdis_export.md` has the width comparison (log r 0.54, ratio p10–p90 0.44–2.58) and a
line saying the gradient one is owed (this issue). The outcome is a measured statement of how far a tuned gradient limit
can be read as a limit on the ground, and a check that reruns unchanged on #120's minimal network.

What exploration found:
- `visits_link.csv` already carries `gradient_pct`, `gradient2_pct`, `grad_sentinel`, `segment_gradient`,
  `fwa_gradient`, `segment_length_m`, `segment_stream_order`, `stream_order`, `catch_status`, `species_caught`, and
  `segment_start_offset_m`; `visits_species.csv` the per-species outcome. No database is needed.
- This checkout's `data/fdis/derived` is the 2026-10-25 build (md5 `d3a434e2`). The published build (`1bd35829`,
  `009698d7`) is in a copy of the published inputs outside the repo on this machine
  (md5s checked 2026-10-30). `data/thresholds.csv`'s `evidence_md5` names it.
- `scripts/0230-fdis-load.R:20-23`: `GRADIENT11/12` are the primary measurement, `21/22` "a second one (a separate
  method code not exported, and it runs higher)". The FDIS dictionary (`data/fdis/fiss-database-structure/`) has only
  `GRADNT1_MTH_CODE`/`GRADNT2_MTH_CODE` ("the method used to determine gradient") and the code table, no values; the
  export's `GRADIENT11..22` names are not in it. The site card field guide (RISC) is where the two slots are defined.
- Model to follow: `data-raw/segment_gradient_check.R` (#92: stream-branch population from `knw_tune_run()`'s
  formals, `say()`/`block()` log, `len_breaks`, flips at cut-offs) and `data-raw/compare_structures_check.R`
  (`EVIDENCE_DIR`, md5s logged, `home_rel()`, `.knw_free_path()`).
- The tuning ladder (`R/tune_grid.R:52`): 0.03, 0.04, 0.0549, 0.07, 0.09, 0.11, 0.13, 0.15, 0.20, 0.25, 0.30.
- The methodology article's limits (`vignettes/habitat_thresholds.Rmd:353`) take every number from `method.rds`, which
  `data-raw/vignette_method.R` builds, and that build needs the full grade tables, which are on m4 only (#119).

## Decided at the gate

Approved by Al at plan approval, 2026-10-30, as recommended:

1. **The article sentence is owed, not in this PR.** The research file gets the result now; the sentence in the
   methodology article's limits lands with the next rebuild of `method.rds` (#119 or the next promotion), carried
   through `vignette_method.R` like every other number there. Putting it in now means a bundle rebuild on m4 for one
   sentence.
2. **The check holds itself to the published build by default**: it compares the visit tables' md5s with
   `data/thresholds.csv`'s `evidence_md5` and stops on a mismatch; `EVIDENCE_CHECK=FALSE` lets #120 run it on
   another build, and the log says which it was.
3. **Measured gradient is converted to a fraction** (÷ 100) and compared on the scale the rules read. Agreement is
   reported as Spearman rank correlation over every pair, and as log correlation and the measured/modelled ratio's
   p10–p90 over pairs where both are above 0 (the width comparison's measures), with the count of zero pairs beside.

## Phase 1: What the two gradient fields measure
- [x] Find the RISC site card field guide (Zotero group library first, then the BC government's RISC pages) and read
      its definition of the two gradient slots and their method codes; record source and page in `findings.md`.
- [x] Measure how `gradient2_pct` stands against `gradient_pct` where both exist (count, median difference, share
      higher), to test 0230's "runs higher".
- [x] Decide from the two whether `gradient2_pct` is reported as a second comparison or left out, and write why.

## Phase 2: The check script, `data-raw/site_gradient_check.R`
- [x] Header in the house form (question, METHOD, INPUT, OUTPUT, RUN); reads `EVIDENCE_DIR` (default
      `data/fdis/derived`), logs the md5s and whether they are the published build's, refuses a mismatch unless
      `EVIDENCE_CHECK=FALSE`; writes `scripts/logs/habitat/<yyyymmdd>_site_gradient_check.txt` via
      `.knw_free_path()`, refused runs as `_refused`.
- [x] Populations: every placed visit with a measured gradient, and the tuning's stream branch (edge types and fished
      area from `knw_tune_run()`'s formals, as `segment_gradient_check.R` does). Counts at each filter.
- [x] Agreement against `segment_gradient` and `fwa_gradient` (Decision 3), overall and by segment length
      (`len_breaks`), stream order, and the measured value's class on the tuning ladder.
- [x] The band: for each published gradient limit in `data/thresholds.csv` (CH rearing, BT rearing, BT spawning,
      and the rest for completeness), the share of visits whose measured and modelled gradients fall on opposite
      sides of it, over all visits and within the ladder steps either side of the limit (CH 0.09–0.13, BT rearing
      0.25–0.30, BT spawning 0.11–0.15).
- [x] By catch: the error and the flip shares by `catch_status`, and by species outcome (in range, present or
      absent) for the tuned keys, and by whether the segment starts at the visit (`segment_start_offset_m` −1 to 5 m).
- [x] Negative `segment_gradient`: count, values, segment lengths and Atlas lines; which tuned keys' populations hold
      them; whether any rule's in/out at those visits changes if they were 0 (every ladder value is ≥ 0.03, so this
      is expected to be none, and the script states it from the data, not by assertion).
      Corrected by the plan review: a negative gradient fails every rule (`R/rule_in.R:71`), so at 0 a visit can
      move in; on the published build none of the 55 is in any key's population, so none moves.
- [x] Run it on the published build (`EVIDENCE_DIR=` the copy of the published inputs);
      commit the log.

## Phase 3: Whether a negative gradient reaches a pick through the curves
- [x] Read `R/tune_curve.R` and `R/tune_run.R` for where `segment_gradient` enters other than the rule's
      threshold (the GAM curve and its prior), and record whether a negative value can move a curve or a pick; if it
      can, count the visits involved per key and report, without retuning (a retune is Al's call).

## Phase 4: Write it up
- [x] `research/fdis_export.md`: replace the "#121" line in "What the evidence says so far" with a "Measured vs
      modelled gradient" section beside the width comparison: plain-language lead (what a point measure and a segment
      average are, then the numbers), the band result, the catch difference, the negatives; a `Verified` line naming
      the script, log and evidence md5.
- [x] `data-raw/README.md`: one sentence for the new check.
- [x] `/code-check branch`, then archive and open the PR.

## Owed at the end (reported, done after merge)
- [ ] The sentence in `vignettes/habitat_thresholds.Rmd`'s limits, carried through `data-raw/vignette_method.R`, at the
      next `method.rds` rebuild (#119 or the next promotion); written into #119's body as a task, with the note that
      `vignette_method.R` must compute it as `data-raw/site_gradient_check.R` does (plan review).
- [ ] #120's body gains the rerun: `EVIDENCE_CHECK=FALSE EVIDENCE_DIR=<minimal network's build> Rscript
      data-raw/site_gradient_check.R`.

## Validation
- [x] Tests pass (`devtools::test()`; the script adds no package code, so this guards against an accidental change):
      298 tests, one failure, `test-vignette-data.R`'s check of the ignored evidence files, because this checkout holds
      the 2026-10-25 build (CLAUDE.md names that failure); the branch changes nothing it reads
- [x] `/code-check` clean (once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: the log's counts are held to the issue's (18,759 of 45,529 with `gradient_pct`, 9,397 with
`gradient2_pct`, 55 negative `segment_gradient` on `1bd35829`); the md5 guard is shown to refuse by running once
against this checkout's `d3a434e2` build (expect a `_refused` log, not committed); and the stream-branch count matches
`20261027_segment_gradient_check.txt`'s on the same build where the two overlap.

