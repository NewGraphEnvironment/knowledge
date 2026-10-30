# Keeping a tuning run: the archive

**Verified:** 2026-10-30 · **Issues:** #119 (built here), #111 (promotion), NewGraphEnvironment/link#420 (tokens for
older builds) · **Produced by:** `R/archive.R`, `scripts/0336-archive.R`; sizes and costs from #119's measurements of
2026-10-29 · **Status:** bucket configured 2026-10-30; first entry (the published run) pending

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

## Which archive is "the run": by content, not by name

A run's name is not its identity: `0320` resumes and regrades a named run, and a key can be promoted, superseded and
promoted again. So each archive call is a **batch** (`batch` in the index), and a run is found by what it holds:

- A restore takes the batch whose stored record is the checkout's record (by md5). The record pins only the grade
  table, so batches sharing a record are narrowed by the curve and segments the checkout holds. Where they still differ,
  the published batch is taken; otherwise the restore refuses and asks for `BATCH=<key>=<batch>`.
- An undo takes the batch the index says the undone promotion unpublished (the latest `superseded` or `undone` batch
  whose record is the restored one). It copies that batch's versions back over a shared folder, and reports restored
  files that differ rather than refusing, because a machine's ignored files can be another build's.
- An unpromoted archive is refused where it would overwrite a published object with other content.

Five review rounds on #119 found each of these one step at a time, each inside the previous fix (the archive README
for #119 has the rounds).

## Overwrite with versioning

A re-run of one setup overwrites its folder, and the bucket keeps the previous objects as versions. An unpromoted run
is refused over a folder whose current objects belong to a promoted run. Versioning is bucket-wide, so it also keeps
old copies of the `rag/` stores. Lifecycle filters have no "everything except", and a bucket-wide noncurrent rule
would also cover `archive/knowledge/` (the shorter expiry wins). So previous versions expire by prefix: 180 days under
`archive/knowledge/`, and 30 days under each other top-level prefix and each other child of `archive/`. **A new
top-level prefix has no noncurrent expiry until it gets its own rule.** The existing rule (Standard-IA after 30 days,
whole bucket) stays, beside a rule that aborts incomplete multipart uploads after 7 days. Configured 2026-10-30
(15 rules, read back); when versioning was turned on the bucket held no previous versions, only 41 delete markers, so
the rules removed nothing. A real round trip through S3 and zstd under a scratch prefix restored every file
md5-identical, and a second archive of the same files sent nothing.

## Cost

At list prices as known (S3 Standard about $0.023 per GB-month, egress about $0.09 per GB): archiving every run,
compressed, with the evidence once per build, comes to about 28 GB and $0.65 a month after a year at 15 runs a year.
Restoring one run costs about $0.15. Storage is not the cost that matters; recreating a run is.
