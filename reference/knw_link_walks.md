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
  workers = 4L,
  batch = 500L,
  cache = FALSE
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

- batch:

  `integer(1)` starts per query. On the database's host a batch of 500
  removes the round trip and R's per-row binding; over a remote link it
  removes almost all of a walk's time.

- cache:

  `FALSE` (the default: walk everything), or a table name,
  `schema.table`, to read walks from and keep them in (see above).

## Value

A `tibble`: `blue_line_key`, `downstream_route_measure`, `src`, `qmin`,
`status`, `dist_m`, `large_mad`, `large_lfid`, `large_edge`,
`large_waterbody_key`, `n_hops`, `max_entry_gap_m`, `dist_centre_m`,
`bank_m`; exactly
`nrow(unique(starts)) * length(sources) * length(q_grid)` rows. With a
cache, attribute `cache` holds the start-and-source pairs read (`hit`)
and walked (`miss`).

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
cannot be passed: it does not serialise to a worker. A worker sends one
query per `batch` starts and source (#87): the starts go to the server
as two arrays, unnested with their position and walked laterally, and
each row comes back tagged with its start's position, so the start's own
values are attached in R and no key or measure is matched by its printed
form. Every start must come back with one row per size. The result does
not depend on `batch`: each start is walked alone, as before.

With `cache` a table name, every walk is kept (#87): a walk depends only
on its start, the river size, the flow source, the flow load
([`knw_discharge_load()`](https://newgraphenvironment.github.io/knowledge/reference/knw_discharge_load.md),
by its md5) and the walk's code
([`knw_walk_md5()`](https://newgraphenvironment.github.io/knowledge/reference/knw_walk_md5.md)),
so a row keyed on all six is the walk's own for as long as those hold.
The starts go to a temporary table and the rows already kept are read
with one join per 500,000 starts; a start missing any size on a source
is walked for every size on that source (each size's result is
independent of the others), and each batch's rows are inserted by the
same query that walks them. The cache and its table of flow loads
(`<cache>_load`) are created when absent. Rows under another load or
walk are never read, and nothing prunes them. The FWA tables the walk
reads carry no load record, so a reload of
`whse_basemapping.fwa_stream_networks_sp` (fwapg#43 moves measures by
millimetres) or of the river, lake, manmade waterbody and wetland
polygons it measures the bank on needs the cache truncated by hand.

## Examples

``` r
if (FALSE) { # \dontrun{
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
knw_link_walks(pg, data.frame(blue_line_key = 360886335, downstream_route_measure = 1520),
               q_grid = c(3, 10), sources = "pick", workers = 1)
} # }
```
