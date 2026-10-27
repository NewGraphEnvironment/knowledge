# The flow load the database serves, by its table comment

wet can reload `discharge.fwa_v1_segment_monthly` between two runs
(NewGraphEnvironment/wet#103 did on 2026-10-19), and the table's comment
names the build. A grade records it, a publish compares it, and the walk
cache keys every row on its md5 (#72, \#87). Refuses a table with no
comment.

## Usage

``` r
knw_discharge_load(conn)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `discharge`.

## Value

`character(1)`, the comment.

## Details

wet writes one comment per table, naming only the scenario loaded last,
and the walk and the grade read only `historical`. Once another scenario
is loaded, the comment no longer names the historical rows' build, so
two different historical loads could share it and the walk cache would
serve walks made on the older one. So this refuses a comment that does
not name `scenario historical`.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
knw_discharge_load(conn)
} # }
```
