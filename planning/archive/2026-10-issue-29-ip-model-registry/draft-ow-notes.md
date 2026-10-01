# Drafter notes: `ow` (Oregon/Washington) family, #29 Phase 3

Files: `draft-ow-evidence.csv` (78 rows), `draft-ow-registry.csv` (20 rows), `draft-ow-tags.csv` (6 tags).
Gate on the merged copy (`gate_frozen`, 2026-10-01): 268 evidence rows, all verified; 26 registry rows with
41 quotes, all verified; 0 unregistered and 0 unread links. I also checked by script that registry and evidence
match on model × species × stage × **form**. The frozen gate does not check form yet.

Page convention: Burnett pages are printed journal pages (PDF page + 65). Busch 2011 is an early-view PDF with no
printed numbers, so its pages are PDF pages. Sheer pages are printed pages (PDF page − 7). Sloat pages are printed
journal pages (PDF page + 603).

## Models: registered or skipped

| model_id | source | species × stage | evidence rows (new + tagged) |
|---|---|---|---|
| `burnett2007` | Burnett et al. 2007 (CLAMS), own PDF | CO, ST × rearing, access | 16 + 0 |
| `busch2011` | Busch et al. 2011, own PDF | CH ocean_type × spawning, access | 5 + 5 (rows 21, 22, 24, 26, 27) |
| `busch_nwfsc` | Sheer pp. 9, 12–14 (Busch et al., NOAA NWFSC, unpublished) | CO access; CH ocean_type × spawning, rearing, access | 15 + 1 (row 59) |
| `blm2008` | Sheer pp. 8, 12, 15, 18, 20 (BLM 2008 Western Oregon) | CO, CH, ST × rearing | 9 qual |
| `dent2005` | Sheer p. 9 (ODFW coastal coho) | CO access | 1 |
| `bartz2006` | Sheer p. 16, Table 5 (Bartz et al. 2006, Snohomish) | CH ocean_type × spawning | 4 (table) |
| `herger2003` | Sheer pp. 8, 12 (Herger et al. 2003, reported by Weiss) | CO, CH × rearing | 6 qual |
| `sloat2017` | Sloat et al. 2017, own PDF | CO, PK, CM × spawning | 22 (19 table + 3 qual) |

Tags: rows 21, 22, 24 and 26 are Busch's own hsi/param values; row 27 is the low-flow access width. Rows 23 (`max_obs`)
and 25 (`dist`) are data summaries and are not tagged. Row 59, Sheer's Busch barrier "bankfull width <2 m", is
**not** a Busch 2011 value: Busch 2011 uses < 4 m at low flow and ≤ 4 m bankfull. It is tagged `busch_nwfsc`, the
unpublished NWFSC model that Sheer's sentence actually describes. Row 59 is committed as `ocean_type`, so every
`busch_nwfsc` CH row and registry row is `ocean_type` too. Sheer's Table A1 (p. 33) shows that this model also covers
spring Chinook, and the notes say so.

Skipped:
- **Burnett et al. 2003**: no PDF in the library. Noted only.
- **Lawson et al. 2004**: Sheer lists only its variables and says it used the same data and model as Burnett (p. 8).
  No thresholds or curves are printed.
- **Lando & Keith (Ripple)**, **Paulsen & Fisher**, **Miewald**, **Gallagher**, **Anderson**, **Dunham**,
  **Steel/FishEye** (App. A p. 31), the **NOAA Puget Sound, Oregon Coast and Willamette IP** projects (Table A1) and
  **ODFW Lower Columbia Recovery Planning**: Sheer prints no threshold, breakpoint or curve figure for them, only
  variable lists or project rows.
- **Zimmerman & Reeves 2000** (Sheer Table 6): redd means ± SE, which is a data summary, not a model rule.
- **WDFW 2000 Table 9** (Sheer p. 26): the gradient strata carry their meaning in shading, so there are no readable
  values.
