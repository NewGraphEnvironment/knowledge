# Code-check round 2 — staged `scripts/0200`, `0210`, `0220`

Reviewed the STAGED diff (`git diff --cached -- scripts/`) plus all three scripts in
full, against the thirteen mechanisms in "Code Check Conventions" and the shell traps.
Note: `0220` has an unstaged follow-on edit on disk (`zone_num()`, "11U" handling); it is
not part of this review.

## Findings

No crash-class bug on any path that stage A can pass. Four fragile points, all of the
"guard that fails toward pass" / "written data outlives the fix" families, and one
pre-existing note outside the diff.

### 1. [fragile] `scripts/0200-fiss-xls-enumerate.R:65-75` — the tunnel fallback swallows *why* the tunnel failed, so an auth failure degrades silently to a snapshot known to be short

`tryCatch(dbConnect(tunnel), error = function(e) NULL)` treats "connection refused"
(tunnel down) and "password authentication failed" (tunnel up, `PGPASSWORD` empty)
identically. CLAUDE.md documents the second as a live trap on this machine (a project
`.Renviron` empties `PGPASSWORD`; `~/.Renviron` line 84 is where it is set). Before this
diff that misconfiguration made `0200` fail loudly; after it, `0200` runs to completion
on the local fwapg whose FISS snapshot the header itself says is missing 5 report ids
across COTR/UNTH/UPCE. `db_source = local_fwapg` is recorded, but nothing downstream
reads it (see 3), and the message never shows the error text, so the operator cannot
tell a down tunnel from a bad credential.

Cheap fix: capture the condition and print it —
`err <- NULL; conn <- tryCatch(..., error = function(e) { err <<- conditionMessage(e); NULL })`
and include `err` in the fallback `message()`. Optionally only fall back when the message
matches connection refused / could not connect, and `stop()` on anything else.

### 2. [fragile] `scripts/0200-fiss-xls-enumerate.R:113-123` — 408 and 429 are classified as deterministic `http_4xx`, not retried, and do not stop the run

The retry loop breaks on any `status_code < 500`, and the comment justifies "recorded and
NOT retried" for 4xx because they are deterministic. 429 (rate limit) and 408 (request
timeout) are not; the script hits ACAT 40-60 times back-to-back with no delay, which is
exactly where a 429 appears. Either lands as `http_429` in `fiss_xls_reports.csv`, the
manifest is short by that page, and the `fetch_failed` gate never fires. The four groups
run so far show only 403s, so this is latent rather than observed.

Fix: treat `status_code %in% c(408, 429)` like a 5xx in the loop (retry, then
`fetch_failed`).

### 3. [fragile] `scripts/0200:146-150` + `scripts/0220:265-296` — the enumerate→manifest link is the one link the reconcile chain does not check

Two halves of one gap:

- `0200` unlinks a stale manifest on the no-attachments path (line 155) but not on the
  `fetch_failed` `stop()` path (line 146). A manifest from an earlier successful run
  survives beside a `fiss_xls_reports.csv` that says `fetch_failed`.
- `0220` stage A reconciles manifest ↔ fetch log ↔ parse log, but never reads
  `fiss_xls_reports.csv`. So a manifest that is stale relative to the reports file (either
  half above, or a `local_fwapg` fallback per finding 1) passes every check, because the
  fetch log was built from that same stale manifest — one fact derived once and compared
  with itself.

Fix in `0220` stage A, two rows from a different producer:
`chk("reports_n_xls_vs_manifest_rows", sum(reports$n_xls), length(manifest_urls))` and
`chk("report_pages_fetch_failed", 0L, sum(reports$page_status == "fetch_failed"))`.
Read the reports file with `report_id = col_character()` for consistency, and treat a
missing reports file as a fail (an old `0200` output predates it, and the manifest-only
path is what this check exists to close).

### 4. [fragile, pre-existing branch] `scripts/0220-fiss-xls-parse-nfc.R:475-478` — the no-placeable-sites branch leaves an earlier run's `.gpkg` in place, and the reconcile passes

