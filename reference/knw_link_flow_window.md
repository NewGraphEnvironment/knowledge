# wet's flow in a seasonal window on FWA segments, on the segment MAD came from

[`knw_link_flow()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_flow.md)
reads the annual flow (MAD). This reads the mean flow over a window of
the year, such as 1 August to 30 September, so a stream can be sized by
what it carries when a life stage is in it (#226). The flow is wet's
monthly flow (`discharge.fwa_v1_segment_monthly`, scenario `historical`)
on the source wet picks for the segment, averaged over the window's days
with each day taking its month's mean
([`wet::wet_flow_window()`](https://newgraphenvironment.github.io/wet/reference/wet_flow_window.html),
the monthly basis).

## Usage

``` r
knw_link_flow_window(conn, linear_feature_id, windows)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `discharge` and
  `whse_basemapping`.

- linear_feature_id:

  `numeric` FWA segment ids.

- windows:

  `data.frame` with `start` and `end`, each `"MM-DD"`, one row per
  window. A window whose end is before its start crosses 1 January.

## Value

A `tibble`, one row per segment, ordered by `linear_feature_id`:
`linear_feature_id`, `mad_pick`, and one column per window named by its
dates, `flow_<mmdd>_<mmdd>` (m³/s).

## Details

A window is read on the segment the annual flow came from: the segment's
own, or the parent
[`knw_link_flow()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_flow.md)
falls back to. So a window flow is present exactly where `mad_pick` is,
on the same source, and `mad_pick` comes back beside it for a caller to
hold to its own. A segment read must carry months 0 to 12 once each on
one picked source, or the call stops: a window read from some of its
months, or across two sources, is not that window's flow.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
knw_link_flow_window(conn, c(701747495, 701747496), data.frame(start = "08-01", end = "09-30"))
} # }
```
