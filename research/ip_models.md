# Intrinsic-potential models: what they threshold on, and how they sized streams

**Verified:** 2026-10-01 · **Issues:** #29 (this); input to NewGraphEnvironment/link#286; follows #19 ·
**Produced by:** `data/ip_model_registry.csv` and the `model_id`-tagged rows of `data/literature_evidence.csv`,
gated by `scripts/0280-literature-verify.R` (logs `scripts/logs/habitat/*_literature_verify*.csv`). Sources are
in the group library's `Fisheries/habitat_modelling` collection (`scripts/0270`) and the `habitat_modelling`
store. The drafting notes, with page references per model, are in the #29 archive (`draft-{ow,ca,nb}-notes.md`).

The registry is the record. This file keeps the conclusions someone would otherwise re-derive from it. Every
value and model attribution below is a registry or evidence row. Quoted claims were found in their PDFs; the
remaining statements come from the rows' notes and validation results, or from the #29 findings.

## What is registered

There are 17 models from Sheer et al. 2009 Table A1 (pp. 33-34) and later work, across species × stage.
Each model's thresholds are evidence rows carrying its `model_id`, written for every species and stage the
source gives a value or variable for (CO, ST, CH, SK, CM, PK, plus BT and RB in Porter 2008).

| Region | Models |
|---|---|
| Oregon and Washington (coast, Puget Sound, Columbia) | `burnett2007` (CLAMS), `blm2008`, `dent2005` (ODFW coastal coho), `busch2011`, `busch_nwfsc`, `bartz2006`, `herger2003`, `cooney_holzer2006` (ICTRT) |
| California | `agrawal2005` (with Bjorkstedt 2005 applying it to coho and steelhead), `bjorkstedt2005` (fall Chinook spawning), `lindley2006`, `boughton_goslin2006` |
| Alaska | `woll2015` (Mat-Su), `woll2017` (Nushagak-Kvichak), `sloat2017` (Tongass) |
| BC | `rebellato2024` (CWF), `porter2008` (Thompson) |

Not registered, and why (details in the #29 archive `findings.md`):
- Burnett 2003: no PDF obtainable; Burnett 2007 is the same model.
- Bidlack 2014: no PDF in any library.
- NOAA NWFSC-128: basin-scale population delineation, not reach thresholds.
- NetMap, Zimmerman & Reeves 2000, Mills 2008: a tool, a life-history paper, a thesis-level model.
- Sheer's other workshop models (Lando & Keith, Paulsen & Fisher, FishEye, the NOAA Puget Sound and Oregon
  Coast IP): no printed numbers or curves.
- The agency IP *layers* (ODFW, NOAA SWFSC, CDFW, PSMFC/StreamNet ICTRT) are implementations of Burnett's,
  Agrawal's and Cooney & Holzer's models, which are registered.

## How the field sized streams

**No model thresholds on gauged flow.** Every flow value in the PNW IP line is modelled, and almost always
from drainage area and precipitation:

| Stream-size variable | How it was obtained | Models |
|---|---|---|
| Mean annual flow | Regression of gauge flows on drainage area and mean annual precipitation | `burnett2007`, `blm2008`, `dent2005`, `agrawal2005`, `bjorkstedt2005`, `lindley2006`, `woll2015` (gauge basis inferred) |
| Mean annual flow | Hydrologic model (PCIC, Foundry Spatial); **modelled width as the surrogate** where it is missing | `rebellato2024` |
| Summer low flow (Aug-Sep mean) | Regression on 29 USGS gauges (R² = 0.38) | `boughton_goslin2006` |
| Channel width | Widths regressed on drainage area and precipitation (or drainage area alone, or orthophoto widths) | `cooney_holzer2006`, `busch2011` (training widths not described), `sloat2017`, `porter2008`, `woll2017` (width from modelled MAF) |
| Channel width, source not stated | Known only through Sheer's secondary account (`flow_source = unstated`) | `busch_nwfsc`, `bartz2006` |
| None | Gradient and other variables only | `herger2003` |

Sheer's own summary table says it of the classic models: mean annual flow is "Regression of gauge data to
drainage area (DEM) and mean annual precipitation" (p. 6). Cooney & Holzer state the logic for width: "Stream
width is predominantly a function of stream discharge, which can be estimated from a combination of drainage
area and precipitation" (C-7). The 2008 workshop went further, recording that drainage area may be the better
intrinsic variable because mean annual flow shifts with climate (p. 36).

**Thresholds exist in both currencies,** at similar levels across models (minima, m³/s or m):

