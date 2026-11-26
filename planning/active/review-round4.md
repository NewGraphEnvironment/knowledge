# Code-check round 4: #140 branch (grayling_use.R, grayling_segments.R, the write-up's numbers)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check-r.md, by heading (6 read in full): "`summarise()` and `mutate()` evaluate in order…", "`ifelse()` with an
  all-NA test returns a logical vector…", "Numeric routines that err at their edge, and `round()`", "A design matrix
  does not hold everything a formula says", "`clusterApply()` returns `NULL` for no tasks…", "Inside a dplyr verb, a
  column named like a local variable wins"; the rest (about 125) not read: no tool or shape they name is in the
  round-3 fixes beyond what round 3 read.
- code-check-shell.md: not read (no shell in the diff beyond `system2("git")`, read in round 3).
- code-check-spatial.md: not read this round (round 3 read the six FWA and sf headings; the fix adds an edge-type
  filter, checked against the database's `whse_basemapping.fwa_edge_type_codes` instead).
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows and evidence blocks skipped).

Index, diff and changed files read from file.

Probes (nothing in the repo kept; one stray probe CSV my script wrote to the repo root, `an1.csv`, was moved out at
once; `git status --porcelain` otherwise as found, `planning/active/progress.md` modified before this round):
- `<scratchpad>/r4/head.R`, lines 1-187 of `data-raw/grayling_use.R` (population, classes, `modelled()`, `fit()`,
  `ratio()`, `fit_ratio()`), sourced by `an1.R`-`an3.R` and `an8.R`. `an8.R` redraws every table's 200 resamples from
  its seed (141-149) serially and reproduces all 75 rows' `n_boot_ok` exactly.
- `<scratchpad>/r4/bq.R` (lines 192-200) tested in `an4.R` against `stats::quantile()` (type 7, Inf kept, NA dropped)
  on 12,000 random columns with 0-12 zeros, 0-12 Inf and 0-5 NA: 0 disagreements.
- `<scratchpad>/r4/seg_copy.R`, `data-raw/grayling_segments.R` with `path_log` in the scratchpad and `lines` saved
  before and after the filters, run with `PGSERVICE=fresh_local`: its log body is identical to
  `scripts/logs/habitat/20261126_grayling_segments.txt` (first line differs only in the commit). `an5.R`-`an7.R` read
  the saved lines and query the five dropped segments' neighbourhood (temporary tables only).

## The mechanism, one axis over

Round 3's fix for connectors (`grayling_segments.R:98-101`) is right for the lines it meant, and it carries the same
assumption to the next unit up: it filters **lines**, and the `segments` count (`:122`) is taken after the filter, so
a segment whose only matched line was a connector leaves the count with nothing saying so. The five that left are not
connector-mapped river reaches but short tributary segments whose own creek line the half-of-line rule never matched;
the connector at the mouth had been standing in for them. The filter's range is also one class wider than its label.
The grayling_use.R fixes hold on every axis measured (below).

## Findings

