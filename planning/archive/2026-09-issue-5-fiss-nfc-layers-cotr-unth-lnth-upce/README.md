# 2026-09 — No-fish-captured layers for COTR, UNTH, LNTH and UPCE from the FISS .xls track (#5)

## Outcome

The FISS `.xls` track (`0200` enumerate → `0210` fetch → `0220` parse) ran end to end on four
groups that had never had it, over a PINE regression control, and every group now has
`fiss_sites_<wsg>.{gpkg,csv}`, `fiss_sites_<wsg>_all.csv` and `fiss_step2_fishcoll_<wsg>.csv`
with `nfc` and `nfc_source` populated. The two hazards the issue named are fixed forward:
`WSG_TARGET` has no default, and the tunnel question was settled by measurement rather than
argument (the tunnel's FISS snapshot is a superset of the local one, so it stays primary with a
down-only fallback). The larger result is the reconcile gate: `0200`, `0210` and `0220` each
write a record file, and `0220` fails the run on any short link in manifest → reports → fetch
log → parse log → sites, before the site tables are written. That gate found real losses in
the pilot code — 5 of 77 PINE workbooks vanishing without a message, and 116 North Thompson
sites per group dropped for a `"11U"` zone string — and four code-check rounds found and fixed
thirteen more ways the chain could be silently short. Undocumented prerequisites are folded
into `scripts/README.md`; the parser graduation and the skill are #7 and #8.

## Measurement

| | PINE | COTR | UNTH | LNTH | UPCE |
|---|---|---|---|---|---|
| report pages / with `.xls` | 78 / 69 | 47 / 30 | 42 / 37 | 58 / 54 | 53 / 45 |
| workbooks fetched (direct / LibreOffice / dead link) | 44 / 33 / 0 | 18 / 12 / 0 | 23 / 14 / 1 | 35 / 20 / 1 | 27 / 21 / 0 |
| sites parsed / inside the group | 1,610 / 411 | 736 / 154 | 996 / 531 | 1,429 / 619 | 7,023 / 4,921 |
| NFC inside (submitted / derived) | 142 (128 / 14) | 62 (62 / 0) | 136 | 136 | 228 (218 / 10) |
| `nfc` NA inside (no Step 2) | 31 | 31 | 0 | 12 | 383 |

Tunnel vs local `fwapg` report ids: COTR 47/45, UNTH 42/40, LNTH 58/58, UPCE 53/52, PINE 78/78;
nothing local-only — which reversed the plan's "switch to local" rule. Restricted (HTTP 403)
report pages: PINE 2, COTR 3, UPCE 1. The zone fix moved UNTH 513 → 531 and LNTH 522 → 619
inside-group sites; the easting window widened from one zone's width to 150–850 km with 0
outside-group sites fixable by a ±1 zone shift anywhere, so window and recorded zones agree.
UPCE's inside-group layer is 76% mainstem-named; 97 of its 228 NFC sites are on tributaries.
Template editions seen: 2012 (two spellings), 2016, 2018, 2019, 2020, 2022; header at row 26,
31, or 17 (two LNTH workbooks). Step 4 is usable on 4–13 workbooks per group.

Wrong turns kept: the first COTR run stopped on three "failed" pages that were deterministic
403s, so the guard learned HTTP status; the round-3 fix for download failures classified a 404 as
transient because `download.file(quiet = TRUE)` raises a length-mismatch warning before the error
that carries the status, and the fix that held was reading the status from `curl` directly.

## Evidence

`scripts/logs/fiss/20260904_fiss_run_*.log` (one per group, with the post-review re-runs
appended in order), `scripts/logs/fiss/20260904_fiss_parse_pine.log` (the regression control),
and per group `data/<wsg>/fiss_xls_{reports,fetch_log,parse_log,reconcile}.csv`. Review rounds:
`review-round1.md` … `review-round4.md` here.

Closed by: PR for branch `5-no-fish-captured-layers-for-cotr-unth-ln`
