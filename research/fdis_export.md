# FDIS electrofishing export: contents, defects, and what it adds

**Verified:** 2026-09-26 (Provenance: 2026-10-16; Where it lives, Repeated surveys and the evidence table: 2026-10-17; Placement: 2026-10-27; Measured vs modelled gradient: 2026-10-30) · **Issues:** #18 (built from), #56 (published), #35 (repeated surveys), #91 (placement), #121 (gradient), NewGraphEnvironment/link#284 (consumer) ·
**Produced by:** direct reads of `s3://fresh-bc/fdis/` and the public BCGW layers (WFS
`DescribeFeatureType`, local `whse_fish`); placement by `data-raw/snap_candidate_check.R` and
`data-raw/snap_limit_sensitivity.R` (`scripts/logs/fdis/20261027_snap_*`); gradient by `data-raw/site_gradient_check.R`
(`scripts/logs/habitat/20261030_site_gradient_check.txt`) · **Status:** evidence built (`scripts/0230`, `scripts/0240`); first calibration read below.

## Provenance

The Province of British Columbia supplied extracts of its Fisheries Data Information System (FDIS),
exported on 2020-11-16 and 2022-03-22, to New Graph Environment for the 2021–22 channel-width and
fish-density work with Poisson Consulting. No use terms were attached; the purpose was to advance
knowledge of fish–habitat relationships in BC. The files lived only on a shared drive until they were
moved byte-identical to `s3://fresh-bc/fdis/` on 2026-09-26; `MANIFEST.md5` there is the checksum
record. On 2026-10-16 the Province agreed to the extract being public, provided it carries a note of
when and from where it was received (#56).

## Where it lives

- `s3://fresh-bc/fdis/`: the extract as received (`2020-11-16/`, `2022-03-22-ef-export/`), the export
  queries, the FDIS data-model documents, `MANIFEST.md5`, and `README.md`, the provenance note, whose
  tracked source is `data/fdis_README.md`. `fissr_explore.sqlite`, a 2021 working database that is not
  part of the extract, and the old `derived/` copies moved to the bucket's private `archive/fdis/`, with
  the original `MANIFEST.md5`; the one in `fdis/` is that record less the sqlite line (26 files).
- `s3://fresh-bc/knowledge/fdis/v2/`: the visit-level tables built here (`fdis_sites`, `bt_use_visits`,
  `ch_mad_visits`, `ch_rule_visits`, `ch_rule_walks`) and `fdis_repeat_surveys` (below) as Parquet, with a
  `manifest.json` naming each table's rows, checksum, producing script and source CSV, the commit it was
  published from, and the version it supersedes. `scripts/0299` writes them, and with `PULL=TRUE`
  restores `data/fdis/derived/` from them. `v1/` is the release before #35: it counts repeated surveys
  once per copy, and `fdis_repeat_surveys` maps its `site_visit` ids to v2's.
- Both prefixes are readable without credentials once the bucket policy grants them; the bucket does not
  list, so start from the manifest.

## Contents and join structure

Every file keys on `KEY` = `fshclctn_id _ site_number _ sequence_number _ method_number _ haul_or_pass`,
which is **one electrofishing pass**. A **site visit** is the first three parts.

| file | rows | grain | notes |
|---|---:|---|---|
| `2020-11-16/visits.csv` | 62,892 | pass | UTM, dates, fishing time (s), fished length/width (m), EF settings, agency |
| `2020-11-16/habitat.csv` | 26,565 | pass | `GRADIENT11..22` (%), `CHANNELWIDTH1..7`, `WETTEDWIDTH1..7` (m), bed material, temperature; no saved query |
| `2020-11-16/details.csv` | 326,388 | fish | species, length (mm), weight, age, sex, egg count, maturity |
| `2020-11-16/counts.csv` | 114,217 | pass × species × age | number caught, min/max length |
| `2022-03-22-ef-export/Details*.csv` | 341,607 | fish | same fields as `details` plus UTM, watershed code, gazetted name |

- **The 2022 fish files contain every 2020 fish row.** Compared as a multiset on (KEY, species,
  length), 0 of 326,388 2020 rows are missing from 2022, and 2022 adds 15,219. The 2022 files are
  the fish table; the 2020 files supply visits, effort and habitat.
- Of the 2020 detail keys, 19,669 of 19,817 have a visit row; habitat covers 23,254 of the 62,892 visits.
- **Passes per site visit:** 53,018 site visits in the export, before repeated surveys are dropped (below). 47,270 have one pass; the rest have 2–8
  (depletion passes). Distributions built per pass would weight multi-pass sites up to 8×, so the
  evidence grain is the site visit, with effort summed over its passes.

## Units and codes

- Fish `LENGTH`: millimetres, "forked or total" per the FDIS data dictionary
  (`fiss-database-structure/FDIS_columns.csv`). The export does not say which, per fish. Salmonids
  are conventionally measured fork length; treat it as length of unknown type.
- `MATURITY_CODE` values in BT/CH rows: blank, `IM`, `U`, `MT`, `M`, `SP`, `ST`. The code table
  (`FDIS_Z_MATURITY_CD`) was not exported. The meanings used here are the RISC fish-collection codes,
  **inferred, not read from the export**: immature, unknown, maturing, mature, spawning, spent.
- Gradient: percent. Of 25,692 `GRADIENT11` values the median is 3, the 95th percentile 22, and the maximum 990.
- Channel width: metres. Of 25,835 `CHANNELWIDTH1` values the median is 2.2 and the 95th percentile 24; `9999` occurs as a sentinel.

## Known defects (flagged in the build, never silently dropped)

Every no-data encoding is declared once, at the top of `scripts/0230` (measured field by field
in /code-check round 3, `planning/archive/2026-09-issue-18-fdis-evidence/review-round3.md`):

| field | no-data encodings found | handling |
|---|---|---|
| `NUMBER_CAUGHT` | 9999 (23 rows), 99999 (48) | count NA; the catch still counts as presence |
| `FISHING_TIME`, `FISHING_AREA_LENGTH/WIDTH` | 9999, 9999.9 | NA, `flag_effort_sentinel` (91 sites) |
| `UTM_EASTING/NORTHING` | 0, out-of-BC values (14 eastings < 100,000; 32 northings < 5.2 M) | `flag_no_utm`, not placed |
| `WATER_TEMPERATURE` | values to 556 | NA outside −1 to 35 °C |
| `MINIMUM/MAXIMUM_LENGTH` | 0 | NA |
| `GRADIENT*` | 990 etc.; 0.00 on blank forms | > 100 NA; 0 kept only when the row has a width |
| `CHANNELWIDTH*`, `WETTEDWIDTH*` | 9999, 0 | ≥ 500 or 0 → NA |
| `SPECIES_CODE` | 115 codes, each classified in `data/fdis_species_codes.csv` (names from `whse_fish.species_cd`): `NFC`/`ZZZ` no fish caught; `ANODON` mussel and `CRA` crayfish not fish; `SP`, `AF` block both absences, `SA`/`AO` block CH, `TR` (trout fry < 70 mm) blocks char; `SLV` counts as char | an unclassified code stops the run |
| `NUMBER_CAUGHT` = 0 on a species row | 21 rows | not a catch unless fish were measured |
| `NEW_WATERSHED_CODE` | mainstem-only codes (`230-000000-…`) | not used as a placement check |

Undecided: 644 habitat rows have one gradient slot at 0 and the other above 0. The data can't
say whether that 0 is a reading or an unfilled slot; it is kept as a reading.


- 4,770 visits have no fished-area length, although the saved `Visit.sql` filters on it. The
  export was not produced exactly by that query, or the query changed.
- 1,084 visits have no UTM.
- Junk dates: years 0200, 0220, 0912, 2028, 2029.
- Sentinel and outlier habitat values: gradient to 990 %, width 9999 m.

## Repeated surveys (#35)

Some surveys were loaded under two to four collection ids: the same UTM, date and per-pass effort, and the
same catch, under ids thousands apart (`42511_102_1` and `65734_102_1`). `scripts/0230` keeps one copy.

- **Signature:** UTM, date, pass count, fished length and width of each pass in order, and the catch by
  species. An empty catch matches whether NFC was recorded or not. Fishing time is not in it; copies
  differ in time in 33 groups, and the map says which.
- **When a match counts:** every member has its own collection id, and the members share a site number or
  hold identical measured fish. 65 groups with different site numbers and no identical fish could be
  adjacent sites at one rounded UTM, and 13 sit inside one collection; their members stay as separate
  visits.
- **The copy kept** has the most measured fish, then the most maturity-coded fish, then a known catch,
  then habitat, then the lowest collection id. The fish are not reliably on the lowest id: in 94 of the
  95 groups where one copy alone has measured fish, it is the higher one. A habitat value the kept copy
  lacks moves to it from a dropped copy (5 pairs: 3 kept copies with no habitat record, 2 whose record
  lacks a gradient, a width or a temperature), and 0230 stops if any habitat value would leave with a
  dropped copy. The placement check reads the 50k watershed codes of every copy, which sit on the fish
  rows.
- **What one copy gives up:** 78 measured fish rows held only on a dropped copy (mostly the same fish
  with another weight or code), 3 maturity-coded fish (none char), 1 species measured only on a dropped
  copy, and 3 count length bounds. Merging copies would count the identical fish twice. A sweep of every
  visit column over the 1,431 pairs finds no other value held only on a dropped copy.
- **Measured** (`scripts/logs/fdis/20261017_03_fdis_load.log`): 1,308 groups; 1,431 visits dropped (623
  fish, 623 zero catch, 185 unknown), with 1,504 passes, 3,591 measured fish rows and 9,597 of 990,606
  counted fish; 51,587 visits remain. In 114 groups the copies' measured fish differ, in 115 their
  habitat, and 89 pair a zero copy with an unknown one.
- **The 2022 fish files** repeat the same fish under every id in 326 of the 440 groups with measured
  fish. In 94 the fish sit under one id only (the copy kept), and in 20 the copies' fish differ slightly
  (a weight, a maturity code, a fish).
- `data/fdis_repeat_surveys.csv` lists every other member of each matching group, with the copy kept and
  whether it was dropped.
- Effect downstream (rerun 2026-10-17): #28's BT rearing weights moved by at most 0.02, #33's spawner
  rate ratios stayed within 0.81–1.16 with a WSG term, and CH detection by stream size did not change
  its detections. Details are in `habitat_weights.md`, `bt_spawning.md`, `chinook_stream_size.md` and
  `chinook_rearing_tuned.md`.

## Placement (#91)

**How a visit reaches its stream.** `scripts/0230` snaps each visit's point with `fresh::frs_point_snap()` twice
within 500 m: to the nearest stream, and to each 20k stream its FDIS 1:50k watershed code names (the code's
`blue_line_key`s in `fwa_streams_20k_50k`, passed as a hint, so that snap can land only on that stream).
`knw_fdis_place()` then picks:

- **Confirmed:** the code names a stream within reach. The visit goes on the nearest such stream, even past a
  nearer one ("moved"). Confirmed means on *some* stream the code names, which is what the old check asked. A
  code naming several 20k keys can confirm a tributary other than the one the surveyor meant, and most codes on
  these visits name several: in the probe's count (from `fish.rds`, without the codes `0230` pools from dropped
  repeat copies), of the 10,889 the crosswalk knows, 4,045 name one key, 3,039 two, 2,222 three to
  five, 1,195 six to twenty and 388 more.
