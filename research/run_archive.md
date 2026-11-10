# Keeping a tuning run: the archive

**Verified:** 2026-10-30; receipts 2026-11-06 · **Issues:** #119 (built here), #111 (promotion),
NewGraphEnvironment/link#420 (tokens for older builds), #154 (receipts), #158 (the first rebuild compared), #160 (the
evidence build's and the published visit set's receipts) ·
**Produced by:** `R/archive.R`, `scripts/0336-archive.R`, `R/grade_receipt.R`, `R/evidence_receipt.R`, `inst/receipt/`; sizes and costs from
#119's measurements of 2026-10-29 · **Status:** bucket configured 2026-10-30; first entry (the published run) pending;
the first receipts arrive with the next retune

## Why a run needs keeping

A tuning run's grade tables (one row per stream segment, 0.7 to 5.6 GB each, about 26 GB a run), curves and segments
are ignored by git. Until #119 they lived only on the machine that ran it, and the methodology article's bundle pinned
the md5 of each grade table, so a published bundle could be rebuilt on one machine and nowhere else. Recreating a run
instead costs about an hour of regrading and works only while the database still holds that run's link build and flow
load. wet reloads its flow table in place, so often it cannot.

## What is kept, and where

Everything is under `s3://fresh-bc/archive/knowledge/`, which is private:

- `tune/<key>/<setup>/` holds a run's files for one key: `<key>_grades.csv.zst` (zstd -3, about 17× smaller), the
  grade record, `<key>_curve.rds`, the comparison's `<key>_segments.rds` and, for a run made since #154, the grade
  table's receipt. `<setup>` is the build's four link
  output-vocabulary tokens, `<cut>.<acc>.<grad>.<flow>`. A build older than the vocabulary (link 0.70.0) logged no
  tokens, so it goes under `untokened/<tune run>`; its folder keeps that name after link#420 names its tokens, and its
  index rows gain them instead.
