# NOTICE

knowledge's code is under the MIT licence (see [`LICENSE`](LICENSE)). The repository also carries data from
other sources, each under its own terms.

## Open Government Licence - British Columbia

Contains information licensed under the
[Open Government Licence - British Columbia](https://www2.gov.bc.ca/gov/content/data/policy-standards/open-data/open-government-licence-bc):

- **BC Freshwater Atlas** lakes, rivers and stream network: `inst/vignette-data/bulk_water.rds` and the
  segment geometry in `inst/vignette-data/bulk_segments.rds`.

## Fisheries Data Information System (FDIS) extract

The Province of British Columbia supplied FDIS electrofishing extracts (exported 2020-11-16 and 2022-03-22)
and agreed on 2026-10-16 to their publication with a note of when and from where they were received:
[`fdis/README.md`](https://fresh-bc.s3.us-west-2.amazonaws.com/fdis/README.md), whose source is
[`data/fdis_README.md`](data/fdis_README.md). The tables under `data/` built from those visits (`data/fdis_*`,
the use, tuning and comparison tables, and `data/thresholds*.csv`) are New Graph Environment's work under
this repository's licence.

## Quotes from published sources

`data/literature_evidence.csv` and `data/ip_model_registry.csv` quote short passages from the papers and reports
each row cites, so that every value can be checked against its source. The quoted text remains its authors'.

## Terms not yet settled

The terms for redistributing these files are open in
[#76](https://github.com/NewGraphEnvironment/knowledge/issues/76), and they are not covered by this notice:

- **PSCIS** crossing layers, whose BC Data Catalogue licence is "Access Only": `data/<wsg>/pscis_<wsg>.gpkg`
  and the tables derived from them (`crossings.csv`, `reports.csv`, `gnis_<wsg>.csv`).
- **EcoCat** fish data submissions and report tables: `data/<wsg>/fiss_sites_*`, `data/<wsg>/fiss_step*`,
  `data/<wsg>/fiss_xls_reports.csv`, the `priority_*` files, `data/priority_farmed_all.csv` and
  `data/rag_priorities.*`.
