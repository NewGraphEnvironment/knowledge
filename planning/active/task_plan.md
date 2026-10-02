# Task: Habitat weights, not only cutoffs: what BT use by gradient, elevation, size and effort should mean (#28)

## Problem

link models habitat with hard cutoffs: a segment is BT rearing if its gradient is at or under `rear_gradient_max`, and not otherwise. That makes maps easy to read, but fish don't see a cliff. NewGraphEnvironment/link#284 step 5 measured what the cliff hides: BT and DV sightings per km of stream, by gradient band, on eight watershed groups held out from the threshold's calibration (ELKR, BULL, UARL, REVL, CLRH, LILL, BABL, BABR).

Sightings per 100 km, held out. "Core" is rearing under every cutoff tested; bands are the stream each looser cutoff adds.

| stream | km | sightings | per 100 km | vs core |
|---|---|---|---|---|
| core, gradient ≤ 2 % | 4,872 | 908 | 18.6 | 1.03 |
| core, 2–5 % | 3,045 | 603 | 19.8 | 1.10 |
| core, 5–8 % | 1,592 | 249 | 15.6 | 0.87 |
| core, 8–10.5 % | 687 | 81 | 11.8 | 0.65 |
| band 10.5–12.5 % | 422 | 46 | 10.9 | 0.60 |
| band 12.5–13.5 % | 163 | 21 | 12.9 | 0.71 |
| band 13.5–14.5 % | 138 | 8 | 5.8 | 0.32 |

Use tapers; it doesn't stop. The cutoff (link's `default_tuned` keeps 0.1349) is one line drawn across that taper.

**The taper is not gradient alone.** Core rearing itself thins with elevation: 24.6, 19.3 and 10.2 sightings per 100 km in the low, mid and high thirds of each watershed's own rearing. The steep bands sit mostly in the high third (263 of 422 km for the first band). Comparing each band with the core at its own elevation raises the first two bands to about 0.75 and 0.89 of the core rate, and leaves the third at about 0.40. So part of what reads as "too steep" is "higher up": colder, smaller, less sampled.

A second number argues the other way: about a quarter of the first band (101 of 422 km) is not steep at all. It is lower-gradient stream newly counted as rearing because the looser cutoff connects its cluster to spawning. A weight on gradient would miss that.

## Decisions taken at the plan gate (approved 2026-10-02)

1. **The weight is observed use, corrected for effort.** It is the probability of detecting BT on a standard electrofishing visit, relative to core rearing, capped at 1. Intrinsic potential cannot be separated out of presence data, so it is not claimed. Access and detectability are named as residual bias.
2. **The shape handed to link is a band table** on link's ladder (≤2, 2–5, 5–8, 8–10.49, 10.49–12.49, 12.49–13.49, 13.49–14.49, >14.49 %), one weight per band, stored like the threshold CSVs. Not a fitted logistic.
3. **Elevation is matched like step 5**, as within-WSG thirds of each group's rearing elevation, with absolute elevation as a sensitivity check. It goes into the weight only if it improves held-out prediction. Otherwise it is "handled elsewhere" (temperature, by link#21 GSDD).
4. **The link issue is drafted, not filed.** The draft goes in the final report for approval.


