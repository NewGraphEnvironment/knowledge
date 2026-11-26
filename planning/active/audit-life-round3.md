# Meaning audit, round 3: `research/grayling_life_history.md`

Scope: every sentence the round-2 fixes changed or added (`fixes-life-round2.md`, findings 1 to 29), each claim read
against its page in `<scratchpad>/txt/<key>.txt`, the OCR cache (`data/rag/ocr/71074d55….txt` Stewart et al. 1982,
`38cc13a4….txt` Stuart and Chislett), and the evidence rows the fixes name; then each changed sentence's paragraph and
bold lead read for anything the fix made untrue around it. Line numbers are the file's as of this audit.

6 findings: 2 moderate, 4 minor. Four of the six sit inside a round-2 fix (1, 2, 3, 5); two are older text around a
fix (4, and the second and third lines of 2).

## Findings

### 1. (moderate, inside fix 8) L572–575: the bull trout and burbot are not "fry", and the 12 cm is not "where fry were caught"

Text: "found grayling fry, like the bull trout and burbot fry caught with them, in shallow, slow water ... (the 12 cm
and < 0.1 m/s are given for the three species together, where fry were caught, not limits; ...)".

Blackman 2004 p. 7, the page the quote comes from, says the opposite of "fry" for the other two species: "All the
grayling captured were young of the year but the burbot and bull trout included one and possibly two year old fish
(Table 1 & Fig. 7). I was unable to separate the habitat point data for the different age classes of bull trout and
burbot in the Table River so the data was pooled." The quoted sentence itself reads "The grayling fry, bull trout and
burbot" (fry attached to grayling only), and the next sentence says the Table burbot "did select deeper water" because
older fish were pooled in. Table 1 (p. 7) gives Anzac bull trout 30–186 mm and burbot 55–220 mm. The abstract (PDF page 3,
no printed number; evidence rows 1291 and 1299) does call all three "fry", but the sentence quotes p. 7, and p. 7 is the
measurement. So the fix invented a life stage for the companions, and "where fry were caught" describes values pooled
over fish that were not all fry.

Suggested: "found grayling fry, like the bull trout and burbot caught with them (which included one- and possibly
two-year-olds), in shallow, slow water ... (the 12 cm and < 0.1 m/s are given for the three species together, where
they were caught, not limits; the grayling's own means are the evidence table's grayling rows)". Optionally quote p. 7's
"the burbot and bull trout included one and possibly two year old fish".

### 2. (minor, inside fix 3; same pattern at L476 and L501) "summarising Northcote's (1995) review" is not on the page

L912: "**Deep pools, across the range.** Cannings and Ptolemy, summarising Northcote's (1995) review of the literature:"
+ "Large deep pools are required for overwintering and holding water." (p. 48).

Cannings and Ptolemy p. 47 opens the habitat paragraph with "Northcote (1995) provides a summary of habitat
requirements found in the Arctic grayling literature. He describes a range of spawning substrate utilization ... for
populations studied elsewhere." From there p. 48 runs on in the authors' own voice with other sources: Adsett Creek
(Liard) spawning sites, then "Stuart and Chislett (1979) found grayling using four mainstem habitat types ... on the
Sukunka", then an unattributed sentence on outmigrations, then the deep-pools sentence. Nothing marks the deep-pools
sentence as Northcote's, and the sentences just before it are not his. "Across the range" (no place named) holds; the
attribution does not.

The same lead-in sits on two older sentences of the same kind:
- L476 (structure as spawning capability, p. 48): follows directly on the Adsett Creek sentence, again with no
  attribution to Northcote.
- L501 ("summarising Northcote's (1995) review of grayling in general", homing, p. 48): this sentence is in the next
  paragraph ("Grayling make complicated migrations ... They show strong reproductive, trophic and refuge homing"),
  after the Northcote paragraph has ended. Nothing on the page ties it to Northcote.

Suggested: "Cannings and Ptolemy, in the habitat account that opens with Northcote's (1995) summary of the
literature:" for L912 and L476; for L501, "Cannings and Ptolemy, of grayling in general:".

### 3. (minor, inside fix 5) L1001–1002: "below the dam" is on no held page

Text: "an egg search in the Anzac found none (as did one in the Sukunka, below the dam)".

