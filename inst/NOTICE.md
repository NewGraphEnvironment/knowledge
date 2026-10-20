# NOTICE

knowledge's code is under the MIT licence (see `LICENSE`). The repository and the package also carry data from
other sources, each under its own terms. Paths are the repository's.

## Open Government Licence - British Columbia

Contains information licensed under the
[Open Government Licence - British Columbia](https://www2.gov.bc.ca/gov/content/data/policy-standards/open-data/open-government-licence-bc):
the **BC Freshwater Atlas** lakes, rivers and stream network in `inst/vignette-data/bulk_water.rds` and
`inst/vignette-data/bulk_segments.rds` (both installed with the package), and the Atlas's streams, lakes and
rivers drawn in `man/figures/readme-bulk.png` and the maps in `research/fig/`.

## Floodplains (CC BY 4.0)

The floodplain panel of the comparison maps in `research/fig/compare_*.png`, where a map has one, is drawn from
the floodplains of [stac_floodplains_bc](https://www.newgraphenvironment.com/stac_floodplains_bc/), published under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Its floodplain delineation contains information
licensed under the Open Government Licence – Canada (MRDEM-30, Natural Resources Canada) and the Open Government
Licence – British Columbia (Freshwater Atlas stream network). The maps modify them: each floodplain cell is
shaded by the grade of the stream segment that owns it.

## Fisheries Data Information System (FDIS) extract

The Province of British Columbia supplied FDIS electrofishing extracts (exported 2020-11-16 and 2022-03-22)
and agreed on 2026-10-16 to their publication with a note of when and from where they were received:
[`fdis/README.md`](https://fresh-bc.s3.us-west-2.amazonaws.com/fdis/README.md), whose source is
`data/fdis_README.md`. The tables built from those visits (`data/fdis_*.csv`, the use, tuning and comparison
tables, and `data/thresholds*.csv`) are New Graph Environment's work under this repository's licence.

## Quotes from published sources

`data/literature_evidence.csv` and `data/ip_model_registry.csv` quote short passages from the papers and reports
each row cites, so that every value can be checked against its source. The quoted text remains its authors'.

## Terms not yet settled

The terms for redistributing these files are open in
[#76](https://github.com/NewGraphEnvironment/knowledge/issues/76), and this notice does not cover them:

- **PSCIS** crossing layers, whose BC Data Catalogue licence is "Access Only": `data/<wsg>/pscis_<wsg>.gpkg`
  and the tables built from them, `data/<wsg>/crossings.csv`, `reports.csv` and `gnis_seed.csv`.
- **EcoCat fish data submissions**: `data/<wsg>/fiss_*` and the tables built from them, `data/fiss_*.csv`.
- **EcoCat report text**: the `priority_*` files, `data/priority_farmed_all.csv`, `data/rag_priorities.*`,
  `data/corpus_tags.csv`, the `context_*.md` files and `data/pine/reports_found.md`.
- **bcfishpass**: `data/pine/gnis_seed_ambiguity.csv` and `data/pine/priority_pine_enriched.csv`.
- **Modelled flows** (PCIC's, through wet) carried on the segments in `inst/vignette-data/bulk_segments.rds`.
