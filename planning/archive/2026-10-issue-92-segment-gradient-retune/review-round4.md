# Code-check round 4: branch 92-score-rules-on-the-gradient-link-applies (base 3f9cf4a, HEAD c8d0f96)

## Checklist read

- code-check-python.md: in full (7,237 bytes). The diff has no Python.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence lines skipped), with "A guard
  that fails toward pass", "A proxy is not the property", "A guard's scope, escape hatches, and remedies" (its
  "Compression runs both ways" and "six ways a restatement names its population" paragraphs), "A fix lands in one of
  two callers" and "Zero-length, empty, and unset" read closely. The rest of the file from the index; none applies.
- code-check-r.md, sections read in full: "A `data-raw/` script must load the source tree", "`$` on a list
  partial-matches", "`identical()` on two reader results". The rest from the index.
- code-check-shell.md and code-check-spatial.md: index only. The round-3 fix adds no shell, SQL or spatial call.

## Probes run

- Throwaway worktree at c8d0f96 (`$TMPDIR/kw_r4`, removed after), `NOT_CRAN=true`, `testthat::test_file()`
  passed/failed/error/skipped: test-settings-register 272/0/0/0 (the edited settings.csv note parses),
  test-grade_species 41/0/0/0, test-thresholds_table 55/0/0/0.
- The round-3 guard at data-raw/vignette_method.R:306, `!identical(unique(fitted$curve_grad), "segment_gradient")`,
  probed in R on the real summaries (refuses = TRUE): current summaries FALSE (passes); column missing TRUE; one NA TRUE;
  zero rows TRUE; `fwa_gradient` TRUE; old summary (no column) bound with new ones through `bind_rows()` TRUE (the NA
  fill). A base data.frame with a `curve_grad_x` sibling and no `curve_grad` passes by `$` partial matching, but
  `fitted` is always a tibble from `bind_rows(read_csv())` and no such column exists: not reachable.
