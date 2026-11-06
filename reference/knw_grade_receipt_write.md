# A grade table's provenance receipt

Writes `<key>_grades_receipt.json` beside a grade table and its record
([`knw_grade_record_write()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_record_write.md)),
in crate's shared receipt shape
([`crate::crt_receipt_write()`](https://newgraphenvironment.github.io/crate/reference/crt_receipt_write.html),
\#154): how the table was made (knowledge's commit, the method register
and the walk's SQL, the run's resolved settings and fold seed, link's
build, wet's flow load and the evidence tables' sha256) and what came
out (the pick, fingerprinted, and the table's rows, graded rows, graded
km and grade sum). A rebuild's receipt compared with this one
([`crate::crt_receipt_compare()`](https://newgraphenvironment.github.io/crate/reference/crt_receipt_compare.html),
with
[`knw_receipt_keys()`](https://newgraphenvironment.github.io/knowledge/reference/knw_receipt_keys.md)`("grade")`)
answers identical, equivalent within the declared tolerances, or
different. The table's bytes are recorded, not judged: a rebuild that
sums in another order moves them and nothing a reader decides on. The
receipt carries no host, because it is tracked in a public repository.

## Usage

``` r
knw_grade_receipt_write(
  grades_path,
  grades,
  spec,
  min_wsg,
  evidence_dir,
  knowledge
)
```

## Arguments

- grades_path:

  `character(1)` the grade table, `<key>_grades.csv`.

- grades:

  a data frame of the table's `length_metre` and `grade`: the grades in
  hand when 0320 writes them, or those two columns read back.

- spec:

  the run's score settings for the key
  ([`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)'s
  `spec`: `fit`, `prior_sd`, `seed`, `folds`, `d_floor`, `extra`,
  `grad`).

- min_wsg:

  `integer(1)` the run's floor on groups with both outcomes.

- evidence_dir:

  `character(1)` the evidence directory the run read.

- knowledge:

  `list(commit, dirty)`: knowledge's full commit and whether its tracked
  package files or scripts differed from it, read at the run's start.
  The receipt is written by the pass that graded the table: every value
  it records is that pass's, so 0320 regrades a kept table whose receipt
  is missing rather than writing one later.

## Value

The receipt, as a list, invisibly.

## Details

The record is written first and read here, so the two describe one
table: the receipt refuses a table whose size is not the record's,
evidence whose md5s are not the record's, and a walk other than the one
the record names, and carries the record's `grades_md5` in its context,
which is how 0320's keep-check and promotion tie a receipt to a checked
table without hashing it again.

## Examples

``` r
d <- tempfile(); dir.create(d)
ev <- file.path(d, "evidence"); dir.create(ev)
for (f in c("visits_link", "visits_species", "walks")) writeLines("x", file.path(ev, paste0(f, ".csv")))
ev_md5 <- paste(unname(tools::md5sum(file.path(ev, paste0(c("visits_link", "visits_species", "walks"),
                                                         ".csv")))), collapse = ";")
grades <- data.frame(id_segment = 1:3, length_metre = c(120, 300, 80), grade = c(0.1, 0.5, NA))
g <- file.path(d, "CH_rear_grades.csv")
utils::write.csv(cbind(grades, species_code = "CH", stage = "rear", rule = "r1", run_uid = "u1",
                       ref_population = "stream_branch", ref_edge = "1000", q_walk = 3, walk = "bank",
                       walk_md5 = knw_walk_md5(), discharge_load = "wet load", curve_prior_sd = 2.5,
                       grade_withheld = FALSE, null_heldout_curve = 1.5, evidence_md5 = ev_md5,
                       curve_grad = "segment_gradient"),
                 g, row.names = FALSE)
knw_grade_record_write(g, tune_run = "20261105_0000", evidence_ledger = "ledger.csv",
                       knowledge_commit = NA, link = c(version = "0.78.2", sha = strrep("b", 40)),
                       tokens = c(cut = NA, acc = NA, grad = NA, flow = NA), rows = 3)
spec <- list(fit = "gam", prior_sd = 2.5, seed = 54L, folds = 5L, d_floor = 200, extra = TRUE,
             grad = "segment_gradient")
r <- knw_grade_receipt_write(g, grades, spec, min_wsg = 5L, evidence_dir = ev,
                             knowledge = list(commit = strrep("a", 40), dirty = FALSE))
r$result$summary$km_graded
#> [1] 0.42
```
