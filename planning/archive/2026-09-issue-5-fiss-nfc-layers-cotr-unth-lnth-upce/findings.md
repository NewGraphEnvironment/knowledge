# Findings — No-fish-captured layers for COTR, UNTH, LNTH and UPCE (#5)

## Issue context

## Problem

The FISS `.xls` track (`0200` enumerate → `0210` fetch → `0220` parse) turns provincial fish
data submissions into a no-fish-captured layer. It has run on exactly **one** watershed group —
PINE, its pilot — and produced a real result there: 411 sites, `nfc` TRUE on 142, with
`nfc_source` splitting 128 `submitted` / 14 `derived`.

Four areas now need that layer and have never had it: **COTR** (Cottonwood River), **UNTH**
(Upper North Thompson River), **LNTH** (Lower North Thompson River) and **UPCE** (Upper Peace
River).

Running a track that has only ever been exercised on its pilot group is where the undocumented
prerequisites surface — the same class of gap that #4 found in the report/PDF track.

## Why this track, and why now

It is the cheap half of the pipeline. `0200`/`0210`/`0220` are deterministic R plus LibreOffice:
**no rag store, no Zotero, no farm workflow, and no LLM subagents at all.** So it delivers a
field artifact without touching the agent token budget, which is what makes it a better use of
time than finishing #4's harvest-and-farm half right now.

Unlike the report track, the FISS scripts write **per-group files only** —
`data/<wsg>/fiss_sites_<wsg>.{gpkg,csv}`, `fiss_sites_<wsg>_all.csv`,
`fiss_step2_fishcoll_<wsg>.csv`. There is no cross-group file to clobber, so none of the
overwrite hazard that affects `0161`/`0162`/`0154` applies here.

## Scale, measured

| group | FISS observations | distinct reports |
|---|---|---|
| COTR | 1,915 | 45 |
| UNTH | 1,065 | 40 |
| LNTH | 5,920 | 58 |
| UPCE | 18,383 | 52 |
| PINE (precedent) | 1,727 | 78 → **77 `.xls`** fetched |

So roughly 40-60 `.xls` per group, ~200 total. Hours, not days.

**Report count, not observation count, is the cost metric.** UPCE has 18,383 observations but
only 52 reports — mainstem reservoir sampling inflates the observation count without adding
reports. Reading the observation count as a download estimate overstates UPCE's cost by roughly
300x; it is the same size of job as the other three.

### Why UPCE is in scope here but parked in #4

#4 stopped short of harvesting UPCE's reports because that half of the pipeline is an expensive
LLM farm over reports concerned with mainstem dam and reservoir monitoring — the wrong scale for
crossing work. **Neither objection applies to this track.** It is deterministic and cheap, and
UPCE has a stronger claim on the result than the others: 3,328 modelled crossings in
`bcfishpass` and **zero PSCIS assessments in all four layers**, so evidence of where fish were
and were not found is the only signal available for prioritising there.

Expect UPCE's NFC sites to skew mainstem, since that is where the submissions are. `0220` writes
both a clipped layer and an unclipped `_all.csv`, so nothing is discarded and the skew is
measurable rather than assumed.

## Known hazards going in

Found while planning #4; none has been fixed.

- **`0220-fiss-xls-parse-nfc.R:324` hard-`stop()`s without the bcfishpass tunnel** (`:63333`),
  with no local `fwapg` fallback — while `scripts/README.md:167-170` implies the tunnel may be
  droppable for this track. Untested either way.
- **`WSG_TARGET` defaults to `PINE`** in all three scripts (`0200:45`, `0210:33`, `0220:54`), so
  an unset variable silently runs the wrong group and overwrites its outputs.
- **`soffice` / `SOFFICE_BIN`** is undocumented in `scripts/README.md`. It is on PATH on m1 via
  Homebrew; that is not guaranteed elsewhere.
