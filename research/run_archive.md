# Keeping a tuning run: the archive

**Verified:** 2026-10-30 · **Issues:** #119 (built here), #111 (promotion), NewGraphEnvironment/link#420 (tokens for
older builds) · **Produced by:** `R/archive.R`, `scripts/0336-archive.R`; sizes and costs from #119's measurements of
2026-10-29 · **Status:** code and tests landed; bucket configuration and the first entry (the published run) pending

## Why a run needs keeping

A tuning run's grade tables (one row per stream segment, 0.7 to 5.6 GB each, about 26 GB a run), curves and segments
are ignored by git. Until #119 they lived only on the machine that ran it, and the methodology article's bundle pinned
the md5 of each grade table, so a published bundle could be rebuilt on one machine and nowhere else. Recreating a run
instead costs about an hour of regrading and works only while the database still holds that run's link build and flow
load. wet reloads its flow table in place, so often it cannot.

## What is kept, and where

Everything is under `s3://fresh-bc/archive/knowledge/`, which is private:

- `tune/<key>/<setup>/` holds a run's files for one key: `<key>_grades.csv.zst` (zstd -3, about 17× smaller), the
  grade record, `<key>_curve.rds` and the comparison's `<key>_segments.rds`. `<setup>` is the build's four link
  output-vocabulary tokens, `<cut>.<acc>.<grad>.<flow>`. A build older than the vocabulary (link 0.70.0) logged no
  tokens, so it goes under `untokened/<tune run>`; its folder keeps that name after link#420 names its tokens, and its
  index rows gain them instead.
- `evidence/<id>/` holds one evidence build: the three visit tables, `fdis_sites.csv`, `reconcile.csv`, `sites.rds`
  and a `MANIFEST` (md5 and name per file). `<id>` is the MANIFEST's md5. A build is stored once, however many runs
  read it.

`data/archive_index.csv` (tracked) holds one row per stored object, with its source md5, its stored md5 and its S3
version id. It also holds one row per key for each `promoted`, `superseded` or `undone` event. A run is found by
reading the index, never by listing the bucket.

Not kept: the score cache (`_score.rds`, which regenerates), the GeoPackages (made from the segments), and the
Atlas-gradient sensitivity's curves (`grad_fwa/`, which grades nothing).

## The record is what the bundles pin

`0320` writes `<key>_grades_record.csv` (tracked) beside each grade table. It holds the table's constant columns
exactly as written, its md5, size and rows, the tuning run, the evidence ledger, the knowledge commit and link's build.
The bundles read and pin the record, so rebuilding them needs the evidence (about 200 MB), not 26 GB of tables. The
record is written once and never changes; where a run is stored lives in the index. A restore fetches the run that a
checkout's records name, by version id, and checks each file against its md5.

## Overwrite with versioning

A re-run of one setup overwrites its folder, and the bucket keeps the previous objects as versions. An unpromoted run
is refused over a folder whose current objects belong to a promoted run. Versioning is bucket-wide, so it also keeps
old copies of the `rag/` stores. Lifecycle filters have no "everything except", and a bucket-wide noncurrent rule
would also cover `archive/knowledge/` (the shorter expiry wins). So previous versions expire by prefix: 180 days under
`archive/knowledge/`, and 30 days under each other top-level prefix and each other child of `archive/`. **A new
top-level prefix has no noncurrent expiry until it gets its own rule.** The existing rule (Standard-IA after 30 days,
whole bucket) stays.

## Cost

At list prices as known (S3 Standard about $0.023 per GB-month, egress about $0.09 per GB): archiving every run,
compressed, with the evidence once per build, comes to about 28 GB and $0.65 a month after a year at 15 runs a year.
Restoring one run costs about $0.15. Storage is not the cost that matters; recreating a run is.
