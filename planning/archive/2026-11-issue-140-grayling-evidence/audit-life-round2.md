# Meaning audit, round 2: `research/grayling_life_history.md`

Every one of the file's 242 quotes was read in its page context: `<scratchpad>/txt/<key>.txt` for text quotes, the OCR
cache for `, OCR` quotes (`data/rag/ocr/71074d55….txt` for Stewart et al. 1982, `38cc13a4….txt` for Stuart and
Chislett, `stanislawski1997FallWinter.ocr.txt`), with the printed page read from `<key>.layout.txt`. The lead, the
section headings, the bold paragraph leads and the gaps section were read against the quotes, and every place the
file points a value to "the evidence table's grayling rows" was checked against `data/literature_evidence.csv` as it
stands now. The round-1 fixes record was read first, and each passage it names as changed or added got a second
reading. Line numbers are the file's current lines. The script that printed each quote's context is
`<scratchpad>/audit2/ctx.py` (output `<scratchpad>/audit2/all.txt`).

Pages: every cited page is the printed page, or the PDF page the header declares (Stuart and Chislett's summary,
Tack's abstract). The Stewart et al. 1982 OCR pages sit at a fixed offset of 11 from the PDF page and Stanislawski's
at 14, both consistent with the printed numbers. No page finding.

## Findings

### 1. L31–33 (lead) and L991–992 (gaps): the Parsnip spawning dates are said to come "from telemetry and fry emergence"

**Wrong:** that is Stamford et al.'s review (p. 11, footnote 3: "inferred from the telemetry data and also from back
calculation"), not the original, which the file now quotes. Blackman computed the dates from water temperature and fry
emergence; the telemetry only told him the estimate may run a week late. The body (L308–313) has it right; the lead
and the gaps section contradict it.
**Page:** Blackman 2002 p. 16: "the spawning period was calculated to be between May 29 and June 25 based on the fry
emergence dates and water temperatures. However, our estimates may have been a week late, judging from observations
of the arrival and departure from suspected spawning areas of tagged fish"; p. ii: "Based on water temperatures and
fry emergence dates, spawning is believed to have occurred ... from late May to mid June."
**Fix:** lead: "in the Parsnip, from water temperature and fry emergence, at late May to late June (perhaps a week
earlier, by the tagged fish)"; gaps: "the Parsnip dates from water temperature and fry emergence".

### 2. L326: a range-wide statement framed as an account of the Williston grayling

**Wrong:** "In the Cannings and Ptolemy account of the Williston grayling, after Northcote (1995)" reads the 4 °C onset
as a Williston finding. The sentence cites Northcote (1995), whose review Cannings and Ptolemy describe as "a summary
of habitat requirements found in the Arctic grayling literature"; it sits in the account's Reproduction paragraph
beside an Alberta fecundity figure. Round 1 (finding 1) asked every range-wide statement to open "Across the range";
this one was missed.
**Page:** Cannings and Ptolemy p. 49: "Grayling are spring spawners often moving onto spawning areas shortly after
ice-out at temperatures near 4°C (Northcote, 1995)."; p. 47: "Northcote (1995) provides a summary of habitat
requirements found in the Arctic grayling literature."
**Fix:** "Across the range, Cannings and Ptolemy, citing Northcote (1995):".

### 3. L868 heading "Small BC streams" holds a range-wide statement (L880–882)