- `evidence/<id>/` holds one evidence build: the three visit tables, `fdis_sites.csv`, `reconcile.csv`, `sites.rds`
  and a `MANIFEST` (md5 and name per file). `<id>` is the MANIFEST's md5. A build is stored once, however many runs
  read it. The visit tables come from `EVIDENCE_DIR`, `reconcile.csv` and `sites.rds` from `0230`'s `BUILD_DIR`, and
  `fdis_sites.csv` from where `0240` writes it, `data/fdis/derived`, for a tagged build too (#136): it is built from
  `sites.rds` and reads no link schema. `sites.rds` is held to the run's ledger, and `fdis_sites.csv` to `sites.rds`
  (one row per site, the same placement columns), since nothing else ties the table to a build. A restore puts every
  file back under `data/fdis/`, and refuses before writing anything when a file there has other bytes.

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

## The receipt says whether a rebuild came out the same

The record says which run made a table. It cannot say whether a rebuild of that run made the same table, because a
rebuild can come out slightly different and still be right: the same build's evidence, built twice, once gave three
byte-identical tables and a fourth that differed at 9.5e-11 km per value, because the database summed in another
order. So since #154 each grade table and each published set also carries a receipt in crate's shared shape
(NewGraphEnvironment/crate#43), which separates two questions. Was it made the same way? That is the recipe: the
knowledge commit, the walk's SQL and the method register, the run's settings and fold seed, link's build, wet's flow
load and the evidence. Did it come out the same? That is the result: what was decided and a few totals. Comparing a
rebuild's receipt with the archived one answers `identical`, `equivalent` (every result within its declared rounding)
or `different`, naming each field that moved.

What each output holds as its result, and the rounding it is allowed, is declared beside its writer in
`inst/receipt/<output>.yaml`:

| output | judged on | rounding |
|---|---|---|
| grade table (`<key>_grades_receipt.json`, tracked) | the pick (rule, reference edges, walk river size, the gate's verdict and number); rows, graded rows, graded km, grade sum | gate number 1e-4 (written to four decimals); graded km and grade sum 1e-3 |
| thresholds set (`receipt.json` beside its manifest) | both tables, read as text | none: exact |
| grade set (`receipt.json` beside its manifest) | rows, graded rows, graded km, grade sum | graded km and grade sum 1e-3 |
| evidence build (`evidence_receipt.json` in the evidence directory, #160) | every table `0310` writes, read back as text; placed visits; `access_check`'s km summed | `access_check`'s km 1e-6 per value, its sum 1e-3; every other table exact |
| published visit set v3 (`receipt.json` beside its manifest, #160) | all 11 tables, read as text | `access_check`'s km 1e-6; every other table exact |

The roundings are absolute, so a sum over millions of segments gets the rounding a sum that size needs (about a metre
of graded km), not the per-value one. A grade table is 0.7 to 5.6 GB, too large to fingerprint, so its bytes are
listed when they move and the verdict rests on the pick and the totals: for a grade, `identical` means those agree
exactly, not that the bytes do.

These roundings are provisional. #158 reruns the published retune on a second database and records each output's
verdict by hand; the roundings are revised from it (an output found identical becomes exact). crate refuses two
receipts that declare different roundings, so a receipt written before a revision compares with one after it only
with a `keys` register override that softens `result.tolerance.*`.

### The evidence build: every table exact but `access_check`'s km

The evidence build's receipt (#160) writes down the rule this track began from. The two measured rebuilds moved
`access_check`'s km by 9.5e-11 and 6.0e-11 km per value (#158's second database), because each value is a sum over up to
millions of segments that a database may take in another order; every other table came back with the same values. So
`access_check`'s km is rounded to 1e-6 km (1 mm, the tolerance #158's hand comparison used) and the rest is exact.
`visits_link` is declared exact although #158 found its `mad_pick` moving on 3 of 45,529 visits: that is #161's
unordered parent-flow tie, so a rebuild on another database reads `different` until #161 lands, and that is true.

Measured on #160's branch (2026-11-06, `data-raw/evidence_receipt_compare.R`,
`scripts/logs/habitat/evidence_receipt_160/`): two `0310` builds of the published build into tagged directories on one
database, 11.9 and 11.6 min, gave one `recipe_id`; six tables byte-identical, `access_check` differing at 1.0e-10 km at
most over 2,193 rows; verdict `equivalent`, on the receipts alone and with the tables re-read (0.9 min). A grade receipt
written against the first build named its `recipe_id`. Both builds ran on one database, so #161's tie, which breaks by
each database's plan, did not fire.

crate rounds a value to its tolerance's decimals rather than allowing a band, so two receipts alone can put values a
hair apart on either side of a rounding edge and read `different`. Judge an evidence or visit-set rebuild with both
builds' tables re-read (`crt_receipt_compare(tables =)`, the tables as `.knw_receipt_csv_tables()` reads them), which
compares cells within the tolerance.

A grade names the evidence by the build's receipt's `recipe_id`, so an evidence rebuild that came out equivalent is the
same input to every grade downstream; a build from before receipts is named by its visit tables' md5s. The cost is the
other direction: two builds of one recipe whose results differ (#161's tie) are also one input, so the evidence's own
comparison is where that difference shows, and each grade keeps `evidence_md5` in its context. The archive stores the
receipt in its build's folder but outside the MANIFEST, because a receipt carries its write time: a rebuild whose
tables came out byte-identical keeps its `evidence_id`, and a restore takes the receipt last archived for it. A restore
refuses an `evidence_receipt.json` present with other bytes rather than write one build's receipt over another's, and
refuses one present where the archived build has none, which every reader of the restored build would refuse.

A receipt names no host, since the grade receipts are tracked in a public repository and the published ones sit on a
public prefix. link enters as its build, the run that made it, not as code: the evidence ledger records link's commit
but not whether its tree was clean.

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
