# Draft notes: trout and char (`tc`), WCT and BT (#38, Phase 4)

Rows are in `draft-tc-evidence.csv` (50 rows: 23 WCT, 23 BT, 4 CRCT). They were checked by the 0280 gate on
the merged draft (`merge_drafts.py tc`). Six are `none` rows. The rest are valued rows, and every one of them
was re-read against its page.

How I searched: grep over the extracted text of every collection PDF in the scratch `txt/` directory
(cutthroat, westslope, bull trout, °C/ºC/˚C, degree-day, thermal unit, CTU, ATU, hatch, emerge, growing
season); `ragnar_retrieve()` on `data/rag/temperature.duckdb` for degree-days to hatch and emergence, growing
season and overwinter size, and incubation lower limits; and `keytext.py` for `hagen_weber2019Limitingfactorsa`,
which is a group key outside the collection. `mcmahon_etal2007TemperatureCompetition` and both Bear et al. items
have no PDF in the group library.

## WCT

| cell | filled by | where |
|---|---|---|
| temperature spawning upper | ranges 6-10 (DFO Table 2), 7-10 (BC account), 7.2-12.8 (Sauter Table 4) | DFO 2019 p. 17; BC 2004 p. 5; Sauter p. 18 |
| temperature spawning lower | the same ranges; onset minima 10 (DFO p. 4; Cleator p. 2), 6 at high elevation (DFO p. 4), 5 C daily mean together with 7 C daily max (Thorley 2022 p. 30, Cope et al. 2016) | |
| temperature incubation upper/lower | 6-10 (DFO Table 2, "Spawn through alevins": spawning and incubation share one attribute list) | DFO p. 17 |
| temperature rearing upper | 4-15 (DFO Table 2, fry to parr); max 22 (DFO p. 6); UILT 19.6 (Cleator p. 4, Bear et al. 2007); 19 (Thorley 2021 p. 1, Bear et al. 2007); >20 (BC account p. 5) | |
| temperature rearing lower | 4-15 (DFO Table 2) | |
| degree_days incubation to_hatch | `none` | the documents give incubation time only: 6-7 weeks (DFO, Cleator), 3-7 weeks (Roberge) |
| degree_days emergence to_emergence | 575-600 thermal units, hatchery-reared WCT (Thorley 2022 p. 30, Kootenay Trout Hatchery pers. comm.) | also in its exec table p. iii |
| degree_days rearing growing_season | `none` | |
| degree_days overwintering growing_season | `none` | |

Extra WCT rows (no cell): optimum 9-12 C twice (DFO p. 6, ASRD and ACA 2006; Cleator p. 4, Behnke and Zarn 1976);
overwintering 0-6 C (DFO Table 2) and 4-5 C as the cue for moving into overwintering habitat (Roberge p. 61);
migration onset at 7-10 C (BC account p. 5).

### Where a WCT document applies a Colorado River cutthroat value

- `thorley_etal2022UpperFording` p. 30 calls WCT hatchery emergence at 575-600 thermal units "consistent with
  Coleman and Fausch's (2007a) estimate of 570 to 600 Accumulated Thermal Units (ATUs) for Colorado Cutthroat
  Trout". The CRCT value is its own row (`coleman_fausch2007ColdSummera` p. 1234).
- Thorley 2022 p. 30 reads age-0 fish under 30 mm as suggesting poor overwinter survival, citing Coleman and
  Fausch 2007a, 2007b; p. 29 and Thorley 2021 p. 1 cite Coleman and Fausch for recruitment failure at low summer
  temperature. No WCT degree-day value comes with either.
- The Hill et al. 2024 and 2025 memos compute GSDD with Coleman and Fausch's start and end rules, and call GSDD
  "a useful predictor of age-0 rainbow and westslope cutthroat trout size at the beginning of winter". They state
  no WCT threshold, so the WCT overwintering cell has a `none` row. If a WCT threshold is wanted, the 800 and
  900 GSDD CRCT rows are the only source, and they are CRCT values.

### Not written for WCT, and why