On `nrow(geo) == 0` the script writes `fiss_sites_<wsg>.csv` and skips the gpkg, but
does not `unlink()` it. A group that placed sites on a previous run and places none now
(re-fetch, changed manifest, a coordinate column that stopped parsing) ends with a fresh
CSV, a stale gpkg the header comment says the CSV "mirrors", and a green
`fiss_xls_reconcile.csv` — `placed_rows_vs_geometry_rows` is 0 == 0. The branch predates
this diff, but the diff is what added the stale-artifact discipline (`unlink` of the
reconcile file and manifest), and this is the same class. One line:
`unlink(file.path(out_dir, paste0("fiss_sites_", wsg_lower, ".gpkg")))` in the else
branch. Also on this branch the WSG-stamped `.csv` is the *unclipped* table (identical
to `_all.csv`); harmless today since nothing in it has coordinates, but worth a note in
the message.

### 5. [note, outside the staged diff] `scripts/0210-fiss-xls-fetch.R:84-90` — `convert_xlsx()` blesses a stale converted file

`file.exists(out)` after `soffice` cannot distinguish "converted just now" from "left by
an earlier run". If the manifest order ever changes, `idx` shifts, and a stale
`<report>_<idx>__<name>.xlsx` can belong to a *different* attachment; a conversion that
fails today then returns that file with status `converted` and `parse_path` pointing at
the wrong workbook. `unlink(out)` before `system2()` closes it. Not in the diff; flagged
because it is the same verification-reads-its-own-output shape as finding 3.

## Focus questions from the brief — checked, no defect

- **Stage A / stage B unbound variables.** Every name stage B reads (`reconcile_a`,
  `n_zone_nonnum`, `site_keys`, `sites`, `n_placed`, `n_geom`, `n_withcoord`,
  `n_clipped`, `n_outside_zone_swap`, `db_source`) is bound at lines 407 and 414 before
  the `if (nrow(geo))` branch, and the only unbound exit inside the branch is a `stop()`.
- **`n_geom` on `nrow(geo) == 0`.** `n_geom = 0L`, `n_placed = nrow(geo) = 0`; the check
  passes correctly. On the placed branch `n_geom = nrow(place(geo))` is the post-rbind
  count, which is the quantity the check names.
- **`character(0)` fill vs `num()` / `first(na.omit()) %||% NA`.** `num(character(0))`
  is `numeric(0)`; zero-group `summarise` slices every expression to length 0, so
  `-Inf` from `max()` and `""` from `paste()` never materialise; `dplyr::first()` on an
  empty `na.omit()` returns a typed NA and the redefined `%||%` returns the typed default.
  The `full_join`s on `site_key` see character on every side. A step with rows but a
  column absent from every workbook gets `NA_character_` (or the logical `NA` from
  `select_wanted`), which vctrs treats as unspecified and casts; `coalesce(species, "")`
  is fine on either.
- **`flog_all` vs `flog`.** `flog_all` (every fetch row) is used for the manifest
  comparison; `flog` (parseable only) for the parse-log comparison. That is the right
  pairing; `parse_path` is unique per row by construction of `local_name()`, so
  `n_distinct(parse_log$path) == nrow(flog)` holds on healthy input.
- **`col_types` with `.default = col_guess()`.** Valid readr usage; `report_id` stays
  character in `0210` and `0220`. The manifest re-read at `0220:268` uses no spec, but
  only `xls_url` is taken from it. (If finding 3 is adopted, the reports file needs the
  same `report_id = col_character()`.)
- **`unlink()` of the reconcile file at the top of `0220`.** `out_dir` is
  `data/<wsg_lower>/`, so it can only remove the same group's previous table. It runs
  before the fetch-log `stopifnot`, which is correct: an aborted run should leave no
  reconcile file. Evidence of a *failed* stage A is preserved by the explicit write at
  line 292.
- **`chk()` default `pass = expected == actual`.** Every row with `expected = NA` passes
  `pass = TRUE` explicitly, so `all(reconcile$pass)` cannot be NA and the `if (!all())`
  cannot throw "missing value where TRUE/FALSE needed".
- **`bind_rows(if ... else ...)` at `0220:276-281`.** `else` on its own line is legal
  inside a call's parentheses; it ran on four groups.
- **Shell/heredoc/sed traps.** None apply; no shell in the diff.

## Verdict

No blocking defect. Findings 1-3 are one cluster (the enumerate step can now be short
in three ways — auth-degraded source, transient 4xx, stale manifest — and nothing
downstream can see any of them). Finding 3's two reconcile rows would close all three
at the gate; findings 1 and 2 make the cause visible at the source.
