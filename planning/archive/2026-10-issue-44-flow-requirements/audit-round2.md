# Meaning audit, round 2 (#44): the round-1 fixes, and the mixed groups

Scope: the 77 rows that round 1 touched or added (current data rows; data row N is file line N + 1), read against
the source page, plus every cross-reference ("data row N", "previous row", "the X row") in rows 687-1014. The source
text was read for each row, beyond the quoted sentence. The Bjornn & Reiser Table 4.10 cell behind row 783 was read
on the rendered page (`img/t410d-24.png`): steelhead age 0, Everest and Chapman (1972), depth <15 cm and velocity
<15 cm/s. That confirms round 1's addition to the note.

## Errors in the re-audited rows

### 791-802 (12 rows, Tennant 1976): the round-1 note cites the wrong recommendation
- **What is wrong:** every note ends "(p. 10, Recommendations, item 4)". "Request 'instantaneous flows'" is item **1**.
  Item 4 is "Justify only that portion of a stream flow required to fulfill specific instream needs".
- **Evidence:** `tennant1976InstreamFlow.layout.txt`, PDF page 5 (printed p. 10): "1. Request "instantaneous flows"
  to prevent flow releases ... 2. Recommend that dual or multiple outlets ... 4. Justify only that portion ...".
- **Fix:** in all 12 notes, replace `(p. 10, Recommendations, item 4)` with `(p. 10, Recommendations, item 1)`.
  `metric = instantaneous` stands: item 1 and item 9 ("minimum instantaneous stream flow regimens") both support it.
  The same "item 4" is in `drafter-brief.md` (the struck-through `seasonal_mean` line) and in
  `audit-ps-round1.md`. Correct the brief.

### 849, 850 (USFWS 2007, spring-run chinook spawning depth): the round-1 fix contradicts p. 24
- **What is wrong:** round 1 wrote "the deepest redd in the HSC sample was 3.0 ft (p. 26)", and on 850 "The optimum
  lies beyond the deepest redd in the HSC sample". Page 26 says something else. The deepest redd *in our study
  sites* (the six RIVER2D sites) was 3.0 ft. The HSC sample itself reached 7.0 ft, so the 6.0-6.2 ft optimum lies
  inside it. The sentence added to 850 is false.
- **Evidence:**
  - p. 24: "The spring-run salmon HSC data had depths ranging from 0.8 to 7.0 feet deep" (180 redds, p. 21-22).
  - p. 26: "Since the deepest spring-run redd in our study sites had a depth of 3.0 feet, we were unable to apply the
    Gard (1998) depth correction method."
  - p. 36: "7.0 feet (the depth of the deepest spring-run Chinook salmon redd)", and "The spring-run Chinook salmon
    spawning depth logistic regression had its first maximum at 2.1 feet (Figure 5)".
- **Fix, 849 `note`:** "Figure 5, spring-run chinook spawning depth HSC, from logistic regression of redd and
  non-redd locations: non-zero suitability 0.8-7.0 ft, so the zero edges lie at those ends; the HSC redd depths span
  the same 0.8-7.0 ft (p. 24). The Gard (1998) correction for low availability of deep water could not be applied,
  because the deepest spring-run redd in the six study sites was 3.0 ft (p. 26)."
- **Fix, 850 `note`:** "Figure 5, spring-run chinook spawning depth HSC: optimum 6.0-6.2 ft. HSC redd depths reach
  7.0 ft (p. 24); the deepest redd in the six study sites was 3.0 ft (p. 26). The sensitivity analysis gives the
  depth regression's first maximum as 2.1 ft (p. 36)."

### 807, 808, 822, 823 (30-200 % MAD, coded `min` with both values): misleading to any reader that follows the reader's contract
- **What is wrong:** `knw_literature_read()` documents that "a bound must sit on its value: `min` on `value_min`".
  A consumer that reads `bound = min` therefore takes 30 % MAD as the minimum. That is the least protective end:
  it is the minimum only for the largest streams, and the smallest streams need about 200 %. `value_max = 200` has
  no meaning under `min` in that contract. Only a reader of the note gets the row right. The note is accurate, so
  the defect is the field coding. It is the same misreading round 1 fixed in `range`, moved to the other column.
