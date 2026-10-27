# Package index

## Habitat evidence

Read and validate the cited literature evidence and the
intrinsic-potential model registry, and list their controlled
vocabularies.

- [`knw_literature_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_read.md)
  : Read the literature evidence table, filtered by species and variable
- [`knw_literature_vocab()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_vocab.md)
  : Controlled vocabularies of the literature evidence table
- [`knw_ip_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_ip_read.md)
  : Read the intrinsic-potential model registry, filtered by species
- [`knw_ip_vocab()`](https://newgraphenvironment.github.io/knowledge/reference/knw_ip_vocab.md)
  : Controlled vocabularies of the intrinsic-potential model registry

## Life-history timing

- [`knw_timing_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_timing_read.md)
  : Read the life-history timing table, filtered by group and species
- [`knw_timing_stages()`](https://newgraphenvironment.github.io/knowledge/reference/knw_timing_stages.md)
  : Life stages in the life-history timing table

## Fish records

- [`knw_size_class()`](https://newgraphenvironment.github.io/knowledge/reference/knw_size_class.md)
  : Size class of each fish from a table of length breaks
- [`knw_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_species.md)
  : The species the habitat evidence is built for
- [`knw_fdis_place()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fdis_place.md)
  : Pick each FDIS site visit's stream from the nearest snap and the
  streams its 1:50k code names
- [`knw_fdis_quality()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fdis_quality.md)
  : Drop the FDIS site visits that cannot carry evidence, and count
  every drop
- [`knw_fdis_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fdis_species.md)
  : Catch, presence and absence per FDIS site visit and species
- [`knw_spawner_evidence()`](https://newgraphenvironment.github.io/knowledge/reference/knw_spawner_evidence.md)
  : Spawner evidence per visit for the char species, from maturity codes
- [`knw_fiss_visits()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_visits.md)
  : Fish Data Submission workbook sites as visits, with the effort they
  recorded
- [`knw_bcfishobs_match()`](https://newgraphenvironment.github.io/knowledge/reference/knw_bcfishobs_match.md)
  : Match bcfishobs records to the FDIS site visits they came from

## Evidence on link’s segments

Place site visits on link’s segments with every species’ access and
habitat flags; read a species’ segments, flow, width, regulated reaches,
natural barriers downstream and the walks to rivers; and count where
link’s two access columns disagree.

- [`knw_link_place()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_place.md)
  : Place site visits on link's segments, with access and habitat for
  every species
- [`knw_link_segments()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_segments.md)
  : link's segments for one species in a set of groups, with flow and
  access, for grading
- [`knw_link_flow()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_flow.md)
  : wet's annual flow on FWA segments, with a parent fallback
- [`knw_link_width()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_width.md)
  : The channel width link reads on a stream nobody measured, and the
  waterbody tests
- [`knw_link_regulated()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_regulated.md)
  : Points on the FWA network downstream of a regulating dam
- [`knw_link_barrier_dnstr()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_barrier_dnstr.md)
  : Whether a natural barrier to a species lies downstream of each point
- [`knw_link_walks()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_walks.md)
  : Network distance downstream to the first river of each size, on each
  flow source
- [`knw_walk_md5()`](https://newgraphenvironment.github.io/knowledge/reference/knw_walk_md5.md)
  : The walk's code, by its md5
- [`knw_discharge_load()`](https://newgraphenvironment.github.io/knowledge/reference/knw_discharge_load.md)
  : The flow load the database serves, by its table comment
- [`knw_build_record()`](https://newgraphenvironment.github.io/knowledge/reference/knw_build_record.md)
  : The database build a run reads, and the check that it is the
  evidence's
- [`knw_link_access_check()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_access_check.md)
  : How link's two access columns disagree, per species

## Tuning

Build candidate rules around link’s thresholds and score them on
held-out watershed groups, fit the joint use curve at the pick, and
grade every segment by expected use. The building, scoring and fitting
run in one call for every species and stage the evidence can speak to.

- [`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md)
  : The candidate rules for one species and stage, around link's own
  thresholds
- [`knw_walk_index()`](https://newgraphenvironment.github.io/knowledge/reference/knw_walk_index.md)
  : Index the walks by source and river size, for the exception test
- [`knw_rule_in()`](https://newgraphenvironment.github.io/knowledge/reference/knw_rule_in.md)
  : Whether each visit is in under one rule, on the stream branch
- [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)
  : Score candidate rules on held-out watershed groups
- [`knw_tune_repick()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_repick.md)
  : Pick a rule again from a tuning table, at another width of the
  region
- [`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md)
  : One curve per species and stage: use against size, gradient and
  distance to a river, together
- [`knw_grade()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade.md)
  : Grade segments by expected use, 0 to 1
- [`knw_grade_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_species.md)
  : Grade every segment of a species' groups by its tuned curve
- [`knw_tune_smoke()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_smoke.md)
  : Score a handful of rules and gate the scorer before a full tuning
  run
- [`knw_tune_run()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_run.md)
  : Tune every species and stage the evidence can speak to, in one run

## Published results and comparison

- [`knw_thresholds_table()`](https://newgraphenvironment.github.io/knowledge/reference/knw_thresholds_table.md)
  : The published thresholds table, from a tuning run's outputs

- [`knw_publish()`](https://newgraphenvironment.github.io/knowledge/reference/knw_publish.md)
  : Write a set of tables as Parquet with a manifest, and upload them

- [`knw_compare_rules()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_rules.md)
  :

  Set a tuned rule beside link's `default` on link's own segments

- [`knw_floodplain_ha()`](https://newgraphenvironment.github.io/knowledge/reference/knw_floodplain_ha.md)
  : Floodplain hectares beside each segment, from a catalog item's
  floodplain

- [`knw_compare_map()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_map.md)
  : Map a group's segments under two rules, by grade, and its floodplain
  by the grade beside it

- [`knw_compare_mapgl()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_mapgl.md)
  : The interactive map of a group's segments under two rules

## Crossings and past reports

Pull PSCIS crossing layers for a watershed group and derive the crossing
and past-report tables; check stream names before searching by name.

- [`knw_pscis_layers()`](https://newgraphenvironment.github.io/knowledge/reference/knw_pscis_layers.md)
  : Provincial PSCIS layers, by phase
- [`knw_pscis_pull()`](https://newgraphenvironment.github.io/knowledge/reference/knw_pscis_pull.md)
  : Pull PSCIS layers clipped to a watershed group
- [`knw_pscis_crossings()`](https://newgraphenvironment.github.io/knowledge/reference/knw_pscis_crossings.md)
  : Crossings table from the PSCIS assessment layer
- [`knw_pscis_reports()`](https://newgraphenvironment.github.io/knowledge/reference/knw_pscis_reports.md)
  : Past reports referenced by PSCIS records
- [`knw_gnis_collisions()`](https://newgraphenvironment.github.io/knowledge/reference/knw_gnis_collisions.md)
  : Which GNIS stream names collide across watershed groups?

## Package

- [`knowledge`](https://newgraphenvironment.github.io/knowledge/reference/knowledge-package.md)
  [`knowledge-package`](https://newgraphenvironment.github.io/knowledge/reference/knowledge-package.md)
  : knowledge: Fisheries Evidence and Tuned Habitat Thresholds for BC
  Watershed Groups
