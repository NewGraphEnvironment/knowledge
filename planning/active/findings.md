# Findings — Measured site gradient against link's segment and Atlas-line gradients at FDIS visits (#121)

## Issue context

**If we do it:** we know how closely the gradient every habitat rule reads (link's segment gradient, and the whole Atlas line's) follows the gradient surveyors measured at the same sites, and so how far a tuned gradient limit can be taken as a limit on the ground. **If we never do:** every gradient threshold is a threshold on a modelled quantity whose error against the stream nobody has measured.

## Problem

From #92 the tuning reads `segment_gradient`, with `fwa_gradient` as its sensitivity. Both come from the Freshwater Atlas, averaged over a segment or a whole line. FDIS surveyors measured gradient at many of the same visits, and `research/fdis_export.md` compares measured with modelled **width** (log correlation 0.54 over 3,637 sites), but not gradient: it says only that the comparison against the segment gradient the model uses has to come first. The link research that was to make it closed without doing so.

The data is already built. In the evidence build the published grades name (`data/fdis/derived/visits_link.csv`, md5 `1bd35829`), 18,759 of 45,529 visits carry a measured `gradient_pct` (from the form's `GRADIENT11`/`GRADIENT12`, sentinels over 100 % dropped by `0230`) beside `segment_gradient` and `fwa_gradient`; 9,397 also carry `gradient2_pct` (`GRADIENT21`/`GRADIENT22`). 55 visits have a negative `segment_gradient` (counted 2026-10-30). The 2026-10-25 build (md5 `d3a434e2`), which a checkout may still hold in its ignored `data/`, has 17,705 of 40,552 and 32 negative, so check the md5 before reading any count.

## Proposed

- [ ] Read what the form's two gradient fields measure (the FDIS data dictionary, or the submission template) before using `gradient2_pct`.
- [ ] Run on the evidence build the published grades name (`evidence_md5`), not whatever a machine holds.
- [ ] Write it as a script that takes the visit table's directory (`EVIDENCE_DIR`, as `data-raw/compare_structures_check.R` does), so #120 reruns it unchanged on the minimal network.
- [ ] Measured against `segment_gradient` and against `fwa_gradient`, in the same units: agreement (log or rank correlation, and the ratio's p10 to p90, as the width comparison reports), and how it varies with segment length, stream order and the measured value itself.
- [ ] The band the rules turn on: within the gradient classes where CH rearing's and BT's limits sit, how often a visit's measured and modelled gradients fall on opposite sides of the published limit.
- [ ] Whether the error differs between visits that caught a species and visits that did not, since link cuts segments at catches (the bias #120 is about).
- [ ] The negative segment gradients: what they are and whether any visit's pick depends on one.
- [ ] Results into `research/fdis_export.md` beside the width comparison, and a sentence in the methodology article's limits once it holds.

## Not proposed

No change to the gradient a rule reads. A point measure over a surveyed site and a segment average are different quantities, so this measures how far apart they are; it does not replace one with the other.

Taken from link's issue on observation points (`NewGraphEnvironment/link#294`, its question 2), which closes pointing here. Runs again under #120 on the minimal network: the two runs together show how much of the error, and of any difference between visits with and without a catch, comes from link cutting segments at catches. Relates to #70 (fixed-window gradients), #92 (segment gradient), #120 (how the cuts move the tuning).



## What the form's two gradient fields measure (Phase 1, 2026-10-30)

- **The card.** RISC, *Reconnaissance (1:20,000) Fish and Fish Habitat Inventory: Site Card Field Guide*, Version 2.0,
  April 2008 (www2.gov.bc.ca `.../risc/sitecard20.pdf`), p. 13, "Gradient %": "Definition: The slope, or rate of
  vertical drop per unit of length, of the channel bed. Method: Measure at a minimum of two sites along the sample site
  over as long a distance as possible." Recording: "Record the method code to the nearest 0.5%" with codes GE (ground
  estimate), C (clinometer), AL (Abney type level), MAP, S (surveying equipment), GIS, O, NS. Elaboration: keep the
  channel length as long as possible, upstream and downstream; on shorter sections sight between similar habitat units
  (riffle crest to riffle crest). The card front (`scf.pdf`) has a GRADIENT % box of two rows of two cells with a method
  column.
- **The database.** `FDIS_SITE_SURVEYS` carries `GRADNT1_MTH_CODE` and `GRADNT2_MTH_CODE` (one method code per row of
  the box); the values sit in `FDIS_SITE_MEASUREMENTS` (`MEASURE_TP_CODE`, `SEQUENCE_NUMBER`, `MEASUREMENT`). So
  `GRADIENT<t><s>` in the export reads as measurement type t (gradient 1 or 2, each with its own method) and sequence s
  (the two places along the site). The export carries neither method code, so which method a value came from is not
  known: a GIS or map reading recorded as gradient 1 cannot be told from a clinometer reading.
  `0230` takes `gradient_pct` as the mean of `GRADIENT11/12`, `gradient2_pct` of `21/22`.
- **The two against each other** (published build `1bd35829`): 18,759 visits have `gradient_pct`, 9,397
  `gradient2_pct`, 9,389 both, 8 the second alone; 55 have a negative `segment_gradient`, none an NA one (the issue's
  counts, reproduced). Where both exist: median difference 0 (p10 −3, p90 +3.5 points), second higher at 47 %, equal at
  12 %, lower at 42 %; Spearman 0.90; median 5.5 % each; ratio second/first p10 0.63, median 1, p90 1.67.
  0230's comment that the second "runs higher" does not hold on this build as a typical difference.
- **Decision.** `gradient_pct` is the measured gradient compared. `gradient2_pct` is reported in one block as a second
  comparison, and the first-against-second spread (ratio p10–p90 0.63–1.67) is reported as the yardstick: how far two
  readings at the same site, by possibly different methods, already disagree. A modelled gradient cannot be expected to
  agree with a reading better than two readings agree with each other.

## The check on the published build (Phases 2 and 3, 2026-10-30)

Log: `scripts/logs/habitat/20261030_site_gradient_check.txt` (evidence `1bd35829 009698d7 99f499bb`, the build
`data/thresholds.csv` names). Stream branch 29,335 placed visits, the count of #92's
`20261027_segment_gradient_check.txt`; 16,279 with a measured gradient. Rearing key populations equal the tracked
`n_visits` once the groups-with-both filter of `knw_tune_score()` (`.tune_modelled()`) is applied; the first run
without it was refused by the script's own guard.

- **Yardstick (two readings at one site):** Spearman 0.90, ratio p10–p90 0.60–1.58, median absolute difference
  0.01 (1 point).
- **Measured against segment gradient, stream branch:** Spearman 0.69, log r 0.64, ratio p10–p90 0.33–2.22, median
  ratio 0.90, median absolute difference 2.2 points, p90 9.3 points; the model higher at 56 %. Against the Atlas line:
  0.65, 0.62, 0.26–1.94, 0.83; 2.5 and 13.0 points; higher at 61 %. The segment follows the site better than the line
  does on every summary. Width's log r is 0.54 for comparison.
- **By length:** best on 50–250 m segments (Spearman 0.73); shortest segments (≤ 10 m) worst (0.53, ratio p90 3.4).
  **By order:** best on orders 2–4 (0.70–0.71); order 1 0.63 with the model higher at 62 %; orders 5–6 the model
  reads far lower than the site (median ratio 1.24, 2.05). **By measured class:** the model reads high on gentle sites
  and low on steep ones (regression to the middle): model higher at 67 % for measured ≤ 3 %, 23 % above 30 %.
- **Waterbodies:** rivers, wetlands and lakes agree poorly (Spearman 0.37, 0.21, 0.33); they are outside the tuning.
- **Flips at the published limits (each key's population, segment gradient):** CH rearing 0.11: 6.4 % of 2,453
  visits; in the modelled band (0.09, 0.13] 33.9 % of 218; in the measured band 31.2 % of 160. BT rearing 0.30:
  0.8 % of 4,427; band 15 visits, 40 %. BT spawning 0.13 (before the spawner filter): 8.5 % of 5,660; band 34.3 % of
  446. CO and GR at 0.0549: 25.8 % and 11.7 %. Within one ladder step of a limit, a third to two fifths of visits sit
  on the other side of it on the ground. Readings exactly on a limit: 45 at 13 %, 22 at 11 %, 1 at 30 %.
- **By catch:** at sites with fish the median absolute difference is smaller (1.7 against 2.6 points), but the ratio's
  p90 is wider (2.63 against 2.02). Within measured-gradient classes the median differences come close (1.2 vs 1.6,
  1.9 vs 2.1, 2.7 vs 3.0, 6.2 vs 6.0 points), so most of the gap is that fish sites are gentler. Within segment length
  classes, short segments at fish sites agree much better than short ones at empty sites (2.4 vs 6.6 points, Spearman
  0.64 vs 0.41): link's cut at a catch makes a short segment that fits the site. Per species, sites where the species
  was present flip less at its limit than where absent (CH 4.1 vs 6.5 %, CO 18.1 vs 27.4 %, GR 2.2 vs 15.0 %).
- **Negative segment gradients:** 55 placed visits, values −0.136 to −0.0001, 52 on the visit's own Atlas line, none
  on the stream branch (all on edge types 1200, 1400, 1410 and 1425, which the stream branch excludes; 34 in
  wetlands, none on a river or lake), so no key
  population holds one: 0 of 6,149–8,385 rules per key move when they are set to 0. `knw_rule_in()` fails a negative
  under every rule (`g >= 0`), while the curve and the grade clamp it to 0 (`R/tune_curve.R:81`, `R/grade.R:59`); the
  two treatments differ, but on this build it reaches nothing.
- **Phase 3:** `segment_gradient` enters the pick only through `knw_rule_in()`'s threshold test, and the curve and
  grade read it clamped to [0, 0.2]. No pick depends on a negative here; on another build the check's last block
  counts it.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| Rearing key populations 1.0–3.4× the tracked `n_visits` (first run) | `knw_tune_score()` keeps only groups with both outcomes; the script now applies `.tune_modelled()`, and its guard refused the run until it did |