- **[severity: fragile]** data-raw/grayling_segments.R:98-101, :122, and research/grayling_habitat.md:129 — the
  connector filter drops five whole segments, and the `segments` column then counts segments with a line left, not
  the group's segments. All five are in the Nation core area: 12 and 42 (both the lower 0.4 km of Rainbow Creek),
  14 and 44 (the lower 0.2 km of Suschona Creek), 41 (0.75 km of an unnamed creek, `CRITICAL_H` "Spawning, rearing
  habitats"); stages Adult+Juvenile (12, 14) and Fry (41, 42, 44). Each matched one line only, a 32-45 m connector
  (1450) at the creek's mouth carrying the creek's MAD (1.2-1.8 m³/s). Their own creek lines (edge 1000, 728-3,290 m)
  hold 23-35 % of their length within 25 m, under the 50 % rule, so they never matched (`an6.R`). The log's group
  counts moved from the layer's 23/27/36/13/14/85 to 20/25/34/12/11/80 and no line says why; the write-up's
  "1,720 km on 80 of the segments, outside lakes and the reservoir" reads as five lake segments, but no segment is
  lost to the lake filter (round 3's run, lake filter alone, kept all 85). The km-weighted numbers do not move at the
  printed precision (about 2 km of 1,720), but the five are small-tributary fry and juvenile segments, the one kind of
  critical habitat the paragraph says the segments do not show (12 and 42 record one Rainbow Creek reach for two
  stages, 14 and 44 one Suschona Creek reach). Count `segments` before the filters (or log the segments left with no line, with the reason)
  and say in the write-up what the other five are; reading them needs a rule that matches a line by the share of the
  **segment** it covers, not only the share of the line. Bound on the rule elsewhere (`an7.R`, every non-connector
  line touching a buffer, each once): lines under the 50 % rule hold 24.8 km inside the buffers against 1,849 km for
  the matched ones (lakes included), 5.5 km of it on 14 lines with 100 m or more inside; only these five segments lose
  every line.
  - **Rule:** code-check.md "A proxy is not the property" (the half-of-the-line rule stands in for "the segment
    follows this line" and fails for a segment shorter than half its line), and "One fact derived twice" (the
    `segments` count and the layer's segments are two populations under one name)

- **[severity: fragile]** data-raw/grayling_segments.R:16, :96-100 — the header and comment say "Connector lines (edge
  types 1400-1450)", and the code drops 1400-1499. Among the matched lines that is 3,354 connections (1450, 97.4 km,
  93.9 km of it in river polygons), one network connector (1410, 0.0 km), one subsurface-flow line (1425, 0.1 km,
  MAD 6.3 m³/s, in no river or lake polygon: part of a stream's course, not a connector carrying a tributary's flow)
  and 116 lake arms (1475, 112 km, every metre in a lake). So the log's "Connector lines left out: 3472 lines, 209 km"
  is 97 km of connectors and 112 km of lake arms, and "Lines in a lake or reservoir polygon left out: 210 lines,
  133 km" is short by those 112 km. Nothing in the write-up quotes either line, and no group's numbers move (the lake
  arms would be dropped by the lake filter anyway; the 1425 line is 0.1 km). Name the types the code drops
  (`edge_type %in% c(1400, 1410, 1450)`) or say in the header and the log line that lake arms and subsurface flow
  are in it.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" (a range standing in for a named set)

- **[severity: fragile]** research/grayling_habitat.md:54-55 — "884 sit on river-polygon lines (711 …, 56 …, 117 on
  connectors)" counts by edge type (1250 + 1350 + 1450 from the log's edge-type table). By the river-polygon flag the
  tuning uses to leave them out (`wb_river`, the funnel's "+ not in a river polygon" step and the next sentence's
  "leaves river polygons out"), it is 882: two of the 117 GR-caught visits on 1450 lines are in no river polygon
  (`129410_4_1`, MSTR, in neither; `66814_14_1`, DEAL, in a lake). 1450 is "Construction line, connection", used in
  lakes too (139 of the 590 in-range visits on 1450 have `wb_river` FALSE). Say 882 (115 on connectors), or say the
  count is by edge type.
  - **Rule:** writing.md "State each claim by the code's definition"

## Enumeration: every aggregate against the unit it names (round 3's set, plus what the round-3 fixes added)

Line numbers are at the branch head (2a3c19ec).

`data-raw/grayling_use.R`

