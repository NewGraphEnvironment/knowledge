# The database's round trip, and the check that a database-bound run is on its host

A grade, a comparison and the visit walks are bound by the database, so
`CLAUDE.md` runs them on the database's own host. `knw_db_latency()`
measures the connection: the median wall time of `n` `SELECT 1` queries
through
[`DBI::dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html),
with no warm-up, which is the path the host's 1.6 ms and a remote link's
104 to 110 ms were measured on (2026-10-24, 2026-10-26).
`knw_db_latency_check()` measures it and, over `limit_ms`, stops with
the round trip and what a remote link cost \#92's comparison, unless
`remote` is `TRUE`. `0310`, `0320` and `0330` call it at connect, before
any work, and set `remote` from `REMOTE=TRUE`; each logs the returned
`line`.

## Usage

``` r
knw_db_latency(conn, n = 20)

knw_db_latency_check(conn, remote = FALSE, limit_ms = 20, n = 20)
```

## Arguments

- conn:

  a `DBI` connection.

- n:

  `integer(1)` how many queries to time.

- remote:

  `logical(1)`: run over the limit anyway, and say so in `line`.

- limit_ms:

  `numeric(1)` the round trip, in ms, above which the connection is
  taken to be off the host.

## Value

`knw_db_latency()`: the median round trip in ms.
`knw_db_latency_check()`: a list of `ms`, `limit_ms`, `remote`, `over`
(the round trip is above the limit) and `line`, the measurement as one
line for a log.

## Details

What the remote link cost \#92's `0330` (every key; the host on
2026-10-26, the remote link on 2026-10-27, so the ratios are
approximate):

|                               |         |             |
|-------------------------------|---------|-------------|
| part of `0330`                | host    | remote link |
| classify, overlay and connect | 115 min | 164 min     |
| the rest of the comparison    | 48 min  | 105 min     |
| GeoPackages                   | 14 min  | 197 min     |

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
knw_db_latency(conn)
knw_db_latency_check(conn)$line
} # }
```