- Sensitivity replayed from data/tune/*_tune.csv and data/tune/grad_fwa/*_tune.csv: 7 fitted keys (BT_rear, BT_spawn,
  CH_rear, CO_rear, GR_rear, RB_rear, ST_rear), main pick inside the Atlas-gradient region for 6 (all but CO_rear);
  every grad_fwa summary names `fwa_gradient` and the main run's evidence md5.
- data/fdis/derived/visits_link.csv (local file, no database): over all 45,529 placed visits, 79.8 % of the 25,748 that
  caught fish start a segment (offset -1 to 5 m) against 11.8 % of the 19,781 that caught none; median segment 97.6 m
  against 279 m. The bundle's population (stream branch, usual area) is 86.2 % / 10.2 % (log).
- link at a17e917: `.lnk_pipeline_break_obs_species()` takes the species in the group's `wsg_species_presence` row
  (plus CT aliases), and `<schema>.observations` is pre-filtered by that and the QA exclusions.
- Readers of data/tune/: 0325:34,68 (`tune_dir <- "data/tune"`, non-recursive), 0330:96, R/thresholds_table.R:63;
  data-raw/vignette_method.R:300 reads grad_fwa/; data-raw/vignette_chinook.R:180-186 reads grad_ext/.
- Record-field readers: 0320:341-354, 0325:74-98, 0330:183-191, vignette_chinook.R:85-92,142, vignette_method.R:87-96,306-311,
  data-raw/compare_parallel_check.R:103 (reads a grade table, compares no record field).
- `gh issue view 70`: OPEN, "Gradient on the ground: field-measured against the Freshwater Atlas, fixed-window
  gradients, then lidar".

## 1. Round 3's 18 rows on the current tree

| id | where now | verdict | evidence |
|---|---|---|---|
| C1 | CLAUDE.md:208 heading | TRUE now (approx.) | "where its species were caught"; the body says "usually" |
| C4 | CLAUDE.md:211-214 | TRUE now | names the three non-readers and vignette_method.R as the reader |
| C7 | CLAUDE.md:216-219 | TRUE now as to noise (claim removed); its replacement is N8 below (scope) | log by catch 0.0083/0.0083 |
| S1 | segment_gradient_check.R:6-7 | TRUE now | "usually", "often" (74.1-100 % per species) |
| VM4 | vignette_method.R:286-288 | TRUE now | observations of the species it models; 86.2 % |
| VM7 | vignette_method.R:306 | TRUE now | probed: refuses missing column, NA, zero rows, other value, mixed old/new |
| SE4 | settings.csv:34 | TRUE now (approx.) | "at the observations of the species it models" |
| SE5 | settings.csv:34 | TRUE now as to noise; its replacement is N16 below (scope) | |
| RE3 | research:95-97 | TRUE now | "usually ... often" |
| RE8 | research:101-104 | TRUE now | scoped "By catch"; equal medians, SD 0.0772/0.0781 |
| Z2 | 0320:39-40 | TRUE now | |
| Z5 | 0320:41-43 | TRUE now | names the three and the bundle |
| Z8 | 0320:87 | TRUE now | "never graded" (0320:310 returns before grading when `main_only`) |
| Z10 | 0320:255-256 | TRUE now | the five comparers named; each compares `curve_grad` (code lines above) |
| CH7 | chinook_rearing.Rmd:138 | TRUE now | parenthetical removed (but see sweep row F1-12 for line 137) |
| H10 | habitat_thresholds.Rmd:261 | TRUE now | "every mapped Atlas stream" (research uses "mapped" to exclude unmapped and 999) |
| H16 | habitat_thresholds.Rmd:355 | TRUE now | replaced by "which stretch ... depends on what the crew caught", guarded by `at_site_fish > at_site_zero` |
| H6 | habitat_thresholds.Rmd:176-177 | still UNGUARDED (narrower) | the sentence now names sites that caught any fish, as the guard does, but unscoped ("most sites that caught fish"); the guard `sg$at_site_fish > 0.5` is over the stream-line, usual-area subset (29,335 of 45,529). True on the full population today (79.8 %, probe above) |

17 of 18 TRUE now; 1 still UNGUARDED (H6, narrower than before).

## 2. Fact sweep (47 restatements: 39 TRUE, 7 FALSE, 1 UNGUARDED)

Grepped the whole tree (CLAUDE.md, research/, vignettes/, R/, man/, scripts/, data-raw/, inst/method/; planning/ and
logs excluded) for each fact, not each sentence.

### F1. Where link breaks streams (observations of the species in the group's presence table, QA exclusions applied)

| # | where | verdict |
|---|---|---|
| 1 | CLAUDE.md:208 heading | TRUE approx. |
| 2 | CLAUDE.md:215-216 | TRUE |
| 3 | scripts/0320-tune-run.R:39-40 | TRUE |
| 4 | data-raw/segment_gradient_check.R:6-7 | TRUE |
| 5 | data-raw/vignette_method.R:286 | TRUE |
| 6 | inst/method/settings.csv:34 note | TRUE |
| 7 | research/habitat_thresholds_tuned.md:95-97 | TRUE |
| 8 | research/habitat_thresholds_tuned.md:71 (pre-existing) | TRUE approx. (scoped by its own figures to "the twelve species codes link models") |
| 9 | R/link_place.R:6, man/knw_link_place.Rd:35 (pre-existing) | TRUE approx. ("at observations", no population named) |
| 10 | vignettes/habitat_thresholds.Rmd:174-175 (pre-existing, base d166c2a) "It also cuts streams where fish have been observed, using bcfishobs" | FALSE in part: link cuts only at observations of the species in the group's presence table, exclusions applied; bcfishobs holds every species (research:71: FDIS's share is 29 % for the modelled codes, 44 % across all species, so the populations differ) |
| 11 | vignettes/habitat_thresholds.Rmd:176-177 | TRUE ("can be"; "most" measured) — guard: see F2-24 |
| 12 | vignettes/chinook_rearing.Rmd:137 (branch, e4f14a8) "link cuts a stream at a site that caught a species it models" | FALSE as a universal: 80.7 % of CH-present stream-branch visits start a segment (log); the identical statement in segment_gradient_check.R and research was corrected to "usually" in c8d0f96, this one was not |
| 13 | research/habitat_thresholds_tuned.md:112 "where a catch cut the stream" | TRUE approx. |

### F2. Whether segment length and the gradient's gap follow the catch

| # | where | verdict |
|---|---|---|
| 14 | CLAUDE.md:216-218 length depends on the outcome; 86 / 10 %, 113 / 305 m | TRUE (log 86.2 / 10.2, 113 / 305) |
| 15 | CLAUDE.md:218-219 "The gradient's gap from the Atlas line's does not (median 0.0083 either way)" | FALSE in part: measured only by any catch. The outcome a key scores is its species' presence, and per species the log's medians differ for four species, three of them fitted keys: CO 0.0079 present vs 0.0115 absent, GR 0.0023 vs 0.0043, ST 0.0086 vs 0.0113, WCT 0.0076 vs 0.0164 |
| 16 | CLAUDE.md:219-220 fixed windows' length would not depend on the outcome (#70) | TRUE (#70 OPEN) |
| 17 | settings.csv:34 "a segment's length follows the outcome" | TRUE |
| 18 | settings.csv:34 "though its gradient's gap from the Atlas line's does not" | FALSE in part (as 15) |
| 19 | research:101-102 short segments further from the line: ≤10 m 13.5 % read 0, 0.015 vs 0.0017 >500 m | TRUE (0.0153, 0.0017, 13.5) |
| 20 | research:102-104 "By catch, though, the gap is the same ... length follows the outcome, and its gradient's departure ... does not" | TRUE as scoped ("By catch") |
| 21 | scripts/0320-tune-run.R:40 a visit with fish usually sits on a short segment starting at it | TRUE (86.2 %, median 113 m) |
| 22 | data-raw/segment_gradient_check.R:7 "often starts at the visit" | TRUE |
| 23 | data-raw/vignette_method.R:287 a site with fish usually starts its own segment | TRUE |
| 24 | vignettes/habitat_thresholds.Rmd:177 "most sites that caught fish start a segment of their own" | TRUE (79.8 % all placed); UNGUARDED in scope (guard over the stream-line subset; = H6) |
| 25 | vignettes/habitat_thresholds.Rmd:90-91 guard comment | TRUE (describes the stream-line guard) |
| 26 | vignettes/habitat_thresholds.Rmd:352-355 shortest where caught; shares; medians; "which stretch ... depends on what the crew caught" | TRUE, guarded (`at_site_fish > at_site_zero`, `len_fish < len_zero`) |
| 27 | vignettes/habitat_thresholds.Rmd:357-358 fixed length would not depend on where fish were caught | TRUE |

### F3. Who reads data/tune/grad_fwa/ (and the sibling grad_ext/)

| # | where | verdict |
|---|---|---|
| 28 | CLAUDE.md:211-214 | TRUE |
| 29 | scripts/0320-tune-run.R:41-43 | TRUE |
| 30 | scripts/0320-tune-run.R:72-73 (no grades, -grad_fwa log) | TRUE |
| 31 | scripts/0320-tune-run.R:86-87 "never graded" | TRUE |
| 32 | data-raw/vignette_method.R:34-35 INPUT | TRUE |
| 33 | settings.csv:34 "scored on every key as the sensitivity (data/tune/grad_fwa/)" | TRUE |
| 34 | scripts/0322-tune-grad-extend.R:8-10 (pre-existing, grad_ext) | TRUE (names the chinook article as the one reader, then defines "publishes" by the three) |
| 35 | CLAUDE.md:80-83 (pre-existing, grad_ext) "nothing that publishes reads them, because 0325, 0330 and knw_thresholds_table() list their directories non-recursively" | FALSE in part, by the standard round 3 applied to Z5: data-raw/vignette_chinook.R:180-186 reads data/tune/grad_ext/ into the chinook bundle, which ships in inst/ and the article prints; 0322's own header and the new grad_fwa sentence (#28) both name their bundle reader, this one does not |

### F4. Which readers compare which record fields

| # | where | verdict |
|---|---|---|
| 36 | CLAUDE.md:349-358 body (fields; 0320 every field, null_heldout_curve by presence; 0325/0330; vignette_chinook; vignette_method; gate fields; 0325 refuses before writing) | TRUE (code lines above; unchanged since round 3's C10-C17) |
| 37 | CLAUDE.md:347 heading (pre-existing, 6e5384d) "every reader compares it, not its presence" | FALSE: its own body (:354-358) says 0330 and vignette_chinook.R check the gate fields by presence and vignette_method.R not at all, and data-raw/compare_parallel_check.R:103 reads a grade table and compares nothing |
| 38 | scripts/0320-tune-run.R:255-256 | TRUE |
| 39 | R/grade_species.R:146-151 | TRUE |
| 40 | scripts/0325-publish.R:80-98 messages; scripts/0330-compare.R:189-192 | TRUE |
| 41 | R/thresholds_table.R:29-31 | TRUE |
| 42 | research/database_builds.md:105 (pre-existing, 0390fce) "every grade table carries the flow load and walk md5 its readers compare" | FALSE in part: data-raw/vignette_method.R compares no walk md5 (it checks one flow load); compare_parallel_check.R compares neither |

### F5. What fresh snaps to (mapped lines only: no NULL local code, no 999; 6010 excluded by 0230; 1425 kept)

| # | where | verdict |
|---|---|---|
| 43 | scripts/0230-fdis-load.R:39-44 | TRUE (fresh R/frs_point_snap.R:12-13, 57-59) |
| 44 | inst/method/settings.csv:8 note | TRUE |
| 45 | CLAUDE.md:198-199 | TRUE |
| 46 | research/fdis_export.md:148-152 | TRUE |
| 47 | vignettes/habitat_thresholds.Rmd:261-262 "every mapped Atlas stream ... except 6010"; vignette_method.R `near()` query (localcode not NULL, not 999, not 6010) | TRUE |

Totals: 47 rows; TRUE 39; FALSE 7 (#10, #12, #15, #18, #35, #37, #42; #15 and #18 are one fact in two places, and
#10, #35, #37, #42 predate the branch); UNGUARDED 1 (#24).

Outside scope, noted only: planning/active/task_plan.md:51-52 still says "link cuts a segment at a catch, so the
segment's length and noise depend on the outcome" (a plan record; it will be archived as written).

## 3. New claims on the '+' lines of c8d0f96 (33: 30 TRUE, 2 FALSE, 1 UNGUARDED)

| id | where | claim | verdict | stopifnot (articles) |
|---|---|---|---|---|
| N1 | CLAUDE.md:208 | heading: link cuts a segment where its species were caught | TRUE approx. | |
| N2 | CLAUDE.md:212 | grad_fwa never graded | TRUE | |
| N3 | CLAUDE.md:212-213 | read by no publisher: 0325, 0330, knw_thresholds_table() list data/tune/ without recursing | TRUE | |
| N4 | CLAUDE.md:213-214 | vignette_method.R reads it for the sensitivity sentence | TRUE | |
| N5 | CLAUDE.md:215-216 | link breaks at the observations of the species it models in each group | TRUE approx. (presence table) | |
| N6 | CLAUDE.md:216 | a visit that caught one is usually such an observation | accepted (log 74-100 %) | |
| N7 | CLAUDE.md:216-218 | segment and length depend on the outcome; 86 / 10 %; 113 / 305 m | TRUE | |
| N8 | CLAUDE.md:218-219 | the gradient's gap does not (median 0.0083 either way) | FALSE in part (scope; F2-15) | |
| N9 | CLAUDE.md:219-220 | fixed-window gradients' length would not depend on the outcome; #70's | TRUE | |
| N10 | segment_gradient_check.R:6 | breaks at the observations of the species it models | TRUE approx. | |
| N11 | segment_gradient_check.R:7 | usually such an observation; often starts at the visit | TRUE | |
| N12 | vignette_method.R:286-288 | cuts at observations of modelled species; a site with fish usually starts its own segment | TRUE | |
| N13 | vignette_method.R:305 | a missing column or an NA refuses | TRUE (probed) | |
| N14 | settings.csv:34 | cuts at the observations of the species it models | TRUE approx. | |
| N15 | settings.csv:34 | a segment's length follows the outcome | TRUE | |
| N16 | settings.csv:34 | its gradient's gap from the Atlas line's does not | FALSE in part (scope; F2-18) | |
| N17 | research:95-96 | breaks at observations of the species it models in each group | TRUE | |
| N18 | research:96-97 | usually such an observation; often starts at the visit | TRUE | |
| N19 | research:101-102 | short segments further from the line: 13.5 %, 0.015 vs 0.0017 | TRUE | |
| N20 | research:102-103 | by catch the gap is the same: 0.0083, SD 0.077 / 0.078 | TRUE | |
| N21 | research:103-104 | length follows the outcome, departure does not | TRUE as scoped "By catch" | |
| N22 | 0320:39-41 | cuts at observations of modelled species; a visit with fish usually on a short segment starting at it | TRUE | |
| N23 | 0320:41-43 | grad_fwa not read by 0325, 0330, knw_thresholds_table(); the bundle reads it | TRUE | |
| N24 | 0320:87 | never graded | TRUE | |
| N25 | 0320:255-256 | every grade table records it; 0320's keep-check, 0325, 0330, the two vignette scripts compare it | TRUE | |
| N26 | chinook_rearing.Rmd:138 | a site with chinook can start a short segment of its own | TRUE ("can"; no quantifier) | none needed |
| N27 | habitat_thresholds.Rmd:176 | a catch of a species link models can be one of those observations | TRUE | none needed |
| N28 | habitat_thresholds.Rmd:177 | so most sites that caught fish start a segment of their own | TRUE (79.8 % all placed, 86.2 % stream branch) | UNGUARDED in scope: `sg$at_site_fish > 0.5` (:93) is over the stream-line, usual-area subset |
| N29 | habitat_thresholds.Rmd:261-262 | every mapped Atlas stream within 500 m, except 6010 | TRUE | values via `val()`, pinned by test-settings-register; "mapped" is a code fact |
| N30 | habitat_thresholds.Rmd:352-354 | segments shortest where fish were caught; shares; medians | TRUE | `sg$at_site_fish > sg$at_site_zero`, `sg$len_fish < sg$len_zero` |
| N31 | habitat_thresholds.Rmd:354-355 | which stretch a slope is worked out over depends on what the crew caught | TRUE | `sg$at_site_fish > sg$at_site_zero` |
| N32 | habitat_thresholds.Rmd:355-357 | still a close call for X of N on the Atlas line's slope | TRUE (6 of 7) | inline count; `sum(gs$pick_in_atlas_region) > nrow(gs) / 2` |
| N33 | habitat_thresholds.Rmd:357-358 | fixed-length slopes would not depend on where fish were caught (#70) | TRUE | none needed |

## 4. The round-3 fix's code

data-raw/vignette_method.R:306: `!identical(unique(fitted$curve_grad), "segment_gradient")`. No bug: it refuses a
missing column, an NA, zero summaries, another gradient and a mix of old and new summaries (probe above), and passes the
current ones. `fitted` comes from `bind_rows(read_csv(..., col_types = cols(.default = "c")))`, so `unique()` returns a
plain unnamed character vector and `identical()` compares like with like. The only other code change in c8d0f96 is
comments.

## Findings

- **[published claim contradicted by data, low; F2-15, F2-18, N8, N16]** CLAUDE.md:218-219 ("The gradient's gap from
  the Atlas line's does not [depend on the outcome] (median 0.0083 either way)") and inst/method/settings.csv:34 ("a
  segment's length follows the outcome, though its gradient's gap from the Atlas line's does not"). The round-3 fix
  replaced "the noise follows the outcome" with its negation, measured on one population: any catch. Each key's
  outcome is its own species' presence, and the same log's per-species table
  (scripts/logs/habitat/20261027_segment_gradient_check.txt, "by species outcome") has the median gap differ for four
  species, three of them fitted keys: CO 0.0079 present against 0.0115 absent, GR 0.0023 against 0.0043, ST 0.0086
  against 0.0113, WCT 0.0076 against 0.0164 (smaller where the species was caught). CH (0.0086 / 0.0089), BT and RB are
  near equal. The research file says "By catch, though, the gap is the same", which is true; scope the other two the
  same way ("by catch, the gap does not"), or drop the clause. This is round 3's mechanism 2 (a claim over a proxy
  population) in the fix itself.
- **[published claim, FALSE as a universal, low; F1-12]** vignettes/chinook_rearing.Rmd:137: "link cuts a stream at a
  site that caught a species it models". It is the statement round 3 found false as a universal (S1, RE3) and c8d0f96
  corrected to "usually" in segment_gradient_check.R, research and CLAUDE.md; this restatement kept the universal. Its
  consequence ("a site with chinook can start a short segment") is hedged, so the reader is not misled about the
  outcome, but the premise is wrong for about one chinook-present site in five (80.7 % start a segment). "usually cuts".
- **[UNGUARDED in scope, low; H6, F2-24, N28]** vignettes/habitat_thresholds.Rmd:177: "most sites that caught fish
  start a segment of their own" names every placed site that caught fish; the guard (`sg$at_site_fish > 0.5`, :93) is
  over the stream-line, usual-area subset the bundle carries (vignette_method.R:289, 29,335 of 45,529 visits). The
  claim holds on the full population today (79.8 %, measured from data/fdis/derived/visits_link.csv), so this is a
  guard on a narrower population, not a false sentence. Scope the sentence ("most stream-line sites that caught fish",
  as the Limits bullet at :352 already does), or carry the all-placed share in the bundle.
- **[pre-existing claims of the swept facts, low; outside the branch diff]**
  - vignettes/habitat_thresholds.Rmd:174-175 (F1-10): "It also cuts streams where fish have been observed, using
    bcfishobs". link cuts only at observations of the species in each group's presence table, with QA exclusions;
    bcfishobs carries every species. The sentence two lines on (:176) now names "a species link models".
  - CLAUDE.md:347 heading (F4-37): "every reader compares it, not its presence". Its own body (:354-358) lists readers
    that check the gate fields by presence or not at all, and compare_parallel_check.R compares nothing.
  - research/database_builds.md:105 (F4-42): "every grade table carries the flow load and walk md5 its readers
    compare". vignette_method.R compares no walk md5; compare_parallel_check.R neither. This is round 3's Z10 one file
    over.
  - CLAUDE.md:80-83 (F3-35): data/tune/grad_ext/ "nothing that publishes reads them". vignette_chinook.R:180-186 reads
    it into the shipped chinook bundle; by the standard round 3 applied to grad_fwa (Z5, C4), name that reader as the
    new grad_fwa sentence at :213-214 and 0322's header do.

Counts: round 3 rows 18 (17 TRUE now, 1 still UNGUARDED, narrower); fact sweep 47 (39 TRUE, 7 FALSE of which 4
pre-existing and outside the diff, 1 UNGUARDED); new claims 33 (30 TRUE, 2 FALSE, 1 UNGUARDED); code: no bugs.
