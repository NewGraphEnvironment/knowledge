# Task: No-fish-captured layers for COTR, UNTH, LNTH and UPCE from the FISS .xls track (#5)

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

## Phase 0 — Land #4's branch, start #5 clean
- [x] On the #4 branch: `git mv planning/active` →
      `planning/archive/2026-09-issue-4-validate-fieldwork-prep-pipeline-upce/`, README stating
      **parked after Phase 3** (not complete), recreate `active/.gitkeep`; one commit.
- [x] Push, open and merge #4's PR (#6). No `pkg/` change, so no version bump. Issue #4 stays
      open, body corrected to "parked after Phase 3".
- [x] `git checkout main && git pull --ff-only`; cut `5-no-fish-captured-layers-for-cotr-unth-ln`;
      scaffold #5's PWF; baseline commit.

## Phase 1 — Preflight, the two known hazards, and the guards the acceptance criteria need
- [ ] Assert from repo root: `soffice`, the R packages, both DBs reachable, all four codes present
      in `fwa_watershed_groups_poly`.
- [ ] Tunnel decision by positive control **before** touching connection code: `0200`'s
      distinct-report-id query for COTR on `5432` and `63333`; record the symmetric difference in
      `findings.md`. Local ⊇ remote → switch `0200`/`0220` to local `fwapg` first (the `0162:122`
      pattern, `postgres/postgres`), tunnel selectable by env; otherwise keep the tunnel and say why.
- [ ] `WSG_TARGET`: drop the `"PINE"` literal in all three scripts — unset → `stop()` naming the
      variable. Keep the interactive `exists("wsg_target")` branch.
- [ ] `0200`: write `fiss_xls_reports.csv` (one row per report id: `n_xls`, `page_status`); retry a
      failed page once, then `stop()` if any page still failed.
- [ ] `0210`: add `idx` and `xls_url` to the fetch log so it joins to the manifest by key.
- [ ] `0220`: write `fiss_xls_parse_log.csv`, one row per workbook, per step: `sheet_matched`,
      `n_sheet_hits`, `header_row`, `rows_raw`, `rows_after_filter`, plus `banner` (first
      non-empty cell of row 1, the edition signal) and a count of non-numeric `utm_zone` strings.
      The five silent-return paths must land as five distinguishable values.
- [ ] `0220`: widen the easting window to 150–850 km (the WSG clip disposes of true strays);
      report placed sites per zone, and for out-of-range rows whether the adjacent zone places
      them inside the polygon.
- [ ] `0220` tail: an **asserting** reconcile block that writes `fiss_xls_reconcile.csv` and
      `stop()`s on: manifest distinct `xls_url` ≠ fetch-log rows; fetch `ok + converted` ≠
      parse-log rows; any workbook with zero rows in all three steps not named; `_all` rows ≠
      distinct `site_key`; not `clipped ≤ placed ≤ with-coords`.
- [ ] Regression control on PINE from the existing local downloads (parse only, no re-fetch):
      expect 411 clipped / 142 NFC / 128 submitted / 14 derived unchanged, and the parse log naming
      exactly the 5 skipped workbooks. Restore each guard's defect once (remove a manifest row;
      rename a sheet) and watch it fire. Commit PINE's new parse log and reconcile file.

## Phase 2 — Run COTR end to end
- [ ] `0200` → `0210` (`FISS_FETCH=TRUE`) → `0220` for COTR, console output teed to
      `scripts/logs/fiss/20260904_fiss_run_cotr.log`. Directory README: what produced these, the
      filename pattern, that they are evidence, and the cutover date; retries to a gitignored
      `scripts/logs/fiss/runs/`.
- [ ] Reconcile file clean; record status counts (ok / converted / unreadable / download_failed)
      and the workbooks that matched no step, by name.
- [ ] Fix what breaks; every undocumented prerequisite into `findings.md`.
- [ ] Commit COTR's tracked outputs: `fiss_xls_{manifest,reports,fetch_log,parse_log,reconcile}.csv`,
      `fiss_sites_cotr{,_all}.csv`, `fiss_sites_cotr.gpkg`, `fiss_step2_fishcoll_cotr.csv`.

## Phase 3 — Run UNTH, LNTH, UPCE
- [ ] Same sequence per group; one commit per group with its log.
- [ ] UNTH/LNTH: placed sites per zone and the out-of-range re-placement count — the first
      exercise of the multi-zone path; report ids shared between the two groups.
- [ ] Per-group results table: submissions, workbooks parsed, site records, clipped, NFC
      submitted / derived / **NA (no Step 2)**, unreadable, and the header-row / banner editions
      each group exercised.
- [ ] UPCE: measure mainstem skew by stream name (`gazetted_name`/`local_name` matching Peace,
      Williston, Dinosaur, Peace Reach) as the share of clipped and of NFC sites; fall back to
      distance to the mainstem via `fwa_named_streams` only if names are mostly blank.
- [ ] Record, do not fix: datum is assumed WGS84 (`326xx`); pre-2010 NAD27 submissions shift
      ~200 m, which only matters at group edges.

## Phase 4 — Fold into docs and close out
- [ ] `scripts/README.md`: `soffice`/`SOFFICE_BIN`, `WSG_TARGET` required (both forms), the
      tunnel decision, the new reconciliation files and what `nfc = NA` means, the corrected PINE
      line (72 workbooks contributed), and the per-group results table. `README.md:30` example no
      longer says `PINE`.
- [ ] `CLAUDE.md` Database access: remove `0200`/`0220` from the tunnel list if the switch landed.
- [ ] File follow-up issues for step 2 (graduate header detection and edition normalisation into
      `pkg/` with tests, citing the header-row/banner evidence from five groups) and step 3 (the
      skill). Not done here: the issue says they may split once step 1 has run, and no acceptance
      box names them.

## Validation
- [ ] All seven acceptance boxes in #5 ticked, each pointing at a reconcile file or log
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` with Measurement and Evidence sections in the README
