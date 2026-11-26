# Draft rows notes: Arctic grayling habitat rows (#140, Phase 3)

Draft: `planning/active/draft-rows-evidence.csv`, 65 rows, appended after data row 1189 (data rows 1190-1254 in the
merged check). Grouped by variable, then stage. Every row passes `scripts/0280-literature-verify.R` (51 text, 9
table, 5 ocr). No cell needed a `none` row.

## How I searched

- Grep (page by page, form feeds kept) of every listed source's `.txt` and `.layout.txt` for gradient, slope,
  width, wide, wetted, bankfull, m3/s, discharge, cfs, stream order and "Nth order", then reading each hit's page.
- `bull_trout_grayling` ragnar store: five hybrid queries (spawning gradient; fry rearing stream width; spawning
  discharge; juvenile stream order; overwintering habitat). Every result row was `hybrid`, none `bm25`. They led to
  Cannings and Ptolemy 1998 (Adsett Creek), Stewart et al. 2007 pp. 17-18 and Tack 1980's spawning-stream passages.
- Nothing relevant to the grid in `carr_etal2020ImpactsVarying`, `beaudry2014Assessmentassignment`,
  `t_silva_etal2017futurefish`, `willsonVariationSalmonid`, `culling1999BurntRiver`. `bottoms_etal2023`,
  `hagen_gantner2020`, `hagen_etal2019`, `hagen_stamford2023` and `martins_etal2020` speak to adult summer habitat
  only (below).

## Per grid cell

### gradient / spawning (`spawn_gradient_max`): 3 qual rows, no number
- Stewart et al. 2007 p. 3 (Table 1, "medium gradient tributary streams"), Cutting et al. 2018 p. 12907 (Upper Red
  Rock Creek, a "low gradient mountain stream", adfluvial), McPherson 2020 p. 54 ("gentle gradient", spawning
  inferred from young-of-year).
- No source gives a spawning gradient as a number at a natural site. The only number: Stuart and Chislett 1979
  pp. 29-30 (PDF 35-36), the trap's overflow channel, "18 m long, 0.5 per cent gradient", average wetted width 60 cm,
  where four captive adults held by the authors spawned (disturbed gravel, fry emerged). Left out as a row: the
  fish did not choose it. Say if you want it as a row with that note.

### gradient / rearing (`rear_gradient_max`): 8 qual rows, no number
- Stewart 2007 p. 3; Hagen et al. 2015 p. 15; Stamford et al. 2017 pp. 7 and 16; Hagen et al. 2026 pp. 7 and 26;
  McPherson 2020 pp. 30 and 54.
- Hagen 2015 p. 15, Stamford 2017 p. 7 and Hagen 2026 p. 7 are nearly one sentence passed down (shared authors,
  near-identical source lists), so they are one claim, not three. Their "rearing" covers every life stage.
- Numbers found are not juvenile rearing: Hubert et al. 1985 p. 6 (adult section) quotes Vincent (1962) defining
  "Arctic grayling habitat" as gradient 0.09-0.28 % with a maximum of 0.38 %, and Liknes (1981) most abundant at
  0.29 % (Montana). Martins et al. 2020 pp. 10-11 and 2022 pp. 11-12 (and Bottoms et al. 2023 p. 11) give the
  Anzac and Table rivers' average gradient 0.7 %, upper 1-2 %, lower < 0.5 % (Blackman 2002a): adult summer rivers.

### channel_width / spawning (`spawn_channel_width_min`): 2 values, 10 qual rows
- Values: Stewart 2007 p. 3, Table 1 class "~10 m wide" (kind `expert`, a class description); House 2021 p. 71,
  the Pigeon Stream Diversion "averages 3.0 m in width" (a constructed channel at Ekati, NT, where spawners were
  observed).
- Qual: Hagen 2015 pp. 16 and 55, Hagen 2026 pp. 6 and B-6, Tack 1980 PDF pp. 18 and 29, Cannings and Ptolemy
  1998 p. 49, Whyte et al. 1997 p. 5-2, Hubert 1985 p. 5, Martins 2022 p. 3. Together they say spawning spans large
  mainstem rivers (Parsnip, Tanana-system rivers) to small bog-fed tributaries; Hagen 2026 B-6 says Williston
  spawning has been described only for large rivers (Parsnip, Anzac, Table) and natal tributaries remain
  undescribed.

### channel_width / rearing (`rear_channel_width_min`): 3 values, 2 qual rows
- Stewart 2007 p. 3 (Table 1, ~10 m); Stewart p. 19, juveniles selected channels 1 to 8 m wide (`optimum`, `pref`)
  and selected against channels wider than 14 m (`max`, `pref`, no parameter: the model has no maximum width),
  from Den Beste and McCart 1984 (Alaska). Qual: Stewart p. 18 (small tributaries), Hubert p. 5 (fry stay in the
  small spawning streams).
