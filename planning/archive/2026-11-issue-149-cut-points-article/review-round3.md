# Code-check round 3: branch 149 (cut-points article), base 0db4bef, HEAD 24c00e2

## Checklist read

- code-check-python.md: in full. No rule applies, because the diff has no Python.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, skipping the table rows and the evidence blocks. Of the
  standalone rules I read one: "An assertion that matches an interpolated value cannot see the claim around it".
  21 standalone headings not read.
- code-check-r.md (by heading), 3 read: "Postgres row order is never fixed unless the query fixes it, so a pick, a float
  sum and a presence check can each depend on it"; "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising,
  so a `tryCatch(error =)` around it never fires"; "`tolerance` in testthat is RELATIVE, so it pins a published figure far
  more loosely than it looks". I checked their call sites: the stage's map-group query and the places queries, the
  `git()` helpers, and the vignette-data tests. 114 headings not read.
- code-check-spatial.md (by heading), 3 read: "A Freshwater Atlas main stem's downstream end lies on the receiving
  river's centreline, not at the confluence" (the places script's mouth only sets a town distance, so it is harmless
  here); "`atan2(0, 0)` is 0, so two points at one place have a bearing of due north" (a town is never at the place);
  "bcdata: `filter()` translates the calls inside it, so build strings, value lists and transforms before the query"
  (the places script filters on a literal). 91 not read.
- code-check-shell.md: none read. The diff has no shell. 70 not read.

What I ran, all read-only:
- rendered a scratch copy of `vignettes/_cut_points.Rmd` after `pkgload::load_all()`, with no stopifnot failure, and read
  the rendered text;
- R reads of both bundles, `inst/vignette-data/method.rds`, `data/tune/*_grades_record.csv` and the tune-run logs;
- one read-only query of the local fwapg database for the Atlas line ends on the three example blue lines;
- `NOT_CRAN=true` `test_file("tests/testthat/test-vignette-data.R")`: the only failures are the 5 known ones, in the
  methodology-evidence test.

## Mechanism

All eleven earlier findings share one shape. Each sentence was written first, from the author's account of the work.
That account is mostly `research/minimal_network_tuning.md`, written by the same hand from the same runs. A guard was
then attached to the number the sentence interpolates. The guard pins the value (13 %, 7, 4,858, 4 of 7). It does not pin
the words that say what the value is about:

- the noun: sites against visits, fish against chinook;
- the quantifier: every, each, only, "the others", "the fewest";
- the population: 7,823 against 4,858, the minimal network against the minimal parent;
- the unit: a slope limit against a rule.