- Not mine: Spence/Agrawal (rows 57 and 120 stay untouched), Cooney & Holzer, Porter 2008 and Boughton & Goslin.
  Porter and Boughton & Goslin have their own PDFs and are printed in Sheer pp. 11, 16 and 21.
- **Sloat 2017** is registered. It does **not** reuse Burnett. Its criteria (Table 1) are Paustian (2010)'s
  Tongass spawning criteria.

## How each model sizes streams (the flow finding)

**burnett2007.** Thresholds are on **mean annual flow (m3/s)**, which is **modelled**. Sheer's Table 2 (p. 6), the
classic-model derivation table footnoted to Burnett 2003/2007 and Agrawal 2005, gives MAF as "Regression of gauge
data to drainage area (DEM) and mean annual precipitation" (Clarke et al. 2008), so the inputs are
`gauge;drainage_area;precipitation`. Burnett p. 68 sets the MAF index curves relative to modelled flows that
approximate Oregon Forest Practices Act "small" streams (< 0.06 m3/s), and relative to gauged-flow classes: medium
0.06–21.24, large 21.24–76.45 and very large > 76.45 m3/s. There is no surrogate and no width conversion. Valley
constraint is the DEM valley-width index; channel width in that index comes from a regional regression on mean
annual flow (Sheer p. 6). It was classed against 124 ODFW field reaches: constrained ≤ 5.06, unconstrained ≥ 8.87,
Kruskal-Wallis p < 0.0001 (p. 69). That is calibration of an input, not validation.
- The text layer garbles "≤ 5.06 / ≥ 8.87" as "55.06 / 18.87", so the evidence rows quote the class medians those
  thresholds equal.
- Index scores are figure-only (Fig. 2). The text-stated scores are coho 0.5 above 76.45 m3/s, the highest steelhead
  score at 2–3 %, and no use above 7 % (CO) or 10 % (ST).
- CLAMS ran IP on fish-bearing streams up to 20 % gradient and reported results up to 10 % (Sheer p. 43). Summer
  rearing stands in for overwintering (Sheer p. 45).

**busch2011.** Thresholds are on **bankfull channel width (m)**, which is **modelled**. Every reach's width comes from
the Steel & Sheer (2003) regression on drainage area (km2) and mean annual precipitation (mm), PDF p. 3.
- Large mainstems were sized by hand from the DEM and other hydrologic sources.
- The regression's training widths are not described, so `field_measurement` is not claimed.
- There is no discharge variable and no surrogate. The access width (< 4 m) is "during seasonal low flow", but how
  low-flow width was obtained is not said.
- Confinement is valley width / bankfull width from 10-m DEMs, with the score 0.25 at a ratio of 1 and 1 at ≥ 8.87.
- Other exclusions with no vocabulary variable: tidal influence (≤ 3.5 m above mean sea level, lower 95 km), the
  350 m elevation contour, and waterfalls (≥ 3–4.6 m).
- The 15–20 m width inflection and 5.06 confinement are sensitivity-analysis only, so they were not written.

**busch_nwfsc.** Sheer names **bankfull width** as the Busch Chinook stream-size variable (p. 12, curve d p. 14,
whose axis is labelled "Wetted width (m)"). Sheer does **not** say how the width was obtained. `modelled` from
`drainage_area;precipitation` is **inferred** from the group's published fall-Chinook model (Busch 2011), and the
registry note says it is not stated in Sheer.
- Gradient curves are split at a reach width of 25 m, and widths of 2–25 m are modelled.
- Coho: Sheer gives only the barriers (≥ 16 %, waterfalls > 3.7 m, bankfull width < 1.2 m).
- No discharge variable.

**blm2008.** Thresholds are on **mean annual flow**, **modelled** (`gauge;drainage_area;precipitation`), via Sheer
Table 2. This is by inheritance: BLM "used same data and model as Burnett et al. (2007)" for coho (p. 8). Its Chinook
and steelhead curves are on mean annual discharge, as figures only (pp. 15, 20). The BLM document is not in the
library.

