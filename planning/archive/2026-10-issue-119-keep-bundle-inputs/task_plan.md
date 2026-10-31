# Task: Keep the inputs a published article bundle was built from, so any machine can rebuild it (#119)


`inst/vignette-data/method.rds` (the methodology article's bundle, from `data-raw/vignette_method.R`) pins the md5s of 12 ignored files it was built from: the seven `data/tune/<key>_grades.csv`, four tables in `data/fdis/derived/` and `data/fdis/build/reconcile.csv`. `vignette_method.R` refuses to run unless `data/fdis/derived` is the evidence the grade tables name. Nothing keeps those files beyond the machine that ran the build, and the published fish-record tables (`knowledge/fdis/v3`) are not yet uploaded.

Measured 2026-10-29: the published bundle (written 2026-10-28, on #92's tables) pins `CH_rear_grades.csv` at `6da9c17f…`. The database's host holds the 2026-10-25 build (`e37f76ea…`, with matching evidence). All 12 pinned files match on one other machine's checkout, and that is the only copy found. So today the bundle can be rebuilt there and nowhere else, and only until that checkout's ignored files are overwritten by its next run. A first check of that machine wrongly reported the files absent: `md5` was not on the non-interactive ssh `PATH`, so the probe printed nothing.


**Parked 2026-10-30:** the approval covered this baseline only; the phases run when Al says to resume.

## Context

`inst/vignette-data/method.rds` pins the md5s of 12 ignored files (seven `data/tune/<key>_grades.csv`, 26 GB; four
`data/fdis/derived/` tables; `data/fdis/build/reconcile.csv`), and `vignette_method.R` refuses unless
`data/fdis/derived` is the evidence the grade tables name. The only full copy is m4's checkout. Both bundle scripts read
only the **first row** of each grade table (`vignette_method.R:87`, `vignette_chinook.R:96`), so the 26 GB is pinned
for one row each. Goal: any machine with the repo rebuilds a published bundle in minutes from ~200 MB restored from
the bucket's private `archive/`.

Explored (2026-10-30, main at 8153244):
- First-row readers of grade tables: `0320` keep-check (`scripts/0320-tune-run.R:411-441`), `0325`
  (`scripts/0325-publish.R:70-115`), `0330` (`:225`), `knw_tune_promote()` (`R/tune_promote.R:93,141`), both bundles,
  two `data-raw/compare_*_check.R`. Only `0325`'s publish and `0330`'s regeneration read whole tables.
- `knw_tune_promote()` moves every `^<key>_` file of a candidate, so a `<key>_grades_record.csv` rides along with no
  change; `.gitignore:23` ignores `*_grades.csv` only, so the record can be tracked.
- `vignette_method.R:455-476` splits sources into `meta$md5` (tracked) and `meta$md5_local` (ignored) by `git ls-files`;
  `test-vignette-data.R` checks both. A tracked record moves the grade pins from `md5_local` to `md5`.
- `vignette_chinook.R` pins `data/compare/CH_rear_segments.rds` and `data/tune/CH_rear_curve.rds` in `md5_local`
  (untested) and needs the database for its map either way.
- S3 from scripts is `system2("aws", …)` (`0299:108`); cred's S3 code is ragnar-store only, so no sibling to reuse.
- Bucket `fresh-bc`: versioning **Suspended**; one lifecycle rule (Standard-IA at 30 days, whole bucket);
  `archive/` holds `dropbox_new_graph/`, `fdis/` and one tarball.
- link#414 is closed: `link/inst/extdata/vocabulary.csv` holds `cut-full-top`, `cut-full-ssf-all`, `acc-v1`,
  `acc-bcfp`, `grad-seg`, `q-fwapg`, `q-wet-fill` (introduced 0.70.0), and link logs `token_cut/acc/grad/flow` in
  `<schema>.log_recompute` (NULL before 0.70.0). **The published run is on link 0.66.0's build
  (`fresh_default_20261017`), which no token describes**, and the Atlas-line gradient (`GRADIENT=fwa_gradient`) has no
  token either.
- The rescued copy (`~/Projects/repo_aside/knowledge_published_inputs_20261028/`, 199 MB) holds the evidence,
  `reconcile.csv`, `sites.rds` and the grade tables' **first rows only**; the full published grade tables exist only on
  m4.

## Decided at the gate

Al, 2026-10-30, at this plan gate (the issue's earlier decisions stand: evidence private under `archive/`, one folder
per evidence build with a manifest; archive at promotion by `0335`, which refuses to finish when the upload fails):
- **Versioning on, expiry by prefix:** noncurrent versions under `archive/knowledge/` expire after 180 days, everywhere
  else (`rag/` and the rest) after 30; current copies never expire; the Standard-IA rule stays.
- **Untokened builds:** a run on a build older than link's vocabulary (no `token_*` in `log_recompute`, the published
  0.66.0 run among them) goes under `tune/<key>/untokened/<run_uid>/`, and its record says why. A tokened run goes
  under `tune/<key>/<cut>.<acc>.<grad>.<flow>/`, the four tokens read from the build's `log_recompute`, and refuses a
  token missing from or retired in link's `vocabulary.csv`.
- **Version ids in the run index, not the record:** `0320` writes the record once; `data/archive_index.csv` holds each
  archived file's md5 and S3 version id.
- **Seed grades from m4, compressed there:** zstd -3 on m4, copied here, md5-checked through decompression, uploaded
  from here; m4 needs no AWS credentials.

Resumed 2026-10-30 (Al): a second plan gate the same day, which had missed this parked branch, was answered
differently (one bucket-wide 180-day expiry; `link-<run_uid>` folders). Al chose this parked, reviewed plan over it,
with two additions from that gate: a link issue for the tokens the published build and the Atlas-line gradient lack
(and which axis names the tuning's wet flow read), and the #121 item added to #119's body after this baseline
(Phase 5).

## Phase 1: The per-key grade record
- [x] `R/grade_record.R`: the record is exactly the grade table's constant columns (one `cols_grade_record` list
      shared with 0320's write: species_code, stage, rule, run_uid, ref_population, ref_edge, q_walk, walk, walk_md5,
      discharge_load, curve_prior_sd, grade_withheld, null_heldout_curve, evidence_md5, curve_grad), plus the table's
      md5, size and rows (rows informational), `tune_run`, `evidence_ledger`, the knowledge commit, link's version and
      sha (from the ledger), link's four tokens (NA before link 0.70.0) and `record_source` (`0320` or `backfill`).
      No curve md5 (0320 rewrites curves every pass; the index holds it, review G3).
      `knw_grade_record_write(grades_path, ...)`, `knw_grade_record_read()` (the one-row head the readers take),
      `knw_grade_record_check(record, grades_path)` (md5 and size)
- [x] `knw_build_record()` reads `token_cut/acc/grad/flow` where `log_recompute` has them, one distinct value per axis
      or a refusal; `test-build_record.R`'s mock answers the token query (G11)
- [x] `0320` writes the record whole after each grade table; a kept table with no record gets one written from the
      table, and a record that does not match its table is regraded (G4); no new top-level `gradient`/`se_strict`
      assignment (`R/settings_register.R:50-53`)
- [x] `knw_tune_promote()`: `record()` reads kept keys' fields from the record before the table, so a machine without
      the tables still checks them (G2); a fitted key with no record or a mismatching one is refused, except a missing
      record in a `replaced_*` archive (O5); md5 and size, not rows (26 GB)
- [x] `vignette_method.R` and `vignette_chinook.R` read records and `evidence_ledger` from them, not grade tables; the
      tracked record lands in `meta$md5`
- [x] `test-vignette-data.R`: where a grade table is present, its record matches it, behind an opt-in
      (`KNW_CHECK_GRADES=TRUE`) because it md5s up to 26 GB (A3)
- [x] `.gitignore` comment and CLAUDE.md "A run's record travels with its table" name the record
- [x] tests: `test-grade_record.R` (round trip, a changed table refused, restore-the-bug); `test-tune_promote.R`
      fixtures write records and `set_col()` rewrites them (G2)

## Phase 2: Archive and restore
- [x] File a link issue for tokens describing the pre-0.70 default network (the published run's 0.66.0 build) and the
      whole-Atlas-line gradient, and to settle which axis names the tuning's wet flow read; write the dependency into
      #119's body. An untokened run's folder is never renamed when tokens arrive: its index rows gain them
- [x] `R/archive.R`: `knw_archive_plan()` over source dirs (`TUNE_DIR`, `COMPARE_DIR`, `EVIDENCE_DIR`, as
      `data-raw/compare_structures_check.R`; B3) lists what goes where under `s3://fresh-bc/archive/knowledge/`:
      `tune/<key>/<setup>/` holding `<key>_grades.csv.zst` (zstd -3), `<key>_curve.rds`, `<key>_grades_record.csv`,
      `<key>_segments.rds` (every fitted key's: the chinook bundle reads CH's, and species articles follow; not
      `grad_fwa/` curves); `evidence/<MANIFEST md5>/` holding the four derived tables, `reconcile.csv`, `sites.rds`
      and `MANIFEST` (G6). `<setup>` is `<cut>.<acc>.<grad>.<flow>` checked against link's `vocabulary.csv` at the
      link checkout's sha, or `untokened/<run id>` where `<run id>` is the record's `tune_run` (the published run's
      is `published_20261028`), never link's shared `run_uid` (G8)
- [x] `data/archive_index.csv` (tracked) and `knw_archive_index_read()`: one row per archived object (tune files and
      evidence), with key, setup, run id, link run_uid, the object's md5 (the stored bytes; the record holds the
      table's), the source md5, S3 version id, and event rows (`archived`, `promoted`, `superseded`, `undone`; G10)
- [x] `scripts/0336-archive.R`: checks every file against its record, the MANIFEST and, for the published run, the
      bundle pins before uploading (B3); uploads with `--metadata md5=`, reads version id and md5 back with
      `head-object`, skips an object whose md5 already matches (G9); refuses with versioning off, a different
      MANIFEST in an existing evidence folder (G6), or an unpromoted run over a promoted run's current objects (G8);
      prints the record against the live `knw_build_record()`: can the database still recreate the run (G13)
- [x] `PULL=TRUE`: restores by the index (version ids) into a target `data/` (default this tree's), evidence and the
      bundles' ignored files by default, grade tables only with `GRADES=TRUE` or `KEYS=` (G5); grades before segments,
      mtimes set (G12); every md5 checked; refuses to overwrite a present file whose md5 differs
- [x] `0335`: preflight before `knw_tune_promote()` (credentials, versioning, the archive plan, evidence present or
      archived; O1), also under `DRY=1`; 0336 runs between the promote log and `if (!bundles) quit` (so
      `BUNDLES=FALSE` archives, undo appends an `undone` event and uploads nothing; O2); a failure names the rerun
- [x] tests with `aws` mocked to fail by default; scripts/README run order, CLAUDE.md layout entry, `research/` note on
      the archive (including: a new top-level prefix has no noncurrent expiry until it gets a rule)

## Phase 3: The bucket (Al runs or approves each command)
- [x] `put-bucket-versioning Status=Enabled`; `put-bucket-lifecycle-configuration` keeping the Standard-IA rule and
      adding noncurrent expiry per prefix: 180 days on `archive/knowledge/`, 30 days on each other top-level prefix
      (`bcfishpass/ bcgw/ discharge/ fdis/ fwapg/ hydat/ knowledge/ rag/ snapshots/`) and each other `archive/` child
      (`dropbox_new_graph/ fdis/`, the tarball), since a bucket-wide rule would override the 180 (B4); abort
      incomplete multipart uploads after 7 days; read both back; bare commands handed over if auto mode refuses
- [x] Phase 2's real round trip on one small key under a scratch prefix (`archive/knowledge/_test/`), deleted after (O3)

## Phase 4: Seed and prove
- [x] m4 first (O4): compress the seven published grade tables (zstd -3), and copy them, the seven `<key>_curve.rds`
      and every key's `<key>_segments.rds` here into a staging tree outside the repo (G1), checked against the md5s
      `method.rds` and `chinook_rearing.rds` pin, through decompression (`/sbin/md5`, `/opt/homebrew/bin/zstd`); m4's
      checkout is only read, and this checkout's ignored `data/` is never written (B1)
- [x] `data-raw/archive_seed.R`: backfilled records with `knw_grade_record_write()` on the staged tables
      (`record_source = backfill`, `tune_run = published_20261028`, the 2026-10-27 ledger), cross-checked against the
      rescued first rows; commit the records (B2)
- [x] `0336` on the staged published run and its evidence (bare command handed over if auto mode refuses the upload);
      commit `data/archive_index.csv` (B2)
- [x] a staging worktree detached at that commit, beside `../link` and `../wet` (or `LINK_REPO`/`WET_REPO`), filled by
      hand from the staged copies; `vignette_method.R` there is the reference R. A second fresh worktree at the same
      commit, `PULL=TRUE` (no grade tables), then `vignette_method.R`: identical to R except `meta$written`, compared
      by name (A1). R against the published bundle: differences named in advance (`written`, `commit`, `md5` gains the
      seven records, `md5_local` loses the seven tables), package versions recorded on both machines; anything else
      explained or a failure (A2)
- [x] `devtools::test()` in the restored worktree, not the main checkout (A3); the chinook bundle rebuilt only after
      the comparison, with `bulk_segments.rds` checked byte-identical or the method bundle rebuilt after it (O6), and
      the schema `fresh_default_20261017` confirmed present first
- [x] commit the rebuilt bundle(s)

## Phase 5: #121 in the methodology article
- [x] Move `data-raw/site_gradient_check.R`'s flip and agreement computation into a package function both it and
      `vignette_method.R` call, over every published gradient limit (underpowered included; `vignette_method.R`'s
      `"fitted"`-only filter would drop WCT rearing)
- [x] The limits section of `vignettes/habitat_thresholds.Rmd`: a tuned gradient limit sorts sites well in bulk but
      reads as a slope on the ground only to within a few points (`research/fdis_export.md`, "Measured vs modelled
      gradient"); numbers inline with `stopifnot()`; rebuild `method.rds` (after Phase 4's comparison), revise pins and
      the settings register where they move

## Owed at the end (reported, done after merge)
- [ ] when link has tokens for the published build, add them to its index rows (its folder is not renamed)
- [ ] delete the spare copies, on Al's word only: m4's and m1's `~/Projects/repo_aside/knowledge_seed_119/` (zst and staged tables, about 30 GB on m1), m1's `~/Projects/repo_aside/knowledge_published_inputs_20261028/`
- [ ] the next promotion archives through `0335` on whichever machine promotes (it needs bucket credentials; m4 has
      none yet)

## Validation
- [x] Tests pass (in the restored worktree)
- [x] `/code-check` clean (once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: Phase 1 by tests (the bundles are rebuilt in Phase 4, once their inputs are staged; A4); Phase 2 by a
mocked round trip and Phase 3's scratch-prefix round trip; Phase 4's two comparisons are the acceptance test the issue
names. Plan review: `review-plan.md` (folded in 2026-10-30).
