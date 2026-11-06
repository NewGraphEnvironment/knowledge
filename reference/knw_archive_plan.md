# What the archive stores for a run, and where

Lists every file one archive of a run sends to the bucket: per key the
grade table (stored compressed), its record, the curve, the comparison's
segments and, where the run wrote one, the grade table's receipt (#154),
under `tune/<key>/<setup>/`; and the evidence build the grades name,
under `evidence/<id>/` with a `MANIFEST` (one line per file, its md5 and
name), `<id>` being the MANIFEST's md5. Each grade table is checked
against its record and the evidence against the grades' `evidence_md5`
before anything is listed, so an archive never stores a table its record
does not describe.

## Usage

``` r
knw_archive_plan(
  keys,
  tune_dir,
  compare_dir,
  evidence_dir,
  build_dir,
  vocabulary = NULL
)
```

## Arguments

- keys:

  the keys (`"CH_rear"`) to archive.

- tune_dir, compare_dir:

  the run's directories (a candidate's, or the tracked `data/tune` and
  `data/compare`, or a staged copy).

- evidence_dir, build_dir:

  the evidence build: `0310`'s `data/fdis/derived` and `0230`'s
  `data/fdis/build`.

- vocabulary:

  passed to
  [`knw_archive_setup()`](https://newgraphenvironment.github.io/knowledge/reference/knw_archive_setup.md).

## Value

A data frame, one row per object: `kind` (`tune`, `evidence`), `key`,
`setup`, `tune_run`, `run_uid`, `evidence_id`, `source` (the local
file), `target` (where a restore puts it: its path in a checkout's
`data/`), `object` (the S3 key), `compress`, `source_md5`; with
attribute `manifest`, the MANIFEST's text.
