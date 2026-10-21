# The published thresholds table, from a tuning run's outputs

One row per species × stage × component of the joint pick, in the
columns link's calibration reads (link#346): `rule_id` ties the
components of one rule; `link_parameter` is the column of link's
`parameters_habitat_thresholds.csv` the value fills, where one exists
(the near-a-river exception has none in link and is `NA`); `model` says
whether the size test is a width (`cw`) or a MAD (`mad`) floor;
`range_lo` and `range_hi` are the smallest and largest value of the
component among the rules inside the one-SE region on the main reading;
`readings_in` is the number of fold seeds (the main one and the extra
seeds) in whose region the recommended rule sits, of `readings`;
`rule_196` is the rule the same pick makes from a region 1.96 standard
errors wide
([`knw_tune_repick()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_repick.md)),
and `holds_196` is `TRUE` where that rule keeps the row's value (a size
row also needs the same size variable; a component the recommended rule
lacks holds when the 1.96 rule lacks it too). A species × stage that was
not fitted (no stream rule, no response, too few groups) gets one row
per stage with `status` saying why and no values.

## Usage

``` r
knw_thresholds_table(
  tune_dir,
  evidence_version,
  link_run_uid,
  link_sha,
  config = "default",
  d_floor = 200
)
```

## Arguments

- tune_dir:

  `character(1)` the directory `scripts/0320` wrote (one
  `<sp>_<stage>_summary.csv` per species × stage, bound here).

- evidence_version, link_run_uid, link_sha, config:

  `character(1)` the provenance every row carries.

- d_floor:

  `numeric(1)` the run's shortest exception distance (m), as given to
  [`knw_tune_run()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_run.md),
  so the 1.96 replay picks as the run did.

## Value

A list: `thresholds` and `groups` (one row per `rule_id` and watershed
group the rule was scored on), both `tibble`s.

## Examples

``` r
if (FALSE) { # \dontrun{
t <- knw_thresholds_table("data/tune", "knowledge/fdis/v3", "20261017_004619-3f4c713b", "a17e9177", "default")
t$thresholds
} # }
```
