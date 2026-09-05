# Code-check round 3 — staged `scripts/0200`, `0210`, `0220`

Scope: the changes since round 2 (`zone_num()`, the tunnel error-text classifier, 408/429
retry, manifest unlink on the `fetch_failed` stop, stage-A reads of `fiss_xls_reports.csv`,
`.gpkg` unlink on the no-placeable branch, `convert_xlsx()` unlink) and the mechanism
behind any remaining way the enumerate→manifest→fetch→parse chain can be short with every
stage-A row green. Working tree equals the index for `scripts/`. Probes ran from
`scratchpad/probe3.R`; the ACAT checks were live `curl`s on 2026-09-04.

## Findings

### 1. [fragile] `scripts/0220-fiss-xls-parse-nfc.R:286-312` with `scripts/0210-fiss-xls-fetch.R:101-105` — a `download_failed` fetch-log row shortens the chain and no stage-A row can see it

This is the answer to the brief's first question, and it is not latent: it is in the
tracked data.

Stage A compares the manifest to `flog_all` (every fetch row, by URL set) and the parse
log to `flog` (rows with a `parse_path`). A row whose download failed is present in the
first comparison and absent from the second, and nothing measures the difference:

| group | fetch log | reconcile row `manifest_urls_vs_fetch_log_urls` | `fetch_parseable_vs_parse_log_workbooks` | verdict |
|---|---|---|---|---|
| LNTH | 55 ok/converted, **1 download_failed** | 56 = 56 | 55 = 55 | 15/15 pass |
| UNTH | 37 ok/converted, **1 download_failed** | 38 = 38 | 37 = 37 | 15/15 pass |

`data/lnth/fiss_xls_reconcile.csv` and `data/unth/fiss_xls_reconcile.csv` are the committed
evidence: each has a workbook missing and no row names it. The 56→55 is recoverable only
by subtracting two rows by hand.

Both failed rows are `reportId` 58437 and 58486, and both URLs are the only two in any
fetch log containing `;` in the path (`...Tributary;2019;KA19-52137_...xls`). Measured
today: HTTP 404 raw, HTTP 404 with `;` encoded as `%3B`, while the report page itself is 200
and lists the link verbatim. So these two are permanent (ACAT lists an attachment it does not
serve), which is the deterministic-4xx case the 0200 design records without stopping.

The gap is that `0210` cannot tell that case from a transient one. `fetch_one` swallows the
condition (`error = function(e) FALSE`) and records the bare status `download_failed`; a
tunnel drop or an ACAT outage mid-run lands as the same row, with no retry and no stop. That
is the shape round 2 fixed in `0200` (finding 2: transient recorded as deterministic) one
script downstream, and the round-2 stage-A rows close the 0200→manifest link without
closing the manifest→fetch link.

Fix, in two halves, mirroring `0200`:

- `0210`: keep the condition message. `download.file(method = "libcurl")` errors with the
  status in the text (`HTTP status was '404 Not Found'`), so classify `http_4xx` from it,
  and treat a transport error / 5xx as `fetch_failed` after one retry, then `stop()` — same
  vocabulary as `0200`. Write the message into a column of the fetch log.
- `0220` stage A: one row from the fetch log's own status column, which no other check
  reads —
  `chk("fetch_download_failed", 0L, sum(flog_all$status == "download_failed"), note = <ids>)`
  failing, or, once `0210` distinguishes them, `http_4xx` informational (`pass = TRUE`,
  ids in the note) and `fetch_failed` failing. An informational `fetch_unreadable` row
  beside it makes the encrypted-and-unconvertible count visible for the same reason.

Until the `0210` half lands, the failing row is the right default: the two known cases are
permanent, but the row is the only thing that would ever show a transient one.

### 2. [fragile, low] `scripts/0220-fiss-xls-parse-nfc.R:299-303, 525` — the enumerate step's `db_source` is written but never read

`fiss_xls_reports.csv` carries `db_source` precisely so "a short manifest is explainable"
(`0200:63-64`), and the tunnel is primary because the local snapshot is known to be short
(five report ids across three groups). Stage A now reads the reports file but takes only
`n_xls` and `page_status`; the reconcile's `clip_polygon_source` row is `0220`'s *own*
connection, not `0200`'s. A `local_fwapg` enumerate run therefore leaves a tracked reconcile
table identical to a tunnel run, and the only signal is a `message()` in a log nobody reads
under Always Away. One informational row from the reports file
(`chk("enumerate_db_source", "tunnel", paste(unique(reports$db_source), collapse = "|"), pass = TRUE)`)
puts it in the artifact. All five tracked groups are `tunnel`, so nothing is wrong today.

## Focus questions from the brief — checked

**Does `zone_num()` change behaviour for a value `num()` handled correctly?** No, for any
value that is a valid zone. Measured (`probe3.R`):

