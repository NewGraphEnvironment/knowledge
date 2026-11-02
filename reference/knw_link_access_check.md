# How link's two access columns disagree, per species

In a link `default` build, `streams_habitat_<sp>.accessible` and
`streams_access.access_<sp>` disagree (link#349; cause not established),
and rearing and spawning are set on segments `streams_access` blocks.
The evidence build gates on `streams_access`, and writes this
cross-tabulation to its ledger on every run so a change between link
runs shows.

## Usage

``` r
knw_link_access_check(conn, schema, species = knw_species(), by_group = FALSE)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `schema`.

- schema:

  `character(1)` link persist schema.

- species:

  `character` species with a habitat table and an access column in the
  schema; a species lacking either is skipped and named in `skipped`.

- by_group:

  `logical(1)`: one row per watershed group as well, so two builds of
  the same groups (link's full and minimal networks, \#120) can be set
  beside each other where their km differ.

## Value

A list: `check`, a `tibble` with one row per species and cell
(`habitat_accessible`, `access_gt0`, `n_segments`, `n_rearing`,
`n_spawning`, `km`; with `by_group`, per `watershed_group_code` too),
and `skipped`, the species not checked.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
knw_link_access_check(conn, "fresh_default", c("BT", "CH", "RB", "KO"))$check
} # }
```