- **Hasnain et al.**: Table A1 lists "Cutthroat Trout, *O. clarkii*", not WCT: OGT 22.0 (Williams et al. 2009),
  13.4 and 14.2 (McMahon et al. 2006); FTP 14.8-14.9 (McMahon et al. 2006); UILT 24.0 (Williams et al. 2009)
  and 19.7 (Bear et al. 2005); CTMax 25.5-29.9 (Beitinger et al. 2000). Its methods say "All metric estimates
  were derived using adult members of each species". The Bear and McMahon values were measured on WCT, but the
  page calls them adult values and lists them under the species. I left them out. The 19.6 C UILT from Cleator
  carries the Bear et al. 2007 value. If the 19.7 C row is wanted, it would be WCT, rearing, constant, cited
  source Bear et al. 2005, and its note would have to give Hasnain's "adult" claim.
- **Species-level cutthroat values** (code `CT` if they are ever wanted): Isaak et al. 2015 apply the 11 C
  mean-August criterion to "cutthroat trout (CT)", and 75 % of juvenile CT observations were at or below 11 C;
  Sauter Table 2 gives juvenile and adult "Cutthroat trout (*O. clarki*)" 10-14 C instantaneous at Lake Pend
  Oreille (Bonneau and Scarnecchia 1996); Bjornn and Reiser give "Cutthroat trout" spawning 6.1-17.2 C and
  22.8 C upper lethal (Bell 1986); Eaton and Scheller give cutthroat trout MWAT tolerance 23.3 C; Chezik et al.
  2014 Table 1 lists cutthroat base temperatures of 0 and 5 C from Coleman and Fausch 2007. None of them names
  westslope.
- DFO p. 6, and Cleator p. 4: adfluvial adults in lakes under 16 C (McIntyre and Rieman 1995). This is adult
  lake habitat, not rearing.
- Thorley 2022 exec table (p. iii): "Growing season ends in October depending on when stream temperatures fall
  below approximately 5 degrees" (no unit; a growing-season definition, not a cell).
- Cope 2020 p. 30: Ewin Creek is "near minima optima for Westslope Cutthroat Trout (Oliver and Fidler 2001)".
  No value.

## BT

The temperature cells already had rows (21 BT temperature rows). Following the brief, I added every new value
these sources give.

