# Draft notes: BT spawning evidence (#33)

23 draft rows in `draft-spawn-evidence.csv`, all `species_code = BT`, `model_id` blank. Every quote was
checked against the page text with the gate's tokeniser (punctuation included). Metolius quotes were checked
against the gate's own OCR cache, `data/rag/ocr/204cff966dfb40fc0342f8c0516d099a.txt`. The values in 21 of
the 23 rows are in their quotes. The merged table (489 + 23 = 512 rows) passes `knw_literature_read()`, and no
new row repeats an existing citation_key + quote. `0280` was not run.

## Flags for the parent

1. **Two depth rows will fail `value_not_in_quote` as drafted** (`hagen_weber2019`, p. 22, 0.24-0.58 m and
   max 0.9 m). The source writes centimetres, and `SCALE$m` in `0280` is `c(1, 1e3)` (km to m, for bridge
   distance), with no ×0.01. Either add a cm-to-m rescale for `depth`, or drop the two rows and move the
   numbers into the velocity rows' note. The values are correct (24-58 cm and <90 cm).
2. **No `groundwater` variable.** Groundwater, upwelling and hyporheic flow are the habitat feature the
   sources stress most, after gradient. I put groundwater statements under `temperature` (qual) only where
   the quote is about cold water (springs, "the coldest streams"), and alluvial/confinement statements under
   `valley_width_index` (qual). I left out statements that are only about groundwater:
   - 75 FR p. 63930: "Selection of spawning habitat by bull trout is also influenced across multiple spatial
     scales by hyporheic flow (Baxter and Hauer 2000, p. 1476)"; and "Spawning areas are often associated
     with cold-water springs, glacial and snow melt, or groundwater upwelling" (Rieman et al. 1997; Baxter et
     al. 1999). The second could go in as `temperature` qual if wanted. I used USFWS 2015 p. 5 instead, which
     is the same claim with "the coldest streams".
   - hagen_weber2019 p. 22: "In larger streams spawning sites are often associated with aggrading areas and
     areas of groundwater infiltration (Oliver 1979; Graham et al. 1981; Fraley and Shepard 1989; Baxter 1995;
     Baxter et al.1999; Oliver 2001), while in some smaller streams all pockets of suitable looking substrate
     have been used".
   - hagen_weber2019 p. 19: groundwater areas gave higher egg-to-alevin survival in the Halfway River (Baxter
     1997) (incubation).
   - USFWS 2015 p. 6: embryos survived better in areas of groundwater upwelling (Baxter and McPhail 1999)
     (incubation).
3. **The two USFWS documents share an ancestor.** The 2015 plan's "Preferred spawning habitat consists of
   low-gradient stream reaches with loose, clean gravel (Fraley and Shepard 1989)" is the 2010 rule's
   sentence. It is one claim, so there is one gradient row, from the 2010 rule (which gives page cites).
4. **The existing `none` rows for `spawn_gradient_max`/`spawn_gradient_min`.** Neither US document gives a
   number. The 2010 rule says why (p. 63931): "attributes such as stream flow and substrate size and
   composition are influenced by stream order and gradient. Accordingly, we are unable to define a conclusive
   upper and lower range of conditions for specific PCEs". Add both documents to those rows' lists of
   sources searched.
5. Citation keys `PENDING_usfws2015` and `PENDING_usfws2010` are placeholders. 2010 rule pages are Federal
   Register pages (PDF page 1 = 63898). 2015 plan pages are the printed footer numbers (PDF page 20 = p. 5).

## Contradictions with existing rows

- **Spawning onset temperature, 9 vs 10 C.** *(Corrected by the parent after review round 2.)*
  - `hagen_weber2019` (p. 22) gives 9 C and cites Fraley and Shepard 1989.
  - `mcphail_baxter1996` (p. 15) gives 9 C and cites McPhail and Murray 1979 and Weaver and White 1985, not Fraley and Shepard.
  - The 2010 rule (p. 63930) says Fraley and Shepard (1989, p. 137) reported spawning "initiated when water temperatures dropped below 10 °C".
  - Metolius (Riehle 1993) observed temperatures below 9 C at onset in every spawning stream.

  Which number Fraley and Shepard gave is not settled here.
