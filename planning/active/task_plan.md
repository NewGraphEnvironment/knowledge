# Task: Backlog move 16: NuSEDS spawning windows for every group, and a publish that runs as documented (#244)

Carries #240 (NuSEDS spawning windows for every watershed group and species, with a mainstem rule) and #230 (0340: the documented tee into a tracked log makes PUBLISH=TRUE refuse).

## Context

`data-raw/timing_nuseds.R` (#96) computes chinook spawning windows from NuSEDS for UFRA and COTR only. It reads a local
CSV and drops every population whose watershed code crosses more than one group, which takes the Bulkley and Morice
mainstems out of their group windows. #241 and #242 (the timing track, #243) start their literature reviews from
windows for every group and species. Separately, `scripts/0340-nuseds-build.R`'s documented RUN line tees into a
tracked log; `tee` truncates that log at launch, so the `PUBLISH=TRUE` clean-tree check refuses (#230).

Measured during exploration (2026-11-20, published `knowledge/nuseds/v1`, release 20260601): 102,803 dated rows,
5,223 populations; 4,928 populations sit on one group's stream, 189 on a stream crossing several groups (70 named
waterbodies), and 72 have no Atlas match. 97 groups hold single-group dated populations. The parquet can be read over
public HTTPS (GetObject is public; listing is not). DFO's census-site points put Morice River in BULK and the
Skeena and North Thompson in their lowest groups, so those points cannot place a spawning reach.

## Decided at the gate (Al, 2026-11-20)

- **Mainstem rule: reported apart, plus a named table.** A population on a stream that crosses several groups stays out
  of the pooled group window and is listed under every group it crosses, beside that group's window. A tracked table,
  `data/nuseds_reach_groups.csv` (gfe_id, waterbody, wsg_code, reason; keyed by DFO's reach, since the Fraser's one code runs through every Fraser group: Plan review), assigns a named reach to one group where we
  know where it spawns. It starts with UFRA's "FRASER RIVER - ABOVE TETE JAUNE", so the published UFRA window is
  unchanged. #241 and #242 add reaches (Morice, Bulkley upper) as they review them.
- **No NuSEDS-only rows.** This PR writes windows and the comparison to tracked logs. `data/life_history_timing.csv`
  is not touched; #241 and #242 add rows alongside their literature reviews.
- **#230: write the log outside the repo, then copy it in.** The RUN line tees to `${TMPDIR:-/tmp}` and copies the log into
  `scripts/logs/nuseds/` after the run. The clean-tree check stays whole.

## Phase 1: 0340 runs as documented (#230)
- [x] `scripts/0340-nuseds-build.R` header RUN line: tee to `"${TMPDIR:-/tmp}/<yyyymmdd>_nuseds_build.txt"`, then `cp` it
      into `scripts/logs/nuseds/`. Say why in one line (tee truncates a tracked log, so the publish refuses)
- [x] `scripts/README.md`'s 0340 entry says the same

## Phase 2: windows for every group and species from the published parquet (#240)
- [x] Read `knowledge/nuseds/v1` (`VERSION=`) over HTTPS: download the manifest and the parquet to a tempfile with curl,
      refuse a sha256 that differs from the manifest's, and print the release, sha256 and manifest commit
- [x] `GROUPS=` and `SPECIES=` (comma lists; default every group and species with dated records). Map NuSEDS species
      to the table's codes (CH CO SK PK CM ST; Atlantic dropped)
- [x] Group by watershed code as now, through one query on `whse_basemapping.fwa_stream_networks_sp`. Single-group
      codes pool into their group; reaches (gfe_id) in `data/nuseds_reach_groups.csv` go to the group it names (and are not listed apart elsewhere); any other
      multi-group population is "apart" and listed under every group its code crosses
- [x] Each population's row carries its `run_type`. Where a group holds more than one run type for a species, print
      a window per run type beside the pooled window
- [x] Write `scripts/logs/timing/<yyyymmdd>_timing_nuseds_windows.csv`: one row per group × species × scope
      (`group` pooled, `population`, `apart`), with the start/end/arrival medians and q10/q90, year counts, first and last year
- [x] Regression stops: UFRA chinook 08-11 to 09-05 (123/126 population-years) and COTR 08-10 to 09-06 (35/36), the
      windows the published rows rest on; BULK chinook tributaries 08-15 to 09-10 (28/27 population-years, #240's run; both counts pinned after the Plan review)
- [x] New `data/nuseds_reach_groups.csv` (UFRA's reach); add it to NuSEDS's row in `inst/NOTICE.md` and to the
      `data/` root list in `CLAUDE.md`

## Phase 3: compare every timing row with NuSEDS (#240)
- [x] For every row of `data/life_history_timing.csv` (`knw_timing_read()`): compare a spawning row's start and end
      with its group's pooled window, in days. Compare a migration row's end with the day before the NuSEDS median
      start, and print the median arrival. Every other stage prints "no NuSEDS measure"
- [x] List the group's apart populations beside each compared row, so BULK and MORR chinook show their mainstems.
      Print every difference sorted by size; no threshold

## Phase 4: run, record, document
- [x] Run on m1 (`PG*` → fwapg) for every group and species; commit the console log
      `scripts/logs/timing/<yyyymmdd>_timing_nuseds.txt` and the windows CSV
- [x] Update the header's INPUT/OUTPUT/RUN lines, the `scripts/README.md` timing note (every group, the reach table,
      the logs) and `scripts/logs/timing/README.md` (the new filenames)

## Owed at the end (reported, done after merge)
- [ ] Tick move 16 and batches 25–26 in `planning/backlog.md` with the PR's URL (`/gh-pr-merge`'s tick commit, as for #176), and #240 in #243's member list
- [ ] #241 and #242 bodies name the windows CSV and the reach table they start from and add to

## Validation
- [ ] Tests pass (`devtools::test()`; `test-data-dir.R` covers the new `data/` file)
- [ ] `/code-check` clean (once over the branch)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: the script's regression stops reproduce the UFRA and COTR windows (and BULK's tributary window) from
the parquet; the sha256 check proves it read the published set; Phase 1 is proved with a stub Rscript under the new RUN line
(a failing run copies nothing; a good one copies the log), since a non-PUBLISH 0340 never reaches the clean-tree check
and rewrites `data/nuseds_release.csv` anyway (Plan review).