## Phase 1: Visit table on link's segmentation
- [x] `scripts/0290-bt-use-build.R`. Read `data/fdis/derived/fdis_sites.csv` and place each visit on a link segment: `blue_line_key` with `downstream_route_measure` in [drm, urm), from `fresh_default.streams` ∪ `score284_default.streams`. Use local fwapg :5432, connecting the way 0230 does.
- [x] Per visit, record:
  - segment `gradient` and `channel_width` (with its source);
  - `access_bt`, plus BT `spawning`/`rearing` under default;
  - elevation at the point (the FWA geometry's Z);
  - the WSG's rearing-elevation third, computed from segment midpoints over that WSG's BT rearing;
  - measured gradient and width;
  - effort and catch status.
- [x] BT presence is `n_bt` + `n_dv` where `lnk_species_pooling()` pools, and `n_bt` alone elsewhere.
- [x] Absence only where `catch_status` is known and `blocks_absence_of` does not include char.
- [x] Drop `flag_effort_sentinel`, `flag_not_placed`, `flag_far_snap` and `flag_junk_date`, and count each drop in a ledger.
- [x] Analysis population: visits on `access_bt` segments in WSGs where link marks BT present. Tag each visit held-out (the 8 step-5 WSGs) or calibration.
- [x] Outputs:
  - per-visit table to `data/fdis/derived/bt_use_visits.csv` (ignored, private; synced to `s3://fresh-bc/fdis/derived/`);
  - ledger to `scripts/logs/habitat/<date>_bt_use_build_ledger.csv`.

- [x] Revised after the plan review (`review-plan.md`, disposition in findings.md):
  - only the 8 held-out WSGs read from score284_default;
  - placement takes the segment starting at the site (within −1 to +5 m), else the segment containing it;
  - ambiguous char codes block a BT absence;
  - ws50 mismatches dropped;
  - step-5 class and score284 gradient carried for the comparisons;
  - link version and tracker md5 in the ledger.

## Phase 2: Effort-corrected use curve
- [ ] `scripts/0291-bt-use-curve.R`, pure R from the visit table.
- [ ] Raw detection per gradient band, then a binomial GLM: present ~ band + elevation third + log(area_m2). Same with log(fishing_time) as a check.
  - *Revised (plan review G1/G4/G5/G7):* three responses, each cloglog with offset log(area), plus data_set, era and WSG:
    - BT caught;
    - any fish caught;
    - BT given fish.

    Classes are on link's ladder, with "accessible, not rearing ≤ 10.49 %" as its own class. Intervals come from a stream-cluster bootstrap. The spec is fixed in 0291's header before the first fit.
- [ ] Predicted detection per band at median effort, relative to the core bands (≤ 10.49 %), with intervals.
- [ ] Driver checks, each reported with and without:
  - band × elevation;
  - channel width and MAD where non-null, with their null share;
  - site-measured vs segment gradient.
- [ ] Q4: size-class mix by band, joining `data/fdis_evidence.csv` on `site_visit`. Fry and juvenile against subadult and adult in steep bands.
- [ ] Hold-out: fit on calibration WSGs, then predict held-out detections by band and compare to observed. Set the curve beside link's `taper.csv` and `elevation_adjusted.csv`, stating that the two share data.
- [ ] Output: `data/bt_rear_use_curve.csv` (aggregates only: band × elevation class, visits, detections, raw rate, adjusted ratio, interval). Log the fits to `scripts/logs/habitat/`.

## Phase 3: Literature use curves
- [x] Search the `habitat_modelling` store with `ragnar::ragnar_retrieve()` directly (cred `crd_search` is broken). Look for BT occurrence or abundance curves by gradient, elevation and temperature: Dunham & Chandler 2001, Isaak 2015, Rieman et al., Porter 2008 HSI, Watson & Hillman 1997, and anything else the store holds.
- [x] Add verified rows to `data/literature_evidence.csv` (`hsi`/`dist`/`qual`/`none`).
- [x] ~~Add `elevation` to the `variable` vocabulary~~: not needed. No source states an elevation value, and elevation appears only as a temperature proxy (findings.md, Phase 3).
- [x] Run the `0280` gate, then audit meaning row by row (CLAUDE.md, "the gate checks words, not meaning").
- [x] List sources the store lacks as gaps. Do not acquire beyond quick open-access PDFs filed via `0270`'s additions.

## Phase 4: Position and candidate weight
- [ ] `research/habitat_weights.md` with the provenance line:
  - answers to Q1–Q5;
  - a per-driver position table: gradient, elevation/temperature, channel size, effort, access/bridge (the 101 km of non-steep band-1 stream). Each is in the weight, handled elsewhere (with where), or bias to correct;
  - the dead ends.
- [ ] `data/habitat_weight_bt_rear.csv`: the candidate band table (gradient_min, gradient_max, weight, basis, n_visits, n_present, sources). Aggregates only, so it can leave this repo.
- [ ] Index row in `research/README.md`. Mention the new data files in CLAUDE.md's Layout.
- [ ] Draft the link issue (use-weighted km beside cutoff km, weights as bundle data) into `planning/active/link-issue-draft.md`.
- [ ] Revise the #28 body if findings change its spec, e.g. the bcfishobs stage claim or the #23 dependency.

## Validation

- [ ] `devtools::test("pkg")` passes (literature vocab test)
- [ ] `0280` gate clean
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then `/gh-pr-push`
