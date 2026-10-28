# Code-check round 3: branch 92-score-rules-on-the-gradient-link-applies (base 3f9cf4a, HEAD e4f14a8)

## Checklist read

- code-check-python.md: in full (7,237 bytes). The diff has no Python.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped), with "A guard
  that fails toward pass", "A guard's scope, escape hatches, and remedies" (its "Compression runs both ways" and
  "six ways a restatement names its population" paragraphs), "A fix lands in one of two callers" and "A proxy is not
  the property" read closely. "Rules that stand alone", Security and Spreadsheets/PDFs from the index only; none
  applies.
- code-check-r.md, sections read in full (9): "A `data-raw/` script must load the source tree", "testthat counts an
  uncaught error under `error`", "`$` on a list partial-matches", "`identical()` on two reader results", "`match()`
  treats NA as a matchable VALUE", "`[[` on a named ATOMIC vector", "Rscript reads a script as it runs", "A
  `function(...)` mock hides arguments", "`ifelse()` with an all-NA test". The rest from the index.
- code-check-shell.md and code-check-spatial.md: index only. The diff adds no shell script; its one new SQL is a
  plain count over `<schema>.streams` (data-raw/segment_gradient_check.R) and no spatial call.

## Probes run

- Throwaway worktree at HEAD e4f14a8 (removed after), `NOT_CRAN=true`, `testthat::test_file()` counting
  passed/failed/error/skipped: test-settings-register 272/0/0/0, test-grade_species 41/0/0/0,
  test-thresholds_table 55/0/0/0.
- Every reader comparison the CLAUDE.md "A run's record" paragraph lists was read in the code: 0320:339-350,
  0325:74-112, 0330:174-191, vignette_chinook.R:81-148, vignette_method.R:81-101. All TRUE as now written.
- The measurement log `scripts/logs/habitat/20261027_segment_gradient_check.txt` against every number in
  research/habitat_thresholds_tuned.md "Which gradient is scored", CLAUDE.md:213-216 and the articles.
- link at the build's commit a17e917 (`../link`): `R/lnk_pipeline_break.R` (observation breaks are "WSG- and
  species-filtered, exclusions applied"; gradient breaks are the 15/20/25/30 % access classes) and
  `inst/extdata/configs/default/config.yaml` `break_order` (observations, gradient_minimal, falls,
  barriers_definite, habitat_endpoints, crossings).
