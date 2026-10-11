# Late drafter notes (#44): six sources added to `Fisheries/flow` after the PR opened

`draft-late-evidence.csv` holds 56 rows. Draft row N becomes data row 1014 + N when merged onto the current table
(1014 data rows). The merged table passes `0280`: all 56 rows verify (26 `verified_table`, 24 `verified_ocr`,
6 `verified_text`), the gate exits 0, and `flow:` reads 60 of 60. Each row was then re-read against its page. Scan
pages whose OCR or text layer was doubtful were checked on the rendered page: Raleigh et al. 1984 pp. 6, 8, 19, 21,
41, 45, 49; Hickman & Raleigh pp. 4, 5, 6, 12, 23; McMahon pp. 4, 6.

Cross-references inside notes say "previous row" or "next row" and pair adjacent draft rows: 19/20, 30/31, 32/33
and 41/42. They stay correct if the block is appended in order.

## `none` cells

**No late row fills a cell that holds only a `none` row.**
- **CO flow needs** (spawning, incubation, rearing, overwintering; data rows 870-873): McMahon 1983 gives only a
  qualitative coho rearing statement (draft 22, `qual`). Hatfield & Bruce has no coho regression; coho are only in
  the pooled set.
- **GR and WCT flow needs, BT and WCT passage depth:** none of the six sources gives a value. Braithwaite's fish are
  Bear Lake cutthroat (`CT`), not westslope.

## Primary rows for values already in the table second-hand

| second-hand data row | late draft row | what the original says |
|---|---|---|
| 942 (Ford: CT spawning 11-90 cm/s, citing Hickman & Raleigh) | 23 | Hickman & Raleigh p. 5: 11-92 cm/s |
| 943 (Ford: CT optimum 30-60 cm/s) | none | On Hickman & Raleigh p. 6 ("We assume that optimal velocities range from 30 to 60 cm/sec", read on the rendered page). The OCR returns noise for that page, so it cannot be quoted. |
| 954 (Ford: RB optimal spawning velocity 30-90 cm/s) | 30, 31 | Raleigh 1984 p. 8: **optimal 30-70**, unsuitable below 10 or above 90 cm/s. Ford's 90 is the unsuitable edge. |
| 955 (Ford: RB spawning depth 0.15-2.5 m) | none | Raleigh 1984 prints no 0.15-2.5 m span. The nearest are the 15 cm spawning-site depth (draft 34, p. 28) and Figure 2's 8.2 ft upper edge (2.5 m; drafts 37, 38). Ford appears to have combined them. |
| 960 (Ford: RB juveniles 5-13 cm, 10-12 cm/s, max 22 cm/s, citing Raleigh 1984 and Rose 1986) | 32, 33 | Raleigh 1984 p. 9 gives these numbers for **juvenile cutthroat** (Griffith 1972, Idaho), with no length. They are coded `CT`. |
| 961-964 (Ford: trout base flow >55 % excellent, 25-50 % fair, <25 % poor) | 25-28 | Raleigh 1984 p. 6: **≥50 %** excellent (OCR '>'), 25-50 % fair, <25 % poor. Ford's 55 is not on the original page. |
| 810-817, 827 (Ptolemy & Lewis, Hatfield et al. 2002, citing Hatfield & Bruce) | 1-12 (qual) | Hatfield & Bruce print only the regressions. The site values (Ash, Little Qualicum, Carnation, Salmon rivers) are the citing documents' own applications, so no primary valued row exists. |

The second-hand rows were not edited. Al should consider:
- 961-964: the 55 is probably a transcription slip for 50.
- 954: the 30-90 merges the optimum with the unsuitable edge.
- 960: the species is wrong, cutthroat rather than rainbow.
- DR 940 (WCT age 1+/2+, max 22 cm/s, Ford): it carries the same 10-12 and 22 cm/s numbers. Hickman & Raleigh
  p. 5 gives "10 and 14 cm/sec, with a maximum of 22 cm/sec" (Griffith 1972) for **adult** cutthroat. Raleigh 1984
  p. 9 gives 10-12 and 22 cm/s for juvenile cutthroat.

## Per source

### hatfield_bruce2000PredictingSalmonid (drafts 1-12, all `qual`)

