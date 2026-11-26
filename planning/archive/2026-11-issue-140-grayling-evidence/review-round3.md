# Code-check round 3: #140 branch (grayling_use.R, grayling_segments.R, the write-up's numbers)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check-r.md, by heading (9 read in full): "A design matrix does not hold everything a formula says",
  "`summarise()` and `mutate()` evaluate in order…", "Numeric routines that err at their edge, and `round()`",
  "`ifelse()` with an all-NA test returns a logical vector…", "`tolerance` in testthat is RELATIVE…",
  "`stats::aggregate()` has three separate silent behaviours…", "`clusterApply()` returns `NULL` for no tasks…",
  "Forked `parallel::mclapply()` workers segfault in `glm.fit`…", "Postgres row order is never fixed unless the query
  fixes it…"; index lines for `system2(stdout = TRUE)`, `match()` NA, `paste()` zero-length and `data-raw/` loading
  checked against the code. The other ~120 headings not read: no tool or shape they name is used.
- code-check-shell.md, by heading (1 read): "Git plumbing calls whose default answers a different question". The rest
  not read.
- code-check-spatial.md, by heading (6 read): "FWA main flow is not edge type 1000 alone", "A Freshwater Atlas main
  stem's downstream end lies on the receiving river's centreline…", "FWA `upstream_route_measure` misses the next
  segment's start", "A relation between FWA watershed codes is not a place", "A GDAL failure partway through
  `sf::st_read()`…", "Ask the file about its field names, not R". The rest not read.
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows and evidence blocks skipped).

Index, diff and changed files read from file.

Probes (nothing in the repo written; `git status --porcelain` identical before and after):
- `<scratchpad>/r3probe/grayling_use_copy.R`, a copy of `data-raw/grayling_use.R` with `path_out` and `path_log` in the
  scratchpad and the bootstrap matrices saved. Its CSV is byte-identical to `data/gr_use.csv` (`cmp`). `an1.R`-`an5.R`
  read the saved matrices; `an2.R`-`an4.R` redraw a table's resamples from its seed (143, 146, 149) and refit the ones
  that came back NA.
- `<scratchpad>/r3probe/grayling_segments_copy.R`, a copy of `data-raw/grayling_segments.R` with `path_log` in the
  scratchpad and `lines` saved, run with `PGSERVICE=fresh_local` (one temporary table, session-local). Its log body is
  identical to `scripts/logs/habitat/20261126_grayling_segments.txt`. `an6.R`, `an7.R` read the saved lines.

## The mechanism

Every defect so far, and every one below, is a summary whose rows are not the units its label names, with no step
that checks the two agree: segment x line join rows labelled as lines (round 1); resamples that fit labelled as
resamples drawn (rounds 1 and 2); a 3-decimal print labelled as the unrounded figure (round 2). The shared assumption
is that **whatever rows reach the summary are the population its name describes**. The data never contradicts it,
because each summary is individually well-formed; only an enumeration of each aggregate against its label finds it.
Below, the rows that reach the summary are: visits in groups the model drops (power), resamples whose fit did not
converge because some *other* term separated (intervals), one class labelled as a range of classes (write-up), and
connector lines crossing the river labelled as lines the segment follows (segments).

## Findings

- **[severity: fragile]** data-raw/grayling_use.R:150 with :176-178 and :202 — a resample whose glm does not converge in
  100 iterations returns NA for every class (`ratio()`), and `bq()` drops it, so round 2's fix ("a separated resample
  counts at its limit") does not reach the classes beside the separated one. In those resamples the separated class
  gets its limit (0) through `r[s0] <- 0` while every other class is NA. Measured: all 10 such resamples are in the
  `gr_caught_given_fish` tables (gradient 5, width 4, MAD 1; the reference rows' `n_boot_ok` 195, 196, 199). Eight of
  them fail to converge because one term separates (`>= 30 m` or `>= 20 m3/s` with no detection, a `data_set`/`era`
  pair) while every other class's ratio is stable across maxit 25, 50, 100 and 300 (for example width resample 101:
  `< 1.5 m` 4.04, `1.5-2 m` 1.84, `2-4 m` 0.738 at every cap); two (gradient 4, width 166) are IRLS divergence, deviance
  9,000+ against about 450, and are rightly unusable. Counting the eight stable ones moves published bounds of `ok` rows
  at the printed precision: gradient 2.49-3.49 % `ratio_hi` 3.327 -> 3.465, 3.49-5.49 % 2.051 -> 2.036, `<= 0.5 %`
  1.307 -> 1.302; width `no width` 0.137-2.244 -> 0.140-2.201, `2-4 m` 0.499 -> 0.500; underpowered 5.49-8 % hi 2.783
  -> 2.887. No conclusion moves (2.49-3.49 % still excludes 1, at 1.013), and `research/grayling_habitat.md` prints
  none of these rows, so the harm is limited to the CSV's intervals and `n_boot_ok` reading as failures what are mostly
  fits with one separated term. Judge a resample's usability on the classes that are not separated (or drop the
  separated class's rows before the refit), not on `m$converged`; keep refusing a diverged fit.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things"