The fixes record cites the file's own header (L16, which carries no quote) and Cannings and Ptolemy p. 46. No page
read places the Sukunka below the dam. Stuart and Chislett's study-area page (PDF page 8) says "The study was conducted
in the lower Sukunka River drainage in the Peace River District of British Columbia ... The Sukunka River rises in the
Rocky Mountains and flows north into the Pine River 16 kilometers south of Chetwynd"; Hagen et al. 2026 p. 6 calls it
"the adjacent Sukunka River" beside the Williston watershed. The statement is true on a map, but it is a place the fix
supplied rather than a source, and the header's "the Sukunka in the Peace below the dam" (L16) shares the gap.

Suggested: "(as did one in the Sukunka, a Pine River tributary beside, not in, the Williston watershed)", resting on
Stuart and Chislett's study-area page and Hagen et al. 2026 p. 6; or drop "below the dam". Apply the same wording at
L16 if kept.

### 4. (moderate, around fixes 7 and 9) The bold lead "Juveniles in the larger rivers." covers paragraphs it does not describe

The bold lead at L703 runs until "**Adults upstream in clear, cool water.**" at L736, so it heads:
- L719–725 (fix 7): Sukunka juveniles "almost [exclusively] in the pools of the Sukunka River **and the tributaries**",
  and adults in the deepest river pools (Stuart and Chislett p. 3, OCR). Juveniles in tributary pools, and adults, are
  not "juveniles in the larger rivers".
- L727–734 (fix 9's L715 parenthesis): Den Beste and McCart's juveniles "appear to select for narrow channel widths (1
  to 8 m wide)" (p. 34). A selection for narrow channels sits under a lead saying juveniles use larger rivers.

Only Hagen et al. p. 6 and the Parsnip yearlings (Blackman and Hunter pp. i, 29, 30) fit the lead. A reader skimming the
bold leads takes away a pattern two of its four paragraphs contradict.

Suggested: retitle "**Juveniles.**" (or "**Where juveniles rear in summer.**"), and move the Sukunka adult clause
under "Adults upstream ..." or say in the lead-in that the Sukunka study covers both. (Lesser, same kind: the Adsett Creek
paragraph at L792, fix 16, now names "smaller fish" in the steep sections, under "**Adults upstream in clear, cool
water.**"; the page does not say Sections 3 and 4 are upstream reaches, and Sections 5–10 are the upper ones, p. 46. A
lead such as "**Adults in pools of clear, cool water.**" would hold for it.)

### 5. (minor, inside fix 9) L804–805: "the 6 m a width selected against"

Text: "(the 10 m is the average width used and the 6 m a width selected against; neither is a limit)".

Den Beste and McCart p. 35: "channels less than 6 m wide are selected against". Widths below 6 m are selected
against; 6 m is the edge of that span, not a width selected against. The lead-in ("selected against those under 6 m")
is right; the parenthesis contradicts it.

Suggested: "(the 10 m is the average width used, and widths under 6 m were selected against; neither is a limit)".

### 6. (minor, inside fix 28) L890–891: the hedge kept, the scope and subject narrowed

Text: "the authors suggest wintering in the creek depends on the conditions before freeze-up and is not obligatory".

Stewart et al. 1982 p. 90 (OCR): "the propensity to overwinter in small tributaries such as Adsett Creek is related to
physical conditions which preceed freeze up, and that overwintering in such habitat is not obligatory". Three drifts:
the claim is about small tributaries such as Adsett Creek, not the creek alone; "is related to" became "depends on";
and the sentence names no fish, while the page's overwinterers are young-of-the-year and yearlings ("substantial
numbers of young-of-the-year and yearling grayling overwintered in Adsett Creek during 1980"; in 1981 a freshet
"flushed most juvenile grayling from Adsett Creek"), and all age classes left before freeze-up (p. 89, quoted at L271).
A reader of "wintering in the creek" may take it as adults'.

Suggested: "the authors suggest that juveniles' wintering in small tributaries such as Adsett Creek is related to the
conditions before freeze-up and is not obligatory".

## Enumeration: each changed sentence, each claim, its page

Fix 1, lead L32–34
- Parsnip spawning dated from water temperature and fry emergence — blackman2002RadioTelemetry p. 16 ("based on the fry emergence dates and water temperatures"), p. ii.
- late May to late June — p. 16 ("between May 29 and June 25").
- the tagged fish suggest the estimate may run a week late — p. 16 ("may have been a week late, judging from observations ... of tagged fish").

Fix 1, gaps L1010–1011
- Parsnip dates from water temperature and fry emergence — blackman2002RadioTelemetry p. 16, p. ii.