| cell | new rows |
|---|---|
| temperature spawning upper | 10 (Sauter Table 4, 'cessation >10'); 9 onset (Hagen and Weber p. 22); 10 (Bustard p. 106); range 4-10 (USFWS 2015 p. 6, Howell et al. 2010) |
| temperature spawning lower | 5, where spawning stops (McPhail and Baxter p. 6, Allan 1987); range 4-10 (USFWS 2015) |
| temperature incubation upper/lower | no new value (1.2-5.4 already a row) |
| temperature rearing upper | UILT 20.9 (Selong p. 1026); 15 (USFWS 2010 p. 63930; USFWS 2015 p. 5; Rieman and McIntyre p. 7); 2-15 (USFWS 2010 PCE, p. 63932); 16 (Hagen and Weber p. 25, '15-16'); 11 MWAT (Hagen and Weber p. 25, Parkinson et al. 2012); 12 (Bustard p. 106); 11 and 13 (O'Connor p. 23) |
| temperature rearing lower | 2 (the PCE range) |
| degree_days incubation to_hatch | 350 CTU (McPhail and Baxter p. 9, Gould 1987) |
| degree_days emergence to_emergence | `none`: the sources give days (about 220 or 223 after deposition; more than 200) |
| degree_days rearing growing_season | `none` |
| degree_days overwintering growing_season | `none` |

Extra BT optimum rows: Sauter Table 4 peak spawning below 7 C; Sauter Table 2 juvenile 13-14 C MDMT (Rieman and
Chandler 1999), and juvenile-and-adult 11.6 C MWMT and 10.2 C MWAT (Haas, Kootenay).

### BT: what the table cannot hold, or I was unsure of

- **Stage assignment.** Several upper limits name no life stage: Rieman and McIntyre ("limit bull trout
  distribution"), Hagen and Weber 15-16 C and 11 C MWAT ("for the species"), and O'Connor's 11 and 13 C. I filed
  them under `rearing` as summer stream limits, the same choice the existing McPhail and Baxter p. 12 row made.
  The USFWS 2010 PCE 2-15 C applies to all stages ("will depend on bull trout life-history stage and form"), and
  it is also under `rearing`. A reviewer may prefer to leave these out of the grid.
- **O'Connor's 11 C** ("a provincially designated thermal threshold", Parkinson et al. 2016) is drawn against
  average daily temperature and applied to spawning-habitat sites. Hagen and Weber give the same BC threshold as
  11 C MWAT (Parkinson et al. 2012). The two may be one threshold under two citations. Both rows are kept, each
  with its own metric (`unstated` and `mwat`).
- **Sauter Table 4 "cessation: >50 (>10)"**: I read it as spawning ceasing above 10 C. The table does not
  explain the term. The table header assumes daily averages, so `unstated`.
- **Sauter Table 2** has control characters before the numbers of the Rieman and Chandler line in the text
  layer, so a table quote cannot match. That row is a `text` quote that skips the Fahrenheit value. MDMT is
  undefined in the paper, so `unstated`. The Saffel and Scarnecchia row prints "(7 .8-13.9)", which breaks the
  number 7.8, so I did not write it. Bonneau and Scarnecchia (8-9 C instantaneous) and Fraley and Shepard (15.0 C,
  "unknown") also have control characters and were left out. All are juvenile preferences.
- **Lab limits and `kind`.** The vocabulary has no kind for a measured laboratory limit (UILT). I used `expert`
  for UILT rows, and for the hatchery degree-day figures (350 CTU; 575-600; 570-600), following the existing
  lab-optimum row only for optima (`pref`). This choice should be made once for the whole table.
- Dunham and Chandler p. 23 give UILT 20.9 C for juveniles (McMahon pers. comm.). That is the Selong measurement,
  so there is no separate row. It is already in the existing Dunham row's note.
- Hagen and Weber p. 25: "physiological stress begins to occur at constant temperatures of 14-16°C (Selong et
  al. 2001)". This is the onset of stress, not a limit. Not written.
- Bustard p. 106: fry grew larger and survived better at 4 C (McPhail and Murray 1979). Bull trout fry are active
  near 1 C in October (Kemess Creek). Not limits.
- O'Connor reports ATU over an assumed incubation window at monitored sites. These are site statistics, not a
  requirement, so they were not used for to_emergence.
- USFWS 2010 p. 63930: adults up to 20 C in large rivers, with declines in abundance at 15-20 C (Gamett 2002).
  Adult, so not rearing (in the row's note).
- USFWS 2015 p. 4: "often less than 12 degrees Celsius". This is a general requirement with no stage, and it was
  not written. p. 5 rearing optimum 7-8 C (Goetz 1989) duplicates the existing Rieman and McIntyre row's claim.
- Hasnain et al. has no bull trout entry. McMahon et al. 2007 (brook trout competition, 16-20 C) has no PDF. USFWS
  2010 p. 63933 cites its 16-20 C, as an interaction effect, not a limit.

## CRCT (extra; not in the grid)

Four rows, so the WCT documents' borrowed values have a home:
- 570-600 degree-days to emergence (`coleman_fausch2007ColdSummera` p. 1234, citing the 2007 lab study).
- Growing-season minimum 800 and optimum 900-1200 (2007a p. 1231). These are overwintering rows, because the
  mechanism is size at winter onset; Discussion p. 1240 gives the 30-35 mm TL minimum.
- Growing-season minimum 900 (lab paper p. 652; the text layer renders '>' as '.').

**Greenback cutthroat:** the 2007a field values are for greenback and Colorado River cutthroat together, and the
Discussion says "three subspecies of cutthroat trout native to Colorado". The brief says one row per named
species, but greenback has no species code in the table. I wrote CRCT only. A greenback row needs a code first.

Base temperature: 2007a defines GSDD as a sum of daily mean temperatures, so in effect base 0 C, with the season
from the first week averaging above 5 C to the first week averaging below 4 C. The lab paper and the 570-600
value do not state a base.

Spawning onset for cutthroat in Colorado ("mean daily water temperatures reach 58C", which is 5 C) cannot be
quoted, because the degree sign renders as '8' and fuses with the number. Not written.

## Parent's decisions after drafting (2026-10-06)

- **Sauter Table 4 BT "cessation: >10" was not filed.** Read as "spawning ceases above 10 C" it contradicts
  the falling-temperature onset every other BT spawning row records, and the paper does not define the term.
  The cell table above lists it; the row is not in the evidence table.
- `kind` `lab` was added for laboratory and hatchery measurements (UILT, CTmax, survival at held temperatures,
  development in thermal units): rows 521, 522, 523, 534, 536, 556 (meaning audit round 1).
