# link's segments for one species in a set of groups, with flow and access, for grading

The segment table a grade is written on: every `streams` row of the
groups, with `streams_access.access_<sp>`, the species' habitat flags
(re-gated on access, stored flags beside), and wet's picked annual flow.
Own flow is one join; the parent fallback
[`knw_link_flow()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_flow.md)
applies per visit (the nearest primary-flow segment on the main line or
the segment's own line) runs only on the segments with no own flow, so
millions of segments read in one pass.

## Usage

``` r
knw_link_segments(conn, schema, species, wsg, parent_fallback = TRUE)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `schema` and `discharge`.

- schema:

  `character(1)` link persist schema.

- species:

  `character(1)` species code.

- wsg:

  `character` watershed group codes.

- parent_fallback:

  `logical(1)` run the parent fallback for segments with no own picked
  flow.

## Value

A `tibble`, one row per segment: `id_segment`, `watershed_group_code`,
`linear_feature_id`, `blue_line_key`, `downstream_route_measure`,
`upstream_route_measure`, `length_metre`, `edge_type`, `stream_order`,
`waterbody_key`, `gradient`, `channel_width`, `channel_width_source`,
`wscode`, `localcode`, `access`, `accessible`, `spawning`, `rearing`,
`lake_rearing`, `wetland_rearing` (re-gated), `*_stored`, `mad_pick`,
`pick_source`, `flow_from`.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
seg <- knw_link_segments(conn, "fresh_default", "CH", c("BULK", "MORR"))
} # }
```
