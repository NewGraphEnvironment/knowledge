# Code-check round 4: branch 149 (cut-points article), base 0db4bef, HEAD 0dc2059

## Checklist read

- code-check-python.md: in full. No rule applies, because the diff has no Python.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, skipping the table rows and evidence blocks. Of the
  other sections I read two headings: "An assertion that matches an interpolated value cannot see the claim around it"
  and "Documentation Staleness". 21 headings not read.
- code-check-r.md (by heading), 5 read:
  - "Moving prose into a code chunk hides it from tools that scan the document";
  - "A `data-raw/` script must load the source tree, not the installed package";
  - "`tolerance` in testthat is RELATIVE, so it pins a published figure far more loosely than it looks";
  - "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires";
  - "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a presence check can each
    depend on it".

  112 headings not read.
- code-check-spatial.md (by heading), 4 read:
  - "A Freshwater Atlas main stem's downstream end lies on the receiving river's centreline, not at the confluence";
  - "`atan2(0, 0)` is 0, so two points at one place have a bearing of due north";
  - "bcdata: `filter()` translates the calls inside it, so build strings, value lists and transforms before the query";
  - "FWA `upstream_route_measure` misses the next segment's start".

  90 not read.
- code-check-shell.md: none read, because the diff has no shell. 70 not read.

What I ran, all read-only or in the scratchpad:
- rendered a scratch copy of `vignettes/_cut_points.Rmd` at HEAD after `pkgload::load_all()`: no stopifnot failure. I read
  the rendered text sentence by sentence;
- R reads of both bundles, `data/tune/CH_rear_tune.csv`, `CH_rear_summary.csv`, every `data/tune/*_grades_record.csv`
  and every `data/tune/grad_fwa/*_summary.csv`;
- read-only reads of this machine's `data/fdis/derived/visits_link.csv`. This is an older build than the stage, but it
  has the same placement, and I used it only for edge-type and waterbody counts;
- one read-only query of the local fwapg `fwa_edge_type_codes`;
- link's own account of its break sources, from the local `link-441` checkout (0.78.0): `NEWS.md` 0.77.0, the
  `RUNBOOK.md` cut-token table, `R/lnk_pipeline_crossings.R`, `R/lnk_pipeline_break.R`, and
  `configs/default/overrides/user_barriers_definite.csv`;
- `research/minimal_network_tuning.md`, sections "The answer", "The full network on the same flows and range",
  "Chinook rearing on every setup" and "What each break source does".

## Claim enumeration

Lines are those of `vignettes/_cut_points.Rmd` at HEAD. A row passes when its guard or computation covers the set it
names (noun, quantifier, population, unit, cut source) at the precision written. "Holds, unguarded" means the bundle
satisfies the claim but nothing in the article would catch a change. I count those rows as failures here, as the brief
asks.

