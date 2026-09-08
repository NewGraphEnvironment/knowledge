# Review round 1 — commit a756556 (`scripts/0105`, `scripts/0100`, `pkg/R/pscis.R`)

Scope: `git show a756556 -- scripts/ pkg/`, plus the working-tree `0105` (identical to the
commit — `git diff a756556 -- scripts/0105-reports-resolve-fetch.R` is empty; the
`exclude_regex` and the 500-character threshold are already in a756556). Every finding below
was probed, not read: R probes in the scratchpad, four live EcoCat fetches, and the committed
`data/{lnth,unth}/*.csv` and `scripts/logs/reports/*.log`.

`pkg/R/pscis.R` and `scripts/0100` — **Clean** (details at the end).

## `scripts/0105-reports-resolve-fetch.R`

### 1. EcoCat serves ISO-8859-1; the page is treated as UTF-8, so the geo-filter silently misses the accented titles it was written to catch — line 62, 110

`get_page()` returns `rawToChar(r$content)` with no encoding. Measured: every EcoCat search
and report page answers `Content-Type: text/html;charset=ISO-8859-1`. Any non-ASCII
character in a title (è, é, °, –, ©) therefore arrives as a single invalid byte in a string
R believes is UTF-8. Probe (`scratchpad/enc.R`): a title `Barri\xe8re Creek [PSCIS40]`
still parses out of `parse_hits()` (stringi is lenient in `str_match_all`), but
`str_detect(title, regex("barri[eè]re", ignore_case = TRUE))` returns **FALSE**, and the
invalid byte is then written into `reports_search_hits.csv` / `reports_resolved.csv`.
`iconv(x, "latin1", "UTF-8")` on the same string matches.

The region regex carries `barri[eè]re` precisely for this case, so the guard fails on
exactly the input it was extended to handle — silently, as `off_region`. No accented
title happened to be in either group's hits (0 Latin-1 bytes across 313 hits; a live
`barriere` search of 70 hits had none either), which is why two clean runs prove nothing
here. Fix: read the charset from `r$type` or just `iconv(rawToChar(r$content), "latin1", "UTF-8")`
before returning; `readr::write_csv` then gets valid UTF-8.

(Mechanism: *a fixture that cannot reach the failure mode*; *serialization loses meaning silently*.)

### 2. The `direct` path stamps the site name as the report title — line 151

For a link that already carries `reportId=N` (`resolve = "direct"`, title NA),
`fetch_one()` falls back to the page `<title>`. Measured on `viewReport.do?reportId=24146`:
`<TITLE>Aquatic Report Catalogue</TITLE>` — the catalogue's name, on every report page.
`str_squish()` of that is non-NA, so `%||%` takes it, and every directly-linked report
lands in `reports_fetch.csv` titled "Aquatic Report Catalogue". Neither LNTH nor UNTH has
a direct link (`0 with a report id` in both logs), so the path has never executed.
The report title on that page is elsewhere in the body; pick it from the same markup
`parse_hits()` reads, or leave the title NA rather than writing a wrong one.

(Mechanism: *verification that reads its own output* — the fallback reads a field that is
always present and never the property wanted.)

### 3. A 200 with a non-results body reads as `no_hits` / zero keyword hits; the server states a count that is never reconciled — lines 69-73, 92-96, 105-108

`parse_hits()` on a maintenance page, a session-expired page, or any HTML that is not the
results table returns zero rows, which is indistinguishable from an honest empty result.
In step 1 that becomes `resolve = "no_hits"` (18 of 21 LNTH tags, 8 of 8 UNTH — and the
commit message draws a conclusion from those counts); in step 2 it becomes a keyword query
contributing nothing, with no message at all. The outputs are written as valid and the
script exits 0.

The page carries its own count: `0 Report(s) Found` / `1 Report(s) Found` /
`1132 Report(s) Found` (measured on all four page shapes; results are not paginated —
1132 anchors came back in one 1.3 MB page). Require the marker and reconcile
`nrow(parse_hits())` against it; a page without the marker is `search_bad_page`, not
`no_hits`. For the record, the probe agrees the 18 `no_hits` are genuine (`[PSCIS3740]` →
`0 Report(s) Found`), but the script cannot currently tell.

Related, same block: `get_page()` discards a 5xx after the retry and returns
`status = NA`, so a 503 is recorded as `search_http_NA` / `page_http_NA`. Keep the last
status code.