Fix 2, L332
- Cannings and Ptolemy say it — cannings_ptolemy1998RareFreshwater p. 49.
- citing Northcote (1995) — p. 49 (in-text citation).
- across the range (no place) — p. 49 (sentence names none).

Fix 3, L912
- deep pools required for overwintering and holding water — cannings_ptolemy1998RareFreshwater p. 48.
- across the range — p. 48 (no place named).
- summarising Northcote's (1995) review — unsupported (finding 2; pp. 47–48 do not attribute the sentence).
- placement before "Elsewhere, spring-fed water" — no claim; holds.

Fix 4, gaps L1017–1018
- winter sampling of tributaries the size of Adsett Creek — stewart_etal1982Ecologicalstudies p. 90, OCR ("similar in size to").
- Adsett among them — p. 90, OCR ("and including").
- along the Alaska Highway gas pipeline — p. 90, OCR.
- used only by underyearlings and yearlings — p. 90, OCR.

Fix 5, gaps L1001–1002
- an egg search in the Anzac found none — blackman_hunter20011998Arctic p. 11.
- one in the Sukunka found none — stuart_chislett1979AspectsLife p. 30.
- the Sukunka is below the dam — unsupported (finding 3).

Fix 6, gaps L1022–1024
- fry in 6 of 13 Parsnip tributaries sampled — cowie_blackman2012OverviewSummary p. 15.
- in 2005 — p. 15.
- the Table and Anzac not sampled — p. 15.
- none caught or seen in the Table's tributaries — mathias_etal1998SummaryReport p. 30.
- what these tributaries contribute is not measured — mathias p. 30 ("no evidence that these tributaries are not important"); a gap statement, holds.

Fix 7, L719–721
- Sukunka juveniles almost only in pools — stuart_chislett1979AspectsLife p. 3, OCR.
- of the river and of the tributaries — p. 3, OCR.
- adults mainly in the deepest river pools — p. 3, OCR.
- seldom in tributary pools — p. 3, OCR.
- the scan splits the bracketed word — 38cc13a4 OCR page 3 ("exclus-" / blank line / "ively"); holds.
- (bold lead "Juveniles in the larger rivers") — does not fit (finding 4).

Fix 8 (with 24), L572–575
- grayling fry in shallow, slow water — blackman20041997Arctic p. 7.
- 1997 electrofishing — p. 7 (electrofished points), p. 11 (distribution confirmed by electrofishing).
- the bull trout and burbot caught with them were fry — unsupported (finding 1; p. 7 says they included one- and two-year-olds).
- upstream limit appeared to fall at the gravel-to-cobble change — p. 11.
- 12 cm and < 0.1 m/s given for the three species together — p. 7.
- where fry were caught — unsupported as worded (finding 1).
- not limits — p. 7 ("affinity", averages); holds.
- grayling's own means are evidence rows — rows 1288–1289, 1297–1298 (Table 2, p. 8); holds.

Fix 9, L711
- depth and velocity a preference from use, not a limit — blackman_hunter20011998Arctic p. 30 ("preferred"); rows 1293, 1301 (use against availability).

Fix 9, L728
- widths selected, not limits — denbeste_mccart1984Overviewstudies p. 34 ("appear to select for").

Fix 9, L804–805
- 10 m the average width used — denbeste_mccart1984Overviewstudies p. 35.
- the 6 m a width selected against — misstated (finding 5; p. 35 "less than 6 m wide are selected against").
- neither is a limit — p. 35; holds.

Fix 10, L325–326
- early, low-water spring of 1998 — blackman_hunter20011998Arctic p. i.
- fry appeared about a month earlier than in 1997 — p. i.
- the abstract says they emerged in early June — p. i.
- by their size, hatching 10 to 25 June — p. 28.

Fix 11, L74–78
- grayling complete their lives in rivers — hagen_etal2026futureArctic p. 6.
- often below headwater lakes — p. 6.
- citing Pollard and Miller 2011 and Stamford et al. 2017 — p. 6.
- one lake-inlet spawning population is known — p. 6 (Toodoggone, "only known").
- they do not live in the reservoir, citing Clarke et al. 2005 — p. 6.
- eDNA and occasional captures suggest some move through it — p. 6.
- citing Golder 2013, Stamford et al. 2022 and Stamford and O'Connor 2022 — p. 6.

