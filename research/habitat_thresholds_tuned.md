# Habitat thresholds tuned for every species and life stage in one run

**Verified:** 2026-10-17 · **Issues:** #57 (this; replaced #59); the one-species tunings it supersedes are #28
(`habitat_weights.md`), #33 (`bt_spawning.md`), #52 (`chinook_stream_size.md`) and #54
(`chinook_rearing_tuned.md`); link reads the result through NewGraphEnvironment/link#346 · **Produced by:**
- `scripts/0300`: the wait for link's province-wide `default` run (`scripts/logs/habitat/20261017_link_settle.csv`);
- `scripts/0310`: the evidence build (`scripts/logs/habitat/20261017_evidence_build_ledger.csv`; tables published as
  `knowledge/fdis/v3`);
- `scripts/0320`: the tuning run (`data/tune/<sp>_<stage>_{tune,curves,groups,summary}.csv`; logs
  `scripts/logs/habitat/20261017_tune_run-*`);
- `scripts/0325`: `data/thresholds.csv`, `data/thresholds_groups.csv`, and the Parquet sets `knowledge/thresholds/v1`
  and `knowledge/habitat_grade/v1`;
- `scripts/0330`: `data/compare/*.csv` (`compare`, `change`, `checks`, `floodplain`), `research/fig/compare_*.png`
  (the comparison; below; logs `scripts/logs/habitat/20261017_compare*`).

