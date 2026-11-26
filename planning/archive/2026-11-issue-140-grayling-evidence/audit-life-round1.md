# Meaning audit, round 1: `research/grayling_life_history.md`

Every one of the file's 136 quotes was read in its page context (`<scratchpad>/txt/<key>.txt`, with the printed page
number read from `<key>.layout.txt`), and so were the headings, the "In brief" lead, the section summaries and the
gaps section. Line numbers are the file's as of commit `e4f43538`. Evidence-table rows are data rows (file line N + 1).

Pages: all 136 cited pages are the printed page (or, for Stuart and Chislett's summary and Tack's abstract, the PDF
page the header declares). No page finding.

## Findings

### 1. L12–14 (header): "Every claim says where it was measured" does not hold

**Wrong:** many passages are range-wide review statements and the sentence names no place, so the header's promise is
broken and a reader takes the statement as one of the listed places: L247 (spawning-site range), L253–257 (substrate),
L263 (no redd), L272 (structural elements), L288 (homing), L326–328 (fry margins), L339–341 (fry shift), L419 (clear
streams), L496 (deep pools), L519 (temperature), L527–529 (sediment), L542 (Clark 1992), L552 (culverts).
**Page:** e.g. Stamford p. 8 cites for L328 "(Stuart and Chislett 1979; Butcher et al. 1981; Stewart et al. 1982;
Armstrong 1986; Blackman 2002a; Blackman 2004; Cowie and Blackman 2003; Cowie and Blackman 2004; Nykänen and Huusko
2004)" (BC, Alaska, Finland); Hagen p. 7 cites for L529 "(Birtwell et al. 1984; McLeay et al. 1987; Reynolds et al.
1989)".
**Fix:** add "or range-wide, where a review states it so" to the header's list, and open each of the passages above
with "Across the range (… review, citing …)".

### 2. L26–27 (In brief): the Sukunka and Parsnip spawning dates are stated as observed

**Wrong:** "in the Sukunka it ran from mid-May to early June and in the Parsnip from late May to late June" drops that
both are estimates; the body (L186, L190–195) and the gaps section (L560–561) say so.
**Page:** Stuart and Chislett p. 31: "From the fry development data, grayling spawned in the Sukunka drainage between
May 15 and June 7"; Stamford p. 11: "Spawning was estimated to have occurred over the late-May to late-June period."
and footnote 3 "While spawning was not observed directly by Blackman (2002a)".
**Fix:** "in the Sukunka it was estimated, from fry development, at mid-May to early June, and in the Parsnip, from
telemetry, at late May to late June".

### 3. L33–34 (In brief) and L372–376: floods "can wipe out a year class" / "can kill many fry"

**Wrong:** the quotes hedge ("may cause high mortalities") and name drought as well as flooding; no quoted passage
says a flood after hatching wiped out a year class. The one year-class failure quoted (Sukunka, L531–536) was put down
to high flows and sediment in July and August 1976, not the weeks after hatching. L372 "Floods in the first two weeks
can kill many fry" also drops "may" and the drought half.
**Page:** Stewart p. 17: "flooding or drought during this period may cause high mortalities"; the year-class
statement on that page is itself hedged and not quoted: "Year class failures in Alaska's Chena River may have resulted
from heavy larval mortality due to flooding (Tack 1974 cited in Armstrong 1986)". Stuart and Chislett p. 68 (PDF 74):
"The Resource Analysis Branch recorded extremely high Flows in the drainage during July and August 1976 with heavy
sediment leads".
**Fix:** lead: "Floods or drought in the two weeks after hatching may kill many fry." L372: "Flooding or drought in the
first two weeks may cause high fry mortality". If the year-class claim is wanted, quote Stamford p. 12 ("Tack (1974)
noted absence of a whole year class in Chena River following a flood event"), in Alaska.

### 4. L44, L259, L350: row references are stale against the rows now in the table

**Wrong:** the header (L14–15) promises held numbers are cited by row, and L44 says the depth and velocity rows are
903–911 and 912–925. Commit `e4f43538` added GR rows 1190–1253, among them the values these passages quote: Stewart
p. 14's 2.5 cm gravel is row 1235; Stewart p. 17's 5–50 cm and 6–31 cm depths are rows 1242–1243 (L350 cites only the
velocity rows 908–910); the Adsett Creek depth, velocity and substrate are rows 1236, 1240, 1248.
**Page:** `data/literature_evidence.csv` file lines 1236, 1237, 1241, 1243, 1244, 1249 (data rows 1235, 1236, 1240,
1242, 1243, 1248; recount at fix time, since rows are appended).
**Fix:** update L44 to include the new depth and velocity rows, L259 to add the substrate row, L350 to add the depth
rows, and point L265–268 at the Adsett rows.

