# Write a set of tables as Parquet with a manifest, and upload them

`scripts/0299`'s pattern as a function: each table is written as zstd
Parquet, compared column by column with an all-character read of its CSV
(numbers within 1e-12, zero-padded codes kept as text, an empty or
`"NA"` cell null on both sides), and described in a `manifest.json` that
carries each file's rows, columns, bytes, sha256 and schema, the source
CSV's sha256 and modification time, and the commit the set was published
from. The bucket does not list, so a reader starts from the manifest.

## Usage

``` r
knw_publish(
  tables,
  dir_out,
  id,
  note,
  provenance = list(),
  supersedes = NULL,
  s3 = NULL,
  republish = FALSE,
  no_sign = FALSE,
  hive = NULL,
  hive_keys = c("species_code", "stage"),
  receipt = NULL
)
```

## Arguments

- tables:

  `data.frame` with `table`, `source` (CSV path), `script` and
  `description`.

- dir_out:

  `character(1)` where the Parquet and manifest are written.

- id:

  `character(1)` the dataset id, e.g. `"knowledge/thresholds/v1"`.

- note:

  `character(1)` a sentence on what this version is.

- provenance:

  a named `list` carried into the manifest (the link run, the evidence
  version, the commit).

- supersedes:

  `character(1)` or `NULL` the id this version replaces.

- s3:

  `NULL`, or the `s3://bucket/` the id is published under.

- republish:

  `logical(1)` allow replacing a published version's contents.

- no_sign:

  `logical(1)` read the published manifest without credentials.

- hive:

  `NULL`, or a `character` of table names whose Parquet is written under
  a Hive path `<table>/<key>=<value>/part.parquet` from the columns
  `hive_keys` (one part per distinct key combination).

- hive_keys:

  `character` the Hive key columns.

- receipt:

  `NULL` (no receipt), or a list for the set's provenance receipt in
  crate's shape (#154): `output`, the declaration it is held to
  ([`knw_receipt_keys()`](https://newgraphenvironment.github.io/knowledge/reference/knw_receipt_keys.md),
  `"thresholds"`, `"habitat_grade"` or `"fdis"`); `recipe`, crate's
  recipe block (`code`, `config`, `inputs`, `seed`); and `summary`, the
  named numbers the declaration lists. The tables the declaration
  fingerprints are read from their source CSVs as text, so they are held
  exact, except a column the declaration gives a tolerance, which is
  read as a number (`"fdis"`'s `access_check` km); the Parquet files are
  the parts, each flat one named by its table. `receipt.json` is written
  beside the manifest with no host, and uploaded after the tables and
  before the manifest.

## Value

The manifest, invisibly.

## Details

With `s3 = NULL` nothing is uploaded. With an `s3://` prefix the
published manifest is read first: a published version with different
tables or schemas refuses (a change of columns or meaning is a new
version), and one with the same tables but different contents refuses
unless `republish = TRUE`. Parquet is uploaded before the manifest, so a
reader never finds a manifest naming a file not yet there.

## Examples

``` r
tmp <- tempfile()
dir.create(tmp)
csv <- file.path(tmp, "t.csv")
utils::write.csv(data.frame(a = 1:3, code = c("08", "09", "10")), csv, row.names = FALSE)
tables <- data.frame(table = "t", source = csv, script = "example", description = "three rows")
m <- knw_publish(tables, file.path(tmp, "out"), id = "example/v1", note = "an example",
                 provenance = list(commit = "none"))
m$files[[1]]$rows
#> [1] 3
```