- **Evidence:** Ptolemy & Lewis p. 30, "range from 30 or 200% but vary dependent on stream size"; Hatfield Table 5
  pairs "30-200%" with the equation; `pkg/R/literature.R` line 116 (bound sits on its value).
- **Fix (a decision for Al; recommendation first):**
  - (a) Recommended: `bound` blank on all four, keep `value_min = 30` and `value_max = 200`. A blank bound already
    means "neither value is a limit" (CLAUDE.md, interior breakpoints). These group-code rows fill no grid cell, so
    the grid is unaffected. The notes stand. On 807, drop the second "(equation in the qual row)", which round 1
    left duplicated.
  - (b) Delete the four valued rows and keep the two `qual` rows (809, 824), which carry the equation.
  - (c) Keep `min`, and accept that only the note carries the meaning.
- **Related, advisory:** 825 and 837 (summer steelhead passage, "50-100%mad or up to 27.8 cms") are coded `range`.
  "Up to" reads as the most that is needed, not an upper limit. Whatever is chosen for the 30-200 rows, apply the
  same reading here.

### 983, 985, 987 (AMEC Table 14, spawning and summer-rearing IFN): `monthly_mean` is inferred
- **What is wrong:** round 1 set `metric = monthly_mean` from p. 30, "The IFN were set as the minimum monthly flows
  required to protect fish". That phrase does not say whether the statistic is a mean over the month or a minimum
  within it. The IFN are derived against a different statistic, the stanza's "mean annual 30-day low flow" (p. 30,
  p. V, p. 82). The brief says `unstated` whenever the source does not say, and never to infer one.
- **Evidence:** p. 30 (between the "Page 29" and "Page 30" footers): "minimum monthly flows required to protect fish
  ... during each biologically relevant stanza". Also "IFN were set as the flows required to provide at least 90% of
  the habitat available for fish under baseline conditions". Section 4.8: "Constant flows were defined for the FSS
  outfall within each stanza".
- **Fix:** `metric = unstated` on 983, 985 and 987. Keep the p. 30 quote in each note, and append: "p. 30 does not
  say whether a 'monthly flow' is a mean or a within-month minimum."
- **989, 990 (winter) stand at `monthly_mean`:** p. 56 says "baseline March flows, the lowest mean monthly flows for
  the winter stanza", and p. 83 says "baseline mean March flows". Both name a monthly mean. The note discloses the
  conflict with p. 30 (30-day low flow). One cosmetic change: the quoted words are p. 56's, while p. 83 reads
  "baseline mean March flows". Change "(p. 56; p. 83)" to "(p. 56; p. 83: 'baseline mean March flows')".

