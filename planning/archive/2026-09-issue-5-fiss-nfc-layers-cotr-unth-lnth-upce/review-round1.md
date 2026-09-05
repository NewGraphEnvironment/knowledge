# Code-check round 1 — staged diff (0200 / 0210 / 0220 + data/pine CSVs)

Reviewed the index state (`git show :scripts/...`), which at review time equalled the
working tree for all three scripts. Note the index for `0200` moved during the review
(the `xml2::read_html(url)` loop was replaced by a `curl::curl_fetch_memory` loop with
`http_4xx` statuses); findings below are against the curl version.

Probes run from files under the scratchpad (`probe.R`, `probe2.R`) — the zero-row
pipeline was reproduced with the script's own `gather_step` fill and its own
`step2_site` / `step1_site` / `step4_site` / `sites` code, verbatim.

## Findings

- **[bug]** `scripts/0220-fiss-xls-parse-nfc.R:232-239` (`gather_step`) with
  `:262-334` — **a step with zero rows in every workbook aborts the run with a vctrs
  type error, and the comment on `gather_step` says the opposite.** The fill
  `res[[cc]] <- logical(0)` makes every column of an empty step *logical*. That does
  get past `group_by()`, which is all the comment claims, but the very next operations
  are typed:
  - step4 empty (the plausible case — a group whose submissions carry no Stream Site
    sheet): `full_join(step4_site, by = "site_key")` →
    `Can't join x$site_key <character> with y$site_key <logical>`.
  - step2 empty: `coalesce(species, "")` →
    `Can't combine ..1 <logical> and ..2 <character>` (line 268).
  - step1 empty: same join error, from the other side.
  - all three empty: the coalesce error.
  Reproduced all four with the script's own code. This is "a fixture that cannot reach
  the failure mode": PINE and COTR both populate all three steps, so the regression
  run could not see it. The failure is loud, but it lands *after* `fiss_xls_parse_log.csv`
  is written and before sites/reconcile, and it exits with a message that reads as a
  join bug rather than "this group has no Step 4 data". Fix is to give the empty
  prototypes their real types (`character(0)` for `site_key`, `report_id` and the key /
  text columns; the numeric ones can stay `logical(0)` since `num()` coerces), or to
  build `res` from a typed zero-row template rather than patching columns on.
  Same family, one more case: `flog` with zero parseable rows (every fetch
  `unreadable`/`download_failed`) makes `parse_log` a 0x0 tibble, `write_csv` writes a
  **zero-byte** `fiss_xls_parse_log.csv`, and `group_by(report_id, path)` at line 250
  then errors "must group by variables found in .data". The empty file left behind
  reads downstream as "no workbooks". Guard `nrow(flog) == 0` explicitly before parsing.

- **[fragile]** `scripts/0220-fiss-xls-parse-nfc.R:343-347, 425-433` vs `:442-478` —
  **the reconcile gate runs after every deliverable has been written.** `_all.csv`,
  `fiss_step2_fishcoll_*.csv`, the clipped `.csv` and the `.gpkg` are all on disk before
  a single check is evaluated, so a failing run leaves fresh, wrong-looking-right
  artifacts with new mtimes; the only difference from a passing run is the exit code and
  the `pass` column of `fiss_xls_reconcile.csv`. The two restore-the-defect tests
  confirmed the exit code, not that the deliverables were withheld. Related: nothing
  removes a previous run's `fiss_xls_reconcile.csv` at start, so a run that aborts
  earlier (the both-DBs-down `stop()` at 421, or the type error above) leaves last
  run's `pass=TRUE` table beside the new partial outputs. The first three checks
  (manifest ↔ fetch log ↔ parse log) depend on nothing written after line 245 and can be
  evaluated before the site writes; the rest can gate a rename from temp paths. At
  minimum `unlink()` the reconcile CSV at the top of the script.

- **[fragile]** `scripts/0220-fiss-xls-parse-nfc.R:463` —
  `chk("utm_zone_non_numeric", 0L, n_zone_nonnum, pass = TRUE)` is an assertion-shaped
  row that cannot fail: `expected = 0`, `pass` hardwired TRUE. On a group with `"10U"`
  zones the table will read `expected 0, actual 12, pass TRUE`, which contradicts itself
  and hides the one dropped-site path the message at 258 warns about. Either
  `expected = NA` (informational, like the other `pass = TRUE` rows) or
  `pass = n_zone_nonnum == 0L`. Decide which; the current form is neither.
  Same shape, lower stakes, at `:465-466`: `placed_le_with_coords` and
  `clipped_le_placed` compare a filter of `sites` with `sites` and a subset of
  `sites_sf` with `nrow(geo)` — same population, strict subset by construction, so they
  are tautologies. The one thing in that chain that *could* drift is `place()`
  (the per-zone `group_split`/`rbind`), and `n_placed <- nrow(geo)` is taken *before*
  `place()`, so it is not measured. `n_pre == n_placed` (line 399 vs 365) is the
  assertion that carries information.