### 5. L54: "for the migratory forms"

**Wrong:** Table 1's columns are FLUVIAL and ADFLUVIAL/LACUSTRINE; the second lumps lake-resident fish with adfluvial
ones, so "migratory forms" names a set the table does not.
**Page:** Stewart p. 3, Table 1: "STREAM-RESIDENT … FLUVIAL ADFLUVIAL/LACUSTRINE • Spawning and rearing habitat. •
Spawning and rearing habitat."
**Fix:** "for fluvial populations and for adfluvial or lake-dwelling ones".

### 6. L57: "Small (~10 m wide), medium gradient tributary streams" reads as a width and gradient threshold

**Wrong:** a reader takes "~10 m" and "medium gradient" as habitat values; the file's own rule (L43–44) says these
belong to the evidence table, which already holds them.
**Page:** Stewart p. 3, Table 1 row heading; evidence rows 1190, 1193 (gradient `qual`), 1202, 1214 (channel width
10 m).
**Fix:** after the quote, "(the table's ~10 m and medium gradient are evidence rows 1190, 1193, 1202 and 1214)", or cut
the quote and cite the rows.

### 7. L54–55 and L61: hedge dropped

**Wrong:** "the review says some grayling spend part or all of their lives near their overwintering water"; the page
says "may", and names who.
**Page:** Stewart p. 22: "Some grayling may spend part or all of their lives near their overwintering areas. These
fish may include stocks in some lakes, those living near major groundwater sources, and perhaps some of those that
spawn in mainstem areas of larger unsilted runoff rivers such as the Chena in Alaska (Armstrong 1986)."
**Fix:** "the review says some grayling may spend part or all of their lives near their overwintering water".

### 8. L21–22 and L63–69: "do not live in the reservoir" drops the same sentence's qualification

**Wrong:** the quote stops at "reservoir"; the sentence continues that eDNA and captures suggest grayling move through
the reservoir more often than thought, and p. 17 calls continued migration through the reservoir a hypothesis. The lead
and L65 present residence and passage as one fact.
**Page:** Hagen p. 6: "Arctic Grayling do not reside in the reservoir (Clarke et al. 2005), although new results from
environmental DNA (eDNA) studies and infrequent grayling encounters in tributaries to the Williston and Upper Peace
core areas suggest that successful movement through the reservoir occurs more frequently than previously thought";
p. 17: "supports an intriguing hypothesis that Arctic Grayling continue to migrate through the reservoir to complete
their life history."
**Fix:** extend the L69 quote through "previously thought" and add to L65 and the lead "though eDNA suggests some move
through it".

### 9. L107–110: hedge dropped, and a range-wide statement read as the Williston's

**Wrong:** "Stamford et al. 2017 say fluvial adults return to the same feeding sites each year, while fish from
different spawning streams can share summer or winter habitat" drops "studies suggest" and "may", and the studies are
mostly Alaskan.
**Page:** Stamford p. 10: "Mark-recapture and radio telemetry studies suggest that individual fluvial adults home
yearly to the same summer feeding sites, but grayling from different spawning streams may exhibit overlap in summer
rearing and/or overwinter habitat (Tack 1980; Buzby and Deegan 2000; Blackman 2002a; Gryska 2006; Earth Tone and
Mainstream 2013). For example, radiotagged adults in the turbid Tanana River, Alaska …".
**Fix:** "Stamford et al. 2017, citing studies in Alaska and the Peace (Tack 1980, Buzby and Deegan 2000, Blackman
2002a, Gryska 2006, Earth Tone and Mainstream 2013), say these suggest fluvial adults return … and that fish from
different spawning streams may share …".

### 10. L122–125 (and L217–220): spawning in the Parsnip's tributaries is inferred, not seen, and the two telemetry studies place it differently

