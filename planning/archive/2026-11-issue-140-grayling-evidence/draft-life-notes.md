# Notes for `draft-life.md` (life drafter, #140 Phase 4)

## What was searched

Read in the extracted PDF text (`<scratchpad>/txt/<key>.txt`, page by page, and grep for spawn, gradient, winter,
fry, juvenile, temperature, homing, barrier, culvert, flow):
- `hagen_etal2026futureArctic`: executive summary (pp. iii–iv), section 3 Key life history attributes (pp. 5–7),
  section 5 distribution and critical habitats (pp. 15–27). Appendix A segment comments were grepped, not read in full.
- `stamford_etal2017FWCPArctic`: section 2 biology (pp. 3–20) in full; core-area critical habitat tables grepped.
- `stewart_etal2007Fishlife`: abstract and pp. 3–24 in full (life history types, Tables 1–4, sections 3.1–3.4).
- `stuart_chislett1979AspectsLife`: summary (PDF pp. 2–3), spawning and incubation (pp. 28–31), fry habitat (p. 36).
  The text layer is an OCR of a typescript with errors (for example "aluoet exelus-" for "almost exclusively"); I quoted
  only stretches that read cleanly and let 0280 decide.
- `martins_etal2022SpatialEcology`: executive summary (pp. 2–4) and discussion (p. 32).
- `bottoms_etal2023Criticalhabitats`: executive summary (pp. 6–7) and introduction (pp. 8–9).
- `hagen_stamford2023ParsnipArctic`: natural limiting factors (p. 51); critical habitat comments grepped.
- `cannings_ptolemy1998RareFreshwater`: the Williston Arctic grayling account (pp. 46–51) in full.
- `mcpherson2020Habitatuse`: abstract (pp. ii–iii).
- `tack1980Migrationsdistributions`: abstract (PDF pp. 3–4). The body's text layer is letter-spaced ("G r a y l i n g
  spawn ...") and was not used; quoting it would need OCR.
- `hagen_etal2015Criticalhabitats`: grepped; its life history paragraph (PDF p. 23) is the source of Stamford et al.
  2017's, which is quoted instead.
- Not used, after a look at the first pages: `house2021Interdisciplinaryapproaches` (Froude number at spawning sites,
  NWT; a rows matter, not life history), `cutting_etal2018Linkingbeaver` (beaver dams and spawning passage, Montana:
  the two-column text layer interleaves; could support the barrier paragraph with a `-layout` read),
  `hubert_etal1985Habitatsuitability` (already in the table), `culling1999BurntRiver` (snorkel notes),
  `beaudry2014Assessmentassignment` (watershed sensitivity), `carr_etal2020ImpactsVarying` (prairie reservoir),
  `t_silva_etal2017futurefish`, `willsonVariationSalmonid`, `whyte_etal1997Restoringfish`, `hagen_gantner2020AbundanceTrend`,
  `hagen_etal2019TrendAbundance`, `martins_etal2020SpatialEcology` (superseded by the 2022 report).
- The ragnar store was not queried: grep over the listed texts answered every topic.

## Statements that are also candidate rows (for the `rows` drafter)

- Stewart et al. 2007 Table 1 (p. 3): fluvial and adfluvial spawning and rearing habitat in "Small (~10 m wide),
  medium gradient tributary streams" (channel_width ~10 m, and a qual gradient statement, both stages).
- Stewart et al. 2007 p. 19: juveniles select channels 1 to 8 m wide, against channels wider than 14 m (Den Beste
  and McCart 1984; channel_width, rearing).
- Stewart et al. 2007 p. 21: adults' average stream width 10 m, channels under 6 m selected against (Den Beste and
  McCart 1984; adult summer, not rearing by the brief's definition).
- Stewart et al. 2007 Table 2 (p. 6): adult stream gradient 0.17–0.18 % on overwintering grounds (Stanislawski 1997,
  Little Smokey River, AB; overwintering gradient).
- Stuart and Chislett 1979 p. 29: spawning in an artificial overflow channel of 0.5 per cent gradient, 60 cm average
  wetted width, 30 cm maximum depth, substrate 15 % sand, 60 % gravel, 20 % cobble, 5 % boulder (gradient, width,
  substrate, spawning; artificial channel, held fish).
