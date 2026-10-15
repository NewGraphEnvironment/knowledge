# Stream size where Chinook are caught: CH detection by MAD, and small streams near large rivers

**Verified:** 2026-10-15 · **Issues:** #52 (this); beside #42 (flow in stage windows); uses #18 (FDIS
export), #28's design (`habitat_weights.md`) and wet's published flow (`modelled_discharge.md`); bears on
NewGraphEnvironment/link#331 · **Produced by:**
- `scripts/0294-ch-mad-build.R` with `scripts/sql/ch_dist_large.sql`: visits, flow, distance and flags;
  ledger `scripts/logs/habitat/20261015_ch_mad_build_ledger.csv`;
- `scripts/0295-ch-mad-use.R`: `data/ch_mad_use.csv`, with log `scripts/logs/habitat/20261015_ch_mad_use.txt`;
- plan review and its disposition: `planning/archive/2026-10-issue-52-chinook-stream-size/review-plan.md`.

**Status:** measured; nothing applied in link.

## The question

Where are juvenile Chinook caught, by stream size? Two parts:
- Is there a MAD below which CH are rarely caught?
- Are the CH caught in small streams there because a large river is close?

This needs no life-stage timing, so it runs in every watershed group with fish records. #42's seasonal
question needs timing, which only BULK and MORR have.

## Short answer

1. **Below 0.5 m³/s, CH are caught at a seventh to three-fifths of the average rate**, after effort, data
   set, era and watershed group:
   - under 0.1 m³/s: 0.14 times the average;
   - 0.1–0.28 m³/s: 0.47 times;
   - 0.28–0.5 m³/s: 0.61 times;
   - 0.5–10 m³/s: 1.4–2.4 times.

   The same shape holds among visits that caught any fish, so it is not fishless headwaters driving it.
2. **On small streams, CH sit next to large rivers.**
   - Where a ≥ 10 m³/s segment lies within 500 m downstream of the visit, 14.5 % of visits caught CH,
     against 0.8 % further away.
   - That is a rate ratio of **26.7** (bootstrap 15.0–58.3).
   - 52 of the 107 small-stream detections with a large river downstream were within 500 m.
   - #52's "< 0.5 m³/s within 500 m of a 10 m³/s stream" is real, and it is most of the small-stream signal.
3. **Above 30 m³/s the data cannot speak to stream size.**
   - The classes are dominated by regulated rivers.
   - One 2010 FDS survey on the Nechako, below Kenney Dam, is 432 of the 978 analysed detections.
   - wet's flow there is natural flow, not what the fish meet.

## Data

FDIS electrofishing site visits (`fdis_export.md`): effort and zero catch, so detection per visit can be
corrected for effort.
- **Population.** 53,018 visits in. 0290's quality drops apply, plus visits where a code blocks CH absence.
  Groups are kept by link's CH range rule: ≥ 5 bcfishobs CH records since 1990, which gives 106 WSGs. That rule
  dropped 20,832 visits, 3 of them with CH.
- **Kept by 0294.** 21,862 visits, 1,186 of them with CH.
- **Analysed by 0295.** 19,077 visits (978 CH) in 102 WSGs: 0291's edges, a fished area of 10–10,000 m², and
  #35's 507 duplicates left out. The model uses the 67 WSGs where CH were both caught and missed: 15,626 visits.
- **Flow.** wet's annual flow on each visit's FWA segment, from `pick` (17,289 routed, 1,788 balance).
  Segments with no `pick` are side channels and connectors with no watershed lut row. They take the parent
  line's flow rather than being dropped: 445 visits, 140 with CH. CH are caught there at about six times the
  overall rate (31 % against 5.4 %), so dropping them would have removed floodplain rearing habitat.
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

Columns: CH caught (U), relative rate after effort, data set, era and WSG (1 = average class; 95 % stream
bootstrap), the same for CH among visits that caught any fish (C), and the regulated and largest-project
shares of the class's detections. Regulated visits are a smaller share (0.1–0.28: 1.5 % of visits but 28 % of
detections: side channels with their own small flow in CHES (14) and NECR (2); 30–100: 66 %; ≥ 100: 81 %).

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

Any fish caught (F) rises steadily with MAD, from 0.42 times the average under 0.1 m³/s to 3.0 at ≥ 100. The CH
contrast within fish-bearing visits (C) is flatter than U, but it keeps the step at 0.5 m³/s.

### Small streams by distance to a large river

Visits under 0.5 m³/s, excluding side channels and ambiguous placements. The rate ratio is against > 500 m.

| downstream distance to MAD ≥ 10 | visits | CH | raw | rate ratio (95 %) |
|---|---:|---:|---:|---|
| ≤ 500 m | 358 | 52 | 14.5 % | 26.7 (15.0–58.3) |
| > 500 m | 6,523 | 55 | 0.8 % | 1 |
| none (to the sea) | 438 | 11 | 2.5 % | 10.0 (1.6–unbounded) |

