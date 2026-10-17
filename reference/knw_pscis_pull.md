# Pull PSCIS layers clipped to a watershed group

Each layer is intersected with
`whse_basemapping.fwa_watershed_groups_poly` in the database, because
the raw PSCIS layers carry no watershed group code. Layers with no rows
in the group are dropped from the result, since an empty `st_read()`
carries no CRS.

## Usage

``` r
knw_pscis_pull(conn, wsg_code, layers = knw_pscis_layers())
```

## Arguments

- conn:

  A `DBI` connection to a database holding the PSCIS layers and the FWA
  watershed-group polygons (PostGIS).

- wsg_code:

  `character(1)` watershed group code, e.g. `"PINE"`.

- layers:

  Named `character` of `schema.table` layers; see
  [`knw_pscis_layers()`](https://newgraphenvironment.github.io/knowledge/reference/knw_pscis_layers.md).

## Value

A named `list` of `sf` objects, one per non-empty layer, each with a
`pscis_layer` column naming the phase.

## Examples

``` r
if (FALSE) { # \dontrun{
# connection details from the standard PGHOST, PGPORT, PGDATABASE, PGUSER
# and PGPASSWORD environment variables
conn <- DBI::dbConnect(RPostgres::Postgres())
layers <- knw_pscis_pull(conn, "PINE")
} # }
```
