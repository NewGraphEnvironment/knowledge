# Grade every segment of a species' groups by its tuned curve

Reads the species' segments
([`knw_link_segments()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_segments.md)),
walks every accessible segment with a gradient (on any edge type and at
any gradient: wetland lines, river polygons and steep segments included,
and whatever its size) from its downstream end to the first river of the
pick's `exc_q`, or of the curve's `q` when the pick has no exception,
and grades them all
([`knw_grade()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade.md)).
The curve reads size and distance jointly, so every graded segment needs
its own distance, whether or not it passes the size test. For the pick
the curve was fitted on, the two rivers are the same.

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
  workers = 4L,
  src = "pick",
  ref_edge = NULL,
  cache = "knw.walk_cache"
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
  result for the species and stage. It must have been fitted on link's
  segment gradient (`curve$cols[["grad"]]` is `segment_gradient`), the
  gradient the segments are graded on (#92).

- pick:

  the recommended rule row.

- stage:

  `"rear"` or `"spawn"`.

- workers:

  `integer(1)` walk workers.

- src:

  `character(1)` the flow source.

- ref_edge:

  `integer` or `NULL` (the default): the stream-branch edge types the
  reference rate is taken over. `NULL` takes the curve's own
  `edge_stream`, the edge types of the visits it was fitted on (#72),
  and a curve that carries none takes
  [`knw_tune_run()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_run.md)'s
  default `edge_stream`.

- cache:

  the walk cache
  [`knw_link_walks()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_walks.md)
  reads and keeps walks in (`"knw.walk_cache"`), or `FALSE` to walk
  every start.

## Value

A list: `grades`, one row per segment with the segment's keys,
`length_metre`, `access`, `accessible`, the stage's flag, `size`,
`dist_m`, `dist_status`, `target_in_group` (`TRUE` where the river the
walk found lies in the segment's own watershed group, `FALSE` where it
lies in another, which link's walk, one group's table at a time, cannot
see; `NA` where no river was found), `rate`, `grade`, `grade_class`;
`reference`; `ref_edge`, the edge types the reference was taken over;
`q`, the river size walked to; `walk`, the walk's convention (`"bank"`:
the distance ends at the river's bank, \#73); `walk_md5`, the walk's
code
([`knw_walk_md5()`](https://newgraphenvironment.github.io/knowledge/reference/knw_walk_md5.md),
\#87); `counts` (segments, accessible, walked starts, starts read from
the walk cache and walked, segments whose walk was found, none or other,
graded, no size, no gradient); `walk_minutes`.

## Details

`dist_m` also serves
[`knw_compare_rules()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_rules.md)
as the exception's distance. That is why a segment with no size is
walked although it is not graded (the exception admits a segment whose
size fails, missing included), and why a pick's own `exc_q` wins: a
candidate whose river differs from the curve's gets a correct exception
and a grade that is not comparable.

The curve was fitted on stream-branch visits outside lakes, wetlands and
river polygons, so a grade off that branch is an extrapolation: a
river-polygon segment often reads the curve near 0 m (about half of
their km within 1 m for grayling, four fifths for chinook) and at sizes
few visits had, and a wetland or lake segment lies outside the visits it
was fitted on. The reference rate that reads 1 is therefore taken over
the stream branch alone (`ref_edge`; Al, 2026-10-19): over every
accessible segment, river-polygon segments make up most of the top 5 %
for chinook, coho, steelhead and cutthroat, whose reference rises 1.4 to
4 times (chinook's from 0.14 to 0.52); for bull trout, grayling and
rainbow the two references are within 7 %.

A walk that finds no river of `q` (`none`: the sea first; `no_parent`;
`too_many_hops`) leaves `dist_m` missing, which the grade reads as the
distance cap, as
[`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md)
censors such visits. `dist_status` says which, and is `no_walk` for a
segment outside the walk set (not accessible, or with no gradient).

## Examples

``` r
if (FALSE) { # \dontrun{
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
g <- knw_grade_species(pg, "fresh_default", "CH", c("BULK", "MORR"),
                       out$CH_rear$curve, out$CH_rear$pick)
} # }
```
