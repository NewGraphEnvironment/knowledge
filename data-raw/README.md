# data-raw

Scripts that write the package's bundled data and figures. `vignette_chinook.R` writes the data
for `vignettes/tuning-chinook-rearing.Rmd`: it runs once against the saved tuning and comparison tables and
the local database, and writes small files under `inst/vignette-data/`, so the article builds
anywhere, with no database, under `R CMD check` and pkgdown. Rerun it from the repo root after any
`scripts/0320`, `0322`, `0325` or `0330` rerun, and `tests/testthat/test-vignette-data.R` fails until you do.

`vignette_context.R` writes what places the Bulkley map for a stranger (#77): the map group's outline, British
Columbia for the keymap, its towns (Natural Resources Canada's geographical names) and its rivers' names, into
`inst/vignette-data/bulk_context.rds`. `readme_figure.R` draws the README's map into `man/figures/` from the same
bundled data, over Esri's topographic map blended with its shaded relief (fetched as it runs), and
`make_hexsticker.R` the hex sticker; rerun the first two after `vignette_chinook.R`.

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

`site_gradient_check.R` is a measurement rather than a check of one path against another: it compares the gradient
crews measured at FDIS sites with link's segment gradient and the Atlas line's, and counts how often a site lies on
the other side of a published limit (#121; `research/fdis_export.md`). It needs no database, refuses evidence that is
not the build `data/thresholds.csv` names unless `EVIDENCE_CHECK=FALSE`, and takes it from `EVIDENCE_DIR`.

`tune_anchor_check.R` is a measurement too: it reads every saved tuning table in `TUNE_DIR` and sets each key's pick
from link's `default` and from its flow version beside the best-scoring rule, with how far behind and how many parts
apart (`knw_tune_anchor()`; #141, `research/baseline_anchoring.md`). It needs no database and rescores nothing.

`minimal_network_check.R` sets two evidence builds of the same groups beside each other, one on link's full network and
one on its minimal network (#120; `research/minimal_network_tuning.md`): the visits placed, the columns that differ,
the walks and outcomes, access per group, each visit's minimal parent, and with `STORED=TRUE` link's stored habitat km
per group from the database. `segment_gradient_check.R` takes `EVIDENCE_DIR` as well, and tags its log by it.

`cut_points_stage.R`, `vignette_cut_points.R` and `vignette_cut_points_places.R` write the data for the cut-points
article (`vignettes/tuning-stream-splits.Rmd`; #149). The first runs on the database's host: it copies the
evidence of three networks, chinook rearing's four setup runs and the geometry of the streams the article draws into
the ignored `data/stage/cut_points/`, each file held to its run, with a manifest. The second reads only that stage and
logs written once, holds the premise, the setups and the other species' counts to the logs that report them and the
transfer's totals to the setups' km, chooses the examples by rules fixed in the
script, and writes `inst/vignette-data/cut_points.rds`. The third names the stream each place's stream flows into and
the nearest town (Freshwater Atlas, BC Geographical Names), pinned to that bundle's md5.

