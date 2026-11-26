# Fixes, round 1: grayling rows (data rows 1190 on)

Applies `audit-rows-round1.md` to `data/literature_evidence.csv`, re-quotes rows whose value a review relays from
an original now held, and appends rows read from the originals filed for #140. Only data rows 1190 on were touched
(lines 1-1190 of the file are byte-identical to before). Data rows now run to 1304: 65 drafted, 50 new.

Check: `LOG=<scratchpad>/verify-fix-rows.csv QUOTED= Rscript scripts/0280-literature-verify.R`. All 115 rows from
1190 pass (89 text, 16 table, 9 OCR, 1 abstract). The run exits 1 on the 42 older OCR rows that fail on this machine
(`bjornn_reiser1991` 32, `hubert_etal1985` 8, `ford_etal1995` 2), none of them in this range.

## Task 1: the 14 round-1 findings

Each page was re-read (text layer; for 3 and 4 the page image of the Stuart and Chislett scan, PDF page 47, rendered
here). All 14 are borne out and accepted; none declined.

| # | rows | decision | what changed | why |
|---|---|---|---|---|
| 1 | 1215 | accepted | Hedge kept ('appear to select'). The row is now quoted from the original, Den Beste and McCart 1984 p. 34 (Task 2a), whose sentence carries the same hedge. | Stewart 2007 p. 19 says "appeared to select"; the original says "appear to select". |
| 2 | 1216 | accepted | Hedge kept; note says use below availability, not absence, so not a limit; `bound = max` kept, no parameter. Re-quoted from Den Beste and McCart p. 34; the adult statement is cited to its p. 35. | The original: "although they are found in channels of average width, tend to select against channels wider than 14 m". |
| 3 | 1229 | accepted | Note: the scan prints m³/s; the OCR reads it 'm?/s'. | Page image, PDF page 47: "1 - 15 m³/s" printed clearly. |
| 4 | 1230 | accepted | Note: the scan prints m³/s; the OCR text drops the superscript. | Same image: "21 - 65 m³/s". |
| 5 | 1233 | accepted | Note: Ballard and Shrimpton 2009 gives no stream order (only "appear ... limited to cooler waters", p. 45); added that Hawkshaw and Shrimpton 2014, now held, has no fifth-order statement either (absent below order 4, p. 25; present watersheds order 4-8, Appendix E p. 60). | Ballard's text has "order" only as "in order to" and in a list of unstudied factors (p. 67); p. 45 confirmed. |
| 6 | 1231, 1232, 1233 | accepted | Each note names the shared claim and the other two rows; 1232 says 4th order is an example ('e.g.'), not a stated minimum. 1231 is now quoted from the original (Task 2a). | Stamford 2017 pp. 7, 16 and Hagen 2026 p. 7 confirmed. |
| 7 | 1234 | accepted | `cited_source` = Cutting et al. 2016; note says no age class is named. | The sentence ends "(Cutting et al., 2016)". |
| 8 | 1207 | accepted | "otolith" removed; 'suggest' and 'e.g.' kept; note adds what Blackman 2002 (now held) describes. | Hagen 2026 B-6: "Recent microchemistry analyses of retrospective movements also suggest that significant proportions (e.g., 13-27%)". |
| 9 | 1210 | accepted | `region` = "Range-wide (Scott and Crossman 1973), in a BC species account". | Cannings and Ptolemy p. 49 attributes the sentence to Scott and Crossman 1973. |
| 10 | 1238 | accepted | `region` = "Range-wide (review)". | Stewart 2007 p. 28, section 4.1.5, is general (the paragraph before is Alberta's Wildhay River). |
| 11 | 1240, 1247, 1248, 1253, 1254 | accepted | `scale` = `reach`; each note adds "Describes the 100 m section, not fish positions." | McPherson p. 23: one transect per 100 m site, four points, "representative of the entire site". |
| 12 | 1250 | accepted | Note keeps 'generally' and 'approximately' and gives the 2014 and 2015 available-habitat means (0.32, 0.39 m/s). | House p. 74 confirmed. |
| 13 | 1252 | accepted | Note keeps 'approximately' and the '0.l m' remark; adds what the two originals say (Task 2a). | Stamford p. 8 confirmed. |
| 14 | 1220 | accepted | "(next sentence)" corrected to "same sentence, continuing on p. 16". | Hagen 2015 pp. 15-16 confirmed. |

## Task 2a: rows a review reports from an original now held

| rows | original | outcome |
|---|---|---|
| 1201 | Stanislawski 1997 (OCR) | Prints the value: "most fish overwintered in water with a mean gradient in the 0.17-0.18% range" (p. 42). Re-quoted; note names Stewart 2007 Table 2 as the relay. Two new rows give the original's ranges (0.11-0.29 %, 0.08-0.33 %, p. 39). |
| 1215, 1216 | Den Beste and McCart 1984 | Prints both values (p. 34). Re-quoted; Stewart 2007 p. 19 named as the relay. |
| 1245 | Den Beste and McCart 1984 (one of three sources of Stewart Table 2's 0.2-0.8 m) | Does not print the range: it gives juveniles' preferred pools an average depth of 0.65 m (p. 33). Review row kept, note says so; 0.65 m is a new row. Vascotto 1970 and Evans et al. 2002 not held. |
| 1231 | Hawkshaw and Shrimpton 2014 | Prints it: juveniles absent below order 4, present and absent at 4 and above (p. 25). Re-quoted (`scale` = `network`, watershed scale); Hagen 2026 p. 7 named as the relay. |
| 1232 | Hawkshaw et al. 2013 (abstract only) | The abstract gives no order. Review row kept; note says so and points to 1231. A new `abstract` row quotes what the abstract does say. |
| 1233 | Ballard and Shrimpton 2009; Hawkshaw and Shrimpton 2014 | Neither prints "fifth order". Review row kept; note says what each says, with pages. |
| 1196 | Hawkshaw et al. 2013 | The abstract says nothing of gradient. Review row kept; note adds the report's gradient findings (poor predictor, p. 25; present sites 0-6.96 %, p. 61). |
| 1237, 1241, 1249 | Stewart et al. 1982 (Adsett Creek; Cannings and Ptolemy name no source, Stewart 2007 p. 14 attributes Adsett spawning to it) | Prints all three on p. 31, in its own units: "stable, coarse (20 - 40 mm) [gravel] substrates, water depths of 0.1 - 0.4 m, and flows of 0.5 - 1.0 m/sec". Re-quoted; the substrate row now carries the value (20-40 mm, `dist`) where the Cannings row could not (cm). The text layer splits "0. 1", so the depth row is quoted against OCR (verified). Notes name Cannings and Ptolemy p. 48 as the relay. |
| 1252 | Mathias et al. 1998; Blackman 2004 | Neither prints Stamford's "approximately 0.1 m ... approximately 0.1 m/s": Mathias could not describe young-of-year habitat in the Table River (p. 30) and gives a generic salmonid fry guideline (< 20 cm, 0-0.2 m/s, pp. 47-48); Blackman 2004 gives fry of three species "shallow (average 12 cm) low velocity (<0.1m-s)" (p. 7) and grayling means of 0.04 and 0.07 m/s (Table 2). Review row kept, note says so; Blackman's grayling values are new rows. |
| 1207 | Blackman 2002 (radio telemetry) | A statement about the literature, not a value; kept, note adds what Blackman 2002 describes (multi-channelled Anzac spawning areas, p. 18). |

Not held and not read: Northcote 1993 and 1995 (never cited directly), Scott and Crossman 1973, Stamford et al. 2015,
Vascotto 1970, Evans et al. 2002, Langston 1998, White 1998, Cutting et al. 2016.

## Task 2b: what the originals add (50 new rows, data rows 1255-1304)

Grouped by variable, then stage. The values the evidence lacked are now there for fry and juveniles:

- **Gradient, rearing:** Osilinka fry section 0.1 % (Cowie and Blackman 2003 p. 9), Omineca 0.2 % (p. 1), Table
  reaches 1-2 < 0.5 % (Blackman 2004 p. 2) and reach 3 1-2 % where 1998 fry reached km 32.6 (Blackman and Hunter
  2001 p. 2), Parsnip 0.3 % (p. 3); Hawkshaw and Shrimpton 2014 Appendix F: segments with juveniles 0-6.96 % (mean
  1.22 %), and a `qual` row that watershed-scale gradient did not predict occurrence (p. 25). Four `qual` rows: Den
  Beste and McCart p. 21 (spawning where gradient and scour are less severe), Stewart 1982 pp. 31, 44, 46, Cowie and
  Blackman 2004 p. 9. Every reach gradient is the reach's, not a fry site's; each note says so and gives the page
  that puts fry there.
- **Gradient, spawning:** Osilinka 0.1 % (spawning inferred from fry, as the authors' "spawning/rearing area").
- **Gradient, overwintering:** Stanislawski's two ranges (above).
- **Channel width, rearing:** Parsnip reaches 60-70 m wetted where young-of-year and age 1 were seined (Blackman
  2002, from White 1998); juvenile sites 0.96-43 m wetted (Hawkshaw and Shrimpton Appendix F); two `qual` rows
  (age 1+ rear in the larger Parsnip; mainstem shore margins). Spawning and overwintering `qual` rows from Blackman
  2002 (multi-channelled Anzac reaches; adults overwinter in the Parsnip).
- **Discharge:** spawning 1.5 m3/s at Adsett Creek through peak spawning (Stewart 1982 p. 31); rearing: Adsett Creek
  up to 2.2 m3/s through the season (p. 19), Table River estimated mean daily 12.9 m3/s (Blackman 2004 p. 2,
  Langston 1998), Parsnip mean daily 142 m3/s (Blackman and Hunter 2001 p. 3), Ingenika 75.5 m3/s (January-August
  average) and Nation 104.4 m3/s (January-September average) where fry were caught; overwintering Parsnip
  December-March 31 m3/s. None is MAD; each note says what it is.
- **Stream order:** Adsett Creek, second order, spawning and rearing (Stewart 1982 p. 2); the Hawkshaw et al. 2013
  abstract (`qual`).
- **Substrate, spawning:** Blackman 2002 small (< 3 cm) gravel (`qual`, cm not converted).
- **Depth and velocity, rearing:** young-of-year means at capture points (Blackman 2004 Table 2: 12.5 and 11.5 cm,
  0.04 and 0.07 m/s), 86-88 % of fry under 20 cm (p. 12), joint fry preference < 30 cm and < 0.3 m/s (abstract),
  age 0+ preference < 0.06 m and < 0.03 m/s and age 1+ 0.40-1.0 m and < 0.20 m/s (Blackman and Hunter 2001 p. 30;
  the abstract gives age 1+ differently, noted), Den Beste and McCart juveniles' pools averaging 0.65 m and lowest
  possible velocity, Hawkshaw and Shrimpton site depth 0.04-2.40 m and velocity 0.01-1.13 m/s, Stewart 1982
  young-of-year in quiescent margins (`qual`). Overwintering: Parsnip adults' cross-section depth 1-2.8 m and
  shallow, higher-velocity overwintering areas (`qual`).

What the originals give that no row holds:
- Adult summer habitat (no adult stage): Mathias et al. pp. 48-50 (adults/subadults 0.7-2.6 m deep, 0-0.90 m/s),
  Blackman 2004 Table 5 (adult depths and velocities), Blackman 2004 Table 4 (adults where the Anzac averaged 24.4 m
  wetted), Stanislawski p. 7 (summer reaches 0.19-0.29 %), Den Beste and McCart p. 34 (adults 0.8 m, near-zero
  velocity).
- Fry-site widths by reach: Cowie and Blackman 2003 Appendix 1 (EDI reach data; the Osilinka fry section, reaches 2-5,
  is 23-40 m wetted) and Blackman 2004 Appendix B (Anzac sections in the fry range 36-40 m wetted). Each needs a
  reach-to-fry-range join across pages, so left out; say if wanted.
- Drainage areas of the fry rivers (Table 506, Anzac 939, Osilinka 2,051, Ingenika 5,491, Omineca 5,851 km2;
  Hawkshaw and Shrimpton present watersheds 15-19,024 km2): `drainage_area` is not among the brief's extras.
- Blackman and Hunter 2001 p. 5: depths 0.1-0.5 m and velocities 0.2-0.75 m/s at a site they judged "should be
  suitable spawning habitat" where no eggs were found: not where fish spawned, left out.
- Stewart 1982 overwintering (deep runs, beaver impoundments, pp. 50-52), and Table 3's section widths and gradients,
  which the text layer garbles.
- Hawkshaw and Shrimpton Appendix E column heads give n = 41 absent and 56 present, the reverse of the caption and
  of p. 21 (42 % present); noted in row 1231.

## Every row from 1190

| data row | key | variable | stage | what I did |
|---|---|---|---|---|
| 1190 | stewart_etal2007Fishlife | gradient | spawning | unchanged |
| 1191 | cutting_etal2018Linkingbeaver | gradient | spawning | unchanged |
| 1192 | mcpherson2020Habitatuse | gradient | spawning | unchanged |
| 1193 | stewart_etal2007Fishlife | gradient | rearing | unchanged |
| 1194 | hagen_etal2015Criticalhabitats | gradient | rearing | unchanged |
| 1195 | stamford_etal2017FWCPArctic | gradient | rearing | unchanged |
| 1196 | stamford_etal2017FWCPArctic | gradient | rearing | fixed: note says what the original (abstract, report) gives |
| 1197 | hagen_etal2026futureArctic | gradient | rearing | unchanged |
| 1198 | hagen_etal2026futureArctic | gradient | rearing | unchanged |
| 1199 | mcpherson2020Habitatuse | gradient | rearing | unchanged |
| 1200 | mcpherson2020Habitatuse | gradient | rearing | unchanged |
| 1201 | stanislawski1997FallWinter | gradient | overwintering | re-quoted from original (Stanislawski 1997) |
| 1202 | stewart_etal2007Fishlife | channel_width | spawning | unchanged |
| 1203 | house2021Interdisciplinaryapproaches | channel_width | spawning | unchanged |
| 1204 | hagen_etal2015Criticalhabitats | channel_width | spawning | unchanged |
| 1205 | hagen_etal2015Criticalhabitats | channel_width | spawning | unchanged |
| 1206 | hagen_etal2026futureArctic | channel_width | spawning | unchanged |
| 1207 | hagen_etal2026futureArctic | channel_width | spawning | fixed (finding 8) |
| 1208 | tack1980Migrationsdistributions | channel_width | spawning | unchanged |
| 1209 | tack1980Migrationsdistributions | channel_width | spawning | unchanged |
| 1210 | cannings_ptolemy1998RareFreshwater | channel_width | spawning | fixed (finding 9) |
| 1211 | whyte_etal1997Restoringfish | channel_width | spawning | unchanged |
| 1212 | hubert_etal1985Habitatsuitability | channel_width | spawning | unchanged |
| 1213 | martins_etal2022SpatialEcology | channel_width | spawning | unchanged |
| 1214 | stewart_etal2007Fishlife | channel_width | rearing | unchanged |
| 1215 | denbeste_mccart1984Overviewstudies | channel_width | rearing | re-quoted from original (Den Beste and McCart 1984); finding 1 |
| 1216 | denbeste_mccart1984Overviewstudies | channel_width | rearing | re-quoted from original (Den Beste and McCart 1984); finding 2 |
| 1217 | stewart_etal2007Fishlife | channel_width | rearing | unchanged |
| 1218 | hubert_etal1985Habitatsuitability | channel_width | rearing | unchanged |
| 1219 | stewart_etal2007Fishlife | channel_width | overwintering | unchanged |
| 1220 | hagen_etal2015Criticalhabitats | channel_width | overwintering | fixed (finding 14) |
| 1221 | hagen_etal2026futureArctic | channel_width | overwintering | unchanged |
| 1222 | martins_etal2022SpatialEcology | channel_width | overwintering | unchanged |
| 1223 | house2021Interdisciplinaryapproaches | discharge | spawning | unchanged |
| 1224 | house2021Interdisciplinaryapproaches | discharge | spawning | unchanged |
| 1225 | house2021Interdisciplinaryapproaches | discharge | spawning | unchanged |
| 1226 | house2021Interdisciplinaryapproaches | discharge | spawning | unchanged |
| 1227 | cutting_etal2018Linkingbeaver | discharge | spawning | unchanged |
| 1228 | tack1980Migrationsdistributions | discharge | spawning | unchanged |
| 1229 | stuart_chislett1979AspectsLife | discharge | rearing | fixed (finding 3) |
| 1230 | stuart_chislett1979AspectsLife | discharge | rearing | fixed (finding 4) |
| 1231 | hawkshaw_shrimpton2014Temperaturepreference | stream_order | rearing | re-quoted from original (Hawkshaw and Shrimpton 2014); finding 6 |
| 1232 | stamford_etal2017FWCPArctic | stream_order | rearing | fixed (finding 6; abstract of the original read) |
| 1233 | stamford_etal2017FWCPArctic | stream_order | rearing | fixed (findings 5, 6; original read) |
| 1234 | cutting_etal2018Linkingbeaver | lake_area | overwintering | fixed (finding 7) |
| 1235 | hagen_etal2015Criticalhabitats | substrate | spawning | unchanged |
| 1236 | stewart_etal2007Fishlife | substrate | spawning | unchanged |
| 1237 | stewart_etal1982Ecologicalstudies | substrate | spawning | re-quoted from original (Stewart et al. 1982) |
| 1238 | stewart_etal2007Fishlife | groundwater | spawning | fixed (finding 10) |
| 1239 | stewart_etal2007Fishlife | groundwater | overwintering | unchanged |
| 1240 | mcpherson2020Habitatuse | elevation | rearing | fixed (finding 11) |
| 1241 | stewart_etal1982Ecologicalstudies | depth | spawning | re-quoted from original (Stewart et al. 1982, OCR) |
| 1242 | house2021Interdisciplinaryapproaches | depth | spawning | unchanged |
| 1243 | stewart_etal2007Fishlife | depth | rearing | unchanged |
| 1244 | stewart_etal2007Fishlife | depth | rearing | unchanged |
| 1245 | stewart_etal2007Fishlife | depth | rearing | fixed: note says what the held original gives |
| 1246 | stuart_chislett1979AspectsLife | depth | rearing | unchanged |
| 1247 | mcpherson2020Habitatuse | depth | rearing | fixed (finding 11) |
| 1248 | mcpherson2020Habitatuse | depth | rearing | fixed (finding 11) |
| 1249 | stewart_etal1982Ecologicalstudies | velocity | spawning | re-quoted from original (Stewart et al. 1982) |
| 1250 | house2021Interdisciplinaryapproaches | velocity | spawning | fixed (finding 12) |
| 1251 | house2021Interdisciplinaryapproaches | velocity | spawning | unchanged |
| 1252 | stamford_etal2017FWCPArctic | velocity | rearing | fixed (finding 13); originals read, they do not print the value |
| 1253 | mcpherson2020Habitatuse | velocity | rearing | fixed (finding 11) |
| 1254 | mcpherson2020Habitatuse | velocity | rearing | fixed (finding 11) |
| 1255 | denbeste_mccart1984Overviewstudies | gradient | spawning | new |
| 1256 | stewart_etal1982Ecologicalstudies | gradient | spawning | new |
| 1257 | cowie_blackman200320012002Arctic | gradient | spawning | new |
| 1258 | cowie_blackman200320012002Arctic | gradient | rearing | new |
| 1259 | cowie_blackman200320012002Arctic | gradient | rearing | new |
| 1260 | blackman20041997Arctic | gradient | rearing | new |
| 1261 | blackman_hunter20011998Arctic | gradient | rearing | new |
| 1262 | blackman_hunter20011998Arctic | gradient | rearing | new |
| 1263 | hawkshaw_shrimpton2014Temperaturepreference | gradient | rearing | new |
| 1264 | hawkshaw_shrimpton2014Temperaturepreference | gradient | rearing | new |
| 1265 | cowie_blackman20042003Arctic | gradient | rearing | new |
| 1266 | stewart_etal1982Ecologicalstudies | gradient | rearing | new |
| 1267 | stewart_etal1982Ecologicalstudies | gradient | rearing | new |
| 1268 | stanislawski1997FallWinter | gradient | overwintering | new |
| 1269 | stanislawski1997FallWinter | gradient | overwintering | new |
| 1270 | blackman2002RadioTelemetry | channel_width | spawning | new |
| 1271 | blackman2002DistributionRelative | channel_width | rearing | new |
| 1272 | hawkshaw_shrimpton2014Temperaturepreference | channel_width | rearing | new |
| 1273 | blackman_hunter20011998Arctic | channel_width | rearing | new |
| 1274 | mathias_etal1998SummaryReport | channel_width | rearing | new |
| 1275 | blackman2002RadioTelemetry | channel_width | overwintering | new |
| 1276 | stewart_etal1982Ecologicalstudies | discharge | spawning | new |
| 1277 | stewart_etal1982Ecologicalstudies | discharge | rearing | new |
| 1278 | blackman20041997Arctic | discharge | rearing | new |
| 1279 | blackman_hunter20011998Arctic | discharge | rearing | new |
| 1280 | cowie_blackman20042003Arctic | discharge | rearing | new |
| 1281 | cowie_blackman2007Arcticgrayling | discharge | rearing | new |
| 1282 | blackman2002RadioTelemetry | discharge | overwintering | new |
| 1283 | stewart_etal1982Ecologicalstudies | stream_order | spawning | new |
| 1284 | stewart_etal1982Ecologicalstudies | stream_order | rearing | new |
| 1285 | hawkshaw_etal2013Habitatcharacteristics | stream_order | rearing | new |
| 1286 | blackman2002RadioTelemetry | substrate | spawning | new |
| 1287 | denbeste_mccart1984Overviewstudies | depth | rearing | new |
| 1288 | blackman20041997Arctic | depth | rearing | new |
| 1289 | blackman20041997Arctic | depth | rearing | new |
| 1290 | blackman20041997Arctic | depth | rearing | new |
| 1291 | blackman20041997Arctic | depth | rearing | new |
| 1292 | blackman_hunter20011998Arctic | depth | rearing | new |
| 1293 | blackman_hunter20011998Arctic | depth | rearing | new |
| 1294 | hawkshaw_shrimpton2014Temperaturepreference | depth | rearing | new |
| 1295 | blackman2002RadioTelemetry | depth | overwintering | new |
| 1296 | denbeste_mccart1984Overviewstudies | velocity | rearing | new |
| 1297 | blackman20041997Arctic | velocity | rearing | new |
| 1298 | blackman20041997Arctic | velocity | rearing | new |
| 1299 | blackman20041997Arctic | velocity | rearing | new |
| 1300 | blackman_hunter20011998Arctic | velocity | rearing | new |
| 1301 | blackman_hunter20011998Arctic | velocity | rearing | new |
| 1302 | hawkshaw_shrimpton2014Temperaturepreference | velocity | rearing | new |
| 1303 | stewart_etal1982Ecologicalstudies | velocity | rearing | new |
| 1304 | blackman2002RadioTelemetry | velocity | overwintering | new |
