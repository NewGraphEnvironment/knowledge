# data-raw

Scripts that write the package's bundled data and figures. `vignette_chinook.R` writes the data
for `vignettes/chinook_rearing.Rmd`: it runs once against the saved tuning and comparison tables and
the local database, and writes small files under `inst/vignette-data/`, so the article builds
anywhere, with no database, under `R CMD check` and pkgdown. Rerun it from the repo root after any
`scripts/0320`, `0322`, `0325` or `0330` rerun, and `tests/testthat/test-vignette-data.R` fails until you do.

`readme_figure.R` draws the README's map into `man/figures/` from the same bundled data, and
`make_hexsticker.R` the hex sticker; rerun the first after `vignette_chinook.R`.
