# Code-check round 5: branch 149 (cut-points article), base 0db4bef, HEAD c34d45c

## Checklist read

- code-check-python.md: read in full. No rule applies, because the diff has no Python.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, skipping table rows and evidence blocks. Of the
  standalone rules I read one: "An assertion that matches an interpolated value cannot see the claim around it".
  22 standalone headings not read.
- code-check-r.md (by heading), 3 read:
  - "`tolerance` in testthat is RELATIVE, so it pins a published figure far more loosely than it looks";
  - "Moving prose into a code chunk hides it from tools that scan the document";
  - "A `data-raw/` script must load the source tree, not the installed package".

  114 headings not read.
- code-check-spatial.md: none read. Its index has no tmap or scale-bar heading, and the spatial code is unchanged
  since round 4 read the 4 relevant headings. 94 not read.
- code-check-shell.md: none read, because the diff has no shell. 70 not read.

What I ran, all read-only or in the scratchpad:
- I rendered a scratch copy of `vignettes/_cut_points.Rmd` at HEAD after `pkgload::load_all()`. No `stopifnot()`
  failed. I read the rendered text and the three PNGs, and measured the map PNG's pixels.
- R reads of both bundles, of `inst/vignette-data/method.rds` (`gradient_sensitivity`, `funnel_species`), of
  `data/tune/*_summary.csv`, `data/tune/grad_fwa/*_summary.csv` and `data/thresholds.csv`.
- I read link's cut-token table in `RUNBOOK.md` (local `link-441` checkout, 0.78.0), `research/minimal_network_tuning.md`
  (whole file to line 360) and `vignettes/habitat_thresholds.Rmd`'s `#steps`, `#lost` and `#limits`.
- `NOT_CRAN=true` `test_file("tests/testthat/test-vignette-data.R")`: 1 failing test, 5 expectations, all in the
  known environmental methodology-evidence test.

## Claim enumeration

Line numbers are those of `vignettes/_cut_points.Rmd` at HEAD. "Covers?" is yes when the guard, the computation or the
linked source covers the set the sentence names, at the precision written. The rows rounds 1-4 rewrote are marked R.

