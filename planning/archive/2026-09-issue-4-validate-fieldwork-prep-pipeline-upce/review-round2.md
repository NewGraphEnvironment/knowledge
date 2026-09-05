# Review round 2 — staged diff (pkg/ carve-out, 0150-store.R, guarded scripts, README)

Scope: `git diff --cached` (31 files). pkg/R/pscis.R and pkg/R/gnis.R compared line by line
against `HEAD:scripts/0100-pscis-acat-reports.R` and `HEAD:scripts/0110-gnis-collision-check.R`;
0150-store.R checked against `cred/R/store.R` (crd_store_connect / crd_search / crd_store_build /
crd_store_push signatures and the `<dir>/<name>.duckdb` naming); path moves in 0154/0156/0161/0162
checked against `git ls-files data`.

## Findings

- **[bug]** data/pine/context_pine.md:78 — the documented query command is
  `WSG_TARGET=peace QUERY="..." Rscript scripts/0150-store.R (ACTION=query)`. `0150-store.R`
  does not read `WSG_TARGET`; it requires `STORE` (`stopifnot("STORE=<name> is required" = nzchar(store))`
  at scripts/0150-store.R:34). Run as written it aborts. Should be `STORE=peace QUERY="..." Rscript scripts/0150-store.R`
  (ACTION defaults to query). Round 1 flagged the stale `0155` reference on this line; the replacement
  carried the wrong variable over.

- **[fragile]** pkg/R/gnis.R:49-50 — NA handling drifted from the original SQL. The original used
  `count(DISTINCT watershed_group_code)` and `string_agg(DISTINCT ...)`, both of which ignore NULL.
  The port computes `n_wsg = dplyr::n_distinct(.data$watershed_group_code)` (default `na.rm = FALSE`,
  so NA counts as a group — measured `n_distinct(c("A", NA))` is 2) while `wsgs = paste(sort(unique(...)))`
  drops NA (`sort()` default). On any table with a NULL `watershed_group_code` for a seed name, a
  single-group name reports `n_wsg = 2`, `wsgs = "PINE"`, `wsg_only = TRUE` — and 0110's summary
  (`sum(amb$n_wsg==1)`) counts it as ambiguous while `wsg_only` says safe. `bcfishpass.streams`
  carries no NULL codes, but the function accepts any `table` and 0110 falls back to the first
  `information_schema` hit when `bcfishpass.streams` is absent. Fix: `n_distinct(..., na.rm = TRUE)`
  or filter `!is.na(watershed_group_code)` before the summarise, so the two columns agree with each
  other and with the original.

## Checked, not an issue

- pscis.R vs original 0100: column set for `crossings` identical; `%||%` empty-layer case reproduced by
  `ids()` (missing layer or missing `stream_crossing_id` column both yield `integer()`); `first_col`
  pattern logic identical; `report_id` via `str_match()[,2]` equals `str_extract |> str_remove` (NA on
  non-match in both); filter-before vs filter-after `bind_rows` gives the same groups; `year` is double
  in both (lubridate::year returns numeric); `arrange` keys identical. New behaviours are all
  fail-loud additions: POINT-count guard, `sf` class guard, typed empty `reports` (the original
  `group_by` would have errored on a zero-column `imap_dfr` result), and `st_read` errors now
  propagate instead of being logged and the layer dropped.
- `DBI::dbQuoteIdentifier(conn, DBI::Id(schema=, table=))` produces the same `"schema"."table"` as the
  original `glue_sql {`schema`}.{`table`}`; `wsg_code` goes through `dbQuoteString` as before. The
  `table` argument in `knw_gnis_collisions` is interpolated raw exactly as the original script did
  (identifier, sourced from information_schema in 0110) — unchanged surface.
- gnis ordering: `arrange()` sorts in the C locale where the original relied on the DB collation.
  Verified against the committed `data/pine/gnis_seed_ambiguity.csv`: 43 rows, order identical under
  both C and case-insensitive ordering, no names with apostrophes/hyphens. Latent only for names that
  collate differently (`O'Brien` vs `Oak`); noting, not reporting.
- `not_found` attribute: same `setdiff(seed, found)` as the original message; survives to 0110's
  `attr(amb, "not_found")`; `write_csv` ignores it as intended.
- Zero-length: `seed` empty short-circuits before the `IN (%s)` is built (an empty IN would be a SQL
  error); `knw_pscis_reports` on a 0-row layer recycles length-1 columns to 0 rows without error.
- `$` partial match: every `$` in pkg/ and 0150 is on an exact existing column (`res$collection`,
  `dup$n`, `d$stream_crossing_id` behind an explicit `%in% names(d)` check).
- `.data` pronoun: `@importFrom rlang .data` present in R/knowledge-package.R and NAMESPACE.
- DESCRIPTION Imports (chk, DBI, dplyr, lubridate, rlang, sf, stringr, tibble) match every `pkg::`
  used in R/. `duckdb` and `RPostgres` are Suggests: RPostgres appears only inside `\dontrun{}`;
  the `knw_gnis_collisions` example calls `duckdb::duckdb()` unguarded, so `R CMD check` would error
  on a machine without duckdb installed — passes here and under any CI that installs Suggests.
- Formal arg `names` in `knw_gnis_collisions` shadows base `names()`; the body never calls `names()`
  so it cannot misresolve. Naming only.
- 0150-store.R: `store_path` (`data/rag/<STORE>.duckdb`) matches what `crd_store_connect(store, dir=)`
  resolves (`file.path(dir, paste0(name, ".duckdb"))`), so the round-1 unverified-open guard keys on
  the right file. `crd_store_build(store_path, citation_keys=, overwrite=)`, `crd_search(store, query,
  top_k=)`, `crd_store_push(store_path, dry_run=)` all match cred 0.3.0 signatures. SQLite quoting in
  `collection_keys` (`''` doubling) is correct for SQLite; the deletedItems exclusion and duplicate-name
  refusal from round 1 are in place. `.Rprofile` (tracked) sets `cred.store_source`.
- 0153: `sys` is imported; empty env var falls through to the file; empty file exits.
- Path moves `data/planning/*` -> `data/*`: `zotero_key_map.csv`, `priority_farmed_all.csv`,
  `corpus_tags.csv`, `rag_priorities.gpkg`, `rag_priorities.kml` are all tracked at `data/`;
  no script still references `data/planning`; README's "tracked" claim for the gpkg is correct.
- No client/project identifiers in pkg/ or its tests (only WSG codes, a `localhost:63333` tunnel
  example and the `newgraph` DB user inside `\dontrun{}`, in a private repo).
- No reference to the deleted 0151/0155/0157 remains outside planning archives, round-1 notes and
  the accepted NEWS-style mentions in 0150-store.R's header.
