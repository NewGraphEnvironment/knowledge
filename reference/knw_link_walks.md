# Network distance downstream to the first river of each size, on each flow source

`scripts/0296`'s walks. From a point on an FWA blue line, the path is
walked downstream on route measures (`inst/sql/ch_dist_profile.sql`, the
walk `scripts/0294` fixed for one river size, for an array of sizes) to
the first primary-flow segment whose annual flow on `src` is at least
each `q` in `q_grid`. One row per start, source and size: `status` is
`found`, `none` (the sea first), `no_parent` or `too_many_hops`. Side
channels, connectors and other secondary-flow edges are passed over; a
lake segment counts, as it would in a link rule.

## Usage

``` r
knw_link_walks(
  connector,
  starts,
  q_grid = c(1, 3, 5, 10, 20, 30, 50),
  sources = c("pick", "pcic_routed", "wet_balance"),
  workers = 4L
)
```

## Arguments

- connector:

  a function of no arguments returning a `DBI` connection to a database
  holding `discharge` and `whse_basemapping`.

- starts:

  `data.frame` with `blue_line_key` and `downstream_route_measure`.

- q_grid:

  `numeric` river sizes (m³/s), walked to in one pass.

- sources:

  `character` flow sources: `pick` (wet's default per segment),
  `pcic_routed`, `wet_balance`.

- workers:

  `integer(1)` socket workers.

## Value

A `tibble`: `blue_line_key`, `downstream_route_measure`, `src`, `qmin`,
`status`, `dist_m`, `large_mad`, `large_lfid`, `large_edge`,
`large_waterbody_key`, `n_hops`, `max_entry_gap_m`, `dist_centre_m`,
`bank_m`; exactly
`nrow(unique(starts)) * length(sources) * length(q_grid)` rows.

## Details

The distance ends at the river's bank, by the rule fresh's
`frs_near_river()` applies (#73): where the river found lies in a
waterbody polygon, the connector segments (FWA edge types 1400 and 1450)
the walk passed inside that polygon and the part of each hop's jump that
crosses it are left out, and a connector inside a polygon the walk only
passes through stays in. `dist_centre_m` is the distance to the
centreline and `bank_m` what the rule took off it, so
`dist_m = pmax(dist_centre_m - bank_m, 0)`. What remains different from
fresh's walk: this one starts where it is told (a visit's own point; the
grade starts it at a segment's downstream end), crosses watershed-group
outlets, and walks a line with no local code.

Each socket worker opens its own connection through `connector` and
installs the walk as a session-temporary function, so a `DBI` connection
cannot be passed: it does not serialise to a worker.

## Examples

``` r
if (FALSE) { # \dontrun{
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
knw_link_walks(pg, data.frame(blue_line_key = 360886335, downstream_route_measure = 1520),
               q_grid = c(3, 10), sources = "pick", workers = 1)
} # }
```