| # | line | claim (scoping words in bold) | guard / computation | covers? |
|---|---|---|---|---|
| 1 | 127-129 | link maps spawning and rearing; cuts Atlas streams into segments tested against thresholds, one a steepest slope | descriptive, cited | yes |
| 2 | 129-131 | at **a site that caught fish** the slope is **often** worked over a short stretch starting at the catch | premise 44.2 % on 0.78.2, guard `> 5 *` zero | yes ("short" carries no number) |
| 3 | 131 | can move the thresholds tuned from the same catches | hedge | yes |
| 4 | 131-133 | full network 13 %, minimal 9 % | `grad_max ==` guards | yes |
| 5 | 132-133 | minimal network cut **only** where Atlas lines meet, at natural barriers and at steep sections fish cannot pass | link RUNBOOK `min`: access-gradient positions, falls, user-definite barriers, on FWA's segments. 2 of the 227 user-definite barriers are a dam and a mining exclusion | yes (link's own account) |
| 6 | 133-134 | on the minimal records the full rule is not a close call | `!in_reg("published","minimal")` | yes |
| 7 | 134-135 | read through the minimal parent, the records choose 9 % again | `pick ==` minimal pick | yes |
| 8 | 162 cap | stream, receiving stream, town, km, compass | places file; md5 pin; `nrow == 1` | yes |
| 9 | 162 cap | "**Each coloured line** ... with ticks at the segment ends: orange ..., blue ..., **dark grey the whole Atlas line's**" | code: ticks only at the downstream end of full and minimal segments (`sg[sg$network != "atlas", ]`) | **no** (F7) |
| 10 | 162 cap | the Atlas line's runs on past the top of the figure | straight line reaches about 1,101 m at x = 700 against ylim 1,040 | **holds, unguarded** (F8) |
| 11 | 162 cap | black dot = chinook caught, open circle = none; labels at the black dot | guards on `site_seg` | yes |
| 12 | 162 cap | elevation stretched several times | fixed by code (xlim, ylim, figure size) | yes |
| 13 | 184 | slope = drop over length | definition | yes |
| 14 | 185-188 | full network cuts at Atlas line ends, natural barriers, steep sections, "**road and rail crossings**", hand-mapped habitat ends and records | link: `crossings_breaks` reads `<schema>.crossings` = PSCIS + **CABD dams** + modelled crossings | **partial**: the list reads as complete and omits dams (F4) |
| 15 | 187-188 | records of the species it models in each group; each such species' highest record per stream | RUNBOOK qualifier `top`; CLAUDE.md | yes |
| 16 | 189-190 | a site that caught fish is often such a record | premise | yes |
| 17 | 190-192 | concept: 10.8 % over the 90 m above; 3.4 % on a minimal segment from near the mouth past the site | guards | yes |
| 18 | 194 | minimal keeps **only** the first three kinds of cut | RUNBOOK `min` | yes |
| 19 | 194-196 | "So it shows what the slopes would be if **no catch decided where a segment begins**" | guard: fish ≈ zero at-site share (`< 0.01`), which shows no catch is cut **at its own position**. link 0.77.0 NEWS: records still reach the minimal cuts through observation lifts | **no** (F1) |
| 20 | 196-198 | the table counts FDIS visits that start their own segment, within a few metres | `at_site()` | yes |
| 21 | table | caption and the three row labels | RUNBOOK; CLAUDE.md | yes |
| 22 | table | the six percentages | computed; held to the three logs (bundle script, test C1) | yes |
| 23 | 214-215 fn | the 29,335 visits are those "on **stream lines** (not in a river polygon, a wetland of 1 ha or more or a lake of 100 ha or more)" | `stream_branch()`: edge types 1000, 1100, 2000 and 2300 only, then those exclusions | **no**: the words imply lines through smaller lakes and wetlands count, but the edge-type filter drops every line through a lake (construction line 1200) or a wetland (1050, 1150) (F2) |
| 24 | 214 fn | "The 29,335" stated for a table of **three networks** | computed from the minimal rows only. The counts are equal on all three (13,058 / 16,277 each) | **holds, unguarded** (F8) |
| 25 | 215-217 fn | 13,058 with fish of any species, 16,277 with none; window 1 m below to 5 m above | computed; offset = segment start minus visit (`R/link_place.R:102`) | yes |
| 26 | 220-221 | on both full networks, far more likely | `> 5 *` guards | yes |
| 27 | 221-222 | newer network cuts at fewer records and halves the share; minimal takes it away | ratio 0.4-0.6 guard; `< 0.01` | yes |
| 28 | 226-228 | 7,823 visits "in chinook's range, with **no code in the catch that could hide chinook** and **nothing downstream that chinook cannot pass**" | `visits_in`: `status != "blocked"` (an absence blocked by a code; present visits are kept whatever else they caught) and `barrier_dnstr_ch == FALSE` (natural barriers only: gradient, falls, subsurface, user-definite, **before** records lift them) | **no** (F3) |
| 29 | 228 | 235 with chinook | computed; summary `detections` 235 | yes |
| 30 | 228-232 | 10 % against 7 %; 2.6 % against 1.3 % | computed; direction guards | yes |
| 31 | 232-234 | 408 visits on opposite sides of 9 % or 13 %, "the two limits the tuning chose" | computed | yes |
| 32 | 234-235 | only 7 caught chinook; at 309 the full network reads steeper | computed; `< 10`, `> 2 *` | yes |
| 33 | 235-236 | the full network's cuts move the slope at many more visits than chinook visits; which cuts is not said | 408 against 7 (5,288 slopes differ, against 235 chinook visits) | yes |
| 34 | 283-286 | the example selection rule | per-example guards; unique groups; test reproduces the rule | yes |
| 35 | 288 cap | ±600 m window; "a bar that stops short of the left edge stops at the stream's mouth" | sites at 119, 46 and 507 m, each first segment at 0, no gaps | **holds, unguarded** (F8) |
| 36 | 288 cap | boxes coloured and labelled by slope; black line = site; titles | code | yes |
| 37 | 316 | "**The shorter segment** does not always read the steeper slope. On two of the three it does." | guard `sum(full_gradient > minimal_gradient) == 2`, which tests **full**, not shorter. The full segment is the shorter at all three (60/214, 109/764, 201/739 m), and nothing guards that | **holds, unguarded** (F8) |
| 38 | 316-318 | third example: full segment ends 79 m above the site; the steeper water above it is read on its own and averaged by the minimal segment | `above3` guards | yes |
| 39 | 322-325 | held-out score; close call = within one SE of the best; pick = fewest changes, then best score | `in_region` = converged & `ddev_best <= se_diff`; all 6,149 CH rules converged | yes |
| 40 | 326-327 | **every** close call changes all three parts on **every** setup, so the choice is the best scorer | `departures == "3"` on all four; each pick has `ddev_best` 0 (checked) | yes |
| 41 | 327-328 | the definition of disagreement | | yes |
| 42 | 330-332 | four ways on **the same** 4,858 visits (those of 7,823 in groups with both outcomes), same flows and range, **the only differences** | `length(unique(n_visits)) == 1`; `sum(both_out) == n_visits`; research note: same flow load, same installed link, byte-identical outcomes | yes |
| 43 | 332-334 | minimal parent = "the minimal-network segment it lies within"; the whole Atlas line it lies on | tokens; full breaks ⊇ minimal breaks on the four drawn streams; research note | yes |
| 44 | table | setups table cells | computed | yes |
| 45 | 353-354 fn | every rule chosen keeps the same flow floor and allowance; only the slope differs | `unique(sub(...)) == 1` | yes |
| 46 | 354-356 fn | habitat through all of link's steps on the tuned segments; last column against the standard rule on the same segments and slopes | `default_km` differs by setup (102,951 / 104,751 / 104,852 / 103,246) | yes |
| 47 | 359-363 | the four verdicts | guards | yes |
| 48 | 363-366 | 13 other rules with a 13 % limit are close calls on the minimal records | `n_lim()` | yes |
| 49 | 368-371 | 3 of the 6 **other** species and stages both could fit; 2 of them disagree | `ok6`; `n_moved == 3`, `n_out == 2` | yes |
| 50 | 404-405 | Morkill River group, around the Fraser River, 63 km north-west of McBride | places | yes |
| 51 | 405-406 | "**the two rules** a user could run on link's full network" | published and parent. The research note: the Atlas line is "a sensitivity link does not build" | yes |
| 52 | 406-408 | 2,150 km alike; adds 76 km; adds 19 km | `km_cls` | yes |
| 53 | 408-409 | most of each difference on order 3 or less (81 %, 98 %) against 41 % | `> 0.75`, `< 0.5` | yes |
| 54 | 410 | chosen as the most km where the four tunings disagree | `wsg_map` | yes |
| 55 | 412 cap | colour classes; grey = other streams chinook can reach; water shaded | code | yes |
| 56 | 412 cap | "a 15 km grid laid from **the group's south-west corner**" | `bb <- sf::st_bbox(mp$background)`: the bbox of the group's chinook-accessible segments, not of the group | **partial** (F7) |
| 57 | 412 cap | line width follows stream order | code | yes |
| 58 | 443-444 | "**The thresholds this package tuned** on 4 November 2026 were tuned on link's full network, each segment reading its own slope" | the date comes from CH's `tune_run` only. All 7 tracked grade records name `20261104_0543`, `segment_gradient` and `cut-full-top` (checked), but no guard reads even CH's `curve_grad` or `token_cut` | **holds, unguarded** (F8) |
| 59 | 444-447 | CH 13 / 9 / 15 %; floor and allowance hold on **all four** | guards | yes |
| 60 | 449-452 | 86,608 against 87,606 km; 1,042 km, 1.2 %, on the minimal network alone | `transfer` guards | yes |
| 61 | 452-455 | the difference comes from the near-river allowance measured from a segment's downstream end | research note (all but 0.4 km) | yes |
| 62 | 459-461 | "Chinook rearing is the only species and stage tuned on all four ... **The others** were tuned on the two networks' own slopes and ... on the Atlas line each visit lies on" | `other_keys` (6 others fitted); the 22 `grad_fwa` summaries: 6 others scored (WCT underpowered), the other **15** species × stages never fitted (8 no_response, 4 no_stream_rule, 3 not_modelled) | **no** (F5) |
| 63 | 462-463 | minimal drops record, crossing and habitat-end cuts together | RUNBOOK `full` against `min` | yes |
| 64 | 464-466 | of 4,858 scored, 225 cross a chosen limit; 7 caught chinook | `cr_scored` | yes |
| 65 | 466-467 | hedges; fixed-length slopes not tested | | yes |
| 66 | 471-473 | bundled from "the tuning runs and **link builds** ... (link's full network, run 20261103_163715-269b585a; its minimal network, run 20261102_203300-60ab009d)" | the first premise row comes from #92's link 0.66.0 build (`fresh_default_20261017`), a third build the parenthetical omits and `meta` does not record | **partial** (F6) |
| 67 | 473-475 | premise, choices and habitat, and other-species counts each checked against the logs that report them in the research notes | bundle script lines 89-101, 123-131, 161-164; the logs are reached from the research notes (line 204; the `2026110[2345]_*` glob; `habitat_thresholds_tuned.md` for 20261027) | yes |
| 68 | 475-476 | FDIS electrofishing records placed on the Atlas; rules run through fresh | | yes |
| 69 | 481 | each tool cited where first used | accepted tradeoff | n/a |