| place | unit named | rows that reach it | verdict, evidence |
|---|---|---|---|
| :104-110 funnel `visits`, `gr_caught`, `groups` | visits, groups | `dr`, one row per visit (round 3: 0 duplicate `site_visit`); last step checked against `d0` at :110 | holds |
| :112-114 edge-type table | visits by edge type | `dr` | holds as labelled; the write-up reads it as river-polygon visits (finding 3) |
| :225 river-sensitivity population | visits | `d_river` (2,518; 361) | holds; not quoted |
| :234-236 modelled / left out | visits, groups | `d`, `d_resp` | holds |
| :237-238 `n_visits`, `n_detect` | the population's visits in the class | `d_resp` | holds; header :27-28 says so |
| :238 `n_groups` | groups | `d_resp` (whole population) | holds; not named in the header, not quoted |
| :239-240 `n_visits_fit`, `n_detect_fit` (new) | "visits the model was fitted to" | `d` = `modelled(d_resp)` | the fit is on `d2` (:179), `d` less separated classes with groups re-dropped. Measured (`an1.R`): in all 9 tables `d2` drops no group, and every non-separated class has the same visits and detections in `d2` as in `d`. Holds today; latent if a separated class's removal ever leaves a group with one outcome |
| :244 `raw_rate` | population rate | `d_resp` | holds (header: raw rates) |
| :248 `sep` | class separated | `d_resp`; `fit_ratio()` separates on `d` | measured: no class has `n_detect_fit` 0 or equal to `n_visits_fit` unless `n_detect` is 0 or `n_visits`; no class becomes separated in `d2` (`an1.R`, `sep_d2` FALSE for all). Holds today; latent as round 3 said |
| :249 `rate_ratio` | fit on the modelled rows | `fit_ratio(d)` -> `d2` | holds; converged in all 9 tables |
| :174-177 `s0`, `s1` (new) | classes separated in the data fitted | the input `d` (main) or resample `bd` | holds (above) |
| :179-181 `d2` refit (new) and its `modelled()` call | rows left after separated classes are set apart | `d` less `s0 \| s1` | holds: 0 groups dropped in any main table; in the 1,800 resamples no class present in `bd` came back NA from a converged fit (`an8.R`, `lost_present_but_NA` 0 everywhere) |
| :183 classes absent from `d2` -> NA | class not in the fit | `levels(d2$cls)` | holds; every NA cell in the 75 x 200 matrix is a class absent from its resample or a non-converged fit (`an8.R`) |
| :192-200 `bq()` (reworked) | type-7 quantile with Inf at its limit | non-NA resamples | holds: equal to `stats::quantile(type = 7)` with Inf kept on 12,000 random columns (`an4.R`) |
| :250-251 `ratio_lo`, `ratio_hi` | 2.5 / 97.5 % of usable resamples | `bw` columns in `labs` order, `apply(…, 2, …)` positional against rows in `labs` order (tibble built from `labs`, `left_join` keeps order) | holds; non-converged resamples dropped are the accepted tradeoff (5 in each `gr_caught_given_fish` gradient table, 4 width, 1 MAD) |
| :252 `n_boot_ok` | usable resamples per class | `colSums(!is.na(bw))` | holds; reproduced for all 75 rows (`an8.R`) |
| :254 `power` (moved) | evidence behind the ratio | `n_visits_fit`, `n_detect_fit` | holds (see :239-240); `channel_width / gr_caught_given_fish / no width` now underpowered (24 fitted visits) |
| :257-262 sensitivity `main`, `logit_or`, `rivers_kept` | ratios | `rr`; `fit_ratio(d, "logit")`; `fit_ratio(dr)` on modelled `dr`, `sep_river` on it | holds; block unchanged by the rerun (log diff) |
| :269-270 `round(3)`, NaN -> NA | the CSV's precision | once | holds; the write-up now prints the CSV's values as stored (checked below) |
| :276-278 visits by month | visits | `d0` | holds |
| :280-286 lengths by month | fish measured | `fish.rds` rows | holds; not quoted |

`data-raw/grayling_segments.R`

| place | unit named | rows that reach it | verdict, evidence |
|---|---|---|---|
| :67-68 header km | the layer's segments | `st_length(seg)`, overlaps included | holds as the layer's km; not quoted as stream km |
| :84-86 lines matched, km | lines, each once | `n_distinct`, `distinct()` over all hits | holds |
| :98-100 connector lines, km (new) | "connector lines (edge types 1400-1450)" | edge 1400-1499, each line once | finding 2: 112 of the 209 km are lake arms (1475) |
| :102-104 lake lines, km (reordered) | lines in a lake or reservoir | after the connector filter, each line once | holds as the lines left after connectors; short by the 112 km of lake arms counted above (finding 2) |
| :122 `segments` | the group's segments | segments with at least one line left after both filters | finding 1: 80 of 85 (fry 20 of 23, juvenile 25 of 27, adult 34 of 36, spawning 12 of 13, possibly spawning 11 of 14); no segment is lost to the lake filter alone |
| :123-133 `km`, quantiles, shares | lines the group's segments follow, each once | deduped lines, connectors and lakes out | holds for the lines matched; the five segments' own creek lines are not among them (finding 1) |
| :114-120 `wq()`, `share()` | length-weighted | `length_metre`; no NA `fwa_gradient`, `mad_pick` or `wb_river` (round 3) | holds |

