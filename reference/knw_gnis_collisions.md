# Which GNIS stream names collide across watershed groups?

GNIS names repeat across BC, so a report search by stream name drags in
reports about a same-named stream elsewhere. This reports, for each seed
name, how many watershed groups carry it. Names in one group only are
safe to search by name; the rest need a geographic qualifier and a
coordinate check on every hit.

## Usage

``` r
knw_gnis_collisions(
  conn,
  stream_names,
  wsg_code,
  table = "bcfishpass.streams",
  pattern = "River|Creek|Lake"
)
```

## Arguments

- conn:

  A `DBI` connection.

- stream_names:

  `character` seed stream names, as they appear in `gnis_name`.

- wsg_code:

  `character(1)` the watershed group being worked.

- table:

  `character(1)` a table carrying both `gnis_name` and
  `watershed_group_code`. Default `"bcfishpass.streams"`.

- pattern:

  `character(1)` regular expression a seed name must match to be
  checked; the default keeps rivers, creeks and lakes. `NULL` checks
  all.

## Value

A `tibble` with one row per seed name found: `gnis_name`, `n_wsg`,
`wsgs` (comma-joined, sorted) and `wsg_only` (`TRUE` when the name
occurs in `wsg_code` and nowhere else). Names absent from `table` are
returned in attribute `"not_found"`.

## Examples

``` r
if (requireNamespace("duckdb", quietly = TRUE)) {
con <- DBI::dbConnect(duckdb::duckdb())
DBI::dbWriteTable(con, "streams", data.frame(
  gnis_name = c("Boulder Creek", "Boulder Creek", "Wildmare Creek"),
  watershed_group_code = c("PINE", "LNTH", "PINE")))
knw_gnis_collisions(con, c("Boulder Creek", "Wildmare Creek", "Ghost Creek"),
                    "PINE", table = "streams")
DBI::dbDisconnect(con, shutdown = TRUE)
}
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpY5bzej/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
```
