# Review of the revision, round 3 (#204)

Reviewer: final round, by enumeration. Diff `c2a6eda4...HEAD` (HEAD `ce4a691c`). Bundles read: `inst/vignette-data/method.rds`
(meta commit `6aace90a`, written 2026-11-13) and `inst/vignette-data/cut_points.rds` (written 2026-11-05). Checks run in a
detached worktree of HEAD (removed afterwards): `data-raw/bayesian_alignment_check.R` with and without
`MD=vignettes/tuning-bayesian-practice.Rmd`.

## Checklist read

- `code-check.md`, `## Mechanisms`, prose of all fourteen (tables skipped): above all "A proxy is not the property" (a
  sentence describing a figure is a claim about the criterion; end by enumerating every result-describing sentence), "A
  guard's scope, escape hatches, and remedies" (compression runs both ways; terminate by enumeration; a claim about
  another system is settled by that system's own account), "Verification that reads its own output", "One fact derived
  twice", "Written data outlives the fix" (enumerate every artifact quoting a moved value), "A fix lands in one of two
  callers that share a harness" (the refactor's two callers).
- `code-check-r.md` for the patterns the diff uses: "A `data-raw/` script must load the source tree" (it does,
  `pkgload::load_all()` at line 52), "`vapply(..., USE.NAMES = FALSE)` strips ALL dimnames" (not used; `vapply()` here
  takes row names from the first result, so `spl[, "groups"]` resolves), "Inside a dplyr verb, a column named like a
  local variable wins" (only literals inside verbs), "`tolerance` in testthat is RELATIVE" (the new test uses
  `expect_identical`), "`identical(-0, 0)`" / type checks (`identical()` on integer sums: bundle columns are all
  integer, verified with `str()`).

## Refactor (task 2)

- `knw_tune_run()` outputs cannot change. `.tune_base()` is the removed block verbatim (same filter, `log_area`, `era`
  factor with the same three levels in the same order, `data_set` and `wsg` factors). `.tune_population()` is the
  removed per-stage block verbatim: `st` and `bcol` move from per-species to per-stage, both pure reads of
  `species_tbl`/`sp`; same `merge()` (same row order), same `in_range`/`blocked`/barrier filters, same `U`/`S`
  construction, `droplevels(d$wsg)` at the same point. The `no_response` path returns `d` before the spawner merge and
  before `droplevels`, exactly as before, and `rec$population <- c(visits_in = nrow(d))` reads the same `d`.
  `chk_subset(stages, c("rear","spawn"))` still guards the stage argument for the run; the data-raw caller passes only
  `rear`/`spawn` from the scope keys.
- `vignette_method.R`'s population call matches `scripts/0320-tune-run.R`: `edge_stream` and `area_range` are
  `eval(formals(knw_tune_run)$...)` and 0320's two `knw_tune_run()` calls (lines 381, 405) pass neither, so both take
  the defaults; `vs` is the same `visits_species.csv` read with the same `col_types`; `vl` the same `visits_link.csv`
  with the same `col_types`; the spawner evidence is built by the identical expression (`codes` with
  `cols(.default = "c"), na = ""`, `fish.rds`, the BT-pooling join). The guard refuses unless `groups` and
  `groups_both` reproduce every summary's, and `groups_all`/`groups_none` come from the same `pop` object, so they
  describe the run that published.

## Enumeration (task 1)

Verdicts: **P** pinned (a stopifnot or computed inline); **T** true, unpinned, and a promotion cannot falsify it (code,
book, issue or prose about method); **TU** true now but a promotion could make it false without failing the build;
**W** wrong or misleading against its source.