- **Unconfirmed:** the visit has no code the crosswalk knows. It goes on the nearest stream.
- **No named stream in reach:** the code names streams, none within 500 m. The visit keeps the nearest stream
  and is dropped as a 1:50k mismatch, because the code contradicts every stream it could be moved to.

An unconfirmed pick beyond 200 m (`snap_limit`) and a confirmed one beyond 500 m (`snap_limit_code`) are dropped
as far snaps. fresh never snaps to an unmapped line (no local code) or a placeholder (`999`) line, and `0230`
excludes the connectors that carry a stream across a watershed-group boundary (6010) as well. link's segments
carry none of those three kinds, so a visit `fwa_indexpoint()` put on one could never be placed on link's segments;
the nearest line is a 6010 connector for 3 visits, which go to the next stream. Subsurface flow (1425), which fresh
excludes by default, stays a candidate because link's segments carry it. Excluding it, as the probe did, kept six fewer
visits: two that link had placed on 1425 under the old snap, and four whose only stream in reach is a 1425 line. In
the final build all 13 visits whose nearest line is 1425 are placed on
it, and 12 are kept (one is 221 m away with no code). Other construction-line connectors (1400, 1410, 1450) stay
candidates too.

**What changed against `fwa_indexpoint()`** (the probe, `data-raw/snap_candidate_check.R`, on the 2026-10-17
placement and link's schema of that run; its new snap also excluded 1425, which the final build does not). Its
classes partition the 50,550 visits with a usable point:

| class | visits | link places them, before | after |
|---|---|---|---|
| same segment | 48,241 | 47,848 | 48,050 |
| old pick unmapped | 1,347 | 0 | 1,347 |
| no stream within 500 m either way | 526 | 0 | 0 |
| old pick a placeholder | 174 | 0 | 165 |
| same stream, another segment | 131 | 107 | 131 |
| only `fwa_indexpoint()` finds a stream | 102 | 2 | 0 |
| a distance tie | 29 | 29 | 29 |

The probe reproduced the old evidence build's 1,491 `no_link_segment` drops from the stored placement, and 1,645 of
the old snap's 2,038 link misses were unmapped or placeholder picks. The visits on those lines re-snap to a mapped
stream a median 135–151 m away. That stream is no worse a guess than any other at its distance: where the code
checks them (186 visits), they agree with it as often by distance band as ordinary snaps do (92 % against 93 %
within 25 m, 71 % against 73 % at 50–100 m). On one segment the two measures differ by at most 1 m, because fresh
places a visit on a whole metre.

**The limits, by measurement** (`data-raw/snap_limit_sensitivity.R`). The rule was set before the run: a confirmed
pick is kept to the search radius, because the code names its stream; an unconfirmed pick is kept to the widest
distance band whose code-checked disagreement stays under one in three; and either limit steps down if CH or BT
rearing's one-SE region moves inside it. Disagreement here means a visit with a checkable code whose nearest
stream its code does not name:

| nearest stream's distance | visits | disagree | share |
|---|---|---|---|
| under 25 m | 8,637 | 645 | 7.5 % |
| 25–50 m | 990 | 164 | 16.6 % |
| 50–100 m | 695 | 188 | 27.1 % |
| 100–200 m | 379 | 126 | 33.2 % |
| 200–500 m | 172 | 96 | 55.8 % |

So the unconfirmed limit is 200 m, though the 100–200 m band clears one in three by only 0.1 point. The rule
compares five pairs of cells (each unconfirmed limit of 100, 200 and 500 m against the next, with confirmed picks
at 500 m; and 200 against 500 m for confirmed picks at each unconfirmed limit). In none of them did either key's
pick fall outside the other cell's one-SE region, so neither limit stepped down. That check is weak, because the
regions hold 51 to 244 rules. Across all ordered pairs of the six cells (30 for each key), one pick falls outside another's
region, and it is CH rearing's: its pick at 200/200 (`g<=0.13`) is outside the 500/500 cell's 51-rule region. CH rearing's pick moves between
cells (`g<=0.15` at 200/500, `g<=0.3` with a smaller flow floor at 100/500), and BT rearing's pick is the same rule
in all six.

Moved picks are where the confirmed limit matters. Of 785, 177 move within 25 m. 56 lie under 25 m from their
nearest stream and are moved 200–500 m to the coded one; the confirmed limit keeps them.

**The evidence before and after** (the evidence ledgers of 2026-10-22 and 2026-10-27, on the same link schema and
flow load):

| step | before | after |
|---|---|---|
| not placed | 1,563 | 1,659 |
| far snap | 5,242 | 1,941 |
| 1:50k code mismatch | 1,088 | 377 |
| no link segment | 1,491 | 178 |
| kept | 40,552 | 45,529 |

Of the 45,529 kept visits, 10,210 are confirmed by their code and 748 were moved to a named stream past a nearer
one (the ledger's `kept_snap_*` rows, 10,247 and 754, are counted before link's segment drops 178).
The FISS workbook sites (`0250`) still snap with `fwa_indexpoint()` and a 100 m flag, so `flag_far_snap` in the
bound `data/fdis_evidence.csv` and `data/fiss_evidence.csv` is not one placement. fresh#266 (open) proposes a new
tie rule between two segments of one stream; the probe's 29 `tie` visits lie at equal distance from two
different streams, so that rule does not reach them; a tie between two segments of one stream falls in `same_segment`
or `same_stream`.

## What this adds over the public layers

| field | `fiss_fish_obsrvtn_pnt_sp` / `bcfishobs` | `fiss_stream_sample_sites_sp` (68,842 sites) | FDIS export |
|---|---|---|---|
| species presence | yes | no | yes |
| life stage | coarse, often blank (BT 0 of 11,524) | no | via length + maturity |
| individual length / weight | no | no | **yes** |
| maturity / sex | no | no | **yes** |
| effort (time, fished area) | no | surveyed length only | **yes, per pass** |
| measured channel width / gradient | no | yes, one value per site | yes, repeated measures per pass |
| fish tied to the habitat measured at the same pass | no | no | **yes** |
| zero catch | no | no | inferable (pass with effort, no fish rows) |

The public sample-sites layer already has measured width and gradient, so the value here is not
those numbers alone. It is fish size and maturity **at the pass where width and gradient were
measured**, plus effort. That is what separates spawning-size from rearing-size evidence against
the same channel measurements.

Not checked: the Fisheries Inventory Data Queries web tool, which is interactive only.

## Scope limit

Electrofishing only. Minnow traps, angling, seines, snorkel and gill nets are absent, which biases
against large-river and lake use. Adult CH in mainstems will be under-represented relative to
their true spawning habitat.

## What the evidence says so far (2026-09-26; counts after #35, 2026-10-17, `scripts/0240`)

Site-visit counts, measured site gradient, against the thresholds link runs now:

| group × class | sites | with gradient | above rear max | above spawn max | below rear cw min |
|---|---:|---:|---:|---:|---:|
| CH present (any size) | 1,359 | 138 | 25 % (> 5.49) | 30 % (> 4.49) | 14 % |
| char present (any size) | 6,879 | 1,956 | 11 % (> 10.49) | 34 % (> 5.49) | 9 % |
| char spawner evidence | 340 | 254 | 16 % | **41 %** | 4 % |

- **CH is rearing-only here.** EF caught 2 CH ≥ 150 mm in the whole export.
- **Size is not maturity for char.** A third of SP/ST-coded char are 80–200 mm, so a length break alone cannot separate spawners; spawner evidence uses maturity plus month.
- **Measured vs modelled width** is comparable at only 3,637 sites after #35 (3,820 when written), where the FWA width is `MODELLED`. FWA's `FIELD_MEASURMENT` widths are these same FISS sites (69 % identical). There the log correlation is 0.54 (also after #35) and the p10–p90 ratio 0.44–2.58 (as written on 2026-09-26).
- **Site gradient is a point measure**; model thresholds apply to a segment's average. The shares above are on the measured value; the next section compares it with the segment gradient the rules read (#121).

## Measured vs modelled gradient (#121, 2026-10-30)

**What was asked.** Every gradient limit the tuning publishes is a limit on link's segment gradient, a Freshwater Atlas
slope averaged over the segment a site sits on. Crews measured gradient at 18,759 of the 45,529 placed visits. How
closely do the two agree, and how often does a site sit on the other side of a published limit on the ground from where
the model puts it?

**What the two numbers are.** The site card asks for the slope of the channel bed, measured at two or more places along
the site over as long a distance as possible, recorded to the nearest 0.5 % with a method code (ground estimate,
clinometer, Abney level, map, survey, GIS; RISC *Site Card Field Guide*, 2008, p. 13). The card has two rows, each with
its own method; `gradient_pct` is the first row's mean and `gradient2_pct` the second's. The export carries neither
method code, so some "measured" values may themselves be map or GIS readings, and a site whose two readings were 0 and 4
% reads 2 % (the 644 half-zero rows above). The model's number is a mean over tens to hundreds of metres. The two are
different quantities: a riffle, a step or a culvert outfall moves the site's slope and not the segment's. So the
yardstick is not perfect agreement but how well two readings at the same site agree with each other: rank correlation
0.90 over the 9,389 sites with both, and the first reading within 0.60 to 1.58 times the second at 80 % of the 9,204
where both are above 0. A model cannot be expected to do better than that.

**How it was judged.** On the tuning's stream branch (16,279 visits with a measured gradient), as the width comparison
above: the rank and log correlations, and the spread of the measured/modelled ratio. Then, at each published limit, the
share of each species' scored visits whose measured and modelled gradients lie on opposite sides of it.

| against | rank r | log r | ratio p10–p50–p90 | median abs. difference | model higher |
|---|---:|---:|---|---:|---:|
| second reading at the same site | 0.90 | 0.89 | 0.60–1.00–1.58 | 1.0 point | (second higher, 46.5 %) |
| link's segment gradient | 0.69 | 0.64 | 0.33–0.90–2.22 | 2.2 points | 56 % |
| the whole Atlas line's | 0.65 | 0.62 | 0.26–0.83–1.94 | 2.5 points | 61 % |

**What it shows.**
- The segment gradient follows the site better than the whole line does: higher rank and log correlations, a median
  ratio nearer 1, a narrower ratio spread on the log scale and a smaller large error (p90 9.3 against 13.0 points),
  which is what #92 moved the tuning to it for. It agrees with the site about as well as modelled width does (log r
  0.64 against width's 0.54), and well short of a second reading.
- The model pulls toward the middle: it reads higher than the site at 87 % of sites measured at 0 and 67 % of those
  above 0 up to 3 %, and at only 23 % of those measured above 30 %. Agreement is best on segments 50 to 250 m long and
  on orders 2 to 4 (rank r 0.70 to 0.73), worst on segments of 10 m or less (0.53) and on orders 5 and 6, where the
  site reads steeper than the segment (median ratio 1.24 and 2.05). On river, wetland and lake segments, which the
  tuning does not score, it barely agrees (rank r 0.37, 0.21, 0.33).
- **At the limits.** Over each species' scored visits that carry a measured gradient, the share on the other side on
  the ground: CH rearing at 11 %, 6.4 % of 2,453; BT rearing at 30 %, 0.8 % of 4,427; WCT rearing at 25 %, 0.7 % of
  461; CO and GR at 5.49 %, 25.8 % and 11.7 %. BT spawning's scored visits need the spawner evidence, which the check
  does not read, so its figure is over the BT visits that pass every other filter of the tuning's (stream branch, in
  range, not blocked, no barrier downstream; 11,805 visits, 5,660 with a measured gradient) but not the spawner and
  groups filters, against the 513 visits the tuning scored: at 13 %, 8.5 %. Within one step of each species' own
  ladder either side of its limit, 33 to 42 % of visits flip (CH 34 % of 218, BT spawning 34 % of 446): near a limit,
  the modelled gradient says little about which side the site is on. A limit can still sort sites well in bulk,
  because most sites are far from it, but read one as a slope on the ground only to within a few points.
