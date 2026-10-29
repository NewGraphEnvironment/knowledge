# data-raw

Scripts that write the package's bundled data and figures. `vignette_chinook.R` writes the data
for `vignettes/chinook_rearing.Rmd`: it runs once against the saved tuning and comparison tables and
the local database, and writes small files under `inst/vignette-data/`, so the article builds
anywhere, with no database, under `R CMD check` and pkgdown. Rerun it from the repo root after any
`scripts/0320`, `0322`, `0325` or `0330` rerun, and `tests/testthat/test-vignette-data.R` fails until you do.

`readme_figure.R` draws the README's map into `man/figures/` from the same bundled data, and
`make_hexsticker.R` the hex sticker; rerun the first after `vignette_chinook.R`.

Four scripts are checks, not data: each proves that a faster or different path returns what the reference path
returns, and writes its verdict to `scripts/logs/habitat/`. `walk_bank_check.R` holds the walk's bank rule to fresh's
`frs_near_river()` on one group (#73). `walk_batch_check.R` holds the batched walk to the one-query-per-start walk on
a grade's own starts in one group, and the walk cache's rows to a fresh walk (#87). `compare_parallel_check.R` holds
the comparison with its groups on several workers to the one-connection loop, on two keys (#87).
`compare_structures_check.R` holds the comparison under the reported structure alone to the every-structure run's
rows for `default` and that structure, and times the rules both ways, on three keys (#112). `walk_batch_check.R` and
`compare_parallel_check.R` take
their references with `REF=1` from the code as it stood before #87 and refuse to run that mode on newer code; run
the last three on the database's host.
