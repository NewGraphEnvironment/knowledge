# Grade every segment of a species' groups by its tuned curve

Reads the species' segments
([`knw_link_segments()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_segments.md)),
walks the ones the pick's exception could admit (accessible
stream-branch segments inside the gradient maximum that fail the size
test) to the first river of the pick's `exc_q` from the segment's
downstream end, and grades them all
([`knw_grade()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade.md)).
Segments the exception cannot reach take the distance cap: a segment
passing the size test is graded on its size, and one off the stream
branch or above the gradient maximum is far from any river by
construction, which the curve reads as the exception not helping it.
With no exception on the pick, no walk is made.

## Usage

``` r
knw_grade_species(
  connector,
  schema,
  species,
  wsg,
  curve,
  pick,
  stage = "rear",
  edge_stream = c(1000L, 1100L, 2000L, 2300L),
  workers = 4L,
  src = "pick"
)
```

## Arguments

- connector:

  a function returning a `DBI` connection (each walk worker opens its
  own).

- schema:

  `character(1)` link persist schema.

- species:

  `character(1)` species code.

- wsg:

  `character` the species' groups.

- curve:

  [`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md)'s
  result for the species and stage.

- pick:

  the recommended rule row.

- stage:

  `"rear"` or `"spawn"`.

- edge_stream:

  `integer` stream-branch edge types.

- workers:

  `integer(1)` walk workers.

- src:

  `character(1)` the flow source.

## Value

A list: `grades`, one row per segment with the segment's keys,
`length_metre`, `access`, `accessible`, the stage's flag, `size`,
`dist_m`, `rate`, `grade`, `grade_class`; `reference`; `counts`
(segments, walked, found, graded, no size, no gradient); `walk_minutes`.

## Examples

``` r
if (FALSE) { # \dontrun{
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
g <- knw_grade_species(pg, "fresh_default", "CH", c("BULK", "MORR"), out$CH_rear$curve, out$CH_rear$pick)
} # }
```
