# Stream size where Chinook are caught: CH detection by MAD, and small streams near large rivers

**Verified:** 2026-10-15 · **Issues:** #52 (this); beside #42 (flow in stage windows); uses #18 (FDIS
export), #28's design (`habitat_weights.md`) and wet's published flow (`modelled_discharge.md`); tuned in #54;
link's move onto wet's flow is NewGraphEnvironment/link#331 · **Produced by:**
- `scripts/0294-ch-mad-build.R` with `scripts/sql/ch_dist_large.sql`: visits, flow, distance and flags;
  ledger `scripts/logs/habitat/20261015_ch_mad_build_ledger.csv`;
- `scripts/0295-ch-mad-use.R`: `data/ch_mad_use.csv`, with log `scripts/logs/habitat/20261015_ch_mad_use.txt`;
- plan review, review rounds and their disposition: `planning/archive/2026-10-issue-52-chinook-stream-size/`.

**Status:** measured; nothing applied in link.

Every figure below names its population. Two populations recur:
- **MAD analysis.** 19,077 visits (978 CH) in 102 WSGs, of which the model uses 15,626 visits in the 67 WSGs
  where CH were both caught and missed. Raw rates and counts in the MAD table are on those 15,626.
- **Distance analysis.** Visits under 0.5 m³/s, with side channels and ambiguous placements out, in the 34 WSGs
  where CH were both caught and missed: 7,319 visits, 118 CH.

## The question

Where are juvenile Chinook caught, by stream size? Two parts:
- Is there a MAD below which CH are rarely caught?
- Are the CH caught in small streams close to a large river?

It needs no life-stage timing, so it can run wherever FDIS has visits. Here it ran in the 106 WSGs inside
link's CH range. #42's seasonal question needs timing, which only BULK and MORR have.

## Short answer

1. **Under 0.5 m³/s, the relative rate of CH detection is 0.14–0.61**, after effort, data set, era and WSG
   (1 = the average class):
   - under 0.1 m³/s: 0.14;
   - 0.1–0.28 m³/s: 0.47;
   - 0.28–0.5 m³/s: 0.61;
   - 0.5–10 m³/s: 1.40–2.40.

   Among visits that caught any fish, it is 0.26–0.48 under 0.5 m³/s and 0.91–1.52 from 0.5 to 30 m³/s.
2. **In the distance analysis, CH were caught on 14.5 % of small-stream visits with a ≥ 10 m³/s segment within
   500 m downstream, and on 0.8 % of those with one further downstream.** That is a rate ratio of **26.7**
   (bootstrap 15.0–58.3). These are 52 and 55 detections respectively.

   Counted on every small-stream CH visit, without the model's restrictions, 82 of the 142 that have a large
   river downstream are within 500 m of it.
3. **Above 30 m³/s, the classes are mostly regulated rivers.**
   - Regulated visits are 66 % of the 30–100 m³/s class and 81 % of the ≥ 100 m³/s class.
   - One 2010 FDS survey on the Nechako, below Kenney Dam, is 432 of the 978 analysed detections.
   - wet's flow there is natural flow, not the flow the fish meet.

## Data

FDIS electrofishing site visits (`fdis_export.md`). They record effort and zero catch, so detection per visit
can be corrected for effort.
- **In and dropped.** 53,018 visits in. 0290's quality drops apply, plus visits where a code blocks CH absence.
  WSGs are kept by link's CH range rule: ≥ 5 bcfishobs CH records since 1990, which gives 106 WSGs. That rule
  dropped 20,832 visits, 3 of them with CH.
- **Kept by 0294.** 21,862 visits, 1,186 of them with CH.
- **Analysed by 0295.** 19,077 visits (978 CH): 0291's edges, a fished area of 10–10,000 m², and #35's 507
  duplicates left out.
- **Flow.** wet's annual flow on each visit's FWA segment, from `pick` (17,289 routed, 1,788 balance).
  Segments with no `pick` are side channels and connectors with no watershed lut row. They take the parent
  line's flow rather than being dropped: 445 kept visits, 140 with CH (31 %, against 5.4 % of all kept visits).
- **Distance.** For visits under 0.5 m³/s, a walk down the route-measure path to the first primary-flow
  segment with flow ≥ 10 m³/s. A walk that reaches the sea is `none`. `fwa_downstreamtrace()` returns side
  channels off the path and drops lut-less segments, so its rows cannot be summed into a distance.
