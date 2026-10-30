# Plan review — #119 (Plan agent, 2026-10-30, synchronous before the parked baseline)

Reviewed `task_plan.md` against the code at 8153244. Findings as reported, with the parent's verification.
Verified by probe (2026-10-30): B1 (this machine's `visits_link.csv` md5 `d3a434e2…`, the bundle pins `1bd35829…`),
G7 (the published `CH_rear_summary.csv` has `run_uid` but no `tune_run` or `evidence_ledger`), G8 (the published and
the 10-25 grade tables share `run_uid` `20261017_004619-3f4c713b`), B4's prefix list (`s3 ls`: archive, bcfishpass,
bcgw, discharge, fdis, fwapg, hydat, knowledge, rag, snapshots). The rest are folded in as stated and get checked when
their phase runs.

## Blocker
- **B1** The reference bundle cannot be built in the main checkout: its ignored `data/` holds the 10-25 build, so
  `vignette_method.R:93` (evidence) and `:191` (`md5_sites`) stop. Build in a staging worktree filled from the rescued
  copy and m4; never write the main checkout's ignored `data/` (possibly the only copy of the 10-25 run).
- **B2** Records and `data/archive_index.csv` must be committed before any rebuild or worktree:
  `vignette_method.R:459-464` sorts tracked from ignored by `git ls-files`, and a worktree checks out a commit.
- **B3** `0336` cannot archive the published run: it has no candidate, and this checkout's tracked-table files are
  another run's. Take source dirs (`TUNE_DIR`/`COMPARE_DIR`/`EVIDENCE_DIR`, as `data-raw/compare_structures_check.R`),
  and check every file's md5 against record, MANIFEST and bundle pins before upload.
- **B4** Lifecycle filters have no "everything except": a bucket-wide 30-day noncurrent rule also covers
  `archive/knowledge/` (the shorter expiry wins). One 30-day rule per top-level prefix (and per `archive/` child other
  than `knowledge/`), the 180-day rule on `archive/knowledge/`, AbortIncompleteMultipartUpload; a new prefix gets no
  expiry until it has a rule (note in research/).

## Gap
- **G1** Copy the published curves (seven `<key>_curve.rds`) and `CH_rear_segments.rds` from m4 too; check against
  `chinook_rearing.rds` `meta$md5_local`.
- **G2** `knw_tune_promote()`'s `record()` (`R/tune_promote.R:140-147`) reads kept keys' fields from grade tables and
  silently skips NA (`:172`): read the record first. `test-tune_promote.R`'s `set_col()` rewrites grade tables, so
  fixtures must rewrite records too.
- **G3** `0320:360-368` rewrites every curve each pass, so a curve md5 in a "written once" record goes stale: keep the
  curve md5 in the index only.
- **G4** A kept grade table with no record would be regraded (hours): write the record from the table; refuse only on
  mismatch.
- **G5** PULL by default restores evidence and the bundles' ignored files only, not grade tables (`GRADES=TRUE`/`KEYS=`);
  the proof restores no grade tables.
- **G6** Index rows for evidence objects too; name the evidence folder by the MANIFEST's md5; refuse, not skip, on a
  different MANIFEST in the same folder.
- **G7** Record = exactly the grade table's constant columns (species_code, stage, q_walk included), from one list
  shared with 0320's write; also `evidence_ledger` and `tune_run`, which the published summaries lack, so
  `knw_run_ledger()` falls back to the newest ledger.
- **G8** `untokened/<run_uid>` is ambiguous: link's run_uid is shared by the published and the 10-25 runs. Define a
  per-tuning-run id; refuse to overwrite a promoted run's current objects with an unpromoted run's.
- **G9** Upload with `--metadata md5=`; `head-object` checks it and skips a matching object.
- **G10** Undo leaves `promoted` wrong in the index: append an event row (promoted / superseded dates).
- **G11** `knw_build_record()` tokens: update the mock in `test-build_record.R:5-7`; distinct per axis, refuse >1.
- **G12** `0330:363,374` refuses segments older than grades: restore grades before segments or set mtimes.
- **G13** Dropped from the issue: say whether the database can still recreate the run (record vs live
  `knw_build_record()`), printed by PULL and 0336.

## Ordering
- **O1** Preflight before `knw_tune_promote()` (`0335:77`): credentials, versioning, the archive plan, evidence present
  or archived; the failure names the rerun command.
- **O2** Call 0336 between `0335:88` and `:89` (so `BUNDLES=FALSE` archives; undo skips); `DRY=1` runs the preflight
  and lists the plan.
- **O3** Phase 2's real round trip needs Phase 3 first; use a scratch prefix or fold into Phase 4.
- **O4** Copy from m4 first, then write backfilled records with `knw_grade_record_write()` on the copies; cross-check
  against the rescued first rows and the pinned md5s.
- **O5** Exempt `replaced_*` archives from the missing-record refusal, keep the mismatch refusal.
- **O6** Rebuilding the chinook bundle rewrites `bulk_segments.rds`, which `method.rds` pins: rebuild it only after the
  acceptance comparison, or check it byte-identical.

## Acceptance
- **A1** Worktree vs reference identical only at one commit, one machine and libraries, `LINK_REPO`/`WET_REPO`
  resolving, the same database, md5 vectors compared by name.
- **A2** Against the published bundle (built elsewhere): name the expected differences in advance; record package
  versions on both machines; anything else explained or a failure.
- **A3** `devtools::test()` fails here today (`test-vignette-data.R:109-118` against other builds' ignored files); run
  the suite in the restored worktree. The new record-vs-table test md5s 26 GB where present: consider gating it.
- **A4** Phase 1's "rebuild both bundles here" cannot run before Phase 4's inputs.

## Assumption
- The chinook rebuild needs schema `fresh_default_20261017` still in the database (`vignette_chinook.R:308`).
- Auto mode may refuse Phase 4's uploads as production writes, not only Phase 3's.
- `R/settings_register.R:50-53` needs exactly one top-level `gradient` and `se_strict` in 0320.
- Promote and `DRY=1` would md5 ~26 GB: check md5 and size; rows as information.
- A `.zst` md5 is not reproducible across zstd versions: the index's md5 is the object's, the record's the table's.

## Scope
- The record file is safe with every reader checked (anchored `_grades\\.csv$`, `_summary\\.csv$`, `_curve\\.rds$`,
  `_compare\\.csv$`; exact names elsewhere; `.gitignore:23` does not match it; promote's `^<key>_` moves it).
- Say what is left out: segments for CH only or every key; `grad_fwa/<key>_curve.rds` not archived.