- `0210` is opt-in behind `FISS_FETCH=TRUE`, deliberately.
- The parser normalises across 2009-2020 template editions by anchoring on the
  `REFERENCE NUMBER` label row. Three new groups is the first real test of that generalisation.

## Proposed Solution

Sequenced so the durable artifact is written over proven code rather than current guesses:

1. **Run the three groups** on the scripts as they stand. Fix what breaks; record every
   undocumented prerequisite, in the manner of #4.
2. **Graduate the parsing into `pkg/`** as tested functions. `CLAUDE.md` sets the bar at "only
   code that has run on two regions"; after PINE + COTR + UNTH + LNTH + UPCE this track has run
   on five, which clears it. The `.xls` header detection and edition normalisation are the parts
   worth having under test.
3. **Write the skill last**, over a thin script layer, capturing the run order, prerequisites and
   gotchas — the operator knowledge that currently lives in script headers and a README nobody
   can execute.

Step 3 is deliberately last. A skill written now would codify assumptions the run has not yet
tested.

## Acceptance criteria

- [ ] `0200` → `0210` → `0220` completes for COTR, UNTH, LNTH and UPCE
- [ ] Each group has `fiss_sites_<wsg>.{gpkg,csv}`, `fiss_sites_<wsg>_all.csv` and
      `fiss_step2_fishcoll_<wsg>.csv`, with `nfc` and `nfc_source` populated
- [ ] Submitted vs derived NFC distinguishable per site, as in PINE
- [ ] Row counts reconciled against the manifest, so a silent fetch or parse failure cannot pass
- [ ] Every undocumented prerequisite and broken step recorded and folded into
      `scripts/README.md`
- [ ] The `WSG_TARGET`-defaults-to-PINE hazard resolved rather than remembered
- [ ] Decision recorded on whether `0220` genuinely needs the tunnel

## Out of scope

The report/PDF track (harvest, rag store, Zotero filing, farm, reconcile, spatialize) — that is
#4, parked. Including for UPCE: this issue covers only its FISS `.xls` submissions, not its
EcoCat reports. `pkg/` graduation and the skill are steps 2 and 3 and may split into their own
issues once step 1 has run.

Relates to #4
Relates to NewGraphEnvironment/fish_passage_template_reporting#198



## Exploration, 2026-09-04 (plan mode; scripts read directly, one Plan reviewer's findings verified)

- All three scripts hardcode the bcfishpass tunnel (`0200:45-47`, `0220:283-285`) and pass no
  password; `0220` `stop()`s at `:324` without it. The local `fwapg` on `5432` carries both
  `whse_fish.fiss_fish_obsrvtn_pnt_sp` (with `acat_report_url`) and
  `whse_basemapping.fwa_watershed_groups_poly` — measured with `psql`. So the tunnel decision is a
  positive-control comparison of report-id sets, not a judgement call.
- All three default `WSG_TARGET` to `PINE` (`0200:45`, `0210:33`, `0220:54`).
- **Silent drops are real.** `parse_step()` in `0220` returns `NULL` with no message on five paths:
  `excel_sheets()` error, no sheet matching a step pattern, a swallowed `read_step()` error, no
  `REFERENCE NUMBER` anchor within 40 rows, and `select_wanted()` filtering every row out.
  Measured on PINE's 77 parseable workbooks: **5 match no step sheet** and vanish —
  `16005__FavelsReachSummary`, `16005__FavelsSiteSummary` (sheets `Sheet1..Sheet16`),
  `50254__…tissuesamplingdata.xlsx`, `57269__FishTissue…`, `57272__FishTissueResults2018…`
  (sheet `Tissue`). Three are tissue data, legitimately not the template; two are summaries.
  `scripts/README.md:166` "77 submissions → 1,610 site records" is therefore 72 → 1,610.
