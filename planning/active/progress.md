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
- Phase 3: full 0320 on `segment_gradient` exit 0, 22:13Z-00:24Z (130.3 min; scoring 42.6 min on 12 workers), log
  `scripts/logs/habitat/20261027_tune_run.txt`; every fitted summary and grade table carries
  `curve_grad = segment_gradient`. Picks against #73's run (Atlas gradient, older evidence): BT_rear
  mad>=0.35|g<=0.25 -> mad>=0.1|g<=0.3; BT_spawn gains Q1@D500; CH_rear g<=0.13 -> g<=0.11; CO_rear
  mad>=0.03|g<=0.04 -> mad>=0.1|g<=0.0549|Q3@D2000; GR_rear width>=1.5|g<=0.0349 -> width>=2|g<=0.0549; RB_rear
  unchanged (width>=3|g<=0.3); ST_rear gains Q1@D250; WCT_rear g<=0.3 -> g<=0.25.
- `GRADIENT=fwa_gradient` 0320 launched 00:24Z; 0330 launched 00:26Z alongside it (CONFIG_SHA 102762da, the earlier
  comparison's baseline; link's default changed since only in config.yaml comments).
- Found: 0325 reads each comparison's `tuned_structure` without checking `tuned_rule` is the pick, so #73's stale
  comparisons would have supplied the near-river scope for the new picks. Test written; the fix waits for the runs to
  release `R/`. vignette_chinook.R checks the comparison's rule too. Chinook article: at 1.96 SE the flow floor no
  longer rises (0.75 at both), so its guard and three sentences changed; the grad_ext bullet says that run was on the
  Atlas gradient and older records.
- Atlas sensitivity: exit 0, 00:24Z-00:37Z (scoring 11.8 min, main seed), `data/tune/grad_fwa/`, log
  `20261027_tune_run-grad_fwa.txt`. Same populations as the main run. Picks differ from the segment gradient's for BT
  rearing (g<=0.25 vs 0.3), CH (0.15 vs 0.11), CO (0.04 vs 0.0549), GR (width 1.5 vs 2), WCT (0.3 vs 0.25), and drop
  the exception for BT spawning and ST. Every pick's limit is in the other gradient's one-SE region except CO's
  segment-gradient 5.49 % (Atlas region 3, 4, 7, 11, 20-30 %).