**69 rows; 12 fail:**
- 5 are wrong or partial as written (19, 23, 28, 62, 14);
- 3 are partial on a figure caption or a provenance list (9, 56, 66);
- 4 hold but are unguarded (10, 24/35 together, 37, 58).

Every sentence that rounds 1-3 rewrote is a row above (rows 5, 14, 15, 18, 21, 23, 28, 42, 49, 56, 66, 67). Three of
round 3's fixes fail again on another axis:
- the footnote's waterbody list (row 23);
- the 7,823 population (row 28);
- the grid caption (row 56).

## Findings

- **[severity: bug]** vignettes/_cut_points.Rmd:194-196. "link's minimal network keeps only the first three kinds of
  cut ... So it shows what the slopes would be if no catch decided where a segment begins."
  - link's own account of the minimal bundle contradicts the claim. NEWS 0.77.0 (#415) says that, on `default_minimal`,
    "Records still reach the cuts through observation lifts: a barrier lifted for a species is no longer that species'
    cut, though another species' barrier or a falls may still cut there, and positions above it can become cuts."
  - So catches do decide where some minimal segments begin.
  - The guard (`abs(fish - zero) < 0.01` on the at-site share) supports the narrower claim the code measures: no catch
    is cut at its own position, so a segment's start no longer depends on the visit's outcome.
  - The full network uses the same lifts, so the article's comparison still holds. The sentence as written does not.
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** vignettes/_cut_points.Rmd:214-215 (and 226-227, "on those stream lines"). The footnote reads
  "stream lines (not in a river polygon, a wetland of 1 ha or more or a lake of 100 ha or more)". Read that way, a
  visit on a line through a 20 ha lake or a 0.5 ha wetland would count.
  - `stream_branch()` first keeps only edge types 1000, 1100, 2000 and 2300 (`knw_tune_run()`'s `edge_stream`):
    single-line blueline main and secondary flow, and canals.
  - That drops every construction line through a lake (1200) and every line through a wetland (1050, 1150), whatever
    their size.
  - On this machine's older derived build, inside the fished-area range:
    - 314 visits on edge 1200: 262 of them not in a lake of 100 ha or more, 229 of those in a smaller lake;
    - 1,172 visits on 1050/1150: 112 of them not in a wetland of 1 ha or more.

    The footnote's words would count all of these; the code excludes all of them.
  - Inside the kept edge types, the waterbody exclusions still bite: 457 visits on edge 1000 lie in a wetland of 1 ha
    or more, and none in any lake.
  - Round 3's F4 premise ("lines through smaller lakes and wetlands are counted") was itself wrong, and its fix wrote
    that premise into the footnote. Describe the edge-type filter, for example "single-line streams and canals (no
    lines through lakes, wetlands or rivers), not in a river polygon or a wetland of 1 ha or more".
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "One fact derived twice"