- **Flags.**
  - **Regulated**: downstream of a CABD dam with a reservoir or ≥ 10 % regulation (101 dams).
  - **Ambiguous placement**: a large segment on another line lies within the visit's snap distance + 20 m.
  - **Side channel.**
  - **Natural CH barrier downstream**, from link's barriers before observation overrides.

## Results

### Detection by MAD class

Columns (MAD analysis):
- **U rel**: CH caught, as a relative rate with its 95 % stream bootstrap interval.
- **C rel**: the same for CH among visits that caught any fish.
- **regulated** and **top project**: those shares of the class's detections.

As shares of the class's visits, regulated reaches are 1.5 % at 0.1–0.28, 12.3 % at 10–30, 66 % at 30–100 and
81 % at ≥ 100 (`regulated_visit_share`). The 16 regulated detections at 0.1–0.28 are side channels with their
own small flow, in CHES (14) and NECR (2).

| MAD (m³/s) | visits | CH | raw | U rel (95 %) | C rel | regulated | top project |
|---|---:|---:|---:|---|---:|---:|---:|
| < 0.1 | 7,840 | 70 | 0.9 % | 0.14 (0.05–0.26) | 0.26 | 0 % | 17 % |
| 0.1–0.28 | 1,791 | 57 | 3.2 % | 0.47 (0.20–0.70) | 0.41 | 28 % | 16 % |
| 0.28–0.5 | 797 | 26 | 3.3 % | 0.61 (0.27–1.04) | 0.48 | 0 % | 15 % |
| 0.5–1 | 885 | 61 | 6.9 % | 1.52 (0.69–2.33) | 1.03 | 2 % | 18 % |
| 1–3 | 1,048 | 50 | 4.8 % | 1.40 (0.80–2.06) | 0.91 | 4 % | 6 % |
| 3–10 | 1,171 | 72 | 6.1 % | 2.40 (1.38–3.80) | 1.52 | 0 % | 7 % |
| 10–30 | 857 | 40 | 4.7 % | 2.16 (0.84–4.60) | 1.32 | 8 % | 13 % |
| 30–100 | 452 | 71 | 15.7 % | 7.76 (2.01–15.6) | 4.16 | 83 % | 51 % |
| ≥ 100 | 785 | 531 | 67.6 % | 2.81 (1.53–5.77) | 1.83 | 92 % | 81 % |

Any fish caught (F) is higher in each class than in the one below it: 0.42 under 0.1 m³/s, 3.0 at ≥ 100.

### Small streams by distance to a large river

Distance analysis. The rate ratio is against > 500 m.

| ≥ 10 m³/s segment downstream | visits | CH | raw | rate ratio (95 %) |
|---|---:|---:|---:|---|
| within 500 m | 358 | 52 | 14.5 % | 26.7 (15.0–58.3) |
| further than 500 m | 6,523 | 55 | 0.8 % | 1 |
| none before the sea | 438 | 11 | 2.5 % | 10.0 (1.6–unbounded) |

Reading the table:
- The 14.5 % raw rate within 500 m is above the raw rate of every MAD class below 30 m³/s in the MAD table
  (0.9–6.9 %). The two tables are different populations.
- In the distance analysis, of the 32 WSGs with any small-stream CH near or far, 11 have CH both near and far, 8 only near and 13 only far.
- Across all 102 analysed WSGs, 1,243 small-stream visits end `none`:
  - 558 drain straight to the sea (9 CH);
  - 685 pass through smaller lines first (2 CH).

### Sensitivities (U, relative rates)

- **Under 0.5 m³/s, the relative rate is 0.08–0.74 in each of these**: regulated reaches out, the Nechako 2010
  project out, CHES and NECR out, parent-flow visits out, duplicates kept, gradient as a covariate, season as
  a covariate, natural-barrier filtering (with or without USER_DEFINITE), routed flow alone, and fwapg's old
  MAD. From 0.5 m³/s up it is above 1 in each, with two exceptions: 1–3 m³/s with barriers filtered (0.84),
  and ≥ 100 m³/s on fwapg's old MAD (0, from 9 visits).
