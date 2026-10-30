# Findings — Keep the inputs a published article bundle was built from, so any machine can rebuild it (#119)

## Issue context

**If we do it:** any machine with the repo can rebuild a published article bundle in minutes, from the inputs it was built from. **If we never do:** a published bundle can be rebuilt only on a machine that still holds its ignored files, which today is one machine. Elsewhere it means rebuilding the evidence and regrading every key, which takes hours and reproduces the bundle only if the database still holds the same build and flow load.

## Problem

`inst/vignette-data/method.rds` (the methodology article's bundle, from `data-raw/vignette_method.R`) pins the md5s of 12 ignored files it was built from: the seven `data/tune/<key>_grades.csv`, four tables in `data/fdis/derived/` and `data/fdis/build/reconcile.csv`. `vignette_method.R` refuses to run unless `data/fdis/derived` is the evidence the grade tables name. Nothing keeps those files beyond the machine that ran the build, and the published fish-record tables (`knowledge/fdis/v3`) are not yet uploaded.

Measured 2026-10-29: the published bundle (written 2026-10-28, on #92's tables) pins `CH_rear_grades.csv` at `6da9c17f…`. The database's host holds the 2026-10-25 build (`e37f76ea…`, with matching evidence). All 12 pinned files match on one other machine's checkout, and that is the only copy found. So today the bundle can be rebuilt there and nowhere else, and only until that checkout's ignored files are overwritten by its next run. A first check of that machine wrongly reported the files absent: `md5` was not on the non-interactive ssh `PATH`, so the probe printed nothing.

## Measured (2026-10-29)

- The 12 pinned inputs are 26 GB, not the size of the evidence: the seven grade tables (one row per stream segment) are 670 MB to 5.6 GB each. The evidence tables, `reconcile.csv` and `sites.rds` are about 200 MB; the fitted curves (`<key>_curve.rds`) 118 MB.
- Both bundle scripts read **only the first row** of each grade table, the run's record (`vignette_method.R:87`, `vignette_chinook.R:96`), and pin the whole file's md5.
- zstd shrinks a grade table about 17× at level 3 (CH rearing: 3.49 GB to 202 MB, about 1 s on 12 cores) and about 29× at level 19 (WCT rearing: 702 MB to 24 MB, 17 s). At level 3 a run's grade tables are about 1.5 GB.
- The bucket's `knowledge/` prefix holds 18 MB today: no grade tables or evidence beyond the published v2 tables.
- The published build's evidence and the grade tables' first rows were copied off the only machine holding them on 2026-10-29 and checked against the bundle's md5s. They are the seed for the first archive entry.

## Cost by scenario

List prices for S3 Standard (about $0.023 per GB-month) and egress (about $0.09 per GB), as known, not re-checked; upload time depends on the link and is not measured.

| Scenario, 15 runs a year | Stored after a year | About per month after a year | Note |
|---|---|---|---|
| Archive every run, grades zstd-3, curves, record; evidence once per build | ~28 GB | ~$0.65 | five years ~140 GB, ~$3/month |
| Archive only promoted runs (say 5 a year) | ~9 GB | ~$0.20 | |
| Every run, uncompressed | ~390 GB | ~$9, growing | |
| External drive, 500 GB | ~250 runs compressed, ~19 uncompressed | none | one place, not reachable from another machine, no off-site copy |
| Recreate instead of store | nothing | none | about an hour of regrading per run, and only while the database still holds that run's link build and flow load; wet reloads its flow table in place, so today it often cannot |

Storage is not the cost that matters; recreating is. Restoring one run costs about $0.15 of egress.

## Decisions

- **Evidence (Al, 2026-10-29):** private, under the bucket's `archive/`, one folder per evidence build (named by its md5s), with a manifest. Public waits on #76 and fdis v3.
- **When (Al, 2026-10-29):** at promotion, by `0335`, which refuses to finish when the upload fails. The promoting machine needs bucket credentials.
- **Rescue (Al, 2026-10-29):** done, above.
- **Grade tables, leaning (confirm at the plan gate).** Al (2026-10-29): keep everything while the modelling is young, keep it flexible across machines, be able to send any run to durable storage, and prefer small records whose provenance reaches back to link. Then, on reflection: overwrite with versioning rather than keep every run, because what is needed is the published run, the one it replaced and any candidate under review, while the per-rule scores and thresholds of every promotion are already in git. The proposal:
  - **Layout, one folder per thing compared side by side:** `tune/<key>/<break set>.<gradient>.<flow>/`, species first because the work goes one species at a time. Only inputs varied for comparison get a level; what the tuning chooses (width against flow, thresholds) is in the rule, and what identifies one run (link build, flow load, commit, run id) is in the record. Keys keep their existing case (`CH_rear`; 170 tracked files carry them); every new token is lowercase.
  - **Tokens from link's output vocabulary** (NewGraphEnvironment/link#414), which these paths wait on before the layout is final.
  - **Overwrite with versioning:** a re-run of the same combination overwrites its folder and the previous files stay as object versions; a lifecycle rule expires previous versions after about 6 months while the current copy never expires. Bucket versioning is currently Suspended and is bucket-wide (it would also keep old copies of the `rag/` stores), so turning it on, and its lifecycle rules, is Al's decision at the plan gate. The bucket already moves objects to Standard-IA after 30 days.
  - **A per-key record** beside each grade table: its run fields, row count and md5, each archived file's version id, the knowledge commit, link's run and config commit, wet's flow load, the walk md5 and the evidence md5. `0320` writes it and `0335` moves it; the bundles read and pin it, so a rebuild needs ~200 MB, not 26 GB, and it says whether the database can still recreate the run.
  - **A tracked run index,** one row per archived run (key, setup tokens, run id, date, promoted or not, path, version ids), so a run is found by reading a table, not the bucket.
  - **Archive any run with one command;** `0335` runs it on the promoted run. The evidence is stored once per build, not per run. The external drive is optional as a second copy, not the system.

## Proposed

- [ ] The per-key grade record, written by `0320` and moved by `0335`; `vignette_method.R` and `vignette_chinook.R` read and pin it instead of the grade tables; `test-vignette-data.R` holds it.
- [ ] An archive step for any run (grade tables at zstd-3, curves, records; the evidence once per build) into the layout above, recording each file's version id in the record and a row in the run index; `0335` runs it on the promoted run and refuses to finish if it fails.
- [ ] A restore (`PULL=TRUE`) that fills a worktree's ignored `data/` from the archive, by version id where given, and checks every md5.
- [ ] Seed the archive with the published build from the rescued copy, and prove it: a fresh worktree on the database's host restores it and rebuilds `method.rds` identical to the published bundle except its written date and commit.

Relates to #111 (promotion), #118 (the rename that met this), #76 (licences before anything goes public).




## Seed and proof (2026-10-30)

- **Seed.** m4 held all eight published grade tables (the seven `method.rds` pins plus underpowered WCT rearing);
  each matched its pin. zstd -3 on m4 with a decompress-and-md5 round trip: 28.1 GB to 1.54 GB, about 2 min on m4.
  Copied to m1 staging (`~/Projects/repo_aside/knowledge_seed_119/`, outside the repo), decompressed, every md5 equal
  to m4's. CH rearing's curve (`54ff646b…`) and segments (`1112dd31…`) matched `chinook_rearing.rds`'s pins.
  `data-raw/archive_seed.R` wrote eight `record_source = backfill` records (run `published_20261028`), each staged first
  row identical to the row rescued on 2026-10-29. The rescued evidence matched every pin (`sites.rds` against the
  ledger's `md5_sites`).
- **Archive.** `0336` from staging, `PROMOTED=TRUE`: 39 objects (8 keys × 4; 6 evidence files and the MANIFEST),
  3,213 MB stored (segments are not compressed: about 1.3 GB of it), evidence folder
  `63aa65a8404c7a212077828f559f9fef`, about 9 min over this link. Index: 39 `archived` and 8 `promoted` rows.
- **Proof (A1, A2).** Two worktrees at `1e7dbb8`: R filled by hand from staging (grade tables as hard links), W by
  `PULL=TRUE 0336` alone (no grade tables). `vignette_method.R` in each: **R and W identical in every element**. R
  against the published bundle (written 2026-10-28 at `9418f8c`): only `meta` differs, in exactly the four fields
  named in advance: `written`, `commit`, `md5` (gains the seven records; every shared entry equal), `md5_local` (loses
  the seven grade tables; every shared entry equal). `ledger`, `flow_load`, `wet_sha`, `link_config_sha` equal.
- **Tests in W** (restored evidence, no grade tables, the rebuilt `method.rds`): `[ FAIL 0 | WARN 0 | SKIP 1 | PASS 1752 ]`.
- **Chinook bundle in W** (`SCHEMA=fresh_default_20261017`): `bulk_segments.rds` and `bulk_water.rds` byte-identical;
  `chinook_rearing.rds` differs in `meta` (`written`; `md5` gains the CH rearing record) and in `surface$rate` by at
  most 1.2e-16, a last-bit difference through the curve's prediction (BLAS). Not committed: the bundle pins no grade
  table, so nothing #119 needs moves, and r-packages.md rebuilds a BLAS-touched bundle where it was built. It reads
  the record at its next rebuild (a promotion).
