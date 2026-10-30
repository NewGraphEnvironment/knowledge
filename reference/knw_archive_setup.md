# Where the archive keeps a run: its setup folder

A run's ignored files are kept under `tune/<key>/<setup>/`, one folder
per setup compared side by side (#119). The setup is the four tokens of
link's output vocabulary its build logged (`cut.acc.grad.flow`, from the
grade record), each held to link's `vocabulary.csv` when one is given. A
build from before link 0.70.0 logged none and is kept under
`untokened/<tune run>`: its folder is never renamed when its tokens are
named later (link#420); the index rows gain them instead. A re-run of a
tokened setup overwrites its folder, and the bucket keeps the previous
objects as versions.

## Usage

``` r
knw_archive_setup(record, vocabulary = NULL)
```

## Arguments

- record:

  a grade record
  ([`knw_grade_record_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_record_write.md)).

- vocabulary:

  `NULL`, or link's vocabulary (`token` and `axis` columns, link's
  `inst/extdata/vocabulary.csv`).

## Value

`character(1)` the setup folder.

## Examples

``` r
knw_archive_setup(data.frame(token_cut = NA, token_acc = NA, token_grad = NA, token_flow = NA,
                             tune_run = "20261027_0000"))
#> [1] "untokened/20261027_0000"
knw_archive_setup(data.frame(token_cut = "cut-full-top", token_acc = "acc-v1", token_grad = "grad-seg",
                             token_flow = "q-wet-fill", tune_run = "20261101_0000"))
#> [1] "cut-full-top.acc-v1.grad-seg.q-wet-fill"
```