## Number check: `research/grayling_habitat.md` against `data/gr_use.csv` and the two logs

| line | number | source | verdict |
|---|---|---|---|
| 11-12 | link's 3.49 %, 1.5 m, 0.021; 2.49 %, 4 m, 0.2 | link `default`, not these scripts | rearing gradient and width match `data/thresholds.csv`'s GR rows (0.0349, 1.5); the MAD floor and the spawning values not checked this round |
| 23 | caught as often up to 5.49 % | CSV: every class to 5.49 % has an interval holding 1 | holds |
| 23 | 2 of 152 at 5.49-8 % | CSV 152 / 2 | holds |
| 26-27, 29 | lowest under 2 m; lowest under 0.021 | CSV (excluding "no width", 0.253, and the 2-visit MAD classes, none caught) | holds as a reading of the sized classes |
| 31-32 | nearly all the segments' length in large rivers | segments log, `pct_km_river_polygon` 93.3 | holds |
| 41 | 1,580 visits, 45 groups, 229 | funnel last row | holds |
| 54 | 1,231 | funnel first row, `gr_caught` | holds |
| 54-55 | 884 = 711 + 56 + 117 on river-polygon lines | edge-type table (1250, 1350, 1450) | finding 3: 882 by `wb_river` |
| 56 | 229 of the 1,231 scored | funnel | holds |
| 61-71 | gradient table, 9 rows x 3 numbers | CSV `gr_caught` | holds, every cell equal to the CSV as stored (`tables.R`, 25 rows, 0 mismatches) |
| 74-75 | 2 of 152; the 54 steeper visits caught 5 | CSV 49 + 5 visits, 5 + 0 | holds |
| 76 | the tuning's picks move the gradient limit to 5.49 % on both networks | `research/baseline_anchoring.md` :50, :69 (`g<=0.0549` both); `data/thresholds.csv` GR rows `rec_rule` `width>=2\|g<=0.0549\|none` | holds |
| 81-90 | width table, 8 rows | CSV | holds (`tables.R`) |
| 92 | a quarter to a third under 2 m | 0.345, 0.260 | holds |
| 93 | about 0.6 at 2-4 m | 0.621 | holds |
| 93 | any-fish ratios 0.15-0.47 | unrounded 0.14863 (1.5-2 m), 0.21458, 0.47298 (`an2.R`) | holds |
| 94-95 | no given-fish width class below its interval | CSV: every given-fish interval holds 1 | holds |
| 100-109 | MAD table, 8 rows | CSV | holds (`tables.R`) |
| 111 | about a third below 0.021 | 0.314 | holds |
| 111-112 | above it every class holds 1 | CSV (0.021-5 m³/s); the two classes over 5 m³/s have 2 visits each and none caught, and the sentence goes on to say so | holds |
| 118 | channels under 2 m, MAD under 0.021 and 5.49-8 % stay low under both sensitivities | log: 0.264, 0.289; 0.173, 0.222; 0.231, 0.266; 0.096, 0.083 | holds |
| 119 | 0.62-0.78 with river polygons added, 2-5.49 % | unrounded 0.65590, 0.78464, 0.62451 (`an2.R`) | holds |
| 121 | 1,357 of 1,580 in July to September | month table 298 + 476 + 583 | holds |
| 121-122 | 175 in May and June, grayling on 11 | 44 + 131; 3 + 8 | holds |
| 126 | 85 segments, six core areas | layer (round 3) | holds |
| 129 | 1,720 km on 80 of the segments, outside lakes and the reservoir | segments log `all` 1720, 80 | the numbers match the log; the five are not lake segments (finding 1) |
| 130 | 93 % in river polygons | 93.3 | holds |
| 130 | median MAD 30 m³/s | `mad_p50` 30 | holds |
| 130 | median width about 57 m | `width_p50` 57.1 | holds |
| 130-131 | over 99 % under 2.49 % | 99.7 | holds |
| 132 | fry: median MAD 37, over 99 % under 2.49 % | 37; 99.8 | holds |
| 133 | spawning 24 m³/s | `mad_p50` 24 | holds |
| 139-178 | literature rows and values | `data/literature_evidence.csv` (audited for meaning in #140's row audits, not these scripts) | out of this round's scope |
