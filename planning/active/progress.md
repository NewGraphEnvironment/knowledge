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
