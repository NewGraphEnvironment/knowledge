# data-raw

Scripts that write the data the package's articles read. Each one runs once against the
saved tuning and comparison tables, the local database and the catalog's floodplain layers,
and writes small files under `inst/vignette-data/`, so the articles build anywhere, with no
database, under `R CMD check` and pkgdown. `vignette_chinook.R` writes the data for
`vignettes/chinook_rearing.Rmd`; rerun it from the repo root after any `scripts/0320` or
`scripts/0330` rerun, and `tests/testthat/test-vignette-data.R` fails until you do.
