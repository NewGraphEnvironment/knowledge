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
- `/code-check branch`, four rounds (reviewers unnamed, findings in `planning/active/review-round{1..4}.md`), no code
  bugs in any round; every finding was a published claim or a guard:
  | round | findings | fixed | inside previous fix? | commit |
  |---|---|---|---|---|
  | 1 | 4 (closed issue as "Open work", unguarded limits, stale cache doc, reader overclaim) | 4 | — | 365771d |
  | 2 | 3 (the reader overclaim for three more readers; a guard passing on NULL; "where fish were caught") | 3 | yes | e4f14a8 |
  | 3 | enumeration: 116 claims, 17 false + 1 unguarded (the gradient gap does NOT follow the catch) | 18 | yes | c8d0f96 |
  | 4 | fact sweep: 47 restatements, 7 false + 1 unguarded (gap scoped by species; older restatements) | 8 | yes | 30fa392 |
  Ended by enumeration: round 4 confirmed round 3's 18 rows (17 true, H6 rescoped in 30fa392), its 10 false or
  unguarded rows each map to an edit in 30fa392, and that commit's 9 gap numbers are all in the segment log. The
  research rewrite and the bundles still to come get their own round before the PR.
- 0325's comparison-rule check (e988eb6) refuses #73's stale comparisons for BT_spawn, CO_rear and ST_rear, whose new
  picks carry a near-river pair, so 0325 runs after 0330 as corrected.

- 0330 ran from this machine against `fresh_default_20261017` (`WORKERS=6`, GPKG on), 2026-10-28T00:25:52Z to 08:12:16Z, exit 0: 466.1 min, of which the comparison 269.1 min (8 keys) and the GeoPackages 196.9 min, against 14.0 min for them on the database's host (2026-10-26). Log `scripts/logs/habitat/20261027_compare.txt`. No other database holds the build (the local service has only `fresh_default` and another flow load). Task added to #81: GeoPackages opt-in (Al, 2026-10-27).
- 0325 ran from the per-key comparison tables once every key had compared (exit 0): 46 threshold rows, 8 keys fitted; CO and WCT grades withheld; nothing uploaded.