| input | `num()` | `zone_num()` | placed before → after |
|---|---|---|---|
| `"10.0"`, `" 11 "`, `"9"`, `"10"`, `10`, `10L`, `"010"` | 10 / 11 / 9 / 10 / 10 / 10 / 10 | identical | same |
| `"11U"`, `"10 U"`, `"zone 11"`, `"Zone10N"` | NA | 11 / 10 / 11 / 10 | not placed → placed (the intended recovery) |
| `"10/11"` | NA | 10 | not placed → placed in zone 10; the WSG clip disposes of it if 11 was meant |
| `"10.5"`, `"-10"` | 10.5 / -10 (fail `%in% 8:11`) | 10 | not placed → placed |
| `"NAD83 10U"` | NA | 83 | not placed either way; now counted as out-of-range rather than non-numeric, so it moves from the `utm_zone` message to the `out-of-range UTM` message |
| `"1e1"` | 10 | 1 | placed → not placed |

The behaviour changes are confined to shapes that were unplaceable before and are not how a
zone is entered in a spreadsheet (`"10.5"`, `"-10"`, `"1e1"` cannot come out of `readxl` for
an integer cell — `as.character(10)` is `"10"`). `"10/11"` is the one plausible entry that
now places silently, and it places in the first-listed zone with the clip as the backstop.
Not a defect; recorded so the next person does not re-derive it. The regex takes the
*first* digit run, not the leading one, which is what makes `"zone 11"` work and
`"NAD83 10U"` give 83 — both end up correct or dropped, never mis-placed.

**Does the tunnel classifier stop on a case that should fall back?** Not on this machine.
The tunnel was up during the probe, so the closed-port text was measured on port 1 through
the same libpq path:

```
connection to server at "localhost" (::1), port 1 failed: Connection refused
	Is the server running on that host and accepting TCP/IP connections?
connection to server at "localhost" (127.0.0.1), port 1 failed: Connection refused
```

`grepl(..., ignore.case = TRUE)` matches → falls back. Pre-14 libpq wording
(`could not connect to server: Connection refused`) is covered by the second alternative;
a TCP timeout on macOS is `Operation timed out` and matches `timed out`. The one
tunnel-is-the-problem case that stops rather than falling back is an ssh forward that
accepts the TCP connection and then closes it because the remote side is down — libpq
reports `server closed the connection unexpectedly`, no alternative matches, and the script
stops with the text printed. That is the accepted safe direction, and the message says why.
`tunnel_err` cannot be `NULL` at line 74: `conn` is `NULL` only via the handler that sets it.

**Any other way the chain is short with stage A green?** After finding 1, the only
remaining shape is a report page that returns 200 and is not a report page (maintenance or
interstitial), which lands as `no_xls` and is consistent everywhere downstream. Measured
today: real pages carry `<TITLE>Aquatic Report Catalogue</TITLE>` and a `Report ID` label; a
non-existent id (`99999999`) returns **403**, not a 200 error page, so ACAT does not
currently produce the degraded-200 shape. Not flagged; if it ever does, the cheap positive
control is asserting the title before classifying `no_xls`. The `no_xls` classification
itself was checked against page 1157 (26 attachment links — dgn/e00/mdb/pdf/txt/zip, no
Excel variant the `\.xls[x]?$` regex misses).

**Other checks on the round-3 changes, clean:**

- `0200:154-160`: the `fetch_failed` stop unlinks the manifest *after* the reports file is
  written, so `0220` sees a reports file saying `fetch_failed` and no manifest; both
  `report_pages_fetch_failed` and (if an old fetch log exists) `manifest_urls_vs_fetch_log_urls`
  fail. A successful re-run of `0200` rewrites both. Nothing is left half-updated.
- `0200:123`: 408/429 fall through to the retry and become `fetch_failed`; a 3xx is resolved
  by `followlocation` before the status is read; a 5xx on the second attempt is discarded
  (`resp <- NULL`) rather than recorded as `http_5xx`.
- `0220:299`: `sum(reports$n_xls)` vs `length(unique(manifest$xls_url))` differ only when one
  attachment URL is linked from two report pages. Zero duplicates across the five tracked
  manifests (251 rows, 251 unique), and attachment paths carry the report id (`/rN/`), so it
  is not a live false-fail; if it ever fires, it fires loud.
- `0220:280-282, 295-297`: a missing reports file fails stage A (`pass = FALSE`); an empty
  one (no report ids) reads as a 0-row tibble and sums to 0. `report_id` is read as
  character, consistent with the manifest and fetch log.
- `0220:320-323`: `zone_raw` on a zero-row step is `character(0)`; `zone_num(character(0))`
  is `numeric(0)`; the count is 0. `zone_num(NA)` and `zone_num("")` are `NA`.
- `0220:374`: `zone_num` runs before the `across(..., num)` that excludes `utm_zone`, so the
  column is numeric once, never coerced twice.
- `0220:498-503`: the `.gpkg` unlink is in the branch that writes no gpkg; the placed branch
  overwrites via `delete_dsn = TRUE`.
- `0210:84-94`: `unlink()` before `soffice` targets exactly the path `file.exists()` will
  test, so a `converted` status can only come from this run's conversion.

## Verdict

One real gap (finding 1), observed in two tracked reconcile tables rather than
hypothesised, and it is the same class as round 2's findings 2-3 one step further down
the chain. Finding 2 is a one-row observability gap. `zone_num()` and the classifier both
measure clean.
