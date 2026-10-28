# Code-check round 5 (#111): the round-4 diff (85daf7d..69adead) and findings.md's "After round 4" table

## Checklist read

- code-check.md, every H3 under `## Mechanisms` (prose, table rows skipped): a guard that fails toward pass; a fixture
  that cannot reach the failure mode; a proxy is not the property; verification that reads its own output; a guard's
  scope, escape hatches and remedies; a fix lands in one of two callers; restore the bug; a shared working tree; a
  wrapper's exit is not the work; zero-length/empty/unset; the probe is broken before the world is; written data
  outlives the fix; serialization loses meaning silently; one fact derived twice.
- code-check-r.md sections for the tools this diff uses (unlink/list.files, file.mtime, read.csv/readLines/write_csv,
  all.equal/tolerance, tryCatch handlers, parallel socket workers, sf::st_write): from rsel.txt.

Probe: `scratchpad/r5/probeA.R` (package copied to the scratchpad; the test file's `promote_fx()`; dry runs only).

## Table check

| row | verdict |
|---|---|
| 0320 `_smoke` ... `_curve.rds`, cleared at pass start | holds (pattern `^(<species>)_(rear\|spawn)_`, non-recursive, so `grad_fwa/` and other species untouched; nothing later in the pass reads them). But "at pass start" is before the smoke gate: see finding 4. |
| 0320 `_score.rds` kept | holds |
| 0320 `_grades.csv` | "the keep-check's ten fields": the keep-check compares eleven (rule, run_uid, walk, walk_md5, ref_edge, discharge_load, curve_prior_sd, grade_withheld, null_heldout_curve by presence, evidence_md5, curve_grad). Otherwise holds: removed after scoring for a key with no curve (line 254); the promotion compares every keep-check field the summary carries. |
| 0330 per-key files, cleared at job start | holds for a full pass (run_one, 0330:217-219). A failed or killed job leaves no comparison, refused. |
| 0330 GeoPackage written part way: removed on its error | holds only for an R error inside `gpkg_one()`. A killed pass or a crashed socket worker leaves the partial file (finding 1). |
| 0330 `compare/change/checks.csv` | holds; the "absent: refused" applies only where the tracked table exists (a first promotion with no tracked table goes through without one). |
| 0330 `floodplain.csv`, figures (STAGE=maps) | wrong in two places. (a) `floodplain.csv` is not cleared when a STAGE=maps pass starts, and a key's figures are cleared when its drawing starts, so a maps pass that dies leaves a partial figure set for the key it was drawing. The promotion takes that set (finding 2). (b) A SPECIES-restricted full pass clears `floodplain.csv`, which holds every key's rows, while the other keys' figures from the same drawing survive (finding 3). |
| logs | holds |
| "Remaining uses of file age: the comparison-after-grades check" | incomplete: 0330's STAGE=maps (lines 310-312) and STAGE=gpkg (321-322) still gate on segments' age against the grades' age. Both are inside a candidate, so they are sound, but the sentence says there is one. |
| missing rows | `<run>/pick_report.csv` (run-level, rewritten each pass with only that pass's keys, never promoted) and `maps/*.html` (never cleared, never promoted). Neither is read by the promotion, so neither changes a verdict. |

## Findings

- **[severity: bug] scripts/0330-compare.R:441 with R/tune_promote.R:222,230** — a STAGE=maps pass unlinks a key's
  figures, then draws them group by group. If the pass dies or is killed partway through a key, that key holds only
  the figures drawn so far. The promotion trusts presence (`take_drawn <- take_cmp`): it moves the partial set in, and
  `plan_dir` removes (archives) the tracked figures of every group not redrawn, with no note. Reproduced (probeA.R):
  run fig = `compare_ch_rear_bulk.png`, tracked = bulk + chwk; `p$removed` holds `compare_ch_rear_chwk.png` and the
  notes say nothing about figures. Nothing in the run records that a drawing finished: `floodplain.csv` is written only
  at the end of the maps pass, but its absence is read as "drew no maps" and kept (noted), not refused. The same holds
  for a PNG that `tmap_save` leaves truncated when killed.
- **[severity: fragile] scripts/0330-compare.R:273-277 (STAGE=gpkg, 316-326)** — the partial GeoPackage is removed only
  by `gpkg_one()`'s R error handler. A killed pass, or a socket worker that crashes in GDAL (parLapplyLB then raises in
  the master, and the worker's handler never runs), leaves a GeoPackage holding the groups written so far. In a full
  pass this is caught, because `compare.csv` is written after the GeoPackages and its absence is refused. In a
  STAGE=gpkg pass the run's `compare.csv` is already there, so the promotion moves the partial GeoPackage over the
  tracked complete one. Reproduced at the promotion level (probeA.R: a run `gpkg/CH_rear.gpkg` reading "partial"
  is in `p$written`). The table's "removed on its error" row is what reads this as covered.
- **[severity: fragile] scripts/0330-compare.R:331 with R/tune_promote.R:263-272** — a full pass restricted by SPECIES
  (the documented way to compose a run: CH and CO, then BT, ...) unlinks `floodplain.csv`, which holds the rows of
  every key the last STAGE=maps drew, while those keys' figures survive. Promoting the run then moves in, say, CH's
  figures from this run and keeps CH's tracked floodplain rows from an older run, under the note "not in the run". That
  is the accepted "drew no maps" case in wording only: the run did draw CH's maps. The way back has a trap too. A
  SPECIES-restricted STAGE=maps writes `floodplain.csv` with that pass's keys only, so promoting the whole run is
  refused by `.knw_rows_merge` (`lost`). Its remedy, "rerun 0330 on the run for them", taken as a full pass, unlinks
  `floodplain.csv` again. Only a STAGE=maps over every key composes a complete table, and no message says so.
- **[severity: fragile] scripts/0320-tune-run.R:221-224 then 242-245** — the clear runs before the smoke gate. On a
  resumed candidate, a refused smoke run deletes the previous pass's `_tune`, `_curves`, `_groups`, `_seeds`,
  `_honest`, `_summary` and `_curve.rds` for every key of the pass, and the refusal says "nothing is scored". The
  previous pass's complete, compared fit becomes unpromotable: no summary. Its grades and its comparison stay in the
  run, and only a later pass that passes the smoke gate restores it. Clearing `_smoke.csv` before the smoke run and
  the rest after the gate would keep the refusal free of side effects.

No other defect found in the round-4 diff. The field checks in `knw_tune_promote()` match what 0320 writes on both
sides: formats, rounding to 4, Inf priors, and TRUE/FALSE. The clears reach no tracked path, since `dir_out` is
`data/tune/dev`, `data/tune/candidate/<stamp>[/grad_fwa]` or `data/compare/candidate/<run>` with the run names
validated. They delete no cache that must survive: the score cache, the grade table, the floodplain catalog and the
walk cache are all kept. And no later step of the same pass reads a file the pass has already deleted. The
undo path (archive: every file taken, no mtime check, rows of every key) is consistent with what an archive holds.