**Wrong:** "They found the three phases, with spawning in the middle reaches of four tributaries" states spawning as
found; the page has "a spring spawning migration into" those reaches, the discussion says the model and the movement
metrics disagree on how far upstream fish go, and Hagen et al. describe the telemetry as flagging movements "possibly
for spawning". L217–220 then has Blackman's telemetry placing spawners "mostly in the lower reaches" of the Anzac and
Table, which the file does not set beside Martins's "middle reaches", and drops "mostly".
**Page:** Martins p. 3: "2) a spring spawning migration into the middle reaches of the Anzac, Table, Hominka, and
Missinka Rivers"; p. 32: "the model predicting middle-tributary home range centers in the springtime while the
population movement metrics would suggest a push further upstream"; Hagen p. 16: "flagged movements into tributaries
possibly for spawning"; Stamford p. 11: "spawning sites were located mostly in the lower reaches of the Anzac and
Table Rivers".
**Fix:** "They found the three phases, the second a spring migration into the middle reaches of four tributaries,
read as a spawning migration"; at L217 "placed most of the Table and Anzac spawners in the lower reaches … (Martins et
al., above, place the spring migration in the middle reaches)".

### 11. L131: "gives the same calendar"

**Wrong:** the two studies' calendars differ: Blackman's fish moved to winter water in September and October; Martins's
began gathering in the mainstem in October and reached winter distribution by November; and they differ on spawning
reaches (finding 10).
**Page:** Stamford p. 11: "downstream movements to overwintering locations occurred in September and October";
Martins p. 32: "Summer distribution patterns persist until October … reaching an approximately winter distribution by
November."
**Fix:** "gives a similar calendar, with the move to winter water a month earlier, in September and October".

### 12. L147–149: Tack's cue stated without its hedge

**Wrong:** "Tack ties the start of the run to the first warming to 1 °C"; the abstract says "probably".
**Page:** Tack p. 3: "The prespawning migration is probably stimulated by the first rise of water temperature to 1°C
in the spring."
**Fix:** "Tack suggests the run is probably triggered by the first warming to 1 °C".

### 13. L213–215: Parsnip spawning in the mainstem and small tributaries stated as reported fact

**Wrong:** "In the Parsnip they report spawning in the mainstem and in small tributaries"; Hagen et al.'s summary
sentence rests on telemetry that, two sentences earlier, flagged tributary movements "possibly for spawning"; no
spawning was observed.
**Page:** Hagen p. 16: "Telemetry studies … identified overwintering locations in the Parsnip River, and flagged
movements into tributaries possibly for spawning. … The Parsnip core area presents a picture of complex migratory
behaviour that includes spawning in the Parsnip River mainstem and small tributaries".
**Fix:** "In the Parsnip their summary, from telemetry that flagged tributary movements possibly for spawning, has
spawning in the mainstem and small tributaries", quoting the "flagged movements" sentence as well.

### 14. L249–251: a hypothesis stated as a held view

**Wrong:** "Tack (Alaska) holds that grayling spawn where their system warms first"; the abstract advances it as a
hypothesis.
**Page:** Tack p. 3: "The hypothesis is advanced that these locations are used for spawning because they are the
first areas in their systems to warm in the spring."
**Fix:** "Tack (Alaska) advances the hypothesis that …".

### 15. Threshold-like values restated in prose that the evidence table does not hold (or holds without a pointer)

**Wrong:** a reader takes these as habitat thresholds, and the file's rule (L43–44) puts values in the table:
- L274–277: the Sukunka overflow channel's "0.5 per cent gradient" reads as a spawning gradient; no row holds it (or
  its 60 cm wetted width), though the gaps section (L559) leans on it. It is an artificial channel stocked with four
  trapped adults.
- L333: Parsnip newly emerged fry at ~0.1 m depth; the velocity is row 1251, the depth is in no row.
- L400: Parsnip juveniles at 0.4–1.0 m depth; no row.
- L441: Den Beste and McCart's adult widths (10 m mean, < 6 m selected against); no row (adult, so notes, by the
  brief).