- `0210`'s fetch log (`0210:91-102`) carries `report_id, file_name, path, parse_path, status,
  converted` — no `xls_url`, no `idx` — so it cannot be key-joined to the manifest; `file_name`
  collides across attachments (the reason `idx` exists at `0210:47-48`). A count-only check passes
  a duplicated download. PINE's log on disk also predates the `idx` naming (`1214__…` where
  current code writes `1214_1__…`): the precedent is schema-stale. Recorded; PINE is not re-fetched.
- `0200` only `message()`s on a failed page fetch (`0200:82-83`) and exits 0 with a short manifest.
- `0220:293` accepts eastings 280–720 km, one UTM zone's width at 51°N. Group bboxes from `fwapg`
  (lon min/max): COTR -122.96/-121.40 (zone 10), PINE -123.01/-120.71 (10), UPCE -122.71/-120.67
  (10), **LNTH -120.67/-119.50 (10/11)**, **UNTH -120.07/-118.79 (10/11)**. A North Thompson
  submission recorded in one zone across 120°W produces eastings near 780 km or 255 km, which
  the filter discards as malformed and counts only in `n_badcoord`. `num(utm_zone)` also turns
  `"10U"` into NA. PINE never exercised zone 11 or a boundary.
- `nfc` is NA for any site with no Step 2 record (`full_join`, `0220:261`); "populated" in the
  acceptance criteria needs that stated as NA = unsampled-in-sheet, not FALSE.
- Nothing records which template edition a workbook is. PINE's header row lands at 6 (24
  workbooks) or 23 (48): already a two-edition signal worth writing to the parse log.
- UNTH and LNTH are adjacent (UNTH ymin 51.50, LNTH ymax 51.85), so North Thompson submissions
  will appear in both manifests. Correct by design; the per-group "submissions" figure double
  counts, so shared report ids are reported.
- Datum: `0220:302` places everything as WGS84 (`326xx`). Pre-2010 NAD27 submissions shift
  ~200 m, which matters only at group edges. Record, do not fix.
- `soffice` on PATH (`/opt/homebrew/bin/soffice`, LibreOffice 26.2.3.2). readxl, janitor, rvest,
  xml2, sf, RPostgres, testthat, chk all installed. Raw `.xls` under `data/*/fiss_xls/` gitignored.
- Both `CLAUDE.md` (Database access) and `scripts/README.md:30,168-170` name `0200`/`0220` as
  tunnel scripts; the doc fold touches both.

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Phase 1 — preflight, tunnel decision, guards (2026-09-04)

**Preflight.** From repo root: `soffice` at `/opt/homebrew/bin/soffice`; all packages present;
`PGPASSWORD` visible to R; both DBs reachable; COTR, UNTH, LNTH, UPCE, PINE all present in
`fwa_watershed_groups_poly` on both.

**Tunnel decision — the tunnel is the superset, so it stays primary.** Same distinct-report-id
query on both databases:

| group | tunnel (bcfishpass) | local fwapg | only on tunnel |
|---|---|---|---|
| COTR | 47 | 45 | 275, 52094 |
| UNTH | 42 | 40 | 23, 34 |
| LNTH | 58 | 58 | — |
| UPCE | 53 | 52 | 17119 |
| PINE | 78 | 78 | — |

Nothing is local-only. The issue's counts (45/40/58/52) were taken from the local copy. So the
plan's rule (local ⊇ remote → switch) did not hold: `0200` and `0220` now try the tunnel first
and fall back to the local `fwapg` with a message; `0200` records `db_source` in
`fiss_xls_reports.csv` so a short manifest is explainable, and `0220`'s fallback is harmless
because the WSG polygon is the same FWA layer on both. `0220` no longer `stop()`s for a missing
tunnel — only when both are down.

**`WSG_TARGET` hazard resolved.** All three scripts `stop()` when it is unset, naming the
variable and the run form; the interactive `wsg_target` branch survives. Tested: all three stop.

**Guards added.**
- `0200` → `fiss_xls_reports.csv` (`page_status` ok / no_xls / fetch_failed, `n_xls`,
  `db_source`); a failed page is retried once, then the script stops.
- `0210` → fetch log carries `idx` and `xls_url` and asserts one row per manifest URL.
  `options(timeout = 120)` so one wedged download cannot pin an unattended run.
- `0220` → `fiss_xls_parse_log.csv`, one row per workbook × step, `status` in {ok,
  sheets_error, no_sheet_match, read_error, empty_sheet, no_header, no_rows} with
  `sheet_matched`, `n_sheet_hits`, `header_row`, `banner`, `rows_raw`, `rows_after_filter`;
  `fiss_xls_reconcile.csv` with 12 checks and a `stop()` if any fails.
- `0220` easting window 150–850 km (was 280–720, one zone's width); placed sites per zone and
  the count of outside-group sites a ±1 zone shift would put inside are reported.

**PINE regression control (parse only, existing downloads): unchanged.** 411 clipped / 142 NFC /
128 submitted / 14 derived, CSVs byte-identical (`git diff` shows only the gpkg binary
re-serialised, reverted). Over all 1,610 sites: 155 NFC (141 submitted, 14 derived), `nfc` NA on
91 (no Step 2 record; 31 of those inside PINE). The parse log names the 5 no-step workbooks
(`no_sheet_match`). PINE already places 96 sites in zone 11 and 1,197 of 1,608 placed sites fall
outside PINE — submissions span groups, which is why the clip exists. 0 outside sites become
inside with a zone shift. Step 4 is rarely usable: 7 ok / 56 no_rows / 9 no_header of 77.

**Template editions (banner of the matched sheet).** "Fish Data Submission Spreadsheet Template
-V 2.0, April 27, 2012" (76 sheet-reads), the same 2012 edition spelled "V. 2.0" (42), and
"April 11, 2018" (7); 24 workbooks carry the step name as the banner instead. Header row at 26
(24 workbooks) or 31 (48). That is the evidence the `pkg/` follow-up needs.

**Guards proven to fire.** Manifest row removed → exit 1,
`manifest_urls_vs_fetch_log_rows`. Fetch-log `parse_path` pointed at a missing file → exit 1,
`workbooks_unopenable_since_fetch` (a check the plan lacked: the fetch log said readable, so an
unopenable file is a change on disk, not a legitimate no-step workbook). Clean run → 12 checks
pass, exit 0.

## Phase 2 — COTR end to end (2026-09-04/05)

**First run tripped the new `0200` guard, correctly, then taught it something.** 3 of 47 report
pages "failed" twice; the wrapper still exited 0 (the `RUN END` line is the only honest one —
the `ALL STEPS DONE` marker is what the check reads). Probed with `curl -L`: all three return
**HTTP 403 Forbidden** after the http→https redirect (ids 275, 51982, 52222), controls return
200. ACAT hides restricted reports. That is deterministic, so `0200` now fetches with `curl`
directly, records `http_<code>` as the page status without retrying, and stops only on
transport failures or 5xx. The attempt log is kept in `scripts/logs/fiss/runs/`. Report 275 is
also one of the two COTR ids the local `fwapg` snapshot lacks.

**Second run: clean, 12 checks pass.** `scripts/logs/fiss/20260904_fiss_run_cotr.log`.

| | |
|---|---|
| report pages | 47: ok 30, no `.xls` 14, http_403 3 |
| `.xls` fetched | 30 (18 readxl-ok, 12 converted by LibreOffice, 0 failed, 0 unreadable) |
| workbooks yielding a step | 29 of 30; `157_1__RMA_…xls` matches no step (no_sheet_match) |
| sites parsed (`_all`) | 736 |
| placed | 734 (zone 10 = 723, zone 11 = 11); 1 out-of-range |
| inside COTR | 154 of 734; 0 of the 580 outside would move inside with a ±1 zone shift |
| NFC inside COTR | 62 of 154, all `submitted`, 0 `derived`; `nfc` NA on 31 (no Step 2) |
| NFC over all 736 | 396 |
| header row (Step 1) | 26 on 7 workbooks, 31 on 22 |
| editions (banner) | April 2012 (two spellings), April 2016, April 2018, Jan 2020, Jan 2022 (two spellings) |
| Step 4 | 13 ok, 13 no_rows, 3 no_header, 1 no_sheet_match |

Undocumented prerequisites surfaced by this run: none beyond Phase 1's. The `curl` R package is
now a dependency of `0200` (it was already installed as a dependency of `xml2`).

## Phase 3 — UNTH, LNTH, UPCE (2026-09-05)

All three ran `0200` → `0210` → `0220` end to end in one sequential batch (parallel headless
LibreOffice conversions contend for one profile lock), then `0220` was re-run on every group
after the round-1 review fixes and again after the zone fix below, so every output on disk comes
from the final code. Logs: `scripts/logs/fiss/20260904_fiss_run_<wsg>.log`, PINE's parse-only
control in `20260904_fiss_parse_pine.log`.

**A real dropped-site path, found by the new count and fixed.** UNTH and LNTH submissions write
the zone as `"11U"` (the latitude band letter) on 116 sites each; `as.numeric()` made those NA
and they were never placed. `zone_num()` now keeps the leading digits. Effect on the inside-group
layers: UNTH 513 → **531** sites (136 NFC), LNTH 522 → **619** (136 NFC), COTR +1 placed, PINE
and UPCE unchanged. The `utm_zone_non_numeric` row now counts values with no digits at all (0
everywhere).

**Two `download_failed` are dead links on ACAT's side.** `r58437/FishSalvageNorthThompson
Tributary;2019;…xls` (UNTH) and `r58486/PermitReturnFishSalvageYatesCreek2018;…xls` (LNTH)
return HTTP 404 both with the href verbatim from the report page and with the semicolons
percent-encoded. Nothing to fix; the fetch log records them.

**Per-group results (inside-group layer unless stated).**

| | PINE | COTR | UNTH | LNTH | UPCE |
|---|---|---|---|---|---|
| report pages | 78 | 47 (3 http_403) | 42 | 58 | 53 (1 http_403) |
| pages with `.xls` | 77 | 30 | 37 | 54 | 45 |
| `.xls` fetched (ok / converted / failed) | 44 / 33 / 0 | 18 / 12 / 0 | 23 / 14 / 1 | 35 / 20 / 1 | 27 / 21 / 0 |
| workbooks yielding a step | 72 of 77 | 29 of 30 | 34 of 37 | 52 of 55 | 45 of 48 |
| sites parsed (`_all`) | 1,610 | 736 | 996 | 1,429 | 7,023 |
| placed (zone 9 / 10 / 11) | 0 / 1,512 / 96 | 0 / 724 / 11 | 0 / 279 / 708 | 5 / 760 / 656 | 0 / 6,796 / 211 |
| inside the group | 411 | 154 | 531 | 619 | 4,921 |
| NFC inside (submitted / derived) | 142 (128 / 14) | 62 (62 / 0) | 136 | 136 | 228 (218 / 10) |
| `nfc` NA inside (no Step 2) | 31 | 31 | 0 | 12 | 383 |
| outside sites fixable by ±1 zone | 0 | 0 | 0 | 0 | 0 |
| Step 1 header row (26 / 31 / 17) | 24 / 48 / 0 | 7 / 22 / 0 | 10 / 24 / 0 | 16 / 34 / 2 | 23 / 22 / 0 |
| editions (banner year) | 2012, 16, 18, 19, 20 | 2012, 16, 18, 20, 22 | 2012, 16, 19, 20 | 2012, 16, 18, 19, 20 | 2012, 16, 18, 19 |

- **UNTH/LNTH share 10 report ids** (of 37 and 54 with `.xls`): the same submissions are fetched
  and parsed in both groups and contribute sites to each after the clip. Correct by design; the
  per-group "pages" figures double count those 10.
- **Multi-zone path exercised for the first time.** UNTH places more sites in zone 11 than 10;
  LNTH straddles evenly. 0 outside-group sites would come inside with a zone shift, so the
  widened easting window and the recorded zones are consistent with each other.
- **UPCE mainstem skew, measured by name.** Of 4,921 sites inside UPCE, 3,726 (76%) carry a
  mainstem name (Peace River 3,663, Moberly River 693, Dinosaur Lake 31 …). Of the 228 NFC
  sites, 131 (57%) are mainstem-named — Peace River 130, Moberly River 68 — leaving ~97 NFC
  sites on tributaries (Portage, Coalbed, Benson, Gething creeks …), which is the signal
  crossing work can use. No site has both names blank, so the distance fallback was not needed.
  UPCE is the only group whose `nfc` NA count (383) exceeds its NFC count: reservoir sampling
  submissions often carry Step 1 locations with no Step 2 record.
- **LNTH has 2 workbooks with the header at row 17**, a layout none of the other 197 workbooks
  use (probably the 2009-era variant the script header mentions); the anchor found it.
- **Step 4 is rarely usable anywhere**: ok on 4–13 workbooks per group; most are `no_rows`.
- Datum recorded, not fixed: everything is placed as WGS84 (`326xx`); pre-2010 NAD27 submissions
  would shift ~200 m, which matters only at group edges.

Undocumented prerequisites surfaced: the `"11U"` zone convention (now handled); nothing else
beyond Phase 1's list.

## Phase 4 — docs and follow-ups (2026-09-05)

- `scripts/README.md`: FISS section rewritten over the proven runs (prerequisites, the three
  output files per step, the reconcile gate, `nfc = NA` semantics, the five-group results table);
  run-order example no longer says `PINE`. `CLAUDE.md` Database access: `0200`/`0220` now
  described as tunnel-first with a down-only fallback.
- Code-check round 2 (5 fragile findings, all fixed): tunnel fallback only on
  connection-refused text, stop otherwise; 408/429 retried then `fetch_failed`; manifest
  unlinked on the `fetch_failed` stop; stage A reads `fiss_xls_reports.csv` (`sum(n_xls)` vs
  manifest URLs, `fetch_failed == 0`, missing file fails); no-placeable branch unlinks a stale
  gpkg; `convert_xlsx()` unlinks a stale conversion first.
- PINE's `0200` re-run to produce its reports file: 78 pages = 69 ok / 7 no_xls / 2 http_403,
  `sum(n_xls) = 77`; the manifest differs from the July one only in the report-page scheme
  (http → https), attachment links identical.
- Follow-ups filed with the measured evidence: #7 (graduate the parser into `pkg/`), #8 (the skill).
- Code-check rounds 3 and 4: `0210` recorded a permanent 404 and a transient outage as the
  same `download_failed`, and stage A never counted either (LNTH and UNTH each passed with one
  workbook missing). Round 4 measured why the first fix failed: with `quiet = TRUE`,
  `download.file(method = "libcurl")` raises a length-mismatch *warning* before the error that
  carries the HTTP status, so a text classifier never sees the 404. Fix taken: `0210` fetches
  with `curl::curl_fetch_disk()` and reads the status explicitly, as `0200` does; 4xx other than
  408/429 → `http_<code>` (recorded, run continues), anything else retried then `fetch_failed`
  and the script stops. Stage A now has `fetch_failed` (failing), `fetch_http_4xx`,
  `fetch_unreadable` and `enumerate_db_source` (informational). Both North Thompson dead links
  now read `http_404` with their report id in the note. Four review rounds, 13 findings, all
  fixed; the last round found one instance of one class and its fix measured clean.
