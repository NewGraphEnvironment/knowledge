# The database build a run reads, and the check that it is the evidence's

A grade or a comparison reads four things from the database besides the
FWA tables: link's persist schema, the run that built it
(`<schema>.log_recompute`'s `run_uid`), wet's flow load (the table
comment,
[`knw_discharge_load()`](https://newgraphenvironment.github.io/knowledge/reference/knw_discharge_load.md))
and the walk installed from this package
([`knw_walk_md5()`](https://newgraphenvironment.github.io/knowledge/reference/knw_walk_md5.md));
fresh's version decides the comparison's regeneration. `0320` and `0330`
read this record at connect and refuse a schema whose run is not the
evidence ledger's, before any work, so the same command runs on any
machine whose database holds the build and stops on one that does not
(#87). A provincial run in link renames `fresh_default` and builds a new
one in its place (link#361), which is the case the check catches.

## Usage

``` r
knw_build_record(conn, schema, run_uid = NULL)
```

## Arguments

- conn:

  a `DBI` connection.

- schema:

  `character(1)` link's persist schema.

- run_uid:

  `character(1)` or `NULL`: the run the evidence was built on (the
  ledger's `link_run_uid`). Given, a schema built by another run, or by
  several, is refused.

## Value

A list: `schema`, `run_uid` (the schema's runs, `;`-joined),
`discharge_load`, `walk_md5`, `fresh_version`, `tokens` (link's output
vocabulary, `c(cut =, acc =, grad =, flow =)`, read from every row of
`<schema>.log`, where link writes them; each `NA` where that log
predates link 0.70.0 and carries none), and `line`, the record as one
line for a log. A schema whose log holds two values on one axis, or rows
with a token beside rows without one, is refused: it is not one build.
The tokens are read over every `log` row, not keyed on the run, because
a build's `log` and its recompute's `log_recompute` can carry different
run ids.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
knw_build_record(conn, "fresh_default_20261017", run_uid = "20261017_004619-3f4c713b")$line
} # }
```