**Written.** Table 3 (p. 1012) gives regressions of ln(PHABSIM optimum flow) on ln(MAD), with latitude or longitude
in some. It tabulates no predicted optimum for any MAD. Following the brief, each species x stage is a `qual` row
with the equation in its note: CH, RB, ST and pooled (`SALMONIDS`), for fry and juvenile (both `rearing`) and for
spawning. The quote is the table row on the `-layout` text. R2 is from the Table 3 extension (p. 1013).

**Sign reading.** The text layer prints minus as `2`, plus as `1`, `=` as `5` and `×` as `3`. So "23.794 1 1.246·loge
(MAD)" is -3.794 + 1.246 ln(MAD). Two checks support this reading:
- The abstract's "loge(optimum flow) 5 A 3 loge(MAD), where A , 1" reads as "= A × ..., where A < 1".
- -3.794 + 1.246 ln(1,000 cfs) gives about 120 cfs, which is plausible. +23.794 would not be.

**Left out:**
- **Brown trout** (four regressions). It has no species code in the table, and adding one is Al's call. The
  coefficients are fry 0.444 + 0.568 ln(MAD); juvenile 90.595 + 0.537 ln(MAD) - 18.705 ln(longitude); adult
  1.449 + 0.585 ln(MAD); spawning 1.822 + 0.478 ln(MAD).
- **Adult regressions.** Adult in-stream habitat is not a grid stage (rearing is juvenile summer). They are:
  - CH: NA
  - RB: -6.636 + 0.641 ln(MAD) + 2.105 ln(latitude), R2 0.777
  - ST: 1.105 + 0.737 ln(MAD), R2 0.679
  - pooled: -7.547 + 0.600 ln(MAD) + 2.409 ln(latitude), R2 0.674
- **Prediction intervals** (p. 1013). They are long, and only the notes could hold them.
- **The restatement of Tennant's 10 % and 30 %** (p. 1010). Tennant's primary is already in the table.

**Unsure:**
- Table 3 prints no units. The notes cite Figures 2-3 (ln ft3/s) for flow units and say that latitude and longitude
  have no stated units.
- A `qual` row fills no grid cell. That is as the brief intends for a regression.

### bradford_heinonen2008LowFlows (drafts 13-18)

**Written:**
- 13: `FISH` rearing, min 50 `percentile`, metric `unstated`. "The median (Q 50) monthly flow observed in the late
  summer" is the common historic-flow recommendation (p. 171).
- 14: `FISH` rearing, min 10 % MAD, `unstated`, `expert`. The authors summarise summer flow-reduction experiments:
  leaving about 10-20 % MAD showed little change, and declines were seen when residual flow was usually below 10 %
  MAD (p. 172).
- 15-18, `qual`:
  - 15: FISH rearing. Smaller streams need a greater share of MAD than Tennant suggests (O'Shea 1995; Rosenfeld et
    al. 2007), p. 171.
  - 16: SALMONIDS incubation. Alevins need enough flow to reach free-flowing water, p. 169.
  - 17: SK incubation. Winter discharge was related to egg and alevin survival, Kamchatka (Selifonov 1987), p. 170.
  - 18: RB overwintering. Mitro et al. (2003) found low winter flows limited access to bank habitat and overwinter
    survival tracked flow, p. 174.

**Left out:**
- **The restatement of Tennant's 10 % and 30 % MAD** (p. 171). The primary is already in the table.
- **Table 1 flow-augmentation case studies** (p. 173). Before and after flows at single sites are outcomes, not needs.
- **Baseflow as % MAD of Vaseux and Carnation creeks and Catamaran Brook** (p. 166). This is hydrology.
- **Brook trout insensitive to 75-90 % reductions of summer flow; 4 % of normal summer flow affected brook trout**
  (p. 168). These are percent of summer flow, not MAD, for a species outside the grid.

**Unsure:**
- **Row 14.** It is a review's reading of experiments, not a standard. I coded it `expert`/`min` with a note saying
  so; `qual` is the alternative.
- **Row 13.** "Median monthly flow" could be the median of monthly means or of daily flows within the month, so the
  metric is `unstated`.

### mcmahon1983Habitatsuitability (drafts 19-22; OCR)