| line | claim | source of truth | verdict |
|---|---|---|---|
| 106-108 | tuning picks thresholds from sampling records; grades by how often caught on streams like it | `knw_tune_run()`, `knw_grade()` | T |
| 108-111 | two textbooks; methodology article sets out steps | bib, link | T |
| 113-115 | judged on left-out watershed groups, by SE of the difference | `R/tune_score.R` 1-17, `.tune_fold_setup()` | T |
| 114-115 | "keeping the near-ties together rather than naming one winner" | `R/tune_score.R` docs: a pick is named; `data/thresholds.csv` `value` + `range_lo/hi`; article's own table row 8 ("one choice and the range") | **W** (finding 4) |
| 115-119 | three main departures, each defensible; listed three match table rows 3, 7, 8 | table `verdict` | T (editorial; a fourth "departs, defensibly" row, effort, is not named "main") |
| 119-122 | three things should change = three "should change" rows (5, 12, 16) | table | T |
| 126-129 | grid around link's definitions: size floor, slope ceiling, for some a near-river exception | `x$picks$pick` (`Q3@D1000`, `none`) | T |
| 131-138 | scorer: regression on sorting + log area + data set + period; each kept group own base rate; score = held-out deviance summed over sites; left-out base rate refit on own sites | `R/tune_score.R` 1-12, `.tune_score_one()`, `.tune_group_dev()` | T |
| 140 | `val("folds")` folds | settings | P |
| 140-142 | close calls within one SE; choose the one changing link's definition least | `.tune_pick` / docs lines 15-22: `recommended` moves off a pick whose exception distance is under `d_floor` (200 m) | **TU** (finding 3) |
| 142-145 | curve: smooth surface against size, distance to a river and slope; grades every reachable stream with size and slope; publishing test publishes only if curve beats no definition on left-out folds | `R/tune_curve.R` 82-104 (distance in model unless too few distinct), `R/grade.R:55`, `R/grade_species.R`, `R/tune_run.R:273` | T |
| 153-192 | table rows 1-15 (code facts) | as rows above and below; row 6 `ridge` on `pen = ^(data_set|era)` only, cloglog; row 12 `R/tune_curve.R:139` vs `.tune_fold_setup()` zero contrast | T |
| 187 | row 16 "link cuts a stream at each species' highest fish record on it" | link `configs/default/config.yaml` `observation_breaks: top_per_species` (present species); prose 370 says "species it models" | T |
| 188-190 | verdict counts used by the answer | table | T |
| 200 | quote p. 426 | `bayesian_alignment_check.R` MD run, line 200 ok | P |
| 202-205 | groups left out whole; base rate refit before scoring | `.tune_fold_setup()`, `.tune_score_one()` | T |
| 205-208 | each definition flattered about equally "by our reasoning (not measured)" | stated as unmeasured | T |
| 209-210 | books average the score over the posterior, pp. 210, 174 | PDF pp. 210 (log score / lppd), 174 (WAIC lppd) | T |
| 216 | quote p. 227 | check, ok | P |
| 218-219 | SE over watershed groups as the book does over sites, p. 228 | `se <- sqrt(length(ix)) * apply(M - M[, best], 2, sd)`; PDF p. 228 | T |
| 219-222 | `val("se_region")` SE; published table gives range beside choice, p. 225 | settings P; `thresholds.csv` `range_lo/range_hi` | P/T |
| 222-223 | one SE is a convention; nearest-default is a decision | settings note | T |
| 225-227 | "thousands of habitat definitions"; quote p. 182 | `x$picks$rules` 6,149-8,385; check ok | T / P |
| 227-230 | honest check chooses on four folds, scores fifth; fits included the fifth; moves no choice or grade | `R/tune_score.R` 178-187; folds pinned `== "5"`; #203 body | P/T |
| 234-236 | separation of a sampling term | `.tune_score_one()` ridge | T |
| 236-239 | normal prior, SD 2.5, cloglog; step of one multiplies rate by e; 2.5 multiplies by about 12 | `prior_sd == 2.5`, `round(exp(prior_sd)) == 12` | P |
| 241-242 | BDA3 default: scale 2.5, Cauchy, every coefficient but the constant, p. 416 | PDF p. 416 "Cauchy ... scale 2.5 to each of the coefficients ... except the constant term" | T |
| 244-246 | 0.3 % of normal, 20 % of Cauchy beyond three scales | computed inline (`p_norm`, `p_cauchy`) | P |
| 246-247 | Cauchy effect untested; habitat definition carries no prior | `ridge` has 0 for `rule` | T |
| 249 caption | dotted lines at three scales (±7.5) | `prior_sd == 2.5` pinned | P |
| 268 | quote p. 216 | check ok | P |
| 270-272 | no uncertainty carried; no prior simulation run, p. 328 | PDF p. 328 (prior predictive); #186 lists it as to do | T |
| 272-274 | fallback without the prior; rests on an argument | `.tune_score_one()` `m$fallback` branch; #203 body | T |
| 282 | quote p. 413 | check ok | P |
| 284-288 | own base rate per group; one-outcome group dropped | `.tune_modelled()` | T |
| 289-291 | CH: 111 groups, keeps 45, drops 65 none, 1 all | `ch$...` inline; sum identity and `groups_all >= 1` pinned | P |
| 291 | every species and stage: none-caught outnumber all-caught | `all(sc$groups_none > sc$groups_all)` | P |
| 292-293 | named keys drop more than half | `under_half` computed (`share < 0.5`), `length >= 2` | P |
| 295 caption | kept/dropped by outcome; spawning counts spawner evidence | `.tune_population()` `S` | T |
| 313-317 | curve pools (random effect); fitted on at most the scorer's groups; held-out group scored by own refit; grades in dropped groups too | `R/tune_curve.R` 85, 104, 124-150; `groups_sp()` in 0320:563 | T |
| 319-322 | grade is an average group, p. 428; no score tested cross-group comparison | `R/grade.R` `exclude = "s(wsg)"`; PDF p. 428 | T |
| 326-329 | same sites and folds; smoothness penalised; point comparison, no SE; any improvement publishes; variables from the choice | `.tune_null_heldout(cv$data, ...)`; `cv$heldout >= null` | T |
| 330 | withheld keys listed | `withheld` computed; `length >= 1` | P |
| 330-331 | closest call, withheld/published by 0.6 | computed; `0.05 <= |margin| < 1` | P |
| 333 caption | left of zero published, at or right withheld | `identical(grade_withheld, margin <= 0)` off ties | P |
| 349-351 | unseen level: scorer reference (prior's centre), curve most common level | `.tune_fold_setup()` zero contrast; `R/tune_curve.R:139` | T |
| 355-358 | log area has a fitted slope, not an offset, p. 357 | `nuis` includes `log_area`; PDF p. 357 "put a parameter in front of log τ" | T |
| 360-362 | response is a catch on one visit, p. 499; grade is expected use per standard visit | `.tune_population()`; PDF p. 499 | T |
| 363-365 | worst-placed sites dropped, rest read as exact, p. 495 | funnel (snap limits); PDF p. 495 | T |
| 369-372 | link cuts at the highest record of each species it models | link `break_order` + `observation_breaks: top_per_species` | T |
| 372 | earlier build cut at every record | `research/minimal_network_tuning.md` table ("every observation a break") | T |
| 372-374 | the build the published tuning reads: fish less often than before, several times an empty site | `pr` rows published_92 / published_145; `> 3x` pinned | P for the numbers; **TU** for "the build the published tuning reads" (finding 2) |
| 374-376 | minimal network: no cut at records, crossings, hand-mapped ends; still at Atlas line joins, natural barriers, impassable slopes | link `default_minimal` `break_order` = `gradient_minimal, falls, barriers_definite`; stream-splits 343-346 | T |
| 376-377 | about as often as an empty one | `abs(diff) < 1` | P |
| 379 caption | stream-branch share, three networks; "as the published tuning reads it" | `cp$premise` | P (numbers) / **TU** (finding 2) |
| 398-400 | minimal 9 % vs published 13 %; 9 % again on parent | `cp_lim()` pins `>` and `==`; `identical(gs_ch, cp published pick)` | P |
| 401-402 | three kinds of cut at once | link `default` vs `default_minimal` `break_order`: `observations`, `habitat_endpoints`, `crossings` | T |
| 401-402 | "and its build is a slightly earlier `link`" offered as a reason the runs cannot isolate the cause | `research/minimal_network_tuning.md` 86-90 (R/ and configs identical; "differs ... in one thing only, the network"); stream-splits 514-515 | **W** (finding 5) |
| 402-404 | runs cannot say how much from fish-record cuts alone; decision not made | #120 open | T |
| 408-411 | #203: three fixes as stated | `gh issue view 203` | T |
| 412-417 | #186: CH and WCT rearing, posterior with smooth priors, one-outcome groups kept, both curves scored both ways, offset and prior simulation | `gh issue view 186` | T |
| 418-420 | #120: every published species and stage tuned on minimal; CH also through the parent; none published; still to decide | `cp$other_keys$key` (7 keys) = `sc$key` today; `cp$setups` parent; #120 open | **TU** (finding 6) |
| 421-422 | #70: modelled vs field slopes; fixed-length slopes | `gh issue view 70` | T |
| 426-429 | review fits nothing; occupancy named not taught; splines without penalty scale | PDF p. 499 names occupancy models | T |
| 430-431 | code at `x$meta$commit`, data written `x$meta$written` | inline | P |
| 435-468 | glossary (17 entries): base rate, Cauchy, close calls (same simplification as 140-142), cloglog step, curve, deviance, fold (`val`), grade, habitat definition, minimal network (as 374-376), partial pooling, penalty, posterior, prior, publishing test, sampling terms, score, scorer, separation, SE of a difference, watershed group | as the rows above | T (close calls: TU, finding 3) |

## Findings

**[medium]** `research/bayesian_alignment.md:398,399,415` (and prose 207, 245, 269, 279) — the refactor of `R/tune_run.R`
moved the three code lines the research file cites by `file:line`, and its own check now fails. Run on HEAD in a detached
worktree, `Rscript data-raw/bayesian_alignment_check.R` prints `FAIL choice response_presence: cites R/tune_run.R:176
but its anchor is at R/tune_run.R:302`, `population_gate: cites :173 ... at :299`, `grade_gate: cites :292 ... at :273`,
then `FAILED: 3 problems`, exit 1. The committed `scripts/logs/habitat/20261113_bayesian_alignment_check.txt` reads PASS
because it was written at `9ca32daa`, before `58ba27e0` moved the lines. The prose citations at lines 207 (`:292`), 245
(`:176`), 269 (`:173`) and 279 (`:174`, the barrier filter, now `:300`) are unchecked and equally stale. Separately, the
committed article log `20261113_bayesian_alignment_check-tuning-bayesian-practice.txt` names quote lines 198/214/224/266/280
while the article's are 200/216/226/268/282: the quotes still pass (rerun), but the log is from an earlier revision.
Remedy: update the three table cells and four prose citations to `R/tune_run.R:302`, `:299`, `:273`, `:300`, rerun both
checks and commit both logs.
**Rule:** "Written data outlives the fix" (when a derived value changes, enumerate every artifact quoting it); "A fix
lands in one of two callers that share a harness" (the line anchors are the harness the research file shares with the
code).