- The sensitivity replayed from data/tune/*_tune.csv and data/tune/grad_fwa/*_tune.csv: the main pick is in the
  Atlas-gradient region for 6 of the 7 `fitted` keys (not CO_rear), so the Limits guard holds; summaries name
  `segment_gradient` / `fwa_gradient` and one evidence md5 (1bd35829d07c...).
- 0230:298-301: `catch_status == "fish"` is `any_catch`, any species caught.
- vignette_method.R:304 guard probed in R: on summaries without a `curve_grad` column it passes; with an NA it errors
  "missing value where TRUE/FALSE needed".
- `gh`: #70 OPEN (fixed-window gradients), #91 CLOSED, #92 OPEN, fresh#257 OPEN ("Fixed-window, mouth-reach and lidar
  gradients per segment").

## Mechanism

The working guess is right in its parts, but the shared assumption underneath is narrower: **a claim is maintained
where it was written, not as a fact with a population.** Three consequences, each seen in rounds 1-3:

1. **A correction lands where the reviewer pointed and nowhere else.** A fact is restated in up to six places (article,
   chinook article, CLAUDE.md heading and body, 0320's header, the register's note, a data-raw comment), and each
   round fixed the instance named. R2 corrected "link cuts where fish were caught" in the two articles; the same
   claim survives as "at each catch" in CLAUDE.md's heading, 0320's header, settings.csv's note and vignette_method.R's
   comment. R1 narrowed one reader in CLAUDE.md; R2 found the same sentence's other readers. This is "A fix lands in
   one of two callers" applied to prose: the fix should have been a grep for the fact, not for the sentence.
2. **A guard holds the direction of a claim on whatever population the bundle carries, not the one the sentence
   names.** R2 found guards that passed on a missing table; this round's version is a guard present and live but on a
   proxy population: step 3's "a site that caught a species link models ... usually" is guarded by the share over
   sites that caught any fish.
3. **A "so" clause chains two measured facts into a third that was never measured** ("Compression runs both ways":
   a causal link added in compression). Short segments have noisier gradients and fish sites have shorter segments,
   so "the noise follows the outcome", but the log measured the gap by outcome directly and it is the same (0.0083
   either way). The conclusion went into CLAUDE.md, the register and the article, where no guard can see it because
   the bundle carries no by-outcome gap.

The enumeration below is over every `+` line of the branch diff in CLAUDE.md, research/, vignettes/, inst/method/,
R/ roxygen and comments, script and data-raw headers, comments and stop/say messages (tests and man/ excluded; man/
duplicates roxygen). Extracted with awk over branch.diff (547 added lines, 222 prose lines), then split into claims.

## Enumeration (116 candidates: 98 TRUE, 17 FALSE, 1 UNGUARDED)

| id | where | claim | verdict |
|---|---|---|---|
| C1 | CLAUDE.md:208 | heading "link cuts a segment at each catch" | FALSE: link breaks only at bcfishobs observations of species in the group's presence table, QA exclusions applied (link R/lnk_pipeline_break.R:23,36); R2's correction not carried here |
| C2 | CLAUDE.md:210-211 | rules and curves read segment_gradient, the one link applies and the grade reads | TRUE |
| C3 | CLAUDE.md:211-212 | fwa_gradient is the sensitivity: GRADIENT=fwa_gradient 0320, main fold seed, data/tune/grad_fwa/ | TRUE (0320:85-95, 211) |
| C4 | CLAUDE.md:212 | "never graded or published" | FALSE in part: never graded TRUE; vignette_method.R reads grad_fwa into method.rds and the methodology article publishes it ("still a close call for 6 of the 7") |
| C5 | CLAUDE.md:213 | knw_grade_species() refuses a curve on any other gradient | TRUE (R/grade_species.R:76-82; test) |
| C6 | CLAUDE.md:213-214 | link breaks at bcfishobs observations; an FDIS visit that caught a modelled species is one | TRUE approx. (species-filtered, exclusions applied) |
| C7 | CLAUDE.md:214-215 | "its gradient's noise depend[s] on the outcome" | FALSE: log, by catch: median abs gap 0.0083 (fish) and 0.0083 (zero); SD 0.0772 and 0.0781 |
| C8 | CLAUDE.md:215-216 | 86 % of visits with fish start a segment against 10 % of empty | TRUE (86.2, 10.2) |
| C9 | CLAUDE.md:216 | fixed-window gradients are #70's | TRUE (#70 OPEN) |
| C10 | CLAUDE.md:346-349 | grade rows carry the fields incl. curve_grad; summary and curve.rds carry evidence_md5, run_uid, gradient; cache spec lists 8 settings | TRUE (0320:254-262, 299-304, 376-381; R/tune_run.R:228-229) |
| C11 | CLAUDE.md:349-350 | 0320's keep-check compares every field, null_heldout_curve by presence | TRUE (0320:339-350) |
| C12 | CLAUDE.md:351 | 0325 and 0330 compare rule, run, walk, evidence, gradient, flow load (live) | TRUE |
| C13 | CLAUDE.md:352 | 0325 the reference edge types across tables | TRUE (0325:108) |
| C14 | CLAUDE.md:352 | vignette_chinook.R the rule, walk, evidence and gradient | TRUE |
| C15 | CLAUDE.md:353 | vignette_method.R the gradient, the evidence and one flow load | TRUE (vignette_method.R:88-96) |
| C16 | CLAUDE.md:353-355 | gate fields: 0330 and vignette_chinook.R by presence, 0325 all but the prior, vignette_method.R none | TRUE (grep: 0 hits in vignette_method.R) |
| C17 | CLAUDE.md:355 | 0325 refuses before it writes anything | TRUE (checks 0325:63-112 precede the write at :116) |
| R1 | R/grade_species.R:40-42 | @param curve must be fitted on segment_gradient | TRUE (enforced) |
| R2 | R/grade_species.R:76-77 | a curve from before #92 records none and was fitted on the Atlas line's | TRUE |
| R3 | R/grade_species.R:146-147 | .knw_grade_grad is the column graded on and recorded as curve_grad | TRUE |
| R4 | R/grade_species.R:150-151 | the five named readers hold a grade table to it before reading | TRUE (not stated as exhaustive) |
| RI1 | R/rule_in.R | default cols grad = segment_gradient (example) | TRUE |
| T1 | R/thresholds_table.R:29-31 | curve_grad is the gradient column; NA on a pre-record summary | TRUE (test) |
| T2 | R/thresholds_table.R:45-46 | a comparison of another rule is an error | TRUE (test) |
| T3 | R/thresholds_table.R:131 | a comparison left from an earlier pick would hand its scope | TRUE |
| TC1 | R/tune_curve.R:49-50 | returns cols as given | TRUE |
| TR1 | R/tune_run.R:39-43 | cols read by the rules and the curve; gradient joins the cache settings | TRUE (test) |
| TR2 | R/tune_run.R:56-58 | record lacking grad rescored; pre-record rescored unless fwa_gradient, then read back with a message | TRUE (R/tune_run.R:236-251) |
| TR3 | R/tune_run.R:57-58 | every pre-record cache was scored on fwa_gradient | TRUE (the default until #92) |
| TR4 | R/tune_run.R:226-227 | a cache from before the record is rescored | TRUE (read as the grad record: spec-without-grad is always rescored) |
| S1 | data-raw/segment_gradient_check.R:6-7 | "an FDIS visit that caught a modelled species is one, so its segment starts at the visit" | FALSE as a universal: the same script measured 80.7 % (CH present), 74.1 % (ST), 90.5 % (CO), 94.2 % (BT) |
| S2 | segment_gradient_check.R:8-11 | what step 1 measures | TRUE |
| S3 | segment_gradient_check.R:12 | `default` cuts gradients only at its access classes | TRUE (link docs, break_order) |
| S4 | segment_gradient_check.R:14 | "every stream-branch segment of SCHEMA" | TRUE with a scope note: the query filters edge types only, not the tuning's waterbody exclusions (not material) |
| S5 | segment_gradient_check.R:30 | access classes 0.15-0.30 are link's default | TRUE |
| S6 | segment_gradient_check.R header | INPUT/OUTPUT/RUN | TRUE |
| SL1 | data-raw/snap_limit_sensitivity.R:105 | the Atlas line's gradient, as #91 measured it | TRUE |
| VC1 | data-raw/vignette_chinook.R:92,135-144 | stop messages for gradient, compared rule, summary gradient | TRUE |
| VC2 | vignette_chinook.R:223 | the gradient is the run's own record, width/flow the defaults | TRUE |
| VM1 | data-raw/vignette_method.R:34-35 | INPUT names grad_fwa | TRUE |
| VM2 | vignette_method.R:39 | OUTPUT names gradient_sensitivity, segment_at_site | TRUE |
| VM3 | vignette_method.R:87 | grades on the gradient the article names | TRUE |
| VM4 | vignette_method.R:286 | "link cuts a stream at each catch" | FALSE (as C1) |
| VM5 | vignette_method.R:287 | the population is segment_gradient_check.R's | TRUE (same edge, waterbody and area filters; 29,335) |
| VM6 | vignette_method.R:296-298 | sensitivity on the main seed, this run's evidence; each summary must name both | TRUE (:307-309) |
| VM7 | vignette_method.R:304 | "the main run's summaries do not all name segment_gradient" (guard) | FALSE as a guard: passes when the column is absent (logical(0)); errors on NA |
| P1 | inst/method/pipeline.csv step 2 | no open issue | TRUE (#91 CLOSED) |
| P2 | pipeline.csv step 5 | each visit takes link's segment and its gradient | TRUE (R/link_place.R:105) |
| P3 | pipeline.csv step 7 | open work #70 | TRUE (OPEN) |
| SE1 | settings.csv snap_limit, snap_limit_code | `code:` patterns in chinook_rearing.Rmd | TRUE (test-settings-register 272 pass) |
| SE2 | settings.csv gradient_col | value and where | TRUE (test) |
| SE3 | settings.csv gradient_col note | Atlas line's scored on every key as the sensitivity | TRUE (22 summaries in grad_fwa/) |
| SE4 | settings.csv gradient_col note | "link cuts a stream at each catch" | FALSE (as C1) |
| SE5 | settings.csv gradient_col note | "its gradient's noise, follow the outcome" | FALSE (as C7) |
| SE6 | settings.csv gradient_col | tested = yes | TRUE |
| SE7 | settings.csv grade_grad_col note | the curve is fitted on it since #92; knw_grade_species() refuses another | TRUE |
| RE1 | research:89-90 | Verified / Produced by | TRUE |
| RE2 | research:94 | Al chose it 2026-10-27 | not checkable; taken as TRUE |
| RE3 | research:95-96 | "a visit that caught a modelled species is one, so its segment starts at the visit" | FALSE as a universal (as S1) |
| RE4 | research:96-97 | 29,335 visits; 86.2 % vs 10.2 % | TRUE |
| RE5 | research:98 | median 113 m vs 305 m | TRUE |
| RE6 | research:98-100 | CH 80.7 / 44.6; BT 94.2 / 37.8 | TRUE |
| RE7 | research:100-101 | short segments noisier: <= 10 m 13.5 % read 0, median gap 0.015 vs 0.0017 over 500 m | TRUE (0.0153, 0.0017) |
| RE8 | research:101-103 | "The median gap is the same either way ..., so the noise follows segment length, and length follows the outcome" | FALSE: the conclusion it sets up (noise follows the outcome) is the one its own measurement contradicts |
| RE9 | research:103-104 | class differs on 7.8-12.1 % | TRUE (7.81-12.06) |
| RE10 | research:105-106 | default breaks at observations, gradient barriers, falls, definite barriers, habitat endpoints, crossings | TRUE (config.yaml break_order) |
| RE11 | research:106-107 | gradient breaks only from the access classes 15/20/25/30 % | TRUE |
| RE12 | research:107-109 | 9,997,708 segments; 0.99-1.03; 15 % at 0.94 | TRUE (0.986-1.027; 0.941) |
| RE13 | research:109 | segment gradients not lined up with default | TRUE |
| RE14 | research:111 | #70 on fresh#257 | TRUE (both OPEN, titles match) |
| RE15 | research:115-118 | the article covers every step; settings register | TRUE |
| RE16 | research:118-120 | 0320's header keeps the spec; issues named there and in the register | TRUE |
| Z1 | 0320:38-39 | #57 to #91 read the whole Atlas line's | TRUE |
| Z2 | 0320:39-40 | "link cuts a stream at each catch" | FALSE (as C1) |
| Z3 | 0320:40 | a visit with fish usually sits on a short segment starting at it | TRUE (86.2 %) |
| Z4 | 0320:41 | main fold seed, no grades, data/tune/grad_fwa/ | TRUE |
| Z5 | 0320:41-42 | "which nothing that publishes reads" | FALSE: data-raw/vignette_method.R:299-319 reads grad_fwa/<key>_{tune,summary}.csv into method.rds, which ships in inst/ and the methodology article prints |
| Z6 | 0320:42 | recorded in the cache, the summary and every grade table | TRUE |
| Z7 | 0320:71-72 | dev/grad_fwa path; log suffix -grad_fwa | TRUE (:94-100) |
| Z8 | 0320:86 | "never graded or published" | FALSE in part (as C4) |
| Z9 | 0320:91 | the main seed alone, no grades: dev and the sensitivity | TRUE |
| Z10 | 0320:254 | "which every grade table records and its readers compare" | FALSE as a universal: data-raw/compare_parallel_check.R:103-107 reads grade tables and compares no record field |
| Z11 | 0320:262 | NA under DEV=1 and on the sensitivity | TRUE |
| Z12 | 0320:351 | a table from before the record was not graded on this gradient | TRUE |
| Q1 | 0322 header | SAME SPEC AS 0320 OF #67 on fwa_gradient; the call names it | TRUE |
| Q2 | 0325:78 comment, :80-83 and :97-98 messages | gradient checks | TRUE |
| Q3 | 0325:129 description | thresholds carry curve_grad | TRUE (knw_thresholds_table output) |
| Q4 | 0330:189 comment and :192 message | gradient check against the curve's | TRUE |
| CH1 | chinook_rearing.Rmd:71-72 | guards for fewer sites, more detections, less habitat | TRUE (guarded) |
| CH2 | chinook_rearing.Rmd:79 comment and 81-84 | at 1.96 the slope goes back, floor and allowance stay | TRUE (guarded) |
| CH3 | chinook_rearing.Rmd:115 | under a stricter bar the slope goes back to link's | TRUE (guarded) |
| CH4 | chinook_rearing.Rmd:129-133 | code-named stream within 500 m, else nearest within 200 m | TRUE (R/fdis_place.R; register patterns) |
| CH5 | chinook_rearing.Rmd:136-137 | gradient is the segment's, from its own ends | TRUE |
| CH6 | chinook_rearing.Rmd:137 | link cuts a stream at a site that caught a species it models | TRUE approx. |
| CH7 | chinook_rearing.Rmd:138 | "(the methodology article measures how often)" a site with chinook starts its own segment | FALSE: the methodology article measures sites that caught any fish (vignette_method.R:290, `catch_status == "fish"`), not chinook sites; the chinook share (80.7 %) is only in the research file |
| CH8 | chinook_rearing.Rmd:176 | calls fewer sites habitat and catches more chinook | TRUE (guarded) |
| CH9 | chinook_rearing.Rmd:248-249 | slope back, floor and allowance unchanged, link's rule not a close call | TRUE (guarded) |
| CH10 | chinook_rearing.Rmd:347-348 | the #67 run scored the Atlas line's slope on an earlier build | TRUE (0322 pins fwa_gradient; before #73) |
| H1 | habitat_thresholds.Rmd:81-84 | step 8: most splits, seldom on a redraw, always a close call, beats link | TRUE (guarded; CH_rear 3/4, 0.095, 4/4, 1326.8 < 1468.6) |
| H2 | habitat_thresholds.Rmd:90-94 | Limits/step 3 guard comment | see H6 |
| H3 | habitat_thresholds.Rmd:162-166 | step 2 placement rule | TRUE |
| H4 | habitat_thresholds.Rmd:166-167 | most dropped because too far | TRUE (pre-existing guard) |
| H5 | habitat_thresholds.Rmd:176-177 | a site that caught a species link models is a bcfishobs observation | TRUE approx. |
| H6 | habitat_thresholds.Rmd:177 | "so it usually starts a segment of its own" | UNGUARDED: the guard (`sg$at_site_fish > 0.5`) is over sites that caught any fish, not a species link models (0230:299); the claim holds per species in the log (74.1-100 %) but nothing in the bundle measures it |
| H7 | habitat_thresholds.Rmd:194-196 | the slope is the segment's, not the whole line's | TRUE |
| H8 | habitat_thresholds.Rmd:196-197 | averaging a line scores a slope link never tests | TRUE |
| H9 | habitat_thresholds.Rmd:223-225 | came back on X of N, only Y % of redraws, close call on all | TRUE (guarded) |
| H10 | habitat_thresholds.Rmd:261-262 | matched with every Atlas stream within 500 m except 6010 connectors | FALSE in part: fresh also never snaps to unmapped or placeholder (999) lines (0230:39-41; the register's snap_edges_excluded note) |
| H11 | habitat_thresholds.Rmd:263-264 | named tributary within 500 m even past a nearer; else nearest within 200 m | TRUE |
| H12 | habitat_thresholds.Rmd:265-266 | three sites: kept on nearest, moved past a nearer, dropped for distance | TRUE (vignette_method.R:345-359 refuses otherwise) |
| H13 | habitat_thresholds.Rmd:350-351 | a code can name several streams; the nearest may not be the fished one | TRUE |
| H14 | habitat_thresholds.Rmd:352-353 | segments are shortest where fish were caught | TRUE (guarded len_fish < len_zero) |
| H15 | habitat_thresholds.Rmd:353-355 | shares and medians | TRUE (inline) |
| H16 | habitat_thresholds.Rmd:355 | "So the slope is less certain at the sites with fish." | FALSE and UNGUARDED: inferred from length; the log's by-catch gap is equal (0.0083 / 0.0083; SD 0.0772 / 0.0781), and the bundle carries no by-outcome gap |
| H17 | habitat_thresholds.Rmd:355-357 | still a close call for X of N | TRUE (guarded; 6 of 7 today) |
| H18 | habitat_thresholds.Rmd:357-358 | fixed-length slopes would not depend on the catch (#70) | TRUE |

FALSE (17): C1, C4, C7, S1, VM4, VM7, SE4, SE5, RE3, RE8, Z2, Z5, Z8, Z10, CH7, H10, H16. UNGUARDED (1): H6.

## Findings

- **[published claim contradicted by data]** CLAUDE.md:214-215; inst/method/settings.csv:34 (gradient_col note);
  research/habitat_thresholds_tuned.md:100-103; vignettes/habitat_thresholds.Rmd:355. Each says, or concludes, that
  the segment gradient's noise follows the catch: "its gradient's noise depend on the outcome", "its gradient's noise,
  follow the outcome", "so the noise follows segment length, and length follows the outcome", "So the slope is less
  certain at the sites with fish." No measurement shows this, and the one by-outcome measurement made shows the
  opposite. scripts/logs/habitat/20261027_segment_gradient_check.txt, "by catch (stream branch)": median abs gap from
  the Atlas line 0.0083 for fish and 0.0083 for zero, SD 0.0772 and 0.0781. Per species it is mixed: CH present
  0.0086 against absent 0.0089, BT 0.0083 against 0.0080. The research file quotes the equal medians and then draws the
  conclusion they contradict. Fish sites do sit on shorter segments, and short segments do disagree more with the line,
  but the gap at fish sites is no larger. The article sentence has no guard, and the bundle carries no by-outcome gap
  to hold it to. State what was measured: segments are shorter at fish sites, and short segments read 0 more often.
  Drop the outcome-noise conclusion, or measure noise by outcome at equal length and carry it in the bundle.
- **[published claim; R2's fix carried to the articles only]** CLAUDE.md:208 (heading "link cuts a segment at each
  catch"); scripts/0320-tune-run.R:39-40 ("link cuts a stream at each catch"); inst/method/settings.csv:34 (same
  words); data-raw/vignette_method.R:286 (same). R2 established that link breaks only at observations of species in
  the group's presence table, with QA exclusions (link R/lnk_pipeline_break.R:23,36, .lnk_pipeline_break_obs_species).
  A catch of a species link does not model cuts nothing. Its universal sibling is research:95-96 and
  segment_gradient_check.R:6-7: "a visit that caught a modelled species is one, so its segment starts at the visit".
  The same script measured 80.7 % for chinook-present visits and 74.1 % for steelhead-present ones (exclusions, the
  presence filter and the 1/5 m window all leave some out). Say "usually", as the articles now do.
- **[UNGUARDED article claim: guard on a proxy population]** vignettes/habitat_thresholds.Rmd:176-177 ("A site that
  caught a species link models ... usually starts a segment of its own"), guarded at :93 by `sg$at_site_fish > 0.5`.
  `at_site_fish` is computed over `catch_status == "fish"` (data-raw/vignette_method.R:290), which is
  `any_catch`, any species (scripts/0230-fdis-load.R:299), including the species link does not model. The guard holds
  the sentence's direction on a superset of its population. It passes today (86 %), and the per-species shares in the
  log support the claim, but nothing in the bundle measures the population the sentence names. In the same vein,
  vignettes/chinook_rearing.Rmd:138 says "the methodology article measures how often" a site with chinook starts its
  own segment. The methodology article measures sites that caught any fish; the chinook share (80.7 %) is only in the
  research file. Compute `at_site` over visits that caught a species in link's presence table (or name the population
  the guard has in the sentence), and point the chinook parenthesis at what the article measures.
- **[fragile: guard fails toward pass]** data-raw/vignette_method.R:304:
  `if (!all(fitted$curve_grad == "segment_gradient")) stop(...)`. On summaries with no `curve_grad` column,
  `fitted$curve_grad` is NULL, the comparison is `logical(0)`, `all()` is TRUE, and the guard passes. This is R2's
  Limits-guard shape. Probed: it passes on a missing column, and on an NA it errors with "missing value where
  TRUE/FALSE needed" rather than its own message. The grade-table check at :88-89 covers the usual case, so this is
  reachable only with new grades beside old summaries. Write
  `!"curve_grad" %in% names(fitted) || !all(fitted$curve_grad %in% "segment_gradient")`.
- **[published claim, low]** scripts/0320-tune-run.R:41-42 says data/tune/grad_fwa/ is something "which nothing that
  publishes reads", and 0320:86 and CLAUDE.md:212 say "never graded or published". data-raw/vignette_method.R:299-319
  reads grad_fwa/<key>_{tune,summary}.csv into inst/vignette-data/method.rds. That file ships with the package, and the
  methodology article prints from it ("still a close call for 6 of the 7"). The accepted point, that 0325, 0330 and
  knw_thresholds_table() do not read it, is true. Name those three, as CLAUDE.md:82 does for grad_ext, instead of
  "nothing that publishes".
- **[published claim, low]** scripts/0320-tune-run.R:254 says the gradient is something "which every grade table
  records and its readers compare". data-raw/compare_parallel_check.R:103-107 reads grade tables and compares no
  record field. This is R2 finding 1's universal one axis over; R/grade_species.R:150-151 now lists its five readers
  instead. Separately, vignettes/habitat_thresholds.Rmd:261-262 says a site is "matched with every Atlas stream
  within 500 m, except the lines that carry a stream across a watershed group's boundary". fresh never snaps to
  unmapped or placeholder (999) lines either (scripts/0230-fdis-load.R:39-41), so the exception list is incomplete.

Round-fix code review (365771d, e4f14a8): no bugs. The new Limits guard refuses a bundle without either table
(`!is.null`, `nrow(gs) > 0`), and a missing `pick_in_atlas_region` column fails it (`sum(NULL) > n/2` is FALSE). The
CLAUDE.md reader list and the R/grade_species.R:150-151 comment match the code. The R/tune_run.R:56-58 roxygen matches
the cache branches at :236-251. pipeline.csv's issue column points only at open work (#70).
