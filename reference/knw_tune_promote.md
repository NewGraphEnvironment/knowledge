# Promote a candidate tuning run into the tracked tables

`scripts/0320` writes a full run to `data/tune/candidate/<run>/` and
`scripts/0330` compares it into `data/compare/candidate/<run>/`, both
ignored, so iterating changes nothing tracked (#111). Promotion, on the
operator's word, moves the run in: every file of each promoted key (its
tables, the grade tables' records, and the ignored grades, curve, score
cache, segments and GeoPackage), its Atlas-gradient sensitivity, the
run's logs, and its rows of the tables that hold every key
(`compare.csv`, `change.csv`, `checks.csv`, `floodplain.csv`). A key's
files are moved, not copied (its grades and GeoPackage run to
gigabytes), so a promoted key leaves the run's directory; the logs are
copied. A tracked file of a promoted key that the run did not write is
removed, so no key is left half one run and half another. Every file
replaced or removed is first moved to `candidate/replaced_<stamp>/`
under the two directories, itself a candidate, so a promotion is undone
by promoting that (the logs it added, and files it added where none
stood, then stay).

## Usage

``` r
knw_tune_promote(
  run,
  keys = NULL,
  live = NULL,
  tune_dir = "data/tune",
  compare_dir = "data/compare",
  log_dir = "scripts/logs/habitat",
  dry_run = FALSE
)
```

## Arguments

- run:

  `character(1)` the candidate run's name.

- keys:

  `NULL` for every key of the run, or the keys to promote (`"CH_rear"`).

- live:

  `NULL`, or a named list of the values the promoted set must carry to
  pass what reads it next (`evidence_md5`: the md5s of this machine's
  derived tables; `walk_md5`: this tree's walk; `discharge_load`: the
  live flow load); `scripts/0335` passes them.

- tune_dir, compare_dir:

  the tracked directories; the candidates are their `candidate/<run>/`.

- log_dir:

  where the tracked logs live. A run's comparison draws no figures since
  \#173, so none are promoted; a `fig/` an older run or archive holds is
  left where it is, noted.

- dry_run:

  `TRUE` checks and lists, moving and writing nothing.

## Value

A list: `keys`, `written` (tracked paths written), `removed` (tracked
paths removed), `archive` (the `replaced_<stamp>` run holding what was
replaced, `NA` when nothing was), and `notes` (what the run did not
bring and was left as it was), invisibly.

## Details

Keys can be promoted alone, but only onto the build the kept keys are
on: `scripts/0325` and the article bundles require one evidence build,
link run, gradient, reference edges, flow load, walk, link config and
tuned structure across every key, so a promotion that would leave two is
refused before anything moves, naming the field and the kept keys that
would have to come along. After a change upstream (a new link run or
evidence build) that means every fitted key moves together. Each
promoted key's grades must carry their record
([`knw_grade_record_write()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_record_write.md))
and match it (md5 and size; a `replaced_*` archive may lack one); a
grade table's receipt
([`knw_grade_receipt_write()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_receipt_write.md),
\#154), where the run wrote one, moves with it and must name the
record's md5. Kept keys are read from their records where the tables are
absent. A key scored under other floors than the tuning's (`min_wsg`,
`folds` in its summary, \#120) is refused. Each promoted key's grades
must be of its recommended rule on its own evidence, and its comparison
of the same rule and made after its grades.

## Examples

``` r
d <- tempfile(); dir.create(c <- file.path(d, "tune", "candidate", "r1"), recursive = TRUE)
dir.create(file.path(d, "compare"))
utils::write.csv(data.frame(species_code = "KO", stage = "rear", status = "no_stream_rule"),
                 file.path(c, "KO_rear_summary.csv"), row.names = FALSE)
p <- knw_tune_promote("r1", tune_dir = file.path(d, "tune"), compare_dir = file.path(d, "compare"),
                      log_dir = file.path(d, "logs"))
basename(p$written)
#> [1] "KO_rear_summary.csv"
```