- **Who reported 4-10 C.** The 2010 rule gives "Goetz (1989, pp. 22–32) reported a spawning temperature
  range from 4 to 10 °C". The 2015 plan (p. 6) attributes 4-10 C to Howell et al. 2010 and gives Goetz 1989 a
  "preferred" 5-9 C.
- **Redd depth.** `hagen_weber2019` gives 24-58 cm (reviewed in Baxter and McPhail 1996). The existing
  `roberge_etal2002` p. 80 row cites the same review for 30-60 cm. The velocities agree (0.14-0.52 m/s).
- **Steep small streams.** The `hagen_etal2015` p. 33 row (expert: small, steep, turbulent 2-5 m streams
  are "not optimal" for spawning) is the authors' view. The `hagenj_spendlowi_2019` row records
  large-bodied spawners using "shorter, steeper tributaries" near the reservoir (Big Creek, 26 redds). That
  is not a contradiction: those populations are smaller, as the earlier row predicts, but they exist. The
  2010 rule's resident row (steeper, smaller headwater streams) agrees with `mcphail_baxter1996` p. 12,
  because it is that sentence.
- **Existing `roberge_etal2002` p. 79 row ("presumably in high gradient").** None of the new sources supports
  high-gradient spawning for migratory fish. The 2010 rule and 2015 plan both say low gradient. Steeper
  streams appear only for residents (2010 rule) and for small migratory populations (Hagen and Spendlow
  2019).

## Per source

### retzer1989SpawningRearing: no rows
I read the whole report (35 printed pages, tabular). It assesses spawning and rearing habitat of Williston
tributaries from helicopter video taken in August 1988, with no ground samples (p. 1). Its ratings are
generic (gravel, turbidity, side channels), not species-specific. Its "DV" records (Dolly Varden, at the time
the name for Williston bull trout) are second-hand from Bruce and Starr 1985 (Ref. A) and the 1977-81
biophysical surveys (Ref. B), e.g. "Lafferty C ... is important to spawning DV", ripe DV in Nabesche R2. It
gives no gradient, width, depth, substrate size or elevation for any DV spawning reach: the gradient words
are only "low/steep/increased". No row: reach ratings from video, without the species, would misstate the
evidence.

### Metolius (Oregon, OCR scan): 4 rows
I read the full OCR (48 PDF pages). Found:
- Spawning in "small, cold water tributaries" (PDF p. 5).
- Spawning gravel dominated by 8-32 mm, and fines <6.4 mm 22-33 % (p. 36).
- Summer temperatures in spawning and rearing streams strongly influenced by cold springs, and below 9 C
  before spawning in every stream (p. 36).
- No cold spring areas in the Crooked River, and no spawning there (p. 6).
- Spawning at Heising Spring and a spring-influenced area of the mainstem (p. 28).

Not found: any gradient, width, depth, velocity or elevation for spawning reaches. Timing (15 Aug-1 Oct,
p. 17) was not drafted, since timing was not asked for. The existing rearing row (p. 16) is not touched.

### RockyCreekbulltroutcumulativeeffectsmodelthreatsummary (Alberta): no rows
I read the full text (32 pp.). It is a Joe cumulative-effects model of stressor-response curves (sediment,
crossings, angling, temperature). Nothing locates spawning habitat. The only habitat-size statement is on
p. 14, for the road-crossing stressor: "Only Order 2 and 3 streams were considered because Bull Trout occur
infrequently in Order 1 streams". That is about occurrence, not spawning, so no row here (it could become a
`rearing` stream_order row). p. 22 lists groundwater input and substrate as "natural limitations", with no
values.

### macpherson_etal2024Prioritizingbull: no rows
I read the full text. It is the same Joe framework in a BACI test in Rocky Creek. Spawning is mentioned only
for the sediment effect on redds (p. 14 PDF). It has no habitat values.

### hagen_etal2015Criticalhabitats: 2 rows
Re-read pp. 8-9 (life history), 21-25 (methods) and 30-33 (results).
- Elevation (fn. 11, p. 22): spawning is tied to cold systems draining higher elevations, and the Pack River
  was rated low potential for spawning because its drainage is mostly low elevation.
- Migration (p. 9): juvenile densities are much higher above chutes and bedrock canyons.
- Not used:
  - The calibration sites (p. 30) span 3.5-18 m wetted width and 0.12-2.9 m3/s, but they include sites with
    zero redds. They are a sampling frame, not spawning habitat.
  - Table 2 (p. 31) has discharge at survey (September low flow, not MAD) but no width column in the text
    layer.
  - Table 3 correlations (p. 32) are with aerial count efficiency, not habitat use.
