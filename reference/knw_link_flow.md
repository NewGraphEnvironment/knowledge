# wet's annual flow on FWA segments, with a parent fallback

`scripts/0294`'s flow read, for any set of FWA segments. The flow is
month 0 (the annual mean) of `discharge.fwa_v1_segment_monthly`,
scenario `historical`, as `wet::wet_db_load()` loaded it: `pick` marks
wet's default source per segment, and both sources' values come back
beside it. A segment with no picked flow, or with no watershed code
(side channels and connectors with no watershed lut row), is not
dropped: it takes the picked flow of the nearest primary-flow segment on
its main line (`watershed_key`) or its own line, and `flow_from` says
which (`own`, `parent`, or `NA` for neither); such a segment takes that
segment's watershed codes too (`code_from_parent`). Where two such
segments are equally near, the one with the lower `linear_feature_id`
gives the flow: an arbitrary but fixed choice, so every database holding
the build takes the same one (#161).

## Usage

``` r
knw_link_flow(conn, linear_feature_id)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `discharge` and
  `whse_basemapping`.

- linear_feature_id:

  `numeric` FWA segment ids.

## Value

A `tibble`, one row per segment: `linear_feature_id`, `side_channel`,
`fwa_gradient`, `wscode`, `localcode`, `code_from_parent`,
`waterbody_key`, `mad_pick`, `pick_source`, `mad_routed`, `mad_balance`,
`flow_from`, `parent_dist_m`.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
knw_link_flow(conn, c(701747495, 701747496))
} # }
```
