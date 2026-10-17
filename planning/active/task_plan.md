# Task: Tune habitat thresholds for every species and life stage in one run, as package functions (#57)

**If done:** one evidence build and one tuning run give, for every species and life stage the evidence can speak to, on every watershed group the species occupies: calibrated thresholds, a 0–1 grade for each segment, and outputs that show what a tuning changes on the ground (km, graded km and graded floodplain hectares, with maps), as published tables that link and anyone else can read. **If never:** each species is tuned by its own one-off scripts (BT `0290`-`0293`, CH `0296`-`0298`), each build is redone, each run covers only the groups that happened to have a link build, and habitat stays on/off, so a floodplain beside marginal habitat ranks with one beside the best.

Replaces #59. Decisions taken at the plan gate (2026-10-17) and the plan review's disposition are in `findings.md`. Data flow for Phase 2: grid → score → pick → curve → grade.

## Phase 0: Wait for link's run to settle
- [x] Background waiter `scripts/0300-link-settle-wait.R` (an `until` loop in one `run_in_background` call, probe in
      the foreground): releases when every group in `fresh_default.streams` has a `log_recompute` row with
      `date_end`, the summed `pg_stat_user_tables` inserts+updates+deletes over `fresh_default` are unchanged across
      three polls 10 min apart, and no non-idle session's query names `fresh_default`; stops and reports after 24 h
- [x] Record in `findings.md`: `run_uid`, `log_recompute` count, churn value, release time (UTC), link, fresh and
      fwapg SHAs from `fresh_default.log`
- [x] Pin the link commit the build reads configs from (`link_sha`, as `0298` does); read wet's picked-flow counts
      from its manifest (`wet_catalog()`), not a re-hardcoded literal (`0294:70`)
- [x] Verify `fresh_default.barriers` covers the 241 groups and which `barrier_source` values it carries
      (`SUBSURFACE_FLOW` was absent before); ledger it

## Phase 1: One evidence build, as package functions
- [x] `knw_fdis_visits(build_dir, codes)`: `0230`'s sites × catch × fish → one row per visit × species: `n_caught`,
      counts per size class (`knw_size_class()`), effort, measured habitat; `0290`/`0294`'s quality drops as a ledger
      that partitions the input; per-species absence blocking from `data/fdis_species_codes.csv`, whose
      `blocks_absence_of` is extended beyond `CH;char` (salmon group codes such as `AO`, trout group, grayling) and
      checked against the FDIS code list; fixture tests
- [x] `knw_bcfishobs_match(conn, visits)`: parse `fshclctn_id` from `bcfishobs.observations.source`, match on
      collection × `species_code` × `observation_date` = visit `date`; report match rate by species and the
      collections with several visits on one date (kept as many-to-one, flagged); a workbook record (`0250`'s
      `fiss_evidence.csv`) that bcfishobs holds and FDIS does not takes its count, and its effort where `0220`'s
      step-2 file holds it (five groups); it scores only with effort, otherwise it is presence-only
      (`scores = FALSE`, chooses groups and feeds the outside check)
- [x] `knw_link_place(conn, visits, schema)`: `0290`'s placement generalised (start window, containing segment,
      deterministic tiebreak, overlap stop); joins `streams`, every `streams_access.access_<sp>`, every
      `streams_habitat_<sp>` (flags re-gated on `access_<sp> > 0`), elevation; one schema, province-wide
- [x] `knw_link_flow(conn, lfids)`: `0294`'s MAD by source with parent fallback and `flow_from`, at visit and at
      segment scale (the segment form feeds the grade); regulated reaches
- [x] `knw_link_width(conn, lfids)`: `0296`'s `cw_deploy` with the model-agreement control
- [x] `knw_link_walks(connector, starts, q_grid, sources, workers)`: `0296`'s walks (`inst/sql/ch_dist_profile.sql`
      moved into the package); takes a connector function, never a connection (each socket worker opens its own
      and installs the `pg_temp` function); positive control against `0294`'s 10 m³/s walk
- [x] `knw_link_barrier_dnstr(conn, pts, species)`: natural barrier downstream before overrides, per species, from
      `fresh_default.barriers` (`blocks_species`); no `fresh` fallback
