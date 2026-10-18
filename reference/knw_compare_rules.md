# Set a tuned rule beside link's `default` on link's own segments

`scripts/0298`'s comparison for any species and stage. Each rule goes
through the three stages that make link's stored flags, on scratch
copies of each group: the predicate gated by access (the habitat table's
`accessible` and `streams_access.access_<sp> > 0` together, the one gate
[`knw_link_place()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_place.md),
[`knw_link_segments()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_segments.md)
and the grades use; the km the gate removes from the habitat table's
`accessible` is reported as `access_gate_differ_km`),
[`fresh::frs_habitat_overlay()`](https://newgraphenvironment.github.io/fresh/reference/frs_habitat_overlay.html)
with link's user-habitat rows for the species, and fresh's connectivity
pass (`.frs_run_connectivity()` with link's `default` parameters),
rearing and spawning together, because the connectivity pass reads
spawning. Regenerated `default` is reported against the stored flags,
never compared to them.

## Usage

``` r
knw_compare_rules(
  connector,
  schema,
  species,
  stage,
  tuned,
  groups,
  link_dir,
  grades,
  visits = NULL,
  visit_species = NULL,
  scratch = "knw_compare_scratch",
  n_boot = 200L,
  seed_boot = 542L
)
```

## Arguments

- connector:

  a function returning a `DBI` connection.

- schema:

  `character(1)` link persist schema.

- species:

  `character(1)` species code.

- stage:

  `"rear"` or `"spawn"`: the stage the tuned rule changes.

- tuned:

  one row of the scored grid (the recommended rule).

- groups:

  `character` watershed groups to compare.

- link_dir:

  `character(1)` a directory holding link's `configs/default` files at
  the run's commit: `parameters_habitat_thresholds.csv`, `rules.yaml`,
  `parameters_fresh.csv`, `overrides/user_habitat_classification.csv`.

- grades:

  the species × stage grade table
  [`knw_grade_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_species.md)
  wrote (`id_segment`, `watershed_group_code`, `size`, `dist_m`,
  `grade`, `grade_class`), for the MAD with parent fallback, the
  exception distance and the graded km.

- visits, visit_species:

  the build's `visits_link` and `visits_species` tables, for the FDIS
  detection check (`NULL` to skip).

- scratch:

  `character(1)` the scratch schema (dropped at the end).

- n_boot, seed_boot:

  the bcfishobs lift's bootstrap.

## Value

A list of `tibble`s: `compare` (per group and total: km by rule, graded
km, km by grade class, gained and lost), `change` (km gained and lost by
reason and stream order), `checks` (FDIS detection on each rule's
segments and the bcfishobs lift), `segments` (the per-segment flags
under each rule, for maps), and `log` lines.

## Details

`default`'s predicate is
[`fresh::frs_habitat_predicates()`](https://newgraphenvironment.github.io/fresh/reference/frs_habitat_predicates.html)
on link's `configs/default`. A tuned rule is the same predicate with its
gradient maximum and, under a width rule, its width floor substituted,
and with the stream branch's size test replaced: a stream-branch segment
(a stream edge in no river polygon, wetland of at least 1 ha or lake of
at least 100 ha) is in when its gradient is inside the maximum and
either the size test holds (width, or MAD at least the floor) or a river
of the rule's `exc_q` lies within `exc_d` m downstream (`dist_m`, walked
from the segment's downstream end by
[`knw_grade_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_species.md)).
The river, wetland and lake branches stay fresh's. When a tuned rule
equals `default` the injected form must equal fresh's own predicate on
every segment, which the call asserts.

## Examples

``` r
if (FALSE) { # \dontrun{
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
cmp <- knw_compare_rules(pg, "fresh_default", "CH", "rear", pick, c("BULK", "MORR"),
                         link_dir, grades)
cmp$compare
} # }
```
