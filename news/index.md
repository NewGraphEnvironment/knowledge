# Changelog

## knowledge 0.4.23

- The tuning runs on a second link build beside the published one
  ([\#120](https://github.com/NewGraphEnvironment/knowledge/issues/120)).
  `0310` writes a build of another schema into its own `EVIDENCE_DIR`,
  with a tagged ledger, and refuses the default directory to it; `0300`
  takes `SCHEMA` and `POLL_MIN`, and `0310` takes `SETTLE=` and
  `PARENT_DIR`, joining each visit’s minimal-network parent through the
  new
  [`knw_parent_join()`](https://newgraphenvironment.github.io/knowledge/reference/knw_parent_join.md).
  `0320` takes `DEV_DIR`, `GRADIENT=parent_gradient` and test floors
  (`MIN_WSG`, `FOLDS`), which
  [`knw_tune_promote()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_promote.md)
  refuses; `knw_link_access_check(by_group = TRUE)` gives the check per
  group.
  [`knw_build_record()`](https://newgraphenvironment.github.io/knowledge/reference/knw_build_record.md)
  reads link’s output tokens from `<schema>.log`, where link writes
  them, so a tokened build no longer records none. The four-group test
  on link’s minimal network is `research/minimal_network_tuning.md`.

## knowledge 0.4.22

- `inst/NOTICE.md` gives the PSCIS snapshots under `data/<wsg>/` their
  own section: incidental working copies of an “Access Only” catalogue
  layer, not a distribution of PSCIS
  ([\#76](https://github.com/NewGraphEnvironment/knowledge/issues/76)).
  EcoCat, bcfishpass and the modelled flows stay under “Terms not yet
  settled”. No code change.

## knowledge 0.4.21

- The repository is public
  ([\#56](https://github.com/NewGraphEnvironment/knowledge/issues/56)).
  The README’s Learn more links point at the published site: the chinook
  rearing article, the methodology article (newly linked), the function
  reference and the news page. No code change.

## knowledge 0.4.20

- A published article bundle can be rebuilt on any machine
  ([\#119](https://github.com/NewGraphEnvironment/knowledge/issues/119)).
  `scripts/0320` writes a tracked record beside each grade table
  (`<key>_grades_record.csv`, read with
  [`knw_grade_record_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_record_write.md)),
  which the bundles pin instead of the gigabyte tables, and
  [`knw_tune_promote()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_promote.md)
  refuses a key whose record is missing or describes another table. A
  run’s grade tables, records, curves and segments, and its evidence
  build once, are kept in a private, versioned archive
  ([`knw_archive_plan()`](https://newgraphenvironment.github.io/knowledge/reference/knw_archive_plan.md),
  [`knw_archive_put()`](https://newgraphenvironment.github.io/knowledge/reference/knw_archive_put.md),
  `scripts/0336-archive.R`), indexed by version id in
  `data/archive_index.csv`; `PULL=TRUE`
  ([`knw_archive_pull()`](https://newgraphenvironment.github.io/knowledge/reference/knw_archive_pull.md))
  restores the run a checkout’s records name, md5-checked, and
  `scripts/0335` archives each promotion.
  [`knw_build_record()`](https://newgraphenvironment.github.io/knowledge/reference/knw_build_record.md)
  reads link’s output-vocabulary tokens. The methodology article’s
  limits carry the measured site gradient against link’s segment
  gradient
  ([\#121](https://github.com/NewGraphEnvironment/knowledge/issues/121)),
  computed by
  [`knw_site_gradient_visits()`](https://newgraphenvironment.github.io/knowledge/reference/knw_site_gradient_visits.md)
  and
  [`knw_gradient_flips()`](https://newgraphenvironment.github.io/knowledge/reference/knw_site_gradient_visits.md).

## knowledge 0.4.19

- R CMD check runs on every pull request and push to `main` through New
  Graph Environment’s shared workflows (NewGraphEnvironment/flows), so a
  broken example, test or documentation page shows on the pull request
  ([\#98](https://github.com/NewGraphEnvironment/knowledge/issues/98),
  [\#99](https://github.com/NewGraphEnvironment/knowledge/issues/99)).
  Its first runs cleared one warning and two notes:
  [`knw_tune_smoke()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_smoke.md)
  documents `folds`, the fixed-effects fit calls
  [`stats::.lm.fit()`](https://rdrr.io/r/stats/lmfit.html), and seven
  examples are wrapped under R CMD check’s Rd line width. No change in
  behaviour.

## knowledge 0.4.18

- [`knw_compare_rules()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_rules.md)
  logs which rules’ predicates read the near-river table and returns
  `bin_minutes`, each worker’s timed minutes with and without
  `default`’s own (and without the walk where no other predicate reads
  that table), so a run projects what reading `default`’s flags instead
  of regenerating them would save
  ([\#101](https://github.com/NewGraphEnvironment/knowledge/issues/101)).
  On
  [\#112](https://github.com/NewGraphEnvironment/knowledge/issues/112)’s
  runs `default` took 51 to 74 % of a two-rule key’s classify, overlay
  and connect worker minutes. The cache is parked until link’s reworked
  stream layers are built (`research/database_builds.md`).

## knowledge 0.4.17

- `scripts/0330-compare.R` compares link’s `default` and the reported
  structure (`door`) alone unless `STRUCTURES=all`
  ([\#112](https://github.com/NewGraphEnvironment/knowledge/issues/112)):
  the rules it no longer regenerates took 29 to 33 % of the worker
  minutes on three keys. A reported-only run matches the every-structure
  run’s `default` and `door` rows
  (`data-raw/compare_structures_check.R`).
  `knw_compare_rules(structures = "reported")` resolves the structure,
  refuses one outside the species x rule’s own set, and returns each
  rule’s minutes (`worker_minutes`). The chinook article no longer
  quotes the `free` structure.

## knowledge 0.4.16

- Retuning no longer touches the tracked tables or the articles until
  the operator promotes a run
  ([\#111](https://github.com/NewGraphEnvironment/knowledge/issues/111)).
  `DEV=1 0320` is the check after a change upstream: minutes, no
  database, ending in a pick report
  ([`knw_tune_pick_report()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_pick_report.md))
  of each key’s pick beside the published one. A full `0320` and
  `0330 TUNE_DIR=` write ignored candidate runs, and
  `scripts/0335-promote.R`
  ([`knw_tune_promote()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_promote.md))
  moves one in, whole or by key, archiving what it replaces so a
  promotion can be undone, then reruns `0325` and the article bundles.
  Before anything moves it refuses a set that `0325` or the bundles
  would refuse. Summaries record their run and evidence ledger, which
  the readers take through
  [`knw_run_ledger()`](https://newgraphenvironment.github.io/knowledge/reference/knw_run_ledger.md)
  rather than the newest ledger on disk.

## knowledge 0.4.15

- A database-bound run checks its connection’s round trip before any
  work
  ([\#110](https://github.com/NewGraphEnvironment/knowledge/issues/110)).
  [`knw_db_latency_check()`](https://newgraphenvironment.github.io/knowledge/reference/knw_db_latency.md)
  stops `0310`, a grading `0320` and every stage of `0330` over a 20 ms
  round trip, with the round trip and what a remote link cost
  [\#92](https://github.com/NewGraphEnvironment/knowledge/issues/92)’s
  comparison, unless `REMOTE=TRUE`; every run logs the round trip and
  whether the override acted, and a refused run writes its log to its
  own file. `0330` also logs each key’s minutes by stage, which
  [`knw_compare_rules()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_rules.md)
  returns as `timing`.

## knowledge 0.4.14

- Habitat rules and curves are tuned on the gradient of the link segment
  a site sits on (`segment_gradient`), the gradient link applies a rule
  to and the grade reads, instead of the whole Freshwater Atlas line’s;
  `knw_tune_run(cols = )` names the columns, and every grade table,
  summary and curve records the gradient it was fitted on
  (`curve_grad`), which `0320`, `0325`, `0330` and the article scripts
  compare
  ([\#92](https://github.com/NewGraphEnvironment/knowledge/issues/92)).
  `GRADIENT=fwa_gradient 0320` scores the Atlas line’s gradient as a
  sensitivity. Every key is retuned on
  [\#91](https://github.com/NewGraphEnvironment/knowledge/issues/91)’s
  evidence and both articles redrawn. link cuts a segment at a fish
  record, so 86 % of sites with fish start a segment of their own
  against 10 % without, and the results are on link 0.66.0’s segments,
  before link changed where it cuts streams.

## knowledge 0.4.13

- FDIS site visits are placed on the stream their own 1:50k watershed
  code names where one lies within 500 m
  ([`knw_fdis_place()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fdis_place.md)),
  otherwise on the nearest stream within 200 m, with
  [`fresh::frs_point_snap()`](https://newgraphenvironment.github.io/fresh/reference/frs_point_snap.html)
  in place of `fwa_indexpoint()`
  ([\#91](https://github.com/NewGraphEnvironment/knowledge/issues/91)).
  The limits were set by measurement. The evidence keeps 45,529 visits
  against 40,552. `0310` takes `SCHEMA` and caches its walks. The tune
  tables and the articles still describe the
  [\#73](https://github.com/NewGraphEnvironment/knowledge/issues/73) run
  until
  [\#92](https://github.com/NewGraphEnvironment/knowledge/issues/92)’s
  retune.

## knowledge 0.4.12

- The methodology article, “Choosing habitat thresholds from where fish
  were caught”, now runs from what a threshold is straight to the flow
  chart and the eleven steps; how rules are told apart and where the
  fish sampling records are lost follow the worked snap example, before
  the limits.

## knowledge 0.4.11

- A retune is fast enough to iterate on the database’s host
  ([\#87](https://github.com/NewGraphEnvironment/knowledge/issues/87)).
  Grading walks 500 segments per query (`knw_link_walks(batch =)`) and
  keeps every walk in `knw.walk_cache` (`cache =`), keyed on the flow
  load
  ([`knw_discharge_load()`](https://newgraphenvironment.github.io/knowledge/reference/knw_discharge_load.md))
  and the walk’s code
  ([`knw_walk_md5()`](https://newgraphenvironment.github.io/knowledge/reference/knw_walk_md5.md)),
  so one key regrades in about 4 min with its walks cached, and a cold
  regrade of every key took 53 min, against 191.
  `knw_compare_rules(workers =)` spreads a key’s watershed groups over
  several connections, so one key recompares in 4.5 to 37 min (BT
  rearing 33, against 143); the full recompare is still about 2.9 h,
  bound by the database’s cores
  ([\#101](https://github.com/NewGraphEnvironment/knowledge/issues/101)).
  Every grade table records its `walk_md5`, which `0320`, `0325`, `0330`
  and `data-raw/vignette_chinook.R` compare, and `0320` and `0330`
  refuse a schema built by another run at connect
  ([`knw_build_record()`](https://newgraphenvironment.github.io/knowledge/reference/knw_build_record.md)).
  [`knw_discharge_load()`](https://newgraphenvironment.github.io/knowledge/reference/knw_discharge_load.md)
  refuses a flow comment that does not name the historical load the walk
  reads. `research/database_builds.md` covers what a run reads and what
  a second database needs.

## knowledge 0.4.10

- A methodology article, “Choosing habitat thresholds from where fish
  were caught” (`vignettes/habitat_thresholds.Rmd`), walks the pipeline
  from the FDIS records to the published thresholds in plain language:
  what a threshold and a tuned threshold are, how rules are scored and
  chosen (the standard error, and 1 against 1.96 SE), each of the eleven
  steps with its code and settings, where the fish sampling records are
  lost, and every setting that shapes a result, with where it came from
  and whether it has been tested
  ([\#93](https://github.com/NewGraphEnvironment/knowledge/issues/93)).
  The settings are `inst/method/settings.csv`, each naming where its
  value is held, and `test-settings-register.R` fails when the register
  and the code disagree. The chinook article now says how sites reach
  the network, where segment flows come from and which gradient was
  scored, and cites PCIC’s VIC-GL, Raven and the fwapg fork
  ([\#89](https://github.com/NewGraphEnvironment/knowledge/issues/89)).

## knowledge 0.4.9

- Every species’ threshold is retuned on rebuilt evidence
  ([\#73](https://github.com/NewGraphEnvironment/knowledge/issues/73)):
  FDIS visits on wet’s 2026-10-19 flows, the walk to a river ending at a
  double-line river’s bank with every hop’s gap counted (fresh 0.42.0’s
  rule), a gradient ladder to 30 % for every species, and a second pick
  read from link’s flow version of `default`. The scorer was reorganised
  after two defects surfaced on this evidence: the held-out intercept
  search now minimises the deviance directly, and
  [`knw_tune_smoke()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_smoke.md)
  gates every key with a minutes-long run before a grid is scored
  ([\#84](https://github.com/NewGraphEnvironment/knowledge/issues/84)).
  The fit absorbs the watershed-group intercepts and carries a normal
  prior (SD 2.5) on the data-set and era terms
  ([\#83](https://github.com/NewGraphEnvironment/knowledge/issues/83)),
  which made rainbow trout feasible again. The fitted curve takes the
  same prior, and grades are published only for a key whose curve
  predicts held-out groups better than no rule on the curve’s own
  visits: bull trout rearing, chinook, grayling and rainbow are graded;
  bull trout spawning, coho, steelhead and westslope cutthroat carry a
  rule and no grade.
  [`knw_compare_rules()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_rules.md)
  sets each tuned rule beside `default` on link’s segments under its
  through-wetland structures, with a GeoPackage per key; the thresholds
  table gains `near_river_scope` and `evidence_md5`; every table a later
  run reads back records the gate, the evidence and the pick, and every
  reader refuses a mismatch. The chinook article and its data are
  regenerated on the new tables, and the eight research files are
  rewritten.

## knowledge 0.4.8

- The tuning’s “within one standard error of the best” is stated as what
  it is, a parsimony rule of thumb fixed before the run, with its
  sources, and the same choice at 1.96 standard errors is published
  beside it
  ([\#79](https://github.com/NewGraphEnvironment/knowledge/issues/79)).
  [`knw_tune_repick()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_repick.md)
  replays the pick from a saved tune table at any width, and
  `data/thresholds.csv` gains `rule_196` and `holds_196` (still
  `knowledge/thresholds/v1`, not uploaded). At 1.96, five of eight
  species × stages keep `default`, though for four of them the stricter
  bar takes in most or all of the rules; chinook keeps its 0.75 m³/s
  flow floor at `default`’s 5.49 % with no near-a-river allowance. The
  chinook rearing article is shorter and plainer, with its sources
  checked against the papers, a bibliography that
  `data-raw/vignette_bib.R` writes from Zotero with the run’s software
  versions, the line-graph figure marking close calls at both bars, a
  chinook 1.96 table, and on the website an interactive Bulkley map on
  Esri’s World Topographic Map
  ([`knw_compare_mapgl()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_mapgl.md)).
  The README credits fwapg, bcfishobs and bcfishpass to Simon Norris.
- `inst/CITATION` reads a Zenodo concept DOI from DESCRIPTION’s
  `Config/DOI` when the package has one. It has none yet, so the
  citation is unchanged.

## knowledge 0.4.7

- The README is rewritten to the README convention
  ([\#75](https://github.com/NewGraphEnvironment/knowledge/issues/75)).
  It says what knowledge is and the thresholds it tunes for link’s
  habitat models, maps chinook rearing in the Bulkley under link’s
  `default` rule and the tuned rule (`data-raw/readme_figure.R`), shows
  how to install the package and reach the published FDIS data, and
  reads `data/thresholds.csv` in a short example. DESCRIPTION’s title
  and description say the same. The package gains a hex sticker, a
  citation (`citation("knowledge")`, and `CITATION.cff` kept current by
  a workflow) and `inst/NOTICE.md`, which names each outside data source
  with its terms; the terms of the PSCIS layers and the EcoCat- and
  bcfishpass-derived files are open in
  [\#76](https://github.com/NewGraphEnvironment/knowledge/issues/76).
  [`knw_compare_map()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_map.md)’s
  `title` is documented as what it does: it names the interactive page
  and the message when nothing is drawn, and the static map draws none.

## knowledge 0.4.6

- The grade reads every segment at its own distance to a river
  ([\#65](https://github.com/NewGraphEnvironment/knowledge/issues/65)).
  [`knw_grade_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_species.md)
  used to walk only the segments the rule’s exception could admit and
  read the rest at the 50 km distance cap, which on the joint size and
  distance curve understates any segment near a river: every key was
  affected, and six of the eight walked nothing at all. It now walks
  every accessible segment with a gradient to the pick’s exception river
  (10 m³/s where it has none) and records `dist_status`. The reference
  rate that reads 1 is now taken over the stream branch, the edge types
  the curve was fitted on. Over every accessible segment, river-polygon
  segments would make up most of the top 5 % for chinook, coho,
  steelhead and cutthroat and raise their reference 1.4 to 4 times
  (chinook 0.14 to 0.52); for bull trout, grayling and rainbow the two
  references are within 7 %.
  [`knw_grade()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade.md)
  gains `ref_rows` and
  [`knw_grade_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_species.md)
  gains `ref_edge` for this; its `edge_stream`, which limited the walk
  to the stream branch and which no caller set, goes with the walk’s old
  limits. `habitat_grade/v1`, never uploaded, is regraded before its
  first publication, and gains `stream_branch`: off the stream branch,
  on lines through lakes, wetlands and double-line rivers and on other
  connectors, the grade extrapolates the curve past its visits, and
  those lines hold 21–79 % of each key’s km graded 0.8 or more. The
  thresholds, `default`‘s km and the width rules’ km do not move; the
  flow-ruled tuned rules move by under 0.3 % because wet republished the
  segment flows the same day (NewGraphEnvironment/wet#103), and retuning
  on those flows is
  [\#73](https://github.com/NewGraphEnvironment/knowledge/issues/73).

## knowledge 0.4.5

- [`knw_tune_run()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_run.md)
  gains `grid_args`, passed to
  [`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md),
  and reads a cached score back only for the grid it was scored on
  ([\#67](https://github.com/NewGraphEnvironment/knowledge/issues/67)).
  `scripts/0322` scored chinook rearing on gradient limits up to 30 %:
  the best rule moves from 9 % to 15 %, and every limit from 7 to 30 %
  has rules in the region, but choosing among the longer ladder loses to
  `default` under nested selection. `CH_rear_v1` keeps 9 %; extending
  the ladder for every species is
  [\#68](https://github.com/NewGraphEnvironment/knowledge/issues/68).
  The chinook rearing article says so.

## knowledge 0.4.4

- A pkgdown article,
  [`vignette("chinook_rearing")`](https://newgraphenvironment.github.io/knowledge/articles/chinook_rearing.md),
  explains in plain language how the chinook rearing threshold was
  chosen from the province’s electrofishing records and what it changes
  on link’s segments, with a Bulkley map, a zoom and three labelled
  example segments
  ([\#62](https://github.com/NewGraphEnvironment/knowledge/issues/62)).
  Its data are written by `data-raw/vignette_chinook.R` to
  `inst/vignette-data/`, and a test fails when a tracked source moves
  on.
  [`knw_compare_map()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_map.md)
  gains `ncol`, `panels`, `mark`, `lwd`, `legend` and `labels`; its
  default output is unchanged. The package now declares R \>= 4.1.0.

## knowledge 0.4.3

- One evidence build, one tuning run and one comparison across species
  and life stages, as package functions on link’s province-wide
  `default` run
  ([\#57](https://github.com/NewGraphEnvironment/knowledge/issues/57)):
  `knw_fdis_visits()`,
  [`knw_link_place()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_place.md),
  [`knw_link_flow()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_flow.md),
  [`knw_link_width()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_width.md),
  [`knw_link_walks()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_walks.md),
  [`knw_link_barrier_dnstr()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_barrier_dnstr.md),
  [`knw_bcfishobs_match()`](https://newgraphenvironment.github.io/knowledge/reference/knw_bcfishobs_match.md)
  and
  [`knw_link_access_check()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_access_check.md)
  build the evidence;
  [`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md),
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md),
  [`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md),
  [`knw_grade()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade.md)
  and
  [`knw_tune_run()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_run.md)
  score every rule of each species and stage on held-out watershed
  groups, pick, fit the joint curve and grade every segment;
  [`knw_thresholds_table()`](https://newgraphenvironment.github.io/knowledge/reference/knw_thresholds_table.md)
  and
  [`knw_publish()`](https://newgraphenvironment.github.io/knowledge/reference/knw_publish.md)
  write the thresholds and grade tables;
  [`knw_compare_rules()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_rules.md),
  [`knw_floodplain_ha()`](https://newgraphenvironment.github.io/knowledge/reference/knw_floodplain_ha.md)
  and
  [`knw_compare_map()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_map.md)
  show what a rule changes on link’s segments (km, graded km, floodplain
  hectares, maps). Scripts `0300`–`0330` run them.
- Eight species × stage fit. `default` is outside the one-SE region for
  every species but grayling; chinook’s size floor settles at 0.75 m³/s;
  bull trout spawning fits but is weak. `data/thresholds.csv` and
  `data/thresholds_groups.csv` carry the result in link’s parameter
  names; `0290`, `0294` and `0296` write their tables from the new
  build, and `0291`–`0298` read the published v2 visit tables
  (`0299 PULL=TRUE VERSION=v2`). Results:
  `research/habitat_thresholds_tuned.md` and one file per species.

## knowledge 0.4.2

- The README points at the published FDIS visit tables’ second release,
  `knowledge/fdis/v2/`, which keeps one copy of a survey loaded under
  several collection ids and carries the crosswalk from v1’s
  `site_visit` ids
  ([\#35](https://github.com/NewGraphEnvironment/knowledge/issues/35)).

## knowledge 0.4.1

- The package now sits at the repository root and installs with
  `pak::pak("NewGraphEnvironment/knowledge")`. `DESCRIPTION` gains `URL`
  (the new pkgdown site and the repository) and `BugReports`, and the
  [`knw_pscis_pull()`](https://newgraphenvironment.github.io/knowledge/reference/knw_pscis_pull.md)
  example connects through the standard `PG*` environment variables.

## knowledge 0.4.0

- New evidence variable `instream_flow`: a flow need, the water a life
  stage needs while it is in the stream, kept apart from `discharge`,
  which is stream size (usually the MAD an intrinsic-potential model
  filters on). It takes `m3/s`, `cfs`, `percent MAD`, a `percentile` or
  a `percent exceedance`, and a `metric` naming the flow statistic it is
  held to (`instantaneous`, `daily_mean`, `7day_low`, `monthly_mean`,
  `monthly_median`, `unstated`). It carries no `parameter` or
  `model_id`, and the `*_mad_*` parameters now sit on `discharge` rows
  only. A `7day_low` row needs a note giving its return period.
- `depth` and `velocity` read in the unit the source wrote: `cm` and
  `ft` for depth, `cm/s` and `ft/s` for velocity, as well as `m` and
  `m/s`. A channel’s bankfull depth is stream size and reads as
  `m bankfull`.
- Rows that changed variable or unit, so a filter on the old values
  returns fewer rows: data row 121 (a migration low flow, now
  `instream_flow` and coded `SALMON`), rows 250, 257 and 264 (bankfull
  depths, now `m bankfull`), and rows 497 and 498 (redd velocities, now
  `cm/s` as quoted).

## knowledge 0.3.1

- New evidence variable `groundwater`: upwelling, hyporheic exchange and
  springs. It takes no unit, so a `groundwater` row is a statement with
  no value, until a source gives an upwelling measure.

## knowledge 0.3.0

- [`knw_literature_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_read.md)
  requires a `metric` column, after `unit`: which statistic a
  temperature value is (daily maximum, MWMT, 7DADM, MWAT, 7DEC, a
  weekly, monthly, August, summer or annual mean, a constant laboratory
  exposure, or `unstated`), or which window a degree-day total
  accumulates over (`growing_season`, `to_hatch`, `to_emergence`,
  `annual`). A table without the column is refused. A temperature-family
  value needs a metric that fits its variable; a `none` row may name the
  one it searched for; every other row leaves it blank.
- New evidence variables `degree_days` (`degC-day`) and
  `air_temperature` (`degC`). Air temperature is its own variable
  because intrinsic-potential models use it as a proxy for water
  temperature. A cited `degree_days` row needs a `note` giving its base
  temperature.
- A `none` row may carry `bound`, naming the limit that was searched
  for.
- New `kind` `lab`: a laboratory or hatchery measurement (a lethal
  limit, CTmax, survival or growth at held temperatures, a development
  time in degree-days), which is not expert opinion.
- A `qual` row is refused a value: it is a statement, and a value on it
  would be counted as evidence it is not.

## knowledge 0.2.1

- [`knw_literature_vocab()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_vocab.md)
  adds `elevation` to the `variable` vocabulary, in `m` or `ft`, so a
  source that fits an elevation term (a watershed-scale occurrence
  coefficient, say) can be recorded. Other units are refused.

## knowledge 0.2.0

- [`knw_ip_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_ip_read.md)
  and
  [`knw_ip_vocab()`](https://newgraphenvironment.github.io/knowledge/reference/knw_ip_vocab.md)
  read and validate the intrinsic-potential model registry: one row per
  model, species and life stage, recording how the model sizes streams
  (`flow_metric`, `flow_source`, `flow_inputs`, `flow_surrogate`), its
  valley-confinement variable and whether it was validated against fish,
  each claim with a verbatim quote.
- [`knw_literature_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_read.md)
  requires a `model_id` column (its value may be blank), linking a
  threshold to the registry model that uses it. A table without the
  column is refused.
- `parameter` is now a controlled vocabulary (the habitat-model
  parameter names, in
  [`knw_literature_vocab()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_vocab.md)),
  so a misspelt or invented parameter is refused rather than silently
  matching nothing.
- New evidence variables `valley_width_index` (`ratio`) and
  `drainage_area` (`km2`, `mi2`); `cfs` for discharge and `ft` for
  channel width are read as the source wrote them.

## knowledge 0.1.0

- First version: PSCIS pulls by watershed group, GNIS collision checks,
  size classes, and readers for the life-history timing and literature
  evidence tables.
