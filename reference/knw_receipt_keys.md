# A receipt declaration knowledge ships

Each output knowledge writes a provenance receipt for (#154) declares,
as data beside its writer, what only knowledge knows about it: which
inputs, run settings and config files are its recipe, which tables are
fingerprinted and with what tolerance, which summary values it reports,
and which differences only a record. crate reads the declaration
([`crate::crt_receipt_keys()`](https://newgraphenvironment.github.io/crate/reference/crt_receipt_keys.html));
knowledge never re-implements the hashing. The declarations are
`inst/receipt/<output>.yaml`.

## Usage

``` r
knw_receipt_keys(output)
```

## Arguments

- output:

  `character(1)`: `"grade"` (a grade table,
  [`knw_grade_receipt_write()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_receipt_write.md)),
  `"evidence"` (an evidence build,
  [`knw_evidence_receipt_write()`](https://newgraphenvironment.github.io/knowledge/reference/knw_evidence_receipt_write.md),
  \#160), `"thresholds"`, `"habitat_grade"` or `"fdis"` (the published
  sets,
  [`knw_publish()`](https://newgraphenvironment.github.io/knowledge/reference/knw_publish.md)).

## Value

A `crt_receipt_keys` list, as
[`crate::crt_receipt_keys()`](https://newgraphenvironment.github.io/crate/reference/crt_receipt_keys.html)
returns.

## Examples

``` r
k <- knw_receipt_keys("grade")
k$inputs
#> [1] "link_build" "flow"       "evidence"  
k$tolerance$summary
#> $km_graded
#> [1] 0.001
#> 
#> $grade_sum
#> [1] 0.001
#> 
```
