# Findings — Habitat weights, not only cutoffs: what BT use by gradient, elevation, size and effort should mean (#28)

## Plan-mode exploration (2026-10-02)

What exploration found that shapes the plan:

- **Effort and zero catch already exist, so this work does not wait on #23.** `data/fdis/derived/fdis_sites.csv` (from 0240) has 53,018 site visits. 51,450 are placed on FWA (`blue_line_key`, `downstream_route_measure`) and 49,037 of those have usable effort (`fishing_time_s`, `area_m2`). It also carries `catch_status` (fish 29,280, zero 21,639), `blocks_absence_of`, `n_bt`/`n_dv`, measured gradient and width, `fwa_gradient_pct`, `stream_order`, `mad_m3s`, and `modelled_channel_width_m`. 7,044 visits caught char, in 155 WSGs; 1,366 of those are in the 8 held-out WSGs. #23 is only the join to bcfishobs, and the curve does not need that join.
- **link's segmentation is on local fwapg :5432.** `fresh_default.streams` (55 WSGs), `streams_access` (`access_bt`) and `streams_habitat_bt` (accessible/spawning/rearing) are there, and `score284_default.*` covers the step-5 closure, which holds the 8 held-out pilots. So FDIS visits can be read against the segment gradient the model actually tests, as step 5 did.
- **Pooling:** `link::lnk_species_pooling()` and `inst/extdata/configs/default/species_pooling.csv` are installed. Reuse them rather than restate the region rule.
- **Life stage (Q4):** `data/fdis_evidence.csv` has char size classes (fry, juvenile, subadult, adult, spawner_evidence) per visit. That answers whether steep-water char are juveniles. link's `bands_pooled.csv` also shows some bcfishobs BT do carry a stage (10 of 46 band-1 records are "rear"), which partly corrects the issue's "bcfishobs has no BT life stage".
- **Not independent:** about 72 % of bcfishobs BT records are FDIS (#23). An FDIS curve and link's step-5 taper share a large part of their data, so their agreement is a consistency check, not corroboration. This gets stated.
- **Literature:** `data/literature_evidence.csv` has 12 BT rearing-gradient rows and 8 temperature rows (Isaak 2015, Porter 2008 HSI/CPUE, Bustard & Schell, Trotter, Dunham & Chandler 2001). It has no elevation rows, and `variable` has no `elevation` in `pkg/R/literature.R`'s vocabulary.
- **Temperature:** #20 and link#21 (GSDD) are open. Elevation is the proxy here.


## Errors Encountered

| Error | Resolution |
|-------|------------|

## Issue context

**If we do it:** BT (then CH) habitat quality becomes a defended weight between 0 and 1, built from fish use with the confounds named. link can then report quality-weighted km beside the familiar cutoff km, so "km of habitat unlocked above a crossing" stops jumping every time a threshold moves. **If we never do:** habitat stays on/off at a gradient cutoff. That cutoff silently stands in for temperature, channel size and sampling effort as well as steepness, and every km figure inherits the yes/no.

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

## Questions this should settle, before any math in link

1. **What should a habitat weight represent: intrinsic potential, or observed use?** Sightings per km are use. They carry sampling effort, access and detectability, not only preference.
2. **Which driver belongs in which weight?**
   - gradient;
   - elevation and temperature (growing degree-days), per #20 for the Fraser;
   - channel size (width is null on about half of accessible BT length in link's `fresh_default`);
   - sampling effort.

   They are correlated, and a gradient-only weight absorbs all four.
3. **Can effort be corrected for?** The FDIS site-visit table (#23) carries catch, effort and no-fish-captured. That is what separates "avoided" from "never sampled", which bcfishobs presence records cannot.
4. **Rearing vs adults.** bcfishobs has no BT life stage. The size classes from FISS submissions (#18, #21) could say whether steep-water records are juveniles rearing or adults moving through.
5. **What does the literature give as a use curve,** not a single cutoff, for BT by gradient and elevation? #19's evidence table and store are the starting point.

## Proposed Solution

1. From the questions above, a written position per driver: in the weight, handled elsewhere (for example temperature by NewGraphEnvironment/link#21's GSDD work), or treated as bias to correct.
2. A candidate weight curve for BT rearing (gradient, and elevation if it earns its place) with sources and the fish evidence behind it. Aggregates only where it leaves this repo, since link is public.
3. Then a separate link issue for the applied side: use-weighted km beside cutoff km in the rollups and per-crossing aggregation, with the weights as bundle data like the thresholds.

## Evidence

- link#284 step 5: `data-raw/logs/habitat_score_284/` in link (`taper.csv`, `elevation.csv`, `elevation_adjusted.csv`, `bands_pooled.csv`, `bridge_band.csv`, `verdict.csv`), produced by `data-raw/habitat_variants_score.R`. The method and the rule are in link's `research/habitat_thresholds.md`, "Step 5".
- Pooling: DV counts as BT per link's `configs/default/species_pooling.csv`. All eight held-out groups are in pooled regions.

Relates to #18, #19, #20, #23, NewGraphEnvironment/link#284, NewGraphEnvironment/link#21

## Phase 1 — the visit table (2026-10-02)

- **link segments overlap by up to ~1.4 mm** at 368,052 breaks in `fresh_default.streams`: the upstream measure of one segment exceeds the downstream measure of the next by float rounding. A point on a break matched two segments. 0290 takes the greatest downstream measure (`DISTINCT ON … ORDER BY drm DESC, id_segment`).
- `access_bt` codes (link `R/lnk_pipeline_access.R`): 0 = barrier downstream, 1 = modelled accessible, 2 = no barrier downstream and species observed upstream, NULL = not modelled. `>= 1` is kept. Code 2 ties access to observations, a small circularity against presence; it is noted, not corrected.
- `score284_default` holds 23 WSGs. 15 are also in `fresh_default`, and the other 8 are exactly the held-out pilots. 0290 reads score284 for those 8 only, so no visit is placed twice; a plain union of the two schemas would double-place 11,421 visits (review B2).
- Ledger, first run, superseded: 15,883 kept. The current ledger is under "Plan review disposition" below.
- First look, raw detection per visit by segment-gradient band:
  - **calibration:** about 0.10 everywhere, 0.044 at 13.49–14.49 %, and 0.10 above 14.49 %;
  - **held out:** 0.29 → 0.22 → 0.22 → 0.14 → 0.13 → 0.18 → 0.17 → 0.19.

  WSG baselines differ about threefold, so the model needs a WSG term before any band comparison.

## Plan review disposition (2026-10-02, `review-plan.md`; code-check round 1, `review-p1-round1.md`)

Every finding was accepted, as follows.

- **B1.** link 0.55.0 is installed into a session scratch library rather than the user library. The ledger records `link_version` and `species_pooling_md5`.
- **B2.** The plan text is corrected: score284_default is read for the 8 held-out WSGs only. Its in-sample pilots carry `segment_gradient_score284` as a segmentation check.
- **G1, the headline.** The visit table shows it before any model: the share of visits catching any fish falls steeply off core rearing, while BT-given-fish does not. The first probe's figures came from a superseded table (round 2 could not reproduce them); the current figures are in Phase 2, from 0291's log. → 0291 models three responses: BT caught (U), any fish (F), and BT given fish (C).
- **G2.** Population is `access_bt IN (1,2)`; never a covariate. BT detections on code-0 (blocked) segments are counted in the ledger (28 in the current run).
- **G3.** Intervals come from a cluster bootstrap by stream (blue_line_key).
- **G4.** `data_set` and era go in the model; month is a sensitivity.
- **G5.** cloglog with offset(log area), area trimmed to 10–10,000 m²; logit as a sensitivity. No-area visits are kept for the fishing-time model.
- **G6.** The hold-out compares shape only, with intercepts re-estimated.
- **G7.** Core = rearing under default. "Accessible, not rearing, ≤ 10.49 %" is its own class. Held-out visits carry `step5_class` from the `score284_bt_rear_*` schemas.
- **G8.** Edges are restricted to stream and canal plus river polygons; river polygons are a sensitivity.
- **G9 and code-check round 1.** Char codes are read from the codes file. Ambiguous codes block a BT absence; SLV blocks everywhere. The non-pooled WSGs are a sensitivity. The size join is pooling-aware.
- **G10.** `flag_ws50_mismatch` is dropped and counted.
- **A1.** Placement takes the segment starting at the site. Round 1's 5 m nudge was replaced in round 2 (below).
- **O1.** 0291's spec was written into its header before its first fit, which ran on the old design and was stopped unread.
- **Scope.** The 19,691 visits dropped as "WSG not in link" are stated. Whether weights apply only to rearing-flagged stream is a question for the link draft.

Current ledger (`scripts/logs/habitat/20261002_bt_use_build_ledger.csv`, numbers copied from the file): 53,018 in. Dropped:

| reason | visits |
|---|---:|
| not placed | 1,568 |
| far snap | 5,322 |
| ws50 mismatch | 1,122 |
| junk date | 23 |
| effort sentinel or none | 1,422 |
| catch unknown | 420 |
| WSG not in link | 19,691 |
| BT absent from WSG | 254 |
| BT absence blocked | 361 |
| no link segment | 885 |
| not BT-accessible | 4,344 |

**17,606 kept**, 2,619 with BT, 4,080 held out. 10,768 take a segment starting within −1 to +5 m of the site; the rest take the segment containing it. BT caught on code-0 (blocked) segments: 28.

- Overlap guard, at each site's own measure: 37 visits in fresh_default (max overlap 0.0014 m) and 11 in score284 (max overlap 0.0007 m), under the 0.01 m stop.

## Phase 3 — literature use curves (2026-10-02)

- **Store search.** `ragnar_retrieve()` on `habitat_modelling` returned eight queries' worth of chunks: BT occurrence or abundance by gradient, elevation and temperature; HSI curves; effort and false absence. The sources that carry a curve, not a cutoff, are Isaak 2015 (Table 4 logistic occupancy), Dunham & Chandler 2001 (logistic, juvenile occurrence at 100 m sites) and Porter 2008 (Thompson, FDIS CPUE and CART). MacPherson 2024, Rieman & McIntyre 1993 and Hagen's Skeena strategy give no gradient or elevation use relation; Rieman & McIntyre's elevation-growth sentence is a secondary citation of Mullan et al. 1992 and was not used.
- **A PDF glyph trap.** Isaak 2015 Table 4 prints −0.166 for BT slope, but pdftotext drops every minus sign in the table, so MinTemp reads +0.632. The sign was read from a 150 dpi render of PDF page 6. The row records the magnitude, which is what the gate can verify, and its note carries the sign.
- **Vocabulary.** First pass: no elevation value found, so `elevation` was not added (superseded). Round 1 of the Phase 3 review found Porter 2008's watershed-scale BT model fits mean elevation (Table 3.5, +0.002 per m on the logit scale), so `elevation` is now in `knw_literature_vocab()` with units m or ft, plus a test. The test was shown to fail when `percent` is allowed. No coefficient kind was added: coefficient rows are `qual` with a table quote, and the coefficient is in the note.
- **Rows added** (data rows 482–489), gate `scripts/logs/habitat/20261002_literature_verify.csv`, all 489 rows pass. Printed page against matched PDF page:
  - Isaak 2545/6 and S1-1/15;
  - Dunham & Chandler 15/18 and 30/33;
  - Porter 66/68, 37/39 and 51/53.

Meaning audit, row by row:

| row | claim the row makes | meaning check |
|---|---|---|
| 482 Isaak 2545 | BT occupancy falls with habitat-average slope, −0.166 per % on the logit scale | Table 4 BT block, Slope line. The quote's magnitude is right; the sign comes from the render and is stated in the note. Network scale (whole cold-water habitat, mean slope 7.96 %), so it is not a reach weight. `parameter = rear_gradient_max` follows the convention of row 98 (the same source's qual statement). |
| 483 Dunham & Chandler 15 | no habitat feature other than temperature, gradient included, explained juvenile occurrence | p. 12 lists gradient among the candidates, and p. 15 says none but temperature were likely. Site scale (100 m), Washington. A null, so qual with no value. |
| 484 Dunham & Chandler 30 | summer maximum temperature follows elevation, but the relation varies by place | Quote verbatim, p. 30. The 94 % sentence runs across pp. 15–16; the model is preliminary and fitted to 2000 streams only (round 1 fix). `variable = temperature`, no parameter. |
| 485 Porter 66 | juvenile BT occur across the whole FDIS gradient range | Same paragraph as row 103. Porter's Interior 2007–08 FDIS extract overlaps the province-wide export 0290/0291 use, so it is not independent; it is not the same data (round 1 fix). |
| 486 none | no graded reach- or segment-scale **occupancy** curve (presence against absence) by gradient or elevation | Restated after round 1, which found two errors in the first wording: a use-only reach-slope distribution (Isaak App. S1) and a watershed-scale elevation effect (Porter Table 3.5) both exist. The note now names what exists instead. |
| 487 Isaak S1-1 | juvenile BT (< 150 mm, 1,102 sites) cumulative share by reach slope: about 0.63 at 6 %, 0.84 at 9 %, 0.95 at 12 % | Figure read from my own render after the reviewer's reading; the numbers are approximate readings, stated as such. Use only, so no selection. |
| 488 Porter 37 | BT occurrence rises with mean watershed elevation (+0.002 per m, logit) | Table 3.5 layout text keeps the signs (Chinook −0.004, coho −0.003, BT +0.002). Network (watershed) scale; detections of any stage. |
| 489 Porter 51 | macroreach BT model keeps sinuosity and bankfull width; gradient and elevation were candidates and not kept | Table 3.15 BT block, Table 3.13 candidates p. 50. Segment scale. |
- **Gaps (not in the group library).** None was acquired: none is an open-access PDF that turned up in a quick look, and none would change the position, since each is a site- or patch-scale occurrence study already summarised by Dunham & Chandler 2001.
  - Watson & Hillman 1997, the BT occurrence models cited by Trotter 2000 and Dunham & Chandler 2001;
  - Rieman & Chandler 1999, the regional BT–temperature database;
  - Dunham & Rieman 1999, patch size and isolation;
  - Mullan et al. 1992 (elevation and growth).

## Code-check, Phase 1 (rounds 1–2 and the enumeration)

| round | findings | fixed | accepted | inside a previous fix? |
|---|---|---|---|---|
| 1 | 3: SLV missing from a literal char list; BT/DV ambiguous codes read as confirmed absences; a duplicate guard that could not fire | 3 | 0 | — |
| 2 | 4: the 5 m nudge skipped short segments starting at the site (817 visits, 171 changing band); `bt_n` excluded the hybrid and ambiguous codes `bt_present` counts (27 rows); the overlap guard did not cover fallback placements; G1 figures in findings not reproducible | 4 | 0 | **yes**: the nudge was this session's fix for plan-review A1 |

- **Mechanism.** A rule was restated by hand where the data already define it:
  - a fixed nudge stood in for "the segment starting at the site";
  - a literal list stood in for the codes file;
  - a count column was built from fewer codes than the presence rule uses.
- **Fixes:**
  - placement takes the lowest segment start within −1 to +5 m of the site, else the segment containing it;
  - `bt_n` is gone (unused; `n_bt`, `n_dv` and `n_char` stay raw);
  - the overlap guard runs at the site's own measure, where every placement starts;
  - the G1 numbers move to Phase 2.
- **Ended by enumeration, not by a quiet round** (scratch `enum_place.R`):
  - placement restated independently in R over all 17,606 kept visits: **17,606 match, 0 mismatch**;
  - presence restated independently over every kept visit (2,039 distinct code combinations): **17,606 agree**;
  - kept absences carrying a presence or blocking code: **0 of 14,987**.

### Code-check, Phase 3 (rounds 1–2 and the enumeration)

| round | findings | fixed | inside a previous fix? |
|---|---|---|---|
| 1 | 4 | 4 | — |
| 2 | 3 | 3 | **yes** |

Round 1 (`review-p3-round1.md`):
- row 486's "none" claim missed Isaak App. S1 Fig. 1 and Porter's elevation term;
- row 484's page;
- row 485's "same FDIS data".

Round 2 (`review-p3-round2.md`), all in the round-1 rewrites or new rows:
- row 488 listed three of the six covariates;
- rows 486 and 489 called Porter's macroreach result a gradient "null". Table 3.13's AIC values for gradient models are not consistent with nested fits, so it is "a candidate, not selected";
- row 485 gave the extract a date (2007–08) the source does not state.

Fixing round 2, I also had p. 15 for the 254-site figure; it is printed p. 16.

**Mechanism.** Notes were written from memory of a read, not from the page. Numbers, page numbers and covariate lists were carried in prose and never re-opened.

**Ended by enumeration.** Every checkable claim in the notes of rows 482–489 (29 claims: numbers, page numbers, labels, covariates) was matched by regex against the PDF page it names, through pdftotext `-layout`. 28 match. The 29th, the figure label "Bull Trout < 150 mm (1102 sites)", is drawn in the image, has no text layer, and was confirmed on a 100 dpi render, as were Isaak's minus sign and the curve readings. The gate passes on all 489 rows.

## Phase 2 — the effort-corrected use curve (2026-10-02, `scripts/0291-bt-use-curve.R`)

All figures below are from `data/bt_rear_use_curve.csv` and `scripts/logs/habitat/20261002_bt_use_curve.txt`.

**Population.**
- Of 0290's 17,606 visits, 16,729 sit on stream, canal or river-polygon edges.
- 14,463 of those have a fished area of 10–10,000 m², and 1,997 caught BT.
- Fits use the WSGs where the response has both outcomes: 53 for BT caught (13,161 visits), 57 for any fish and 52 for BT given fish.

**Run history, kept as evidence.**
- Run 1 used the pre-review design and was stopped unread.
- Run 2 used the visit table round 2 corrected and was stopped unread.
- Run 3 was the forked bootstrap. It segfaulted in `glm.fit` under the Accelerate BLAS, and the guard stopped it. The task reported exit 0 only because of a trailing `echo`.
- Run 4 died in a sensitivity check: a one-data-set subset cannot carry a `data_set` term. Now a one-level nuisance term is dropped.
- Run 5 finished, but F and C did not converge (coefficients near 1e14) and every bootstrap interval was 0 to Inf.
  - Cause: the offset(log area) assumption. With log(area) free, its coefficient is 0.07 (F) to 0.19 (U, C), not 1.
  - Spec Change 1 in 0291's header: area becomes a covariate, the WSG filter needs both outcomes, and a non-converged fit gives NA.
  - The change was made from the convergence failure. The weights it produced had not been read, because they were 0/NaN.
- Run 6 is the reported one. Run 7 is its reproducibility check (below).

### Weights, all WSGs (1 = count-weighted core; 95 % stream-bootstrap interval)

| class | visits | BT caught (U) | any fish (F) | BT given fish (C) |
|---|---:|---|---|---|
| core 0–2 | 5,024 | 0.92 (0.81–1.03) | 1.16 | 0.79 (0.69–0.92) |
| core 2–5 | 2,600 | 1.25 (1.09–1.40) | 0.94 | 1.31 (1.08–1.46) |
| core 5–8 | 1,364 | 0.89 (0.73–1.14) | 0.69 | 1.18 (0.93–1.44) |
| core 8–10.49 | 547 | 0.74 (0.54–0.97) | 0.57 | 1.16 (0.85–1.58) |
| not rearing ≤ 10.49 | 3,244 | 0.50 (0.40–0.61) | 0.36 | 1.07 (0.82–1.35) |
| 10.49–12.49 | 607 | 0.64 (0.46–0.83) | 0.38 | 1.27 (0.86–1.77) |
| 12.49–13.49 | 203 | 0.50 (0.25–0.75) | 0.34 | 1.27 (0.63–2.03) |
| 13.49–14.49 | 157 | 0.27 (0.07–0.51), underpowered | 0.24 | 0.88 (0.27–1.79), underpowered |
| > 14.49 | 717 | 0.56 (0.35–0.74) | 0.29 | 1.20 (0.81–1.79) |

### What it says

1. **Use falls with gradient. The fall sits in where fish and BT are present, not in BT's share among fish.** *(Wording revised after review round 1; see the dead ends.)*
   - Given that a visit caught any fish, BT turn up as often on steep accessible stream as on core rearing: C is about 1 or above in every class off the core, and every one of those intervals includes 1 (0.82–1.35 not rearing; 0.86–1.77, 0.63–2.03, 0.27–1.79, 0.81–1.79 steep).
   - What falls is whether a visit catches fish at all (F): 1.16 on low-gradient core, 0.57 at 8–10.49 %, 0.24–0.38 beyond.
   - A fishless steep visit is consistent with being above an upper fish limit, or on a fishless stream. The analysis does not locate that limit.
   - C ≈ 1 does not prove equal quality: a BT-only visit is a fish visit, so C can hold up as other species drop out.
2. **The steep classes hold mostly small BT, with some spawner evidence.**
   - 87–94 % of measured BT there are fry or juveniles: 249 fish at 10.49–12.49 %, 294 above 14.49 %.
   - 80–100 % of BT visits with measured fish there include fry or juveniles: 80 % is the 5 such visits at 13.49–14.49 %.
   - Low-gradient core holds the large adults (511 of 3,195 measured fish at 0–2 %).
   - Spawner evidence per BT visit is higher on steep stream: 9 of 63 at 10.49–12.49 % and 9 of 75 above 14.49 %, against 23 of 791 at 0–2 % (round 1 caught a raw-count comparison).
3. **A single elevation term does not earn a place, but elevation is not irrelevant.**
   - Held-out log-likelihood is −1,754.2 without the elevation third and −1,836.5 with it, worse by 82.4 against the bar of +2.
   - The cause is a sign flip between groups. On held-out core, BT per visit falls by elevation third: 0.40, 0.28, 0.11, on 942, 818 and 913 visits. Calibration core rises: 0.10, 0.17, 0.16.
   - So in the step-5 WSGs the taper is per-visit detection, matching step 5. It is not sampling density, which a first draft claimed from the all-WSG average (mid 1.27, high 1.01).
   - It is regional, which is why temperature belongs with link#21's GSDD work.
4. **Channel size explains part of the steep decline.**
   - log(segment width) has coefficient +0.229 (SE 0.028) in U, so larger streams have more BT.
   - Adding width moves the steep U weights from 0.73, 0.50 and 0.40 to 0.88, 0.64 and 0.49 (width subset).
   - Adding MAD moves them further on the MAD subset: 0.50 → 0.89, 0.34 → 0.64, 0.15 → 0.30 and 0.51 → 0.94 (lifts of 0.15–0.43).
   - The null shares: segment width 12.7 %, measured width 57.1 %, MAD 25.3 %.
5. **Data sets agree on the first steep step.**
   - FDS-only U weights for the steep classes are 0.60, 0.91, 0.50 and 1.12; FDIS-only are 0.61, 0.44, 0.31 and 0.50.
   - They agree at 10.49–12.49 %. The steeper FDS classes rest on few detections, two of them under the power rule.
6. **Held out vs calibration.**
   - Held-out U: 0.42 at 10.49–12.49 % and 0.50 above 14.49 %, against calibration 0.75 and 0.63.
   - Held-out C: 0.79 and 0.77, against calibration 1.55 and 1.81. The intervals overlap.
   - Held-out step-5 classes are too sparse to read: 85, 34 and 20 visits in the three bands.
7. **Robust to the effort measure and the link.** The time-effort, logit, no-river-polygon, pooled-WSGs-only and with-month sensitivities move no steep U weight by more than about 0.1.
8. **Segmentation barely matters.** In-sample pilots, fresh_default against score284: class agrees for 98.1 % of 1,698 visits.
9. **The access code is circular, so it is not evidence.** A fix after round 1 quoted the code-1 rate (0.034 on steep and non-steep) and the code-2 share (30 % → 9 %) as evidence that the decline sits in where BT live. Round 2 showed code 2 is built largely from these visits' own catches: on steep segments it holds 68.1 % of BT-caught visits and 2.6 % of the rest. Withdrawn wherever it was used; the log block stays, labelled circular.
   - Detection on `access_bt = 1` segments is 0.016–0.067 across classes; on code 2 (BT observed upstream) it is 0.30–0.85.
   - The code-2 share falls from 0.50 at core 0–2 to 0.05–0.10 in the steep classes.
   - Code 2 is defined from observations, so it is not a covariate, but it is the same mechanism as F: whether BT live up there at all.

### Code-check, Phases 2 and 4, round 1 (`review-p24-round1.md`)

The code was found correct: class_weight, the C subset, the bootstrap, held-out alignment, and PAVA against a brute force on 2,000 random cases. Ten write-up findings, all fixed:

| # | finding | fix |
|---|---|---|
| 1 | elevation "sampling density" claim contradicted by held-out per-visit rates | rewritten; per-role elevation table added to 0291's log |
| 2 | spawner evidence compared as raw counts | per-BT-visit rates; Q4 answer softened |
| 3 | "FDS shows no steep decline" unsupported | rewritten: FDS and FDIS agree at the first step |
| 4 | MAD lift stated as 0.3–0.4 | stated as 0.15–0.43 |
| 5 | "58 WSGs for any fish" | 57; 52 for C |
| 6 | C ≈ 1 read as equal quality; "usually above the fish limit" asserted; access-code mix unquantified | caveat added; inference marked; access block added to the log |
| 7 | coverage "58 WSGs" | 63 modelled by link, 53 in the U fit |
| 8 | link draft "stops jumping" true only under option B; "about half" | reworded |
| 9 | the weight CSV's `sources` named a private issue | public-safe text, regenerated |
| 10 | task_plan Phase 2 output wording | corrected |

### Code-check, Phases 2 and 4, round 2 (`review-p24-round2.md`), and the enumeration that ended it

Round 2 enumerated about 55 numbers across the research file, findings, the link draft and the #28 body against the curve CSV, the weight CSV, the 0291 log and the 0290 ledger: **all match**. It found five defects in round 1's fixes, so the inside-a-fix pattern recurred.

1. **Bug, circular evidence.** The access-code split was used as evidence that the decline is where BT live. Code 2 is built largely from these visits' own catches: on steep segments it holds 68.1 % of BT-caught visits and 2.6 % of the rest (my probe reproduced both). Withdrawn in all five places, and kept as a dead end. 0291's log blocks are labelled circular.
2. **Bug.** The link draft called an upper-fish-limit model "the real driver". Restated as "suggested by the any-fish decline; not located here".
3. **Fragile.** The link draft's cutoff sentence described option B only. Rewritten per option.
4. **Fragile.** The #28 body still said "quality-weighted" and "stops jumping". Fixed.
5. **Fragile.** The #28 Problem section still said "less sampled". Annotated with the per-visit result.

**Mechanism, the same one as rounds 1–2 of Phase 1: a quantity defined from the response was read as evidence about it.** Plan review G2 had named code 2 as circular, and a fix reached for it anyway because it was the variable at hand for "quantify the access mix".

**Enumeration.** Every place in the four documents where access, fish-limit, quality or sampling claims appear was listed with one grep: `known upstream|0.034|30 % → 9 %|real driver|quality-weighted|less sampled|fish limit|upper limit`.
- After the fixes, the only `known upstream` / `0.034` hit is the dead-end entry that records the withdrawal.
- Every fish-limit mention says the limit is not located here.
- `findings.md` lines quoting the original issue (the Issue context) are the issue as filed, left as written.

Round 2's number enumeration plus this claim enumeration ends the loop.
