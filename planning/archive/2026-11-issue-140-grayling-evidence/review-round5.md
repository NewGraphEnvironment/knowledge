# Code-check round 5: #140 branch (round-4 fixes; enumeration and number check)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows skipped).
- code-check-spatial.md, full sections: "A name is not a key: `GNIS_NAME` matches features all over BC", "FWA main flow
  is not edge type 1000 alone", "`sf::st_read()` promotes a mixed POLYGON/MULTIPOLYGON layer to all-MULTIPOLYGON",
  "A GDAL failure partway through `sf::st_read()` returns the rows read so far, with only a warning", "FWA lookup area
  follows watershed codes, so side channels get the river's", "A relation between FWA watershed codes is not a place".
  Edge-type codes read from the database's `whse_basemapping.fwa_edge_type_codes` (1400 other flow/inferred
  connection, 1410 network connector, 1425 subsurface flow, 1450 connection, 1475 lake arm).
- code-check-r.md and code-check-shell.md: by index only; the round-4 fixes add no R or shell construct beyond those
  rounds 3-4 read (`%in%` on edge types, `setdiff`, `grepl`, `sum`, a SQL `LEAST`).

Index, diff and changed files read from file.

Probes (all in `<scratchpad>/r5/`, nothing written to the repo but this file; `git status` as found):
- `seg_copy.R`: `data-raw/grayling_segments.R` with `path_log` redirected and `lines` saved before and after the
  filters, run with `PGSERVICE=fresh_local` at 8f0d708: its log body is identical to
  `scripts/logs/habitat/20261126_grayling_segments.txt` (the first line differs only in the commit; the script is
  unchanged between c902652, the log's commit, and HEAD).
- `perseg.R`: every FWA line touching any segment's 25 m buffer, with its GNIS name, length, length inside the buffer,
  and the old and new match rule; its matched set equals the script's `hits` row for row (14,612 rows).
- `analyse.R`, `cover.R`, `dup2.R`, `gap.R`: per-segment km, coverage, names, self-overlap, distance to the network.
- `extra.R`, `spread.R`: flow and width for the unmatched lines, and the published numbers under four match variants.
- `v882.R`: the 882 recomputed from `data/fdis/derived/`; `tables.R`: the write-up's three tables against the CSV.

## Findings

- **[severity: fragile]** data-raw/grayling_segments.R:76-83, :108-110 — the new rule ("half the shorter of line and
  segment") still misses part of four segments' own stream, and the new "Segments left with no line: 0" guard reads at
  the segment's grain, so it cannot show it. A segment whose stream is split between two Atlas lines, each holding less
  than half of the segment and less than half of itself, loses the line: seg 13 Sylvester Creek (Nation, 2.49 km) loses
  Sylvester Creek line 151053649 (757 m of 3,295 m inside the buffer, 30 % of the segment); seg 21 Carruthers Creek
  (4.79 km) loses Carruthers Creek 233010413 (843 m, 18 %); seg 56 Pesika Creek (1.21 km) loses Pesika Creek 49115546
  (304 m, 25 %); seg 73 (2026 juvenile layer, no name, 2.34 km) loses Bills Creek 165097106 (763 m, 33 %); and smaller
  tails on Lafferty, Fries, McCook and Davis (3-10 % of their segments). Every sampled point of these segments lies within
  2.2 m of an Atlas line (`gap.R`), so the uncovered length is unmatched line, not off-network geometry. The rule
  admitted nothing it should not (below), and no printed number moves: across four variants (the script's; plus every
  unmatched non-connector line holding 10 % of a segment or 100 m inside it, 18 rows; each weighted by length inside the
  buffer instead of whole-line length) the "all" group reads 1,718-1,745 km, 92.6-93.3 % in river polygons (printed
  93 %), median MAD 30 in all four, median width 56.3-57.1 m ("about 57"), 99.7 % under 2.49 %; fry median MAD 37 and
  spawning 24 in all four (`spread.R`). So the write-up holds at its precision; the log's "0" reads as complete coverage
  when four short creek segments are 18-33 % short. Either log the share of each segment's length its kept lines cover
  (the guard at the property's grain), or match on the share of the segment a line covers.
  - **Rule:** code-check.md "A proxy is not the property" (half the shorter of the two stands in for "the segment
    follows this line"), and "A guard's scope, escape hatches, and remedies" ("a guard that reads a coarser grain than
    its property passes on the grain")

No other finding.

## Task 1: the match rule on the data, per segment

- **What the new rule admits.** New set = old set plus exactly 5 rows (`LEAST` can only lower the bar): seg 12/42
  Rainbow Creek line 151055361 (421 m of 1,277 m inside; segment 396 m), seg 14/44 Suschona Creek 151064216 (254 of
  728; segment 228 m), seg 41 (`GAZETTED_N` Munro Creek) unnamed line 151055303 (770 of 3,290; segment 746 m, so the
  line runs the whole segment). Each is the segment's own creek. No tributary crossing, no mainstem at a mouth and no
  parallel line was admitted by the change. These five lines count whole (5.3 km of line for 1.37 km of segment,
  3.2-4.4x); the inside-length variants above bound the effect (1,718 against 1,726 km, no printed number moves).
- **Matched km far from the segment's length** (kept lines' km over segment length): seg 1 Williston Lake 0.003
  (the lake filter, as the header says); segs 84, 78, 67 (2026 layers) 0.51-0.70: their parts overlap each other by
  11.3-14.7 km (`dup2.R`: 84's 1,670 m part is drawn three times and its 25,982 and 21,037 m parts share 13 km; 78's and
  67's two parts share 11.3 km), so the layer's own length is inflated, not the match short; segs 13, 21, 56, 73
  0.67-0.83 (the finding); segs 12/42, 14/44, 41 3.2-4.4 and 17, 36 1.5-1.6 (whole short-segment lines). The other 72
  segments read 0.90-1.10.
- **Lines whose GNIS name differs from the segment's `GAZETTED_N`** (ignoring "Nation"/"Nation River"): all were
  matched by the old rule too, nearly all wholly inside the buffer. seg 5 Finlay River: Bower Creek, 11 lines 3.75 km
  (all inside); seg 15 Mesilinka: Kliyul Creek 0.62 km (the same line is seg 17 Kliyul Creek's own, counted once in
  "all"); seg 35 `GAZETTED_N` Finlay River: Delta Creek 0.89 km of its 0.91 km (and seg 36, also named Finlay River,
  follows an unnamed 1.38 km line of MAD 1.1): the layer's name and its geometry disagree there, not the match; seg 1
  Williston Lake: Finlay River 0.69 km; segs 22 and 55: Moosehorn Creek 0.10 km (58 m inside); seg 6, 7, 22, 52: 8-39 m
  of Finlay, Haworth, Fox. About 6 km of 1,726 in all. The 24 segments of the 2026 layers carry no `GAZETTED_N` and
  could not be name-checked; their coverage was checked instead (above).

## Task 2: every aggregate in data-raw/grayling_segments.R

Line numbers at HEAD (8f0d708).

| place | unit named | rows it is computed over | verdict, evidence |
|---|---|---|---|
| :67-68 `%d segments, %.0f km` | the layer's segments and km | `nrow(seg)`, `st_length(seg)` summed | holds as the layer's km, overlaps included (cross-layer redraws, and 37 km of within-segment self-overlap in 84, 78, 67); not quoted in the write-up |
| :69 segments by layer and stage | segments | `seg` | holds (85 rows) |
| :85-87 lines matched, segments, km | lines each once; segments with a match | `hits`; `n_distinct`; `distinct(linear_feature_id, length_metre)` | holds (8,643 lines, 85 of 85, 2,068 km reproduced) |
| :99-101 connectors | lines of edge 1400, 1410, 1450, each once | `lines[conn]` distinct | holds: 3,355 lines, 97 km; label and set now agree (1425 and 1475 kept, 1475 then dropped by the lake filter) |
| :103-105 lake lines | lines in a lake or reservoir, each once | after connectors, `wb_lake | wb_any_lake` | holds: 326 lines, 245 km; no matched line has an NA flag |
| :108-110 segments left with no line | segments | `setdiff(seg_id, lines$seg_id)` | holds as written (0); reads at the segment's grain (finding) |
| :111-117 `seg_groups`; :118-124 `groups` | a segment's stage and critical habitat | the layer; the lines | two copies of one predicate; measured identical membership for all five groups (`seg_id` sets equal), so it holds today |
| :133 `segments` | the group's segments in the layer | `seg_groups` | holds: 23/27/36/13/14/85 equal the layer's counts (spawning 13 and possibly spawning 14 recounted from `CRITICAL_H`) |
| :134-136 `km` | lines the group's segments follow, each once | `distinct(linear_feature_id)` after both filters, whole `length_metre` | holds as whole Atlas lines; partial misses and whole-line counting bound by the variants (finding) |
| :137 `grad_p50`, `grad_p90` | length-weighted quantiles | the same deduped lines; no NA gradient (4,962 lines) | holds |
| :138-139 `pct_km_grad_le_*` | share of km | same | holds |
| :140 `mad_p10`, `mad_p50` | length-weighted quantiles | same; no NA MAD | holds |
| :141 `pct_km_mad_ge_*` | share of km | same | holds |
| :142 `width_p10`, `width_p50` | length-weighted quantiles over lines with a width | `wq()` drops 65 lines with no width | holds; their km is reported in `pct_km_no_width` |
| :143 `pct_km_width_ge_*` | share of all km | NA width counted as not passing | holds as labelled (share of all km) |
| :144 `pct_km_no_width` | share of km with no width | `is.na(cw_deploy)` | holds |
| :144 `pct_km_river_polygon` | share of km in a river polygon | `wb_river`, no NA | holds; every kept 1250/1350 line is `wb_river` TRUE and no other edge type is |
| :125-131 `wq()`, `share()` | weighted lower quantile; share | as round 4 | holds; widths do not depend on the id set passed (8,643 lines, 0 differ between the script's run and one with 11 more ids) |

## Task 3: research/grayling_habitat.md, every number

| line | number | source | verdict |
|---|---|---|---|
| 11-12 | rearing 3.49 %, 1.5 m, 0.021 m³/s | link 0.78.1 `configs/default/parameters_habitat_thresholds.csv` GR row | holds (0.0349, 1.5, 0.021) |
| 12 | spawning 2.49 %, 4 m, 0.2 m³/s | same row | holds (0.0249, 4, 0.2) |
| 23 | caught as often up to 5.49 % | CSV: every class to 5.49 % has an interval holding 1 | holds |
| 23 | 2 of 152 at 5.49-8 % | CSV 152 / 2 | holds |
| 26 | lowest under 2 m | CSV 0.345, 0.260 (no-width class 0.253 is unsized) | holds as a reading of sized classes (accepted in round 4) |
| 29 | lowest under 0.021 | CSV 0.314 | holds |
| 31 | nearly all the segments' length in large rivers | segments log `all` 93.0 % | holds |
| 40-41 | 1,580 visits, 45 groups, 229 | use log funnel last row | holds |
| 48 | 200 refits | `n_boot` 200 | holds |
| 49 | 30 visits, 10 catches | `min_visits`, `min_detect` | holds |
| 54 | 1,231 | funnel first row, `gr_caught` | holds |
| 54 | 882 by the river-polygon test | `v882.R`: GR present, in range, not blocked, `wb_river` TRUE: 882 | holds |
| 55 | 711 / 56 / 117 by edge type | 1250 711, 1350 56, 1450 117 (and the log's edge-type table) | holds |
| 55-56 | two of the 117 outside any river polygon | 1450 with `wb_river` FALSE: 129410_4_1 (MSTR) and 66814_14_1 (DEAL), both in a lake polygon (`wb_any_lake` TRUE); no `wb_river` visit on any other edge type | holds (882 = 711 + 56 + 115) |
| 57 | 229 of the 1,231 scored | funnel | holds |
| 64-72 | gradient table, 9 rows x 3 cells | CSV `gr_caught` | holds (`tables.R`: 25 rows, 0 mismatches) |
| 74-75 | every class to 5.49 % holds 1 | CSV intervals 0.705-1.778, 0.584-1.583, 0.479-1.417, 0.701-1.601, 0.485-1.282 | holds |
| 75 | 2 of 152 | CSV | holds |
| 75-76 | the 54 steeper visits caught 5 | 49 + 5; 5 + 0 | holds |
| 77 | picks move the limit to 5.49 % on both networks | `data/thresholds.csv` GR `rec_rule` `width>=2|g<=0.0549|none`; `baseline_anchoring.md` (round 4) | holds |
| 84-91 | width table, 8 rows | CSV | holds (`tables.R`) |
| 93 | a quarter to a third under 2 m | 0.345, 0.260 | holds |
| 94 | about 0.6 at 2-4 m | 0.621 | holds |
| 94-95 | any-fish ratios 0.15-0.47 | 0.215, 0.149, 0.473 | holds |
| 95-96 | no given-fish width class below 4-8 m beyond its interval | every given-fish interval holds 1 (≥ 30 m: 0 of 2, none) | holds |
| 103-110 | MAD table, 8 rows | CSV | holds (`tables.R`) |
| 112 | about a third below 0.021 | 0.314 | holds |
| 112-113 | every class above holds 1 | 0.021-5 m³/s classes; the two over 5 m³/s, 4 visits, none caught | holds (sentence names them) |
| 114 | almost no stream over 5 m³/s | 4 of 1,580 | holds |
| 119 | under 2 m, under 0.021 and 5.49-8 % stay low under both sensitivities | log: 0.264/0.289, 0.173/0.222; 0.231/0.266; 0.096/0.083 | holds |
| 120 | 0.62-0.78, 2-5.49 % with rivers kept | 0.656, 0.785, 0.625 (unrounded 0.6559, 0.7846, 0.6245, round 4) | holds |
| 122 | 1,357 of 1,580 July-September | 298 + 476 + 583 | holds |
| 122-123 | 175 in May-June, grayling on 11 | 44 + 131; 3 + 8 | holds |
| 127 | 85 segments | layer | holds |
| 127 | six Williston core areas | `CORE_AREA`: Ingenika, Lower_Finlay, Nation, Omineca, Upper_Finlay, Williston (24 of the 2026 layers carry none) | holds for the attributed 61 |
| 130 | 1,726 km | segments log `all` 1726 | holds (spread 1,718-1,745 across match variants, finding) |
| 130 | 93 % in river polygons | 93.0 | holds (92.6-93.3 across variants) |
| 131 | median MAD 30 | `mad_p50` 30 | holds (30 in every variant) |
| 131 | median width about 57 m | 57.0 | holds (56.3-57.1) |
| 131-132 | over 99 % under 2.49 % | 99.7 | holds |
| 133 | fry median MAD 37, over 99 % | 37; 99.8 | holds |
| 134 | spawning 24 | `mad_p50` 24 | holds |
| 139 | 115 rows, data rows 1190-1304 | `data/literature_evidence.csv`: 1,304 data rows, rows 1190-1304 all GR, the branch adds 115 | holds; the rows' values are the row audits' scope |

Verdict: one fragile finding (partial misses invisible to the new guard); no published number is wrong at its printed
precision under any of the four match variants measured.