- L503: Cache Creek overwintering depth 0.5–1.5 m; no row.
- L358–360, L458–460: 4th and 5th order; rows 1230–1232 hold them but the prose does not cite them.
- L408–410: juvenile widths 1–8 m and > 14 m; rows 1215–1216, not cited.
**Page:** Stuart and Chislett p. 29: "The overflow channel was 18 m long, 0.5 per cent gradient … The average wetted
width 60 cm"; Stamford p. 8 "approximately 0.l m"; p. 9 "approximately 0.4-1.0 m depth"; Stewart p. 21 "The average
stream width used by adults was 10 m"; p. 22 "depth 0.5-1.5 m".
**Fix:** cite the rows where held; for the rest, either add rows (a `rows` follow-up) or say beside the quote that the
value is not a habitat limit (L277: "an artificial channel holding four trapped adults, not a measure of where
grayling choose to spawn").

### 16. L281–286: homing stated as reported, not suggested

**Wrong:** "Stamford et al. 2017 report precise homing for many stream populations" drops "relatively" and "has been
suggested"; "after a poor spring" drops "sometimes".
**Page:** Stamford p. 10: "Relatively precise homing of adults on spawning migrations, and corresponding demographic
independence, has been suggested for numerous stream populations (e.g. Tack 1980; Ridder et al. 1993; Ridder 1994,
2000; Blackman 2002a; Gryska 2006), although adults have also been observed moving to different spawning sites
sometimes in response to poor spring conditions".
**Fix:** "Stamford et al. 2017 say relatively precise homing has been suggested for many stream populations (mostly
Alaskan studies, and Blackman 2002a in the Parsnip), with some adults sometimes switching sites after a poor spring".

### 17. L288: Cannings and Ptolemy's homing sentence has no lead-in and reads as Stamford's

**Wrong:** the quote follows "Stamford et al. 2017 report …" with no sentence of its own; it is Cannings and Ptolemy's
summary of the habitat literature (Northcote 1995), about grayling in general, not a Williston finding.
**Page:** Cannings and Ptolemy p. 47–48: "Northcote (1995) provides a summary of habitat requirements found in the
Arctic grayling literature. … Grayling make complicated migrations between three different habitat types … They show
strong reproductive, trophic and refuge homing with offspring utilizing the same habitat areas as their parents."
**Fix:** precede it with "Cannings and Ptolemy, summarising Northcote's (1995) review of grayling in general:".

### 18. L314–316: "The eggs lie only a few centimetres into the gravel"

**Wrong:** the page gives a hedged maximum, not where eggs lie.
**Page:** Stewart p. 15: "They may be covered by up to 5 cm of substrate (Reed 1964; Tack 1971; Kratt 1977; Kratt and
Smith 1977; Krueger 1981)."
**Fix:** "The eggs may be covered by up to 5 cm of gravel".

### 19. L318–320: the disturbed gravel is stated as the spawning site

**Wrong:** "fry emerged on 27 June from the gravel disturbed on 3 June" drops that the page calls these "possible"
spawning sites, that spawning was not seen, and that fry also emerged from a third, undisturbed area.
**Page:** Stuart and Chislett p. 30: "On June 27, fry emerged from the gravel in the two areas noted as possible
grayling spawning sites and in a third area of quiet water near the inlet of the channel."
**Fix:** "fry emerged on 27 June from the two areas of gravel disturbed on 3 June, which the authors call possible
spawning sites, and from a third area of quiet water".

### 20. L408–410: "juveniles selected narrow channels"

**Wrong:** hedge dropped.
**Page:** Stewart p. 19: "They appeared to select for channels that are 1 to 8 m wide and against channels wider than
14 m (Den Beste and McCart 1984)."
**Fix:** "juveniles appeared to select narrow channels".

### 21. L428–430: "snorkel and drone surveys … tied grayling to cool pools"

**Wrong:** the association is the snorkel surveys'; the drones mapped habitat and surface heat. "Tied" also strengthens
"showed associations".
**Page:** Bottoms p. 6: "multiscale data collected with drones, snorkel surveys, temperature logger arrays … At both
the reach-scale and the riverscape-scales, snorkel surveys showed associations between Arctic grayling occurrence and
cool pool habitats."
**Fix:** "In the Anzac River (Parsnip), snorkel surveys in July to September 2022, over drone-mapped habitat, found
grayling associated with cool pools".

### 22. L432–437: an untested candidate factor presented as an observation from snorkel counts

**Wrong:** "Hagen and Stamford, from Parsnip snorkel counts, observe fewer adults in streams with long low-gradient
meanders" — the page lists this as one of nine example natural limiting factors the snorkel data could be used to
evaluate, in an analysis not yet done; it does not say the observation comes from the counts.
**Page:** Hagen and Stamford p. 51: "These data therefore provide a good opportunity for evaluating natural factors
limiting Arctic Grayling distribution … Examples include: … 3. Stream gradient: Our observation is that streams of the
Parsnip River watershed with extensive sections of low-gradient meanders have fewer adult grayling. … The process of
compiling these data and designing an analysis has begun."
**Fix:** "Hagen and Stamford list, among factors their Parsnip snorkel data could test (the analysis was not yet
done), their observation that streams with long low-gradient meanders have fewer adults, and cite Blackman (2004) for
Anzac adults in the deepest water".

