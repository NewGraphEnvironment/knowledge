# Plan review — #28 (Plan agent, 2026-10-02, read-only; written here by the parent)

Reviewed `task_plan.md` and the draft `scripts/0290-bt-use-build.R` against local fwapg, `fdis_sites.csv` and link.

## Blocker
- **B1. The installed link is 0.50.0, without `lnk_species_pooling`.** → It was run from a scratch library holding link 0.55.0, built from the checkout. The version now goes in the ledger.
- **B2. A union of `fresh_default` and `score284_default` double-places visits.** The two share 15 WSGs: 11,421 visits match in both, and their segmentations differ (BULK 42,860 vs 87,639 segments). → 0290 already reads score284 only for the 8 held-out WSGs. Held-out vs calibration is therefore confounded with segmentation and link version.

## Gap
- **G1. Zero-fish visits drive the taper.**
  - Share of visits with no fish of any species: 0.27 at ≤ 5 %, 0.52 at 5–10.49 %, 0.62 at 10.49–14.49 %, 0.64 above that.
  - BT detection given any fish: 0.209 → 0.259 → 0.259 → 0.337.
  - FDS and FDIS data sets differ in their zero share at low gradient (0.13 vs 0.46).
  - → Hurdle decomposition, P(any fish) × P(BT | fish), with the fishless part placed as access/range bias.
- **G2. `access_bt` codes and circularity.**
  - Codes: -9 species absent, 0 blocked, 1 modelled, 2 BT observed upstream (link `R/lnk_pipeline_access.R:16-21`).
  - Code 2 is defined from bcfishobs, mostly FDIS: detection is 0.34/0.52 on code 2 against 0.03/0.07 on code 1, and the code-2 share falls with gradient.
  - → Population is `access_bt IN (1,2)`; never use it as a covariate; name the mix. Report the 45 BT detections on code-0 segments.
- **G3. Repeat visits.** 1,524 locations hold 4,840 visits, up to 32 at one place. → Cluster-bootstrap by stream (blue_line_key) or use a GLMM.
- **G4. Nuisance terms.**
  - Year: the median is 2009 at ≤ 2 % but 2000 in steeper bands.
  - `data_set` (FDS vs FDIS), agency, month, `n_pass`.
  - → Add `data_set` and an era term; check month.
- **G5. Effort scale.**
  - `area_m2` runs from 0 to 1.8 M m². 264 visits are under 10 m² and 136 are over 10,000 m².
  - Under a logit, the ratio depends on the effort level chosen.
  - → cloglog with offset(log area) after a declared trim; keep the logit as a check. Keep the no-area visits so the time model can use them.
- **G6. Hold-out level.** Detection at ≤ 2 % is 0.097 in calibration and 0.293 held out. → Compare shape only, with intercepts re-estimated. PARS/KOTL/BULK/MORR are in both schemas and can measure the segmentation effect.
- **G7. Bands vs link semantics.** Step 5's core is default rearing; its bands are rearing-flag flips between variants. Only 73 % of visits at ≤ 10.49 % are on rearing segments. → Core = `rearing AND gradient ≤ 0.1049`. Tag held-out visits with their step-5 class from the `score284_bt_rear_*` schemas.
- **G8. Edge types.** 740 visits sit on 1200/1410/1450/1475 connectors. 2,764 sit on 1250 (double-line river), where detection is 0.189. → Use stream and canal edges plus river polygons, as step 5 did; 1250 as a sensitivity check.
- **G9. Ambiguous char codes.**
  - BT/DV, DV/BT and DVxBT are this repo's extension of the pooling.
  - SLV-only (2 visits) and BT/DV codes in non-pooled WSGs (19) currently read as BT absences.
  - → Those codes block a BT absence. Run a sensitivity check without the non-pooled WSGs (682 visits, 270 DV-only).
- **G10.** `flag_ws50_mismatch` (411 kept) is not handled. → Drop, and count in the ledger.

## Assumption
- **A1. Visits near breaks.**
  - About 52 % of visits sit within 1 m of a segment break (link breaks at observations).
  - 1,269 score284 visits sit within 1 m *below* a break, so `[drm, urm)` gives them the downstream segment.
  - Segments under 20 m are three times as often gradient 0.
  - → Take the upstream segment when a break is within a few metres upstream. Check against a 100 m window gradient.
- **A2.** Elevation: segment mid Z is what 0290 computes, matching link. Plan text corrected.
- **A3.** `lnk_species_pooling` works outside the pipeline once installed. Filter the aoi to link WSGs first.
- **A4.** Per-visit detection is not sightings per km: step 5's taper mixes in sampling density.

## Ordering
- **O1.** Fix the analysis spec (model, nuisance terms, minimum n, hold-out metric, monotonicity rule) in 0291's header **before** fitting.
- **O2.** Literature is independent of the fitting.
- **O3.** Pin link before re-running.

## Scope / Acceptance
- 35 % of input is dropped as "WSG not in link". Say so.
- The `>14.49 %` band is never rearing. The link draft must say whether weights apply to rearing segments only.
- `elevation` in the literature vocabulary needs a unit rule.
- There is no minimum n per band, no rule for non-monotone or flat curves, and no defined hold-out metric. Add data checks: the ledger partitions; no visit sits in two schemas; the visit table stays ignored and is synced to S3.

## Disposition (parent)
All accepted except as noted in `findings.md`, "Plan review disposition".