- **[severity: fragile]** vignettes/_cut_points.Rmd:226-228. The 7,823 visits are described as "with no code in the
  catch that could hide chinook and nothing downstream that chinook cannot pass". Two parts of that do not match the
  code.
  - **"nothing downstream that chinook cannot pass"**: `barrier_dnstr_ch` (`R/link_barrier_dnstr.R`) tests only the
    natural sources (`GRADIENT`, `FALLS`, `SUBSURFACE_FLOW`, `USER_DEFINITE`), and tests them *before* records lift
    them.
    - A visit above a dam or an impassable crossing is kept.
    - A visit above a natural barrier that chinook records show they pass is dropped.
    - The words name access as link grants it; the code names natural barriers before lifts. `R/tune_run.R:10-13`
      states it precisely: "no natural barrier to the species downstream before observation overrides".
  - **"no code in the catch that could hide chinook"**: `status == "blocked"` is set only for an absence
    (`R/fdis_species.R:120`, `!present[k] && ...`). A visit that caught chinook is kept whatever other codes it
    caught, so some of the 235 may carry such a code. This part is small.
  - This sentence was rewritten in round 3 (F4).
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:185-187. The full network's cut sources are listed as "where one
  Atlas line meets the next, at natural barriers and at the steep sections ..., and also at road and rail crossings, at
  the ends of stretches whose habitat has been mapped by hand, and at records". The list reads as complete.
  - link cuts at every row of `<schema>.crossings` (`R/lnk_pipeline_break.R:285-293`).
  - That table is the union of PSCIS, CABD dams and modelled crossings (`R/lnk_pipeline_crossings.R`,
    `.lnk_crossings_union()`). So dams are cut too, and the list omits them.
  - The Limits bullet (462) says "crossings" and holds. This is the same cut-source axis as round 3's F1.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:459-461. "Chinook rearing is the only species and stage tuned on
  all four of the ways above. The others were tuned on the two networks' own slopes and, in a separate check, on the
  Atlas line each visit lies on".
  - "The others" are the other species and stages. The tuning's own records hold 22 keys
    (`data/tune/grad_fwa/*_summary.csv`). Of the 21 others, only 6 were fitted on either network (`other_keys`, and the
    6 non-CH fitted rows of those summaries).
  - The other 15 were never tuned at all: 8 `no_response`, 4 `no_stream_rule` and 3 `not_modelled`. Rainbow trout
    rearing is `not_modelled`, and is on neither build.
  - The quantifier needs "the six others that could be fitted" (as line 369 has it).
  - Lesser point: "but not on the minimal parent's slope" implies that the parent was the only way the six missed.
    Their Atlas run reads `fwa_gradient`, the visit's own line. Chinook's fourth way reads `segment_fwa_gradient`. The
    research note says the two differ at 732 visits, 136 of them across a 13 % limit.
  - **Rule:** code-check.md "An assertion that matches an interpolated value cannot see the claim around it" ;
    code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:471-473. "The numbers were bundled ... from the tuning runs and
  link builds the research notes describe (link's full network, run 20261103_163715-269b585a; its minimal network, run
  20261102_203300-60ab009d)."
  - The parenthetical names the builds and lists two.
  - The premise table's first row ("link 0.66.0, full network") comes from #92's build (`fresh_default_20261017`,
    staged as `evidence/published_92`). The parenthetical omits it.
  - `x$meta` carries only `link_run_full` and `link_run_minimal`, so the article cannot name the third build. The
    article reports two full networks; the parenthetical gives "link's full network" one run.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** vignettes/_cut_points.Rmd:162 and 412 (two figure captions that state what the code does not
  draw or compute).
  - **Profile (162).** "Each coloured line is a segment ... with ticks at the segment ends: orange the full network's,
    blue the minimal network's, dark grey the whole Atlas line's". The ticks (`geom_point(data = sg[sg$network !=
    "atlas", ], aes(x = from_m, ...), shape = 124)`) are drawn only at the downstream end of each full and minimal
    segment. The Atlas lines get none.
  - **Map (412).** "of a 15 km grid laid from the group's south-west corner". The grid's origin is
    `sf::st_bbox(mp$background)`: the corner of the bounding box of the group's chinook-accessible segments, not of the
    group. This is round 3's F6 fix restated more precisely than the code; the code comment at 389 says the same.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:162, 214, 288, 316, 443-444. These claims hold on today's bundle,
  but no guard covers the set or quantity their words name. A rebuilt bundle could falsify any of them under a green
  render:
  - **316**: "The shorter segment does not always read the steeper slope. On two of the three it does." The guard
    counts `full_gradient > minimal_gradient`, so it tests the full network, not the shorter segment. The full segment
    is the shorter at all three, unguarded. Pinning it needs
    `all(vapply(ex, function(e) e$site$full_length_m < e$site$minimal_length_m, TRUE))`.
  - **443-444**: "The thresholds this package tuned on 4 November 2026 were tuned on link's full network, each segment
    reading its own slope". The date comes from chinook rearing's `tune_run`, and nothing reads `curve_grad` or
    `token_cut` even for it (`s_of("published")$curve_grad == "segment_gradient"`, `token_cut == "cut-full-top"`). The
    other keys' records are not in the bundle at all. They agree today: all 7 tracked grade records name
    `20261104_0543`, `segment_gradient` and `cut-full-top`.
  - **214**: "The 29,335 electrofishing visits" is stated for a table of three networks but computed from the minimal
    rows only. The three networks' counts are equal, but nothing checks that.
  - **162**: "the whole Atlas line's, which runs on past the top of the figure" depends on the concept line's gradient
    against `ylim = 1040`. Today the line reaches about 1,101 m at x = 700.
  - **288**: "a bar that stops short of the left edge stops at the stream's mouth" depends on the three windows having
    no gap and starting at measure 0. Today they do.
  - **Rule:** code-check.md "An assertion that matches an interpolated value cannot see the claim around it" ;
    code-check.md "A proxy is not the property"

- **[severity: fragile]** data-raw/README.md:41-42 and data-raw/vignette_cut_points.R:12-15. Round 3's F5 was fixed
  in the article only.
  - The README still says the script "holds each number a log first reported (the premise, the setups, the transfer,
    the other species' counts) to that log".
    - The setups' picks and km were first reported by their own tune-run and comparison logs (round 3, F5), not by
      `20261105_setup_compare-ch_rear.csv`, the file they are held to.
    - The transfer is held only through `minimal_km` and `parent_km` against that csv.
  - The script header's "EACH NUMBER A LOG PUBLISHED IS HELD TO THAT LOG" fails the same way:
    - `scripts/logs/habitat/20261105_setup_compare-ch_rear.txt:65-67` publishes `minimal_only_km` 1041.738 and
      `parent_only_km` 43.50613;
    - the article prints the first as "1,042 km";
    - neither is compared with the log (`data-raw/vignette_cut_points.R:143-151` checks only `minimal_km` and
      `parent_km`).
  - The values agree today; the two comments claim a check that is not made.
  - **Rule:** code-check.md "Written data outlives the fix" ; code-check.md "A guard's scope, escape hatches, and
    remedies"

No other code defect found in the branch. Specifically:
- the bundle and places scripts read `attr(out, "status")` from `system2()`;
- `vignette_cut_points.R` loads the source tree unconditionally; the places script calls no `knowledge` function;
- the places queries' `LIMIT 1` picks read one main stem's name or end on a unique order;
- the tests compare km under a relative tolerance of 1e-9 and reproduce the example selection independently of the
  bundle script;
- the article renders at HEAD with every `stopifnot()` passing.
