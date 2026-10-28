# The evidence ledger a set of tuning tables was scored on

`scripts/0310` writes one ledger per evidence build into
`scripts/logs/habitat/`, so a build checked but not promoted (#111)
leaves a newer ledger than the published tables'. Since \#111 each
summary names the ledger its run read (`evidence_ledger`); this returns
it, so `scripts/0325`, `scripts/0330` and the methodology bundle read
the published run's build, not the newest on disk. Tables from before
the record fall back to the newest ledger, which is what every reader
took until then.

## Usage

``` r
knw_run_ledger(tune_dir, log_dir = "scripts/logs/habitat")
```

## Arguments

- tune_dir:

  the directory of `<key>_summary.csv` tables (not recursed).

- log_dir:

  where the ledgers live.

## Value

`character(1)` the ledger's path.

## Examples

``` r
d <- tempfile(); dir.create(d); dir.create(l <- file.path(d, "logs"))
for (f in c("20261020", "20261027")) {
  writeLines("kind,step,n,note", file.path(l, paste0(f, "_evidence_build_ledger.csv")))
}
utils::write.csv(data.frame(species_code = "CH", stage = "rear",
                            evidence_ledger = file.path(l, "20261020_evidence_build_ledger.csv")),
                 file.path(d, "CH_rear_summary.csv"), row.names = FALSE)
basename(knw_run_ledger(d, l))   # the run's, not the newest
#> [1] "20261020_evidence_build_ledger.csv"
```