- **[severity: fragile]** data-raw/grayling_use.R:230-231, 244 — `power` (and `n_visits`, `n_detect`) is counted over
  the whole population (`d_resp`), while `rate_ratio` and its interval come from `modelled(d_resp, y)`, which drops the
  groups with one outcome (225 of 1,580 visits for `gr_caught`, 107 of 736 for the given-fish response). So a class is
  called `ok` on visits its ratio never saw. One row flips: `channel_width / gr_caught_given_fish / no width` is `ok`
  on 31 visits and 10 detections, but the fit sees 24 visits (10 detections), under the script's own 30-visit floor.
  No `gr_caught` row flips, so the write-up's tables are unaffected, but the write-up's tables print the population's
  `visits` beside a ratio fitted on fewer (8-15 m: 195 visits printed, 142 fitted). Count `power` on the modelled rows,
  or say in the header and the write-up which rows each column counts.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: fragile]** research/grayling_habitat.md:72 (also :22-23 and :113-114) — "Above 5.49 % grayling were
  caught on 2 of 152 visits" gives the 5.49-8 % class's count as the whole range above 5.49 %. Above 5.49 % is 206
  visits with 7 catches (5.49-8 % 2/152, 8-12 % 5/49, > 12 % 0/5), and the 8-12 % class's rate ratio is 1.08 (main), 1.06
  (logit), 0.76 (rivers kept), about the reference's rate. So "almost never above it" (:23) and "gradients over 5.49 %
  stay low" under the sensitivities (:114) hold for 5.49-8 % only. Both classes above 5.49 % are underpowered, which is
  the honest statement; the sentences name the range and quote one class.
  - **Rule:** writing.md "State each claim by the code's definition"

- **[severity: fragile]** research/grayling_habitat.md:61, :80 — two table entries are rounded from the CSV's
  3-decimal print, not from the value, the same defect round 2 found in the sensitivity range. `<= 0.5 %` lower bound
  is printed 0.71; the value is 0.70458 (0.705 in the CSV), so 0.70. `< 1.5 m` rate ratio is printed 0.35; the value is
  0.34462 (0.345 in the CSV), so 0.34. Every other number in the three tables matches its unrounded value at two
  decimals (checked all 54).
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: fragile]** data-raw/grayling_segments.R:12-13, 76-82 — the rule "at least half its length within 25 m of
  the segment" admits connector lines (edge 1450) that cross the river polygon from a tributary's mouth to the
  centreline: 3,351 of the 8,311 lines in `all`, 93 km of 1,814. Connectors carry their tributary's flow (CLAUDE.md,
  "Flow on river polygons"), median MAD 0.17 m3/s against 30.8 on the 1250 main flow, so they are tributary rows
  labelled as lines the segment follows. They hold 27.3 of the 28 km under 0.021 m3/s and 18 of the 24 km over 2.49 %:
  without them `pct_km_mad_ge_0.021` is 100.0 (not 98.5) and `pct_km_grad_le_2.49` 99.7 (not 98.7), in every group
  checked (fry, spawning, all). So the log's 1.5 % "below link's MAD floor" and 1.3 % "steeper than 2.49 %" are almost
  all tributary mouths, not critical habitat. The write-up's numbers move by one in their last digit: 1,814 km -> 1,721,
  94 % in river polygons -> 93, median MAD 29 -> 30, width about 56 -> 57; "99 % under 2.49 %" holds. Exclude edge 1450
  (or keep only lines whose watershed code is the segment's river) and rerun, or say in the header that connectors
  are counted.
  - **Rule:** code-check.md "A proxy is not the property"

## Enumeration: every aggregate, count, quantile and share, against the unit it names

`data-raw/grayling_use.R`

| place | unit named | rows that reach it | verdict |
|---|---|---|---|
| :91-107 funnel `visits`, `gr_caught`, `groups` | visits, groups | `dr` rows; `site_visit` unique in `visits_link` (0 dups) and in GR's `visits_species` (0 dups), so one row per visit; last step checked against `pop$d` | holds |
| :109-111 edge-type table | visits by edge type | `dr` rows; sums 11,567 and 1,231 | holds |
| :227-229 "modelled / left out" message | visits, groups | `d` and `d_resp` | holds |
| :230-231 `n_visits`, `n_detect`, `n_groups`, `raw_rate` | class's visits | `d_resp` (whole population) | holds as raw counts; see `power` |
| :244 `power` | evidence behind the ratio | `d_resp`, not the fit's rows | finding 2 (1 row flips) |
| :239 `sep` | class separated in the fit | `d_resp`; the fit's separation is on `d` | holds today (every NA ratio is separated in both); latent: a class separated only after `modelled()` would print `bq()` bounds beside an NA ratio, and `bq()` on an all-Inf column returns -Inf (the run's `max()` warning is that column, masked by `sep` today) |
| :240 `rate_ratio` | fit on modelled rows | `fit_ratio(d)` | holds |
| :241-242 `ratio_lo`, `ratio_hi` | 200 resamples drawn | resamples whose fit converged, separated class at its limit | finding 1 |
| :185-193 `bq()` thresholds | the type-7 quantile with limits | `mean(x == Inf) > 1 - p` | holds today; at exactly 5 Inf of 200 the 0.975 quantile is Inf while `bq()` interpolates to `max(f)` (no column has that count) |
| :243 `n_boot_ok` | usable resamples | non-NA, limits included | holds as defined; counts the finding-1 resamples as failures |
| :250-252 sensitivity `main`, `logit_or`, `rivers_kept` | ratios | `rr`; `fit_ratio(d, "logit")`; `fit_ratio(dr)` with `sep_river` on modelled `dr` | holds |
| :259 `round(..., 3)` | the CSV's precision | once | holds; the write-up re-rounds (finding 4) |
| :266-268 visits by month | visits | `d0` rows | holds |
| :270-276 lengths by month | fish measured | `fish.rds` rows, one per fish | holds |