- **[fragile]** `scripts/0220-fiss-xls-parse-nfc.R:446-454` —
  `manifest_urls_vs_fetch_log_rows` compares `length(unique(manifest$xls_url))` with
  `nrow(fetch_log)`: a count standing in for set identity. A manifest re-enumerated
  after ACAT changed a page (one attachment replaced by another, same count) passes
  against a fetch log built from the old manifest. `0210` now writes `xls_url` into the
  fetch log precisely so this join is by key, but the check does not use it. The staged
  PINE data shows the gap: `data/pine/fiss_xls_fetch_log.csv` (tracked, not re-fetched)
  has **no `idx`/`xls_url` columns** and the staged `fiss_xls_parse_log.csv` paths are
  the pre-idx `16005__Favels...` layout — and the reconcile passes 12/12 because it
  only counts. `setequal(manifest_urls, flog_all$xls_url)` when the column is present
  (falling back to the count with a note when it is absent) makes the check mean what
  its name says; otherwise rename the check to what it measures.

- **[fragile]** `scripts/0200-fiss-xls-enumerate.R:151-158` (index version) — on the
  "no .xls attachments" path nothing is written *and nothing is removed*, so a
  `fiss_xls_manifest.csv` from an earlier run survives. The same holds on the
  `fetch_failed` `stop()` at 145. The reports file is rewritten every time, so
  `fiss_xls_reports.csv` can say `n_xls = 0` everywhere while a stale manifest beside it
  lists 30 attachments that `0210`/`0220` will keep consuming — and the reconcile at the
  other end passes, because manifest and fetch log are both stale together. The realistic
  trigger is a report page going `http_403` (ACAT hides it) or a fallback run on
  `local_fwapg` returning fewer pages. `unlink()` the manifest on the empty path (and
  leave it on the stop path, since that run is loudly incomplete).

- **[fragile, low]** `scripts/0220-fiss-xls-parse-nfc.R:203, 223` —
  `as.character(report_id)` on the double that `read_csv` produces gives `"1e+05"` for
  `100000` (and `2e+05`, `1e+06`, ...): `report_id`/`site_key` in the parse log and site
  tables would then not join to the manifest. Verified `as.character(100000)` → `1e+05`;
  `write_csv` itself is fine (writes `100000`). Only round ids hit it, and ACAT is at
  ~57k, so this is latent, but the fix is one line: read `report_id` as character in
  `flog` (`col_types = cols(report_id = col_character())`), which is what the manifest
  already carries.

## Checked and clean

- `stopifnot(setequal(...))` in 0210: `manifest` is `distinct(xls_url)` and the log is
  one row per manifest row via `pmap_dfr`, so equal `nrow` + `setequal` cannot be
  satisfied by a duplicated URL on either side.
- `map_dfr(pages, "links")` with every `links = NULL` → 0x0 tibble, `!nrow()` branch;
  `map_int(... nrow(.x$links))` returns integer; `report_ids = character(0)` gives a
  0-row `reports` tibble and an empty status summary without error.
- Zone-shift probe: `alt` is filtered to `utm_zone %in% 8:11` before `place()`, an empty
  `alt` is skipped, both frames are EPSG:3005 at `st_intersects`, and a row cannot land
  inside under both `dz = -1` and `dz = +1`.
- `wb_status` / `wb_no_step` / `n_zone_nonnum` / `n_placed` / `n_clipped` /
  `n_outside_zone_swap` / `db_source` are all bound before the `if (nrow(geo))` branch,
  and every `chk()` call with an `NA` expected value passes `pass=` explicitly, so
  `all(reconcile$pass)` cannot be `NA` on the `nrow(geo) == 0` path.
- `parse_log_rows_vs_3_per_workbook` and `fetch_parseable_vs_parse_log_workbooks` fail
  loudly on a duplicated `parse_path` (n_distinct drops below rows/3).
- 0200 curl loop: a 4xx breaks on the first attempt and is recorded, a 5xx or transport
  error is retried once and becomes `fetch_failed`, which stops the run; only
  `fetch_failed` gates, by design.