**Wrong:** round 1's fix (finding 25) moved the Cannings and Ptolemy "Large deep pools are required for overwintering"
sentence out of the Parsnip paragraph and under the bold lead "Small BC streams", so it now reads as a finding in
small BC streams. It is part of the account's summary of Northcote's review of the literature, range-wide.
**Page:** Cannings and Ptolemy p. 48 (habitat paragraph opened on p. 47 by "Northcote (1995) provides a summary of
habitat requirements found in the Arctic grayling literature"): "Large deep pools are required for overwintering and
holding water."
**Fix:** move L880–882 out from under "Small BC streams" (for example to "Elsewhere, spring-fed water", retitled
"Across the range"), keeping its own lead-in.

### 4. L996–997 (gaps): "Adsett Creek's small tributaries held only underyearlings and yearlings in winter"

**Wrong:** a place a fix invented. The winter sampling was of watercourses along the Alaska Highway gas pipeline,
tributaries similar in size to Adsett Creek (Adsett among them), not tributaries of Adsett Creek. The body (L873–878)
has it right.
**Page:** Stewart et al. 1982 p. 90 (OCR): "Results of 1982 winter sampling in selected watercourses along the Alaska
Highway Gas Pipeline showed that tributaries similar in size to (and including) Adsett Creek were utilized only by
overwintering underyearling and yearling grayling (E.V.S. Consultants Ltd. 1982d)."
**Fix:** "and winter sampling of small tributaries like Adsett Creek along the Alaska Highway found only underyearlings
and yearlings".

### 5. L981–984 (gaps): the Sukunka egg search is listed under "Spawning sites in the Williston watershed"

**Wrong:** the Sukunka is in the Peace below the dam (the header, L16, says so), not in the Williston watershed, so the
bullet counts a non-Williston search as Williston evidence.
**Page:** Stuart and Chislett p. 30: "Gravels in the Sukunka River sidechannels and backchannels were searched for eggs
from June 1 to 30 but eggs were not located."; Cannings and Ptolemy p. 46: the Williston populations "are found only in
the basin of the Williston Reservoir, above the W.A.C. Bennett Dam".
**Fix:** "an egg search in the Anzac found none (as did one in the Sukunka, below the dam)".

### 6. L1001–1002 (gaps): heading and wording misdescribe the 2005 survey

**Wrong:** the heading "Rearing in the Parsnip tributaries' own tributaries" names tributaries of the Table and Anzac,
but the 2005 fry came from tributaries of the Parsnip itself (the Table and Anzac were excluded); and "small" Parsnip
tributaries is not in the source, which says the survey covered all tributaries within the watershed.
**Page:** Cowie and Blackman 2012 p. 15: "with a primary focus on the distribution and abundance of Arctic grayling fry in
the Parsnip River and all tributaries within the Parsnip River Watershed ... A 51 km section of the Parsnip River (km 39
to km 90) and two major tributaries, the Table and Anzac rivers, were not included".
**Fix:** heading "Rearing in the Parsnip's other tributaries"; "Fry were found in 6 of 13 Parsnip tributaries sampled in
2005 (the Table and Anzac not sampled), and none have been reported in the Table's tributaries".

### 7. L710–712: an original we hold is quoted through a review

**Wrong:** "Stuart and Chislett (reported by Cannings and Ptolemy) found juveniles and adults in pools" quotes Cannings
and Ptolemy's report of the Sukunka study, which the file quotes directly elsewhere. CLAUDE.md asks for the original
wherever it is held, and the original says more (pools of the tributaries as well as the river; adults in the deepest
river pools, seldom in tributary pools).
**Page:** Stuart and Chislett p. 3 (summary, OCR): "Juvenile grayling were found almost exclusively in the pools of the
Sukunka River and the tributaries." and "Adult grayling to age eight were found mainly in the deepest pools of the
Sukunka River and seldom found in the tributary pools."
**Fix:** re-quote both sentences from the original (`, OCR`; the text layer garbles "almost exclusively"), and drop or
demote the Cannings and Ptolemy quote.

### 8. L566–570: a three-species value given as grayling fry's

**Wrong (species):** "Blackman's 1997 electrofishing found fry in shallow, slow water" carries a quote whose "average
12 cm" and "<0.1 m/s" are for grayling, bull trout and burbot fry together. Grayling's own values are in Table 2 (and
are already evidence rows 1288–1289 and 1297–1298). The fixes record's candidate row ("Table and Anzac fry average
12 cm depth, < 0.1 m/s") repeats the mix.
**Page:** Blackman 2004 p. 7: "The grayling fry, bull trout and burbot showed a strong affinity for shallow (average
12 cm) low velocity (<0.1m-s) habitats (Table 2)."; p. 8, Table 2, Arctic grayling: Anzac mean depth 12.5 cm, velocity
0.04 m/s; Table mean depth 11.5 cm, velocity 0.07 m/s.
**Fix:** "found grayling fry, like the bull trout and burbot fry caught with them, in shallow, slow water", or replace the
quote with Table 2's grayling row.

### 9. L702, L715–716, L787: preferences called "where fish were, not limits"

