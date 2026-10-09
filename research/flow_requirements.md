# Flow needs by species and life stage

**Verified:** 2026-10-07 · **Issues:** #44 (this); flows to compare against in `modelled_discharge.md` (#42);
companion to `thermal_requirements.md` (#38) · **Produced by:** rows of `data/literature_evidence.csv` with
`variable` `instream_flow`, `depth` or `velocity` (data rows 687–1014 are #44's; 121, 250, 257, 264, 407, 497
and 498 are from earlier issues, and #44 recoded all but 407), gated by `scripts/0280-literature-verify.R` (log `scripts/logs/habitat/20261007_literature_verify.csv`).
The sources are the group's `Fisheries/flow` collection (`FWTJDD8Z`; `data/flow_{members,additions}.csv`, 40
items, all with a PDF since 2026-10-09) and the `flow` store.

**Status:** every species × cell of the gate's flow grid (CH, CO, SK, ST, BT, GR, WCT; 60 cells) has a value or a
`none` row. Cited flow needs exist for CH and ST, and thinly for BT. CO and SK have only a September low flow
from the upper Bulkley. GR and WCT have none in any source read. Spawning depth and spawning and rearing velocity have
values for every species (SK has no rearing-velocity cell); passage depth is `none` for BT and WCT.
Six sources reached the collection after the rows were drafted and are not yet read for rows (below).

## How to read the rows

- **`instream_flow` is a flow need: the water a life stage needs while it is in the stream.** `discharge` is
  stream size: the MAD an intrinsic-potential model uses to say a stream is big enough. The two never mix. Of the
  45 `discharge` rows before #44, one was a need (Gottesfeld & Rabnett's migration low flow, row 121) and moved.
  Isaak 2015 and Boughton & Goslin 2006 give summer flows, but both use them to size streams, so they stay
  `discharge`. Boughton & Goslin's envelope (rows 310, 311, 318, 319) is still the nearest thing to an
  over-summer need for juvenile steelhead in a dry climate.
- **The unit is as the source wrote it:** m3/s, cfs, `percent MAD`, a `percentile` of a flow distribution (the
  90th is a high flow), or a `percent exceedance` (Q95, exceeded 95 % of the time, is a low flow). Never
  convert. Depth is in m, cm or ft, and velocity in m/s, cm/s or ft/s. A bankfull depth is stream size, so it is
  `m bankfull` and fills no cell. `0280` no longer rescales cm/s to m/s, and its m/km rescale is for bridge
  distance only.
- **`metric` is the flow statistic the need is held to.** It is `unstated` unless the source names one, and it
  is `unstated` on most rows: the BC standards name none. Tennant asks for *instantaneous* flows (p. 10,
  recommendation 1). Warkentin et al. use mean August flow and Gottesfeld & Rabnett average September flow
  (rows 865, 866), both `monthly_mean`; Gottesfeld & Rabnett's salmon sentence (row 121) names no statistic and is
  `unstated`. DFO 2013 states its 30 % MAD as an instantaneous flow.
- **`bound`:**
  - `min` is a minimum flow.
  - `optimum` is a PHABSIM or WUA peak, Tennant's optimum range, the best class of a three-class scheme (Ford's and
    Raleigh's base flow "excellent" class), or a flow the source calls optimal or near-optimal.
  - `range` is a span between two limits.
  - The 30–200 % MAD standard has **no bound**: it is one minimum per stream, about 200 % of MAD in the smallest
    streams falling to 30 % in the largest. A program reading `min` would take 30 %, which is right only for big
    rivers. The equation is in the `qual` rows (809, 824).
- **`species_code`** is the species measured, or the scope a standard states: `FISH`, `SALMON` or `SALMONIDS`
  (Al, 2026-10-07). A group-code row fills no cell, so a full grid means species evidence, not a generic floor
  copied seven times.
  - A curve that pools steelhead and resident rainbow is one row per named species: the ST row and its RB twin
    cross-reference each other.
  - Generic cutthroat is `CT`, never `WCT`. Ford's fry velocity of <1 cm/s comes from a study of Cascade
    Mountain cutthroat whose subspecies is uncertain (row 928).
- **The stage carries the season, and there is no month column.** A row's note names any months the source
  gives. To place a need in the year, join its stage to `life_history_timing.csv` (see the #42 join below). A
  year-round standard (DFO's 30 %, Hatfield 2003's lowest-month threshold) is coded `rearing` because the stage is
  required, and its note says it applies all year. That is a gap in the vocabulary. It costs no cell, because
  these are `FISH` rows.

## The generic floor (fills no cell)

- **BC (Ptolemy's standards).** These appear in Hatfield et al. 2002 Table 5 (rows 819–824; row 826 is the linear
  stand-in for the spawning equation on p. 43; the table's summer steelhead line is coded ST and listed under ST),
  Ptolemy & Lewis 2002 (rows 803–809 and 818; their steelhead PHABSIM optima are listed under ST) and Hatfield et al. 2003 (which restates Table 5, so it is not written again):
  - incubation, rearing and overwintering: 20 % MAD;
  - spawning and adult migration: 30–200 % MAD by stream size;
  - summer steelhead passage: 50–100 % MAD for days.

  These are the provincial instream-flow standards. The Appendix A periodicity charts apply them to the Nechako,
  Ash, Cheakamus and Sinmax as worked examples. The Nechako conservation flow is marked preliminary.
- **Hatfield et al. 2003 fish-bearing threshold (row 847).** The 90th percentile of mean daily flows in the
  lowest-flow month, falling to the 20th percentile in the highest, interpolated between them. It needs daily
  flows; monthly means cannot reproduce it.
- **DFO 2013 (row 848).** Below 30 % MAD instantaneous flow, a more rigorous assessment is recommended. It is a
  screening level, not a need.
- **Tennant 1976 (rows 791–802).** Instantaneous flows as a percent of average flow, October–March / April–September:
  - 10 / 10 % is poor or minimum, short-term survival;
  - 10 / 30 % is fair or degrading;
  - 20 / 40 % is good;
  - 30 / 50 % is excellent;
  - 40 / 60 % is outstanding;
  - 60–100 % is the optimum range.

  Neuman & Newcombe's Okanagan variant halves the Montana flows (rows 788, 789).
- **Salmonids.** Raleigh et al. 1986 give a base flow ≥50 % of average annual flow as excellent and <25 % as poor
  (rows 760, 761). Bjornn & Reiser and Keeley & Slaney give generic spawning depths and velocities.

## By species (cells that are filled)

| species | flow need (rows) | depth, spawning / passage | velocity, spawning / rearing |
|---|---|---|---|
| CH | Ptolemy's standards on the Nechako (rows 832–835: 22 % spawning, 20 % incubation, rearing and overwintering) and Hatfield's 5.8 m3/s worked example (828–831); Warkentin et al. 2022, Nicola: mean August rearing flow below 10.6 m3/s (36 % MAD) drops productivity below replacement (862–864); Clear Creek, California: a WUA peak at 650 cfs (857) and the authors' recommended ≥600 cfs for September–December (858) | 15 rows: criteria ≥24–30 cm (Bjornn & Reiser, Levy & Slaney), HSI zero edges at 9–15 cm (Raleigh) and 0.35–1.55 ft (Beecher, 762, 763, 766), Clear Creek's 0.8–7.0 ft HSC (849), observed redd depths / 0.24 m passage | 18 / 17 rows |
| ST | Ptolemy's summer steelhead passage, 50–100 % MAD (825, and 837 on the Ash); Ash and Cheakamus charts (836–846: 20 % rearing, incubation and overwintering; 34–45 % spawning and passage); PHABSIM optima from Ptolemy & Lewis (810–817: 12–128 % MAD, or 0.19–9.0 m3/s at named sites), which they contrast with the 20 % standard, and Hatfield's Salmon River run (827, 5.5 m3/s); Clear Creek, California: WUA peaks at 350 and 600 cfs (859, 860) and a recommended 200 cfs judged near the optimum (861) | 4 rows: ≥24 cm criterion, HSI edges at 0.4–0.65 ft, observed 0.2–1.5 m (782) / 0.18 m | 4 / 4 rows |
| CO | upper Bulkley average September flow below 1 m3/s impairs adults reaching spawning areas (865); otherwise **none** | 2 rows: ≥18 cm criterion, Beecher's 0.15 ft zero edge / 0.18 m | 2 / 4 rows |
| SK | as CO for migration (866); spawning and incubation **none** | 2 rows: ≥15 cm criterion, 0.15 ft zero edge / 0.18 m | 2 rows / no cell (lake rearing) |
| BT | Nechako chart only: adult passage 40–80 % MAD (901); "rearing (adult and juvenile)" 55 % MAD, which is Ptolemy's *adult* rearing standard (902) | 4 rows (redd means 24–58 cm, 876; spawning-area depth 30–60 cm, 886; Ford's 0.15–0.84 m, 889; Beecher's 0.15 ft zero edge, 894) / **none** | 5 rows, ≤65 cm/s typical / 6 rows, fry ≤30 cm/s |
| GR | **none** in any source | Hubert et al. 1985 HSI and Stewart et al. 2007 / Hubert's passage curve: 0.3 ft zero edge (924), 0.4 ft minimum suitable (923) | 6 / 5 rows |
| WCT | **none** in any source | 3 rows (0.10–0.75 m) / **none** | 3 / 4 rows |

Values are in each row's own unit and mix criteria, HSI zero edges and observed redd depths (row 777 is
deep-water spawning at Columbia dam outfalls, 4.0–8.1 m), so a single span across a cell's rows means
nothing; read the rows. The `none` rows (data rows 870–875 and 992–1006) name what was searched. Coho and sockeye are charted in
Hatfield's Appendix A without a standard of their own. The Ash River chart lists general standards under its
coho rows but names no species, so it is cited in the coho `none` notes, not coded as coho.

## Comparing a need with #42's monthly flows

- **Directly comparable:** `monthly_mean` rows in m3/s. Warkentin's August 10.6 m3/s is for the Nicola, and
  Gottesfeld's September 1 m3/s for the upper Bulkley. Compare them with the same month's modelled mean.
- **Comparable after scaling:** `percent MAD` rows. Multiply by the segment's MAD, then compare with the monthly
  mean of the stage's months. Most of these rows are `unstated`, so treating them as monthly means is an
  assumption, and a mild one only for the 20 % standards that run for months.
- **Not comparable with monthly means:**
  - `instantaneous` rows (Tennant, DFO), because a monthly mean hides the low days;
  - `percentile` rows (Hatfield 2003), which need the daily distribution.

  #42 found that the model overstates drought low flows, so a modelled month that clears a need in a dry year is
  weak evidence that the need was met.
- **The timing table is the limit.** `life_history_timing.csv` has no `rearing` rows, no GR, and writes cutthroat
  as `CT` where this table writes `WCT`. It covers only BULK and MORR. Until it grows, a stage's months come from
  the source's own note or from the timing rows that exist.

## Not obtained, left out, and why

- **PDFs in the collection since 2026-10-09, not yet drafted:** the rows above were written without them, and
  any value they give appears here only where another document reports it.
  - Hatfield & Bruce 2000 (`hatfield_bruce2000PredictingSalmonid`): the PHABSIM regressions of optimum flow on MAD,
    the likeliest to add species optima;
  - Bradford & Heinonen 2008 (`bradford_heinonen2008LowFlows`): small-stream low flows;
  - McMahon 1983 (`mcmahon1983Habitatsuitability`): coho HSI, a scan, which may fill coho flow or depth cells;
  - Raleigh et al. 1984 (`raleigh_etal1984Habitatsuitability`): rainbow trout HSI, a scan (already a member; only
    its PDF is new);
  - Hickman & Raleigh 1982 (`hickman_raleigh1982Habitatsuitability`): cutthroat HSI (FWS/OBS-82/10.5), from the
    Internet Archive (`doi-report_i-499782-105`); generic cutthroat, so `CT`, and a WCT cell only where it names
    westslope;
  - Braithwaite 2011 (`braithwaite2011effectstream`): cutthroat depth and velocity preference in the Strawberry
    River, Utah. The fish are Bear Lake (Bonneville) cutthroat, *O. clarkii utah*, not westslope, so its rows
    would not fill a WCT cell.
- **Scans:** the store holds no text for the McMahon coho scan, and only a garbled layer for Raleigh 1984 and
  Hickman & Raleigh, so a store search will not find their values; rows from them go through `0280`'s OCR path.
- **Out of scope, not written:**
  - smolt (downstream) migration flows: `migration` is adult upstream passage;
  - adult holding;
  - rearing depths;
  - values with no bound, by the salmon draft (the trout draft wrote four as `dist` rows with no bound, which fill
    no cell: the redd means 881–883, and 900, which its source does not call a mean or a limit);
  - equations with no tabulated values (Keeley & Slaney's regressions on fish length; the Washington toe-width
    method);
  - Baxter 1961, which is about Atlantic salmon.

  Both drafts' notes list the rest (`planning/archive/2026-10-issue-44-*/draft-*-notes.md`).
- **Scans:** Neuman & Newcombe's appendix depth and velocity tables are rotated and unreadable by OCR.
  Bjornn & Reiser's OCR garbles the "≥" depths, so those cells cite Levy & Slaney's text reproduction of the same
  tables.

## How the rows were checked

Every quote verifies in its PDF (`0280`). Three rounds of meaning audit read every new row, or every row the
previous round changed, against its page:
- **Round 1:** 58 errors in 325 rows. The largest single cause was the drafter brief's own Tennant metric.
- **Round 2:** 24 errors in the 77 rows round 1 touched, several inside round 1's fixes.
- **Round 3:** 0 errors in the 44 rows round 2 changed, so the audit stopped there.

Same-page groups with mixed kind, metric or unit were enumerated, 34 of them. Each is explained by its own
sentences or was fixed. Measurements and the full chain are in the #44 planning archive.