- Stamford et al. 2017 p. 16 and p. 8 (Hawkshaw et al. 2013): fry rearing in low-gradient middle reaches of 4th order
  and larger tributaries (stream_order and qual gradient, rearing).
- Stamford et al. 2017 p. 7: grayling appear more limited to cooler fifth-order streams (stream_order).
- Hagen et al. 2026 p. 7 (Hawkshaw and Shrimpton 2014): juveniles in 4th order and larger tributaries (stream_order,
  rearing); p. 7 low-gradient rearing reaches for all stages (qual gradient, rearing); p. 26 fry and juveniles in low
  gradient river margins (qual).
- Hagen and Stamford 2023 p. 51: fewer adults in streams with long low-gradient meanders (adult, qual); Blackman 2004
  adult depth 1.36 m and 0.36 m/s (adult depth and velocity).
- Stamford et al. 2017 p. 8: Parsnip newly emerged fry at about 0.1 m depth and 0.1 m/s (rearing depth and velocity;
  the depth prints as "0.l m" in the text layer); p. 9: Parsnip juveniles at 0.4–1.0 m depth (rearing depth).
- Stamford et al. 2017 p. 10: pea-sized unembedded gravel; Stewart et al. 2007 p. 14: gravel about 2.5 cm (substrate,
  spawning; check whether the table already holds them).
- Cannings and Ptolemy 1998 p. 48: Adsett Creek (Liard, BC) spawning over 2–4 cm gravel at 10–40 cm depth and 0.5 to
  1.0 (unit garbled in the text layer) (substrate, depth, velocity, spawning; Stewart et al. 1982 via Northcote 1995).
- Stewart et al. 2007 p. 22: overwintering in spring-fed Cache Creek at 0.5–1.5 m depth (overwintering depth).
- McPherson 2020 p. ii: YOY only in low-elevation, low-gradient habitat; p. iii adults above 1200 m (elevation).

## Left out, and why

