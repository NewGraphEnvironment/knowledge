# Thermal requirements by species and life stage

**Verified:** 2026-10-14 · **Issues:** #38 (this), #40 (Bear et al. 2005 and 2007), #47 (growing-season and first-winter size thresholds, searched beyond the collection); background in `stream_temperature.md`; for
NewGraphEnvironment/link#21, NewGraphEnvironment/wet#40 and NewGraphEnvironment/fish_passage_template_reporting#214 ·
**Produced by:** rows of `data/literature_evidence.csv` with `variable` `temperature`, `air_temperature` or
`degree_days` (rows 511 onward are #38's, rows 1071 onward #40's), and `fish_length` (rows 1103 onward are #47's), gated by
`scripts/0280-literature-verify.R` (log `scripts/logs/habitat/20261013_literature_verify.csv`); sources in the group's
`Fisheries/temperature` collection (`data/temperature_members.csv`, 46 members, and `data/temperature_additions.csv`, 8
works #47 added) and the `temperature` store. #47's search log and the sources it dropped are in
`planning/archive/2026-10-issue-47-growing-season-thresholds/findings.md`.

**Status:** every species × cell of the gate's thermal grid has a value or a `none` row. The degree-day
cells are mostly `none`. No source found gives a growing-season degree-day requirement for a BC species: #38
read the collection's members with a PDF (McMahon et al. 2007 has none), #40 read Bear et al. 2005 and 2007, and
#47 searched beyond the collection (web search, forward citations of Coleman & Fausch 2007a/b, Quinn & Peterson
1996 and Holtby 1988, and the reference lists of the BC reports). The only growing-season threshold anywhere is
Colorado River cutthroat's (Coleman & Fausch). What #47 found instead is first-winter **size**: the cutthroat
30–35 mm TL threshold that the BC reports apply to westslope cutthroat, coho size–survival relations, and
counter-evidence that size does not set first-winter survival everywhere (below).

## How to read the rows

```r
pkgload::load_all("pkg")
x <- knw_literature_read("data/literature_evidence.csv",
                         species_code = c("BT", "WCT", "CH", "CO", "ST", "CRCT"),
                         variable = c("temperature", "degree_days"))
```

A temperature value is only comparable with a prediction of the same statistic, so read `metric` before
`value_*`:
- a daily maximum or mean, MWMT, 7DADM, MWAT, 7DEC or weekly, August or summer mean is a statistic of a stream
  record;
- `constant` is a laboratory exposure at a held temperature (a UILT, a growth optimum);
- `unstated` means the source gives a number without the statistic.

A degree-day row's `metric` names the window: `growing_season` (Coleman & Fausch 2007a, the window
`gsdd::gsdd()` computes), `to_hatch` or `to_emergence` (from fertilization), or `unstated` when a source's
window is none of these (its note gives the window). Its note gives the base temperature. A `fish_length` row
is a body length tied to first-winter survival, in mm; its `metric` is the length the source measured
(`total_length`, `fork_length`, `unstated`). Total and fork length differ by about 2 mm at fry size (30–35 mm TL
is 28–33 mm FL in Thorley & Branton 2022 p. 3), so compare like with like.

`kind` separates what a number is: `param` (a value a model or standard sets, such as the Iacarella and
Isaak thresholds), `expert` (a criterion or recommendation), `lab` (a laboratory or hatchery measurement:
a lethal limit, CTmax, survival or growth at a held temperature, including a growth optimum the source itself
measured, a development time in degree-days), `dist` and `max_obs` (where fish were found), `pref` (a preference,
or an optimum a source states or reviews). Air-temperature rows (the IP models'
proxies: Agrawal, Lindley, Boughton & Goslin, Weiss) are a separate variable and never stand in for a water
limit.

## Degree-days

