# Carry each visit's minimal-network parent onto its full-network segment

link deploys a rule on its full network, whose segments are cut at fish
records, crossings and habitat end points as well as at barriers and
access gradients; its minimal network (`default_minimal`, link#415) is
cut at the last two alone. A rule tuned on the minimal network transfers
to the full one when each full segment carries its minimal parent's
gradient (link#444). This joins that parent to the visits placed on the
full network, so the tuning can read the parent's gradient there
(`GRADIENT=parent_gradient` in `scripts/0320`, \#120).

## Usage

``` r
knw_parent_join(visits, parent)
```

## Arguments

- visits:

  `data.frame` of placed visits with `site_visit`,
  `watershed_group_code`, `id_segment` and `segment_length_m` (the full
  network's segment, as
  [`knw_link_place()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_place.md)
  returns it).

- parent:

  `data.frame` with one row per full segment: `id_segment`, `wsg`,
  `id_segment_minimal`, `gradient_minimal`, `length_minimal`,
  `overlap_m` and `straddle_m`, as link's
  `data-raw/logs/minimal_breaks_415/parent_<wsg>.csv.gz` holds them.

## Value

`visits` with `parent_id_segment`, `parent_gradient`, `parent_length_m`
and `parent_straddle_m`, in the same rows and order.

## Details

A full segment's parent is the minimal segment it overlaps most, and
every visit on the full segment takes that parent's gradient. Where a
full segment straddles a minimal break, `straddle_m` is the length that
lies on another minimal segment: a visit on that stretch sits on the
other segment on the minimal network, so there the two setups read
different gradients. A placed visit whose segment has no parent row is
an error. link numbers each group's segments from 1, so a parent table
of another build covers the same ids: each visit's segment must be as
long as its parent row's `overlap_m + straddle_m` (within 1 cm; a
missing length fails), or the join stops as another network's table.

## Examples

``` r
v <- data.frame(site_visit = c("a", "b"), watershed_group_code = "BULK", id_segment = c(10, 11),
                segment_length_m = c(120, 315))
p <- data.frame(id_segment = c(10, 11, 12), wsg = "BULK", id_segment_minimal = c(4, 4, 5),
                gradient_minimal = c(0.012, 0.012, 0.031), length_minimal = c(900, 900, 400),
                overlap_m = c(120, 300, 400), straddle_m = c(0, 15, 0))
knw_parent_join(v, p)
#>   site_visit watershed_group_code id_segment segment_length_m parent_id_segment
#> 1          a                 BULK         10              120                 4
#> 2          b                 BULK         11              315                 4
#>   parent_gradient parent_length_m parent_straddle_m
#> 1           0.012             900                 0
#> 2           0.012             900                15
```
