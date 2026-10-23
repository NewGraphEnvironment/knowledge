# Habitat thresholds tuned for every species and life stage in one run

**Verified:** 2026-10-17; the grade, graded figures and rule km regraded and recompared 2026-10-19 (#65, on the
flows wet republished that day; retuning on them is #73); the `stream_branch` flag and the connector measure
2026-10-20 (#65); the one-SE wording and the picks at 1.96 SE 2026-10-20 (#79) · **Issues:** #57 (this; replaced #59), #65, #79; the one-species tunings it supersedes are #28
(`habitat_weights.md`), #33 (`bt_spawning.md`), #52 (`chinook_stream_size.md`) and #54
(`chinook_rearing_tuned.md`); link reads the result through NewGraphEnvironment/link#346 · **Produced by:**
- `scripts/0300`: the wait for link's province-wide `default` run (`scripts/logs/habitat/20261017_link_settle.csv`);
- `scripts/0310`: the evidence build (`scripts/logs/habitat/20261017_evidence_build_ledger.csv`; tables published as
  `knowledge/fdis/v3`);
- `scripts/0320`: the tuning run (`data/tune/<sp>_<stage>_{tune,curves,groups,summary}.csv`; logs
  `scripts/logs/habitat/20261017_tune_run-*`; #65's regrade `20261019_tune_run.{txt,out}`, after the superseded
  `20261019_tune_run-ch.txt`);
- `scripts/0325`: `data/thresholds.csv`, `data/thresholds_groups.csv`, and the Parquet sets `knowledge/thresholds/v1`
  and `knowledge/habitat_grade/v1`;
- `planning/archive/2026-10-issue-65-grade-walks-every-segment/check_{off_branch,connector_share}.R`: the grade off
  the stream branch and the connector's share of the walked distance (Limits);
- `scripts/0330`: `data/compare/*.csv` (`compare`, `change`, `checks`, `floodplain`), `research/fig/compare_*.png`
  (the comparison; below; logs `scripts/logs/habitat/20261017_compare*`, and #65's `20261019_compare.txt`).

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
boundary of noise), and recommended the one of those closest to link's current test. link's current test is not among them for any fitted species but grayling, and every recommended
rule but grayling's draws less habitat than link does now. A grade from 0 to 1 then gives the use to expect on
each segment, read at that segment's own distance to a river (#65 corrected a first build that read most segments at
the distance cap). The package article on chinook rearing (https://newgraphenvironment.github.io/knowledge/articles/chinook_rearing.html) walks through one species from the question to
the map; the specification below is the record.

## The question

link's `default` draws habitat as on/off at a size floor and a gradient maximum per species and stage, set from
bcfishpass and the literature. #28 and #54 tuned two of those rules one species at a time, each with its own
build and its own scripts, on the 55 groups link had run. link's province-wide `default` run
(NewGraphEnvironment/link#246, `run_uid 20261017_004619-3f4c713b`, 241 groups) makes one build and one run
possible: which rule does the electrofishing evidence support for each species and stage, how far can each value
move before the data can tell, and what does a segment just inside or just outside a cut deserve?

## Evidence

FDIS electrofishing site visits (`fdis_export.md`), placed on link's segments: 51,587 visits, 40,552 placed, one
row per visit and species with catch, size classes, presence and whether an absence is blocked by a code that
could hide the species (`knw_fdis_species()`). Each visit carries link's access code and habitat flags per
species (re-gated on `streams_access`; link#349's disagreement is ledgered per run), wet's annual flow by source
(`modelled_discharge.md`), the width link reads on an unmeasured stream, regulated reach, the natural barriers
downstream per species, and walks to the first river of 1–50 m³/s on each flow source. Presence-only bcfishobs
records never score a rule; `knw_bcfishobs_match()` ties 24,000 of them to their FDIS visits by collection,
species and date, and the rest give the outside check. The Fish Data Submission workbooks add 871 placed sites,
92 of them with electrofishing effort.

## Method (0297's spec, fixed for CH before its first fit, carried to every species)

- **Population per species × stage:** stream-branch visits (stream edges in no river polygon, wetland ≥ 1 ha or
  lake ≥ 100 ha), 10–10,000 m² fished, in groups where link marks the species present, no code blocking its
  absence, no natural barrier to it downstream. Rearing's response is detection; spawning's is spawner evidence
  from maturity codes, which only char carry.
- **Grid** around link's own `default` thresholds: a size test (MAD floor 0.1–1 m³/s or width floor 1–4 m, the
  species' own values joining the ladder), a gradient maximum (3–9 % plus the species' own), and an exception
  admitting a segment that fails the size test when a river of Q ∈ {1…50} m³/s lies within D ∈ {100…5,000} m
  downstream. 2,795 rules for CH; a species whose `default` has no stream rule (KO, SK: lake rearing only) has no grid.
- **Score:** held-out binomial deviance (cloglog, with log area, data set, era and the group), five stratified
  group folds, each group held out once, each held-out group refitting only its own intercept. The **region** is
  every rule within one SE of the best (the group is the unit), a parsimony rule of thumb fixed before the run, not a
  boundary of noise ("At 1.96 SE", below); the **pick** is the region rule with the fewest
  departures from `default`; `recommended` moves off an exception under 200 m. A 200-resample group bootstrap, a
  nested selection and four more fold seeds measure stability. A species × stage fits with ≥ 5 groups having both
  outcomes and is `underpowered` under 10.
- **Curve:** one GAM per species × stage after the pick, `te(log size, log distance to the pick's river)` +
  `s(gradient)` with the same nuisance terms and a group random effect; held-out deviance on the same folds.
- **Grade:** the curve's predicted rate at the reference nuisance values (group effect excluded) over the 95th
  percentile of the rate on accessible stream-branch segments (the edge types of the curve's visits; since #65),
  capped at 1, in fifths. Expected use per standard electrofishing
  visit, not habitat quality. A segment with no size (an unmeasured first-order stream under a width rule) or no
  gradient is `NA`, counted. Every accessible segment with a gradient is walked from its downstream end to the
  first river of the pick's exception flow (10 m³/s where the pick has no exception), on any edge type and at any gradient,
  because the curve reads size and distance together; a walk that reaches the sea first, or stops, reads the
  50 km cap, as the curve's visits did (`dist_status` in the grade table says which). #57's first build walked
  only the segments the exception could admit and read every other segment at the cap (#65).

## Results

| species × stage | visits (detections), groups | recommended rule | region | `default` | pick holds in | power |
|---|---|---|---|---|---|---|
| BT rearing | 8,717 (1,198), 75 | MAD ≥ 0.35, ≤ 10.49 %, none | 196 rules: MAD 0.1–0.5, 9–10.49 % | out, +138.7 (SE 87.8) | 5 of 5 seeds | fitted |
| BT spawning | 475 (98), 22 | MAD ≥ 0.75, ≤ 5.49 %, Q3 within 2 km | 18: MAD 0.15–1, 4–9 %, Q 1–5, D 0.5–2 km | out, +44.0 (SE 41.6) | 1 of 5 | fitted, **weak** |
| CH rearing | 4,490 (215), 43 | MAD ≥ 0.75, ≤ 13 %, Q3 within 1 km | 83: MAD 0.15–1, 7–30 %, Q 1–10, D 0.5–2 km | out, +226.4 (SE 91.8) | 5 of 5 | fitted |
| CO rearing | 4,263 (1,107), 62 | MAD ≥ 0.03, ≤ 4 %, none | 89: MAD 0.03–0.2, 3–4 % (one at 7 %) | out, +111.8 (SE 47.4) | 5 of 5 | fitted |
| GR rearing | 1,230 (212), 26 | **`default`** (width ≥ 1.5, ≤ 3.49 %) | 799: width 1–4, 3–9 % | **in**, +10.7 (SE 12.1) | 3 of 5 | fitted |
| RB rearing | 12,959 (3,513), 129 | width ≥ 3, ≤ 9 %, none | 81: width 2–3, 7–9 % | out, +150.6 (SE 63.9) | 2 of 5 | fitted |
| ST rearing | 1,375 (82), 11 | MAD ≥ 1, ≤ 8.49 %, none | 330: MAD 0.35–1, 3–9 % | out, +42.4 (SE 29.9) | 4 of 5 | fitted |
| WCT rearing | 1,157 (536), 6 | width ≥ 1.5, ≤ 4 %, none | 677: width 1–4 or MAD ≥ 0.28, 3–9 % | out, +17.8 (SE 13.4) | 5 of 5 | underpowered |
| CH, CO, GR, RB, ST, WCT spawning | — | — | — | — | — | no electrofishing response |
| KO, SK rearing; CM, PK | — | — | — | — | — | no stream rule in `default` |

The CH and CO rows are #73's retune (2026-10-23: the evidence rebuilt on wet's 2026-10-19 flows, the walk to the bank,
the ladder to 30 %, 6,149 and 6,622 rules); the other rows are #57's until #73 reruns them.

Three readings across the table:
1. **`default` is outside the one-SE region for every fitted species but grayling.** For BT, CH, CO and ST the
   evidence prefers sizing streams by flow (a MAD floor) to `default`'s 1.5 m width; for RB and WCT it keeps
   width. Where the floor moves it moves up for CH (0.75), BT (0.35) and ST (1 m³/s) and down to the bottom of
   the grid for CO (0.03), whose juveniles rear in the smallest streams.
2. **The gradient maximum moves both ways:** up to 9 % for CH and RB, down to 4 % for CO and WCT, unchanged for
   BT (10.49 %) and GR (3.49 %). For CH and RB, 9 % is the top of the shared ladder. CH alone, scored again on a
   ladder to 30 % (#67, `chinook_rearing_tuned.md`), moves its best rule to 15 %, and every limit from 7 to 30 %
   has rules in the region; `CH_rear_v1` keeps 9 % until every species is tuned on the longer ladder (#68).
3. **Only CH's rule needs the near-a-river exception** on the main reading; BT spawning's does too, but that row
   is weak (its raw rates do not separate, and nested selection puts the pick behind `default`).

### At 1.96 SE (#79, 2026-10-20)

One standard error is a rule of thumb, not a test. Its sources are Breiman et al. 1984, who proposed it for pruning trees, as cited in Chen & Yang 2021, §1.3, since no copy is held; Hastie, Tibshirani & Friedman 2009, pp. 61 and 244, whose only rationale is that the curve "is estimated with error, and hence takes a conservative approach". Chen & Yang (2021, §6) find "no evidence
confirming that the 1se rule can consistently outperform the regular CV", with an SE that can be off by 100 % either
way; no unbiased estimator of K-fold cross-validation's variance exists (Bengio & Grandvalet 2004), and the usual
estimate is too small (Bates, Hastie & Tibshirani 2024). The threshold was fixed before the run and is kept. Replayed
from the saved tables with the same pick at 1.96 SE (`knw_tune_repick()` on `data/tune/<sp>_<stage>_tune.csv`, the
main ladders; #67's ladder to 30 % is not replayed):

| species × stage | `default` behind the best, in SEs | pick at 1 SE | pick at 1.96 SE | rules within 1 SE → 1.96 SE, of |
|---|---|---|---|---|
| BT rearing | 1.58 | MAD ≥ 0.35, ≤ 10.49 % | `default` | 196 → 1,066, of 3,612 |
| BT spawning | 1.06 | MAD ≥ 0.75, ≤ 5.49 %, a ≥ 3 m³/s river within 2 km | `default` | 18 → 3,010, of 3,010 |
| CH rearing | 2.47 | MAD ≥ 0.75, ≤ 13 %, a ≥ 3 m³/s river within 1 km | MAD ≥ 1, ≤ 5.49 %, a ≥ 3 m³/s river within 1 km | 83 → 2,066, of 6,149 |
| CO rearing | 2.36 | MAD ≥ 0.03, ≤ 4 % | width ≥ 1.5, ≤ 4 % | 89 → 1,507, of 6,622 |
| GR rearing | 0.89 | `default` | `default` | 799 → 3,493, of 3,612 |
| RB rearing | 2.36 | width ≥ 3, ≤ 9 % | width ≥ 3, ≤ 8.49 % | 81 → 323, of 3,612 |
| ST rearing | 1.42 | MAD ≥ 1, ≤ 8.49 % | `default` | 330 → 3,307, of 3,612 |
| WCT rearing | 1.33 | width ≥ 1.5, ≤ 4 % | `default` | 677 → 3,010, of 3,612 |

- **Five of eight keep `default` at 1.96**, and three move off it: CH, CO and RB. For BT spawning, GR, ST and WCT the
  1.96 region holds most or all of the grid, so keeping `default` there says the stricter bar cannot separate the
  rules, not that the records support `default`.
- **CH keeps a flow floor and the exception at `default`'s 5.49 %** (MAD ≥ 1 from the width start, 0.28 from link's
  flow start, #73; before the retune the 1.96 pick had dropped the exception), and `default` stays outside, 2.47 SEs
  behind. RB keeps its 3 m width floor at `default`'s gradient; CO goes back to width at its 4 % gradient.
- `data/thresholds.csv` carries the 1.96 pick per rule as `rule_196`, and per component whether it keeps the value
  as `holds_196` (a size row also needs the same size variable). A component equal to `default`'s value holds
  trivially (BT rearing's 10.49 %), and a MAD row's `link_parameter` is not what a width rule at 1.96 would set.

**CH's open floor (#54) settles at 0.75 m³/s**, with 0.5 inside the region on all five seeds.

## Grades

| species × stage | segments (groups) | accessible km | graded km | grade-weighted km | reference rate | km under 0.2 | km at 0.8–1 |
|---|---|---|---|---|---|---|---|
| BT rearing | 8.41 M (158) | 577,130 | 571,305 | 151,418 | 0.226 | 63 % | 10 % |
| BT spawning | 8.41 M (158) | 577,130 | 571,305 | 392,475 | 0.210 | 0.2 % | 23 % |
| CH rearing | 5.76 M (125) | 225,152 | 224,459 | 61,423 | 0.136 | 68 % | 21 % |
| CO rearing | 4.92 M (100) | 147,795 | 146,612 | 72,637 | 0.520 | 19 % | 23 % |
| GR rearing | 4.21 M (82) | 258,724 | 146,128 | 72,867 | 0.034 | 25 % | 25 % |
| RB rearing | 10.33 M (210) | 510,150 | 277,539 | 121,816 | 0.445 | 27 % | 15 % |
| ST rearing | 4.14 M (79) | 155,481 | 154,855 | 32,290 | 0.201 | 76 % | 14 % |
| WCT rearing | 1.19 M (16) | 35,320 | 25,932 | 18,671 | 0.473 | 6 % | 52 % |

The CH and CO rows are #73's grades (2026-10-23: each segment walked to the river's bank, the reference over edge types
1000, 1100, 2000 and 2300, CH under its new pick); the other rows are #65's until #73 regrades them.

A width rule grades only measured streams: fwapg models width where `stream_order > 1`, so GR, RB and WCT leave
every unmeasured first-order stream `NA` (RB: 6.26 M of 10.33 M segments). A MAD rule grades almost everything
(BT: 33,992 segments with no flow even from a parent).

Revised 2026-10-19 (#65). #57's grades read every segment the exception could not admit at the 50 km distance
cap, and six of the eight keys walked no segment at all; every segment now reads its own distance, and the
reference is the stream branch's 95th percentile. The regrade also reads the flows wet republished on
2026-10-19 (NewGraphEnvironment/wet#103, about ±5 % on most segments; BT gains 4 segments with no flow), after
the thresholds were tuned on the load before it (#73 retunes). The references move by under 1 % (CO) and 2 % (GR)
to 25 % (BT rearing, up); CH's grade-weighted km grows by three quarters (36,149 → 63,059) and its km at 0.8–1 triples.

## What each rule changes on link's segments

`scripts/0330` regenerates `default` and the tuned rule through fresh's predicate, the user-habitat overlay and
connectivity on scratch copies of every group the species' habitat table covers (`knw_compare_rules()`; the
regenerated `default` equals fresh's own predicate on every segment), and reads the grade beside each segment.
Kilometres are accessible stream under `streams_access`, flagged rearing or spawning by each rule; graded km is
km × grade (`data/compare/compare.csv`, `change.csv`, `checks.csv`).

| species × stage | accessible km | `default` km | tuned km | change | lost | gained | graded km, `default` → tuned |
|---|---|---|---|---|---|---|---|
| RB rearing | 509,975 | 227,089 | 183,988 | −19.0 % | 44,368 | 1,267 | 103,160 → 90,429 |
| BT rearing | 576,908 | 248,927 | 156,091 | −37.3 % | 94,199 | 1,363 | 105,605 → 77,856 |
| BT spawning | 576,908 | 133,382 | 99,555 | −25.4 % | 56,411 | 22,585 | 88,070 → 62,266 |
| CH rearing | 225,152 | 101,184 | 88,641 | −12.4 % | 24,832 | 12,289 | 49,434 → 54,443 |
| CO rearing | 147,795 | 81,629 | 77,603 | −4.9 % | 9,215 | 5,189 | 49,790 → 49,570 |
| GR rearing | 258,576 | 77,740 | 77,740 | 0 | 0 | 0 | 44,602 → 44,602 |
| ST rearing | 155,357 | 71,619 | 45,274 | −36.8 % | 26,677 | 332 | 22,498 → 20,730 |
| WCT rearing | 35,285 | 20,749 | 16,243 | −21.7 % | 4,510 | 4 | 14,939 → 11,277 |

1. **Every tuned rule but grayling's draws less than `default`**, from 5 % less for coho to 37 % less for bull
   trout rearing and steelhead. The loss is the size floor: segments over 1.5 m wide that fail the tuned flow or
   width floor with no exception (BT rearing 93,376 of its 94,199 km lost, RB all 44,368, ST 26,284 of 26,677,
   CH 24,532 of 24,832). For coho and cutthroat it is the lower gradient maximum (5,047 and 4,332 km).
2. **The gains are the exception and coho's floor.** BT spawning gains 21,807 km through its river-within-2-km
   exception, 15,617 of them order-1 streams, and CH 9,665 km (6,948 order 1); coho's 0.03 m³/s floor admits
   5,077 km of streams under 1.5 m wide (4,653 order 1). Connectivity and the overlay move under 1,000 km for
   every species.
3. **Graded km falls with km except for chinook**, whose tuned 88,641 km carry 54,443 graded km against
   `default`'s 49,434 on 101,184: the rule trades small low-grade streams for the near-river exception.
4. **Checks** (`checks.csv`). FDIS detection on each rule's segments against accessible segments outside it,
   `default` then tuned: RB 33 % against 15 %, then 35 % against 18 %; BT rearing 17 against 6, then 21 against
   8; CH 14 against 2, then 17 against 1.5; CO 29 against 13, then 32 against 11; ST 4.8 against 0.7, then 7.5
   against 0.6; WCT 35 against 24, then 35 against 27. On the bcfishobs records FDIS does not hold (A/B matches, presence only,
   never scored), the share of their locations on accessible stream edges that falls on the rule's segments, over the
   rule's share of accessible stream-edge km, rises under every tuned
   rule: RB 2.34 → 3.04, BT rearing 2.45 → 5.21, BT spawning 3.04 → 3.70, CH 2.46 → 3.26, CO 1.75 → 1.82,
   ST 2.20 → 4.08, WCT 1.56 → 1.73 (bootstrap intervals in the table). The tuned rules hold more of the
   independent records per kilometre they draw, which is what the score rewards; it is not a claim about extent.

**Maps.** `research/fig/compare_<sp>_<stage>_<wsg>.png` for every floodplain-catalog group the species covers and
three groups per species chosen by criteria fixed before drawing (largest gained share, largest lost share, most
`default` km): habitat by rule (kept, lost, gained), grade class, and the floodplain shaded by its segment's grade.
`data/compare/maps/` holds the interactive pages (ignored).

**Floodplain as a unit** (`data/compare/floodplain.csv`). For the 23 groups whose whole-network floodplain the
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

Set against the km on the same catalog groups (`compare.csv`'s rows for those groups; the km table above is over
every group), the floodplain falls less than the km for BT rearing (24 % against 37 %), CO (11 against 14), RB (15
against 20), ST (31 against 45) and WCT (4 against 24): the streams those rules drop carry less floodplain per km
than the habitat `default` draws. For CH (20 against 19) and BT spawning (22 against 19) the two fall about
together. Graded ha follows graded km, rising only for CH. (Revised 2026-10-18, #62: this paragraph first
compared catalog-group floodplain with all-group km. Revised 2026-10-19, #65: graded km and ha are from the
regrade, every segment at its own distance and the reference over the stream branch, on the flows wet
republished that day; #57's grades read most segments at the 50 km distance cap. The flow republish also moved
each MAD rule's habitat by under 0.3 % (BT spawning −231 km, CH +34, ST +60, BT rearing −49, CO −9); every moved
verdict is a segment whose flow crossed the floor or whose exception distance crossed its limit, or a
connectivity cascade from one. Width rules did not move.)

## Limits

- **Juveniles, electrofished, on the stream branch.** Spawning has a response for char only, and that one is weak.
  River polygons, wetlands and lakes keep `default`'s tests under every rule.
- **The score rewards separation, not extent** (as #54 said): the tuned rules are narrower than `default` where
  the floor moves up.
- **Thin rows.** ST (82 detections, 11 groups) and WCT (6 groups) carry their labels; BT spawning should not be
  applied. For ST and GR the joint curve predicts worse than the cut on held-out groups, so their grades rank
  segments but their rates are not to be read.
- **The grade off the stream branch is an extrapolation.** The curve was fitted on stream-branch visits
  outside lakes, wetlands and river polygons; a river-polygon segment often reads it at 0 m from the river it is
  part of (48 % of river-polygon km within 1 m for GR, 79 % for CH) and at flows few visits had, so its grade rests
  on the surface past its data: for CH, 77 % of river-polygon km grades 0.8 or more and 69 % reads 1. Main-flow
  lines through lakes and wetlands (edge type 1200) read their river within 1 m on 10–18 % of their graded km
  (WCT 62 %), and 4–34 % of their km grades 0.8 or more (WCT 79 %). Off the stream
  branch is 24–36 % of each key's graded km and 21–79 % of its km at 0.8 or more, far above its share for CH (79 %),
  ST (70 %) and CO (66 %) and below it for BT spawning, GR and RB, so `habitat_grade/v1` carries `stream_branch` to
  say which segments the curve's visits support (`check_off_branch.txt` in #65's archive).
  The reference is taken over the stream branch so that river polygons do not set it: over every accessible
  segment, they would make up 66–89 % of the top 5 % for CH, CO, ST and WCT and raise the reference 1.4 to 4 times
  (CH's from 0.14 to 0.52, leaving 0.4 % of stream km at 0.8 or more); for BT, GR and RB they are 19–34 % of it
  and the two references are within 7 % (#65).
- **Distance is to the river's main line, not its bank.** Where a tributary meets a double-line river, its line
  usually crosses the polygon as a connector (edge type 1450) to the river's centreline, and the connector carries
  the tributary's flow, so the walk counts it, for visits and segments alike. Of the curves' visit sites whose walk
  found a river, 59–94 % per key end on a double-line river. Of those whose tributary could be traced (97–99 %),
  89–96 % have a connector, which adds a median of 14–88 m (90th percentile 38–324 m), a median 0–2 % of the
  site's distance. The rest (4–11 %) have none: 31–96 % of them hop no gap of 1 m or more on the way, and the others
  hop one somewhere on the walk, which the walk does not count. Measured to the bank instead, 22 of the 2,260 traced
  CH sites would fall inside its 1 km exception, and none of BT spawning's inside 2 km (`check_connector_share.txt`
  in #65's archive). Ending the walk at the bank changes the visits' distances, so it waits for the retune (#73).
- **Width rules leave first-order streams ungraded**; a consumer summing graded km over a width-ruled species
  sums measured streams only.
- **One link run.** Every grade carries `run_uid 20261017_004619-3f4c713b`; link recomputed UPET twice after the
  waiter released and before the build read, and the build's UPET visits place identically on the result.
- **The access gate.** Grades and the comparison are gated on `streams_access`; link's `accessible` disagrees on
  1.6–3.5 % of habitat-accessible segments for most species, 17 % for RB and 90 % for KO (link#349), ledgered per
  run. For RB the disagreement is whole groups: in 23 of its 210 groups (BRID CANO CARP CLRH CRKD FINA FINL FIRE
  FOXR INGR LEUT LOMI MAHD MESI MURT NATR OSPK PARA PARS PCEA TURN UEUT UOMI; 37,895 km of stored rearing) every
  segment has `access_rb = 0`, so they carry no graded and no compared RB km; GR has three such groups (BULL ELKR
  TURN) and BT one (TURN).
- **Regenerated, not stored.** The comparison's `default` is fresh's predicate rerun, which differs from the flags
  link stores by 45,970 km for RB, 2,659 for BT, 2,142 for GR and under 125 km for the rest (`compare.csv`,
  `stored_vs_default_differ_km`); the stored flags are not what any rule here is compared with.
