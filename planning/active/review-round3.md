# Review round 3 (revision after b84b0de, at HEAD 0d04557), #149

Scope: `revision.diff` (b84b0de..HEAD, planning excluded), read against the full working-tree files. Those are
`vignettes/_cut_points.Rmd`, `data-raw/vignette_bib.R`, `data-raw/vignette_cut_points_places.R`, `inst/NOTICE.md`,
`vignettes/cut_points.bib`, and the key changes in `chinook_rearing.Rmd` and `habitat_thresholds.Rmd`.

What I ran:
- I rendered `_cut_points.Rmd` from a scratch copy. The installed bundles' md5s equal the tree's (003c7a90…, a04b84fb…).
  The render exited 0 with no `(key?)`. I stripped the HTML to text and read every sentence as printed.
- I recomputed each claim from `cut_points.rds` and `cut_points_places.rds`, `data/thresholds.csv`,
  `research/minimal_network_tuning.md` and `habitat_thresholds.Rmd`.
- Every citation key in the three articles resolves in its `.bib`, with no extras. No `irvine2026*` key is left.
- `test-vignette-data.R` (`NOT_CRAN=true`) gave 245 expectations. The only failure is the known environmental one
  ("every ignored source of the methodology article, where present, is unchanged").

## Checklist read
- code-check-python.md: in full. Nothing applies; the revision has no Python.
- code-check.md: the opening prose of all fourteen H3s under `## Mechanisms`, table rows skipped. "The probe is broken
  before the world is" is the mechanism below. "A guard's scope, escape hatches, and remedies" and "A guard that fails
  toward pass" are applied to the rounding guards. I read none of the Rules that stand alone in full. Documentation
  Staleness I checked from its index line.
- code-check-r.md, by heading, 2 read: "`$` on a list partial-matches, so a longer sibling key answers for a missing
  one" (`v$link`, `v$fresh` and `v$wet` in `vignette_bib.R`) and "`sort()` and `order()` collate by `LC_COLLATE`, so a
  canonical form is locale-dependent" (the radix sorts). The other ~118 I did not read; they name tools the revision
  does not use.
- code-check-spatial.md, by heading, 2 read: "A name is not a key: `GNIS_NAME` matches features all over BC" (the
  places script groups streams by name within one group) and "sf: `st_intersection()` / `st_difference()` return a
  GEOMETRYCOLLECTION that QGIS will not draw" (`stream_labels()`, the zoom-panel length filter). The other ~96 I did
  not read.
- code-check-shell.md: 0 read. The revision has no shell.

## Mechanism

Every defect in this revision has the same shape. A plain-language rewrite drops a qualifier or a definition, and
the shorter phrase that replaces it names a **larger set** than the code computes. The guard, where there is one,
still checks the narrower set, so it keeps passing. The three earlier findings were each a widening of this kind:

- round 1, "1.2 % less": a share of one side widened into a net difference;
- round 1, "9.0 %": printed coarser than the limit it was said to cross;
- round 2, "finds the rule that best predicts": the tuning's pick widened to "the best scorer".

The three failures below are the same move:

- "for each species and life stage" widens the keys with enough records to all keys;
- "the rule ... changes" widens chinook's result to every key;
- "the numbers ... checked" widens the four checked kinds to every number in the article.

The first of these is inside round 2's own fix. A fix made by the same reflex brings the defect back.
code-check.md, "The probe is broken before the world is", names the rule: "When a claim is flagged as under-evidenced,
narrow it — widening adds a quantifier over a population you have not enumerated". The working check for each reworded
sentence: write down the set the old wording named, and ask whether the new wording names a larger one.

## Claim enumeration

The table holds every factual claim the revision added or reworded (b84b0de..HEAD), cited by `_cut_points.Rmd` line
as of HEAD. Sentences carried over unchanged are left out: "Both of link's networks cut … cannot pass", and "Slopes
taken over a fixed length … were not tested". A row passes when the claim is true for the shipped data and its guard,
computation or cited source covers the set and the precision it states.

