# Match bcfishobs records to the FDIS site visits they came from

About half of the province's fish observation records carry
`FDIS Database: fshclctn_id <n>` in `source`: the collection id the FDIS
export keys on (issue \#23). A record is matched to a visit when the
visit's collection (the first field of `site_visit`), species and date
agree. One collection holds several sites and dates, so a record can
match several visits of one collection on the same date: those are kept,
one row per pair, and flagged `many`. A record whose collection is in
the export but whose species and date match no visit is
`collection_only`; one whose collection is not in the export is
`unmatched`; a record with no FDIS key is `not_fdis`.

## Usage

``` r
knw_bcfishobs_match(conn, visits, species, species_codes = knw_species())
```

## Arguments

- conn:

  a `DBI` connection to a database holding `bcfishobs.observations`.

- visits:

  `data.frame` with `site_visit` and `date` (`Date`), one row per visit,
  and the per-visit species table `species` below.

- species:

  `data.frame` with `site_visit` and `species_code`, one row per visit
  and species caught (any code), as `0230`'s `catch.rds` has them.

- species_codes:

  `character` the bcfishobs species to read.

## Value

A list: `matched`, a `tibble` with one row per bcfishobs record and
matched visit (`observation_key`, `fish_observation_point_id`,
`species_code`, `observation_date`, `fshclctn_id`, `site_visit`,
`match`); `summary`, counts per species and `match` class.

## Details

Codes that the export records differently from bcfishobs (DV pooled into
BT, hybrid codes) are matched as written: a bcfishobs `DV` matches a
visit's `DV`.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
sites <- readRDS("data/fdis/build/sites.rds")
catch <- readRDS("data/fdis/build/catch.rds")
knw_bcfishobs_match(conn, sites, catch, c("BT", "CH"))$summary
} # }
```