**[low]** `vignettes/tuning-bayesian-practice.Rmd:372-374, 379` — "the build the published tuning reads" and the caption's
"as the published tuning reads it" are guarded only by chinook rearing's pick (`identical(gs_ch, cp$setups$pick[...
"published"])`, line 84), a proxy for the claim, which is that `cut_points.rds`'s `published_145` evidence is the evidence
of the run `method.rds` describes. A promotion onto a new link build or evidence build that leaves chinook rearing at
`g<=0.13` passes the guard while the sentence and the figure's middle bar ("full network, published tuning", 44 % / 6.6 %)
then describe a superseded build, and "the earlier tuning" names two tunings back. The bundles already carry the
discriminating fact: `x$meta$md5_local[["data/fdis/derived/visits_link.csv"]]` and
`cp$meta$md5_local[["data/stage/cut_points/evidence/published_145/visits_link.csv"]]` are both
`db5ca99a659b242bede926db1bca4c0a` today. Pin their equality (and the `visits_species.csv` pair) beside the pick check.
**Rule:** "A proxy is not the property" (a sentence describing a figure is a claim about the criterion the figure stands
in for); "A guard's scope, escape hatches, and remedies".

**[low]** `vignettes/tuning-bayesian-practice.Rmd:141-142`, table row 4 (line 175), glossary 439 — "among them we choose
the one that changes `link`'s current habitat definition least" / "the close call nearest link's current habitat
definition" omits the `d_floor` condition the code applies: `recommended` (what `x$picks$pick` and `thresholds.csv`
publish) moves off a pick whose near-river exception distance is under 200 m (`R/tune_score.R` docs lines 19-22;
`settings.csv` `d_floor`). It holds today (pick and recommended coincide in all seven `data/tune/<key>_tune.csv`), but the
grid carries `Q*@D100` rules (1,001 of chinook rearing's), so a promotion whose fewest-departures close call has a 100 m
exception would publish a rule that is not the one nearest `link`'s, with no guard firing. The methodology article
(`tuning-method.Rmd:327`) has the same sentence, outside this diff. Either name the exception ("unless its near-river
distance is under 200 m, where placement cannot tell a mainstem catch from a tributary's") or pin it: have
`vignette_method.R` record each key's unconstrained pick and stop the article unless it equals `pick`.
**Rule:** "State each claim by the code's definition" (writing.md); same mechanism as round 1's `R/grade_species.R:106`
finding.

**[low]** `vignettes/tuning-bayesian-practice.Rmd:114-115` — "keeping the near-ties together rather than naming one
winner" is wider than the code and contradicts the article's own lines 141-142 and table row 8 ("No: as one choice and
the range of close calls"): the tuning names one winner, the pick, which is the published `value`, and reports the
range beside it. Say "reporting the near-ties beside the one it chooses" or similar.
**Rule:** "A guard's scope, escape hatches, and remedies" (compression adds a claim the source never made).

**[low]** `vignettes/tuning-bayesian-practice.Rmd:401-402` — "and its build is a slightly earlier `link`, so these runs
cannot say how much of the change comes from the cuts at fish records alone" offers the link version as a second
confound, which the sources rule out: `research/minimal_network_tuning.md:86-90` records that link 0.78.2 changed no code
(`R/` and `configs/` identical at the two runs' commits) and that a tuning on the published build "differs from the
minimal network's in one thing only, the network", and the linked stream-splits article (lines 514-515) says the setups
were tuned "on the same visits, flows and species range, so that the segments and the slope tested are the only
differences". The conclusion stands on the three kinds of cut alone; the version clause (and its pin at line 83, which
pins a true but irrelevant fact) should go, or be stated as "a link release that changed no code".
**Rule:** "A guard's scope, escape hatches, and remedies" (a causal claim about another system is settled by that
system's own account; read the source beside the compression).

**[low]** `vignettes/tuning-bayesian-practice.Rmd:418-419` — "every published species and stage has been tuned on it" is
unpinned. It is true today (`cp$other_keys$key` and `sc$key` are the same seven keys), but a promotion that publishes a
key the minimal run never tuned (rainbow trout rearing, paused on the minimal build per #120, is the nearest case) makes
it false and the build passes. Pin `setequal(sc$key, cp$other_keys$key)` in the setup chunk's `stopifnot()`.
**Rule:** "Check that each guard covers the set its sentence names" (writing.md); "A guard's scope, escape hatches, and
remedies".

No other claim is wrong or outrun: every number in the groups, publishing-test and prior sections is computed inline and
held by a `stopifnot()` that covers the set its sentence names, the five book quotes pass the PDF check on HEAD, the
unquoted page citations (pp. 174, 210, 225, 228, 328, 357, 416, 428, 495, 499) carry what the article says of them, and
the four issue bodies (#203, #186, #120, #70) and #214 match the article and CLAUDE.md.