- Cannot hold: McPherson 2020 p. 32 Table 3 gives width in cm (young-of-year sites 132-998 cm, mean 413.6;
  juvenile sites 77-1190 cm, mean 424.4). The vocabulary's width units are `m bankfull`, `m wetted`, `m`, `ft`,
  and the brief says never convert. Width (wetted) did not predict young-of-year or juvenile presence alone
  (Table 4) but entered the top young-of-year model (Table 5).

### discharge / spawning (`spawn_mad_min`): 5 values, 1 qual row
- House 2021 p. 104: spawning across 34 location-years at flows of 0.096 to 33.90 m3/s; p. 74: the Pigeon Stream
  Diversion carried 0.21 m3/s (2014) and 0.25 m3/s (2015) at peak spawn; p. 80: the Fond du Lac River (SK)
  spawning discharge "in the order of 400 m3/s" (Golder Associates 2013). Cutting 2018 p. 12907: Upper Red Rock
  Creek's annual peak discharge 1.9-8.3 m3/s (mean 4.2). Tack 1980 PDF p. 18 (qual): bog streams that dry in late
  summer are used for spawning.
- None of these is MAD: they are flows on or near the spawning day, or the annual peak. Each note says which.
- House p. 104 also gives unit discharge near peak spawn, mostly 0.001-0.04 m3/s/km2 (range 0.00069-0.079); no
  vocabulary unit for it. Unsure: whether the 0.096-33.90 range is of peak-day flows only or of every plotted day
  (Figure 4-2 plots discharge against day of spawn); the note says the text does not settle it.

### discharge / rearing (`rear_mad_min`): 2 values
- Stuart and Chislett 1979 p. 41 (OCR): flows in the tributary and sidechannel pools used by 2+ juveniles in
  summer were 1-15, and in Sukunka mainstem pools 21-65. The scan prints "m/s" (the OCR reads "m?/s" for the
  first); the glossary (p. 77) defines flow as velocity x depth x wetted width, and Appendix 3 heads the column
  "Flow (m3/s)", so I coded `m3/s`. Unsure: this rests on reading a lost superscript; check against the scan.
- No other source gives a stream size as discharge for fry or juveniles. Hagen 2026 Appendix B (PDF pp. 106-107)
  models August flow as a percent of MAD with an optimum at 57 % MAD (36-96 %), adapted from Rosenfeld and Enright
  (2025): a flow need, not stream size, and not measured on grayling, so not written here. It bears on the
  existing GR `instream_flow` `none` rows (data rows 997-1001), which a later pass may want to revisit.

## Extra rows
- gradient / overwintering: Stewart 2007 p. 6, Table 2: 0.17-0.18 % on adult overwintering grounds (Stanislawski
  1997, Little Smoky River, AB).
- channel_width / overwintering (qual): Stewart p. 18, Hagen 2015 p. 15, Hagen 2026 p. 6, Martins 2022 p. 32.
- stream_order / rearing: Hagen 2026 p. 7 (juvenile occurrence in 4th order and larger tributaries, Hawkshaw and
  Shrimpton 2014, with footnote 3's hedge in the note); Stamford 2017 p. 16 (fry rearing areas, "e.g. 4th order and
  larger", Hawkshaw et al. 2013); Stamford p. 7 ("appear more limited to cooler fifth order streams"). The 4th and
  5th order statements differ; both are relayed, neither original is held.
- lake_area: Cutting 2018, Upper Red Rock Lake 893 ha (adfluvial). Coded `overwintering` because the population
  lives in the lake outside the spawning season and the vocabulary has no adult-residence stage; no parameter.
  Unsure: `rearing` with `rear_lake_ha_min` would claim juvenile rearing, which the page does not state.
- substrate / spawning (qual): Hagen 2015 p. 16, Stewart p. 14 (about 2.5 cm), Cannings p. 48 (2-4 cm). Substrate
  is held in mm; the rows do not convert, so they are `qual` with the cm values in the quote and note.
- groundwater (qual): Stewart p. 28 (spawning), Stewart p. 3 Table 1 (stream-resident fish overwinter in deep,
  often spring-fed pools; `resident`).
- elevation / rearing: McPherson p. 32, young-of-year sites 965-1103 m (NT; local, likely of little use for BC).
- depth: spawning Cannings p. 48 (10-40 cm, Adsett Creek BC), House p. 80 (0.15-0.86 m, Fond du Lac); rearing
  Stewart p. 17 (5-50 cm and preferred 6-31 cm, young-of-year), Stewart p. 6 (juveniles 0.2-0.8 m), Stuart and
  Chislett p. 36 (fry to 50 cm, same quote as data row 912's velocity), McPherson p. 32 (young-of-year 20.2-68.5
  cm, juvenile 19.1-68.5 cm). The table held no GR rearing depth before.
- velocity: spawning Cannings p. 48 (0.5-1.0, printed "ms"), House p. 74 (0.32 m/s mean), House p. 80 (0.0-1.26
  m/s); rearing Stamford p. 8 (newly emerged fry, about 0.1 m/s), McPherson p. 32 (young-of-year 0-1.12, juvenile
  0.23-1.12 m/s).

## What the sources say that the table cannot hold
- Adults' summer habitat (no `adult` life stage): Stewart p. 21 (adults averaged 10 m wide streams and selected
  against channels < 6 m, Den Beste and McCart 1984); Hagen and Stamford 2023 p. 24 Table 5 (mean wetted widths
  15.6-30.1 m of adult snorkel index sections, Anzac and Table rivers); Hagen and Stamford 2023 p. 51 and
  Hagen and Gantner 2020 p. 21 (fewer adults in long low-gradient meanders); Tack 1980 PDF pp. 19-20 (subadults in
  headwaters under 0.5 m wide, only adults where 1.0-1.5 m wide); Hubert p. 6 (Vincent 1962, Liknes 1981 gradients
  above); McPherson p. 44 (sub-adults and adults at higher, colder, wider sites).
