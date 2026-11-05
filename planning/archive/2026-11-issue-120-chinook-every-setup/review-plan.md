# Plan review (Plan agent, spawned 2026-11-05T03:47Z, read only), with verdicts

| finding | verdict |
|---|---|
| B1 `.knw_grade_grad` as a lookup breaks the guards' default | Not real here: the code keeps `.knw_grade_grad <- "segment_gradient"` and adds `.knw_grade_grads` beside it (`R/grade_species.R:155,159`), the fix the reviewer names |
| G1 no segment-gradient guard in `knw_tune_promote()`/`0335`: "the guards stay" is wrong | Real (`R/tune_promote.R:140-211` compares fields across keys only). Add one: a promoted key or its kept set on any `curve_grad` but `segment_gradient` is refused |
| G2 SETUP output lands in `<run>/grad_fwa/`, which promotion treats as the sensitivity | Real: SETUP writes the run root, forces the full run, skips the RUN requirement, names its log `-setup_<g>` |
| G3 nothing ties `token_grad` to `curve_grad`; the Atlas token has no path into the record | Real: a fixed map `curve_grad` → `token_grad` (`grad-parent`, and `grad-fwa`, the name the link issue proposes); the archive refuses `grad-fwa` until link's vocabulary has it |
| G4 Phase 5 omits `EVIDENCE_DIR=data/fdis/derived_parent` | Real: added |
| G5 `data/compare/setups/` not ignored | Real: ignore it |
| G6 0330 does not record the gradient | Real: `knw_compare_rules()`'s log line names it (done), and 0330's own log |
| Q3 SETUP over an existing run; sensitivity on a SETUP run; log suffix; cache without spec | Real: refuse SETUP on a run whose summaries name another `curve_grad`, refuse the sensitivity on a SETUP run |
| Q4 0310 on the default settle log works; pass SETTLE | Holds; the run in flight took the newest default log, `20261103_link_settle.csv` (the published build's run) |
| Q5 compare's segment read and change reasons read `s.gradient` | Already covered in the working tree (`%7$s AS gradient`); fresh's connectivity reads the scratch copy's `gradient`, which the UPDATE overwrites |
| Q5 NULL Atlas gradient drops segments silently | Measured 0 NULL Atlas and 0 NULL parent gradients over all 5,546,370 segments; the check now refuses a NULL as well as a missing row |
| Q5 visit `linear_feature_id` vs segment's for the Atlas gradient | To count on the evidence after 0310 |
| Ordering: file the link token issue in Phase 2 | Taken |
| Assumption: streams_parent provenance not recorded | 0310's ledger row `parent_table` records built_at, rows and both runs |
| Scope: a gradient column in compare.csv changes its header | Not added: the log names it |
| Acceptance notes (one-group regrade, pick-agreement criterion stated before, column-wise evidence compare, stored-vs-default nonzero by design, expected record fields) | Taken into the plan |
