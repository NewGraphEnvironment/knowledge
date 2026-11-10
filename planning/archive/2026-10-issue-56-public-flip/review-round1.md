# Code review, round 1: branch 56-clean-up-and-make-the-repo-public-packag

Reviewed the branch diff against its merge-base (renames detected), and read the changed scripts in full. Probes ran in the
scratchpad only. Nothing in the repo was edited except this file, and nothing was written to S3, a database or GitHub.

## Findings

- **[bug] scripts/wf_peace_report_harvest.js:12 and :38**: `const A` is now declared twice. The branch added
  `const A = typeof args === 'string' ? JSON.parse(args) : (args || {})` at line 12 so it could read `harvest_dir`, but
  the original declaration at line 38 is still there. The script no longer parses: `node --check` gives
  `SyntaxError: Identifier 'A' has already been declared` at line 39 of the probe copy (a 3-line stub of `args`, `phase`
  and `agent` was prepended). The main version gets past that point and fails only at its top-level `return`, which the
  workflow runtime allows. So the Peace harvest workflow cannot run at all. Fix: delete lines 37–38 (the comment and the
  second `const A`).

- **[bug] scripts/0230-fdis-load.R:65-67**: the `NO_SIGN=TRUE` path cannot work. `aws s3 sync s3://fresh-bc/fdis/`
  always lists its source (ListObjectsV2). An internal issue, the bucket-policy change this relies on, explicitly grants "No
  ListBucket in prefix mode", and the bucket refuses anonymous listing today:
  `aws s3 ls s3://fresh-bc/fdis/ --no-sign-request` returns AccessDenied on ListObjectsV2. An already-public prefix does
  the same: anonymous `?list-type=2&prefix=discharge/` returns 403, while `discharge/fwa/v1/manifest.json` returns 200.
  So once `fdis/` is public, a reader without credentials still fails at the sync and gets "aws s3 sync failed". The
  comment ("NO_SIGN=TRUE reads the public prefix without AWS credentials") and the plan review's G14 disposition both
  say this works. To work without credentials, 0230 has to fetch `MANIFEST.md5` and then `aws s3 cp` (or curl) each
  path it lists, the same way 0299's `PULL` reads its manifest. `0299 PULL=TRUE NO_SIGN=TRUE` itself is fine, because
  it fetches only exact keys.

- **[fragile] scripts/0299-fdis-publish.R:186-189**: nothing enforces the "a change to a table's columns or meaning is
  a new version, never an overwrite of v1" rule (header line 12, also in CLAUDE.md). Every `PUBLISH=TRUE` writes over
  `s3://fresh-bc/knowledge/fdis/v1/` whatever the tables now contain. Example: 0294 or 0296 gains or renames a column,
  someone re-runs 0299, and v1 changes shape under consumers who pinned it. A cheap guard: before uploading, fetch the
  published `manifest.json` and stop if any table's column names or types (or `columns`) differ, unless `s3_id` was
  bumped.

- **[fragile] planning/active/public_sweep.py:50-53**: `tree()` skips any tracked file that does not decode as UTF-8,
  silently. That is 31 tracked files outside `planning/` and `scripts/logs/`: 27 `.gpkg` and 4 `.png`. The gpkg files
  carry free-text attribute columns (0162 copies the farmed notes into `rag_priorities.gpkg`), so a sweep reporting "no
  hits" never looked at them. That fails toward pass. Measured now: running the sweep's patterns over the gpkg and kml
  bytes (latin-1 decode, `63333` excluded) finds nothing. The only raw `63333` hits are inside numbers such as
  `6333333`. So nothing leaks today. To close the gap, scan bytes (`open(f, "rb").read().decode("latin-1")`) instead of
  skipping.

## Checked and not a problem

- Ran `0299` local-only in a scratch git copy with the real `data/fdis/derived/*.csv`: all 5 tables pass the
  value-level read-back, and `ch_rule_visits.hydro_zone` is kept as text.
- PULL round-trip: Parquet, then `write_csv_arrow`, then each downstream `read_csv` call with its own `col_types` and
  `guess_max`. Types are identical in all 5 tables. Numeric values differ by at most 1 ulp (max relative 2e-16, for
  example `7886.4000000000005` against `7886.400000000001`). The cause is the parsers: arrow parses 17-digit text
  exactly, and R's `as.numeric` and readr do not (`as.numeric("7886.4000000000005")` prints `7886.3999999999996`). So
  the Parquet holds the original doubles, and the restored CSVs match the originals as readr reads them except in the
  last bit. Every double-keyed join I found (0298's visits-to-walks join on `downstream_route_measure`) reads both sides
  from pulled files, so the join stays consistent. Not a bug. But "equal as readr reads them" in progress.md holds only
  with a tolerance.
- Removing the database fallback in 0200, 0220 and 0162 is intended. `db_source` is set to `NA_character_` before
  0220's clip block and to the database name inside it. Nothing reads the old `tunnel` and `local_fwapg` values
  anymore.
- 0298 creates `ch_rule_scratch` only after `fresh_default.streams_habitat_ch` has been queried, so a wrong `PG*`
  target fails before any DDL runs.
- PSOCK workers in 0294, 0296 and 0298 inherit `PGSERVICE` from the parent, so they use the same database as the
  master under the documented ways of selecting it.
- Moving the package: no `R/` or `tests/` file depends on the old `pkg/` relative paths. `test-data-dir.R`'s
  `test_path("..", "..", "data")` resolves to the repo's `data/` under `devtools::test()` and skips under
  `R CMD check`. `data/` currently has no top-level `.R` or `.rda` files.
- pkgdown: the local `docs/` has exactly the expected top-level pages (404, authors, index, LICENSE-text, as .html and
  .md). `search.json` indexes only home, authors, news and reference pages, and `articles/` is empty.
- 0153 and 0270: the key is read once at import of 0153, which 0270 loads as a module. The env-only change applies to
  both.

planning/active/review-round1.md