Fix 12, L121–123
- surviving populations appear to move locally within home streams — hagen_etal2026futureArctic p. 5.
- Hagen et al. "suggest" — p. 5 ("appear to").
- citing Stamford et al. 2017 — p. 6.
- populations thought lost to flooding — p. 5 ("thought to be extirpated by flooding").
- presumably adapted to large rivers — p. 6.

Fix 13, L963–964
- missing year class put down to high flows and heavy sediment — stuart_chislett1979AspectsLife p. 2 (summary, PDF page).
- summer of 1976 — p. 2.

Fix 14, L975–976
- Tack (1974) on the Chena River — stamford_etal2017FWCPArctic p. 12.
- Clark (1992), no river — p. 12.

Fix 15, L813–814
- citing Vascotto 1970, Hughes and Reynolds 1994, Hughes 1998a and 1999 — stewart_etal2007Fishlife p. 21.
- larger fish hold the upstream positions — p. 21.
- across the range (no place) — p. 21.

Fix 16, L792–795
- densest per unit of habitat in the steep sections — stewart_etal1982Ecologicalstudies p. 46, OCR.
- the authors read it as a preference — p. 46, OCR ("suggest that grayling preferred").
- large grayling repeatedly in the deeper pools there through summer — p. 46, OCR.
- smaller fish used the area continuously — p. 46, OCR.
- the first quote skips a word split across a line — p. 46, OCR ("gray-/ling"); holds.
- diet mostly terrestrial insects — p. 47, OCR.
- (bold lead "Adults upstream in clear, cool water") — loose fit (finding 4, lesser).

Fix 17, L374–375
- evidence rows hold the passage as a statement, not the gravel size — row 1286 (`qual`, no value); holds.

Fix 18, L1025–1031
- Zemlak and Langston 1998 dropped — no other line cites it; holds.

Fix 19 — no prose change.

Fix 20, L231–232
- onset of flow probably cued the run — stewart_etal1982Ecologicalstudies p. 31, OCR.
- no single factor appeared to govern it — p. 31, OCR.

Fix 21, L320–321
- suggests most spawning occurs just after the freshet peak — blackman20041997Arctic p. 13 ("appears to occur").

Fix 22, L468–470
- spawning concentrated 4 to 5 km above the Prophet River — stewart_etal1982Ecologicalstudies p. 31, OCR ("majority ... approximately 4 - 5 km").
- over stable coarse gravel — p. 31, OCR.
- generally toward the tails of long runs — p. 31, OCR.
- especially those above steep gradients — p. 31, OCR ("particularly those preceding").

Fix 23, L505–506
- Blackman sets the literature's homing beside his count — blackman2002RadioTelemetry p. 16.
- fish that appeared to spawn away from their summer (tagging) stream — p. 16 ("did not appear to spawn").

Fix 25, L703–705
- juveniles 100 to 200 mm often using the larger streams through the year — hagen_etal2026futureArctic p. 6.
- citing Tack 1980, Butcher et al. 1981, Northcote 1993, Stewart et al. 2007 — p. 6.

Fix 26, L748–749
- deepest water near the thalweg, usually where the river narrows — blackman20041997Arctic p. 10.

Fix 27, L842–843
- Stamford et al. 2017 read Hawkshaw and Shrimpton and Ballard and Shrimpton as suggesting — stamford_etal2017FWCPArctic p. 7 ("appear").
- more limited to cooler fifth-order streams — p. 7.
- neither original says fifth order — ballard_shrimpton2009Summaryreport (no "fifth", "5th" or stream-order statement in its text); hawkshaw_shrimpton2014Temperaturepreference p. 25 (fourth); holds.

Fix 28, L890–892
- the authors suggest — stewart_etal1982Ecologicalstudies p. 90, OCR.
- wintering in the creek — narrowed (finding 6; page: "small tributaries such as Adsett Creek").
- depends on conditions before freeze-up — strengthened (finding 6; page: "is related to").
- is not obligatory — p. 90, OCR.
- winter sampling of similar small tributaries found only underyearlings and yearlings (EVS 1982d) — p. 90, OCR.

Fix 29, body L691–693
- the Sukunka fry did not move down in fall — stuart_chislett1979AspectsLife p. 3 (OCR page 3), p. 68.
- fry in ice-covered cobble riffles in November — p. 68.
- a downstream movement of yearlings in June — p. 68 ("one year old grayling").
- fry may winter in the cobbles of frozen side channels (summary) — p. 3.
- or in the tributary (discussion) — p. 68.

Fix 29, gaps L1015–1017
- same four claims — pp. 3, 68 as above.