### 928 (CT fry <1 cm/s, Ford p. 72): the round-1 note misstates what Ford says
- **What is wrong:** the note says "Ford's westslope chapter cites Moore and Gregory (1988b), Cascade Mountains
  streams, cutthroat not identified as westslope". In fact Ford attributes the same study to westslope cutthroat
  (p. 71: "After emergence westslope cutthroat trout have been observed to immediately take up positions in stream
  margin habitat ... (Moore and Gregory 1988b)") and to interior cutthroat (p. 71: "Moore and Gregory (1988b) also
  found that interior cutthroat fry less than 30 mm long ..."). What is not identified is the subspecies of the
  velocity sentence itself (p. 72) and of the study. The reference list title is "cutthroat trout fry (Salmo clarki)
  in Cascade Mountain streams".
- **Fix, `note`:** "Fry over 30 mm (fry under 30 mm were in velocities too low to measure). Moore and Gregory (1988b)
  studied 'cutthroat trout fry (Salmo clarki) in Cascade Mountain streams' (Ford's reference list); this sentence
  names no subspecies. Ford calls the same study's fish westslope and interior cutthroat on p. 71, so the subspecies
  is uncertain and the row is coded generic cutthroat. The 2004 WCT account (p. 6) restates the value for westslope
  cutthroat, citing Ford." `species_code = CT` stands.

### 889 (BT spawning depth 0.15-0.84 m, Ford Table 8): the round-1 note claims more than Table 10 shows
- **What is wrong:**
  - The note says the span "is the extremes of Table 10's (p. 125) depths over redds". Table 10's column is "Mean
    water depth over redd (m)": 0.84 is the upper end of Meadow Creek's *mean* (0.73-0.84), not a redd depth.
  - Ford never says Table 8 was taken from Table 10. The match is an inference, and the note states it as fact.
  - The recode to `range` and `dist` is defensible and stays.
- **Fix, `note`:** "Table 8 (observed habitat use) labels it 'preferred spawning depth'. The span matches the ends of
  Table 10 (p. 125), mean water depth over redds by study: 0.15 m is the low end of the Flathead River range (mean
  0.28, range 0.15-0.35) and 0.84 m the high end of Meadow Creek's mean of 0.73-0.84 m (Kootenay Lake). Ford does not
  say Table 8 was compiled from Table 10. Coded as an observed span, not a preference."

### 742 (Raleigh Fig. 12 depth): `region` says "Not stated", but p. 54 states it
- **What is wrong:** `region = Not stated (Vincent-Lang et al. 1984)`. Page 54: "Vincent-Lang et al. (1984) collected
  data (n = 262) from Portage Creek (n = 137) and the Indian River (n = 125), tributaries of the Susitna River in
  Alaska". Page 54 also says the depth curve "was modified based on the assumption that depths from 48.8 to 122.0 cm
  (1.6 to 4.0 ft) will not limit spawning". The note's "paired with the Vincent-Lang et al. (1984) velocity curve"
  undersells that the depth curve is theirs.
- **Fix:** `region = Portage Creek and Indian River (Susitna River tributaries), Alaska (Vincent-Lang et al. 1984)`.
  `note`: "Figure 12 depth curve (labelled category one) from Vincent-Lang et al. (1984), modified on the assumption
  that depths of 48.8-122.0 cm do not limit spawning (p. 54): SI 0 at and below 15.2 cm, 1.0 from 30.5 cm. Quote is
  the cm and ft columns. Numerically identical to the Figure 5 category-one curve (data row 731)."
- **The same defect in nine rows outside this scope:** pp. 53-54 name the streams for every category-two curve, and
  each row says "Not stated":
  - 735: Little North Santiam, Molalla and South Fork McKenzie rivers, Oregon (Sams and Pearson 1963; spring chinook).
  - 736: Humbug, East Humbug and Moon creeks and Tillamook River, Oregon (Sams and Pearson; fall chinook).
  - 737, 738: Battle Creek, California (Vogel 1982).
  - 739, 740: upper Yakima and American rivers, Washington (Stempel 1984).
  - 741: as 742.
  - 743, 744: upper Skagit River, Washington (Kurko 1977).

## Errors found outside the re-audited rows (consequences of fixes, or found by the cross-reference check)

### 760 (Raleigh 1986, base flow ≥50 % "excellent", coded `min`): inconsistent with round 1's recode of 961, 963
- **What is wrong:** round 1 recoded Ford's "greater than 55% ... excellent, 25 to 50% fair, less than 25% poor"
  (961, 963) from `min` to `optimum`, as the best of three classes. Raleigh et al. 1986 p. 5 states the same
  three-class scheme (both are adapted from Tennant): "50% ... excellent for salmonid production, ... 25% to 50% ...
  fair to good, ... <25% ... poor". 760 stays `min`. The table now codes one scheme two ways. Tennant's "Excellent"
  (793, 794) is a different case and rightly stays `min`, because Tennant tabulates a separate "Optimum range"
  above his classes.
- **Fix:** 760 `bound = optimum` (value_min 50, value_max blank). Note: prefix "Excellent class (best of three)." and
  keep the rest. 761 (`min` 25) stands, matching 962 and 964.

### 876, 886 (BT spawning, Hagen & Weber p. 22 and Roberge p. 80): notes point at rows that do not exist
- **What is wrong:** 876 says "Same sentence as the velocity rows for this page". 886 says the 0.14-0.52 m/s span "is
  the one in the hagen_weber2019 row (14-52 cm/s) ... so it is not repeated here". Neither the tc draft nor the
  table has ever held a Hagen & Weber velocity row (checked `draft-tc-evidence.csv` and the round-1 diff, which
  deleted no Hagen & Weber row). So the BT spawning velocity of 14-52 cm/s (study means) and "typically 65 cm/s or
  less" is in the table nowhere, while two notes say it is.
- **Fix:** append two rows:
  - `BT,spawning,,velocity,,range,14,52,cm/s,,dist,BC (review),hagen_weber2019Limitingfactorsa,22,"<same quote as 876>",text,site,Baxter and McPhail 1996,"Range of study means of velocity at redds, as written. Same sentence as the depth rows for this page.",`
  - `BT,spawning,,velocity,,max,,65,cm/s,,dist,...,"Redd velocities 'are typically 65 cm/s or less': an upper value of redd velocities reviewed, not a strict limit.",`

  Run 0280 on both. Alternatively, rewrite the two notes so they claim no such row.

## Re-audited and correct (no change)
- **696-702, 704:** match pp. 94-95. "Usually at the upstream edge" and "most velocity criteria are for 0.6 x depth"
  are p. 95's words. 704's "excavated pit, not the upstream edge" is p. 95.
- **731, 757, 759, 775:** the cross-references resolve: 731↔742, 757↔759, 775→970/971.
- **783:** the round-1 addition matches Table 4.10, confirmed on the rendered page.
- **787, 788, 789:** match Neuman & Newcombe PDF p. 6. `unstated` is right; the page names no statistic.
- **848:** matches DFO p. 2.
- **853-856, 859-863, 1007-1013:**
  - Every twin cross-reference resolves: 853↔1007, 854↔1008, 855↔1009, 856↔1010, 859↔1011, 860↔1012, 861↔1013,
    862↔863.
  - The twins copy species-neutral fields correctly. `species_code = RB`, with `life_history_form` blank, because
    the source says "steelhead/rainbow trout" and not "resident".
  - Cosmetic: 1011-1013 say "the curve is for steelhead/rainbow trout", but they are WUA flows. "The WUA is for" would
    be exact.
- **870-875:** the Ash p. 92 general list and the Sinmax p. 98 October 160 % match the charts. The coho notes'
  earlier sentence "gives no coho standard" is qualified by the appended sentence. Acceptable.
- **879:** the "previous row" (878) resolves after renumbering. `expert` fits "suggested upper limit".
- **891, 892:** Ford names no stream. McPhail & Baxter place the study in Mackenzie Creek, with juveniles in pools
  <25 cm/s and in runs >50 cm/s by August.
- **902:** matches Nechako PDF p. 89 ("Rearing (adult and juvenile) ... 55", April-November) and Table 5.
- **912:** matches Hubert p. 2.
- **944:** matches Beecher Fig. 13a ("Irely (4) and Skookum (3) creeks").
- **961, 963:** match Ford p. 53. See 760 above for the consistency fix.
- **970, 971, 1014:** the cross-references resolve (970↔1014, 971→775). `resident` follows Beecher's "resident rainbow".
- **989, 990:** see the AMEC entry above.
- **1000:** text correct. Cosmetic: the note ends in a trailing space.

## The 34 mixed groups (same source and page, kind, metric or unit differing)

| # | group (rows) | explained? | why |
|---|---|---|---|
| 1 | WCT 2004 p. 5 (926-927) | yes | Depth in m, velocity in m/s, as written. |
| 2 | AMEC p. 57 (982-990) | **partly** | Kind: two table columns, the flow producing maximum habitat (`hsi` optimum) and the recommended IFN (`expert` min). Metric: winter IFN `monthly_mean` follows p. 56 and p. 83. The spawning and summer IFN `monthly_mean` (983, 985, 987) is inferred; fix to `unstated` (above). |
| 3 | Bjornn & Reiser p. 84 (687-695) | yes | Table 4.1 depth (m) and velocity (m/s). |
| 4 | Bjornn & Reiser p. 89 (706-707) | yes | One sentence: "depth (18 cm) and velocity (0.3-3.0 m/s)", units as printed. |
| 5 | Bjornn & Reiser p. 94 (703-705) | yes | Nechako: depths in m, velocity over the pit in cm/s, as printed. |
| 6 | Bjornn & Reiser p. 95 (696-702) | yes | Table 4.5 columns: depth (cm), velocity (cm/s). |
| 7 | DFO 2019 p. 17 (929-932) | yes | Table 2 depth (m) and velocities (m/s). |
| 8 | Ford p. 47 (958-959) | yes | One sentence, two statements: "found in ... less than 30 cm/s" (`dist` max) and "prefer velocities less than 8 cm/s" (`pref` optimum). |
| 9 | Ford p. 52 (954-957) | yes | Raleigh et al. 1984's suggestion (`expert`) against the Gerrard stock's observed velocities (`dist`). Depth in m, velocity in cm/s. Advisory: 955 codes "in water depths between 0.15 and 2.5m" as an optimum, but the sentence calls only the velocity range optimal. `range` would be the literal reading. |
| 10 | Ford p. 77 (933-934) | yes | Mean depths (cm) and mean velocities (cm/s), one sentence. |
| 11 | Ford p. 78 (940-943) | yes | Observed spans (`dist`) and Hickman & Raleigh's "estimated ... optimal range" (`expert`). Depth in cm, velocity in cm/s. |
| 12 | Hagen & Weber p. 19 (878-880) | yes | Fry preference (`pref`), the fry "suggested upper limit" (`expert`, round-1 fix), and the older-juvenile preference (`pref`). |
| 13 | Hatfield 2002 p. 41 (819-825) | yes | 824 is a `qual` row (equation; no metric or unit). 825 is another Table 5 line. All valued rows are `expert`, `unstated`, percent MAD. (The `min`/30-200 coding is the separate error above.) |
| 14 | Hubert p. 17 (913-914) | yes | Velocity in ft/s and depth in ft, from two sentences. |
| 15 | Hubert p. 18 (915-919) | yes | Figure 1 depth (ft) and velocity (ft/s) curves. |
| 16 | Keeley & Slaney p. 10 (867-868) | yes | "10 cm • s-1 and 10 cm deep": velocity and depth. |
| 17 | Levy & Slaney p. 12 (720-724, 938-939, 952-953) | yes | Table 6 depth (cm) and velocity (cm/s) columns. |
| 18 | McPhail & Baxter p. 6 (881-883) | yes | As printed: 56.5 cm, 0.35 m-s, 30.5 cm. |
| 19 | Neuman & Newcombe p. 6 (787-789) | yes | Different methods on one page: the Oregon Fish Commission pool velocity (CO, `pref`, ft/s) and the Okanagan Montana-method flows (FISH, `expert`, percent MAD, `unstated`). |
| 20 | Ptolemy & Lewis p. 22 (812-817) | yes | Optima given in m3/s and in percent MAD as written. 816 and 817 cross-reference each other. |
| 21 | Ptolemy & Lewis p. 30 (807-809, 818) | yes | 809 is the `qual` equation row. 818 is the passage depth (cm), a different variable. |
| 22 | Raleigh p. 10 (756-757) | yes | Everest & Chapman's densest fry (`dist`) against juveniles "tended to select" (`pref`), two sentences. |
| 23 | Raleigh p. 34 (729-732) | yes | Figure 5 velocity (cm/s) and depth (cm) curves. |
| 24 | Raleigh p. 40 (737-738) | yes | Figure 10 velocity and depth. |
| 25 | Raleigh p. 41 (739-740) | yes | Figure 11. Velocity in ft/s because the cm/s column splits '121. 9'; the note says so. |
| 26 | Raleigh p. 42 (741-742) | yes | Figure 12 velocity and depth (region error above). |
| 27 | Raleigh p. 43 (743-744) | yes | Figure 13 velocity and depth. |
| 28 | Raleigh p. 7 (751-755) | yes | The authors' conclusions (`expert`) against Andrew & Geen and Divinin observations (`dist`). Velocity in m/s, depth in m. |
| 29 | Roberge p. 67 (781-782) | yes | One sentence: velocity (m/s), depth (m). |
| 30 | Roberge p. 80 (886-888) | yes | Spawning depth observed (`dist`), "Velocities > 0.7 m/s are unsuitable" (`expert`), juvenile "preferred" (`pref`). Units as written (dangling note in 886 above). |
| 31 | Stewart p. 14 (903-906) | yes | Units as written in two sentences. |
| 32 | Stewart p. 17 (908-910) | yes | Use (`dist` max 80), "strong preference" (`pref`), Alaskan occupancy (`dist`), three sentences. |
| 33 | USFWS p. 59 (858, 861, 1013) | yes | 858: "flows exceeding 600 cfs ... are needed" (`expert` min). 861 and 1013: a recommended flow judged to give >91 % of maximum WUA (`hsi` optimum, a WUA band). Different statements. |
| 34 | Warkentin p. 8 (863-864) | yes | Two estimates: 36 % MAD (no fishing) and 17.2 m3/s (30 % harvest), each in the unit written. |

### Same-page groups with mixed `bound` (same species, variable and stage)

There are 45 such groups among rows 687-1014 (non-`none`, non-`qual`). All are explained:
- **27 are one curve or one table giving zero edges or limits and an optimum:**
  - Raleigh Fig. 5.
  - USFWS Figs. 5-8 and their RB twins.
  - Beecher Figs. 9b, 10a, 10b, 13a, 13b, 14b, 15a, 15b and 16b.
  - Hubert Figs. 1 and 3.
  - Tennant Table 1, where the class levels are `min` and the explicit "Optimum range" is `optimum`.
  - Ford p. 53 classes.
  - AMEC Table 14, maximum-habitat flow against IFN.
- **18 are different statements, studies or ages on one page:**
  - Bjornn & Reiser p. 94 (shallowest redd site against pit depths).
  - Bjornn & Reiser p. 129: ST from Sheppard & Johnson and Stuehrenberg; CO from Thompson, Sheppard & Johnson and
    Nickelson & Reisenbichler.
  - Raleigh p. 7 and p. 11 (usable against optimal).
  - Roberge p. 65 (nose velocities in pools against the highest-density velocity).
  - Ptolemy & Lewis p. 29 (the 10 % threshold for all channels against the confined-channel optimum).
  - Hatfield p. 92 ST (45 % winter and smolt passage against 50-100 % summer passage).
  - Hagen & Weber p. 22 and p. 19.
  - Ford p. 120 (pools, runs, focal velocities), p. 72 (fry against age 1+/2+), p. 78, p. 52 and p. 47.
  - Stewart p. 14 (general against artificial channels) and p. 17.

None is an inconsistency. Two flagged codings sit among them: the 50-100 % `range` (825, 837; advisory under the
30-200 entry) and 760 against 961/963 (cross-source; above).

## Mechanisms
1. **A fix paraphrased the source into a stronger claim.** "Study sites" became "HSC sample" (849, 850), "minimum
   monthly flows" became `monthly_mean` (983-987), "mean depth over redd" became "depths over redds" (889), and "this
   sentence names no subspecies" became "not identified as westslope" (928). Each paraphrase was then reasoned from
   as if it were the source.
2. **A citation locator was carried without being re-read.** Tennant's "item 4" came from the round-1 audit and went
   into 12 notes and the brief; it is item 1.
3. **A recode was not propagated to the sibling that shares the scheme.** 961 and 963 became `optimum`; 760, the
   same Tennant-derived three-class scheme in another document, did not.
4. **Notes promise rows that were never written.** 876 and 886 refer to a Hagen & Weber velocity row the draft never
   held. Round 1 checked rows against pages, not notes against rows.

re-audited 77 rows, 24 with errors; groups explained 33 of 34
