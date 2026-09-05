# Code-check round 4 — staged `scripts/0210`, `0220` (round-3 finding 1 fix)

Scope: the change since round 3 only — `fetch_one()` in `0210` capturing the `download.file`
condition text, classifying `http_<code>`, retrying once, then `fetch_failed` + `stop()`;
the four new stage-A rows in `0220`. Working tree equals the index for `scripts/`. Probes ran
from `scratchpad/probe4.R` and `scratchpad/probe4b.R` (outputs beside them), R 4.5.2,
libcurl 8.7.1, live against ACAT and httpbin on 2026-09-04.

## Findings

### 1. [defect — live, in today's run logs] `scripts/0210-fiss-xls-fetch.R:114-121` — an ACAT 404 classifies `fetch_failed`, not `http_404`, so `0210` stops on LNTH and UNTH and `0220` refuses both

`download.file(method = "libcurl")` raises **three** conditions on the dead URL, in this order
(measured with `withCallingHandlers`, all warnings muffled):

```
[warning] downloaded length 0 != reported length 842
[warning] cannot open URL '…/r58437/FishSalvageNorthThompsonTributary;2019;KA19-52137_….xls': HTTP status was '404 Not Found'
[error]   cannot open URL '…/r58437/FishSalvageNorthThompsonTributary;2019;KA19-52137_….xls'
```

`tryCatch(warning = …)` unwinds on the **first** warning, so `err` is
`"downloaded length 0 != reported length 842"`. That text has no `HTTP status was`, `code` is
`NA`, the branch at :120 is skipped, the second attempt does the same, and the row lands as
`fetch_failed`. The status line the classifier is written for is in the second warning, which
is never reached. The ACAT 403 page has the same shape (`reported length 661` first, then
`HTTP status was '403 Forbidden'`), so it too is `fetch_failed`. The length warning fires
because R sets `CURLOPT_FAILONERROR`: libcurl reads the `Content-Length` header of the error
body and then aborts without writing it, so every 4xx that carries a body — which is every
ACAT 4xx — emits the mismatch warning first. httpbin's `/status/410` sends `Content-Length: 0`,
raises no length warning, and does classify `http_410`, which is why a quick test against a
synthetic endpoint would have passed.

Verbatim `fetch_one()` (copied from :104-131 into `probe4.R`):

| input | result | expected |
|---|---|---|
| dead ACAT URL (r58437, 404) | `fetch_failed` after 4.5 s | `http_404` |
| ACAT `reportId=99999999` (403) | `fetch_failed` | `http_403` |
| live cotr URL | `ok` | `ok` |
| httpbin 410 | `http_410` | `http_410` |
| httpbin 500 / 429 / 408, no such host | `fetch_failed` | `fetch_failed` |

This is not hypothetical. `scripts/logs/fiss/20260904_fiss_run_lnth.log:242-252` and
`…_unth.log:242-252` — the `0210 RE-FETCH … after the round-3 review fix` runs — show
`fetch_failed 1` for exactly the two permanent 404s, then
`Error: Download failed after retry … Re-run when ACAT is reachable.` Lines 254-289 of each
log show the `0220 RE-RUN` failing stage A on the new `fetch_failed` row. So the fix for
round-3 finding 1 has turned "a short chain nobody can see" into "these two groups cannot
complete `0210` at all", and the `stop()` text tells the operator to wait for an outage that
is not happening. (`data/lnth/` and `data/unth/` are untracked — `git ls-files` returns 0 for
both — so the reconcile tables round 3 called "committed evidence" were never in git; noting
it because the failing rows there are what the next person will read.)

**Fix.** Collect every condition instead of unwinding on the first, and keep the current
"any warning means not clean" semantics so a truncated 200 (the only case the length warning
means anything on a success) still retries rather than passing on `size > 0`:

```r
msgs <- character(0); ok <- FALSE
for (attempt in 1:2) {
  msgs <- character(0)
  ok <- tryCatch(withCallingHandlers({
    utils::download.file(xls_url, dest, mode = "wb", quiet = TRUE, method = "libcurl")
    file.exists(dest) && file.info(dest)$size > 0
  }, warning = function(w) { msgs <<- c(msgs, conditionMessage(w)); invokeRestart("muffleWarning") }),
  error = function(e) { msgs <<- c(msgs, conditionMessage(e)); FALSE })
  ok <- ok && !length(msgs)      # a warning on a 200 is a length mismatch: retry, not ok
  if (ok) break
  code <- str_extract(paste(msgs, collapse = " | "), "(?<=HTTP status was ')[0-9]{3}")
  …
```

Measured with that shape (`probe4b.R`): dead 404 → `http_404`, ACAT 403 → `http_403`, live →
`ok`, no-host / 500 / 429 → `fetch_failed`, 410 → `http_410`. The comment at :108-110 should
say the status is in the *second* warning, since that is the fact this bug depends on.

After the fix, re-run `0210` and `0220` on LNTH and UNTH; the expected stage-A shape is
`fetch_failed 0 = 0`, `fetch_http_4xx` actual 1 with the report id in the note, and
`fetch_parseable_vs_parse_log_workbooks` 55/37 — the short set is then explained by name,
which is what round 3 asked for.

## Focus questions from the brief — checked

**(1) error or warning, and does the text carry the status?** Both, and yes — but the status
is in the second of two warnings, followed by an error that does not carry it. The handler as
staged classifies the dead URL `fetch_failed` (finding 1); the live one classifies `ok`
(329,216 bytes, no conditions).

**(2) a successful download that emits a warning.** Not observed: six live cotr URLs
downloaded with zero conditions. If it ever happens (a `Content-Length` mismatch on a 200 is
the only warning libcurl emits on success), the staged code retries and then records
`fetch_failed` and stops — loud, and the right direction, since that mismatch is truncation.
The fix above preserves that.

**(3) partial `dest` on a 404 / stale `dest` surviving.** `download.file` removes `dest`
itself on failure: after a raw 404 the file does not exist, and a pre-existing 14-byte
stale `dest` is gone after a raw 404 with no `unlink()` at all. The `unlink(dest)` calls at
:121 and :125 are therefore belt-and-braces, not load-bearing, and a stale file cannot reach
an `http_4xx` or `fetch_failed` row. It also cannot reach `ok`: the `size > 0` test is inside
the `tryCatch` and only runs after `download.file` returned, which has just overwritten it.

**(4) `str_extract(err %||% "", …)` with `err` NULL.** Safe: `""` → `NA` → not a 4xx →
retry → `fetch_failed`. Measured with a `file://` URL to a zero-byte file (no condition
raised, `size == 0`): `fetch_failed` after 4.2 s, `dest` removed. The `err <- NULL` at :113
resets per attempt, so a second-attempt message is what gets classified.

**(5) other checks on the two hunks, clean:**

- `0220:307-312`: `fetch_failed` expected `0L` vs an integer sum — the default `pass` compares
  the raw arguments, so `0L == 0L`; `status` is never `NA` from `0210`, so `all(pass)` cannot
  be `NA`. `fetch_http_4xx` and `fetch_unreadable` are `pass = TRUE` with ids in the note.
- `0220:313-314`: the bare `if (!is.null(reports))` contributes `NULL` to `bind_rows()`, which
  drops it; a reports file with no `db_source` column gives `paste(NULL, collapse = "|")` →
  `""`, informational, no failure.
- `0210:137-138`: the row-count and URL-set assertions run before the log is written, and the
  `fetch_failed` `stop()` runs after, so a partial log is never on disk under the assertions
  and a complete one is under the stop.
- `0210:123`: `Sys.sleep(2)` also runs after the second attempt (4 s per permanent 4xx after
  the fix classifies on attempt 1, so this only costs on genuine `fetch_failed`). Not a defect.
- `0220:200`: the "every fetch was download_failed or unreadable" message uses the retired
  vocabulary. Text only.

## Verdict

One defect, and it is the fix under review: the classifier reads the wrong warning, so the
deterministic-4xx path is unreachable for ACAT and both North Thompson groups now stop
instead of recording the 404 by name. Two run logs staged for commit show it happening.
Everything else in the two hunks measures clean.