**Wrong (kind):** three parentheticals added by round 1 (finding 15) call values the source reports as selection or
preference "where yearlings were caught", "widths where juveniles were" and "widths where adults were". Blackman and
Hunter tested preference ("preferred"); Den Beste and McCart report selection ("select for", "selected against").
The evidence table codes them `pref` (rows 1293, 1301, 1215). Only the adults' 10 m average is use.
**Page:** Blackman and Hunter p. 30: "Age 1+ Arctic grayling preferred for low velocity (<0.20 ms-1) sites with a depth
between 0.40 and 1.0 m."; Den Beste and McCart p. 34: "Juvenile grayling also appear to select for narrow channel widths
(1 to 8 m wide)"; p. 35: "The average channel width used by adults was is 10m, but channels less than 6 m wide are
selected against."
**Fix:** L702 "(a preference from use, not a limit)"; L715 "(widths selected, not limits)"; L787 "(the 10 m is the width
used and the 6 m a width selected against; neither is a limit)". Note also that the same report's abstract gives the
yearlings' preference as "shallow (60-100cm) low velocity (<0.5 ms-1) glides" (p. i), which differs from p. 30; the
evidence table should say so.

### 10. L319–324: two 1998 dates set side by side that contradict each other

**Wrong (date):** the sentence has fry emerging "in early June" and hatching "from 10 to 25 June", so emergence comes
before hatching. Both come from the same report, on different pages, and the report's own June 16–18 survey found
"newly hatched" fry.
**Page:** Blackman and Hunter p. i: "resulted in the fry emerging in early June, one month earlier than in 1997"; p. 28:
"hatching occurred from June 10th to June 25th in 1998"; p. 11: "The preliminary fry distribution surveys conducted
from June 16 to 18, 1998 found Arctic grayling fry were 10-15 mm in length (newly hatched)".
**Fix:** "In the early, low-water spring of 1998, Table and Anzac fry appeared about a month earlier than in 1997 (the
abstract says early June; by their size the report puts hatching at 10 to 25 June)".

### 11. L73–76: citations misassigned in Hagen et al.'s passage

**Wrong (attribution):** "citing Pollard and Miller 2011 and Stamford et al. 2017, says ... that they do not live in the
reservoir, though eDNA and occasional captures suggest some move through it". Pollard and Miller and Stamford are cited
for the fluvial-life sentence only; the reservoir sentence cites Clarke et al. 2005, and the eDNA clause Golder 2013,
Stamford et al. 2022 and Stamford and O'Connor 2022.
**Page:** Hagen et al. 2026 p. 6: "(Pollard and Miller 2011; Stamford et al. 2017). The Toodoggone ... Arctic Grayling do
not reside in the reservoir (Clarke et al. 2005), although new results from environmental DNA ... more frequently than
previously thought (Golder 2013; Stamford et al. 2022; Stamford and O'Connor 2022)."
**Fix:** name each citation with its claim.

### 12. L119–124: a held review's claim credited to the later synthesis, hedge dropped

**Wrong (attribution, hedge):** "Hagen et al. 2026 suggest ... that the populations flooded by the reservoir were
presumably adapted to large rivers" — Hagen et al. cite Stamford et al. 2017 (held) for it, and speak of populations
"thought to be extirpated by flooding".
**Page:** Hagen et al. 2026 pp. 5–6: "In contrast, Arctic Grayling metapopulations thought to be extirpated by flooding
in the Williston and Upper Peace core areas (Figure 1) were demographically independent from surviving metapopulations
and presumably adapted to the (now flooded) large river habitats (Stamford et al. 2017)."
**Fix:** "and, citing Stamford et al. 2017, that the populations thought lost to flooding were presumably adapted to
large rivers".

### 13. L945–946: "July and August 1976" is not in any quote under it

**Wrong (date):** both quotes are from the summary, which says "the summer of 1976"; July and August come from p. 68,
which is not quoted here (round 1, finding 3, took the wording from p. 68 but kept only the p. 2 quotes).
**Page:** Stuart and Chislett p. 2: "high flows and heavy sediment loads during the summer of 1976."; p. 68: "The
Resource Analysis Branch recorded extremely high Flows in the drainage during July and August 1976 with heavy sediment
leads".
**Fix:** "in the summer of 1976", or add the p. 68 sentence (quoted up to "1976", since the text has "leads").

### 14. L957–958: Clark (1992) placed on the Chena River without page support

**Wrong (place):** "report Tack (1974) and Clark (1992) on the Chena River (Alaska)" — the page places only Tack's year
class failure on the Chena; it names no river for Clark's 14-year correlation (round 1, finding 1, added the placement).
**Page:** Stamford et al. 2017 p. 12: "Tack (1974) noted absence of a whole year class in Chena River following a flood
event and Clark (1992) found a significant correlation between recruitment levels and stream flows over a 14-year
period."
**Fix:** "report Tack (1974) on the Chena River (Alaska) and Clark (1992)".

### 15. L795–800: no place given for the upstream-size gradient

**Wrong (place):** the header (L15–17) promises every claim says where it was measured; this sentence opens "In the
studies it cites (Vascotto 1970, Hughes and Reynolds 1994, Hughes 1998a)" and names no place, so a reader takes it as
the Northwest Territories. The page does not place these studies.
**Page:** Stewart et al. 2007 p. 21: "They adopt a larger, older-fish upstream distribution pattern (Vascotto 1970; Hughes
and Reynolds 1994; Hughes 1998a, 1999) ... Headwater positions appeared to be preferred by grayling, and the larger
fishes were more successful competing for these positions (Hughes and Reynolds 1994)."
**Fix:** open "Across the range, the Northwest Territories review, citing Vascotto 1970, Hughes and Reynolds 1994 and
Hughes 1998a and 1999, reports".