- Stamford 2017 p. 97: extant Williston populations "require larger (5th order and larger) streams to complete
  their life history" (Williamson and Zimmerman 2004, 2005; Clarke et al. 2005; Hawkshaw et al. 2013): a whole-life
  statement with no stage, left out. Hagen 2026 Figure B 11 (system capacity against unflooded 4th order and larger
  mainstem length) is a model input, not a habitat value.
- Stewart p. 5: Hershey et al. 2006's CART, grayling present in lakes linked to streams of average gradient
  <= 4.6 % (and deeper lakes where steeper): lake occurrence, not a stream habitat cell.
- Stamford 2017 pp. 29-31, Table 3: watershed area and stream order of every core-area sub-basin (descriptive, not
  habitat use).
- Stamford p. 8 prints the fry depth as "approximately 0.l m" (letter l): no depth row written.
- Cutting 2018: drainage area (110 km2) and elevation (2,017 m) of Upper Red Rock Creek, whose text layer garbles
  the superscript; not written.
- Stewart Table 2's young-of-year depth 0.05-0.5 m duplicates the text's 5-50 cm (one row written); Stewart p. 18,
  Tyee Lake young-of-year in littoral depths 0.02-0.46 m (lake habitat).
- Stuart and Chislett 1979 Appendix 3 (PDF pp. 102-114): per-habitat tables of wetted width, gradient and flow for
  pools, riffles, runs and side channels used by each age class. The OCR is too garbled to quote a row reliably.

## Unsure
- Stewart Table 1 width as `expert`: it is the review's habitat class, not a measured distribution or a limit.
- The Stuart and Chislett flow unit (above) and the House p. 104 range (above).
- McPherson's spawning statement rests on young-of-year, not observed spawners.
- Stamford p. 7's fifth-order row is coded `rearing`; the paragraph is about rearing of every life stage.

## Originals cited by reviews for values used (not in the source list)
- Stanislawski 1997 (Stewart 2007 p. 6, Table 2; source 51, p. 8): overwintering gradient.
- Den Beste and McCart 1984 (Stewart 2007 p. 19, and Table 2 p. 6 as source 43): juvenile widths and depth.
- Vascotto 1970; Evans et al. 2002 (Stewart p. 6, Table 2): juvenile depth.
- Vascotto 1970; de Bruyn and McCart 1974; Lee 1985; Kaya 1989; Deleray 1991; McClure and Gould 1991; Jones et
  al. 2003a; Birtwell et al. 1984; Deegan et al. 2005 (Stewart p. 17): young-of-year depths. (Ford et al. 1995 and
  Stuart and Chislett 1979, also cited there, are held.)
- Hawkshaw and Shrimpton 2014 (Hagen 2026 p. 7; Stamford 2017 p. 7); Hawkshaw et al. 2013 (Stamford p. 16);
  Ballard and Shrimpton 2009 (Stamford p. 7): stream order.
- Mathias et al. 1998; Blackman 2004 (Stamford p. 8): fry velocity.
- Golder Associates 2013 (House pp. 80): Fond du Lac discharge, depth, velocity.
- ERM 2015, 2016 (House p. 74): Pigeon Stream Diversion flows and velocity.
- Moshenko and Low 1983; Steed 2007; Shepard and Oswald 1990; Bond and Machniak 1977; Fleming 1995; Ekati
  monitoring reports by Dillon Consulting, Rescan and ERM (House pp. 100-101): the 0.096-33.90 m3/s range.
- Stewart et al. 1982 (Stewart 2007 p. 14, via Northcote 1995): Adsett Creek spawning, the likely source of
  Cannings and Ptolemy p. 48's depth and velocity, which name no source.
- Qual rows' cited sources are in their `cited_source` cells (Tack 1980 and Stuart and Chislett 1979 among them are
  held).

## Check run
`0280` on the merged table: all 65 draft rows verified. 42 existing rows fail `quote_not_found` on this machine
(`bjornn_reiser1991HabitatRequirements` 32, `hubert_etal1985Habitatsuitability` 8,
`ford_etal1995LiteratureReviews` 2), which makes the run exit 1; they are not this draft's.