**dent2005.** Same data and model as Burnett (p. 8), so **mean annual flow**, modelled as above. Sheer prints only
the 7 % maximum gradient.

**bartz2006.** Thresholds are on **bankfull width** (Table 5: > 25 m, 5–25 m; gradient ≤ 4 %, < 1 %, 1–4 %).
**UNVERIFIED source.** Sheer does not say how widths were obtained, and Bartz et al. 2006 is not in the library. The
registry's `modelled` / `drainage_area` is a placeholder to check against the paper, and the registry note says so.
Drop the model if that is not acceptable.

**herger2003 (Weiss).** `flow_metric = none`. Sheer lists gradient, temperature, elevation, mean annual
precipitation and grain size (pp. 8, 12), but no flow or width variable, and nothing says precipitation stands for
stream size.

**sloat2017.** Thresholds are on **bankfull width and depth (m)**, which are **modelled**. Hydraulic-geometry
regressions on drainage area were fitted to field data: Wood-Smith & Buffington 1996 (n = 23) and Zynda 2005
(n = 83), w = 0.0027 A^0.5129 with R² = 0.92 (Fig. 3, p. 607). They run on a 20-m DEM NetMap network, so the inputs
are `field_measurement;drainage_area`.
- The mean annual flood (Q2, from a USGS regression on drainage area, lake storage, precipitation and January
  temperature) drives the scour and D50 predictions, not the habitat thresholds.
- No surrogate and no discharge-to-width conversion.
- Unconfined means a floodplain wider than twice the bankfull width, mapped from air photos and ground-truthed at
  372 reaches (p. 608). The word "twice" cannot carry a value through the gate, so it is a `qual` row.
- The egg-scour criterion (> 50 % probability of scour to 30 cm) is incubation and has no matching variable, so it
  is noted only.

## Validation

| model | validation | result |
|---|---|---|
| burnett2007 | density | Sheer pp. 9, 19: reach IP classes compared with fish-density classes for select populations. No statistic. Sheer App. C p. 45 says the model's validation was "not published yet". Burnett 2007 itself has no fish validation. |
| busch2011 | fish_observations | 89 % of ODFW/WDFW-mapped spawning reaches scored high or very high, against 43 % network-wide (χ² 394.84, df 4, p < 0.001). Population IP did not predict current abundance (p = 0.47). Reach IP vs EDT gave adjusted R² 0.46. |
| busch_nwfsc | CH: fish_observations; CO: none | CH was assessed against Willamette/Lower Columbia TRT population-size data, with no result reported (p. 13). No coho validation is listed. |
| blm2008 | fish_observations | Current fish distribution was compared with IP > 0.75 (pp. 9, 13, 19). No result reported. |
| dent2005 | none | Dent's work was a sensitivity analysis of the gradient threshold (p. 9), not a comparison with fish. |
| bartz2006 | none | None listed in Sheer. |
| herger2003 | none | Its ordination of fish assemblages built the model; it did not test it. |
| sloat2017 | none | The criteria came from field measurement, fish sampling and expert judgment (calibration). p. 618 calls the predictions "first-order approximations that require field validation". |

## Judgement calls for review

- `busch_nwfsc` is a model_id I created for Sheer's unpublished NWFSC Busch models, which differ from Busch 2011:
  the coho barrier is 1.2 m, the Chinook barrier 2 m, and there are two width-class gradient curves. If the
  coordinator prefers, its 15 rows and the row 59 tag can be dropped as a unit.
- Burnett's access rows rest on "assumes no use upstream of reaches with gradients exceeding 7 % / 10 %", which
  works as a barrier. They duplicate the rearing curve endpoints under `access_gradient_max`.
- The Burnett MAF class boundaries are recorded as `hsi` rows with blank `parameter`. Whether the curves reach 0
  below 0.06 m3/s is figure-only, so `rear_mad_min` is not claimed.
