# Review: final edits to vignettes/_cut_points.Rmd (16d3641..HEAD), round 2

Reviewed at 7968c98, against `final.diff` (16d3641..HEAD, which matches the working tree). The article was rendered
from a scratch copy (`/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/4806f24e-ad07-420c-9786-93dc7069477e/scratchpad/render_r2/`)
against the installed package. Its two bundles have the same md5s as `inst/vignette-data/` (003c7a90..., a04b84fb...).
The render exited 0, so every `stopifnot()` ran and passed, and it gave four figures with one caption each. I looked at
all four PNGs, and sampled the map's pixels to check that the Fraser in the lower panel draws grey (#797979 to
#7c7c7c, `mid` antialiased over the basemap's blue river polygon), not steel blue. `test-vignette-data.R`: 245
expectations, 5 failures, all in the accepted environmental test ("every ignored source of the methodology article,
where present, is unchanged"). The working tree is clean.

## Checklist read

- code-check-python.md: in full. None of it applies; the diff has no Python.
- code-check-r.md: by heading. I read "ggplot2 legends and labels: a key for an unused factor level, and ggrepel
  labels that must avoid each other" (the premise bar graph's fill legend and its geom_text, the strip's geom_label)
  and "`ifelse()` with an all-NA test returns a logical vector, whatever `yes` and `no` are" (the premise's
  `ifelse(pm$catch_status == ...)`, which has no NA). I did not read the other headings (about 100), because they name
  tools this diff does not use.
- code-check-shell.md: by heading. I read none: the diff has no shell.
- code-check-spatial.md: by heading. I read none. The spatial change is one raster arithmetic line (the basemap fade)
  and a tmap casing layer, and no heading names either.
- code-check.md: the prose of every H3 under `## Mechanisms`, skipping `|` rows. I read most closely "A proxy is not
  the property", "Verification that reads its own output", "A guard's scope, escape hatches, and remedies" and "One
  fact derived twice". No other headings read.

## Claim enumeration

This table lists every factual claim that 16d3641..HEAD added or reworded, in prose, captions, legends, table cells,
footnotes and axis labels, every sentence where "rule" was replaced among them. Captions that this diff changed are
enumerated sentence by sentence, including sentences whose words did not change. Purely normative sentences are listed
and marked n/a. Line numbers are HEAD's.

Data checks are on `inst/vignette-data/cut_points.rds`, run in R during this review. "Guard Lnn" is the `stopifnot()`
at that line, which passed in the render.

| # | Line(s) | Claim (abridged) | Set or quantity named | Guard, computation or source | Covers? |
|---|---|---|---|---|---|
| 1 | 142-143 | link holds the recipes that turn life history into habitat on BC's streams | link's role | link README, origin/main ("building models of where each fish species could spawn and rear") | yes (owner-approved; not false) |
| 2 | 143-144 | A recipe is a config; every rule and threshold in it is a row in a table | link configs | link README: "every rule and threshold is a row in a config"; "its rules are tables" | yes |
| 3 | 144-146 | It sets a habitat definition per species and stage: smallest stream, steepest slope, how close a large river must be | link's habitat parameters | link README (gradient, width, discharge); the near-river pair is in link's parameter names (`thresholds.csv`, `near_river_scope`) | yes (not false) |
| 4 | 146-147 | It also defines obstacles: falls, steep sections, road and rail crossings and dams below | link access | link README ("natural barriers such as falls and steep gradients ... road and rail crossings and dams") | yes |
| 5 | 147-149 | fresh runs the recipe: cuts the FWA into segments, works out reach, classifies habitat | fresh's role | fresh README ("segment networks at barriers and break points", "classify habitat", multi-species habitat modelling); CLAUDE.md (fresh's predicate gated by access) | yes |
| 6 | 149-150 | So a model can be changed, run beside another and traced back to its rules | link | link README, nearly verbatim | yes |
| 7 | 152 | knowledge is the evidence tool for link's habitat definitions | knowledge's role | `thresholds.csv` in link's parameter names; CLAUDE.md | yes |
| 8 | 152-154 | It starts from life history in the literature and past reports; biology sets the shape (young chinook in small streams near a large river) | inputs | `literature_evidence.csv`, the corpus; CH's near-river allowance (`research/chinook_stream_size.md`) | yes |
| 9 | 154-157 | Records tune values: candidates scored against catches and empties; keeps the smallest change to link's standard settings that fits about as well as the best; checked on parts of the province not chosen from | the tuning | the pick is the fewest-departure region rule (research notes, "The answer"); held-out groups (methodology article) | yes |
| 10 | 158-159 | A habitat map steers restoration effort; one tuned this way rests on where fish were found | none | n/a (normative) | n/a |
| 11 | 161-162 | The research notes hold every species tuned, each run behind this article and its checks | the runs | `research/minimal_network_tuning.md` (on origin/main): Status names the nine species tuned and the runs `20261104_0543`, `20261103_0838`, `20261105_0436`/`0437` (= `x$setups$tune_run`) and both link builds | yes |
| 12 | 164-165 | A segment's slope is its drop over its whole length, so the cut decides the slope a definition is tested on | definition | profile guards L331-333 (segment gradients match the sites' records) | yes |
| 13 | 165 | Some cuts fall exactly where fish were caught | full network | premise guard L64 (fish starts own segment > 5x empty); 44.2 % | yes |
| 14 | 165-166 | Change the cuts and the definition chosen can change | the setups | guard L83 (13 % vs 9 %) | yes |
| 15 | 166-168 | Limit is 13 % full, 9 % minimal; minimal leaves out cuts at records, crossings, mapped habitat | two setups | guard L83; `token_cut` cut-full-top / cut-min; research notes | yes |
| 16 | 168-169 | The two definitions draw much the same habitat; they differ in short pieces of small streams | map group | guard L183-184 (shared > 10x differences; each difference > 75 % order <= 3) | yes |
| 17 | 175-176 (legend) | Both definitions / full network's own slope (13 %) only / minimal network's slope (9 %) only | map classes | `lv` from `s_of("published")`, `s_of("parent")`; guard L85 (parent pick == minimal pick) | yes |
| 18 | 219 caption | Two habitat definitions, both run on link's full network | map data | `mp$drawn` published and parent; parent is `cut-full-top` in `x$setups` | yes |
| 19 | 219 caption | Grey: both. Black: own-slope definition (13 %). Steel blue: minimal-network definition (9 %) | colours | `cols_map` = mid / ink / accent; rendered pixels grey, black, steel blue | yes |
| 20 | 219 caption | Between the dashed lines is the 15 km square with the most km drawn by one definition and not the other | zoom cell | code L188-198 (`dif` = class != both); dash box = `zoom` | yes |
| 21 | 310-312 | Two definitions draw X km alike; own-slope one adds Y; minimal one adds Z | km per class | inline `km_cls`; guard L183 | yes |
| 22 | 349-350 | Every habitat definition is then tested on the slope of the shorter segment | full network | guard L90 (published `curve_grad` == segment_gradient, `cut-full-top`) | yes |
| 23 | 352-353 | The cut lands at the visit; the slope tested there is worked out from the visit upstream | concept site | guard L331 (full segment starts within 1 m of the site) | yes |
| 24 | 357 caption | Thin grey line = elevation along the Atlas line | profile line | `geom_line(pr)`, grey78, linewidth 0.35; `pr` = `atlas_profile` | yes |
| 25 | 357 caption | Each line is a segment drawn as the straight slope tested on it, ticks at the ends of full and minimal segments | marks | `geom_segment` z_dn to z_up; shape-124 ticks on non-atlas segments | yes |
| 26 | 357 caption | Black full, steel blue minimal, grey Atlas line, which runs past the top | colours | `cols_net` ink / accent / grey; guard L336 (`z_up` > 1040) | yes |
| 27 | 357 caption | Black dot = chinook caught; open circle on the same full-network segment = none | sites | `cc$sites`: 494 TRUE, 519 FALSE; full segment 494-584 (checked in data; no guard; wording unchanged) | yes |
| 28 | 357 caption | Labels give the slope each version reads at the black dot | labels | `site_seg$lab`; guards L332-333 | yes |
| 29 | 357 caption | Elevation stretched several times | exaggeration | measured on the rendered PNG: 960 px per 700 m against 410 px per 50 m, about 6.0x at the new height 3.6 | yes |
| 30 | 429 | Three more visits with chinook show how far the cut moves the slope tested | examples | guards L387, L391 (`present`) | yes |
| 31 | 430-431 | One per group, largest gap on opposite sides of a tuned limit, picked by criteria set before drawing | examples | guards L391-396 (crosses, one per group); selection in `data-raw/vignette_cut_points.R` | yes |
| 32 | 433 caption | Each bar is a segment, coloured by the slope tested on it; line marks the visit; slopes labelled | marks | `geom_rect` fill = `cls`; `geom_vline(0)`; guard L423-425 | yes |
| 33 | 433 caption | The criteria: ... | selection | guards L391-396; the bundle's selection | yes |
| 34 | 444 (legend) | "Slope tested": 9 % or less / over 9 % to 13 % / over 13 % | classes | `cut()` at `crit$limits`; guard L436 (printed values on their bar's side) | yes |
| 35 | 474 caption | Visits starting their own segment on three networks: dark with fish (any species), light without | bars | `cols_catch` ink / soft; `pm$catch_status` fish / zero | yes |
| 36 | 474 caption | Starts its own segment = segment begins 1 m below to 5 m above | definition | `vignette_cut_points.R:78` `at_site <- off >= -1 & off <= 5` | yes |
| 37 | 474 caption | The same 29,335 visits on each network (13,058 with fish, 16,277 without) | counts | guard L61 (counts identical across networks per catch status); inline from the minimal rows | yes |
| 38 | 474 caption | Those with a fished area in the usual range, on the stream lines the tuning scores | population | carried from the old footnote; the bundle's premise reads the evidence build | yes |
| 39 | 474 caption | Networks are link 0.66.0's, 0.78.2's, 0.78.1's | versions | inline `unique(pm$link[...])`, each of length 1 (checked); one caption rendered | yes |
| 40 | 475-477 (axis) | Earlier full network cut at every record; the network used here cut at each species' highest record; minimal with no cuts at records, crossings or mapped habitat | networks | research notes table ("every observation a break"; link#396 highest record; `cut-min`) | yes |
| 41 | 485 (bar labels) | 86.2 / 10.2 / 44.2 / 6.6 / 3.4 / 3.0 % | shares | `pm$at_site_pct`; rendered values match `x$premise` | yes |
| 42 | 500 | Heading: how does the tuning choose a habitat definition? | none | n/a | n/a |
| 43 | 502 | A definition decides how much habitat link draws, so it should be one the records support | none | n/a (normative) | n/a |
| 44 | 502-504 | Tries many candidate definitions, each a different set of parameters, scored on held-out groups; lower is better | candidates | each `x$tune` holds 6,149 distinct rule strings; methodology article step 7 | yes |
| 45 | 505-506 | Every candidate within one standard error of the best is a close call | region | settings register `se_region` = 1 SE | yes |
| 46 | 506-508 | For chinook rearing the tuning varies the three parts: smallest stream (flow or width), steepest slope, allowance (river size and distance) | grid | all four `x$tune`: `size_var` {mad, width}, `size_min` 12 values, `grad_max` 11, `exc_q` 7, `exc_d` 6 (plus none); methodology article step 6 and settings rows `grid_mad`, `grid_width`, `grid_grad`, `grid_q`, `grid_d` (linked in the opening) | yes (round 1's defect fixed) |
| 47 | 508-511 | Chooses the close call closest to standard settings, then the best scorer; every close call differs in all three parts, so the choice is the best scorer | picks | guard L95 (`departures` == 3 on all four); checked in data: pick == lowest `ddev_best` in region == `recommended` on all four setups | yes |
| 48 | 515-516 | Tuned four ways on the same visits, flows and range, so the segments and slope tested are the only differences | setups | guard L73 (`n_visits` equal); flows and range per research notes (#145) | yes |
| 49 | 520 (table cell) | Full network, each segment its own slope (how link applies a habitat definition) | setup | guard L90 | yes |
| 50 | 531 (table caption) | The chinook rearing habitat definition chosen on each network and slope | table | table rows `su` | yes |
| 51 | 534-535 (footnote) | Every definition chosen keeps the same flow floor and allowance; only the slope limit differs | picks | guard L87; picks all `mad>=0.75\|...\|Q3@D1000` | yes |
| 52 | 535-537 (footnote) | On the minimal network's records, N other candidates with a 13 % limit, differing in flow floor or allowance, are close calls | candidates | `n_lim` = 13 (guard L101 > 0); checked: all 13 are `mad` and differ from the pick in `size_min` or `exc_q`/`exc_d` | yes |
| 53 | 542 | The 13 % definition is not a close call on the minimal network's records | verdict | guard L84 | yes |
| 54 | 543 | 9 % is a close call on the full network's records too | verdict | guard L84 | yes |
| 55 | 544 | Given the minimal parent's slope, the full network chooses the minimal network's definition exactly | pick | guard L85 | yes |
| 56 | 545 | The Atlas line chooses 15 %, a close call on neither network | pick | guards L85-86 | yes |
| 57 | 546-547 | Habitat differs by under X % across the four | spread | guard L92; `tuned_km` 85,962-88,458, so 2.8 %, printed "under 3 %" | yes |
| 58 | 551-552 | Published thresholds tuned on the full network, own slope, which is how link applies a habitat definition | published setup | guard L90 | yes |
| 59 | 552-555 | Another network or slope reading chooses another definition: 13, 9 or 15 %; floor and allowance hold on all four | picks | guards L83, L85, L87 | yes |
| 60 | 558-559 | A minimal-network definition run on the full one draws X % less habitat | transfer | guards L106-107 | yes |
| 61 | 559-561 | Stretches only the minimal network draws are small streams near large rivers, because the allowance is measured from a segment's downstream end | transfer | the section pointer was removed; the research notes linked in the opening, "Chinook rearing on every setup": "walked from a segment's downstream end", "all of it in small streams near large rivers" | yes |
| 62 | 567-568 | The network moved the definition for some of the other keys too | other keys | guard L116 (`n_moved` == 3 of 6) | yes |
| 63 | 579-580 | Bundled from the tuning runs and link builds the research notes describe | provenance | the research notes' Status names all four runs and both builds | yes |
| 64 | 583 | fresh runs link's habitat definitions | fresh | fresh README; opening row 5 | yes |

64 rows (5 n/a), 0 failures.

On "rule": the only "rule" left in the rendered text is in the owner-approved opening, at lines 143 and 150. There it
means link's config rules, as link's README uses the word, not a habitat definition. Every replacement listed above
(rows 14-22, 30-33, 43-62, 64) reads true for the shipped data.

On the captions against the new palette: each figure's caption names the colours it now draws.
- Map: grey, black, steel blue.
- Profile: thin grey, black, steel blue, grey, black dot, open circle.
- Strip: its fills are named by the legend; the caption says "coloured by the slope tested".
- Premise: dark, light.

The map's white casing is a halo under the difference lines, not a mark of its own (round 1 judged the same).

## Clean
No issues found.
