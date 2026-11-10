# Restore a run from the archive into a tree's ignored data/

Fetches, by version id, the objects the index lists for each key's run
(the run its tracked record names, so a checkout restores what its
tables were made from) and their evidence build, decompresses the grade
table, and checks every file's md5 against the index's `source_md5` (and
a grade table against its record). Each file is written aside and moved
in once checked; a file already there with the same md5 is left, and one
with another md5 refuses before anything is written. The evidence and
the bundles' ignored files come by default; grade tables, gigabytes
each, only with `grades = TRUE`. Grade tables are restored before
segments, whose mtime `scripts/0330` holds to be later.

## Usage

``` r
knw_archive_pull(
  keys,
  dest = ".",
  grades = FALSE,
  index = "data/archive_index.csv",
  bucket = .knw_archive_bucket,
  batch = NULL
)
```

## Arguments

- keys:

  the keys whose run to restore.

- dest:

  the tree to restore into (its `data/`).

- grades:

  `TRUE` to restore the grade tables too.

- index:

  the index path.

- bucket:

  the bucket.

- batch:

  `NULL`, or a named character vector of batch ids by key, for a record
  that several archives hold with other curves or segments (the
  checkout's own files, and then the published batch, decide otherwise).

## Value

The restored and kept files' paths, invisibly.
