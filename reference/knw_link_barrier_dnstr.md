# Whether a natural barrier to a species lies downstream of each point

`scripts/0296`'s access test, per species. link applies a habitat rule
behind its access gate, and the gate's observation overrides come mostly
from these same electrofishing records, so a rule scored on them must
use the barriers as they stood *before* overrides: `GRADIENT`, `FALLS`,
`SUBSURFACE_FLOW` and `USER_DEFINITE` rows of the schema's `barriers`
table that block the species (`blocks_species`), tested with
`fwa_downstream()` from the point.

## Usage

``` r
knw_link_barrier_dnstr(
  conn,
  pts,
  species,
  schema,
  natural = c("GRADIENT", "FALLS", "SUBSURFACE_FLOW", "USER_DEFINITE")
)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `schema`.

- pts:

  `data.frame` with `blue_line_key`, `downstream_route_measure`,
  `wscode` and `localcode` (ltree text). A point with no codes gets
  `NA`.

- species:

  `character` species codes, each tested on its own.

- schema:

  `character(1)` link persist schema.

- natural:

  `character` the barrier sources that count as natural.

## Value

A `tibble` of the distinct `pts` keys with one logical column
`barrier_dnstr_<sp>` per species (lower case).

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
pts <- data.frame(blue_line_key = 360886335, downstream_route_measure = 1520,
                  wscode = "400.431358.785328", localcode = "400.431358.785328.000001")
knw_link_barrier_dnstr(conn, pts, c("BT", "CH"), "fresh_default")
} # }
```
