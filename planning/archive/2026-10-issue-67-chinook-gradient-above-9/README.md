## Outcome

CH rearing's recommended rule (`CH_rear_v1`: MAD ≥ 0.75 m³/s, gradient ≤ 9 %, a ≥ 3 m³/s river within 1 km) took the
steepest gradient on the shared tuning ladder, so `scripts/0322-tune-grad-extend.R` scored CH rearing again with the
ladder extended above 9 %, on the same evidence, folds, seeds and bootstrap, and set the steeper rules beside
`CH_rear_v1` on link's segments. A first pass to 15 % put the best at 15 %, the top again, so the ladder ran on to
30 %. 15 % stayed best, every limit from 7 to 30 % had rules in the region, and the other seeds all chose 15 %. But
nested selection on the longer ladder lost to `default`, so the steeper edge does not carry to groups the choice
has not seen. `CH_rear_v1` stays at 9 %; extending the ladder for every species is #68 (BT and RB rearing also sit
at its top). `knw_tune_run()` gained `grid_args`, and its score cache is now read back only for the grid it was
scored on (it had read the old grid's scores for any grid, and the rule strings alone missed a moved `default`).
The article says what the second run found, computed from its tables. The verdict is the section "The gradient
maximum above 9 % (#67)" in `research/chinook_rearing_tuned.md`.

Wrong turns kept in `findings.md`: the plan joined segments on `id_segment` alone, which repeats across groups;
the compare was first built beside the extended run's recommended rule, not the rule 0330 compared; one candidate
was graded with a curve that reads a different river size than its walk; and the code review needed three rounds
and an enumeration of 15 artifact pairs, after round 3 found a defect inside round 2's fix.

## Measurement

| | value |
|---|---|
| shared rules reproducing 0320's held-out deviance | 2,795 of 2,795, largest difference 9.1e-13 |
| best rule, ladder to 30 % (6,149 rules) | MAD ≥ 0.75, ≤ 15 %, Q1 within 1 km, deviance 1,131.0 |
| `CH_rear_v1` behind it | 19.7 (SE 22.1), in the region (23 → 91 rules) |
| bootstrap recommended share by gradient | 15 % 43 %, 30 % 17.5 %, 11 % 17 %, 5.49 % 11.5 %, 9 % 0 % |
| nested selection (held-out deviance) | longer ladder 1,389.4; 0320's 1,234.5; `default` 1,347.0; no rule 1,382.5 |
| km added beside `CH_rear_v1`'s 88,607 | 11 % 1,680; 13 % 2,470; 15 % 2,754; 30 % 3,070; extended best 10,392 |
| of which off the stream edges (river polygons) | 30–58 km |
| run times | scoring 13.6 min (to 15 %) and 22.4 min (to 30 %) on 8 workers; grading 7.5–9.3 min per rule; five comparisons 62 min in parallel |

The nested-selection result changed the decision's reason: before it, 9 % was kept for the shared ladder alone.

## Evidence

`scripts/logs/habitat/2026101[89]_tune_grad_extend*`; tables `data/tune/grad_ext/`, `data/compare/grad_ext/`.

Closed by: the PR for #67
