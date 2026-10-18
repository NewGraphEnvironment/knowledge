# Points on the FWA network downstream of a regulating dam

`scripts/0294`'s regulated-reach test. A CABD dam with a reservoir, or a
degree of regulation of `regulation_min` percent or more, is placed on
the nearest main-flow FWA segment within `dam_snap_m`; a point is
regulated when such a dam lies upstream of it (`fwa_downstream()` with
the roles swapped). wet's flow is natural flow, so on a regulated river
it is not the flow the fish meet.

## Usage

``` r
knw_link_regulated(conn, pts, dam_snap_m = 500, regulation_min = 10)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `cabd` and
  `whse_basemapping`.

- pts:

  `data.frame` with `blue_line_key`, `downstream_route_measure`,
  `wscode` and `localcode` (ltree text, as
  [`knw_link_flow()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_flow.md)
  returns them).

- dam_snap_m:

  `numeric(1)` how far a dam may sit from the segment it is placed on.

- regulation_min:

  `numeric(1)` percent degree of regulation at or above which a dam
  without a reservoir counts.

## Value

A list: `regulated`, a `tibble` of the distinct `pts` keys with a
logical `regulated`; `dams`, the dams placed (`cabd_id`, `dam_name_en`,
`degree_of_regulation_pc`, `reservoir_present`, position, `snap_m`).

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
f <- knw_link_flow(conn, 701747495)
knw_link_regulated(conn, data.frame(blue_line_key = 360886335, downstream_route_measure = 100,
                                    wscode = f$wscode, localcode = f$localcode))
} # }
```
