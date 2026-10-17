# Provincial PSCIS layers, by phase

The four PSCIS "spatial view" layers, named by the phase of work each
records. Each carries an `ecocat_url` pointing at the report that
documents the work.

## Usage

``` r
knw_pscis_layers()
```

## Value

A named `character` vector of `schema.table` names.

## Examples

``` r
knw_pscis_layers()
#>                                 assessment 
#>           "whse_fish.pscis_assessment_svw" 
#>                               confirmation 
#> "whse_fish.pscis_habitat_confirmation_svw" 
#>                                     design 
#>      "whse_fish.pscis_design_proposal_svw" 
#>                                remediation 
#>          "whse_fish.pscis_remediation_svw" 
```
