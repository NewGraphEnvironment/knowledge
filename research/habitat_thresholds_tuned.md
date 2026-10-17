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
- `scripts/0330`: `data/compare/*.csv`, `research/fig/compare_*.png` (the comparison; below).

**Status:** measured; nothing applied in link. One file per species holds the species' reading:
`bull_trout_tuned.md`, `chinook_rearing_tuned.md` (#54's file, with the province-wide rescoring at its head),
`coho_rearing_tuned.md`, `grayling_rearing_tuned.md`, `rainbow_rearing_tuned.md`, `steelhead_rearing_tuned.md`,
`westslope_cutthroat_rearing_tuned.md`.

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
  percentile of accessible segments' rate, capped at 1, in fifths. Expected use per standard electrofishing
  visit, not habitat quality. A segment with no size (an unmeasured first-order stream under a width rule) or no
  gradient is `NA`, counted.

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
   BT (10.49 %) and GR (3.49 %).
3. **Only CH's rule needs the near-a-river exception** on the main reading; BT spawning's does too, but that row
   is weak (its raw rates do not separate, and nested selection puts the pick behind `default`).

**CH's open floor (#54) settles at 0.75 m³/s**, with 0.5 inside the region on all five seeds.

## Grades

| species × stage | segments (groups) | accessible km | graded km | grade-weighted km | reference rate | km under 0.2 | km at 0.8–1 |
|---|---|---|---|---|---|---|---|
| BT rearing | 8.41 M (158) | 577,130 | 571,306 | 175,327 | 0.180 | 54 % | 9 % |
| BT spawning | 8.41 M (158) | 577,130 | 571,306 | 375,213 | 0.239 | 0.1 % | 21 % |
| CH rearing | 5.76 M (125) | 225,326 | 224,459 | 36,149 | 0.146 | 76 % | 7 % |
| CO rearing | 4.92 M (100) | 147,962 | 146,612 | 66,893 | 0.514 | 20 % | 14 % |
| GR rearing | 4.21 M (82) | 258,724 | 146,128 | 83,850 | 0.034 | 5 % | 24 % |
| RB rearing | 10.33 M (210) | 510,150 | 277,539 | 134,596 | 0.411 | 24 % | 21 % |
| ST rearing | 4.14 M (79) | 155,481 | 154,855 | 44,545 | 0.236 | 61 % | 14 % |
| WCT rearing | 1.19 M (16) | 35,320 | 25,932 | 16,871 | 0.429 | 15 % | 47 % |

A width rule grades only measured streams: fwapg models width where `stream_order > 1`, so GR, RB and WCT leave
every unmeasured first-order stream `NA` (RB: 6.26 M of 10.33 M segments). A MAD rule grades almost everything
(BT: 33,988 segments with no flow even from a parent).

## Limits

- **Juveniles, electrofished, on the stream branch.** Spawning has a response for char only, and that one is weak.
  River polygons, wetlands and lakes keep `default`'s tests under every rule.
- **The score rewards separation, not extent** (as #54 said): the tuned rules are narrower than `default` where
  the floor moves up.
- **Thin rows.** ST (82 detections, 11 groups) and WCT (6 groups) carry their labels; BT spawning should not be
  applied. For ST and GR the joint curve predicts worse than the cut on held-out groups, so their grades rank
  segments but their rates are not to be read.
- **Width rules leave first-order streams ungraded**; a consumer summing graded km over a width-ruled species
  sums measured streams only.
- **One link run.** Every grade carries `run_uid 20261017_004619-3f4c713b`; link recomputed UPET twice after the
  waiter released and before the build read, and the build's UPET visits place identically on the result.
- **The access gate.** Grades are gated on `streams_access`; link's `accessible` disagrees on 1.6–3.5 % of
  habitat-accessible segments for most species, 17 % for RB and 90 % for KO (link#349), ledgered per run.
