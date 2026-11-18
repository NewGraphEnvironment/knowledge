# Fetch a release of DFO's NuSEDS All Areas file

NuSEDS (Fisheries and Oceans Canada's New Salmon Escapement Database
System) is published on the Open Government Portal as
`All Areas NuSEDS_<YYYYMMDD>.zip`, one CSV of every salmon population,
stream, species and year, under the Open Government Licence - Canada.
This finds the release through the portal's CKAN API (`ckanr`),
downloads it once to `<dir>/<YYYYMMDD>/`, and returns where it is with
its md5.

## Usage

``` r
knw_nuseds_fetch(
  dir = "data/nuseds",
  release = NULL,
  dataset = "c48669a3-045b-400d-b730-48aafe8c5ee6",
  url = "https://open.canada.ca/data/en"
)
```

## Arguments

- dir:

  `character(1)` the directory releases are kept under.

- release:

  `character(1)` a release date as `YYYYMMDD`, or `NULL` for the newest
  the record lists.

- dataset:

  `character(1)` the portal's dataset id for NuSEDS.

- url:

  `character(1)` the CKAN site.

## Value

A list: `path` (the zip), `release` (`YYYYMMDD`), `md5`, `url` (where it
came from) and `fetched` (when, UTC), both kept in `source.dcf` beside
the zip when it was downloaded and read back from there when it is held
(`NA` for a zip that has none), and `downloaded` (`TRUE` when this call
fetched it).

## Details

A release already held is never downloaded again or overwritten: a later
release is a new directory, so a run names the input it read. Asked for
the latest, the function takes the newest release the record lists. The
download is refused unless it is a zip holding exactly one CSV, the
shape
[`knw_nuseds_records()`](https://newgraphenvironment.github.io/knowledge/reference/knw_nuseds_records.md)
reads through crate.

## Examples

``` r
if (FALSE) { # \dontrun{
x <- knw_nuseds_fetch()
x$release
} # }
```
