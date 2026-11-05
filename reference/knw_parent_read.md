# Read link's parent table, held to the two builds it joins

link#444 writes `<schema>.streams_parent`: one row per segment of the
full network, naming the minimal-network segment it lies in (`cut-min`),
with that parent's gradient and length and how much of the full segment
lies on another minimal segment (`straddle_m`). This reads it for
[`knw_parent_join()`](https://newgraphenvironment.github.io/knowledge/reference/knw_parent_join.md)
(#120), after checking that it describes the two builds in the database
now, because a re-model of either network leaves the table behind:

- the table names one minimal build, `minimal_schema`'s, by schema and
  run (`schema_minimal`, `run_uid_minimal`);

- each group's `run_id_full` is a row of `<schema>.log` for that group
  from a run `<schema>.log_recompute` names, and each `run_id_minimal` a
  row of `<minimal_schema>.log` from the minimal build's run;

- every segment of `<schema>.streams` has exactly one parent row, and
  each row's `overlap_m + straddle_m` is its segment's length within 1
  cm.

## Usage

``` r
knw_parent_read(conn, schema, minimal_schema = NULL, keys = NULL)
```

## Arguments

- conn:

  a `DBI` connection.

- schema:

  `character(1)` the full network's persist schema, which holds
  `streams_parent`.

- minimal_schema:

  `character(1)` or `NULL`: the minimal network's schema. `NULL` takes
  the one the table names, which must be one.

- keys:

  `NULL`, or a `data.frame` with `watershed_group_code` and
  `id_segment`: read only those segments' rows (the checks still cover
  the whole table).

## Value

A `data.frame` with
[`knw_parent_join()`](https://newgraphenvironment.github.io/knowledge/reference/knw_parent_join.md)'s
columns (`id_segment`, `wsg`, `id_segment_minimal`, `gradient_minimal`,
`length_minimal`, `overlap_m`, `straddle_m`), and attribute
`provenance`: a one-row `data.frame` with `schema`, `minimal_schema`,
`run_uid_full`, `run_uid_minimal`, `link_sha_minimal`,
`config_hash_minimal`, `built_at` (the latest) and `rows` (the table's).

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
p <- knw_parent_read(conn, "fresh_default", "fresh_default_minimal",
                     keys = data.frame(watershed_group_code = "BULK", id_segment = 1:10))
attr(p, "provenance")
} # }
```