`data-raw/grayling_segments.R`

| place | unit named | rows that reach it | verdict |
|---|---|---|---|
| :67-68 header km | the layer's segments | `st_length(seg)`, overlaps included | holds as "the layer's km" (not quoted as stream km) |
| :84-86 lines matched, km | lines, each once | `n_distinct`, `distinct()` | holds |
| :96-98 lake lines, km | lines, each once | `distinct()` | holds |
| :116 `segments` | segments in the group | before the dedupe; 23/27/36/13/14/85 match the layer's stage and `CRITICAL_H` counts | holds |
| :117-127 `km`, quantiles, shares | lines the group's segments follow, each once | deduped lines, connectors (1450) included | dedupe holds; finding 5 |
| :114 `share()` denominator | km of the group | includes NA values | holds: no NA `fwa_gradient`, `mad_pick` or `wb_river` among the 8,311 lines |

`research/grayling_habitat.md` numbers

| line | number | source | verdict |
|---|---|---|---|
| 39 | 1,580 visits, 45 groups, 229 | funnel | holds |
| 52-54 | 1,231; 884 = 711 + 56 + 117; 229 | edge-type table | holds |
| 59-69 | gradient table | `gr_use.csv`, unrounded | holds except 0.71 (finding 4) |
| 71-72 | every class to 5.49 % within the interval | CSV | holds |
| 72 | "above 5.49 %: 2 of 152" | 5.49-8 % only | finding 3 |
| 78-87 | width table | CSV, unrounded | holds except 0.35 (finding 4) |
| 89-91 | quarter to a third; 0.6; any-fish 0.15-0.47; no given-fish class below its interval | CSV | holds |
| 97-105 | MAD table | CSV, unrounded | holds (≥ 5 is 2 + 2 visits) |
| 107-109 | a third; no class differs | CSV | holds |
| 114 | "gradients over 5.49 % stay low" | sensitivity | finding 3 (8-12 %: 1.06, 0.76) |
| 115 | 0.62-0.78 | unrounded 0.6245, 0.7846 | holds |
| 117-118 | 1,357 of 1,580; 175 with 11 | month table | holds |
| 122 | 85 segments, six core areas | layer (`CORE_AREA`: 6 named, 24 NA from the 2026 layers) | holds |
| 124-128 | 1,814 km, 94 %, MAD 29, width ~56, 99 %, fry 37 and 99 %, spawning 24 | segments log | match the log; finding 5 moves 1,814, 94, 29, 56 by one in the last digit |