- **With and without a catch.** Sites with fish are off by less in absolute terms (median 1.7 against 2.6 points), but
  mostly because they are gentler: within classes of measured gradient the gap nearly closes (1.2 against 1.6 points
  at 3 % or less, 6.2 against 6.0 above 13 %). On the scale-free measures they agree no better (rank r 0.64 against
  0.68, and a wider ratio spread). Within segment-length classes the absolute gap persists (2.4 against 6.6 points on
  segments of 50 m or less, 1.7 against 3.4 on 50 to 250 m), and on the shortest segments rank r favours sites with
  fish (0.64 against 0.41); those classes are not split by gradient, so part of that is again gentler ground. It is
  what link cutting a segment at a catch would produce, a short segment drawn around a fish site, but this check
  cannot separate the two. Per species, visits where it was caught flip at its limit less often than visits where it
  was not (CH 4.1 against 6.5 %, CO 18.1 against 27.4 %, GR 2.2 against 15.0 %). #120 reruns this on link's minimal
  network, where segments are not cut at catches.
- **Negative segment gradients.** 55 placed visits have one (−13.6 % to −0.01 %), 52 of them on the visit's own Atlas
  line, all on edge types the stream branch excludes (1200, 1400, 1410, 1425; 34 in wetlands). No species' scored
  population holds one, so no pick depends on one; on a build where one does, the check tests every rule of the key at
  it, as it is and set to 0. The two code paths treat one differently, though: `knw_rule_in()` keeps a gradient only
  from 0 up, so a negative fails every rule, while the curve and the grade clamp it to 0 (`R/tune_curve.R`,
  `R/grade.R`).