- No redd-site gradient, depth or substrate values.

### hagen_etal2020CriticalSpawning: 1 row
Re-read pp. 31-50. p. 49: redds of large-bodied migratory BT found in streams as small as 2 m wetted. Not
used:
- p. 46: the low elevations of accessible habitat are offered as one of three possible reasons for the lack
  of redds in small Parsnip Reach tributaries. It is a hypothesis, and the hagen_etal2015 elevation row
  covers the idea.
- p. 37: passage through the Ospika canyon, shown by redds above it. The table lists chutes, but the text
  gives no gradient, so it was left out in favour of the hagen_etal2015 migration row.
- p. 40: GRAVEL 15-60 % and OH 2-26 % are the ranges at calibration reaches for detection modelling, not
  habitat selection.

### hagen_weber2019Limitingfactorsa: 5 rows
Re-read pp. 19-22, 26-27, 40-41, 71-73, 82, 89-90.
- p. 22: redd depths and velocities (4 rows).
- p. 90: substrate qual.

Not drafted:
- p. 22, aggrading/groundwater (see flags).
- p. 22, "Bull Trout generally do not appear to spawn in large mainstem reaches". Same claim as the
  existing `mcphail_baxter1996` stream_order qual row, but Williston-specific; add it if wanted.
- p. 22, 9 C onset and 25-60 mm substrate: already in the table.
- p. 41: Moody et al. 2007 restrict instream structures to streams ≤2 % gradient. That is a restoration
  criterion, not habitat use.
- p. 82, aerial method unsuitable for streams <5 m wide with steep gradients: about survey method.

### hagen_sary2023BullTrout: 2 rows from one sentence
Re-read pp. 3-4, 10. p. 4: redd distribution is related to temperature (or elevation), migration barriers
and alluvial sections with gravel accumulation and groundwater exchange. One `elevation` row and one
`valley_width_index` row. Not used:
- p. 3, 5th-6th order: already in the table.
- p. 10, floodplain groundwater areas: a management recommendation.

### hagenj_spendlowi_2019BullTrout: 1 row
Re-read pp. 18-20, 28-31. p. 30: smaller populations of large-bodied spawners in shorter, steeper tributaries
near the reservoir; p. 18: Big Creek is "relatively steep, high energy". Not used:
- p. 31, Chris Schell Consulting 2002: small-bodied residents in very small streams, maturing at 104 mm.
  Spawning there is implied, not stated.
- p. 30: unembedded cobble substrate. hagen_weber2019 p. 90 restates it more directly and that row is used.
- p. 20: the two steeper, more turbulent streams had the lowest aerial detection (method, not habitat).

### PENDING_usfws2015 (recovery plan): 3 rows
Read pp. 4-6 (life history), 15 and 25. Rows:
- p. 5: spawning areas and the coldest streams.
- p. 6: preferred 5-9 C.
- p. 6: Swan River redd abundance and bounded alluvial valley reaches.

Not used:
- p. 6, low-gradient preference: duplicate of the 2010 rule.
- p. 6, "generally range from 4 to 10" C (Howell et al. 2010): the 2010 rule's row covers 4-10.
- p. 6, migrations up to 250 km: no variable.
- p. 25, "low-gradient stream segments with stable channel structure": a spawning-and-rearing requirement
  that restates p. 6.
- p. 15, brook trout effects worst in small, low-gradient resident streams: not spawning.

The plan gives no numeric gradient, width, depth or elevation.

### PENDING_usfws2010 (75 FR 63898): 5 rows
Read pp. 63928-63932 (background, PCEs) and searched the whole text for gradient, steep, headwater,
resident, order and width.

Rows:
- p. 63929: resident headwater streams are smaller and steeper.
- p. 63930: preferred low-gradient reaches.
- p. 63930: onset below 10 C (Flathead).
- p. 63930: 4-10 C (Goetz).
- p. 63930: incubation 1.2-5.4 C.

Not used:
- PCE 5, 2-15 C: all stages, not spawning.
- PCE 6, substrate: no values; "size and amounts of fine sediment ... will likely vary from system to
  system".
- PCE 4, "variety of depths, gradients, velocities": no values.
- The unit descriptions name streams but give no habitat values.