| species | window | value | source | note |
|---|---|---|---|---|
| WCT | to_emergence | 575–600 | Thorley et al. 2022 p. 30 (Kootenay Trout Hatchery, pers. comm.) | hatchery-reared; base and start not stated |
| BT | to_hatch | 350 CTU | McPhail & Baxter 1996 p. 9 (Gould 1987) | base not stated |
| CH | to_hatch | 900–1,000 TU | Raleigh et al. 1986 p. 4 (Seymour 1956) | base 0 °C |
| CRCT | to_emergence | 570–600 | Coleman & Fausch 2007a p. 1234, citing the 2007 laboratory study | Colorado River cutthroat |
| CRCT | growing_season | < 800 unsuitable; 800–900 recruitment "in some years"; 900–1,200 best | Coleman & Fausch 2007a p. 1231 | field, greenback and Colorado River cutthroat |
| CRCT | growing_season | > 900 for consistent recruitment | Coleman & Fausch 2007 p. 652 | laboratory regimes of 666, 763, 974 |
| BT | unstated (egg deposition to onset of winter) | ≥ 1,600 | Mochnacz 2021 p. 98 | the author's inference; the post-emergence 800 is from Arctic char, not bull trout |
| ST | unstated (base 7 °C) | 450 to smolt | Riley et al. 1998 p. 5 | Mid-Fraser model parameter; a smolting rule, not a first-winter one |

**No source read** gives degree-days to emergence for BT, CH, CO or ST, to hatch for WCT, CO or ST, or a
growing-season degree-day requirement for any BC species (#38 read the members with a PDF; #47 searched beyond
them). Several give days to hatch or emerge at a stated temperature (Bjornn & Reiser 1991 p. 106–107, Roberge et al. 2002
p. 64, McPhail & Baxter 1996 p. 9). Their products were not computed: the table holds what a source prints.
The `none` rows say what was searched.

Bear et al. 2005 and 2007, the likeliest unread source of WCT degree-days after #38, measured 60-day growth
and survival of juveniles held at constant temperatures. Neither gives degree-days, so the WCT to-hatch and
growing-season cells stay `none`.

Mochnacz (2021 p. 115) adds counter-evidence for transferring a cutthroat floor to bull trout: every stream in
his Northwest Territories watershed holds self-sustaining juvenile bull trout, and several accumulate 800 or
fewer thermal units from hatch to the onset of winter (data row 1118).

The WCT documents borrow the cutthroat growing-season values. Thorley et al. 2022 reads age-0 fish under
30 mm as poor overwinter survival, citing Coleman & Fausch. The Hill et al. 2024 and 2025 memos compute GSDD
with Coleman & Fausch's start and end rules and call it "a useful predictor of age-0 rainbow and westslope
cutthroat trout size at the beginning of winter". Neither states a WCT threshold. The two Teck Harmer Creek reports
(2022) fit Elk Valley WCT data: Thorley & Branton relate fork length at the onset of winter to GSDD and energetic
status at the onset of winter to egg-to-age-1 survival, and say GSDD explains 34 % of Harmer Creek's reduced
recruitment (data rows 1111–1113); Hocking et al. find Elk Valley fry slightly larger than the Colorado relation
predicts (data row 1116). Those are relations, not thresholds. So any WCT GSDD threshold is
a transfer from Colorado's native cutthroat (greenback and Colorado River cutthroat, filed as `CRCT` because
greenback has no code), and should be labelled one.

## First-winter size

The fish-size form of the growing-season question: how big an age-0 fish must be at the onset of winter.

| species | length | value | source | note |
|---|---|---|---|---|
| CRCT | total_length | ≥ 30–35 mm at onset of winter | Coleman & Fausch 2007a p. 1241 | proposed, "if ... validated and generalized"; field and laboratory (data row 1103) |
| CRCT | unstated | ≥ 30–35 mm | Coleman & Fausch 2007 p. 651 | laboratory paper (data row 1104) |
| CRCT | fork_length | ≥ 28–33 mm | Thorley & Branton 2022 p. 3 | the report's FL conversion of the above (data row 1109) |
| CRCT | unstated | 30 mm, applied to WCT fry | Thorley et al. 2022 p. 30 | "less than 30 mm, suggesting poor overwintering survival" (data row 1110) |
| CRCT | fork_length | > ~30 mm for > 90 % survival | Hocking et al. 2022 p. 51 | the report's logistic fit to three laboratory means (data row 1114) |
| CO | fork_length | survival highest > 90 mm | Ebersole et al. 2006 p. 1690 | top length class, Oregon; the model explains 8.7 % of deviance (data row 1131) |
| CO | fork_length | 80 mm | Ebersole et al. 2009 p. 569 | a threshold the model assumed, which then explained little (data row 1132) |

