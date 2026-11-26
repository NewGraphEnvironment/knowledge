# Code-check round 2: #140 branch (grayling_use.R, grayling_segments.R, docs, round-1 fixes)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check-r.md, by heading (18 read): "`download.file(quiet = TRUE)` never tells you the HTTP status", "A URL handed
  to a reader goes through R's 60 s connection timeout", "A `data-raw/` script must load the source tree, not the
  installed package", "A database driver's value is not a base R type", "`paste()` with a zero-length argument
  returns length ONE", "A design matrix does not hold everything a formula says", "`tryCatch(warning = )` DISCARDS
  the value", "`match()` treats NA as a matchable VALUE", "`unlist()` prefixes a `split()` group's name",
  "`summarise()` and `mutate()` evaluate in order", "Postgres row order is never fixed unless the query fixes it",
  "Inside a dplyr verb, a column named like a local variable wins", "`system2(stdout = TRUE)` warns on a non-zero
  exit", "Forked `parallel::mclapply()` workers segfault in `glm.fit`", "`clusterApply()` returns `NULL` for no
  tasks", "`c(name = x)` keeps `x`'s own name", "`ifelse()` with an all-NA test returns a logical vector", "Numeric
  routines that err at their edge, and `round()`". The other 114 headings not read: no tool or shape they name is
  used.
- code-check-shell.md, by heading (1 read): "Git plumbing calls whose default answers a different question". The
  other ~120 not read.
- code-check-spatial.md, by heading (4 read): "Ask the file about its field names, not R", "A GDAL failure partway
  through `sf::st_read()`…", "FWA main flow is not edge type 1000 alone", "FWA lookup area follows watershed codes…".
  The rest not read.
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows and evidence blocks skipped).

Index, diff and changed files read from file.

Probes (nothing in the repo written; `git status` unchanged before and after): a copy of `data-raw/grayling_use.R`
at `<scratchpad>/r2probe/grayling_use_copy.R` with `path_out` and `path_log` redirected to the scratchpad, run from
the repo root. It reproduced `data/gr_use.csv` byte for byte (`cmp`), and its log differs from the committed
`20261126_grayling_use.txt` only in the commit stamp. A second probe (`<scratchpad>/r2probe/probe2.R`) re-drew the
gradient / gr_caught bootstrap (seed 141, as the script draws it) and the unrounded sensitivity ratios. No database
was used.

## Findings

- **[severity: fragile]** data-raw/grayling_use.R:165-174 (`fit_ratio`'s separation check, applied in each
  resample) with :411-414 (`quantile(..., na.rm = TRUE)`, `n_boot_ok`) — round 1's fix moved the defect one axis
  over. A resample where a class is separated is informative, not failed: for a class with no detection its ratio
  is at the bottom of the distribution. The fix turns it into NA, and `na.rm = TRUE` then drops it, so the published
  interval is the interval *conditional on the class having a detection*, which cuts off exactly the tail the
  2.5 % bound is meant to report. Measured on gradient 5.49-8 % / gr_caught (2 detections in 152 visits): the class
  is present in all 200 resamples and has zero detections in 26 of them (13 %, far past the 2.5 % tail). The CSV
  gives 0.047-0.313 (`n_boot_ok` 174); with those 26 resamples at 0 the percentile interval is 0-0.312. So the lower
  bound reads as a measured floor that the bootstrap does not support. Round 1 gave 0 here (correct in substance);
  now it is a plausible wrong number. The same conditioning applies wherever `n_boot_ok` falls below the reference
  row's by more than 5 (2.5 % of 200): gradient 5.49-8 % and 8-12 % (gr_caught and gr_caught_given_fish), > 12 %
  any_fish_caught, channel width 15-30 m (gr_caught, any_fish_caught, given_fish), >= 30 m any_fish_caught, 1.5-2 m
  given_fish, MAD >= 20 m3/s any_fish_caught. Every one is `underpowered` today, and `research/grayling_habitat.md`
  prints no interval for any of them, which limits the harm; but `data/gr_use.csv` is the tracked table CLAUDE.md
  describes as carrying stream-bootstrap intervals, and `n_boot_ok` does not say that the missing resamples are the
  tail rather than failures. The header's accepted tradeoff covers near-separated resamples widening an interval,
  not separated ones narrowing it. Where a class's separated resamples exceed the tail, give that bound as the
  separated limit (0 for no detection, NA for all detections) or NA, as round 1 suggested, instead of the quantile
  of the rest.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things"

- **[severity: fragile]** research/grayling_habitat.md:115 — "the classes from 2 to 5.49 % read somewhat lower
  (0.63–0.79 against 1–2 %)" does not match its source at the precision written. The log's sensitivity table prints
  `rivers_kept` 0.656, 0.785, 0.625 (rounded to 3), and the unrounded values are 0.65590, 0.78464 and 0.62451, so
  the range is 0.62–0.78. Both ends were rounded a second time from the log's 3-digit print (0.625 -> 0.63,
  0.785 -> 0.79). Small, but it is a printed number in the write-up whose source says otherwise.
  - **Rule:** code-check.md "One fact derived twice"

## Round-1 fixes, checked

- Segments double counting (finding 1): `distinct(linear_feature_id, .keep_all = TRUE)` per group is safe because
  every per-line attribute used after it (`length_metre`, `fwa_gradient`, `mad_pick`, `cw_deploy`, `wb_river`) comes
  from joins that are 1:1 on `linear_feature_id` (`knw_link_flow()` and `knw_link_width()` stop on a duplicate id);
  `stage`/`critical` differ by row but are read only before the dedupe. `segments` is counted before the dedupe. The
  lake message and the matched-km message count each line once. The committed log (stamped a78463f; the script is
  unchanged since) is internally consistent: 2,063 km matched - 249 km in lakes = 1,814 km for `all`, 85 of 85
  segments. Research numbers on the segments (1,814 km, 94 % river polygon, median MAD 29, width ~56, 99 % under
  2.49 %, fry median MAD 37 and 99 %, spawning 24) all match the log.
- Lake definition (finding 3): `wb_any_lake` is every FWA lake polygon and `wb_lake` adds man-made waterbodies of
  100 ha or more, as the header now says; the gradient sentence now names the Atlas line's gradient.
- Terms (finding 4): NOTICE's "Terms not yet settled" lists the layer, and #76's body (open) names it.
- `why` notes (finding 5): all 18 rows of `data/grayling_additions.csv` parse with 14 fields and no readr problems,
  no note is cut, and the Northcote 1995 row now agrees with its filing (neither PDF nor abstract).
- Capture tables: every count, ratio and interval `research/grayling_habitat.md` prints in its three tables matches
  `data/gr_use.csv` (MAD's "≥ 5" row sums the 5-20 and >= 20 rows), and the funnel (1,580 visits, 45 groups, 229 with
  GR), edge-type split (711 + 56 + 117 = 884 of 1,231) and month counts (1,357 in July-September; 175 in May-June with
  11) match the log. The any-fish range 0.15-0.47 and the "no class differs" sentences hold against the CSV.
- Issue numbers the branch adds (#76, #140, #280, #281) resolve to grayling or licence issues as cited. No host,
  port, home path or private identifier in the diff or the two committed logs.
- Other checks clean: `transform(vl, wb_river = FALSE)` cannot mangle names (every `visits_link.csv` column is
  syntactic), and no evidence column is named like a local the dplyr verbs read (`y`, `F`, `U`, `cls`, `class`,
  `rr`, `bw`, `v`, `sep`).