No numeric gradient, width or elevation anywhere in the rule.

## Meaning audit, one line per row (CSV order)

1. Metolius PDF p. 5, channel_width qual. "Most bull trout ... spawned ... in small, cold water tributaries":
   migratory fish (adfluvial and fluvial); stage spawning; no value. OK.
2. Metolius p. 36, substrate 8-32 mm. Core samples in spawning areas; "dominated by" is the dominant size,
   so `dist` at site scale, not a preference. The paragraph's citation is Riehle 1993. OK.
3. Metolius p. 36, temperature max 9. An observation in all monitored spawning streams before onset, so
   `dist`; Riehle 1993. OK.
4. Metolius p. 36, temperature qual. The streams used for spawning and rearing are spring-influenced; a
   report observation; no value. OK.
5. hagen_etal2015 p. 22, elevation qual. The footnote is general ("usually"). It was applied to rate the
   Pack River low; network scale; no value. OK.
6. hagen_etal2015 p. 9, migration gradient qual. The evidence is juvenile densities above chutes and
   canyons, citing Bustard and Schell 2002 and Decker and Hagen 2007. Spawning above difficult passage is
   inferred by the authors ("suggesting"), and the note says so. No value. OK.
7. hagen_etal2020 p. 49, width min 2 m wetted, expert. The authors' experience of the smallest stream with
   redds of large migratory fish; a wetted width. Not independent of the 2015 row. OK.
8. hagen_weber2019 p. 22, depth 0.24-0.58 m. Range of means at redd sites, from a review (Baxter and
   McPhail 1996); site scale. Gate unit issue (flag 1). OK in meaning.
9. hagen_weber2019 p. 22, depth max 0.9 m, `max_obs`. "Appear to always be less than 90 cm" is an observed
   upper bound across studies. Gate unit issue. OK in meaning.
10. hagen_weber2019 p. 22, velocity 0.14-0.52 m/s. Range of means at redds, from the review. OK.
11. hagen_weber2019 p. 22, velocity max 0.65 m/s, `dist`. "Typically ... or less" is typical, not absolute.
    OK.
12. hagen_weber2019 p. 90, substrate qual. Describes where the largest migratory populations spawn (named
    reaches); reach scale; no value. OK.
13. hagenj_spendlowi_2019 p. 30, gradient qual. Large-bodied spawners in steeper tributaries, as smaller
    populations; no value. Region: the three named watersheds. OK.
14. hagen_sary2023 p. 4, elevation qual. "Proxies like elevation" for temperature; a general statement with
    four cited studies (Montana and BC). OK.
15. hagen_sary2023 p. 4, valley_width_index qual. "Alluvial stream sections" is read as unconfined; the note
    states that inference. OK.
16. usfws2015 p. 5, temperature qual. "Spawning areas are often associated with ... the coldest streams";
    range-wide review; several citations. OK.
17. usfws2015 p. 6, temperature 5-9 `pref`. The plan's "preferred spawning habitat", citing Goetz 1989, in
    late summer to early fall. OK.
18. usfws2015 p. 6, valley_width_index qual. A Swan River correlation of redd abundance with the extent of
    bounded alluvial valley reaches. Its citation is questioned in the note. OK.
19. usfws2010 p. 63929, resident gradient qual. The populations are resident (all stages, in SR areas year
    round); the sentence is McPhail and Baxter 1996. Stage `spawning` rests on "inhabit the spawning and
    rearing areas year round". OK.
20. usfws2010 p. 63930, gradient qual. "Preferred spawning habitat ... low-gradient" (Fraley and Shepard
    1989, Flathead). OK.
21. usfws2010 p. 63930, temperature max 10. Flathead onset of spawning (Fraley and Shepard 1989). OK; it
    conflicts with the 9 C attributions (above).
22. usfws2010 p. 63930, temperature 4-10 `dist`. Goetz's reported spawning range; the rule adds that the
    range could be wider. OK.
23. usfws2010 p. 63930, incubation 1.2-5.4 `dist`. Temperatures reported for incubation (Fraley and Shepard
    1989; McPhail and Baxter 1996), not an optimum. OK.


> Parent, after review round 2 (`review-p12-round2.md`): corrected in the CSV notes for rows 490, 500, 501, 502, 505 and 508; the 9 °C attribution is corrected above.
