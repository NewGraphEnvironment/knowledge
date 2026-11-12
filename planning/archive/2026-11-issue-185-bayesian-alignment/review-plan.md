# Plan review — #185 (Plan agent, 2026-11-12)

Returned as reply text (Plan agents cannot write); recorded here by the session. Spot-checked before acting:
B1 (point-estimate deviance with a per-group intercept fitted on the scored outcomes, `R/tune_score.R:277-281,
408-425`), G1 (fallback folds refit with `glm.fit` and no ridge, `R/tune_score.R:266-270`), G5 (`honest` picks from
other folds' rows of `Sw`, whose fits trained on fold k, `R/tune_score.R:178-185`) and G7 (the bootstrap resamples
groups of the fixed `Sw` and refits nothing, `R/tune_score.R:160-177`): all four reproduce.

## Findings and dispositions

| id | kind | finding | disposition |
|---|---|---|---|
| a–c | confirm | `log_area` free in scorer and curve; curve `s(wsg, bs = "re")` by REML; held-out groups refit their intercept in both | kept |
| b' | gap | the smoke run and the gate's no-rule baseline also absorb fixed group intercepts, not only the scorer | Context corrected |
| d | gap | the gate is `cv$heldout >= null_heldout_curve` on the curve's own visits: a point comparison, a tie withholds, REML GAM vs ridge GLM | own row (Phase 3) |
| B1 | blocker | the held-out deviance is not −2 × lppd: plug-in point estimate plus one parameter per held-out group fitted on the scored outcomes; clamped at 1e-12 | Context corrected before Phase 3; central ch. 7 row |
| G1 | gap | prior silently dropped on fallback folds | priors row |
| G2 | gap | rule, `log_area`, group intercepts unpenalised; smoothing parameters and `wsg` variance are REML plug-ins; `smoke_coef_max` = 2 × `prior_sd` | priors row; settings rows |
| G3 | gap | groups with one outcome only are dropped (`.tune_modelled`) before scorer and curve; the curve's random effect is estimated on an outcome-selected set | groups row; #186 body |
| G4 | gap | the score tests within-group discrimination; the grade drops `s(wsg)` to compare across groups, which nothing tests; RE = 0 is the average cluster, not the marginal | own row |
| G5 | gap | `honest` is not fully nested | step 8 row |
| G6 | gap | unseen levels: reference in the scorer, training mode in the curve | no-key choices table |
| G7 | gap | the bootstrap measures selection stability given fixed scores, not estimation uncertainty (also `cmp_n_boot`) | reporting row; settings rows |
| G8 | gap | folds dealt stratified on detections; no settings key | no-key choices table |
| G9 | gap | the curve is scored on the folds that chose its variables | gate row |
| G10 | gap | nearest-to-`default` pick is a prior in decision form (#141, #139) | pick row |
| G11 | gap | BDA3 ch. 16 (weakly informative priors, separation), ch. 20 (basis functions), ch. 8 (data collection, ignorability); Rethinking ch. 4 B-splines | searched in Phase 3 |
| G12 | gap | Phase 2 file list misses `grade_species.R`, `tune_grid.R`, `rule_in.R`, `thresholds_table.R`, `compare_rules.R` | Phase 2 list widened |
| G13 | gap | the response is presence per visit, the grade says "expected use per standard electrofishing visit" | detection row starts there |
| O1 | ordering | GitHub writes (Phase 5) before the meaning audit and code-check | Phase 5 moved after the audit and the branch review |
| O2 | ordering | row format is the check's contract; fix it before writing | recorded in findings |
| O3 | ordering | B1 and b' corrections before any verdict | done at the fold-in |
| A1 | assumption | cloglog ↔ Poisson exposure is a derivation | row marked derived unless a page links them |
| A2 | assumption | 1.96 widens the region (pick moves toward `default`): stricter only about calling `default` worse | Context corrected |
| A3 | assumption | `paraPen` scale unverified against Wood | said so in the row |
| A4 | assumption | snap radii, gradient source, modelled MAD, distance cap are predictor measurement error (ch. 15), not "no bearing"; step 10 and spawn settings need reading | decision 2 narrowed: `no bearing` only where nothing statistical turns on it |
| A5 | assumption | which Rethinking PDF | resolved from the guarded copy (findings, Phase 1); evidence recorded |
| A6 | assumption | starter-table errors: the offset, fixed intercepts as the whole method, "worse than" vs `>=` | Context corrected |
| S1 | scope | choices with no settings key (held-out refit, SE formula, gate, outcome-based group drop, unseen levels, clamp, fallback, link, `log_area`'s role, curve reference, stratified dealing) | a third table, checked against code anchors |
| S2 | scope | #186 assumes varying intercepts are new; both models must be scored both ways (own intercept and new cluster) | #186 body edit |
| C1 | acceptance | unquoted page citations are not machine-checked | said plainly; the audit re-reads each cited page and records it |
| C2 | acceptance | quotes outside blockquotes invisible | check fails on any `"…" (<citekey>, p.` not in a blockquote line |
| C3 | acceptance | letters-and-digits normalisation gives false passes | token matching as 0280 does (numbers as written), minimum fragment length |
| C4 | acceptance | running head on first line only | folio on first or last non-notice line; offset measured at several points |
| C5 | acceptance | verdict test too loose | dedicated last-column verdict, exactly one, scoped by table heading; stale keys and duplicates fail |
| C6 | acceptance | more negative tests | fabricated quote, verdict only in prose, duplicate row, stale key, short fragment, wrong page |
| C7 | acceptance | meaning audit concrete | each "what the method does" sentence cites file:line; audit re-reads them |
| C8 | acceptance | the log is tracked | kept; it names only relative paths |
