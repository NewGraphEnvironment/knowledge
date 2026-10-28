# Findings — Score rules on the gradient link applies (#92)

## Issue context

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

## Proposed

1. **Check the segment at a visit first.** link breaks streams at observations, and FDIS visits are observations, so the
   segment holding a visit starts at the visit and runs upstream to the next break. Measure those segments' lengths and
   how their gradient relates to the Atlas line's before trusting it as the gradient at the site.
2. **Score on link's segment gradient** as the main reading, the gradient link applies; keep the Atlas gradient as a
   sensitivity and report both regions.
3. **Check link's breakpoints.** If link cuts streams at `default`'s own gradient cut-offs (its gradient-class
   breaks), segment gradients line up with `default`'s rule and not a tuned one's; measure whether they do.
4. Say in the method which gradient was scored and why.

Run with #91's placement change in the same retune, and written up with #90's generated reports.

## Depends on

#87; the methodology article (#93) is drafted first, so the fixes it surfaces join this retune.



## Owed to #93's methodology article

- [ ] After this issue's retune (with #91's placement): rerun `Rscript data-raw/vignette_method.R` and
      `data-raw/vignette_bib.R`, and update the rows of `inst/method/settings.csv` the retune changed (the gradient
      source rows, `gradient_col` and `grade_grad_col`, and #91's snap rows: `snap_limit`'s `code:` pointer, below). The article,
      `vignettes/habitat_thresholds.Rmd`, is published already and redraws from the new bundle; replace the long Method
      section of `research/habitat_thresholds_tuned.md` with a link to it.

## Owed by #91 (placement), in this retune

#91 rebuilt the evidence on fresh's snap and the 1:50k code and stopped there
(`scripts/logs/habitat/20261027_evidence_build_ledger.csv`, on `fresh_default_20261017`: 45,529 visits kept
against 40,552; `research/fdis_export.md`, "Placement"). The tracked tune and compare tables still describe the
#73 run.

- [ ] Retune on that evidence (or on this issue's rebuild of it): `0320`, `0325`, `0330` with `SCHEMA` set to the
      schema the evidence names. `0310`'s visit walks are cached from #91, so a rebuild on the same flow load
      reads them back.
- [ ] Rerun `data-raw/vignette_method.R` (its worked examples now carry a moved visit, `examples$moved`, beside
      `kept` and `far`) and `data-raw/vignette_chinook.R`; `test-vignette-data.R`'s "every tracked source" and
      "every ignored source" tests pass again.
- [ ] `vignettes/habitat_thresholds.Rmd`: step 2's prose, the `#snap` section ("The other streams in reach are
      not weighed" is no longer true; show the moved example) and the limits' prose (`snap_limit` 200 m
      unconfirmed, `snap_limit_code` 500 m confirmed, `snap_edges_excluded`).
- [ ] `vignettes/chinook_rearing.Rmd`: the placement sentence ("stream lay within 100 m"), then restore
      `snap_limit`'s `code:` pointer to it in `inst/method/settings.csv` (moved to the row's note by #91).
- [ ] `research/habitat_thresholds_tuned.md`: drop #91's note above its Evidence paragraph once the tables
      describe the new evidence.




## Plan-mode probes (2026-10-27)

Recorded in task_plan.md, "What exploration found"; Phase 1's script reproduces them from committed code.

## Errors Encountered

| Error | Resolution |
|-------|------------|