**Written:**
- 19: CO spawning velocity, optimum 21-70 cm/s, `pref`. "Preferred redd construction sites" (Smith 1973), p. 4.
- 20: CO spawning depth, min 15 cm, `pref`. The same sentence; the scan's "≥ 15 cm" is OCR'd "= 15 cm".
- 21: CO overwintering velocity, max 15 cm/s, `dist` (Hartman 1965; Bustard & Narver 1975a), p. 6. Not a grid cell.
- 22: CO rearing `qual`. Higher streamflows during rearing give more suitable habitat, p. 6.

**Left out:**
- **Thompson (1972) adult coho passage, minimum depth 0.18 m and maximum velocity 244 cm/s** (p. 4). Data rows
  692-693 already hold the same Thompson criterion via Bjornn & Reiser. A third restatement would count one value
  twice more.
- **The winter fry depth of 45 cm or more.** The OCR prints "2 45 cm", so the row was not written.
- **The parr pool depth of more than 0.30 m** (Nickelson, pers. comm.). Rearing depth is not a grid cell.
- **The model's variables.** The HSI model has no flow, depth or velocity variable.

**Unsure.** The `pref` kind on 19-20. McMahon calls the sites "preferred" but does not say how Smith (1973) derived
the numbers. Levy & Slaney's Smith (1973) rows (952, 953) are `expert`.

### hickman_raleigh1982Habitatsuitability (drafts 23-24; OCR)

The OCR is poor for this scan:
- Printed p. 4 (PDF 12) is missing from the OCR.
- Pp. 6-7 (PDF 14-15) come out as noise.
- The SI graphs carry no coordinate tables.

**Written:**
- 23: CT spawning velocity, range 11-92 cm/s, `dist`, p. 5. "Average water column velocities for embryo development
  apparently range from 11 to 92 cm/sec", coded spawning as row 751 codes Raleigh 1986.
- 24: CT spawning depth, min 15 cm, `param`. The model's definition of a potential spawning site, p. 23.

**Seen on the rendered pages but not quotable** (the OCR has nothing on those pages):
- **p. 4:** base flow ≥ 50 % of average annual daily flow is excellent, 25-50 % fair, < 25 % poor (Binns & Eiserman
  1979; Wesche 1980). This is the same scheme as Raleigh 1984 (drafts 25-28).
- **p. 6:**
  - "We assume that optimal velocities range from 30 to 60 cm/sec" (the original of data row 943).
  - Fry "utilize velocities of less than 30 cm/sec, but less than 8.0 cm/sec are preferred" (Griffith 1972; Horner &
    Bjornn 1976).
- **V5 velocity SI graph (p. 12):** read by eye, SI 0 near 12 cm/s, 1.0 near 30-60, 0 near 90. It has no printed
  coordinates.

**Left out:**
- **Hooper (1973) and Thompson (1972) "31 to 92 cm/sec"** (p. 5). The page does not say which species those studies
  measured. Row 23, the authors' cutthroat statement, carries the span.
- **Adult focal-point velocities, 10-14 and maximum 22 cm/s** (Griffith 1972, p. 5). Adults are not a grid stage.
  See the DR 940 note above.
- **Additional Model 1, "< 50% annual fluctuation from average annual daily flow"** (p. 29). This is a stability
  attribute, not a flow level.

**Unsure.**
- **Row 23's species.** The authors state it for cutthroat embryo development, but Table 1 (p. 21) says the model's
  sources include related salmonid species.

### raleigh_etal1984Habitatsuitability (drafts 25-42; OCR)

**Written:**
- **25-28.** RB rearing and overwintering instream_flow: optimum 50 % MAD (the excellent class) and min 25 % MAD,
  `unstated`, p. 6. The originals of data rows 961-964; same stage convention.
- **29.** ST migration `qual`, p. 8. "Streamflow conditions should be above normal seasonal flows during upstream
  migrations of steelhead adults." Optional variable V18 (p. 21) is a curve with no printed coordinates: SI 0 at
  25 % of average daily flow, rising to 1.0 near 110-115 %, read by eye.
- **30-31.** RB spawning velocity above redds, p. 8: optimum 30-70 and limits 10-90 cm/s, `expert`.
- **32-33.** CT rearing velocity (Griffith 1972, juvenile cutthroat, Idaho), p. 9: 10-12 cm/s (`optimum`, `dist`)
  and max 22 cm/s.