### 16. L779–782: Adsett "steep sections" are grayling of all sizes, under an "Adults upstream" heading

**Wrong (stage):** the bold lead (L723) is "Adults upstream in clear, cool water", and "summering grayling preferred the
steep sections" reads as adults. The comparison is of all grayling counted per section through the season (large
fish of 250 mm and smaller fish alike), per unit area of habitat; raw numbers did not differ between sections.
**Page:** Stewart et al. 1982 p. 46 (OCR): "analysis of variance ... showed no significant difference (H = 2.51; 0.75<
p< 0.90) in numbers of grayling between sections ... grayling numbers were compared on the basis of area of available
fish habitat/section ... These results suggest that grayling preferred areas of steep gradient, typified by Sections 3
and 4. Throughout the summer, large grayling (250 mm) were repeatedly found in the deeper pools of this area. Smaller
fish utilized this area continuously".
**Fix:** "In Adsett Creek (BC), grayling of all sizes were densest, per unit of habitat, in the steep sections, which the
authors read as a preference".

### 17. L369: the Anzac gravel size is said to be an evidence row; the only row holds no value

**Wrong (pointer):** "(the gravel size is the evidence table's grayling rows)" — the one row from this passage, 1286
(`blackman2002RadioTelemetry` p. 18, substrate, spawning), is `qual` with no value or unit, so the "<3 cm" is not held.
**Page:** `data/literature_evidence.csv` data row 1286: kind `qual`, value_min and value_max blank.
**Fix:** either the rows drafter codes the value (`max`, 3, `cm`) or the parenthetical says the table holds the statement,
not the size.

### 18. L1004 (gaps): Zemlak and Langston 1998 listed but never cited, and read through a report the list omits

