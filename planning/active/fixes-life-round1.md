# Fixes, round 1: `research/grayling_life_history.md`

Each finding of `audit-life-round1.md` was checked on its page (`<scratchpad>/txt/<key>.txt`, printed pages from
`<key>.layout.txt`, OCR from `data/rag/ocr/` where the citation says OCR). The file was also revised for Task 2: the
originals filed for #140 were read and replace the reviews' reports of them. Line numbers below are the audit's (the
file as of commit `e4f43538`); the file has since been rewritten, so the fix names the passage, not a line.

## Findings

| # | verdict | what changed | why (page) |
|---|---|---|---|
| 1 | accepted | Header now lists "range-wide where a review states it so" (and Alberta, Adsett Creek). Each listed passage opens "Across the range" or names the summary it comes from: spawning-site range, substrate, "no redd" (now "the Northwest Territories review"), structural elements and homing and deep pools (Cannings and Ptolemy "summarising Northcote's (1995) review"), fry margins, fry shift, clear streams, temperature, sediment, culverts. The Clark 1992 passage now quotes the whole sentence and places it on the Chena River. | Stamford p. 8 and p. 10 and Hagen p. 7 cite range-wide lists; Stamford p. 12 "Tack (1974) noted absence of a whole year class in Chena River ... and Clark (1992) found ...". |
| 2 | accepted | Lead: Sukunka "estimated, from fry development", Parsnip "from telemetry and fry emergence", Adsett "apparent"; "In BC no study has watched it". | Stuart and Chislett p. 31; Blackman telemetry p. ii "observation of spawning activities impossible". |
| 3 | accepted | Lead: "Floods or drought in the two weeks after hatching may kill many fry". Body: "flooding or drought in the first two weeks may cause high fry mortality". The year-class claim is now Blackman's literature statement, attributed, and the Sukunka failure is "high flows and heavy sediment in July and August 1976". | Stewart p. 17 "may cause high mortalities"; Stuart and Chislett p. 68 "extremely high Flows ... during July and August 1976"; Blackman telemetry p. 19. |
| 4 | accepted | Every data-row number removed (old L14–15, L44, L259, L350); values point to "the evidence table's grayling rows". | Rows are being renumbered by the `rows` agent; a later file cites rows. |
| 5 | accepted | "for fluvial populations and for adfluvial or lake-dwelling ones". | Stewart p. 3, Table 1 columns. |
| 6 | accepted | Quote kept; the sentence says the table's width and gradient are the evidence table's grayling rows, not restated. | Stewart p. 3. |
| 7 | accepted | "the review says some grayling may spend part or all of their lives". | Stewart p. 22 "may". |
| 8 | accepted | Hagen p. 6 quote extended through "previously thought"; lead and body add "though eDNA and occasional captures suggest some move through it". Added Blackman's three tagged fish in the reservoir, none returning to spawn. | Hagen p. 6; Blackman telemetry p. 17. |
| 9 | accepted | "Stamford et al. 2017, citing studies in Alaska and the Parsnip (Tack 1980, Buzby and Deegan 2000, Blackman 2002a, Gryska 2006, Earth Tone and Mainstream 2013), say these suggest ... may share". | Stamford p. 10. |
| 10 | accepted | Martins: "the second a spring migration into the middle reaches of four tributaries, which they read as a spawning migration". The Stamford report of Blackman's spawning sites ("mostly in the lower reaches") is replaced by Blackman's original: fish beside, not on, spawning water; no exact site; two Anzac areas (3 km above the mouth; km 12–22, multi-channel), set beside Martins's middle reaches. | Martins p. 3, p. 32; Hagen p. 16; Blackman telemetry p. 13, p. 18. |
| 11 | accepted | "gives a similar calendar"; the fall dates now come from the original: Table fish by 19 September, Anzac fish by 6 November (no flight 24 September–6 November), early October the next year. | Blackman telemetry p. 9, p. ii; Martins p. 32. |
| 12 | accepted | "Tack suggests the run is probably triggered by the first warming to 1 °C". | Tack p. 3. |
| 13 | accepted | "their summary has spawning in the mainstem and in small tributaries, from telemetry that flagged movements into tributaries possibly for spawning", with the "flagged movements" sentence quoted. | Hagen p. 16. |
| 14 | accepted | "Tack (Alaska) advances the hypothesis". | Tack p. 3. |
| 15 | accepted | No rows added (the evidence table is the other agent's). Each quote printing a depth, width, gradient or velocity now says whether it is a limit or where fish were: Sukunka channel ("an artificial channel holding four trapped adults, not a measure of where grayling choose to spawn"); Parsnip fry and yearling depths (now quoted from Blackman 2004 and Blackman and Hunter 2001, "where fry/yearlings were caught, not limits"); Den Beste and McCart widths, juveniles and adults ("where ... were, not limits"); Cache Creek depth; Osilinka 0.1 %, Little Smoky 0.17–0.18 %, Adsett gravel and depth. Stream order points to the grayling rows. Candidate rows for the `rows` agent: the values listed in "Candidate rows" below. | Pages as quoted. |
| 16 | accepted | "say relatively precise homing has been suggested for many stream populations (mostly Alaskan studies, and Blackman 2002a in the Parsnip), with adults sometimes switching sites after a poor spring". Added Blackman's own count (6 of 18 spawned away from the tagging stream). | Stamford p. 10; Blackman telemetry p. 16, p. 18. |
| 17 | accepted | Own lead-in: "Cannings and Ptolemy, summarising Northcote's (1995) review of grayling in general". | Cannings and Ptolemy pp. 47–48. |
| 18 | accepted | "The eggs may be covered by up to 5 cm of gravel". | Stewart p. 15. |
| 19 | accepted | "fry emerged on 27 June from the two areas of gravel disturbed on 3 June, which the authors call possible spawning sites, and from a third area of quiet water", quote extended through "near the inlet of the channel". | Stuart and Chislett p. 30. |
| 20 | accepted | Now quoted from the original: "Juvenile grayling also appear to select for narrow channel widths (1 to 8 m wide)"; sentence "appeared to select". (The original's text layer drops "14 m", so only the 1–8 m half is quoted.) | Den Beste and McCart p. 34. |
| 21 | accepted, wording changed | "snorkel surveys in July to September 2022 found grayling associated with cool pools", with the dates quoted. The audit's "over drone-mapped habitat" was not adopted: the drone sentence is not in the quoted passage. | Bottoms p. 6. |
| 22 | accepted | "Hagen and Stamford list, among natural factors their Parsnip snorkel counts could be used to evaluate (an analysis not yet done), their observation ...", with the "good opportunity for evaluating" and "designing an analysis has begun" sentences quoted. The Blackman (2004) Anzac depth passage is now quoted from Blackman 2004 itself (finding 31, Task 2). | Hagen and Stamford p. 51; Blackman 2004 p. 10. |
| 23 | accepted | "In the studies it cites (Vascotto 1970, Hughes and Reynolds 1994, Hughes 1998a), the Northwest Territories review reports ..."; "appeared" kept. | Stewart p. 21. |
| 24 | accepted | Martins quote now under its own sentence: "Martins et al.'s acoustic telemetry found the wintering fish gathered near the tributary mouths". | Martins p. 32. |
| 25 | accepted | "Cannings and Ptolemy, summarising Northcote's (1995) review of the literature", moved out of the Parsnip paragraph under "Small BC streams". | Cannings and Ptolemy pp. 47–48. |
| 26 | accepted | "grayling winter in deep lakes and large rivers, and the use of spring-fed reaches may be relatively common". | Stewart p. 22. |
| 27 | accepted | Gap rewritten: no Williston spawning site seen; the telemetry's suspected areas and the fry infer them; egg searches (Anzac, Sukunka) found none; Hagen p. 26 information-gap sentence quoted; "No source read gives the gradient or size of a Williston stream where spawning was seen"; in BC only Adsett Creek's spawning areas are described; outside BC, the evidence rows. | Hagen p. 26; Blackman telemetry p. 13; Blackman and Hunter p. 11; Stuart and Chislett p. 30. |
| 28 | accepted | "The Toodoggone lake-inlet population and the lower Peace lake populations are named but not described", plus the Mesilinka above-lake grayling named only through Cowie and Blackman's citation. | Stamford p. 4; Cowie and Blackman 2007 p. 11. |
| 29 | accepted | "The Sukunka study infers, from fry in ice-covered cobble riffles in November, that fry winter in the cobbles of frozen side channels ... no BC study follows fry or juveniles through a winter", with the p. 68 sentence quoted in the body. | Stuart and Chislett p. 3, p. 68. |
| 30 | accepted | List rewritten as "Among them", and the originals now read are taken off it (Task 2c). | — |
| 31 | accepted | Originals named: Stamford p. 4 (McLean and Langston 1992, Pollard and Miller 2011, Northcote 1993); Hagen p. 5 second quote (Armstrong 1986, Northcote 1993, Stewart et al. 2007); Donnelly River (Tripp and McCart 1974); spawning-site range (Tack 1980, Armstrong 1986, Blackman 2002a, Stewart et al. 2007); fry margins ("nine studies from BC, Alaska and Finland (among them ...)"); clear streams (Birtwell et al. 1984, McLeay et al. 1987, Ott et al. 1998, Stewart et al. 2007); Stamford p. 7 (Ballard and Shrimpton 2009, Hawkshaw and Shrimpton 2014; "might present a somewhat unique picture" kept in the quote). The Cowie and Blackman (p. 12) and Blackman and Hunter / Blackman (p. 14) reports are replaced by the originals. | Each review page's parenthesis. |
| 32 | accepted | Martins's years dropped (the text layer reads "20182021", which a quote cannot carry). Sukunka: "four adults caught in a trap (a male and three females)" and "Spawning was not seen", carried by quotes from p. 29 ("were taken in the upstream trap and held in the overflow with the male and first female"; "The male and three females were observed daily from June 1 to 8") and p. 30 ("Spawning activity was not observed but on June 3, disturbed gravel was observed"). | Martins p. 3; Stuart and Chislett pp. 29–30. |

## Task 2: originals

**(a) Review statements re-quoted from the originals.** Where the original says something different, the file now says
what the original says:

| statement (review) | original | difference |
|---|---|---|
| Parsnip spring migration, late April–early May, 9–71 km (Stamford p. 11) | Blackman telemetry p. 9 | same; original adds 13 of 18, break-up |
| Summer homing in July, "high site fidelity" (Stamford p. 11) | telemetry p. 9 | original: 8 of 18 presumed spawners returned |
| Fall move in September–October, "may have been triggered by a drop in water temperature" (Stamford p. 11) | telemetry p. 9, p. ii | original: Table by 19 Sept, Anzac by 6 Nov, early October next year; no temperature trigger stated |
| Parsnip arrival at about 4 °C (Stamford p. 10) | telemetry p. 16 | original: run starts at break-up above 0 °C; estimated spawning start coincides with 4 °C |
| Spawning late May–late June, inferred (Stamford p. 11 and note 3) | telemetry p. ii, p. 16 | original: late May–mid June (abstract), 29 May–25 June, "may have been a week late" |
| Spawning sites "mostly in the lower reaches of the Anzac and Table ... side channels with small gravel" (Stamford p. 11) | telemetry p. 13, p. 18 | original: no exact site; fish beside spawning water; two Anzac areas; too few Table fish; Parsnip side channels; suspected areas multi-channel glides with < 3 cm gravel |
| Adsett Creek spawning (Cannings and Ptolemy via Northcote 1995) | Stewart et al. 1982 p. 31 | same; original adds 4–5 km above the Prophet, peak 16–23 May |
| Parsnip newly emerged fry at ~0.1 m and ~0.1 m/s (Stamford p. 8, Mathias et al. and Blackman 2004) | Blackman 2004 p. 7 | Mathias et al. 1998 (p. 30) say fry habitat "cannot yet be described"; Blackman 2004 gives average 12 cm and < 0.1 m/s, Table and Anzac |
| Upstream end of fry habitat at gravel to cobble (Stamford p. 8) | Blackman 2004 p. 11 | same |
| Alcoves, side and back channels in four systems (Stamford p. 12) | Cowie and Blackman 2003 p. i, p. 9; 2004 p. i; Mathias p. 48; Blackman and Hunter p. 13 | originals add isolated pools on bars (46–85 %) |
| Parsnip juveniles in the mainstem, 0.4–1.0 m (Stamford p. 9) | Blackman and Hunter p. i, p. 29, p. 30 | same; original adds < 0.20 m/s and "may be the primary rearing area" |
| Juvenile rearing downstream in larger mainstems (Stamford p. 13) | Blackman and Hunter p. 30; Cowie and Blackman 2012 p. 6 | same, as a hedged reading |
| Juvenile channel widths (Stewart 2007 p. 19) | Den Beste and McCart p. 34 | same ("appear to select") |
| Adult pools > 60 %, riffles < 1 % (Stamford p. 9) | Blackman 2004 p. 10 | original: 63 % pools, 22 % glides, 15 % runs, < 1 % riffles (Table and Anzac pooled) |
| Anzac adults "at or near the edge of the thalweg" (Hagen and Stamford p. 51) | Blackman 2004 p. 10 | original: "at or near the thalweg" (no "edge of") |
| Adult channel widths (Stewart 2007 p. 21) | Den Beste and McCart p. 35 | same |
| Juvenile occurrence, distance and stream order (Hagen p. 7) | Hawkshaw and Shrimpton pp. 25, 29, 31 | original: absent below 4th order, present or absent above (order predicts only absence); product of distance and order; short tributaries (< 79 km) unlikely |
| "cooler fifth order streams" (Stamford p. 7) | Hawkshaw and Shrimpton; Ballard and Shrimpton | neither original says fifth order; Stamford's quote kept as its synthesis, with that said |
| Overwintering in the Parsnip mainstem, shallow faster water (Stamford p. 11) | telemetry p. 9, p. 13, p. 17, p. 18 | same; original adds no concentrations, one fish in the tributaries, winter habitat may not be limiting |
| "Virtual absence" of wintering fish in lower Anzac and Table (Stamford p. 14) | telemetry p. 13 | original: one tagged fish stayed in the tagging streams; juveniles not studied in winter |
| No adults above 14.5 °C, Omineca (Stamford p. 16) | Ballard and Shrimpton p. 45 | original: "fish", not adults; "must be ... interpreted with caution"; Peace Region range 1–25 °C |
| Parsnip natal homing (Stamford p. 10 citing Blackman 2002a) | telemetry p. 16, p. 18 | original: 6 of 18 spawned away from the tagging stream |

Kept as the review's, and said so: Stamford's range-wide syntheses; Stamford's p. 13 pools-in-moderate-gradient
judgement (citing originals); Stamford's report of Hawkshaw et al. 2013 (the library holds its abstract only; not
quoted); Hagen et al.'s Williston summaries.

**(b) Statements added** from the originals, in the existing sections, BC first: Williston forms and lakes (reservoir
passage, fluvial only, lakes unused, Nation/Osilinka/Mesilinka lakes); annual distances; spawning-stream switching;
the Parsnip annual cycle (Cowie and Blackman 2012); fall dates; the Adsett Creek cue, summer residence and fall
emigration; Little Smoky fall migration; Adsett, Parsnip (1997, 1998) and Nation timing and emergence; Adsett
turbidity; Ballard's few Omineca spawning areas; the Anzac suspected areas, the km 14–20 reach and the empty egg search;
2005 Parsnip tributary fry; the Osilinka reach; steep cobble reaches limiting spawning; Nation cobble spawning
(hedged); Sukunka egg search; Adsett age at maturity; Adsett incubation; fry habitat in the Table, Anzac, Ingenika,
Osilinka, Omineca and Nation; fry staying shallow in the Table and Anzac; drift, fyke nets, flow-driven emigration and
stranding; Sukunka winter fry; Table and Anzac adult habitat, wood and late-summer concentration upstream; Adsett
steep sections and diet; Hawkshaw and Shrimpton's gradient model and east-side absence; Parsnip winter habitat;
Ballard's winter gap; Adsett and Little Smoky winter habitat; Den Beste and McCart's winter limit; flood and stranding
statements. About 55 statements, counted by paragraph.

**(c)** The gaps section and the list of primaries read only through reviews are rewritten to match what is now held.

## Candidate rows for the `rows` agent (values quoted here that may not be rows)

- Osilinka fry reach gradient 0.1 % (Cowie and Blackman 2003 p. 9; rearing, where fry were).
- Little Smoky overwintering mean gradient 0.17–0.18 % (Stanislawski 1997 p. 42, OCR; Alberta).
- Parsnip yearlings < 0.20 m/s and 0.40–1.0 m depth (Blackman and Hunter 2001 p. 30).
- Table and Anzac fry average 12 cm depth, < 0.1 m/s (Blackman 2004 p. 7).
- Anzac suspected spawning areas, gravel < 3 cm (Blackman telemetry p. 18).
- Adsett Creek spawning gravel 20–40 mm, depth 0.1–0.4 m (Stewart et al. 1982 p. 31, OCR).
- Den Beste and McCart adult channel width 10 m, < 6 m selected against (p. 35; adult, notes by the brief).
- Hawkshaw and Shrimpton juveniles absent below 4th order (p. 25); tributaries < 79 km unlikely (p. 31).
- Cache Creek overwintering depth 0.5–1.5 m (Stewart 2007 p. 22).

## Gate

`QUOTED=research/grayling_life_history.md 0280` (fourth run, 2026-11-26): 242 quotes, 242 pass (218 `verified_text`,
24 `verified_ocr`). Every quote's printed page was checked against the PDF page the log gives it. Five quotes match on
more than one PDF page (Stewart 2007 pp. v and 17, also on its summary pages; Hagen p. 7, also on appendix pages); each
matches its cited page. Six Adsett Creek quotes failed on the first run, where the scan misreads "1" as "|"; they were
cut to the clean text-layer passages or skip the misread word with ` ... `, and the prose dropped the numbers the quotes
no longer carry. The run exits 1 on 42 evidence-table `ocr` rows that are not this file's (32 Bjornn and Reiser, 8
Hubert et al., 2 Ford et al.).

## Counts

| | count |
|---|---|
| findings accepted | 32 (one, 21, with different wording) |
| findings declined | 0 |
| review statements re-quoted from originals | 22 |
| statements added from originals | about 55 |
| quotes in the file | 242 (136 before) |
| quotes passing 0280 | 242 of 242 |