- **Temperature numbers as thresholds** (fry preference 16.7 °C, Bottoms et al.'s TPREF 11.6 °C and TSET 10.1–13.0 °C,
  the 16 °C avoidance, Stewart's Table 2 limits): temperature is a separate topic; the file quotes temperature only
  as a cue (about 4 °C at arrival) and as a stated limiting factor.
- **Fecundity, egg size, growth and maximum age**: not asked for. Ages appear only where they bear on spawning.
- **Spawning behaviour** (male territories, lateral display): not asked for.
- **Stuart and Chislett's tagging tables (pp. 52–57)**: OCR is poor; the summary's statements were used instead.
- **The adfluvial/lake spawning detail from Alaska** (Stewart p. 16, Krueger 1981): left out as outside BC with no
  BC counterpart beyond the Toodoggone, which no source read describes.
- **Hagen et al. 2026 Appendix A** segment comments: not quoted one by one; the Phase 5 segment read covers them.
- **A claim I could not source**: that Williston grayling spawn in the Finlay, Omineca, Nation or Ingenika tributaries
  at named sites. Only fry captures (Ospika) and the Parsnip telemetry are stated.

## Originals cited by the reviews quoted, which we may want to hold

BC first:
- Blackman 2002a (Parsnip, Anzac and Table, report 254) and 2002b (radio telemetry, report 263): Stamford et al. 2017
  pp. 10–11, 14; the Parsnip spawning, summer and overwintering dates and sites.
- Blackman 2004 (Parsnip habitat use; adult depth 1.36 m, 0.36 m/s): Stamford et al. 2017 pp. 8–9, 12–13; Hagen and
  Stamford 2023 p. 51.
- Blackman and Hunter 2001 (Parsnip juveniles in the mainstem): Stamford et al. 2017 pp. 9, 13–14.
- Hawkshaw and Shrimpton 2014 and Hawkshaw et al. 2013 (juvenile occurrence, stream order, fry rearing reaches,
  16.7 °C): Stamford et al. 2017 pp. 7–8, 16; Hagen et al. 2026 p. 7.
- Ballard and Shrimpton 2009 (Omineca region, no adults above 14.5 °C; ages): Stamford et al. 2017 pp. 7, 11, 16.
- Mathias et al. 1998 (Parsnip fry habitat): Stamford et al. 2017 pp. 8, 12–13.
- Cowie and Blackman 2003, 2004, 2007 (fry habitat Ingenika, Osilinka, Omineca; Nation fry growth): Stamford et al.
  2017 pp. 8–9, 12.
- Zemlak and Langston 1998 (Parsnip adult pool use): Stamford et al. 2017 p. 9.
- Stewart et al. 1982 (Adsett Creek, Liard, BC; spawning at the tails of long runs): Stewart et al. 2007 p. 14 and
  Cannings and Ptolemy 1998 p. 48, both via Northcote 1995.
- Northcote 1995 (review of grayling habitat): Cannings and Ptolemy 1998 pp. 48–49; Stewart et al. 2007 tables.
- O'Connor et al. 2026 (Omineca fin ray microchemistry): Hagen et al. 2026 p. 16.
- Chu Cho Environmental 2018 (Upper Finlay beach seining): Hagen et al. 2026 p. 17.
- Stamford and O'Connor 2022 (Ospika fry): Hagen et al. 2026 p. 17.
- McPhail 2007 (BC maturity after the fifth summer): Stamford et al. 2017 p. 11.
- Mainstream 2012; Earthtone and Mainstream 2013 (lower Peace juveniles in the Peace mainstem): Stamford et al. 2017
  p. 9 (not quoted here).

Outside BC:
- Northcote 1993 (the three-habitat model): Hagen et al. 2026 p. 5; Stamford et al. 2017 p. 7.
- Den Beste and McCart 1984 (juvenile and adult channel widths, Alaska): Stewart et al. 2007 pp. 19, 21.
- Ott and Morris 2005, 2006 (spawning onset about 4 °C, Alaska): Stewart et al. 2007 p. 14.
- Clark 1992 (recruitment and stream flow, Alaska): Stamford et al. 2017 p. 12.
- Armstrong 1986, Tack 1972 (temperature cue): Stewart et al. 2007 p. 12; Stamford et al. 2017 p. 10.

## Unsure

- Hagen et al. 2026 p. 5 cites Stewart et al. 2007 for the single-watershed migrations; I kept Hagen's wording.
- Stuart and Chislett's quote on spawning dates ends at "in both 1977 and", because the text layer drops "1978"
  before the next paragraph; the summary (p. 2) gives the same dates in full.
- Stuart and Chislett's summary and Tack's abstract carry no printed page number; both are cited by PDF page, as the
  file's header says. Stuart and Chislett's PDF page 44 prints 36 and its page 43 prints 37 (figure pages out of order).
- The prose's statement that Blackman's fish wintered in shallow, faster water is Stamford et al.'s report of
  Blackman 2002b; Stamford et al. also say overwintering may not limit the Parsnip population (p. 14, not quoted).

- Two quotes are checked against OCR (`, OCR`): the Sukunka summary's sentences on juvenile movement (PDF p. 3) and
  on mainstem spawning (PDF p. 2), which the text layer splits or hyphenates. The Sukunka sentence on juveniles in
  pools could not be matched and is quoted instead through Cannings and Ptolemy 1998 p. 48.
- Stewart et al. 2007 p. 21's "larger-older-fish-upstream" did not match (the text layer drops the line-end hyphen);
  the two sentences after it are quoted instead.

## Gate result

`QUOTED=planning/active/draft-life.md 0280` (third run, 2026-11-26): 136 quotes, 136 pass (134 `verified_text`,
2 `verified_ocr`). Five quotes match on more than one PDF page (Stewart et al. pp. v and 17, also on PDF pp. 43–44, the
report's summary; Hagen et al. p. 7, also on PDF pp. 96 and 111, its appendices); each matches its cited page.
The run exits 1 because of 42 evidence-table rows that are not mine: 32 `bjornn_reiser1991HabitatRequirements`,
8 `hubert_etal1985Habitatsuitability` and 2 `ford_etal1995LiteratureReviews`, all `ocr` rows reported
`quote_not_found` (their OCR copies on this machine, `*_ocr.pdf`, may differ from the ones they were written against).