A green render therefore proves only that the numbers are what they are. Those scope words were never executed against
the data. The research note cannot corroborate them, because it carries the same framings ("cut only at barriers and
access", "every published threshold"), so it shares an ancestor with the article. This is code-check.md "An assertion
that matches an interpolated value cannot see the claim around it", applied to prose. The compression direction that
"A guard's scope, escape hatches, and remedies" warns about is the same thing: a sentence gains a quantifier the source
did not measure.

This round's two bugs are the same mechanism again:
- "cut only at natural barriers and at the steep sections" is the research note's line 25, carried over with no guard.
  The staged segments contradict it.
- The guard for "other species' rules ... 4 of the 7" asserts that `CH_rear` is one of the four. So the code knew what
  the sentence's frame ("other species") denies.

## Claim enumeration

A row passes when its guard or computation covers the set at the precision written. "Holds, unguarded" means I checked
the bundle and it holds, but nothing in the article would catch a change.

| # | line | claim | set or quantity named | guard / computation | covers? |
|---|---|---|---|---|---|
| 1 | 124-126 | link maps spawning and rearing; cuts Atlas streams into segments tested against thresholds, one a steepest slope | link's design | descriptive, cited | yes |
| 2 | 126-128 | at a site that caught fish the slope is often worked out over a short stretch starting at the catch | fish visits (any species), 0.78.2 full network | premise 44.2 % at the site; `pm_at(145, fish) > 5 * zero` | "often" yes; "short" is not computed (medians 305 m against 466 m), but it is an adjective with no number. Pass |
| 3 | 128 | that can move the thresholds tuned from the same catches | hedged | setups | yes |
| 4 | 128-130 | full network 13 %, minimal 9 % | CH rear picks | `grad_max ==` guards | yes |
| 5 | 130 | minimal network "cut only at natural barriers and at the steep sections fish cannot pass" | the minimal network's cut sources | none (research L25 wording) | **no**: minimal segments also end at each Atlas line end (F1) |
| 6 | 130-131 | on the minimal network's records the full network's rule is not a close call | `in_region` | `!in_reg("published","minimal")` | yes |
| 7 | 131-132 | read through the minimal parent, the records choose 9 % again | parent pick | `pick == minimal pick` | yes |
| 8 | 159 cap | the stream, what it flows into, the town, km and compass | places file | computed; bundle md5 identity, `nrow == 1` | yes |
| 9 | 159 cap | grey band = elevation along the Atlas line; coloured lines = each segment's straight slope with end ticks; the Atlas line's runs past the top | profile geometry | `z_dn` / `z_up`; I checked Δz/length = gradient (31177: 0.1083; 703534204: 0.1578); the Atlas line reaches about 1,101 m at x = 700, above ylim 1,040 | holds, unguarded |
| 10 | 159 cap | black dot = chinook caught, open circle = none; labels give the slope at the black dot | `cc$sites` (2 visits), `site_seg` | guards on `site_seg` | yes |
| 11 | 159 cap | elevation stretched several times | aspect | about 7x | yes |
| 12 | 181 | a segment's slope is its drop over its length | definition | | yes |
| 13 | 182-184 | full network cuts at barriers, steep sections, crossings, ends of hand-mapped habitat and fish records | the full network's cut sources | none | **partial**: the list reads as complete but omits Atlas line ends (F1) |
| 14 | 184 | "each species' highest record on each stream" | 0.78.2 record cuts | CLAUDE.md, link#396 | **partial**: only the species link models in the group (F3) |
| 15 | 185-186 | a site that caught fish is often such a record, so the cut lands at the site | 44.2 % | premise guard | yes |
| 16 | 186-188 | concept: 10.8 % over the 90 m above; minimal 3.4 %, segment from near the mouth past the site | concept segments | `from_m` at the site, gradients, `minimal from_m < 50` | yes |
| 17 | 190 | the minimal network keeps only the first kind of cut | the minimal network's cut sources | none | **no** (F1) |
| 18 | 190-191 | so it shows the slopes if no catch decided where a segment begins | premise, minimal | `abs(fish - zero) < 0.01` | yes |
| 19 | 191-193 | the table counts FDIS electrofishing visits that start their own segment, within a few metres | `at_site` -1..5 | computed | yes |
| 20 | 196-198 | row labels "every fish record a cut", "each species' highest record a cut", "barriers and steep sections only" | cut sources per build | none | **no** for row 3 (F1); **partial** for rows 1-2 (F3) |
| 21 | table | the six percentages | `premise` | checked against the three logs (bundle script, test C1) | yes |
| 22 | 209-210 | 29,335 visits "of a usual fished area on ordinary stream lines (not lines through rivers, lakes or wetlands)", 13,058 with fish of any species, 16,277 without | `stream_branch()`, minimal rows, labelled for the whole table | computed; counts identical on all three networks (checked, unguarded) | **partial**: lakes under 100 ha and wetlands under 1 ha stay in (F4) |
| 23 | 212 | a visit starts its own segment when its segment begins between 1 m below and 5 m above it | offset = segment start minus site | `at_site()` | yes |
| 24 | 215-216 | on both full networks a fish visit is far more likely to start its own segment | premise | `> 5x` guards | yes ("site" for visit is residual wording only) |
| 25 | 216 | the newer full network cuts at fewer records and halves the share | ratio 0.51 | 0.4-0.6 guard | yes |
| 26 | 216-217 | the minimal network takes the difference away | 3.4 against 3.0 | `< 0.01` | yes |
| 27 | 221-222 | the tuning starts from 7,823 visits "on stream lines in chinook's range with nothing downstream that chinook cannot pass", 235 with chinook | `x$sites` (visits_in) | counts computed; logged 7823/235 | **partial**: the counted set also requires a fished area within range and absence not blocked, and excludes only large lakes and wetlands (F4) |
| 28 | 222-226 | shares over 9 %: 10 against 7 % without chinook, 2.6 against 1.3 % with | `steep()` on 7,823 | computed; direction guards | yes |
| 29 | 226-228 | 408 visits on opposite sides of 9 % or 13 % on the two networks, "the two limits the tuning chose" | `cr` on `minimal_gradient` | computed | yes (the two networks' limits) |
| 30 | 228 | only 7 caught chinook; at 309 the full network reads steeper | `cr` | `< 10`, `> 2x` guards | yes |
| 31 | 229-230 | the full network's cuts move the slope at many more visits than chinook visits; which cuts is not shown | 408 against 7 | computed | yes |
| 32 | 277-280 | the example selection rule | bundle `ex_sites` | per-example guards plus unique groups; the test reproduces the rule; candidates UFRA, KLUM, LNAR, LSKE, COTR give KLUM, LNAR, LSKE | yes |
| 33 | 282 cap | ±600 m window; a bar short of the left edge stops at the mouth | the three windows | sites at measures 119, 46, 507 m, each first segment at 0 | holds, unguarded |
| 34 | 282 cap | boxes are segments coloured and labelled by slope; black line = site; titles name stream, receiving stream, town | `strip` | code | yes |
| 35 | 310 | the shorter segment does not always read steeper; it does on two of three | `steeper` | `sum == 2`; the full segment is shorter in all three (60/214, 109/764, 201/739 m), unguarded | holds |
| 36 | 311-312 | on the third, the full segment ends 79 m above the site; the steeper water above it is read on its own and averaged in by the minimal segment | LNAR | `above3` guards | yes |
| 37 | 316-319 | scoring on held-out groups; close call = within one SE of the best; pick = fewest departures, then best score | method | `knw_tune_repick()` order(dep, dev); methodology article | yes |
| 38 | 320-321 | every close call changes all three parts on every setup, so the choice is the best scorer | `departures` | `all(departures == "3")` on all four tunes | yes |
| 39 | 321-322 | definition of disagreement | | | yes |
| 40 | 324-326 | four tunings on the same 4,858 visits (those of the 7,823 in groups with both outcomes), same flows and range | `n_visits`, `both_out` | `length(unique(n_visits)) == 1`, `sum(both_out) == n_visits` | count, not set identity; flows and range rest on the research note. Pass |
| 41 | 326-328 | two read slopes from another source: the minimal parent and the whole Atlas line | `token_grad` grad-parent, grad-fwa | records | yes |
| 42 | table | setups table values and close-call cells | `su`, `in_reg` | computed | yes |
| 43 | 347-348 fn | every rule chosen keeps the same flow floor and allowance; only the limit differs | picks | `unique(sub(...)) == 1` | yes |
| 44 | 348-350 fn | habitat from all of link's steps on the tuned segments over CH groups; last column against the standard rule on the same segments and slopes | compare csv ALL row | per-setup `default_km` | yes |
| 45 | 353-357 | 13 % not a close call on the minimal records; 9 % a close call on the full; parent = minimal exactly; Atlas 15 % a close call on neither | picks, regions | guards | yes |
| 46 | 357-360 | 13 other rules with a 13 % limit are close calls on the minimal records, differing in flow floor or allowance | `n_lim()` | count exact; difference by construction | yes |
| 47 | 362-364 | "moves other species' rules as well ... 4 of the 7 ... 3 of them" | other species and stages | `n_moved`, `n_out` over all 7 keys including `CH_rear` (guard asserts it) | **no**: other keys are 3 of 6 moved and 2 of 6 outside (F2) |
| 48 | 362 | tuned on the same flows and range | | research note | yes |
| 49 | 398-399 | Morkill River group, around the Fraser River, 63 km north-west of McBride | places map row | computed | yes |
| 50 | 399-402 | 2,150 km alike; adds 76 km; adds 19 km | `km_cls` | computed; ordering guards | yes |
| 51 | 402-403 | most of each difference on order 3 or less (81 %, 98 %) against 41 % shared | `small` | guards `> 0.75`, `< 0.5` | yes |
| 52 | 404 | group chosen as the most km where the four tunings disagree | `wsg_map` from pattern not in (every setup, none) | code | yes |
| 53 | 406 cap | the colour classes; grey = other streams chinook can reach; lakes of 10 ha or more and river polygons shaded | `lv`; `map_bg` = published comparison's `accessible`; stage water query | code | yes |
| 54 | 406 cap | "the 15 km square outlined above, the one holding the most km drawn by one rule and not the other (9 km)" | the zoom | best cell of a fixed grid anchored at the background's south-west corner, segments counted whole by centroid | **partial** (F6) |
| 55 | 406 cap | line width follows stream order | `lwd` | code | yes |
| 56 | 437-438 | the thresholds tuned on 4 November 2026 were tuned on the full network's own slopes | all published keys | date from CH's run; all 7 tracked grade records name `20261104_0543`, `segment_gradient`, `cut-full-top` (checked) | holds, unguarded |
| 57 | 438-441 | for CH the same records choose another rule on another network or slope reading: 13 / 9 / 15 %; flow floor and allowance hold on all four | setups | guards | yes |
| 58 | 443-445 | run through parent slopes it draws 86,608 against 87,606 km; 1,042 km (1.2 %) on the minimal network alone | `transfer` | `parent_km` match, `< 0.02` guard; bundle checks the gpkg against the csv | yes |
| 59 | 446-449 | the difference comes from the near-river allowance measured from a segment's downstream end | transfer | cited research note ("all 1,042 km fails the flow floor") | yes (cited) |
| 60 | 453-455 | CH is the only key tuned all four ways; the others on both networks' own slopes and on the visit's Atlas line, not on the parent | the 6 other fitted keys | `other_keys` (6 others); the grad_fwa log tunes all 6 (WCT underpowered; RB not modelled) | yes |
| 61 | 456-457 | the minimal network drops fish-record, crossing and habitat-end cuts together; cannot say which | | research L278 | yes |
| 62 | 458-460 | of the 4,858 scored, 225 cross a chosen limit between the networks; 7 caught chinook | `cr_scored` | `sum(both_out) == n_visits`; computed | yes |
| 63 | 460-461 | the network moves the choice, not which visits; fixed-length slopes not tested | hedges | | yes |
| 64 | 465-467 | bundled 2026-11-05; link run ids | `meta` | | yes |
| 65 | 467-469 | premise, choices and habitat, and other-species counts each "checked against the run log that first reported them" | bundle-script checks | premise against the three segment-gradient logs (first reports); other keys against `pick_network_compare.csv`; choices and km against `setup_compare-ch_rear.csv`, a 2026-11-05 collation | **partial**: "first reported" fails for the choices and habitat (F5) |
| 66 | 469-471 | FDIS electrofishing records placed on the Atlas; rules run through fresh | | | yes |
| 67 | 475 | each tool is cited where first used | | accepted tradeoff per the brief | n/a |

## Findings

- **[severity: bug]** vignettes/_cut_points.Rmd:130, 182-184, 190, 198. The minimal network is called "cut only at natural
  barriers and at the steep sections fish cannot pass" and said to keep "only the first kind of cut". The premise
  table's row label repeats it ("barriers and steep sections only").
  - The staged segments show minimal segments also end at every Atlas line end:
    - concept stream (bundle `concept$segments`): minimal breaks at 13.80, 3,010.08 and 3,462.87 m equal the Atlas line
      ends. Two of those breaks fall between gentle slopes (0 to 3.4 %, 7.5 to 5.4 %), so neither can be a steep-section
      cut;
    - KLUM example: minimal breaks at 70.75, 284.54, 576.87, 591.38 and 1,237.34 m are all Atlas line ends (local
      `fwa_stream_networks_sp`). The minimal segment 70.75-284.54 m is exactly one Atlas line, which is why that
      example's parent and Atlas slopes are equal (0.0561);
    - LNAR example: 15.73, 809.09, 1,258.23, 1,364.12, 1,440.12 and 1,454.71 m, likewise.
  - The full network's list of cut sources (182-184) omits the Atlas line ends too, though it reads as complete.
  - No guard covers either sentence. The wording is `research/minimal_network_tuning.md` line 25's.
  - The premise conclusion ("no catch decided where a segment begins") still holds. The definition is wrong as written,
    and it misleads a reader comparing the minimal parent with "the whole Atlas line it lies on".
  - **Rule:** code-check.md "A proxy is not the property" ; code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: bug]** vignettes/_cut_points.Rmd:362-364. "The network moves other species' rules as well. ... the full
  and minimal networks choose different rules for 4 of the 7 species and stages both could fit, and for 3 of them one
  network's choice is not a close call on the other's records."
  - `n_moved` and `n_out` count all seven keys, chinook rearing included. The guard at line 101 even asserts
    `"CH_rear" %in% ok$key[ok$network_moved != "same"]`.
  - The sentence's subject is the other species. For them the counts are 3 of 6 moved (BT_rear, BT_spawn, ST_rear) and 2
    of 6 with a pick outside the other network's region (BT_rear, BT_spawn).
  - As written, a reader takes it that four other keys moved.
  - **Rule:** code-check.md "An assertion that matches an interpolated value cannot see the claim around it" ;
    code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:184, 196-197. Record cuts are described as "every fish record a cut"
  (link 0.66.0) and "each species' highest record on each stream" (0.78.2).
  - link cuts at the bcfishobs records of the species it models in each group (CLAUDE.md, "The tuning scores link's
    segment gradient ..."), not at every fish record.
  - Meanwhile the table's "visits with fish" are visits that caught any species.
  - The scope gap is part of why the 0.66.0 share is 86.2 % and not near 100 %. The label states a population the build
    did not cut at.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:209-210, 221-222. The two population descriptions do not match the
  filters that produce their counts (`knw_tune_run()`'s population, R/tune_run.R:8-13 and 135-174; the bundle's
  `stream_branch()`).
  - The footnote says "not lines through rivers, lakes or wetlands". The code excludes river polygons, wetlands of 1 ha
    or more and lakes of 100 ha or more, so lines through smaller lakes and wetlands are counted.
  - The 7,823 are described as "visits on stream lines in chinook's range with nothing downstream that chinook cannot
    pass". The counted set also requires a fished area within `area_range` and an absence not blocked
    (`status != "blocked"`).
  - Both counts are exact. The words name a different, larger set.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:467-469. "When the bundle was written, ... the four tunings' choices
  and habitat ... were each checked against the run log that first reported them."
  - `data-raw/vignette_cut_points.R:123-131` checks them against `scripts/logs/habitat/20261105_setup_compare-ch_rear.csv`.
    That is `setup_compare.R`'s collation, written on 2026-11-05.
  - Each pick was first reported by its own tune-run log, and each habitat total by its comparison run: 20261103_0838
    (minimal), 20261104_0543 (published), 20261105_0436 and 0437 (parent, Atlas).
  - The premise and other-keys halves of the sentence hold. "first reported" does not hold for the choices and habitat.
    This is the axis round 1 fixed ("each number was checked against the logs"), now as a provenance superlative.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** vignettes/_cut_points.Rmd:406 (computed at 383-395). The map caption calls the zoom "the 15 km
  square outlined above, the one holding the most km drawn by one rule and not the other (9 km)".
  - The code picks the best cell of one fixed 15 km grid anchored at the background's south-west bbox corner.
  - It assigns each segment's whole length to the cell holding its centroid.
  - So it is the best grid cell by centroid, not the best 15 km square, and the 9 km is not clipped to the square. The
    code comment says so; the caption states the broader superlative.
  - **Rule:** code-check.md "A proxy is not the property"

No code defect found elsewhere in the branch. Specifically:
- the stage and bundle queries end their `ORDER BY` on unique keys;
- the `git()` helpers read `attr(out, "status")`;
- the vignette-data tests reproduce the example selection independently of the bundle script;
- the stage md5 test resolves its paths from the repo root.
