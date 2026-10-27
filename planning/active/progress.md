# Progress — Score rules on the gradient link applies (#92)

## Session 2026-10-27

- Plan-mode exploration: probed visits_link.csv (segment at a visit, outcome-linked segment length), link's break
  sources and gradient classes; Al chose link's segment gradient as the main reading, the Atlas line as a sensitivity
- Created branch `92-score-rules-on-the-gradient-link-applies` off main
- Scaffolded PWF baseline from issue #92 with approved phases
- Next: start Phase 1
- Phase 1: `data-raw/segment_gradient_check.R` run on `fresh_default_20261017`; stream branch: 86.2 % of visits with
  fish on a segment starting at the visit vs 10.2 % of empty ones (median 113 vs 305 m); no bunching at default's
  cut-offs (0.99-1.03), 15 % access class 0.94. Research section and #92/#70 bodies written.
- Plan review (Plan agent, 2026-10-27T21:57Z) delivered: `planning/active/review-plan.md`; findings folded into
  task_plan.md (B1/B2 0320's sensitivity path, G4/G5 the record readers and the grade guard, O1 Phase 4 order; G10
  resolved: thresholds and habitat_grade were never published, so v1 stays).
- Phase 2 (part): `knw_tune_run(cols = )` with `segment_gradient` the default, threaded to the rule and the curve;
  `spec$grad` in the score cache; a pre-record cache rescored unless the run reads `fwa_gradient`; curve keeps `cols`.
  Tests shown red first (6 failures), then green across the six tune test files.
- Phase 2 (rest): `knw_grade_species()` refuses a curve not fitted on `segment_gradient`; `.knw_grade_grad_ok()` holds
  a grade table's `curve_grad`, called by 0320's keep-check, 0325, 0330, vignette_chinook.R and vignette_method.R;
  `knw_thresholds_table()` carries `curve_grad`. 0320: `GRADIENT` (segment_gradient | fwa_gradient → grad_fwa/),
  `main_only` gates extras and grading, `-grad_fwa` log suffix, `cols` on both calls, `curve_grad` in summary and
  grades. 0322 and snap_limit_sensitivity.R pin `fwa_gradient`. Register: `gradient_col` = segment_gradient
  (script:/fn:/record: pointers, tested yes); the register test shown red (4) with the old value restored.
- Phase 3 started: DEV=1 CH runs on both gradients (logs `20261027_tune_run-ch-dev{,-grad_fwa}.txt`): the same
  population (7,659 visits, 235 detections, 45 groups both); pick g<=0.11 on segments vs g<=0.15 on the Atlas line.
  Full suite: 254 tests, 2 failing (test-vignette-data's source tests, expected until Phase 4). Full 0320 launched
  22:14Z from a frozen copy (SCHEMA=fresh_default_20261017, WORKERS=12); every key's smoke gates passed.
- Phase 4 drafted while it runs: vignette_method.R bundles `gradient_sensitivity` and `segment_at_site`; the
  methodology article's steps 2, 3, 5, the snap section (three examples) and limits; the chinook article's placement
  and gradient sentences, with `snap_limit`/`snap_limit_code`'s `code:` pointers restored (proved by a planted 400 m);
  CLAUDE.md's record section and a gradient note.
