# Habitat thresholds tuned for every species and life stage in one run

**Verified:** 2026-10-27 for Evidence and Method's placement, flow source and gradient read (#89); 2026-10-25 (#73: every key retuned on the evidence rebuilt on wet's 2026-10-19 flows with the walk ending at
the river's bank, on a gradient ladder to 30 %, with the grid's fit absorbing the groups and a prior on its data-set and
era terms; graded with the curve's prior under a gate; recompared under link's through-wetland structures); first
tuned 2026-10-17 (#57); regraded 2026-10-19 (#65); the one-SE wording and the picks at 1.96 SE 2026-10-20 (#79) ·
**Issues:** #57 (this; replaced #59), #65, #79, #73 (folding #68, #80 and #81's run-time pieces; #83 and #84 are its
scorer work; #85, #86 and #87 the speed work it spawned); the one-species tunings it supersedes are #28
(`habitat_weights.md`), #33 (`bt_spawning.md`), #52 (`chinook_stream_size.md`) and #54 (`chinook_rearing_tuned.md`);
link reads the result through NewGraphEnvironment/link#346 · **Produced by:**
- `scripts/0300`: the wait for link's province-wide `default` run (`scripts/logs/habitat/20261017_link_settle.csv`);
- `scripts/0310`: the evidence build (`scripts/logs/habitat/20261022_evidence_build_ledger.csv`; tables built as
  `knowledge/fdis/v3`, not yet uploaded);
- `scripts/0320`: the tuning run (`data/tune/<sp>_<stage>_{tune,summary,honest,seeds,curves,groups,smoke}.csv`; the
  rescore's grading `scripts/logs/habitat/20261023_tune_run.txt`, the regrade with the curve's prior and the grade gate
  `20261024_tune_run.txt`; #57's `20261017_tune_run-*` and #65's `20261019_tune_run.{txt,out}` are the earlier runs);
- `scripts/0325`: `data/thresholds.csv`, `data/thresholds_groups.csv`, and the Parquet sets `knowledge/thresholds/v1`
  and `knowledge/habitat_grade/v1` (rerun on #73's regraded tables on the database's host on 2026-10-25, from commit `bf41ebd`; BT spawning and CO,
  ST and WCT rearing are left out of the grade set);
- `planning/archive/2026-10-issue-65-grade-walks-every-segment/check_{off_branch,connector_share}.R`: the grade off
  the stream branch and the connector's share of the walked distance (Limits; #65's measurement);
- `scripts/0330`: `data/compare/*.csv` (`compare`, `change` and `checks`, composed over every key; log
  `scripts/logs/habitat/20261024_compare.txt`); `floodplain.csv` and `research/fig/compare_*.png` are #65's.

**Status:** measured; nothing applied in link. One file per species holds the species' reading:
`bull_trout_tuned.md`, `chinook_rearing_tuned.md` (#54's file, with the province-wide rescoring at its head),
`coho_rearing_tuned.md`, `grayling_rearing_tuned.md`, `rainbow_rearing_tuned.md`, `steelhead_rearing_tuned.md`,
`westslope_cutthroat_rearing_tuned.md`.

**In plain words.** link calls a stream segment rearing or spawning habitat for a species with a yes-or-no
test: big enough, and not too steep. This run asked, for each species and life stage the electrofishing record
can speak to, which version of that test best predicts where the fish were caught in watersheds held out of the
fit. For each one it tried a ladder of size floors (by flow or by width) and gradient limits, and, for small
streams, an allowance for a river close downstream. It scored every version on held-out watershed groups,
kept every version within one standard error of the best (a rule of thumb fixed before the run, not a
boundary of noise), and recommended the one of those closest to link's current test. link's current test is not among
them for any fitted species but grayling. Five of the eight recommended rules draw less habitat than link does now (5 %
less for coho to 42 % less for bull trout rearing), bull trout spawning's and westslope cutthroat's draw
more, and grayling's is link's own. A grade from 0 to 1 then gives the use to expect on each segment, read at that
segment's own distance to a river (#65 corrected a first build that read most segments at the distance cap), and is
published only where the curve behind it predicts held-out groups better than no rule at all: for bull trout spawning,
coho, steelhead and westslope cutthroat it does not, so they carry a rule and no grade. The package article on chinook rearing
(https://newgraphenvironment.github.io/knowledge/articles/chinook_rearing.html) walks through one species from the
question to the map; the specification below is the record.

## The question

link's `default` draws habitat as on/off at a size floor and a gradient maximum per species and stage, set from
bcfishpass and the literature. #28 and #54 tuned two of those rules one species at a time, each with its own
build and its own scripts, on the 55 groups link had run. link's province-wide `default` run
(NewGraphEnvironment/link#246, `run_uid 20261017_004619-3f4c713b`, 241 groups) makes one build and one run
possible: which rule does the electrofishing evidence support for each species and stage, how far can each value
move before the data can tell, and what does a segment just inside or just outside a cut deserve?

## Evidence

FDIS electrofishing site visits (`fdis_export.md`), placed on link's segments: 51,587 visits, 40,552 placed, one
row per visit and species. Placement (#89): `scripts/0230` snaps each visit's UTM point to the nearest Freshwater Atlas
stream with fwapg's `fwa_indexpoint()` (500 m search, `snap_tol_m`); `knw_fdis_quality()` drops a visit not placed
(1,563), placed more than 100 m from its stream (`snap_flag_m`, 5,242) or on a stream outside the FDIS 1:50k watershed
code (1,088); `knw_link_place()` then takes link's segment at the visit's measure (1,491 with none). bcfishobs plays no
part in placement. The row carries catch, size classes, presence and whether an absence is blocked by a code that
could hide the species (`knw_fdis_species()`). Each visit carries link's access code and habitat flags per
species (re-gated on `streams_access`; link#349's disagreement is ledgered per run), wet's annual flow by source
(`modelled_discharge.md`; the default, `pick`, is PCIC's VIC-GL runoff routed by Raven on PCIC's network on 86.3 % of
the placed visits and wet's water balance on 13.7 %, build `94deeb5`; routed flow reaches Atlas segments through the
PCIC crosswalk on the `newgraph` branch of NewGraphEnvironment/fwapg, fork PRs NewGraphEnvironment/fwapg#6, fwapg#10, fwapg#21, fwapg#26 and fwapg#32, which
upstream fwapg does not carry), the width link reads on an unmeasured stream, regulated reach, the natural barriers
downstream per species, and walks to the first river of 1–50 m³/s on each flow source, each ending at a double-line
river's bank (#73). Presence-only bcfishobs records never score a rule; `knw_bcfishobs_match()` ties 24,000 of them to
their FDIS visits by collection, species and date, and the rest give the outside check. The Fish Data Submission
workbooks add 871 placed sites, 92 of them with electrofishing effort.

## Method (0297's spec, fixed for CH before its first fit, carried to every species)

- **Population per species × stage:** stream-branch visits (stream edges in no river polygon, wetland ≥ 1 ha or
  lake ≥ 100 ha), 10–10,000 m² fished, in groups where link marks the species present, no code blocking its
  absence, no natural barrier to it downstream. Rearing's response is detection; spawning's is spawner evidence
  from maturity codes, which only char carry.
- **Gradient read:** the visit's Freshwater Atlas line's (`fwa_gradient`, from `fwa_stream_networks_sp.gradient`,
  `knw_link_flow()`), the default `cols` of `knw_rule_in()` and `knw_tune_curve()`. link applies a rule on its own
  segments, cut from those lines, whose gradient `fresh::frs_col_generate()` recomputes from each piece's end
  elevations after every cut; the two can differ, and scoring on link's is #92.
- **Grid** around link's own `default` thresholds: a size test (MAD floor 0.1–1 m³/s or width floor 1–4 m, the
  species' own values and link's `default_tuned` floor joining the ladder), a gradient maximum on a ladder from 3 to
  30 % (#68; #57's ended at 9 %) plus the species' own, and an exception admitting a segment that fails the size test
  when a river of Q ∈ {1…50} m³/s lies within D ∈ {100…5,000} m downstream. 6,149 rules for CH and 6,622 to 8,385
  for the other keys; a species whose `default` has no stream rule (KO, SK: lake rearing only) has no grid.
- **Score:** held-out binomial deviance (cloglog, with log area, data set, era and the group), five stratified
  group folds, each group held out once, each held-out group refitting only its own intercept, found as the root of
  the deviance's derivative (#84). The fit absorbs the group intercepts instead of carrying a column per group (#83)
  and holds the data-set and era coefficients under a normal prior, SD 2.5 on the cloglog scale (#84: without it a
  level that separates runs to a hazard ratio in the millions and every held-out visit of that level is scored on the
  noise). Before any grid is scored, a smoke run scores no rule, `default`, link's `default_tuned` row and the previous
  pick on every key and refuses the run on four gates (#84). The **region** is every rule within one SE of the best
  (the group is the unit), a parsimony rule of thumb fixed before the run, not a boundary of noise ("At 1.96 SE",
  below); the **pick** is the region rule with the fewest departures from `default`, read from link's width `default`
  and again from its flow version (#80); `recommended` moves off an exception under 200 m. A 200-resample group
  bootstrap, a nested selection and four more fold seeds measure stability. A species × stage fits with ≥ 5 groups
  having both outcomes and is `underpowered` under 10.
- **Curve:** one GAM per species × stage after the pick, `te(log size, log distance to the pick's river)` +
  `s(gradient)` with the same nuisance terms under the same prior (#73) and a group random effect; held-out deviance on
  the same folds.
- **Grade:** the curve's predicted rate at the reference nuisance values (group effect excluded) over the 95th
  percentile of the rate on accessible stream-branch segments (the edge types of the curve's visits; since #65),
  capped at 1, in fifths. Expected use per standard electrofishing
  visit, not habitat quality. A segment with no size (an unmeasured first-order stream under a width rule) or no
  gradient is `NA`, counted. Every accessible segment with a gradient is walked from its downstream end to the
  first river of the pick's exception flow (10 m³/s where the pick has no exception), on any edge type and at any
  gradient, ending at a double-line river's bank (#73), because the curve reads size and distance together; a walk that
  reaches the sea first, or stops, reads the 50 km cap, as the curve's visits did (`dist_status` in the grade table says
  which). **The gate** (Al, 2026-10-24): a key whose curve scores no better on held-out groups than no rule gets no
  grade, no rule being scored on the curve's own visits (those with a size, a gradient and a distance) on the same
  folds (`null_heldout_curve`; until the branch review of 2026-10-25 it was scored on the grid's larger population,
  which favoured publishing for the width-ruled keys and let bull trout spawning through); its grade table carries size
  and distance with `rate`, `grade` and `grade_class` blank and
  `grade_withheld = TRUE`, the comparison reports its graded km as NA, and `0325` leaves it out of
  `habitat_grade/v1`. #57's first build walked only the segments the exception could admit and read every other
  segment at the cap (#65).

## Results

| species × stage | visits (detections), groups | recommended rule | region | `default` | pick holds in | power |
|---|---|---|---|---|---|---|
| BT rearing | 8,717 (1,198), 75 | MAD ≥ 0.35, ≤ 25 %, none | 316 rules: MAD 0.043–0.5 or width 3, 11–30 % | out, +226.4 (SE 111.7) | 2 of 5 seeds | fitted |
| BT spawning | 475 (98), 22 | width ≥ 2, ≤ 13 %, none | 333: width 1.5–3 or MAD 0.041–1, 11–30 % | out, +10.1 (SE 5.7) | 4 of 5 | fitted, **weak** |
| CH rearing | 4,490 (215), 43 | MAD ≥ 0.75, ≤ 13 %, Q3 within 1 km | 84: MAD 0.15–1, 7–30 %, Q 1–10, D 0.5–2 km | out, +224.7 (SE 91.6) | 1 of 5 | fitted |
| CO rearing | 4,263 (1,107), 62 | MAD ≥ 0.03, ≤ 4 %, none | 89: MAD 0.03–0.2, 3–7 % | out, +111.8 (SE 47.4) | 5 of 5 | fitted |
| GR rearing | 1,230 (212), 26 | **`default`** (width ≥ 1.5, ≤ 3.49 %) | 1,231: width 1–4, 3–30 % | **in**, +10.8 (SE 12.0) | 3 of 5 | fitted |
| RB rearing | 12,959 (3,513), 129 | width ≥ 3, ≤ 30 %, none | 14: width 2–4, 20–30 % | out, +302.9 (SE 104.8) | 5 of 5 | fitted |
| ST rearing | 1,375 (82), 11 | MAD ≥ 1, ≤ 8.49 %, none | 1,034: MAD 0.15–1 or width 4, 3–30 % | out, +50.3 (SE 29.9) | 5 of 5 | fitted |
| WCT rearing | 1,157 (536), 6 | MAD ≥ 0.03, ≤ 30 %, none | 225: MAD 0.03–0.35 or width 1–3, 4–30 % | out, +30.6 (SE 22.4) | 5 of 5 | underpowered |
| CH, CO, GR, RB, ST, WCT spawning | — | — | — | — | — | no electrofishing response |
| KO, SK rearing; CM, PK | — | — | — | — | — | no stream rule in `default` |

Every row is #73's (scored 2026-10-23 and graded 2026-10-24 on the evidence rebuilt on wet's 2026-10-19 flows, the
walk to the bank and the ladder to 30 %: 8,385, 7,095, 6,149, 6,622, 7,740, 7,740, 7,224 and 7,224 rules). "Pick holds
in" counts the main seed and the extra fold seeds whose recommendation is this exact rule; a seed that recommends a
neighbour (the same floor at another limit) is not counted, and the species files say what each seed chose.

Four readings across the table:
1. **`default` is outside the one-SE region for every fitted key but grayling.** For BT rearing, CH, CO, ST and WCT
   the evidence prefers sizing streams by flow (a MAD floor) to `default`'s 1.5 m width; RB keeps width and raises it to
   3 m, and BT spawning keeps `default`'s 2 m. Where the flow floor moves it moves up for BT rearing (0.35), CH (0.75)
   and ST (1 m³/s) and to the bottom of the grid for CO and WCT (0.03), whose juveniles rear in the smallest streams.
2. **The gradient limit moves up for five keys and down for one:** up to 25 % for BT rearing, 13 % for BT spawning and
   CH, and 30 %, the top of the ladder, for RB and WCT; down to 4 % for CO; unchanged for GR (3.49 %) and ST (8.49 %).
   Where the limit is the ladder's top rung (RB, WCT) or the one below it (BT rearing), the profile is flat from about
   20 % up, so the data say that a limit near `default`'s costs and do not say where the limit is (each species file's
   "ladder's edge" check); none of those three is a claim that the species rears to 30 %.
3. **Only CH's rule needs the near-a-river exception.** BT spawning's best rule carries one, but its pick does not, and
   that row is weak (its raw rates do not separate, and nested selection puts the pick behind no rule).
4. **Two rows are thin and one is underpowered:** ST (82 detections, 11 groups), BT spawning (98 detections, 22
   groups) and WCT (6 groups, `underpowered`). Their picks stand as the grid's reading; what each can claim is in its
   file.

### At 1.96 SE (#79, 2026-10-20; replayed on #73's tables 2026-10-25)

One standard error is a rule of thumb, not a test. Its sources are Breiman et al. 1984, who proposed it for pruning trees, as cited in Chen & Yang 2021, §1.3, since no copy is held; Hastie, Tibshirani & Friedman 2009, pp. 61 and 244, whose only rationale is that the curve "is estimated with error, and hence takes a conservative approach". Chen & Yang (2021, §6) find "no evidence
confirming that the 1se rule can consistently outperform the regular CV", with an SE that can be off by 100 % either
way; no unbiased estimator of K-fold cross-validation's variance exists (Bengio & Grandvalet 2004), and the usual
estimate is too small (Bates, Hastie & Tibshirani 2024). The threshold was fixed before the run and is kept. The pick at
1.96 SE is read from the same tables (`knw_tune_repick()` on `data/tune/<sp>_<stage>_tune.csv`; the run writes it to
each key's summary as `rule_recommended_196`, and from link's flow start as `rule_recommended_flow_196`):

| species × stage | `default` behind the best, in SEs | pick at 1 SE | pick at 1.96 SE | rules within 1 SE → 1.96 SE, of |
|---|---|---|---|---|
| BT rearing | 2.03 | MAD ≥ 0.35, ≤ 25 % | MAD ≥ 0.35, ≤ 10.49 % | 316 → 3,312, of 8,385 |
| BT spawning | 1.77 | width ≥ 2, ≤ 13 % | `default` | 333 → 5,774, of 7,095 |
| CH rearing | 2.45 | MAD ≥ 0.75, ≤ 13 %, a ≥ 3 m³/s river within 1 km | MAD ≥ 1, ≤ 5.49 %, the same exception | 84 → 2,102, of 6,149 |
| CO rearing | 2.36 | MAD ≥ 0.03, ≤ 4 % | width ≥ 1.5, ≤ 4 % | 89 → 1,511, of 6,622 |
| GR rearing | 0.90 | `default` | `default` | 1,231 → 7,337, of 7,740 |
| RB rearing | 2.89 | width ≥ 3, ≤ 30 % | the same rule | 14 → 463, of 7,740 |
| ST rearing | 1.68 | MAD ≥ 1, ≤ 8.49 % | `default` | 1,034 → 6,434, of 7,224 |
| WCT rearing | 1.37 | MAD ≥ 0.03, ≤ 30 % | `default` | 225 → 7,183, of 7,224 |

- **Four of eight keep `default` at 1.96** (BT spawning, GR, ST and WCT), and for each of them the 1.96 region holds
  most or all of the grid, so keeping `default` there says the stricter bar cannot separate the rules, not that the
  records support `default`. Four move off it: BT rearing keeps its flow floor and returns to `default`'s 10.49 %
  (`default` itself is outside at 1.96, 2.03 SEs behind); CH keeps a flow floor and the exception at `default`'s
  5.49 % (MAD ≥ 1 from the width start, 0.28 from link's flow start), 2.45 SEs behind; CO goes back to width at its
  4 % limit; RB's pick is the same rule at either bar, with `default` 2.89 SEs behind.
- **From link's flow start** (#80: `default`'s width floor written as the MAD it stands for), the 1.96 pick keeps the
  flow start's own floor for every key and moves only the gradient limit or the exception: it is the flow start's own
  rule for BT rearing, BT spawning, GR, ST and WCT, CO's own pick (MAD ≥ 0.03 at 4 %), MAD ≥ 0.28 at 5.49 % with the
  exception for CH, and MAD ≥ 0.021 at 11 % for RB.
- `data/thresholds.csv` carries the 1.96 pick per rule as `rule_196`, and per component whether it keeps the value
  as `holds_196` (a size row also needs the same size variable). A component equal to `default`'s value holds
  trivially, and a MAD row's `link_parameter` is not what a width rule at 1.96 would set.

**CH's open floor (#54) settles at 0.75 m³/s**, the best rule's and the pick's, with the region's floors running from
0.15 to 1.

## Grades

| species × stage | segments (groups) | accessible km | graded km | grade-weighted km | reference rate | km under 0.2 | km at 0.8–1 |
|---|---|---|---|---|---|---|---|
| BT rearing | 8.41 M (158) | 576,908 | 571,305 | 146,894 | 0.221 | 64 % | 10 % |
| BT spawning | 8.41 M (158) | 576,908 | withheld (corrected 2026-10-25): curve 397.3 against 377.9 for no rule on the curve's 450 visits; the 2026-10-24 grade (246,336 grade-weighted km) is withdrawn and the 2026-10-25 regrade carries none | | | | |
| CH rearing | 5.76 M (125) | 225,152 | 224,459 | 61,491 | 0.146 | 68 % | 21 % |
| CO rearing | 4.92 M (100) | 147,795 | withheld: curve 4,092.0 against 4,021.4 for no rule | | | | |
| GR rearing | 4.21 M (82) | 258,576 | 146,128 | 74,376 | 0.081 | 22 % | 26 % |
| RB rearing | 10.33 M (210) | 509,975 | 277,539 | 117,596 | 0.448 | 31 % | 14 % |
| ST rearing | 4.14 M (79) | 155,357 | withheld: 553.8 against 413.9 | | | | |
| WCT rearing | 1.19 M (16) | 35,285 | withheld: 1,453.4 against 1,329.7 | | | | |

Every row is #73's grade of 2026-10-24: each accessible segment walked to the river's bank and read on the flows wet
republished on 2026-10-19 (the table records the load, wet `94deeb5`), the reference over edge types 1000, 1100,
2000 and 2300, and the curve fitted with the grid's prior (`curve_prior_sd` 2.5 on every table). The prior moved
steelhead's curve from 860.8 to 553.8 held-out and grayling's from 786.9 to 743.6, bull trout spawning's by 6 and the
other five by about 1; every key's curve still beats the best cut except coho's, steelhead's, WCT's and bull trout
spawning's, and none of those four beats no rule scored on the curve's own visits, so all four are withheld. Bull trout
spawning's verdict moved on 2026-10-25, when the branch review found the gate comparing the curve, scored over the
visits with a size, against no rule over every modelled visit: against the grid's 401.4 its curve looked 4.2 ahead,
against 377.9 on its own 450 visits it is 19.4 behind. The four graded keys' margins over no rule on their own visits
are BT rearing 407.9, CH 320.8, GR 19.2 and RB 906.1 (the grid's no-rule scores overstate them by 4.9, 7.0, 65.3 and
2,301.4). Coho's curve is behind no rule with 62 groups having both outcomes, so the cause there is not power alone
(`coho_rearing_tuned.md`, "No grade"). BT spawning was regraded and recompared on the database's host on 2026-10-25 under the corrected
gate.

A width rule grades only measured streams: fwapg models width where `stream_order > 1`, so GR and RB leave every
unmeasured first-order stream `NA` (RB: 6.26 M of 10.33 M segments; GR: 2.62 M of 4.21 M), as BT spawning's table
does (5.10 M of 8.41 M with no width). A MAD rule grades almost everything (BT rearing: 33,992 segments
with no flow even from a parent). Against #65's grades the references move with the pick and the walk: BT rearing
0.226 → 0.221, CH 0.136 → 0.146, GR 0.034 → 0.081, RB 0.445 → 0.448, BT spawning 0.210 → 0.151 (a width rule on a
smaller graded population).

Revised 2026-10-19 (#65). #57's grades read every segment the exception could not admit at the 50 km distance
cap, and six of the eight keys walked no segment at all; every segment now reads its own distance, and the
reference is the stream branch's 95th percentile. The regrade also read the flows wet republished on
2026-10-19 (NewGraphEnvironment/wet#103, about ±5 % on most segments), after the thresholds had been tuned on the load
before it; #73 retuned on them.

## What each rule changes on link's segments

`scripts/0330` regenerates `default` and the tuned rule through fresh's predicate, the user-habitat overlay and
connectivity on scratch copies of every group the species' habitat table covers (`knw_compare_rules()`; the
regenerated `default` equals fresh's own predicate on every segment), and reads the grade beside each segment.
Kilometres are accessible stream under `streams_access`, flagged rearing or spawning by each rule; graded km is
km × grade (`data/compare/compare.csv`, `change.csv`, `checks.csv`). Every row is #73's, against link 0.68.3's
`default` (`configs/default` at `102762da`, read on the archived schema `fresh_default_20261017`; log
`scripts/logs/habitat/20261024_compare.txt`), and under the structure each species file records for through-wetland
lines (edge 1050/1150, link#364): `door` for every key, link's `stream`, which puts those lines through the gradient and
size test. The free pass, the structure the rules were scored under, draws more for every rule that has a size floor
(BT rearing 158,584 km, CH 92,041, CO 77,602, RB 194,307, ST 45,274, WCT 24,572; GR and BT spawning have one structure);
CH, whose `default` pairs a wetland-flow test with its exception, has a third (`door_wetland`, 66,832 km). The checks
cannot tell the structures apart for any key, so the structure is link's call.

| species × stage | accessible km | `default` km | tuned km | change | lost | gained | graded km, `default` → tuned |
|---|---|---|---|---|---|---|---|
| BT rearing | 576,908 | 244,328 | 142,015 | −41.9 % | 106,132 | 3,819 | 101,583 → 74,218 |
| BT spawning | 576,908 | 133,382 | 169,416 | +27.0 % | 0 | 36,034 | no grade (the withdrawn grade of 2026-10-24 read 93,333 → 123,687) |
| CH rearing | 225,152 | 99,186 | 84,294 | −15.0 % | 30,477 | 15,585 | 48,134 → 53,957 |
| CO rearing | 147,795 | 79,829 | 75,430 | −5.5 % | 9,945 | 5,546 | no grade |
| GR rearing | 258,576 | 77,740 | 77,740 | 0 | 0 | 0 | 45,564 → 45,564 |
| RB rearing | 509,975 | 219,156 | 180,951 | −17.4 % | 49,797 | 11,593 | 99,441 → 92,150 |
| ST rearing | 155,357 | 70,980 | 41,714 | −41.2 % | 29,605 | 339 | no grade |
| WCT rearing | 35,285 | 20,632 | 24,428 | +18.4 % | 913 | 4,710 | no grade |

1. **Five tuned rearing rules draw less than `default`**, from 5.5 % less for coho to 41.9 % less for bull trout and
   41.2 % for steelhead; grayling's is `default`, and westslope cutthroat's draws 18.4 % more. The loss is the size
   floor: segments over 1.5 m wide that fail the tuned flow or width floor with no exception (BT rearing 93,550 of its
   106,132 km lost, RB 44,368 of 49,797, ST 26,451 of 29,605, CH 24,250 of 30,477), with through-wetland lines that pass
   `default`'s door and fail the tuned one next (BT 12,130 km, CH 6,127, RB 5,429, ST 2,984). For coho it is the lower
   gradient limit (5,045 km) and then the floor (3,613).
2. **The gains are the exception, the gradient limits and coho's floor.** CH gains 12,221 km through its exception
   (8,931 of its 15,585 km gained are order 1); the raised limits add 35,500 km of stream between 5.49 and 13 % for BT
   spawning (its rule contains `default`: the same 2 m width, nothing lost; 35,652 of the gain is order 2 and up),
   11,402 km for RB, 3,090 for WCT and 2,107 for BT rearing; coho's 0.03 m³/s floor admits 5,063 km of streams under
   1.5 m wide (5,048 of coho's 5,546 km gained are order 1), and WCT's 1,165. Connectivity and the overlay move under 1,000 km for every key.
3. **Graded km falls with km except for chinook**: chinook's tuned 84,294 km carry 53,957
   graded km against `default`'s 48,134 on 99,186, the rule trading small low-grade streams for the near-river
   exception. Bull trout rearing's
   rule sheds the grade's low end (its 0–0.2 class 88,869 → 46,407 km) and its 0.8–1 class rises (49,466 → 50,485). The
   grade is fitted on the same visits, so this is consistency, not a check.
4. **Checks** (`checks.csv`). FDIS detection on each rule's segments against accessible segments outside it,
   `default` then tuned (door): RB 33.7 % against 15.2 %, then 35.0 against 16.4; BT rearing 16.7 against 6.2, then
   21.4 against 7.5; CH 13.6 against 2.2, then 16.7 against 1.3; CO 29.1 against 12.9, then 33.0 against 11.1; GR 15.0
   against 5.0, unchanged; ST 4.8 against 0.7, then 7.8 against 0.6; WCT 34.6 against 23.4, then 33.3 against 17.9. On
   the bcfishobs records FDIS does not hold (A/B matches, presence only, never scored), the share of their locations on
   accessible stream edges that falls on the rule's segments, over the rule's share of accessible stream-edge km, rises
   under every tuned rule but two: RB 2.34 → 3.03, BT rearing 2.45 → 5.42, CH 2.46 → 3.11, CO 1.75 → 1.82, ST 2.19 →
   4.08, GR 3.56 unchanged; BT spawning 3.04 → 3.03 (−0.02, interval −0.12 to +0.07: the added km hold records at
   `default`'s density) and WCT 1.56 → 1.46 (−0.10, −0.14 to −0.06: the added km hold fewer). The tuned rules hold more
   of the independent records per kilometre they draw, which is what the score rewards; it is not a claim about extent,
   and the lift rises as a rule narrows (BT rearing's 5.42 against 3.81 for its 2026-10-23 pick).

**Maps and the floodplain table were not redrawn for #73** (`0330 STAGE=maps`); both are #65's, on the run's own configs
and the picks of 2026-10-19 (`width>=3|g<=0.09` for RB, `mad>=0.35|g<=0.1049` for BT rearing, and so on), and are kept
here as the record of that reading.

**Maps.** `research/fig/compare_<sp>_<stage>_<wsg>.png` for every floodplain-catalog group the species covers and
three groups per species chosen by criteria fixed before drawing (largest gained share, largest lost share, most
`default` km): habitat by rule (kept, lost, gained), grade class, and the floodplain shaded by its segment's grade.
`data/compare/maps/` holds the interactive pages (ignored). `data/compare/gpkg/<key>.gpkg` (ignored) is #73's view
of each comparison for QGIS (#81).

**Floodplain as a unit** (`data/compare/floodplain.csv`, #65). For the 23 groups whose whole-network floodplain the
stac-floodplains-bc catalog holds (`<wsg>_all_ff04`; NewGraphEnvironment/floodplains#123 for the rest),
`knw_floodplain_ha()` gives every 30 m floodplain cell one owning segment, the nearest among the claiming blue
lines' segments through `flooded::fl_valley_join()`, and sums hectares beside each rule's habitat; graded ha is
ha × the owning segment's grade. Hectares beside accessible stream are the group's whole accessible floodplain.

| species × stage | catalog groups | ha beside accessible stream | beside `default` habitat | beside tuned | change | graded ha, `default` → tuned |
|---|---|---|---|---|---|---|
| RB rearing | 23 | 781,723 | 663,464 | 560,759 | −15 % | 273,535 → 243,741 |
| BT rearing | 22 | 894,237 | 746,145 | 565,706 | −24 % | 260,172 → 216,596 |
| BT spawning | 22 | 894,237 | 354,423 | 275,002 | −22 % | 253,726 → 199,664 |
| CH rearing | 16 | 588,216 | 426,681 | 340,929 | −20 % | 206,011 → 207,639 |
| CO rearing | 10 | 329,838 | 272,429 | 242,163 | −11 % | 168,866 → 158,795 |
| GR rearing | 3 | 137,000 | 96,530 | 96,530 | 0 | 32,386 → 32,386 |
| ST rearing | 4 | 143,349 | 108,807 | 74,948 | −31 % | 35,822 → 34,802 |
| WCT rearing | 4 | 129,911 | 122,584 | 117,691 | −4 % | 89,778 → 85,858 |

Set against the km on the same catalog groups on #65's run, the floodplain fell less than the km for BT rearing (24 %
against 37 %), CO (11 against 14), RB (15 against 20), ST (31 against 45) and WCT (4 against 24): the streams those
rules dropped carried less floodplain per km than the habitat `default` draws. For CH (20 against 19) and BT spawning
(22 against 19) the two fell about together. Graded ha followed graded km, rising only for CH. (Revised 2026-10-18,
#62: this paragraph first compared catalog-group floodplain with all-group km. Revised 2026-10-19, #65: graded km and
ha are from the regrade, every segment at its own distance and the reference over the stream branch, on the flows wet
republished that day. The flow republish also moved each MAD rule's habitat by under 0.3 % (BT spawning −231 km, CH
+34, ST +60, BT rearing −49, CO −9); every moved verdict is a segment whose flow crossed the floor or whose exception
distance crossed its limit, or a connectivity cascade from one. Width rules did not move.) #73's picks differ from #65's for
BT rearing, BT spawning, CH, RB and WCT, so those rows no longer describe the recommended rule.

## Limits

- **Juveniles, electrofished, on the stream branch.** Spawning has a response for char only, and that one is weak.
  River polygons, wetlands and lakes keep `default`'s tests under every rule.
- **The score rewards separation, not extent** (as #54 said): the tuned rules are narrower than `default` where
  the floor moves up.
- **Thin rows, and the rows with no grade.** ST (82 detections, 11 groups) and WCT (6 groups) carry their labels;
  BT spawning should not be applied. BT spawning, CO, ST and WCT publish a rule and no grade: their curves predict
  held-out groups worse than one constant rate on the visits they were fitted to, so they could not rank segments. Steelhead's
  curve was measured (`steelhead_rearing_tuned.md`): the prior fixed half its gap, and the joint smooth overfits one
  group that holds a third of its detections.
- **The grade off the stream branch is an extrapolation.** The curve was fitted on stream-branch visits
  outside lakes, wetlands and river polygons; a river-polygon segment often reads it at 0 m from the river it is
  part of (48 % of river-polygon km within 1 m for GR, 79 % for CH on #65's grades) and at flows few visits had, so its
  grade rests on the surface past its data: on #73's grades, CH's river-polygon lines are 43,497 of its 224,459 graded
  km and 31,542 of them grade 0.8 or more, against 9,684 of the stream branch's 147,668. Main-flow lines through lakes
  and wetlands (edge type 1200) read their river within 1 m on 10–18 % of their graded km (WCT 62 %), and 4–34 % of
  their km grades 0.8 or more (WCT 79 %); off the stream branch is 24–36 % of each key's graded km and 21–79 % of its
  km at 0.8 or more (#65's measurement, `check_off_branch.txt` in its archive, not repeated for #73), so
  `habitat_grade/v1` carries `stream_branch` to say which segments the curve's visits support. The reference is taken
  over the stream branch so that river polygons do not set it: over every accessible segment, they would make up
  66–89 % of the top 5 % for CH, CO, ST and WCT and raise the reference 1.4 to 4 times (CH's from 0.14 to 0.52, leaving
  0.4 % of stream km at 0.8 or more); for BT, GR and RB they are 19–34 % of it and the two references are within 7 %
  (#65).
- **Distance is to the river's bank (#73).** The walk (`inst/sql/ch_dist_profile.sql`) ends where a tributary meets a
  double-line river, by fresh 0.42.0's rule: a connector inside the river's polygon (edge type 1400/1450) is never a
  target, the connector run and the jump's crossing inside the target's polygon are left out, and every other hop's
  gap counts. Checked against fresh's own walk on BULK (`data-raw/walk_bank_check.R`, 2,460 starts): 0 differ by the
  bank rule, 92.6 % of the 2,006 starts both walks found agree within 0.01 m, and the rest are the two walks' entry
  conventions. The correction is positive on 67 % of found starts, median 31.8 m, 90th percentile 66.1 m, largest
  599 m (#65 had estimated the connector at a median of 14–88 m). A distance of 0 still occurs where the segment is
  itself a river-polygon line or sits at the bank (BT rearing 53,897 graded km, CH 51,257), where the curve is read past
  its data. #65's measurement of the centreline walk is in its archive (`check_connector_share.txt`).
- **Width rules leave first-order streams ungraded**; a consumer summing graded km over a width-ruled species
  (GR, RB) sums measured streams only.
- **One link run, one flow load.** Every grade carries `run_uid 20261017_004619-3f4c713b`; link recomputed UPET twice
  after the waiter released and before the build read, and the build's UPET visits place identically on the result.
  Every grade table records the flow load it was read on (wet `94deeb5`, built 2026-10-19), and `0325` refuses to
  publish when the live table's comment names another; the schema the run read is the archived
  `fresh_default_20261017` (link#361 renamed it while #73 ran).
- **The access gate.** Grades and the comparison are gated on `streams_access`; link's `accessible` disagrees on
  1.6–3.5 % of habitat-accessible segments for most species, 17 % for RB and 90 % for KO (link#349), ledgered per
  run. For RB the disagreement is whole groups: in 23 of its 210 groups (BRID CANO CARP CLRH CRKD FINA FINL FIRE
  FOXR INGR LEUT LOMI MAHD MESI MURT NATR OSPK PARA PARS PCEA TURN UEUT UOMI; 37,895 km of stored rearing) every
  segment has `access_rb = 0`, and two more (TOOD, UNRS) draw no km under `default`, so 25 groups carry no graded and
  no compared RB km; GR has three groups with no km (BULL ELKR TURN) and BT one (TURN).
- **Regenerated, not stored.** The comparison's `default` is fresh's predicate rerun, which differs from the flags
  link stores by 55,242 km for RB, 9,243 for BT rearing, 2,942 for CH, 2,142 for GR, 1,932 for CO, 1,674 for ST, 1,497
  for BT spawning and 196 for WCT (`compare.csv`, `stored_vs_default_differ_km`); the stored flags are not what any rule
  here is compared with, and `default`'s CH rearing has no rows in link's own log, so its stored flags are never the
  reference (CLAUDE.md, "link's CH rearing").
