# Stream temperature: what the network models do, and what NGE holds

**Verified:** 2026-10-06 (model repos read 2026-10-03; evidence and Zotero bullets revised for #38) · **Issues:** NewGraphEnvironment/logic#4 (roadmap);
NewGraphEnvironment/wet#36, NewGraphEnvironment/link#21, NewGraphEnvironment/fish_passage_template_reporting#214,
#20 · **Produced by:** reading `fish-passage-22` `526d02c`, `fish-passage-22b` `1464c9d` and
`skeena-stream-temp-25` `c128f14` (the NGE fork), the rendered memos
([hill_etal2024Spatialstream](https://www.poissonconsulting.ca/analyses/fish-passage-22b/),
[hill_etal2025Spatialstream](https://www.poissonconsulting.ca/analyses/skeena-stream-temp-25/)), and a read-only copy of the
group library.

Where the work is going is logic#4. This file is the technical state that roadmap rests on.

## The three model repos

| repo | area, years | water temperature | model | memo |
|---|---|---|---|---|
| `fish-passage-22` | Nechako, 2019–21 | UNBC loggers (Zenodo 10.5281/zenodo.6426023), 24 sites | logistic air–water curve (Mohseni 1998), correlated site effects | not published |
| `fish-passage-22b` | Nechako, 2019–21 | same, 21 sites × 157 weeks | 4-parameter air2stream with discharge | `hill_etal2024Spatialstream` |
| `skeena-stream-temp-25` | Skeena, 2015–2025.07 | ECCC hydrometric (water-temp-bc), 17 stations × 553 weeks, 60 % observed | 3-parameter air2stream, no discharge | `hill_etal2025Spatialstream` |

The three share one structure, fitted in Stan:

- **Weekly recursion per site.** The weekly change in water temperature is
  `ΔW = a1_s + a2_s·A − a3_s·W_prev` (Skeena). 22b divides it by `(Q/Q̄)^a4_s`. It starts from one shared
  initial temperature and is floored at 0. `a1`–`a3` (`a4`) are site random effects around population
  means, with no covariates.
- **Air temperature** is ERA5-Land 2 m hourly, from the cell nearest each site, averaged to the week.
- **Discharge (22b only)** is PCIC VIC-GL `ACCESS1-0_rcp85`, the area-weighted mean upstream of each site. It
  is a GCM-driven scenario run, so its 2019–21 days do not follow that period's real weather. It enters only
  normalised (`Q/Q̄`). PCIC has no Skeena output, which is why Skeena dropped the term.
- **Residual.** Each week the residual is multivariate normal across sites, with a nugget plus an exponential
  tail-down covariance on hydrologic distance (km). Missing site-weeks are parameters (`y_mis`).
- **Abandoned before 22b:** a mechanistic heat budget and the 8-parameter air2stream, neither of which
  converged.
- **GSDD** is computed from the weekly predictions with `gsdd`, using Coleman & Fausch (2007) growing-season
  rules (starts when the weekly mean stays above 5 °C, ends below 4 °C).

**Fitted values (rendered memos)**

| | Nechako 22b | Skeena |
|---|---|---|
| tail-down range | 9,770 km | 19,300 km |
| tail-down SD | 1.37 °C | 0.835 °C |
| nugget SD | 0.420 °C | 0.806 °C |
| implied in-sample weekly SD | ≈1.43 °C | ≈1.16 °C |

The implied SDs are `sqrt(nugget² + tail-down²)`, computed here; neither memo reports them. Skeena
mean GSDD by year runs 1,815–2,233. By site it runs from 1,029 (08EE020) to 2,639 (08EC004).

## What the models can and cannot do

**Gap-filling at a monitored station: yes.**
- The grid takes in every site-week inside the date window. A station observed 2010–12 and 2014–20 gets
  predictions for 2012–14 from its fitted parameters and ERA5-Land. Skeena already fills 40 % of its grid
  this way.
- **The fill is open-loop.** `eTemp` runs forward from week 1 on air temperature alone. An observation
  never updates it, so readings either side of a gap, and other stations that week, do not inform it.
- **The model's conditional estimates are thrown away.** It does estimate missing weeks from the stations
  observed that week (`y_mis`). `predict-air2stream.R` filters those out
  (`filter(!(str_detect(term, "y_mis")))`).
- **`ePrediction` widens the interval only.** It is an unconditional draw around `eTemp`.
- **The "spatial" term acts as a shared weekly anomaly.** The fitted ranges are 30–60× the network size,
  so correlation at 300 km is still about 0.9–0.95. In Skeena it carries about half the residual variance.
  Conditioning on it is the cheapest improvement available.

**Prediction at unmonitored segments: no.**
- The networks hold observation sites only.
- Site parameters have no covariates (elevation, upstream area, lakes, glacier). A new site could only take
  the population means.
- Kriging was planned (`fish-passage-22` issue #5, step 3) and never coded.
- **The Skeena 2025 report overstates this.** `fish_passage_skeena_2025_reporting/0300-methods.Rmd` l.193
  says the models "predict stream temperature at fine spatial resolution across the FWA network".

**Validation: none out of sample.**
- There is no holdout, cross-validation, RMSE or NSE.
- What exists is convergence (R̂ ≈ 1.01, ESS ≈ 500) and prior sensitivity.
- `fish-passage-22` issue #18 (open) reports that the logistic model runs warm in the warming phase, which
  inflates GSDD.

**Time step: weekly.** `week = day %/% 7 + 1`, continuous across years, so week 1 is six days long.
Anything daily, wet#36 included, needs either a daily step or an explicit weekly product.

## Re-running them today

- **Licence.** None of the three repos has a licence. `skeena-stream-temp-25` is a private fork of a
  private upstream, which is 3 small commits ahead: CODEOWNERS, a comment, and a non-SSN `air2stream.stan`
  kept for comparison.
- **Stan versions.** The 22/22b Stan files use pre-2.33 array syntax, so they need rstan 2.32 or a port.
  Skeena runs on current cmdstan.
- **Packages.** The stack is the public Poisson packages (`embr`, `smbr2`, `mcmcderive`, `subfoldr2`,
  `gsdd`, `fwapgr`, `fwatlasbc`, `evrfish`) plus `SSNbler`, `SSN2` and `SSNbayes`. `poisreport`, needed
  only to knit, is private.
- **Skeena data URL.** `.../data/realtime_raw_20250521.parquet` now returns 404 (checked 2026-10-06).
  water-temp-bc's read path is `data/canonical/Parameter=5/`.
- **Data paths.** They are hard-coded to Dropbox (22/22b) and OneDrive (Skeena). `output/` is gitignored,
  so no fitted objects are kept.
- **Manual steps.** The Skeena network build has hand-listed connecting segments and reversals in
  `ssnbler.R`, and the ERA5 pull is noted at about 8 h.
- **Cost.** The covariance Cholesky is recomputed every week inside every gradient evaluation, although
  the covariance is constant. Factoring it once is a large speed-up.

**Reusable as code:**
- the Stan model;
- the site × week grid builder (`prepare-data.R`);
- the ERA5-Land and water-temp-bc readers with QA;
- the PCIC upstream-discharge step;
- the FWA → SSNbler → SSN2 distance wrapper;
- GSDD from draws.

**Study-specific:** dates, bboxes, paths, dropped-site lists, hand network edits, the Nechako-only
distance script, and logger-cleaning literals.

## What NGE holds besides the models

- **Observed data.**
  - water-temp-bc has 306 ECCC stations, hourly, from 2002 (`canonical/Parameter=5/`); wet#36 reads it.
  - FDIS and FISS spot temperatures are parsed in this repo (`water_temp_c`, `temperature_c`) and not used.
  - There are logger series from the Upper Bulkley, the Nechako (Gilbert et al. 2022) and Weigert Creek.
    Weigert Creek recorded 693.5 °C-days, against a WCT requirement of 570–600 thermal units (template#214).
- **Evidence.** `data/literature_evidence.csv` holds the cited thermal requirements for BT, WCT, CH, CO and
  ST by life stage, each value with its `metric`, plus degree-day rows (#38). What they say, and what has no
  source, is `thermal_requirements.md`. The template#214 and `fish_passage_elk_2022_reporting#55` thresholds
  are rows now: WCT emergence at 575–600 thermal units (Thorley et al. 2022), and the 800–900 degree-day
  recruitment threshold, which is Colorado River cutthroat (Coleman & Fausch 2007a).
- **Zotero.** Both memos (`QYU2YFFZ`, `F4Y3AQZH`) have PDFs since #38. They were printed from the rendered
  analytic appendices (`/analyses/fish-passage-22b/`, `/analyses/skeena-stream-temp-25/`), because the
  `/f/` links the items carried now serve an empty page; the items' URLs point at the appendices since #38. `Fisheries/temperature` holds 47 items and feeds the
  `temperature` store.
- **External layers named but not obtained:** the Weller et al. thermalscape (August mean), PCIC Raven
  channel-scale temperature (wet#9), and the DFO CSAS 2025/013 layers (#20).
- **link.** No code uses temperature. link#21 (GSDD and upper limits as IP variables) waits on a
  per-segment product.