**Wrong (attribution):** no other line of the file cites Zemlak and Langston 1998; it appears in Blackman and Hunter 2001's
text (p. 29), which is not among the documents the list says these primaries were "read here only through".
**Page:** Blackman and Hunter p. 29: "extensive electrofishing surveys conducted from1994 to1997 also failed to find any
substantial utilisation by this age class ... (Mathias et al. 1998; Langston 1998; Zemlak and Langston 1998".
**Fix:** drop it, or add Blackman and Hunter 2001 to the closing list.

### 19. Threshold-like values in prose that no evidence row holds

Each of these is a stream-size, depth or distance value a reader can take as habitat criterion; the evidence table has
no row for it (checked by quote text):
- L815: "shorter tributaries (< 79 km) are not likely to be used by juvenile Arctic grayling" (Hawkshaw and Shrimpton
  p. 31). The vocabulary may lack a stream-length variable: if so, say it in the rows notes.
- L904: Cache Creek overwintering "depth 0.5-1.5 m" (Stewart et al. 2007 p. 22): a candidate `overwintering` depth row.
- L623 and L967: fry "remain in shallow water (<10cm) throughout the summer" and "concentrate in very shallow (<10 cm)
  stream margin areas" (Blackman and Hunter pp. 29–30, citing Blackman 2002 in prep): a candidate rearing depth row (or a
  note that Blackman 2004's own Table 2 rows stand for it).

**Fix:** hand the three to the rows drafter; the prose may keep them as statements.

### 20. L226–227: hedge dropped ("governed")

"no single factor governed it" — p. 31 (OCR): "no single physical parameter appeared responsible for regulating ascent."
**Fix:** "no single factor appeared to govern it".

### 21. L315: hedge dropped ("puts most spawning")

Blackman 2004 p. 13: "most Arctic grayling spawning appears to occur just after the peak of spring freshet".
**Fix:** "suggests most spawning occurs just after the peak".

### 22. L462–463: "toward the tails of long runs before steep gradients" drops "generally" and "particularly"

Stewart et al. 1982 p. 31 (OCR): "These areas generally occurred toward the tail of long runs, particularly those
preceding steep gradients." The sentence makes every site precede a steep gradient.
**Fix:** "generally toward the tails of long runs, especially those above steep gradients".

### 23. L499–500: "fish spawning away from their summer stream" drops "did not appear to"

Blackman 2002 p. 16: "6 of 18 fish did not appear to spawn in the stream where they were tagged".
**Fix:** "his own count of fish that appeared to spawn away from their summer stream".

### 24. L567–568: "their upstream limit where the bed turned from gravel to cobble" drops "appeared"

Blackman 2004 p. 11: "The upstream distribution of fry appeared to coincide with a change from gravel to cobble".
**Fix:** "and their upstream limit appeared to fall where the bed turned from gravel to cobble".

### 25. L695–696: "juveniles of 100 to 200 mm using the larger streams through the year" drops "often"

Hagen et al. 2026 p. 6: "These larger streams are often utilized by juvenile grayling 100-200 mm".
**Fix:** "often using".

### 26. L735–736: "where the river narrows" drops "usually"

Blackman 2004 p. 10: "at or near the thalweg, usually where the river is narrow."
**Fix:** "usually where the river narrows".

### 27. L824–825: "as limiting grayling to cooler fifth-order streams" drops "appear more limited"

Stamford et al. 2017 p. 7: "grayling appear more limited to cooler fifth order streams".
**Fix:** "as suggesting grayling are more limited to cooler fifth-order streams". (Outside this file: evidence row 1233
codes this as a `dist` value of 5 with no note that neither cited original says fifth order.)

### 28. L872–873: "depended on the conditions before freeze-up" drops "suggest"

Stewart et al. 1982 p. 90 (OCR): "Results of the present investigation suggest that the propensity to overwinter in small
tributaries such as Adsett Creek is related to physical conditions which preceed freeze up".
**Fix:** "the authors suggest wintering in the creek depends on the conditions before freeze-up and is not obligatory".

### 29. L684–685 and L996–997: the Sukunka winter-fry inference, hedge and basis

The gaps line says the study infers "that fry winter in the cobbles of frozen side channels", dropping "may"; and both
lines give the November fry as the only basis, though the study also rests it on yearlings moving down in June, and on
p. 68 places the wintering "in the tributary".
**Page:** Stuart and Chislett p. 3: "the study indicates fry may overwinter in the cobbles of frozen sidechannels"; p. 68:
"Fry were observed in cobbles in ice-covered riffles in November and a downstream movement of one year old grayling in
June suggests fry over-wintered in the tributary."
**Fix:** "infers, from fry in ice-covered cobble riffles in November and yearlings moving down in June, that fry may
winter in the tributary's frozen side channels".

## Checked and found sound

The round-1 fixes record's changed and added passages were each re-read; apart from the entries above (findings 3, 4,
9, 13 and 14 sit inside round-1 fixes; findings 1, 8 and 10 inside Task 2's new or re-quoted passages), they say what
their pages say: the Blackman telemetry calendar, distances, winter spread and the three reservoir fish; the Anzac
suspected areas, km 12–22 and km 14–20 reaches and the empty egg search; the Osilinka, Ingenika, Omineca and Nation fry
surveys; the Table fry, side channels and tributaries (Mathias et al.); Hawkshaw and Shrimpton's order, distance and
gradient results; the Little Smoky fall and winter passages; the Adsett timing, emigration and winter passages; Ballard
and Shrimpton's temperature caveat; and the "fifth order" note (Ballard and Shrimpton's text has no stream order at
all; Hawkshaw and Shrimpton give fourth).

## Counts

| | count |
|---|---|
| quotes checked in page context | 242 of 242 |
| prose blocks checked (lead bullets, bold leads, headings, gaps bullets, "not" paragraph) | 7 lead bullets, 11 section headings, 40 bold leads, 6 gaps bullets |
| evidence-row pointers checked against the table | 10 |
| findings | 29 |

| kind | findings |
|---|---|
| attribution (review for original, citations misassigned, list) | 1, 7, 11, 12, 18 |
| place | 2, 3, 4, 5, 14, 15 |
| species or life stage | 8, 16 |
| kind of value (preference called use) | 9 |
| date or number | 6, 10, 13 |
| hedge dropped | 20–29 (with 12 and 27 also) |
| evidence-table pointer | 17 |
| threshold-like value not held | 19 |
| page | 0 |