| # | line | claim (set or quantity) | backed by | covers? |
|---|---|---|---|---|
| 1 | 140-141 | link maps where each species can spawn and rear on BC streams | link's documentation; methodology article | yes |
| 2 | 141-142 | a rule is a handful of thresholds (e.g. smallest stream, steepest slope); the stretches that pass are habitat | methodology article, "What is a threshold" | yes |
| 3 | 142-145 | knowledge, **for each species and life stage**, tests many rules and keeps the close call nearest link's standard settings | `data/thresholds.csv`: 6 of 22 keys `fitted`, 8 `no_response`, 4 `no_stream_rule`, 3 `not_modelled`, 1 `underpowered`. The methodology article scopes it to "species and life stages with enough records" | **no** (finding 1) |
| 4 | 145-146 | the research notes carry every species tuned | `research/minimal_network_tuning.md`: the seven fitted keys, and the others named as no response or no stream rule | yes |
| 5 | 148-149 | link tests a rule on segments; a segment's slope is its drop over its whole length | methodology article ("The slope is the segment's own") | yes |
| 6 | 149-150 | where link cuts sets the slope a rule reads; some cuts fall exactly where fish were caught | Table 1 (44.2 % of visits with fish start their own segment); guard L61 | yes |
| 7 | 150-151 | "Change the cuts and the rule chosen from those catches **changes**" (stated generally) | `other_keys`: 3 of the 6 other keys pick the same rule on both networks (coho, grayling, westslope cutthroat rearing); guard L113 `n_moved == 3` | **no** (finding 2) |
| 8 | 151-153 | chinook rearing's limit is 13 % on the full network and 9 % on the minimal one, which leaves out the cuts at records, crossings and hand-mapped habitat | guard L80; research note ("cut only at barriers and access gradients") | yes |
| 9 | 153-154 | the two rules draw much the same habitat; on the map they differ in short pieces of small streams | guards L89 (spread < 3 %) and L168-169; "short" unguarded (median 139 m, round 2) | yes |
| 10 | map caption | Morkill River group, "around the Fraser River 63 km north-west of McBride" | places file, by `vignette_cut_points_places.R`'s rule | yes |
| 11 | map caption | both rules run on the full network; navy, orange (13 %) and pink (9 %, the minimal-network slope) as defined | `lv` built from `published` and `parent`; guard L82 (the parent pick is the minimal pick) | yes |
| 12 | map caption | line width follows stream order | `lwd = pmin(pmax(order, 1), 6) / 3` | yes |
| 13 | map caption | the lower panel enlarges the outlined box; the dashed lines bound the 15 km square holding the most single-rule km | computed L173-183; round 2's clipped-length cross-check gives the same cell | yes |
| 14 | map caption | stream names are the Atlas's; basemap is Esri topographic and shaded relief | places script SQL; `basemap()` | yes |
| 15 | 290 | 2,150 km drawn alike | computed `km_cls[[1]]` | yes |
| 16 | 291-292 | +76 km (own slope), +19 km (minimal network) | computed | yes |
| 17 | 292-293 | most of each difference on order ≤ 3, against under half of the shared habitat | guard L169 | yes |
| 18 | 293-294 | the group was chosen before drawing as the one with the most km of disagreement among the tunings | research note: "MORK holds the most km of disagreement … chosen by that rule before drawing" | yes |
| 19 | 325-328 | the full network adds cuts at crossings, the ends of hand-mapped habitat, and records (each species' highest per stream, from bcfishobs) | research note; CLAUDE.md (link#396) | yes |
| 20 | 328-329 | link cuts at records so that a segment can say whether the species was seen at or above it, as bcfishpass does | link's CLAUDE.md (round 1) | yes |
| 21 | 329 | every rule then reads the slope of the shorter segment | follows from 5 and 19 | yes |
| 22 | 331-334 | the stream below: 10.8 % over 90 m on the full network; 3.4 % on the minimal network, from near the mouth past the visit | guards L311-315 (`from_m < 50`; the minimal segment starts at 13.8 m) | yes |
| 23 | profile caption | the open circle sits on the same full-network segment, at a visit with no chinook | data: 101360_2_1 at 519 m, `present` FALSE, in the 494-584 m segment; unguarded | yes |
| 24 | profile caption | ticks at the segments' ends; the Atlas line runs past the top | ticks at `from_m`, and every end in frame is the next segment's start; guard L316 | yes |
| 25 | 406-408 | in each of three groups, the visit where the two networks' slopes differ most while sitting across a tuned limit, by a rule set before drawing | recomputed: KLUM, LNAR and LSKE are each group's largest crossing gap, on minimal and on parent slopes, with or without the 50 m floor | yes |
| 26 | strip caption | 600 m window; a bar that stops short of the left edge stops at the mouth | guard L394-396 (all three visits sit under 600 m; both networks start at 0) | yes |
| 27 | strip caption | the slope each network reads at the visit is labelled | guards L398-403; L413 (each two-decimal label on its bar's side) | yes |
| 28 | strip caption | the selection rule (≥ 50 m, outside UFRA, the largest gap per group, the 3 groups with the largest gaps) | guards L366-372 for the criteria; ranking recomputed (0.0621, 0.0272, 0.0139 > COTR 0.0115) | yes |
| 29 | 443-445 | second panel: the full segment ends 79 m above the visit; the steeper water above is read alone, and the minimal segment averages it in | guards L432-440 | yes |
| 30 | 447-449 | on the full network a visit with fish starts its own segment far more often; the minimal network takes the difference away | guards L61-63 (> 5×; within 1 point) | yes |
| 31 | Table 1 rows | earlier network cut at every record; this one at each species' highest record; minimal at none | research note's table; CLAUDE.md | yes |
| 32 | Table 1 footnote | the same 29,335 visits (13,058 / 16,277); the 1 m below to 5 m above window; link 0.66.0, 0.78.2, 0.78.1 | guard L58; bundle `at_site()` and `premise$link` | yes |
| 33 | 473-475 | about 7,800 visits the tuning starts from; about 400 cross 9 % or 13 %; only 7 caught chinook | computed (7,823; 408; 7); guard L135 (< 10). The L134 rounding guard cannot fail (see notes), but the printed figure is the computed rounding | yes |
| 34 | 480-482 | each rule is scored on prediction in groups left out of the fit; lower is better | methodology article | yes |
| 35 | 482-483 | about 4,900 visits in 45 groups | computed (4,858; 45); `thresholds.csv` `n_wsg` 45 | yes |
| 36 | 483-484 | a close call is within one standard error of the best | research note ("within one standard error of its best") | yes |
| 37 | 484-485 | a rule has three parts (smallest stream, steepest slope, near-river allowance) | pick structure `mad|g|Q@D`; guard L92 (`departures == 3`) | yes |
| 38 | 485-487 | nearest the standard rule, ties to the best scorer; for chinook every close call differs in all three, so the choice is the best scorer | guard L92; every pick's `ddev_best` is 0 | yes |
| 39 | 491-492 | four tunings on the same visits, flows and range | guard L70 (visits); research note (flows, range) | yes |
| 40 | 492-493 | two tunings read another slope onto the full segments: the minimal parent's, the whole Atlas line's | research note | yes |
| 41 | Table 2 | limits and close-call verdicts | guards L80-83; computed `in_reg` | yes |
| 42 | Table 2 footnote | same floor and allowance, only the slope differs; 13 other 13 % rules are close calls on the minimal records, each differing in floor or allowance | guards L84, L98; the 13 listed (all `mad`, differing in size_min, exc_q or exc_d) | yes |
| 43 | 516 | without the extra cuts the records argue for the gentler limit | guards L81; research note ("without them the data argue for 9 %") | yes |
| 44 | 516-522 | 13 % not a close call on the minimal records; 9 % is on the full; parent picks it exactly; Atlas 15 % on neither | guards L81-83 | yes |
| 45 | 522-523 | the habitat drawn, through all of link's steps on the tuned segments, differs by under 3 % | guard L89 (2.82 %); research note ("through every stage") | yes |
| 46 | 527-528 | thresholds tuned on 4 November 2026, on the full network's own slopes | guard L87; run `20261104_0543`, the promoted run (research note) | yes |
| 47 | 528-531 | another network or slope reading picks 13 / 9 / 15 %; floor and allowance hold on all four | guards L80-84 | yes |
| 48 | 531-532 | each limit is the best fit for the slopes it was tuned on; 13 % was tuned on the slopes link applies | every pick's `ddev_best` is 0 (`x$tune`); guards L92, L87 | yes |
| 49 | 534-535 | the transferred rule draws 1.1 % less than on the minimal network itself | computed net; guards L103-104 | yes |
| 50 | 535-538 | the only-minimal stretches are small streams near large rivers, because of where the allowance measures from | research note, "Chinook rearing on every setup" | yes |
| 51 | 542-544 | the 6 other keys were tuned on both networks' own slopes and, separately, on the visit's Atlas line | guard L113; research note; methodology article's limits (`grad_fwa`) | yes |
| 52 | 544-545 | the network moved the rule for some of those too | guard L113 (`n_moved == 3`) | yes |
| 53 | 546-547 | the three kinds of cut are left out together; builds leaving out one each would separate them | research note | yes |
| 54 | 548-551 | of about 4,900 scored visits, 225 cross a chosen limit on the two networks, and 7 of those caught chinook | computed (`cr_scored`) | yes |
| 55 | 556-557 | the numbers were bundled from the runs and builds the notes describe, and **checked then against the logs that report them there** | `vignette_cut_points.R` holds only the premise, the setups' picks and km, the transfer and the other keys to logs (its header and the `stop()`s at L95, L130, L149, L163). The site counts, map km, examples and profile come from staged inputs that no log reports | **no** (finding 3) |
| 56 | 557-559 | visits are FDIS electrofishing records on the Atlas; rules run through fresh | methodology article | yes |
| 57 | 559-560 | the basemap is Esri's World Topographic Map blended with World Shaded Relief | `basemap()` L210-216 | yes |

**57 rows, 3 failures** (rows 3, 7, 55).

Notes, not findings:
- Two guards cannot fail. `abs(nrow(cr) - r_cross) < 50` and `abs(su$n_visits[1] - round(su$n_visits[1], -2)) < 50`
  (L134) compare a value with its own rounding to hundreds, which is always within 50. The one exception is an exact
  half, which round-half-even sends 50 away. The sentences hold anyway, because the printed figure is that rounding.
- `strip$lab` (L391) is computed and never drawn. It is harmless.

## Findings

- **[severity: bug]** vignettes/_cut_points.Rmd:142-145 — Round 2's rewording says knowledge "chooses link's
  thresholds from fish records: for each species and life stage, it tests many rules … and of the rules that predict
  about as well as the best, keeps the one closest to link's standard settings". That is false for most of the set it
  names. `data/thresholds.csv` gives a kept rule (`fitted`) for 6 of 22 species × stage keys. 8 are `no_response`,
  4 `no_stream_rule` and 1 `underpowered`, and none of those keeps a rule. 3 are `not_modelled` (rainbow trout
  rearing and spawning, kokanee spawning), and those are not tested at all. The methodology article the sentence links
  scopes the same claim to "the N species and life stages with enough records". No guard covers the sentence. Fix:
  scope it, for example "for each species and life stage with enough records".
  - **Rule:** writing.md "State each claim by the code's definition" ; writing.md "Check that each guard covers the
    set its sentence names"

- **[severity: bug]** vignettes/_cut_points.Rmd:150-151 — "Change the cuts and the rule chosen from those catches
  changes." The sentence states as a general law what holds for chinook rearing and half of the others. The
  article's own bundle says the opposite for half the other keys: `other_keys` has 3 of the 6 other keys picking the
  same rule on the full and minimal networks (coho, grayling and westslope cutthroat rearing), and guard L113 asserts
  `n_moved == 3`. The Limits section words it correctly ("moved the rule for some of those too"). Fix: "can change".
  - **Rule:** writing.md "State each claim by the code's definition" ; writing.md "Check that each guard covers the
    set its sentence names"

- **[severity: bug]** vignettes/_cut_points.Rmd:556-557 — "The numbers were bundled … and checked then against the
  logs that report them there." The pre-revision text listed what was checked: the share of visits starting their own
  segment, the four tunings' choices and habitat, and the other species' counts. The rewording covers every number
  the article prints. `data-raw/vignette_cut_points.R` holds only those kinds to logs, plus the transfer (its header,
  "THE PREMISE, THE SETUPS AND THE OTHER KEYS ARE HELD TO THEIR LOGS", and the `stop()`s at L95, L130, L149 and L163).
  Several printed numbers are not reported in any log and were checked against none: the about 7,800 / 400 / 7 and
  225 / 7 visit counts, the map's 2,150 / 76 / 19 km, the three examples, and the profile's slopes. Fix: scope it to
  what was checked, for example "and those the research notes report were checked then against their logs".
  - **Rule:** writing.md "State each claim by the code's definition" ; writing.md "Check that each guard covers the
    set its sentence names"

No code defect found in the revision. Things checked and holding:
- `vignette_bib.R`: `bib_package()`, the radix sorts and the exact `v$link` / `v$fresh` / `v$wet` names. A missing run
  version stops loudly in `if (grepl(...))` rather than writing a borrowed version.
- `vignette_cut_points_places.R`: streams are grouped by name within one group. A homonym merges, but its label
  still carries its own name.
- The article's label helpers: `stream_labels()`, and the zoom filter, whose `st_intersection()` rows align with
  `st_intersects()`.
- The bundles, the places' meta and the diff carry no host names, home paths or client identifiers.
