# A grade table's record: what the run made, in one tracked row

A grade table (`data/tune/<key>_grades.csv`, written by `scripts/0320`)
is one row per stream segment, 0.7 to 5.6 GB, and ignored. Every reader
that checks which run made it reads only its first row, where the run's
record sits in the constant columns. The record is that row's constant
columns with the table's md5, size and row count, the run, the evidence
ledger, the knowledge commit and link's build beside it, written once
beside the table as `<key>_grades_record.csv` and tracked, so a machine
without the table still knows which run it was and an article bundle
pins the record rather than the table (#119). The archive
(`scripts/0336`) stores the table and restores it against the record's
md5.

## Usage

``` r
knw_grade_record_write(
  grades_path,
  tune_run,
  evidence_ledger,
  knowledge_commit,
  link,
  tokens,
  rows = NA,
  record_source = c("0320", "backfill")
)

knw_grade_record_read(path)

knw_grade_record_check(record, grades_path)
```

## Arguments

- grades_path:

  `character(1)` the grade table.

- tune_run:

  `character(1)` the tuning run that made it (`0320`'s `RUN`), or the
  name a backfill gives a run that predates the record.

- evidence_ledger:

  `character(1)` the evidence build ledger the run read.

- knowledge_commit:

  `character(1)` the knowledge commit the run ran at, or `NA` where it
  is not known.

- link:

  `named character`: `version` and `sha` of the link that built the
  network (the ledger's `run_link_version` and `run_link_sha`).

- tokens:

  `named character` `c(cut =, acc =, grad =, flow =)` from
  [`knw_build_record()`](https://newgraphenvironment.github.io/knowledge/reference/knw_build_record.md);
  `NA` where the build predates link's vocabulary.

- rows:

  `numeric(1)` the table's row count, or `NA`: counting a 5 GB table to
  write its record costs more than the record is worth, so the writer
  passes what it knows and the check never reads it.

- record_source:

  `character(1)` `"0320"` (written with the table) or `"backfill"`
  (written later from a table that predates the record).

- path:

  `character(1)` a `<key>_grades_record.csv`.

- record:

  a record from `knw_grade_record_read()`.

## Value

`knw_grade_record_write()`: the record (a one-row data frame),
invisibly, after writing it beside the table. `knw_grade_record_read()`:
the record. `knw_grade_record_check()`: `TRUE`, invisibly, or an error
naming what differs.

## Examples

``` r
d <- tempfile(); dir.create(d)
g <- file.path(d, "CH_rear_grades.csv")
utils::write.csv(data.frame(id_segment = 1:2, grade = c(0.1, 0.2), species_code = "CH", stage = "rear",
                            rule = "r1", run_uid = "u1", ref_population = "stream_branch", ref_edge = "1000",
                            q_walk = 0.75, walk = "bank", walk_md5 = "w", discharge_load = "wet load",
                            curve_prior_sd = 1, grade_withheld = FALSE, null_heldout_curve = 1.5,
                            evidence_md5 = "a;b;c", curve_grad = "segment_gradient"),
                 g, row.names = FALSE)
knw_grade_record_write(g, tune_run = "20261027_0000", evidence_ledger = "ledger.csv",
                       knowledge_commit = NA, link = c(version = "0.66.0", sha = "abc"),
                       tokens = c(cut = NA, acc = NA, grad = NA, flow = NA), rows = 2)
r <- knw_grade_record_read(file.path(d, "CH_rear_grades_record.csv"))
r$rule
#> [1] "r1"
knw_grade_record_check(r, g)
```