**Status:** measured; nothing applied in link. One file per species holds the species' reading:
`bull_trout_tuned.md`, `chinook_rearing_tuned.md` (#54's file, with the province-wide rescoring at its head),
`coho_rearing_tuned.md`, `grayling_rearing_tuned.md`, `rainbow_rearing_tuned.md`, `steelhead_rearing_tuned.md`,
`westslope_cutthroat_rearing_tuned.md`.

**In plain words.** link calls a stream segment rearing or spawning habitat for a species with a yes-or-no
test: big enough, and not too steep. This run asked, for each species and life stage the electrofishing record
can speak to, which version of that test best predicts where the fish were caught in watersheds held out of the
fit. For each one it tried a ladder of size floors (by flow or by width) and gradient limits, and, for small
streams, an allowance for a river close downstream. It scored every version on held-out watershed groups,
kept every version the data cannot tell from the best, and recommended the one of those closest to link's
current test. link's current test is not among them for any fitted species but grayling, and every recommended
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
  every rule within one SE of the best (the group is the unit); the **pick** is the region rule with the fewest
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
| CH rearing | 4,490 (215), 43 | MAD ≥ 0.75, ≤ 9 %, Q3 within 1 km | 23: MAD 0.35–1, 7–9 %, Q 1–10, D 1–2 km | out, +196.3 (SE 81.6) | 5 of 5 | fitted |
| CO rearing | 4,263 (1,107), 62 | MAD ≥ 0.03, ≤ 4 %, none | 87: MAD 0.03–0.2, 3–4 % | out, +113.2 (SE 45.8) | 4 of 5 | fitted |
| GR rearing | 1,230 (212), 26 | **`default`** (width ≥ 1.5, ≤ 3.49 %) | 799: width 1–4, 3–9 % | **in**, +10.7 (SE 12.1) | 3 of 5 | fitted |
| RB rearing | 12,959 (3,513), 129 | width ≥ 3, ≤ 9 %, none | 81: width 2–3, 7–9 % | out, +150.6 (SE 63.9) | 2 of 5 | fitted |
| ST rearing | 1,375 (82), 11 | MAD ≥ 1, ≤ 8.49 %, none | 330: MAD 0.35–1, 3–9 % | out, +42.4 (SE 29.9) | 4 of 5 | fitted |
| WCT rearing | 1,157 (536), 6 | width ≥ 1.5, ≤ 4 %, none | 677: width 1–4 or MAD ≥ 0.28, 3–9 % | out, +17.8 (SE 13.4) | 5 of 5 | underpowered |
| CH, CO, GR, RB, ST, WCT spawning | — | — | — | — | — | no electrofishing response |
| KO, SK rearing; CM, PK | — | — | — | — | — | no stream rule in `default` |

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

**CH's open floor (#54) settles at 0.75 m³/s**, with 0.5 inside the region on all five seeds.

## Grades

| species × stage | segments (groups) | accessible km | graded km | grade-weighted km | reference rate | km under 0.2 | km at 0.8–1 |
|---|---|---|---|---|---|---|---|
| BT rearing | 8.41 M (158) | 577,130 | 571,305 | 151,418 | 0.226 | 63 % | 10 % |
| BT spawning | 8.41 M (158) | 577,130 | 571,305 | 392,475 | 0.210 | 0.2 % | 23 % |
| CH rearing | 5.76 M (125) | 225,326 | 224,459 | 63,059 | 0.139 | 67 % | 21 % |
| CO rearing | 4.92 M (100) | 147,962 | 146,612 | 70,905 | 0.512 | 22 % | 22 % |
| GR rearing | 4.21 M (82) | 258,724 | 146,128 | 72,867 | 0.034 | 25 % | 25 % |
| RB rearing | 10.33 M (210) | 510,150 | 277,539 | 121,816 | 0.445 | 27 % | 15 % |
| ST rearing | 4.14 M (79) | 155,481 | 154,855 | 32,290 | 0.201 | 76 % | 14 % |
| WCT rearing | 1.19 M (16) | 35,320 | 25,932 | 18,671 | 0.473 | 6 % | 52 % |

A width rule grades only measured streams: fwapg models width where `stream_order > 1`, so GR, RB and WCT leave
every unmeasured first-order stream `NA` (RB: 6.26 M of 10.33 M segments). A MAD rule grades almost everything
(BT: 33,992 segments with no flow even from a parent).

Revised 2026-10-19 (#65). #57's grades read every segment the exception could not admit at the 50 km distance
cap, and six of the eight keys walked no segment at all; every segment now reads its own distance, and the
reference is the stream branch's 95th percentile. The regrade also reads the flows wet republished on
2026-10-19 (NewGraphEnvironment/wet#103, about ±5 % on most segments; BT gains 4 segments with no flow), after
the thresholds were tuned on the load before it (#73 retunes). The references move by under 1 % (CO, GR) to
25 % (BT rearing, up); CH's grade-weighted km nearly doubles (36,149 → 63,059) and its km at 0.8–1 triples.

## What each rule changes on link's segments

`scripts/0330` regenerates `default` and the tuned rule through fresh's predicate, the user-habitat overlay and
connectivity on scratch copies of every group the species' habitat table covers (`knw_compare_rules()`; the
regenerated `default` equals fresh's own predicate on every segment), and reads the grade beside each segment.
Kilometres are accessible stream under `streams_access`, flagged rearing or spawning by each rule; graded km is
km × grade (`data/compare/compare.csv`, `change.csv`, `checks.csv`).

| species × stage | accessible km | `default` km | tuned km | change | lost | gained | graded km, `default` → tuned |
|---|---|---|---|---|---|---|---|
| RB rearing | 509,975 | 227,089 | 183,988 | −19.0 % | 44,368 | 1,267 | 115,119 → 101,860 |
| BT rearing | 576,908 | 248,927 | 156,141 | −37.3 % | 94,139 | 1,352 | 114,856 → 76,118 |
| BT spawning | 576,908 | 133,382 | 99,786 | −25.2 % | 56,284 | 22,688 | 66,216 → 43,559 |
| CH rearing | 225,152 | 101,184 | 88,607 | −12.4 % | 24,843 | 12,266 | 27,681 → 32,018 |
| CO rearing | 147,795 | 81,629 | 77,612 | −4.9 % | 9,184 | 5,167 | 48,879 → 48,516 |
| GR rearing | 258,576 | 77,740 | 77,740 | 0 | 0 | 0 | 46,831 → 46,831 |
| ST rearing | 155,357 | 71,619 | 45,214 | −36.9 % | 26,731 | 326 | 28,717 → 25,571 |
| WCT rearing | 35,285 | 20,749 | 16,243 | −21.7 % | 4,510 | 4 | 12,463 → 8,543 |

1. **Every tuned rule but grayling's draws less than `default`**, from 5 % less for coho to 37 % less for bull
   trout rearing and steelhead. The loss is the size floor: segments over 1.5 m wide that fail the tuned flow or
   width floor with no exception (BT rearing 93,316 of its 94,139 km lost, RB all 44,368, ST 26,337 of 26,731,
   CH 24,542 of 24,843). For coho and cutthroat it is the lower gradient maximum (5,059 and 4,332 km).
2. **The gains are the exception and coho's floor.** BT spawning gains 21,917 km through its river-within-2-km
   exception, 15,699 of them order-1 streams, and CH 9,666 km (6,952 order 1); coho's 0.03 m³/s floor admits
   5,056 km of streams under 1.5 m wide (4,634 order 1). Connectivity and the overlay move under 1,000 km for
   every species.
3. **Graded km falls with km except for chinook**, whose tuned 88,607 km carry 32,018 graded km against
   `default`'s 27,681 on 101,184: the rule trades small low-grade streams for the near-river exception.
4. **Checks** (`checks.csv`). FDIS detection on each rule's segments against accessible segments outside it,
   `default` then tuned: RB 33 % against 15 %, then 35 % against 18 %; BT rearing 17 against 6, then 21 against
   8; CH 14 against 2, then 17 against 1.5; CO 29 against 13, then 32 against 11; ST 4.8 against 0.7, then 7.5
   against 0.6; WCT 35 against 24, then 35 against 27. On the bcfishobs records FDIS does not hold (A/B matches, presence only,
   never scored), the share of their locations on accessible stream edges that falls on the rule's segments, over the
   rule's share of accessible stream-edge km, rises under every tuned
   rule: RB 2.34 → 3.04, BT rearing 2.45 → 5.17, BT spawning 3.04 → 3.70, CH 2.46 → 3.27, CO 1.75 → 1.82,
   ST 2.20 → 4.09, WCT 1.56 → 1.73 (bootstrap intervals in the table). The tuned rules hold more of the
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
| RB rearing | 23 | 781,723 | 663,464 | 560,759 | −15 % | 324,847 → 293,833 |
| BT rearing | 22 | 894,237 | 746,145 | 565,869 | −24 % | 278,349 → 215,614 |
| BT spawning | 22 | 894,237 | 354,423 | 275,514 | −22 % | 163,055 → 115,833 |
| CH rearing | 16 | 588,216 | 426,681 | 341,298 | −20 % | 146,059 → 147,442 |
| CO rearing | 10 | 329,838 | 272,429 | 243,051 | −11 % | 176,396 → 166,814 |
| GR rearing | 3 | 137,000 | 96,530 | 96,530 | 0 | 46,793 → 46,793 |
| ST rearing | 4 | 143,349 | 108,807 | 74,933 | −31 % | 44,775 → 41,791 |
| WCT rearing | 4 | 129,911 | 122,584 | 117,691 | −4 % | 47,027 → 43,010 |

Set against the km on the same catalog groups (`compare.csv`'s rows for those groups; the km table above is over
every group), the floodplain falls less than the km for BT rearing (24 % against 37 %), CO (11 against 14), RB (15
against 20), ST (31 against 45) and WCT (4 against 24): the streams those rules drop carry less floodplain per km
than the habitat `default` draws. For CH (20 against 19) and BT spawning (22 against 19) the two fall about
together. Graded ha follows graded km, rising only for CH; both rest on the grade, which reads every segment that
passes its size test at the 50 km distance cap (#65), so read them as provisional. (Revised 2026-10-18, #62: this
paragraph first compared catalog-group floodplain with all-group km.)

## Limits

- **Juveniles, electrofished, on the stream branch.** Spawning has a response for char only, and that one is weak.
  River polygons, wetlands and lakes keep `default`'s tests under every rule.
- **The score rewards separation, not extent** (as #54 said): the tuned rules are narrower than `default` where
  the floor moves up.
- **Thin rows.** ST (82 detections, 11 groups) and WCT (6 groups) carry their labels; BT spawning should not be
  applied. For ST and GR the joint curve predicts worse than the cut on held-out groups, so their grades rank
  segments but their rates are not to be read.
- **The grade on river polygons and wetlands is an extrapolation.** The curve was fitted on stream-branch visits
  outside lakes, wetlands and river polygons; a river-polygon segment reads it at 0 m from the river it is part of
  and at flows few visits had, so its grade rests on the surface past its data, and about half of their km reads 0.8 or more (CH).
  The reference is taken over the stream branch so that they do not set it: over every accessible segment, CH's
  rose from 0.14 to 0.52 and left 0.4 % of stream km at 0.8 or more (#65).
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