### 23. L447–452: "Across the range, the larger fish hold the upstream positions"

**Wrong:** the page attributes the pattern to specific studies (Vascotto 1970; Hughes and Reynolds 1994; Hughes 1998a,
1999), not to the range; Stewart elsewhere places this work in Alaska (p. 19, "In McManus Creek, Alaska, … (Vascotto
1970)").
**Page:** Stewart p. 21: "They adopt a larger-older-fish-upstream distribution pattern (Vascotto 1970; Hughes and
Reynolds 1994; Hughes 1998a, 1999). … Headwater positions appeared to be preferred by grayling, and the larger fishes
were more successful competing for these positions (Hughes and Reynolds 1994)."
**Fix:** "In the streams Hughes and others studied (Northwest Territories review, citing Vascotto 1970, Hughes and
Reynolds 1994 and Hughes 1998a), the larger fish hold the upstream positions"; keep "appeared".

### 24. L475–480: Martins et al.'s overwintering quote sits under Blackman's sentence

**Wrong:** L480 is the 2018–2021 acoustic study, but the only sentence above it names Blackman's radio tags.
**Page:** Martins p. 32: "Overwintering assemblages of Arctic Grayling in the Parsnip River mainstem are concentrated
in the reaches near the confluences of the four study tributaries".
**Fix:** add before L480: "Martins et al.'s acoustic telemetry found the wintering fish gathered near the tributary
mouths:".

### 25. L494–496: Cannings and Ptolemy's deep-pools sentence under a Parsnip and BC subsection

**Wrong:** the sentence is Cannings and Ptolemy's summary of Northcote's (1995) literature review, not a BC or
Williston finding, yet it sits under "In the Parsnip, the mainstem" after the Sukunka sentence.
**Page:** Cannings and Ptolemy p. 47–48: "Northcote (1995) provides a summary of habitat requirements found in the
Arctic grayling literature. … Large deep pools are required for overwintering and holding water."
**Fix:** "Cannings and Ptolemy, summarising Northcote's (1995) review of the literature:", or move it to "Elsewhere".

### 26. L498–501: spring-fed overwintering stated without its hedge

**Wrong:** "grayling winter in spring-fed reaches, deep lakes and large rivers" turns "may be relatively common" into a
general fact; the review's examples also include the Yukon.
**Page:** Stewart p. 22: "The use of spring-fed tributaries by grayling for overwintering and perhaps spawning may be
relatively common (McCart 1974; Jessop and Lilley 1975; N. Mochnacz, pers. obs.)."
**Fix:** "grayling winter in deep lakes and large rivers, and the use of spring-fed reaches may be relatively common".

### 27. L556–559 (gaps): spawning sites "located" by the Parsnip telemetry, and no spawning stream sizes

**Wrong:** (a) the telemetry inferred spawning sites without seeing spawning (findings 10, 13); listing them as
located overstates. (b) "No source read gives the gradient or size of a stream where spawning was seen, other than the
artificial Sukunka channel" is contradicted by the evidence rows this branch added (House 2021, Pigeon Stream
Diversion NT: 3.0 m wide, 0.21 and 0.25 m3/s at peak spawn, rows 1203, 1223–1224; Cutting et al. 2018, Upper Red Rock
Creek, Montana, row 1226; Cannings and Ptolemy's Adsett Creek, BC), unless the sentence means the Williston
watershed, which it does not say. (c) "Hagen et al. 2026 call spawning and overwintering locations an information
gap" carries no quote.
**Page:** Hagen p. 26: "Imprecise knowledge of overwintering and spawning locations remains an important information
gap limiting conservation and recovery actions for these life stages"; Stamford p. 11, footnote 3: "While spawning was
not observed directly by Blackman (2002a)".
**Fix:** "No spawning site in the Williston watershed has been seen: the Parsnip telemetry (Anzac, Table, Hominka,
Missinka and the Parsnip mainstem) and fry captures infer them. No source read gives the gradient or size of a
Williston stream where spawning was seen; outside it, see the evidence rows." Quote the Hagen p. 26 sentence.

### 28. L562 (gaps): lacustrine grayling in BC

**Wrong:** the gap names only the Toodoggone, but the file quotes (L76) Stamford et al. that lake populations exist in
the lower Peace, also undescribed in any source read.
**Page:** Stamford p. 4: "but lake populations exist in the lower Peace watershed".
**Fix:** "The Toodoggone lake-inlet population and the lower Peace lake populations are named but not described".

