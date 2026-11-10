# Task: Backlog move 1: Evidence builds and tests: a tagged build archives like the default, a live test skips an empty schema (#170)

**If we do it:** a build under a tagged `EVIDENCE_DIR` archives and checks with the default build's commands, and a full test run against an empty or partial `fresh_default` reads as untested rather than broken. **If we never do:** every run on another schema needs `fdis_sites.csv` copied in by hand (met on 2026-11-03 and again on 2026-11-05), and every test run on such a database reports an error unrelated to the code.

Members: #136 (a tagged EVIDENCE_DIR is a second-class evidence build), #142 (live placement test errors when fresh_default holds no BULK BT rearing segment).

## Context

Two defects bite every run off the published build. `0336` archives `fdis_sites.csv` from `EVIDENCE_DIR`, but only
`0240` writes it, into `data/fdis/derived`, so a tagged build (`derived_minimal`, `derived_parent`) needed it copied in
by hand (2026-11-03, 2026-11-05). `minimal_network_check.R` writes its log only at the end, so a refusal at step 3
loses steps 1 and 2. And `test-link_place.R`'s live test errors (not skips) on a `fresh_default` that holds no BULK BT
rearing segment, which was the state of one database on 2026-11-05.

Measured while planning (2026-11-09, this machine): `data/fdis/build/sites.rds` and `data/fdis/derived/fdis_sites.csv`
both hold 51,587 sites, no duplicate `site_visit`, the same set, and the five placement columns are identical after
`utils::read.csv(colClasses = "character")` vs `as.character()`. Every archived evidence build's `fdis_sites.csv` is md5
`2de46c60…`, the same as `derived/`, `derived_parent/` and `derived_minimal/` hold now, so reading it from
`derived/` leaves every archived evidence id where it is (the MANIFEST lists name and md5, row order unchanged).

## Decided at the gate

- (Al, 2026-11-09, in the issue) The archive reads `fdis_sites.csv` from where `0240` writes it, `data/fdis/derived`,
  never from a tagged `EVIDENCE_DIR`; `0310` does not copy it. Owed with it: hold the file to the ledger's `sites.rds`
  before archiving, and a restore refuses a different `fdis_sites.csv` already in `data/fdis/derived`.
- (mine, mechanism) The source directory is a new `knw_archive_plan(sites_dir = "data/fdis/derived")` argument, and
  `0336` passes `SITES_DIR` (default `data/fdis/derived`) for a staged copy, alongside `BUILD_DIR`. `0335`'s positional
  calls keep working. The restore target stays `data/fdis/derived/fdis_sites.csv`.
- (mine) The restore refusal already exists for every evidence file (`knw_archive_pull`, "is here with another md5
  than the archive's"); this PR pins it for `fdis_sites.csv` with a test rather than adding code.
- Not done: `data-raw/vignette_method.R` keeps its own copy of the placement-column check (it reruns only at
  promotion); switching it to the new helper is a one-line follow-up if wanted.

## Phase 1: Batch 1 — evidence-build and test fixes (#136, #142)

- [ ] Tests first (`tests/testthat/test-archive.R`): `run_fx()` writes a real `sites.rds` (data frame: `site_visit` and
      the five placement columns) and an `fdis_sites.csv` from it; new tests that (a) a plan on a tagged evidence
      directory with no `fdis_sites.csv` reads it from `sites_dir` and its MANIFEST/evidence id equals the default
      build's with the same files; (b) a `fdis_sites.csv` with a row missing, a duplicate `site_visit`, or one placement
      column changed is refused, naming `0240`; (c) a restore into a checkout whose `data/fdis/derived/fdis_sites.csv`
      has other bytes refuses and writes nothing. Watch them fail first.
- [ ] `R/archive.R`: `.knw_archive_evidence_files` gains a source column (`evidence` / `build` / `sites`) beside the
      target `dir`, same row order; `knw_archive_plan()` gains `sites_dir`, reads `fdis_sites.csv` from it, and, after
      `sites.rds` is held to the ledger, holds `fdis_sites.csv` to that `sites.rds` through a new
      `.knw_archive_sites_check()` (one row per site, same site set, `flag_far_snap`, `flag_ws50_mismatch`,
      `snap_confirmed`, `snap_moved`, `blue_line_key` equal). Roxygen for the new argument; `devtools::document()`.
- [ ] `scripts/0336-archive.R`: pass `SITES_DIR`; header INPUT/RUN say `fdis_sites.csv` comes from
      `data/fdis/derived` whatever `EVIDENCE_DIR`.
- [ ] `data-raw/minimal_network_check.R`: `say()` and `block()` append to the log as they go (file created at start), and
      step 3's refusal is said to the log before it stops, so steps 1 and 2 survive a refusal.
- [ ] `tests/testthat/test-link_place.R`: `skip_if(nrow(one) == 0, …)` naming an empty schema or a missing BULK group.
- [ ] Docs: `research/run_archive.md` (evidence folder: where `fdis_sites.csv` is read from and what it is held to);
      CLAUDE.md only if a sentence there states the old behaviour (grep found none).

## Validation

- [ ] Tests pass (`devtools::test()`, failures and errors counted), lintr unchanged per file
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- Archive: the new tests, each mutation-checked (remove the check / point back at `evidence_dir` → red). Live, no
  upload: `RUN=20261105_0436 EVIDENCE_DIR=data/fdis/derived_parent DRY=1 Rscript scripts/0336-archive.R` with the
  hand-copied `derived_parent/fdis_sites.csv` moved aside; the evidence id printed must equal the one
  `data/archive_index.csv` already holds for that build.
- `minimal_network_check.R`: run it on `derived_zz415_default` vs `derived_zz415_minimal` with a scratch copy of
  one `access_check.csv` lacking `watershed_group_code`; the log must hold steps 1 and 2 and the refusal.
- #142: the suite on this machine's database (`PGSERVICE=fresh_local`), plus a scratch-copy mutation of the query to a
  group with no rows, which must report SKIP with the reason, not ERROR.