The CH caught in small streams close to a large river are caught at a higher rate than in any MAD class below
30 m³/s. Beyond 500 m, small streams have the rate of the < 0.1 m³/s class. Of the 32 WSGs with CH in small
streams near or far, 11 have both, 8 only near and 13 only far. Coastal small streams draining straight to the
sea (`none`) carry CH more often than inland small streams far from a large river.

### Sensitivities (U, relative rates)

- **The step below 0.5 m³/s survives** each of these: regulated reaches out, the Nechako 2010 project out,
  CHES and NECR out, parent-flow visits out, duplicates kept, gradient as a covariate, season as a covariate,
  natural-barrier filtering (with or without USER_DEFINITE), routed flow alone, and fwapg's old MAD. Under
  0.5 m³/s the rate stays at 0.08–0.74 of the average; from 0.5 m³/s it is above 1, except 1–3 m³/s
  with barriers filtered (0.84) and ≥ 100 m³/s on fwapg's old MAD (0, from 9 visits).
- **The source moves the step.** On wet's balance alone, 0.28–0.5 m³/s reads 0.29 and 0.5–1 m³/s reads 0.54.
  On routed flow they read 0.55 and 1.46. The two sources agree on the class for only 53–67 % of visits
  between 0.1 and 1 m³/s, against 75–99 % elsewhere. So the step lies somewhere between 0.5 and 3 m³/s, and
  where exactly depends on the flow model. Small-stream flow is where both models are weakest
  (`modelled_discharge.md`).
- **Regulated reaches out**, the top classes are:
  - ≥ 100 m³/s: 149 visits, 41 CH (27.5 %), relative 3.2;
  - 30–100 m³/s: 153 visits, 12 CH (7.8 %), relative 8.3.

  The rise above 10 m³/s is therefore not only the Nechako, but it rests on few unregulated visits.
- **No river polygons.** This removes 72 % of the detections, which happen to sit in river polygons. The
  class ranks hold, rising from 0.34 to 4.5 between < 0.1 and 3–10 m³/s.
- **Distance.** Keeping the ambiguous placements gives 30.2. Leaving out lake targets gives 28.8. Leaving out
  walks with an entry gap over 200 m (lake tributaries, whose code points at the river that feeds the lake)
  gives 24.0.
- **Cross-check.** 4,384 bcfishobs CH records are not FDIS. Their life stage is almost all unrecorded, and they
  include other methods and adults. 13 % of them sit under 0.5 m³/s, against 16 % of FDIS CH visits. They are
  spread over 1–100 m³/s much more evenly than FDIS, whose ≥ 100 m³/s share (54 %) is the Nechako survey.

## What it means for link's CH bounds

link's `default` CH rearing bounds come from Rebellato et al. 2024 (evidence data rows 118–119): MAD 0.28 to
100 m³/s. Woll 2015 (Mat-Su, data row 412) set no potential below 0.5 m³/s. Against these:

- **A floor between 0.28 and 0.5 m³/s is too sharp a line.** CH are caught at 0.1–0.28 m³/s at nearly the rate
  of 0.28–0.5 (relative 0.47 against 0.61; raw 3.2 % against 3.3 %), and about half of the detections under
  0.5 m³/s are within 500 m of a large river (82 of 153; 31 of 57 at 0.1–0.28). Away from a large river,
  small streams carry CH at the < 0.1 m³/s rate (0.8 %).
- **The rule this suggests** is: MAD ≥ 0.5 m³/s, or MAD < 0.5 m³/s within about 500 m of a ≥ 10 m³/s river. It
  would fit these records better than either single floor. It is evidence for link#331's predicate, not a
  change made here.
- **A rearing maximum of 100 m³/s gets no support.** CH are caught on 27.5 % of unregulated visits above
  100 m³/s. Electrofishing samples only river margins, so this says the margins are used, not that the channel
  is.
- **Spawning bounds (0.46 m³/s) cannot be tested.** These are juvenile records (S1).

## Limits

- **Juveniles only.** FDIS caught 2 CH ≥ 150 mm in the whole export. This is rearing, not spawning.
- **Margins, not channels.** Electrofishing works at the edges, so large-river use is measured at the margins.
  72 % of detections are inside river polygons, so large rivers are not missing. Their interiors are.
- **Modelled, natural flow.**
  - Small-stream classes are uncertain: the two sources agree on the class only 53–67 % of the time there.
  - On regulated rivers the flow is wrong in kind, which is why those visits are flagged and left out in a
    sensitivity.
  - CABD records a degree of regulation for only 38 dams. Regulated means a reservoir, or regulation of 10 %
    or more.
- **One survey dominates the top class.** Each class reports its top-project share; read any class above
  50 % as that project.
- **Distance is measured to the large river's centreline** where a tributary's mouth meets it, so it includes
  half the receiving channel's width. The 500 m class therefore includes tributary mouths on wide rivers.
- **A WSG with CH only near or only far** informs the distance contrast only through its rate against other
  WSGs. 11 WSGs have both.