**What this is not.** No change to the gradient a rule reads: a point and a segment average are different quantities,
and this measures how far apart they are.

**Specification.** `data-raw/site_gradient_check.R` on evidence `1bd35829 009698d7 99f499bb` (`knowledge/fdis/v3`, the
build `data/thresholds.csv` names), log `scripts/logs/habitat/20261030_site_gradient_check.txt`. Measured percent ÷ 100;
stream branch is `knw_tune_run()`'s edge types and fished area with no river, wetland or lake (29,335 placed visits, as
#92's check counts); each rearing key's population is held to its tracked `n_visits`. Log and ratio statistics use pairs
where both are above 0 (against the segment gradient 487 of 16,279 are not, against the Atlas line 337). A reading
exactly on a limit counts as in, as the rule's `<=` does (45 visits at 13 %, 22 at 11 %). The band is the modelled
gradient within one step either side of the limit on the species' own ladder (the gradient maxima of its tracked tune
table), mirrored at the top; the log also gives the band on the measured gradient.

## Supplement: Fish Data Submission workbooks (#21)

`scripts/0250` adds Step 3 individual fish from the submission workbooks 0220 parses, in the
`fdis_evidence.csv` shape (`data/fiss_evidence.csv`, `source = "fiss_xls"`). Across the five
groups harvested so far, most electrofished workbook fish are already in this export (45 of 68
reports match ≥ 90 % by date, place, species and length), which is how the export was built. What
the workbooks add is other years at resurveyed index sites (Peace boat EF 2012–2016) and other
methods (angling, gill net, minnow trap, snorkel). No workbook in those five groups postdates 2020,
so the post-export gap is not closed by them yet.