| Species, stage | Mean annual flow minimum | Channel-width minimum |
|---|---|---|
| CO rearing | 0.01 (`agrawal2005`), 0.03 (`rebellato2024`), 0.06 class boundary (`burnett2007`) | 1.5 (`rebellato2024`) |
| CO access | | 1.2 bankfull barrier (`busch_nwfsc`) |
| CO spawning | 0.164 (`rebellato2024`) | 2 (`rebellato2024`, `sloat2017` bankfull, `woll2017`) |
| ST rearing | 0.02 (`rebellato2024`), 0.028 (`lindley2006`), 0.06 class boundary (`burnett2007`) | 1.5 (`rebellato2024`), 3.8 bankfull (`cooney_holzer2006`) |
| ST spawning | 0.447 (`rebellato2024`), 0.028 (`lindley2006`) | 3.8 bankfull (`cooney_holzer2006`), 4 (`rebellato2024`) |
| CH rearing | 0.28 (`agrawal2005`, `rebellato2024`), 0.5 (`woll2015`) | 1.5 (`rebellato2024`), 2 (`busch_nwfsc`), 3.6 wetted (`cooney_holzer2006`) |
| CH spawning | 0.46 (`rebellato2024`) | 2 (`busch_nwfsc`), 3.7 bankfull (`cooney_holzer2006`), 4 (`busch2011`, `woll2017`, `rebellato2024`), 5 bankfull (`bartz2006`) |

## What this means for width vs MAD in BC (link#286)

Modelled MAD covers the Fraser, Columbia and Peace (104 of 246 watershed groups), and none of the Skeena,
Nass, Stikine or coast. The literature says three things about that gap:
- **The field did not need gauged discharge.** Its MAD was a regression on drainage area and precipitation.
  Building one for the Skeena and coast would repeat the inputs our width model already uses, and add no new
  information.
- **Width thresholds are an established currency, not a stopgap.** Five models threshold directly on modelled
  width. Rebellato's BC model already uses width as the discharge surrogate outside the Fraser and the Bulkley.
- **BC's MAD is different in kind.** It comes from a process-based hydrologic model, not a regression, so in
  snowmelt- and glacier-fed basins it may carry information that width does not. Whether it does is a
  measurement, not a literature question. Compare `cw` and `mad` classification where both exist (the
  Fraser, Columbia and Peace groups) before building MAD elsewhere.

How fwapg builds that MAD from PCIC's gridded runoff, and PCIC's routed channel-scale alternative, is
`modelled_discharge.md`.

## Validation

The registry codes a model as validated only when its output was compared with fish records that did not set
its thresholds or classes. A comparison with the data that set them is calibration, and is coded `none`. On that rule,
few models were tested, and one with a statistic:
- **`busch2011`:** 89 % of mapped spawning reaches scored high or very high, against 43 % of the network
  (χ² = 394.84, p < 0.001). Population-level IP did not predict abundance. The network's lower limit was set
  from the same spawning maps, so the comparison is not wholly independent.
- **Compared with fish records, no statistic:**
  - `rebellato2024` (CH, CO, SK, ST): compared with the Pacific Salmon Explorer;
  - `woll2017` (all but pink): maps compared by eye with the Anadromous Waters Catalog (plus telemetry and
    aerial counts for spawning), with named false positives. Not fully independent: the same records were
    among the "known patterns" the models were developed from (p. 80);
  - `boughton_goslin2006`: historical records;
  - `burnett2007`: fish-density bins;
  - `busch_nwfsc` Chinook and `blm2008`: compared, result not reported. BLM reuses Burnett's barriers,
    placed partly from fish distribution maps, so its comparison would not be wholly independent.
- **Calibration, not validation:**
  - `cooney_holzer2006`'s redd-count ANOVA set its final rating classes;
  - Rebellato's chum and pink thresholds were set from the same PSE sites they were compared with;
  - `porter2008`'s cross-validation was tree pruning during fitting, and it rejected every split.
- **Every other model:** none.

IP models are hypotheses about where habitat can be. Their thresholds are screening values, the same status
`habitat_literature.md` gives the bcfishpass ones.

## Species with no IP model

**WCT and GR have no IP model.** RB appears only in Porter 2008, as juvenile O. mykiss in the Thompson
(steelhead not separated). Searched the text of all 13 model documents and Sheer's Table A1:
- cutthroat has no thresholds in any model document. It appears in reference lists, species lists and
  passing mentions: Porter citing Rosenfeld 2000, Boughton & Goslin's barrier parameter, and Sheer's WDFW
  2000 Table 9 (shading only);
- grayling appears once, in Rebellato's species list.

Thresholds for these species have to come from elsewhere (FDIS and FISS evidence, #18 and #21; the species
literature).

## Vocabulary gaps met while drafting

- `lake_area` takes hectares only, so Woll's km² lake rules are `qual` rows.
- There is no stream-order flow metric, so Woll 2017 rearing is `flow_metric = none`.
- Turbidity, glacial influence, floodplain width and obstacle height have no variable; they are only in
  notes.

None of these has blocked a threshold yet.
