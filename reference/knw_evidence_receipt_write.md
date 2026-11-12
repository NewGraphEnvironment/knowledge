# An evidence build's provenance receipt

Writes `evidence_receipt.json` into an evidence directory, beside the
tables `scripts/0310` builds there, in crate's shared receipt shape
([`crate::crt_receipt_write()`](https://newgraphenvironment.github.io/crate/reference/crt_receipt_write.html),
\#160): how the build was made (knowledge's commit, the method register
and the walk's SQL, the build's settings, link's build, wet's flow load,
the FDIS extract and its load, and the tracked tables it reads) and what
came out (every table, fingerprinted, the placed visits and
`access_check`'s km). The declaration
([`knw_receipt_keys()`](https://newgraphenvironment.github.io/knowledge/reference/knw_receipt_keys.md)`("evidence")`)
holds every table exact but `access_check`'s km, which a database
summing in another order moves in the last place, so a rebuild compared
with this receipt
([`crate::crt_receipt_compare()`](https://newgraphenvironment.github.io/crate/reference/crt_receipt_compare.html))
answers identical, equivalent, or different. A grade graded on the build
names it by this receipt's `recipe_id`
([`knw_grade_receipt_write()`](https://newgraphenvironment.github.io/knowledge/reference/knw_grade_receipt_write.md)),
so an equivalent rebuild of the evidence is the same input to every
grade. The receipt carries no host, because the evidence it describes is
public.

## Usage

``` r
knw_evidence_receipt_write(
  evidence_dir,
  settings,
  inputs,
  knowledge,
  context = list()
)
```

## Arguments

- evidence_dir:

  `character(1)` the evidence directory, holding the seven tables the
  declaration fingerprints.

- settings:

  a named list of the build's settings the declaration lists: `species`,
  `q_grid`, `sources`, `snap_limit_m`, `snap_limit_code_m`, `parent`.

- inputs:

  a named list of the inputs the declaration lists, each in crate's form
  (`list(version_id = )`, `list(sha256 = )`, `list(none = )`).

- knowledge:

  `list(commit, dirty)`: knowledge's full commit and whether its tracked
  package files or scripts differed from it, read at the build's start
  (`.knw_git_state()`).

- context:

  a named list carried into the receipt's context (the run's
  identifiers, link's version and commit); never part of its identity.

## Value

The receipt as read back from the file just written
([`crate::crt_receipt_read()`](https://newgraphenvironment.github.io/crate/reference/crt_receipt_read.html)),
invisibly.

## Details

The tables are read back from their CSVs as text, as a reader gets them,
with `access_check`'s km read as a number.

## Examples

``` r
ev <- tempfile(); dir.create(ev)
tbl <- c("visits_link", "visits_species", "walks", "bcfishobs_fdis_match", "workbook_sites", "workbook_species")
for (f in tbl) utils::write.csv(data.frame(site_visit = c("a", "b")), file.path(ev, paste0(f, ".csv")),
                                row.names = FALSE)
utils::write.csv(data.frame(species_code = "BT", km = 787407.1195799585), file.path(ev, "access_check.csv"),
                 row.names = FALSE)
inputs <- lapply(stats::setNames(nm = knw_receipt_keys("evidence")$inputs), function(i) list(version_id = "x"))
settings <- list(species = c("BT", "CH"), q_grid = c(1, 3), sources = "pick", snap_limit_m = 100,
                 snap_limit_code_m = 150, parent = "none")
r <- knw_evidence_receipt_write(ev, settings, inputs, knowledge = list(commit = strrep("a", 40), dirty = FALSE))
r$result$summary$visits
#> [1] 2
r$recipe$recipe_id
#> [1] "cee2189c556c67d968c55806b129c60882192218b60ff34e7c0dff956a568be2"
```
