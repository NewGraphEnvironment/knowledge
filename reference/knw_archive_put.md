# Store a run in the archive, and record where

Sends each object of a
[`knw_archive_plan()`](https://newgraphenvironment.github.io/knowledge/reference/knw_archive_plan.md)
to the bucket (`aws s3api put-object`, the grade table through `zstd -3`
first) with its md5 and its source's md5 as metadata, reads the version
id back, and appends one `archived` row per object to the index. An
object whose current version already carries the same md5 is not sent
again: its version is recorded. Refused before anything is sent: a
bucket whose versioning is not enabled (an overwrite would lose the last
copy), and, for an unpromoted run, a setup folder whose current objects
are a promoted run's.

## Usage

``` r
knw_archive_put(
  plan,
  index = "data/archive_index.csv",
  promoted = FALSE,
  dry_run = FALSE,
  bucket = .knw_archive_bucket
)
```

## Arguments

- plan:

  from
  [`knw_archive_plan()`](https://newgraphenvironment.github.io/knowledge/reference/knw_archive_plan.md).

- index:

  the index path.

- promoted:

  `TRUE` when the run is being promoted: `promoted` events are appended
  for its keys, and `superseded` for the keys' runs it replaces.

- dry_run:

  `TRUE` lists the plan and sends nothing.

- bucket:

  the bucket.

## Value

The rows appended to the index, invisibly.
