# NOTICE

knowledge's code is under the MIT licence (see `LICENSE`). The repository and the package also carry data from
other sources, each under its own terms. Paths are the repository's.

## Open Government Licence - British Columbia

Contains information licensed under the
[Open Government Licence - British Columbia](https://www2.gov.bc.ca/gov/content/data/policy-standards/open-data/open-government-licence-bc):
the **BC Freshwater Atlas** lakes, rivers and stream network in `inst/vignette-data/bulk_water.rds`,
`inst/vignette-data/bulk_segments.rds`, `inst/vignette-data/cut_points.rds`, the stream names and named
streams in `inst/vignette-data/cut_points_places.rds`, and the watershed group outline, the province drawn from the
watershed groups and the river names in `inst/vignette-data/bulk_context.rds` (all installed with the package), and the
Atlas's streams, lakes, rivers and watershed groups drawn in `man/figures/readme-bulk.png`.

## Canadian Geographical Names (Open Government Licence - Canada)

The towns named on the Bulkley maps, their names and locations in `inst/vignette-data/bulk_context.rds` and drawn in
`man/figures/readme-bulk.png`, come from Natural Resources Canada's
[Canadian Geographical Names](https://open.canada.ca/data/en/dataset/e27c6eba-3c5d-4051-9db2-082dc6411c2c), read through
its geonames service by `data-raw/vignette_context.R`. Contains information licensed under the
[Open Government Licence - Canada](https://open.canada.ca/en/open-government-licence-canada).

## BC Geographical Names

`inst/vignette-data/cut_points_places.rds` names, for each place the cut-points article describes, the nearest
incorporated city, town, village or district municipality in the Province's
[BC Geographical Names](https://catalogue.data.gov.bc.ca/dataset/bc-geographical-names), with the distance and
direction measured to it. The layer's BC Data Catalogue licence is "Access Only"; the file keeps each town's name and
nothing else from it, and `data-raw/vignette_cut_points_places.R` reads the layer from the catalogue. The streams it
names come from the Freshwater Atlas (above).

## Floodplains (CC BY 4.0)

The floodplain areas in `data/compare/floodplain.csv` are drawn from the floodplains of [stac_floodplains_bc](https://www.newgraphenvironment.com/stac_floodplains_bc/), published under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Its floodplain delineation contains information
licensed under the Open Government Licence – Canada (MRDEM-30, Natural Resources Canada) and the Open Government
Licence – British Columbia (Freshwater Atlas stream network). The areas modify them: each floodplain cell
is assigned the grade of the stream segment that owns it.

## Fisheries Data Information System (FDIS) extract

The Province of British Columbia supplied FDIS electrofishing extracts (exported 2020-11-16 and 2022-03-22)
and agreed on 2026-10-16 to their publication with a note of when and from where they were received:
[`fdis/README.md`](https://fresh-bc.s3.us-west-2.amazonaws.com/fdis/README.md), whose source is
`data/fdis_README.md`. The tables built from those visits (`data/fdis_*.csv`, the use, tuning and comparison
tables, `data/thresholds*.csv`, and the site visits in `inst/vignette-data/cut_points.rds`) are New Graph Environment's
work under this repository's licence.

## Quotes from published sources

`data/literature_evidence.csv` and `data/ip_model_registry.csv` quote short passages from the papers and reports
each row cites, so that every value can be checked against its source. The quoted text remains its authors'.

## Provincial Stream Crossing Information System (PSCIS)

`data/<wsg>/pscis_<wsg>.gpkg` and the tables built from them (`data/<wsg>/crossings.csv`, `reports.csv` and
`gnis_seed.csv`) are working copies of the Province's
[PSCIS](https://catalogue.data.gov.bc.ca/dataset/pscis-assessments) layers, clipped to a watershed group when the
report-corpus scripts ran (`scripts/0100`). They are incidental, not a distribution of PSCIS: its BC Data Catalogue
licence is "Access Only", and the current layers come from the catalogue. The package does not ship them, and
`knw_pscis_pull()` reads PSCIS from the user's own database.

## Terms not yet settled

The terms for redistributing these files are open in
[#76](https://github.com/NewGraphEnvironment/knowledge/issues/76), and this notice does not cover them:

- **EcoCat fish data submissions**: `data/<wsg>/fiss_*` and the tables built from them, `data/fiss_*.csv`.
- **EcoCat report text**: the `priority_*` files, `data/priority_farmed_all.csv`, `data/rag_priorities.*`,
  `data/corpus_tags.csv`, the `context_*.md` files and `data/pine/reports_found.md`.
- **bcfishpass**: `data/pine/gnis_seed_ambiguity.csv` and `data/pine/priority_pine_enriched.csv`.
- **Modelled flows** (PCIC's, through wet) carried on the segments in `inst/vignette-data/bulk_segments.rds`.
