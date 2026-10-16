# FDIS electrofishing extract (Fisheries Data Information System, British Columbia)

## Provenance

These files are extracts of the Province of British Columbia's Fisheries Data Information System (FDIS),
exported on 2020-11-16 and 2022-03-22 and supplied by the Province to New Graph Environment Ltd. for the
2021–22 channel-width and fish-density analyses with Poisson Consulting. They are published here as
received, with the Province's agreement (2026-10-16), to advance knowledge of fish–habitat relationships in
BC. No other use terms came with them.

`MANIFEST.md5` is the checksum record made when the files were moved to this bucket on 2026-09-26. It also
lists `fissr_explore.sqlite`, a working database from the 2021 exploration that is not part of the extract
and is not published.

## Contents

- `2020-11-16/`: export of 2020-11-16, produced by `queries/*.sql`. **Electrofishing only**
  (`col_meth_code = 'EF'`), and only passes with a recorded fishing-area length. Joined on `KEY` =
  `fshclctn_id_site_number_sequence_number_method_number_haul_or_pass`.
  - `visits.csv`: 62,892 passes (UTM, method, pass, in/out date and time, fishing time, fished area
    length and width, EF settings, agency)
  - `details.csv`: 326,388 individual fish (species, length, weight, age, sex, egg count, maturity, comments)
  - `counts.csv`: 114,217 species × age tallies with min/max length
  - `habitat.csv`: 26,565 site habitat rows (water temperature, conductivity, turbidity, bed material,
    gradient, channel and wetted widths)
- `2022-03-22-ef-export/`: `Details*.csv`, individual fish from electrofishing with UTM, watershed code and
  gazetted name. The 2022 files contain every 2020 fish row and add 15,219. The extraction query is not
  documented.
- `queries/`: the SQL (and PDF prints) behind the 2020 export.
- `fiss-database-structure/`: the FDIS data model (tables, columns, entity reports, relational diagrams).

## Built from it

Visit-level tables (passes rolled to site visits, placed on the FWA stream network, joined to modelled
segments) are published as Parquet under `knowledge/fdis/`, with a `manifest.json`. The bucket does not
list, so start from that manifest:
`https://fresh-bc.s3.us-west-2.amazonaws.com/knowledge/fdis/manifest.json`.

How the extract was read, its defects and what it adds over the public layers:
<https://github.com/NewGraphEnvironment/knowledge/blob/main/research/fdis_export.md>.
