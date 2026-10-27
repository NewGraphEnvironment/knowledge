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
  seed_boot = 542L,
  structures = NULL,
  tuned_as = "door",
  config_sha = NA_character_
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

  `character(1)` a directory holding link's `configs/default` files:
  `parameters_habitat_thresholds.csv`, `rules.yaml`,
  `parameters_fresh.csv`, `overrides/user_habitat_classification.csv`,
  and, read when present, `parameters_habitat_method.csv` and
  `dimensions.csv`.

- grades:

  the species × stage grade table
  [`knw_grade_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_species.md)
  wrote (`id_segment`, `watershed_group_code`, `size`, `dist_m`,
  `grade`, `grade_class`, and `target_in_group` when the table carries
  it), for the MAD with parent fallback, the exception distance and the
  graded km.

- visits, visit_species:

  the build's `visits_link` and `visits_species` tables, for the FDIS
  detection check (`NULL` to skip).

- scratch:

  `character(1)` the scratch schema (dropped at the end).

- n_boot, seed_boot:

  the bcfishobs lift's bootstrap.

- structures:

  `NULL` (chosen as above) or a subset of
  `c("free", "door", "door_wetland")`.

- tuned_as:

  `character(1)` the structure reported as `tuned`.

- config_sha:

  `character(1)` the link commit `link_dir` was read at, carried on
  every output row (`NA` when unknown).

## Value

A list of `tibble`s: `compare` (per structure, group and total: km by
rule, graded km, km by grade class, gained and lost, and the km gained
by an exception whose river lies in another watershed group), `change`
(km gained and lost by structure, reason and stream order), `checks`
(FDIS detection on each rule's segments and the bcfishobs lift, per
structure), `segments` (the per-segment flags under `default` and each
structure, with `tuned` the `tuned_as` structure, and the `default`
branch each segment lies on), and `log` lines.

## Details

`default`'s predicate is
[`fresh::frs_habitat_predicates()`](https://newgraphenvironment.github.io/fresh/reference/frs_habitat_predicates.html)
on the `configs/default` in `link_dir`, under each group's size model
(`parameters_habitat_method.csv`; `cw` where a group is not listed).
Since link 0.67.0 a rule can carry a near-river pair (a river of at
least some size within some distance downstream, fresh#263), so where
the species' rules resolve to one, the pairs are walked on the scratch
copy with
[`fresh::frs_near_river()`](https://newgraphenvironment.github.io/fresh/reference/frs_near_river.html)
first, exactly as `frs_habitat_classify()` walks them, and the predicate
reads that table.

A tuned rule is the same predicate with its gradient maximum and, under
a width rule, its width floor substituted, and with two branches
replaced by the rule's own tests, in one of three **structures** (#73,
link#364):

- on the **stream branch** (a stream edge in no river polygon, wetland
  of at least 1 ha or lake of at least 100 ha), a segment is in when its
  gradient is inside the maximum and either the size test holds (width,
  or MAD at least the floor) or the exception does: a river of the
  rule's `exc_q` lies within `exc_d` m downstream (`dist_m`, walked from
  the segment's downstream end to the river's bank by
  [`knw_grade_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_species.md)),
  on a segment with a local watershed code, the only segments link's own
  walk measures;

- on **through-wetland lines** (FWA edge types 1050 and 1150) the
  structures differ: `free` keeps the free pass link's `default` gave
  them before 0.67.0 (in, with no test, inside a wetland of at least 1
  ha); `door` puts them through the stream branch's door, size or
  exception (link's `rear_near_river = both`); `door_wetland` puts them
  through the door with the exception while the stream branch keeps the
  size test alone (link's `wetland_flow`, `default`'s choice for
  chinook). The river, wetland-polygon and lake branches stay fresh's. A
  species whose `default` has no through-wetland rule (grayling) is
  compared under `door` alone, with those lines out as `default` has
  them; one whose tuned rule carries no exception under `free` and
  `door`, since `door_wetland` would equal `door`; otherwise under all
  three. The structure named `tuned_as` is also reported as `tuned`, the
  name the maps and the article read. When a tuned rule under `door`
  equals `default` and `default` resolves no pair, the injected form
  must equal fresh's own predicate on every segment, which the call
  asserts.

## Examples

``` r
if (FALSE) { # \dontrun{
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
cmp <- knw_compare_rules(pg, "fresh_default", "CH", "rear", pick, c("BULK", "MORR"),
                         link_dir, grades)
cmp$compare[cmp$compare$watershed_group_code == "ALL", ]
} # }
```