| # | line | claim (scoping words in bold) | backing | covers? |
|---|---|---|---|---|
| 1 | 131-133 | link maps spawning and rearing; it cuts Atlas streams into segments tested against a few thresholds, one of them a steepest slope | descriptive, cited | yes |
| 2 | 133-135 | some cuts fall where fish were caught, so at **a site that caught fish** the slope is **often** worked over a short stretch from the catch | premise 44.2 % on 0.78.2; guard `> 5 *` zero | yes |
| 3 | 135 | that **can** move the thresholds | hedge | yes |
| 4 | 135-136 | full network, chinook rearing: 13 % | `grad_max == 0.13` | yes |
| 5 R | 136-137 | the minimal network "**drops** the cuts at crossings, at hand-mapped habitat and at fish records" | link RUNBOOK: `full` minus `min` is observations, habitat end points, crossings, exactly | yes |
| 6 | 137 | minimal: 9 % | guard | yes |
| 7 | 137-138 | on the minimal records the full network's rule is not a close call | `!in_reg("published","minimal")` | yes |
| 8 | 138-139 | read through the minimal-network slope, the records choose 9 % **again** | `pick == pick` | yes |
| 9 | 167 cap | stream name, receiving stream ("flowing into" from `joins_direct` TRUE), 40 km east of McBride | places file; md5 pin; `nrow == 1` | yes |
| 10 | 167 cap | grey band = elevation along the Atlas line | code | yes |
| 11 R | 167 cap | each coloured line a segment drawn as its straight slope; ticks at the ends of the full and minimal segments | `geom_point(from_m)` on full and minimal only; every segment end in 0-700 m is some segment's `from_m` (0, 13.8, 489, 494, 584) | yes |
| 12 R | 167 cap | the Atlas line runs past the top of the figure | guard `z_up > 1040`; it reaches about 1,101 m at x = 700 | yes |
| 13 | 167 cap | black dot = chinook caught; open circle = none; labels at the black dot | `cc$sites$present` TRUE / FALSE; guards | yes |
| 14 | 167 cap | elevation stretched several times | code | yes |
| 15 | 189 | slope = drop over length | definition | yes |
| 16 R | 190-191 | **both** networks cut where Atlas lines meet, at natural barriers and at steep sections a species cannot pass | RUNBOOK: both sets hold access-gradient positions, falls, user-definite barriers | yes |
| 17 R | 191-194 | the full network adds cuts, "**among them**" crossings, habitat-mapping ends and records; each such species' highest record per stream, from bcfishobs | RUNBOOK `full`, `top` | yes |
| 18 | 195-196 | a site that caught fish is **often** such a record, so the cut lands at the site | premise | yes |
| 19 | 196-198 | concept: 10.8 % over the 90 m above it; 3.4 % on a minimal segment running from near the mouth past the site | guards `from_m < 1`, `from_m < 50`, gradients | yes |
| 20 | 200-202 | the table counts FDIS visits (a site fished on one occasion) that start their own segment, within a few metres | `at_site()`; footnote | yes |
| 21 | 205-207 | table row labels: 0.66.0 every record a cut; 0.78.2 highest record per stream; 0.78.1 no crossings, mapped habitat or records | RUNBOOK; research note table; script's `premise$link` | yes |
| 22 | 209-212 | the six percentages | computed; held to the three logs | yes |
| 23 | 215 | caption: three of link's networks | code | yes |
| 24 R | 218-219 | "**The same** 29,335 visits **on each network**" | guard: equal counts per outcome on all three; research note: the same visits placed | yes |
| 25 R | 219 | "those of a usual fished area on the stream lines the tuning scores" | `stream_branch()` is `knw_tune_run()`'s own filter (formals read); the methodology funnel gives 29,335 for "fished area" | yes |
| 26 | 219-221 | 13,058 with fish **of any species**, 16,277 with none; window 1 m below to 5 m above | computed | yes |
| 27 | 224-225 | on **both** full networks fish sites are far more likely to start their own segment | `> 5 *` guards | yes |
| 28 | 225-226 | the newer network cuts at fewer records and halves the share; the minimal network takes the difference away | RUNBOOK `top`; ratio 0.4-0.6; `< 0.01` | yes |
| 29 R | 230-231 | 7,823 "**of those visits**, the ones in chinook's range that pass its other filters ([which visits](habitat_thresholds.html#steps))" | the number: `sites`, which the methodology funnel matches (29,335 down to 7,823). The **link**: `#steps` names no species filter; `#lost` does ("where link expects the species, with no code that could hide it and no natural barrier to it downstream") | **no** (F2) |
| 30 | 231 | 235 of them with chinook | computed | yes |
| 31 | 231-235 | 10 % against 7 %; 2.6 % against 1.3 % | computed over the 7,823 | yes |
| 32 | 235-237 | 408 visits on opposite sides of 9 % or 13 %, "the two limits the tuning chose" | computed; `crit$limits` (0.09, 0.13) equal the minimal and published `grad_max` in the bundle | yes |
| 33 | 237-238 | only 7 caught chinook; at 309 the full network reads steeper | computed; `< 10`, `> 2 *` | yes |
| 34 | 238-239 | cuts move the slope at many more visits than those with chinook; which cuts is not said | 408 against 7 | yes |
| 35 | 291-294 | example selection rule (chinook, crossing on parent = minimal, segment of at least 50 m, outside the concept's group, largest gap per group, 3 groups) | per-example guards; unique groups; test reproduces the rule | yes |
| 36 R | 296 cap | ±600 m window; a bar stopping short of the left edge stops at the mouth | guard (all three sites lie under 600 m; each first segment starts at 0) | yes |
| 37 | 296 cap | boxes coloured and labelled by slope; black line = site | code; at-site gradient guards | yes |
| 38 | 296 cap | "The panel titles name each stream, **what it flows into** and the nearest town" | `where()` writes "draining to" when `joins_direct` is FALSE. The third panel (Skeena, `142532_2_1`) is FALSE, so its title names what it drains to, not what it flows into | **no** (F4) |
| 39 R | 324 | "**The shorter segment** does not always read the steeper slope. On two of the three it does." | guards `full_length_m < minimal_length_m` and `sum(steeper) == 2` | yes |
| 40 | 324-326 | the third: the full segment ends 79 m above the site; the steeper water above it is read on its own and averaged by the minimal segment | `above3` guards | yes |
| 41 | 330-333 | held-out score; close call = within one SE; pick = fewest changes, then best score | `in_region`; linked article | yes |
| 42 | 334-335 | **every** close call changes all three parts on **every** network and slope, so the choice is the best scorer | `departures == "3"` on all four | yes |
| 43 | 335-336 | definition of a disagreement | definition | yes |
| 44 | 338-340 | four ways on **the same** 4,858 visits (those of the 7,823 in groups with both outcomes), same flows and range, the **only** differences | `length(unique(n_visits)) == 1`; `sum(both_out) == n_visits`; research note (same load, same installed link) | yes |
| 45 | 340-342 | two read slopes from another source: the minimal parent (the minimal segment it lies within) and the whole Atlas line | tokens `grad-parent`, `grad-fwa`; research note | yes |
| 46 | 349-356 | setups table cells | computed | yes |
| 47 | 358 | caption | | yes |
| 48 | 361-362 | **every** rule chosen keeps the same flow floor and allowance; only the limit differs | `unique(sub(...)) == 1` | yes |
| 49 | 362-364 | habitat through all of link's steps on the tuned segments, over the groups link classified for chinook; last column against the standard rule on the same segments and slopes | `default_km` differs by setup | yes |
| 50 | 367-371 | the four verdicts; "these runs do not show why" | guards | yes |
| 51 | 371-374 | 13 other rules with a 13 % limit, **differing in their flow floor or their allowance**, are close calls on the minimal records | `n_lim()`; all 13 are `mad` rules (checked) | yes |
| 52 | 376-379 | same flows and range; 3 of the 6 **other** species and stages both could fit choose differently; for 2, one choice is outside the other's region | `ok6`; `n_moved == 3`; `n_out == 2`; research note | yes |
| 53 | 412-413 | Morkill River group, around the Fraser River, 63 km north-west of McBride | places | yes |
| 54 | 413 | "the two rules a user could run on link's full network" | research note: the Atlas line is a sensitivity link does not build | yes |
| 55 | 413-416 | 2,150 km alike; adds 76 km; adds 19 km | `km_cls` | yes |
| 56 | 416-417 | most of each difference on order 3 or less (81 %, 98 %) against 41 % | `> 0.75`, `< 0.5` | yes |
| 57 | 418 | chosen before drawing: the most km where the four tunings disagree | stage query (`pattern NOT IN ('every setup','none')`) | yes |
| 58 | 420 cap | colour classes; grey = other streams chinook can reach; lakes of 10 ha or more (min 10.08 ha) and river polygons shaded | code; `mp$water` | yes |
| 59 R | 420 cap | "The lower panel is **the square outlined above**" | measured: the lower panel spans about 28 km by 15 km, the square plus about 6.6 km either side (an 18 ha lake 5.8 km west of the square sits inside the panel) | **no** (F1) |
| 60 R | 420 cap | "a 15 km grid laid from **the map's south-west corner**" | the grid's origin is `st_bbox(mp$background)`. The drawn top panel is padded to the panel's aspect, so its frame reaches about 33 km west of that corner | **no** (F1) |
| 61 | 420 / figure | scale bars "0 10 20 km" and "0 2 4 km" | measured against the 15 km square: the 20 km bar spans about 27.6 km, the 4 km bar about 7.4 km | **no** (F1) |
| 62 | 420 cap | the cell holding the most km drawn by one rule only, counted at segment middles (`km_zoom` km); line width follows order | code | yes |
| 63 R | 451-452 | **this package's chinook rearing thresholds**, tuned on 4 November 2026, on the full network reading each segment's own slope | guard `token_cut`, `curve_grad`; the published setup is read from tracked `data/tune`; `data/thresholds.csv` CH rear `g 0.13`, `segment_gradient`, tune run 20261104_0543 | yes |
| 64 | 452-455 | CH 13 / 9 / 15 %; floor and allowance hold on **all four** | guards | yes |
| 65 | 457-460 | 86,608 against 87,606 km; 1,042 km (1.2 %) on the minimal network alone | `transfer`; script holds both totals to the setups' km | yes |
| 66 | 460-463 | the difference comes from the near-river allowance measured from a segment's downstream end | research note | yes |
| 67 R | 467-470 | "Chinook rearing is **the only** species and stage tuned on all four of the ways above. The 6 others ... were tuned on the two networks' own slopes and ... on the Atlas line each visit lies on, **but not on the minimal parent's slope** or on the Atlas line of the segment." | province-wide: true. The 6 others are in `data/tune/grad_fwa` (5 fitted, WCT underpowered with a pick). But the research note's four-group test (2026-11-02) tuned bull trout rearing on full, minimal, full-with-parent-gradient and Atlas-line setups, with picks for each | **no** (F3) |
| 68 | 471-472 | the minimal network drops record, crossing and habitat-end cuts together; "which of **the three**" | RUNBOOK `full` minus `min` is exactly these three | yes |
| 69 | 473-475 | of the 4,858 scored, 225 cross a chosen limit; N of them caught chinook | `cr_scored` | yes |
| 70 | 475-476 | hedge; fixed-length slopes not tested | #70 open | yes |
| 71 R | 480-483 | bundled from the runs: full network run, minimal network run, and, for the first table's first row, link 0.66.0's earlier full network | `x$meta`; row label; script `premise$link` | yes |
| 72 R | 483-485 | premise shares, the four tunings' choices and habitat, and the other species' counts were each checked against the logs | script: premise against the 3 logs; pick, tune run, km, default km and rules in region against the setup csv; other-key counts against the picks csv | yes |
| 73 | 485-487 | FDIS electrofishing records placed on the Atlas; rules run through fresh | | yes |
| 74 | 491 | each tool cited where first used | accepted tradeoff | n/a |

Other files:

| # | file | claim | backing | covers? |
|---|---|---|---|---|
| 75 R | data-raw/README.md:41-42 | "holds the premise, the setups and the other species' counts to the logs that report them and the transfer's totals to the setups' km" | script lines 89-101 (premise), 123-131 (setups), 161-164 (other keys), 143-147 (transfer against `setups$tuned_km`) | yes |
| 76 R | data-raw/vignette_cut_points.R:12-15 | "THE PREMISE, THE SETUPS AND THE OTHER KEYS ARE HELD TO THEIR LOGS ... the transfer ... must equal the minimal and parent setups' km in that csv" | the transfer is compared with `setups$tuned_km`, which was itself held to the csv | yes |

**76 rows (74 in the article, 2 in the data-raw files); 6 fail, in 4 findings.**
- F1 is one figure, 3 rows: 59, 60 and 61.
- The other three are one row each: F2 (row 29), F3 (row 67) and F4 (row 38).

Rounds 1-4 rewrote rows 5, 11, 12, 16, 17, 24, 25, 29, 36, 39, 59, 60, 63, 67, 71, 72, 75 and 76. Three of those
rewrites fail on a new axis: the link target (29), the scope of "only" (67) and the map's corner (60). Row 59 is
round 3's wording, but it fails because of the same aspect-ratio defect that breaks row 60.

## Findings

- **[severity: bug]** vignettes/_cut_points.Rmd:420-446 (the map figure and its caption). Both scale bars misstate
  distance. The caption describes a lower panel and a grid origin that are not what the figure draws.
  - **Cause.** Each panel is about 1,007 × 547 px, an aspect of 1.84. The top panel's bbox
    (`st_bbox(mp$background)`, 170 × 128 km) has an aspect of 1.33, and the zoom square has 1.0. tmap fits each bbox to
    the panel's height and pads the width.
  - **How measured.** I rendered the article at HEAD and read the pixels of `map-1.png`:
    - In the top panel, the outlined 15 km square is 63 px wide, so the scale is about 4.2 px/km. The "0 10 20 km" bar
      is 116 px long, so it spans about 27.6 km.
    - In the lower panel, the fit-by-height scale is 547 px for 15.3 km, about 35.7 px/km. The "0 2 4 km" bar is
      263 px long, so it spans about 7.4 km.
    - An independent check confirms the fit-by-height reading: an 18.2 ha lake whose centre lies 5.8 km west and
      2.2 km north of the square's south-west corner sits inside the lower panel at about (45, 1045) px. The fit by
      height predicts (51, 1046). If the panel showed only the square, no lake could appear there.
  - **What is wrong.**
    - The bars overstate distance by 38 % and 84 %.
    - "The lower panel is the square outlined above" (row 59): the lower panel shows about 28 × 15 km, the square
      plus about 6.6 km on each side, with the square itself not marked.
    - "a 15 km grid laid from the map's south-west corner" (row 60, round 4's fix): the grid's origin is the bbox
      corner, about 33 km east of the drawn frame's left edge.
  - **Fix.** Make each bbox match its panel's aspect before drawing. This is cartography.md, "Bbox must match canvas
    aspect ratio". Extend `bb` and `zoom` about their centres to 1.84:1, or give the panels the bboxes' aspects. Then
    check each scale bar against the 15 km square in the rendered PNG.
  - **Rule:** none

- **[severity: fragile]** vignettes/_cut_points.Rmd:230-231. The sentence reads "the ones in chinook's range that
  pass its other filters ([which visits](habitat_thresholds.html#steps))". The sentence hands its definition of
  "its other filters" to the link, and the link's target does not give it.
  - `#steps` ("What happens, in order?") lists the eleven pipeline steps. None of them names the species filters
    (expected range, a code that could hide the species, a natural barrier downstream).
  - Those filters are stated in `#lost` ("Each species then keeps the sites its rules can speak to: ... where link
    expects the species, with no code that could hide it and no natural barrier to it downstream"), and the funnel
    table there gives chinook's 29,335, 17,942, 17,812 and 7,823.
  - The chinook article links the same population's description to `#lost` ("Left out ... ([More](habitat_thresholds.html#lost))").
  - The number is right; the linked source does not say what the sentence delegates to it. Point the link at `#lost`.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** vignettes/_cut_points.Rmd:467-470. "Chinook rearing is the only species and stage tuned on
  all four of the ways above. The 6 others ... were tuned on the two networks' own slopes and ... on the Atlas line
  each visit lies on, but not on the minimal parent's slope or on the Atlas line of the segment."
  - The research notes the article links (`research/minimal_network_tuning.md`, "The four-group test (2026-11-02)")
    record bull trout rearing tuned (`DEV=1`) on all four setups on link's four proof groups:
    - full, minimal and "full, parent gradient", the last two giving byte-identical tables;
    - "the Atlas line picks a 20 % gradient limit against 25 %".
  - So "the only" and "but not on the minimal parent's slope" are false for bull trout rearing as written. They hold
    only for province-wide runs, a scope the sentence does not state.
  - Those runs carry no threshold (the note says so), so the fix is one word of scope, for example "the only species
    and stage tuned province-wide on all four ...". Round 4's rewrite added "the 6 others both networks could fit"
    and the second clause, but kept the unscoped "only".
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** vignettes/_cut_points.Rmd:296 (the strip caption). "The panel titles name each stream,
  what it flows into and the nearest town."
  - `where()` (line 49) writes "flowing into" only when `joins_direct` is TRUE and "draining to" otherwise.
  - The third example (`142532_2_1`) has `joins_direct` FALSE, and its title reads "An unnamed stream draining to the
    Skeena River". By the code's own distinction the Skeena is not what that stream flows into.
  - The caption should say "what it flows or drains into", or similar.
  - **Rule:** code-check.md "A proxy is not the property"

No other code defect found in the branch. Rounds 1-4's code fixes touched only the article and two header comments.
Specifically:
- the article renders at HEAD with every `stopifnot()` passing;
- `test-vignette-data.R` fails only the known environmental test;
- `data-raw/README.md` and the bundle script's header now describe exactly the checks the script makes (rows 75-76).