- **34.** RB spawning depth min 15 cm, `param`. The spawning-site definition, p. 28.
- **35-38.** Figure 2 spawning curves, p. 41, `hsi`. Coordinates checked on the rendered page:
  - velocity: zero edges 0.9 and 3.1 ft/s, SI 1.0 from 1.6 to 3.0;
  - depth: zero edges 0.6 and 8.3 ft, SI 1.0 from 0.7 to 8.2.
- **39.** Figure 3 fry velocity, upper zero edge 2.95 ft/s, p. 45.
- **40.** Figure 4 juvenile velocity, upper zero edge 3.50 ft/s, p. 49. Both from Moyle et al. (1983), California.
- **41-42.** ST overwintering velocity, p. 48 (Bustard & Narver 1975, Carnation Creek, winter): preferred < 0.5 ft/s
  (`pref`) and almost none above 1 ft/s (`dist`). Not a grid cell.

**Left out:**
- **Fry "utilize velocities less than 30 cm/sec, but velocities less than 8 cm/sec are preferred"** (p. 8). The
  cited studies are Griffith 1972, which per the reference list is brook and cutthroat trout in northern Idaho, and
  Horner & Bjornn 1976, "trout and salmon fry". So the species measured is not rainbow trout. Data rows 958-959
  (Ford p. 47, RB, no cited source) carry the same 30 and 8 cm/s and may trace here; worth a look.
- **Adult curves (Fig. 5) and adult focal velocities.** Adults are not a grid stage.
- **Juvenile and fry depth curves; Gosse (1982) seasonal mean velocities.** Rearing depth is not a cell, and Gosse's
  values are averages by activity and season, not a need.
- **"Average depth of egg deposition is 15 cm"** (Hooper 1973, p. 2). This is burial depth, not water depth.
- **"Egg incubation velocities above redds which range from 1.0 to 3.0 fps"** (p. 44). The page restates the
  spawning curve for incubation, and row 751's convention draws no separate incubation row.

**Unsure:**
- **ST twins.** RB rows from curves titled "rainbow trout" have no ST twins. Raleigh's model covers steelhead as
  Case 2, but the curves and text name rainbow trout. Steelhead-only statements (29, 41-42) are `ST`.
- **Rows 35-40 quote coordinate columns as the OCR emits them, stray plot characters included.** This is the same
  practice as the Raleigh 1986 rows (729-750). The notes say so.

### braithwaite2011effectstream (drafts 43-56; `table`)

Bear Lake cutthroat (*O. clarkii utah*, printed "clarkia"), coded `CT` with the subspecies in every note. Region:
Strawberry River, Utah. Classes come from use data only: optimal is the central 50 %, useable 50-94 %, unsuitable
outside the central 95 %.

**Written:**
- **43-50.** Table 2-1 (p. 34), spawning redds, 2009 and 2010:
  - optimal depth and near-bed velocity as `optimum`;
  - the unsuitable edges (depth < 0.10/> 0.37 m, velocity < 0.07/> 0.66 m/s in 2009; < 0.13/> 0.26 m and < 0.13/
    > 0.58 m/s in 2010) as `range`, `dist`, noted as observed spans.
- **51-56.** Table 3-1 (p. 69), juveniles (0-150 mm), late August and early September, 2008-2010: optimal near-bed
  velocity as `optimum`; the upper unsuitable edge (0.33, 0.24, 0.29 m/s) as `max`, `dist`.

**Left out:**
- **Adult (> 150 mm) rows of Table 3-1.** Adults are not a grid stage.
- **Juvenile depth and substrate; spawning substrate.** These are not cells.
- **The logistic regressions** (Tables 2-2, 3-2). They give odds ratios, not thresholds.

**Unsure.** I treated the unsuitable boundaries as observed spans (`dist`). The author labels them "unsuitable",
but they are percentiles of use, with no availability correction.

## Anything the table cannot hold
- **Hatfield & Bruce's prediction intervals and its latitude and longitude terms.** These live only in notes.
- **Graphs printed without coordinates** (Raleigh 1984 V14 and V18; Hickman & Raleigh's SI graphs). They can only be
  described in notes.
