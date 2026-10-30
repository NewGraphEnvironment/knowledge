# Record an undone promotion in the archive's index

`scripts/0335` undoes a promotion by promoting its `replaced_<stamp>`
archive, which sends nothing new to the bucket. This appends, per key,
an `undone` event for the run that was promoted and a `promoted` event
for the run the restored record names, so the index says which run is
published. Where the run's folder is shared (a tokened setup), the
promotion being undone made the restored run's objects previous
versions, which the bucket expires; each is copied back over its key
(server side, from its indexed version) so it is current again, and the
copy's version is recorded as an `archived` row.

## Usage

``` r
knw_archive_undo(
  keys,
  tune_dir = "data/tune",
  index = "data/archive_index.csv",
  bucket = .knw_archive_bucket,
  compare_dir = "data/compare",
  batch = NULL
)
```

## Arguments

- keys:

  the keys moved back.

- tune_dir:

  where their restored records (and curves) are.

- index:

  the index path.

- bucket:

  the bucket.

- compare_dir:

  where their restored segments are. The batch restored is the one the
  undone promotion superseded whose record is the restored one; restored
  curves and segments that differ from it are reported, and the
  archive's copies are published.

- batch:

  `NULL`, or a named character vector of batch ids by key, where the
  index cannot name the batch.

## Value

The rows appended, invisibly.
