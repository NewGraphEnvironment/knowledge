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