(Mechanism: *a guard that fails toward pass* — "a search that finds nothing has proven
nothing until it has found something"; *one fact derived twice* done right is the fix.)

### 4. A group with no PSCIS links crashes at line 99, before the keyword search runs

`0100` always writes `reports.csv`; for a group with no PSCIS rows (UPCE, per the recent
history) it is header-only. Probed: `read_csv` of that header yields a 0-row tibble,
`pmap_dfr()` over zero rows returns a **0 × 0** tibble, and line 99
`resolved %>% filter(is.na(report_id))` dies with `object 'report_id' not found`. The
thematic search, which is the only source of reports for such a group, never runs, and
the error blames a column rather than the input. Same shape at line 110 if every keyword
query fails (`map_dfr` of all-NULL is 0 × 0, `mutate(in_region = str_detect(title, …))`
errors) and if `KEYWORD_QUERIES=""`. Branch on `nrow(links) == 0` explicitly and give
`resolved` its columns.

(Mechanism: *zero-length, empty and unset are three different things*.)

### 5. The region and query defaults are North Thompson, keyed on nothing — lines 44-51

The script is parameterised by `WSG_TARGET` but `REGION_REGEX` and `KEYWORD_QUERIES`
default to the North Thompson regardless of the group. `WSG_TARGET=UPCE Rscript scripts/0105-…`
with no env overrides searches "fish passage north thompson", keeps every title matching
`thompson|clearwater|…`, and writes those as `source = ecocat_search`, `verdict = keep`
into `data/upce/reports_resolved.csv` and fetches them into `data/upce/reports_pdf/`.
Nothing in the outputs says the filter was for a different region. Either require both
env vars when `WSG_TARGET` is not one the defaults were written for, or key the defaults
on the group (a small lookup in the script or `data/<wsg>/`).

(Mechanism: *a guard's scope is usually a coincidence* — the default is right for the two
groups it has run on.)

### 6. Reused files are recorded as this run's fetch — lines 158-172

- An existing valid `<id>.pdf` is reused whatever `pick_main()` now returns, and the row
  records the **current** `pdf_url` with `http = 200L` hard-coded and the old file's
  `bytes`. If the `SUPPORTING`/main regex is edited (it was tuned during this work),
  the manifest names a document that is not the one on disk, and `.txt` from the old
  document is reused too (line 168 only re-extracts when the file is empty or missing).
- The LNTH log records that `25682.txt` was produced by hand-run OCR
  (`0105 RE-RUN … after OCR of 25682`); the script then reused it and wrote `status = ok`,
  `txt_chars = 6570`. A fresh clone re-running `0105` gets `no_text` for 25682, and
  `.gitignore`'s comment ("reproducible from data/<wsg>/reports_fetch.csv via scripts/0105")
  is false for that row.

Record what actually happened: `fetched`/`reused` in the row, and the basename of the
document on disk (or a `.url` sidecar) so a `pdf_url` change forces a re-fetch; an OCR'd
text needs a `text_source` value rather than `ok`.

(Mechanism: *written data outlives the fix*; *a proxy is not the property* — `http = 200`
stands for "we have a PDF", not for a request that happened.)

### 7. The committed outputs are not reproducible from the committed script — line 50-51 vs `data/*/reports_search_hits.csv`

The CSVs carry 16 queries (Trumbley 104 hits, Snowy River Resources 83, Cornice 23, …);
the script's default is 7 thematic ones and the log line `313 hits over 16 queries` does
not list them. The consultant-name queries the commit message and header describe exist
only as a `KEYWORD_QUERIES` override that is not in the repo. Running `0105` as committed
produces 61 hits, not 313. Put the query list in the script or in `data/<wsg>/`.

(Mechanism: *running a generator is not committing what it generated*.)

### 8. `search_hits_untagged` attributes the link's crossings to every hit, with no verdict — line 95

If a `[PSCISnn]` search returns hits whose titles lack the tag, all of them become
`source = "pscis"` rows carrying the link's `pscis_layer` and full `n_crossings`, are
fetched, and are counted as "from PSCIS links" in the summary — with no geo-filter and no
`verdict` column, unlike step 2. `searchKeyType=searchAll` matches abstract/keyword fields,
so this is reachable; it did not occur in either group (every tag was `tag_in_title` or
`no_hits`), so it is untested. Either give these rows the step-2 verdict treatment or set
`n_crossings = NA` on them.

### 9. Titles keep HTML entities, and a title with inline markup is truncated — line 70

25 `&amp;` and 1 `&lt;` per group are written literally into three CSVs and into the
`title` the region regex sees. `[^<]*?` also stops at the first tag inside an anchor, so a
title with `<i>` or `<b>` in it is cut off before the region words. Decode entities
(`xml2::xml_text(xml2::read_html(…))` or a small `str_replace_all`) after parsing.

### 10. Log line 100-102 counts tags, not links

`n_distinct(resolved$pscis_tag)` counts `NA` as one value, so "across N links" is wrong the
moment a group has any `direct` link (all of them collapse into one). It was right for
LNTH/UNTH only because every link there had a tag. Use `nrow(links)`.

## `pkg/R/pscis.R` — Clean

`.first_col(df, "ecocat_url$")` was checked against the real layers in
`data/lnth/pscis_lnth.gpkg` and `data/unth/pscis_unth.gpkg`: `assessment`, `design` and
`remediation` carry exactly one column matching (`ecocat_url`), `confirmation` exactly one
(`habconf_ecocat_url`); `image_view_url` does not match. `_date$` picks `assmt_date` on
confirmation and `proposal_date` (before `expiry_date`) on design; `consultant` picks
`assmt_consultant_name`. The pattern is not start-anchored, so a future column such as
`parent_ecocat_url` would win by position — not a defect today. The new test reaches the
changed branch (a layer with only `habconf_ecocat_url`).

## `scripts/0100-pscis-acat-reports.R` — Clean

`tunnel_err` is always set when `conn` is NULL (`dbConnect` returns or errors). The LNTH
log shows the fallback path exercised end to end (`db source: local_fwapg`, confirmation
layer 11 rows), so the local copy does carry the confirmation SVW.

## Probe artefacts

`/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/67c3fd9e-7107-4013-b2b5-30924f45be08/scratchpad/{cols.R,enc.R,s_*.html,h_*.txt,view24146.html}`