- [x] `knw_link_access_check(conn, schema)`: the habitat-`accessible` vs `access_<sp>` cross-tabulation per species
      (link#349's query), written to the ledger on every run; RB and KO flagged unresolved
- [x] Species pooling per group through `link::lnk_species_pooling()` per species (BT/DV is the only pool; no row
      is the normal result); `access_<sp> = 2` kept in the population, never a covariate
- [ ] `scripts/0310-evidence-build.R` runs the above → `data/fdis/derived/visits_link.csv`, `walks.csv`,
      `access_check.csv`; ledger in `scripts/logs/habitat/`; `0290`, `0294`, `0296` reduced to calls that write their
      tables from it; `0299` gains `VERSION=` for `PULL` and publishes the set as `knowledge/fdis/v3`
- [x] Tests: pure parts (placement tiebreak, ledger partition, absence blocking, size classes, match logic) as
      functions with fixture tests; SQL-bound functions behind a `skip_if_no_pg()` helper that attempts the
      connection (not an env-var test), listed in `tests/testthat/README` as live-only; `@examples` for `conn`
      functions in `\dontrun{}`

## Phase 2: One tuning run across species and stages (data flow: grid → score → pick → curve → grade)
- [x] `knw_tune_grid(species, stage, thresholds)`: a rule family per species × stage around link's own `default`
      thresholds (`parameters_habitat_thresholds.csv` at the pinned commit): size test (MAD floor or width floor),
      gradient maximum, near-a-river exception Q × D; `default` is a member; departures counted against it. KO
      rearing (lake-only in `default`) and SK have no stream rule and are out of the grid, stated in the output
- [x] `knw_tune_score(visits, walks, grid, resp, seed, folds = 5)`: `0297`'s spec as a function: in/out patterns,
      five stratified WSG folds (each group held out once), cloglog glm + per-WSG intercept refit, held-out
      deviance, one-SE region, fewest-departures pick, `d_floor`, WSG bootstrap, nested selection, extra seeds
- [x] Stage × response: rearing from electrofishing detection (U, with F and C beside it); spawning from spawner
      evidence (`0293`'s maturity rule) which only char carry, so spawning rows exist for BT (WCT if the counts
      allow) and other species' spawning rows state "no electrofishing spawner evidence"; a species × stage enters
      when ≥ 5 groups have both outcomes and is labelled `underpowered` under 10 groups; each thresholds row states
      its response and `n_wsg`
- [x] `knw_tune_curve(visits, walks, pick, seed)`: after the pick, one GAM per species × stage: `te(log size,
      log dist)` + `s(gradient)` + `log_area + data_set + era + s(wsg, re)`, size = the pick's `size_var`, dist = the
      walk to the pick's Q with `none`/`Inf` censored at 50 km; held-out deviance on the same five folds reported
      beside the grid's; never a product of one-variable curves
- [x] `knw_grade(model, segments)`: segment prediction at reference nuisance values, random effect excluded, / the
      95th percentile over accessible segments, capped at 1; a segment with the pick's size variable NULL takes the
      other size variable (segment-scale MAD with parent fallback where width is NULL), grade NA only when both are
      missing, counted; `grade_class` in fifths
- [x] `knw_tune_run(evidence, species, stages, workers, seed)`: one job, socket workers, seed fixed, writes
      `data/tune/<sp>_<stage>_{tune,curves,flips}.csv`; CH's size floor (0.75 vs 0.5) read off the CH rearing row
      on all CH groups
- [ ] `scripts/0320-tune-run.R` on the 16-core machine after its link/fresh upgrade; versions asserted; log with
      runtimes; two re-runs byte-identical

## Phase 3: Published results
- [ ] Thresholds table `knowledge/thresholds/v1`, one row per species × stage × component of the joint pick:
      `rule_id` (ties the components), `species_code`, `stage`, `response`, `component` (`size`, `gradient`,
      `exception_q`, `exception_d`), `link_parameter` (link's column name where one exists, e.g. `rear_mad_min`,
      `rear_gradient_max`; `NA` for the exception, which link has no column for), `model` (`cw`/`mad`), `value`,
      `unit`, `range_lo`, `range_hi` (one-SE), `readings_in`, `default_value`, `default_in_region`, `n_visits`,
      `n_detect`, `n_wsg`, `power`, `evidence_version`, `link_run_uid`, `link_sha`, `config`; a companion
      `thresholds_groups` table lists the groups each `rule_id` was scored on
- [ ] Grade table `knowledge/habitat_grade/v1`: `blue_line_key`, `downstream_route_measure`,
      `upstream_route_measure`, `linear_feature_id`, `watershed_group_code`, `length_metre`, `access` (`access_<sp>`
      value; inaccessible segments carry grade NA), `species_code`, `stage`, `grade`, `grade_class`, `rule_id`,
      `config`, `link_run_uid`, `evidence_version`; Hive `species=/stage=`, one part per FWA drainage
- [x] `knw_publish(tables, dataset_id)` generalising `0299` (schema-drift and sha gates kept); built locally in every
      run; `PUBLISH=TRUE` only after #56's bucket policy is applied (gate in the script, noted in README)
- [ ] `research/` one file per species, revised in place: `chinook_rearing_tuned.md` and `habitat_weights.md` gain
      the table pointers and the historical markers (decision 2); new species get `<species>_tuned.md`;
      `research/README.md` rows
- [ ] `scripts/README.md` run order (new block, frozen-on-v2 note); CLAUDE.md layout entries

## Phase 4: What a tuning changes: comparison outputs
- [x] flooded: file an issue and PR so `fl_valley_join()`'s `nearest` returns the owning segment row (`seg`), which
      it computes and drops; knowledge pins `flooded >= ` that release. Until it lands, Phase 4's floodplain step
      runs on grade-class logical dummies and reports ha by class only
- [x] `knw_compare_rules(connector, schema, species, stage, rules, groups)`: `0298`'s three-stage regeneration on
      scratch copies, with the predicate built from `fresh::frs_habitat_predicates()` with substituted thresholds
      plus an injected exception clause, checked equal to fresh's own `default` on every segment per species × stage
      (count in the ledger); spawning and rearing regenerated together (connectivity reads spawning); km kept, lost,
      gained; graded km (km × grade); km by grade class; change by reason and order; `0298`'s bcfishobs outside
      check (lift with bootstrap) per species
- [ ] Floodplain as a unit: for the 23 catalog groups, `floodplain.gpkg`'s `all_ff04` polygon rasterised on the
      item's `proj:transform` grid in its CRS (reproduces `floodplain_ff04_km2` within a cell's tolerance, checked),
      `all_ff04_by_blue_line_key` as the attributed layer (claims must cover exactly the raster's cells, checked),
      link segments cut from the FWA blue line at their measures and transformed; `fl_valley_join(nearest)` → ha
      beside each segment; graded ha = ha × grade; ha, graded ha and ha by grade class under each rule; the FWA
      version and the item's `link:config_sha256` recorded
- [ ] Maps per group: kept / lost / gained; grade class; floodplain polygons shaded by their segment's grade; static
      through gq (`gq_reg_main()`), interactive through mapgl; `research/fig/`
- [ ] `scripts/0330-compare.R` → `data/compare/*.csv`, maps; parallel per group on the run host; totals upstream of
      a crossing left to link#321

## Phase 5: Take over link's calibration
- [ ] WCT, GR, RB and KO are in Phase 2's species set wherever the evidence admits them; what each lacks is stated
      in its thresholds rows
- [ ] After the repo is public (#56): file the transfer issues here for link#322 and link#343, pointing at the
      thresholds table (link is public, so `NewGraphEnvironment/link#N` links are fine); draft, not post, the link
      comments that close the loop on link#346

## Validation
- [ ] Tests pass (`devtools::test()`), `devtools::document()`, `pkgdown::check_pkgdown()`, `lintr`
- [ ] `/code-check branch` clean (three-round floor)
- [ ] Every build's ledger partitions its input; rule outputs byte-identical on a re-run
- [ ] PWF checkboxes match landed work; `/planning-archive` on completion