Relations with no threshold: Carnation Creek coho winter survival rises with fall fork length (Holtby &
Scrivener 1989 eq. 18, p. 70; Hartman & Scrivener 1990 Fig. 72, p. 88; data rows 1123, 1126), and is "an
asymptotic function of size" (data row 1124). Counter-evidence: Ebersole et al. 2009 found fall length
"relatively uninformative" (data row 1133); Quinn & Peterson 1996 found the size effect in one winter of two
(data rows 1135–1136); Coleman & Fausch's own laboratory size dependence held only in the colder regimes (data
row 1105). No source found gives a size threshold for BT, CH or ST. Seven paywalled candidates, among them the rainbow trout 90 and 100 mm cutoffs and the Chinook work, are #48.

## Temperature limits

The thermal grid asks, per species, for an upper and a lower water-temperature limit for spawning,
incubation and rearing. A `range` fills both. Every cell has at least one value, except CO rearing lower.
That cell's one value, Bjornn & Reiser's 1.7 °C lower lethal, OCRs as "17" on the scan and cannot be quoted.

Values a BC model would most likely use:

| species | stage | value | metric | source |
|---|---|---|---|---|
| CH, CO | rearing | 24 °C | `7dec` | Iacarella et al. 2024 (BC anadromous streams; lab IT-Dmax) |
| CH, CO, ST | spawning, incubation | 13 °C / 10 °C | `7dadm` / `weekly_mean` | Richter & Kolmes 2005 Table 1 (upper optimal criteria) |
| CH, CO, ST | rearing | 16 °C / 15 °C | `7dadm` / `weekly_mean` | Richter & Kolmes 2005 Table 1 |
| BT | rearing | 11 °C | `mwat` | Hagen & Weber 2019 p. 25 (BC threshold, Parkinson et al. 2012) |
| BT | rearing | 11 °C | `august_mean` | Isaak et al. 2015 (cold-water habitat) |
| BT | rearing | 20.9 °C | `constant` | Selong et al. 2001 (UILT, age-0) |
| BT | spawning | 9–10 °C at onset as temperatures fall | `unstated` | rows 149, 492, 508 (row 546 gives 9 °C onset without saying falling) |
| WCT | rearing | 19.6 °C | `constant` | Bear et al. 2007 p. 1115 (60-d UUILT, juveniles; the 2005 report's survival curve gives the same, its LD50 regression 19.7 °C) |
| WCT | rearing | 13.6 °C optimum | `constant` | Bear et al. 2007 p. 1117, 2005 p. 11 (peak growth, satiation ration) |
| WCT | rearing | 13–15 °C | `daily_max` | Bear et al. 2007 p. 1113 (suitable habitat; the lower end is stored) |
| WCT | rearing | 16 °C / 20 °C | `daily_mean` / `daily_max` | Bear et al. 2005 p. 17 (maximum growth / survival) |
| WCT | spawning, incubation | 6–10 °C | `unstated` | DFO 2019 Table 2 (critical habitat) |
| WCT | rearing | 4–15 °C | `unstated` | DFO 2019 Table 2 |

Conventions a reader needs:
- **A stage-less BT limit is under `rearing`.** Rieman & McIntyre's 15 °C, Hagen & Weber's 15–16 °C and
  11 °C MWAT, O'Connor's 11 and 13 °C, and the USFWS 2010 2–15 °C critical-habitat range name no stage. They
  are filed as summer stream limits, and each note says no stage is named.
- **A span stored as a single limit holds its lower end**, for recommendations (Hicks's 14–17 °C 7-DAM for
  juvenile coho rearing; a 13.5–14.5 °C single daily maximum) and measured onsets (Burck's 23.8–25.5 °C; Hagen
  & Weber's 15–16 °C distribution limit) alike. The note gives the span.
- **Richter & Kolmes Table 1 holds for CH, CO and ST.** It has no species column. pp. 38–39 discuss each
  criterion for each species.

## Left out, and why

- **From Bear et al. 2005 and 2007** (#40): rainbow trout values Bear cites from other studies only for comparison
  (Hokanson et al. 1977's 17.2 °C optimum and 25.6 °C 7-d UUILT, Kaya 1978's 26.2 °C); cutthroat scope-for-activity
  values (Dwyer & Kramer 1975, 15 °C; Hickman & Raleigh 1982, 12–15 °C), which are species-level like Hasnain's
  (and Hickman & Raleigh is in the library to read directly); the 12–16 °C over which the report expects the two
  species to compete equally, and the paper's "exceeded 22°C for even short periods" (competition, not a limit);
  survival percentages at single test temperatures; and the hybrid hatching failure. The report and the paper
  publish the same fitted growth and survival curves (identical coefficients), so the survival-curve UUILTs
  (19.6, 24.3 °C) and the optima are one estimate twice; the report's LD50-regression UUILTs (19.7, 24.2 °C) pool
  all its experiments and are its own, and the two 7-d UUILTs differ in method. Rainbow trout values from both are coded `RB`, never `ST`.
- **Hasnain et al.** (key thermal metrics for Canadian fishes) says every estimate comes from adults, so its
  lethal and growth values are not rearing values. Its cutthroat values are species-level, not westslope.
- **OCR-garbled Bjornn & Reiser 1991 cells:** coho spawning 4.4–9.4 and incubation 4.4–13.3 °C, steelhead
  spawning 3.9–9.4 °C, coho lower lethal 1.7 °C, and Chinook upper lethal 26.2 °C. The coho spawning span is
  in the table through Richter & Kolmes p. 33.
- **Values with no stage:** McCullough's distribution limits, and Chinook, coho and steelhead lethal limits in
  Richter & Kolmes pp. 28–36 and Roberge et al. 2002 p. 65. **Resident rainbow trout** values are not steelhead (Bear et al.'s are filed as `RB`).
- Draft notes with every source read: `planning/archive/2026-10-issue-38-*/draft-{tc,ps}-notes.md`.

## What the consumers should use

- **wet#40 (GSDD at stations).** `gsdd::gsdd()` computes the Coleman & Fausch window, which is the
  `growing_season` metric here. The only thresholds to compare against are still cutthroat ones: 800, 900 and
  900–1,200 degree-days; #47's wider search found no other. Report GSDD for every species, but threshold only
  cutthroat, and label those values as Colorado cutthroat (greenback and Colorado River cutthroat; filed as
  `CRCT`). For WCT, the Elk Valley reports (Thorley & Branton 2022, Hocking et al. 2022) are the BC
  precedent for applying them, and say BC fry ran slightly larger than the Colorado relation predicts. Do not
  threshold bull trout on 800: Mochnacz 2021 reports self-sustaining northern populations at or below it.
- **template#214 (Weigert Creek, 693.5 °C-days).** That total runs "across the logger deployment", which is
  neither the growing season nor the time from spawning. Compute GSDD on the Coleman & Fausch window before
  comparing it with 800. Compare degree-days from WCT spawning (5 °C daily mean and 7 °C daily maximum, Cope et
  al. 2016 via Thorley 2022 p. 30) with the 575–600 to emergence. The source does not say when the hatchery
  count starts; counting from spawning onset is the nearest field equivalent. Cite Thorley et al. 2022 for WCT
  emergence, and Coleman & Fausch only for the cutthroat transfer. Where fry were measured, the size form is the
  more direct test: 30–35 mm TL (28–33 mm FL) at the onset of winter, a Colorado value the Elk Valley reports
  apply to WCT.
- **link#21 (temperature as an IP variable).** Match the metric to the per-segment product. The Hill models
  predict weekly means, so `weekly_mean` and `mwat` rows apply directly. A `7dadm`, `7dec` or `daily_max` limit
  needs a daily maximum the models do not produce. For the upper limit of BT rearing, 11 °C MWAT (BC) and 11 °C
  August mean (Isaak) are the BC and regional criteria. For CH, CO and ST with Hill predictions, the Richter &
  Kolmes Table 1 weekly means apply (15 °C rearing, 10 °C spawning and incubation), and Cooney & Holzer's 22 °C
  weekly mean for CH and ST. Iacarella's 24 °C 7DEC needs a 7DEC product (Iacarella's own BC model): the 7DEC
  is "the median value between 7DADM and MWAT", so a weekly mean compared with it under-calls exceedance.
  For WCT rearing, Bear et al. 2005 recommends a maximum daily mean below 16 °C for growth (a weekly mean below
  16 °C does not show that every daily mean was), and both daily-maximum criteria (13–15 °C, 20 °C) need a daily
  maximum; the 19.6 °C 60-d UUILT is a held-temperature limit. The paper (p. 1118, citing other studies) notes that fish
  allowed to recover at lower temperatures each day can survive brief exposure above such a limit, and lists the
  untested fluctuating regime as a limitation of its own study.
  There is no degree-day threshold to gate segments on for any BC species, and #47's wider search did not find one.
  A GSDD layer can rank segments, but a cutoff would come from cutthroat in Colorado.