- **On wet's balance alone**, 0.28–0.5 m³/s reads 0.29, 0.5–1 m³/s 0.54 and 1–3 m³/s 1.43. On routed flow
  alone they read 0.55, 1.46 and 1.39.
  - The two sources put a visit in the same class 53–67 % of the time between 0.1 and 1 m³/s, and 75–99 % in
    the other classes.
  - `modelled_discharge.md` describes the balance as weakest on small basins.
- **Regulated reaches out**, relative rates from 3 m³/s up are:
  - 3.49 at 3–10 m³/s (72 CH);
  - 2.86 at 10–30 (37 CH);
  - 8.34 at 30–100 (12 CH);
  - 3.20 at ≥ 100 (41 CH; 27.5 % of its 149 visits).
- **No river polygons.** 275 of the 978 detections remain. From < 0.1 to 3–10 m³/s the relative rates are 0.34,
  0.86, 1.39, 2.49, 3.36 and 4.54.
- **Distance.** The rate ratio is 30.2 with ambiguous placements kept, 28.8 with lake targets left out, and
  24.0 with walks whose entry gap exceeds 200 m left out. Those are lake tributaries, whose code points at the
  river that feeds the lake.
- **Cross-check against bcfishobs.** 4,384 bcfishobs CH records are not FDIS. Their life stage is almost all
  unrecorded, and they include other methods and adults.
  - Under 0.5 m³/s: 13 % of these records, against 16 % of FDIS CH visits in the MAD analysis.
  - 1–100 m³/s: 71 % of these records, against 24 % of FDIS CH visits.
  - ≥ 100 m³/s: 54 % of FDIS CH visits, of which the Nechako survey is 432 of 531.

## What it means for link's CH bounds

link's `default` CH rearing bounds come from Rebellato et al. 2024 (evidence data rows 118–119): MAD 0.28 to
100 m³/s. Woll 2015 (Mat-Su, data row 412) set no potential below 0.5 m³/s. Against these:

- **CH are caught under both floors.** The relative rate is 0.47 at 0.1–0.28 m³/s (57 CH) and 0.61 at
  0.28–0.5 (26 CH); with regulated reaches out, 0.46 and 0.72. In the distance analysis, small streams within
  500 m of a large river had CH on 14.5 % of visits. Those further away had CH on 0.8 %, and the < 0.1 m³/s
  class in the MAD analysis on 0.9 %.
- **A rule of the form "MAD ≥ 0.5 m³/s, or MAD < 0.5 m³/s within about 500 m downstream of a ≥ 10 m³/s
  river"** follows the pattern above. No rule was fitted here, or scored against a single floor. #54 tunes one
  (`chinook_rearing_tuned.md`): on held-out groups the data prefer a gradient of at most 7 % and either MAD ≥ 0.75 m³/s or a ≥ 3 m³/s river
  within 1,000 m downstream, with each value given as a range. link's
  CH MAD bounds act in no group today (all 188 size streams by channel width), so this is not a change to them.
- **On `rear_mad_max` 100 m³/s.** CH were caught on 27.5 % of the 149 unregulated visits at ≥ 100 m³/s.
  Electrofishing samples river margins, so this measures use of margins, not of channels.
- **Spawning bounds (0.46 m³/s) are not tested.** These are juvenile records.

## Limits

- **Juveniles only.** FDIS caught 2 CH ≥ 150 mm in the whole export.
- **Margins, not channels.** 702 of the 978 analysed detections are on segments inside a river polygon or on
  river-polygon edges. The data do measure large rivers, at their electrofishable margins.
- **Modelled, natural flow.**
  - The two sources put a visit in the same class 53–67 % of the time between 0.1 and 1 m³/s.
  - On regulated rivers, natural flow is not the flow in the channel. Those visits are flagged, and a
    sensitivity leaves them out.
  - CABD records a degree of regulation for 38 of 2,592 dams, so regulated means a reservoir or regulation of
    10 % or more.
- **Single projects.** The top-project column gives the share of a class's detections from one survey: 81 % at
  ≥ 100 m³/s and 51 % at 30–100 m³/s.
- **Distance is measured to the large river's centreline** where a tributary's mouth meets it, so it includes
  part of the receiving channel's width.
- **The 0.1, 1, 3 and 30 m³/s breaks have no source.** They fill the steps between the sourced breaks: link's
  0.28 and 100, Woll's 0.5, and #52's 0.5 and 10.