### 29. L563–564 (gaps): "The Sukunka winter fry habitat was not found"

**Wrong:** the Sukunka study inferred it and saw fry in it in November.
**Page:** Stuart and Chislett p. 3: "the study indicates fry may overwinter in the cobbles of frozen sidechannels";
p. 68 (PDF 74): "Fry were observed in cobbles in ice-covered riffles in November and a downstream movement of one year
old grayling in June suggests fry over-wintered in the tributary."
**Fix:** "The Sukunka study infers, from fry in ice-covered cobble riffles in November, that fry winter in the cobbles
of frozen side channels; no BC study follows fry through a winter."

### 30. L565–567 (gaps): the list of BC primaries read only through reviews is incomplete

**Wrong:** the list reads as the whole set but leaves out other BC studies the file cites through a review: Blackman
and Hunter 2001 (L397), Zemlak and Langston 1998 (L421), Cowie and Blackman 2003 and 2004 (L337), McPhail 2007
(L299), McLean and Langston 1992 and Pollard and Miller 2011 (L74), O'Connor et al. 2026 (L92), Chu Cho Environmental
2018 (L362), Stamford and O'Connor 2022 (L227).
**Page:** as cited at each line.
**Fix:** add them, or say "among them".

### 31. Originals a quoted page names, left unnamed by the sentence

**Wrong:** the header (L12) says "Where a source reports another study, the sentence names it". These do not:
- L71–76: McLean and Langston 1992; Pollard and Miller 2011 (Williston lakes), Northcote 1993 (range).
- L99–101: the second quote's Armstrong 1986, Northcote 1993, Stewart et al. 2007.
- L103–105: Tripp and McCart 1974 (the Donnelly River fish).
- L247: Tack 1980; Armstrong 1986; Blackman 2002a; Stewart et al. 2007a.
- L326–328: the nine studies listed in finding 1 (BC, Alaska and Finland).
- L337: Cowie and Blackman 2003, 2004 (Ingenika, Osilinka, Omineca).
- L419: Birtwell et al. 1984; McLeay et al. 1987; Ott et al. 1998; Stewart et al. 2007.
- L460: Ballard and Shrimpton 2009; Hawkshaw and Shrimpton 2014, and "might present a somewhat unique picture".
- L482–484: Blackman 2002a; Blackman and Hunter 2001.
**Page:** each citation is in the parenthesis that follows the quoted words (e.g. Stewart p. 22 "… 4 October 1972
(Tripp and McCart 1974)"; Stamford p. 7 "… cooler fifth order streams (Ballard and Shrimpton 2009; Hawkshaw and
Shrimpton 2014)"; Stamford p. 14 "… overwintering areas used in the Parsnip mainstem (Blackman 2002a; Blackman and
Hunter 2001)").
**Fix:** name the originals in each sentence.

### 32. Facts in the prose that no quote carries

**Wrong:** "Every factual sentence carries a quote" (brief), but these details are only on the page, not in a quote:
L122 "from 2018 to 2021"; L274–275 "four adults (a male and three females)" and "Spawning was not seen".
**Page:** Martins p. 3: "A total of 157 grayling and 63 Bull Trout were tagged with acoustic transmitters between
2018-2021"; Stuart and Chislett p. 30: "Spawning activity was not observed but on June 3, disturbed gravel was
observed".
**Fix:** extend the L279 quote to start at "Spawning activity was not observed", and quote the Martins tagging
sentence or drop the years; the four adults are on p. 29 ("The male and three females were observed daily from June 1
to 8").

## Count

Statements checked: 136 quotes (every one, in page context) plus the header, the seven "In brief" bullets, every
section's lead and connecting sentence, and the five gaps bullets.

| kind | findings |
|---|---|
| hedge dropped | 2, 7, 9, 12, 13, 14, 16, 18, 19, 20, 26 (11) |
| claim beyond the page | 3, 10, 11, 21, 22 (5) |
| place or scope | 1, 23, 25 (3) |
| attribution | 17, 24, 31 (3) |
| life-history form | 5 (1) |
| qualification cut from the quoted sentence | 8 (1) |
| threshold values and row pointers | 4, 6, 15 (3) |
| gaps section | 27, 28, 29, 30 (4) |
| fact with no quote | 32 (1) |
| page number | none |
| **total** | **32** |
