# Task: Backlog move 6: Where records sit: the site-visit table, and whether one flow per segment is fine enough (#175)

**If we do it:** each FDIS visit joins its bcfishobs records with a span on the network, and we know whether discharge resolution adds error beyond where records already sit. **If we never do:** location error and flow-resolution error stay unmeasured beside each other.


## Context

Backlog move 6 carries two batches, landed in one PR:

- **Batch 18, the FDIS load's outputs (#225, #214).** The per-pass tables already exist inside `0230` but are summed away before anything is written. Their reader is a private detection package's issue, whose own gate settled that knowledge publishes the passes and the package reads them. Separately, `fish.rds` is read by `0320` and `vignette_method.R`, yet `0336 PULL=TRUE` does not restore it.
- **Batch 10, location error against flow resolution (#23 cut, #137).** We want to know how much error one discharge value per FWA segment adds, measured against the error already in where a record sits. #23's span and its downstream-end check are the yardstick #137 needs.

What exploration found:

- **The kept visits.** `0230` keeps visits by dropping the #35 repeats at lines 428-431. Those lines filter `sites`, `catch`, `fish` and `counts`, but **not `passes`**.
  - `passes` (141-153) has no width, method or pass number; `visits.csv` carries `METHOD_NUMBER`, `HAUL_OR_PASS` and `FISHING_AREA_WIDTH`.
  - Per-pass counts (224-230) sit at pass × species × age grain.
  - The missing-or-short count rule (261-268) runs per visit × species.
- **`fish.rds` is byte-stable.** All 12 ledgers carry `md5_fish 8cf273515ce2b692c3719130eac75b93`, including the 2026-10-27 rebuild where `md5_sites` moved. `fish.rds`'s row order is deterministic.
- **The archive.** `R/archive.R`'s `.knw_archive_evidence_files` lists 6 files; adding one changes the `evidence_id`. The published tables name link run `20261102_203300-60ab009d`, whose evidence is archived as `3d907629…` without `fish.rds`.
- **v3.** It is unpublished and hard-coded as `tables_v3` in `scripts/0299` (11 tables). It is mirrored in `inst/receipt/fdis.yaml`, and `test-receipt.R:135` pins the count.
- **#23's join key already exists** (`knw_bcfishobs_match()`, `bcfishobs_fdis_match.csv`, which carries both points' blue line and measure). No `upstream_route_measure` exists anywhere in the FDIS path, and `fdis_export.md` says nothing about the downstream-end assumption.
  - `.knw_archive_sites_check()` compares only the columns `fdis_sites.csv` shares with `sites.rds`, so a span column added by `0240` passes it.
- **#137.** Every discharge read is one annual value per `linear_feature_id`, and nothing in the repo measures within-segment variation.
  - `fwa_watersheds_upstream_area`, `fwa_streams_watersheds_lut` and `fwa_watersheds_poly` are on this host's database. Its flow comment names wet's 2026-10-24 build, `scenario historical`.
  - Yardsticks already measured: source error (pick MAE 23 %) and the two sources' disagreement (same MAD class 53–67 % at 0.1–1 m³/s).
- **This machine (m1).** Its `data/fdis/derived` is an older build (2026-10-22), so every evidence-based measurement runs on the published evidence, restored with `0336 PULL=TRUE` into a scratch worktree.

## Decided at the gate (Al, 2026-11-19)

- **Per-pass tables join `knowledge/fdis/v3`** before its first upload, making 13 tables with no version bump. They reach the bucket when #219 uploads v3.
- **#23 is cut** to the span and the downstream-end check, with match rates. Age-class counts and the workbook second source go to a new issue naming move 6, left out of `planning/backlog.md` for the next sweep. #23 closes with this PR.
- **Re-archive the published evidence in this PR** with `fish.rds`. This makes a new evidence id in the bucket's private `archive/knowledge/` and new rows in `data/archive_index.csv`, so `PULL=TRUE` restores `fish.rds` for the published run.
- **No retune and no promotion.** #137's third question is answered with a count of flips at the published thresholds, not a regrade. A change to how flow is given waits on Al's word, through its own issue.

## Phase 1: per-pass tables (#225)

- [x] Read the private consumer's reader and its pass-table design before fixing columns. It needs:
  - a "no fish caught" pass told apart from a pass with no catch record;
  - the raw species code, so its blocking rules apply per pass.

  Nothing private is named in tracked text.
- [x] Tests first: `tests/testthat/test-fdis_passes.R`, on hand-written passes covering:
  - two passes of one visit;
  - a multi-method visit;
  - a pass with only NFC;
  - a pass with no counts row;
  - a sentinel count;
  - a count below the measured fish;
  - age rows summed;
  - a dropped repeat visit absent.
- [x] `R/fdis_passes.R`: `knw_fdis_passes(visits, counts, fish, keep)` returns two frames.
  - `passes`: one row per kept pass, with site_visit, method_number, haul_or_pass, date, fishing_time_s, fished_length_m, width_m, area_m2, the effort sentinel flag, `catch_record` and `no_fish_caught`.
  - `pass_catch`: one row per pass × species code with `n_caught > 0`. It applies the visit table's missing-or-short rule per pass, after summing age rows, and carries `n_measured` and the flags.
  - Roxygen states that summing `pass_catch` over passes need not equal the visit's `n_caught`, because a maximum of sums is not a sum of maxima.
  - A runnable example.
- [x] `0230` calls it on the kept visits and writes `data/fdis/build/{passes,pass_catch}.rds`. `sites`, `catch` and `fish` are untouched.
- [x] `0240` writes `data/fdis/derived/{fdis_passes,fdis_pass_catch}.csv`.
- [x] Wire the tables into v3:
  - two rows in `0299`'s `tables_v3`, plus its header and note;
  - two tables in `inst/receipt/fdis.yaml` (exact);
  - `test-receipt.R` 11 → 13;
  - a v3 section in `data/fdis_README.md` naming the per-pass tables and the caller's choice of which passes form one closed population.

## Phase 2: archive fish.rds (#214)

- [ ] Tests first in `test-archive.R`:
  - `fish.rds` in the evidence MANIFEST;
  - a plan refused when `fish.rds`'s md5 is not the run ledger's `md5_fish`;
  - a pull that restores it.

  Update the fixture and the 6-row and MANIFEST-tail expectations.
- [ ] `R/archive.R`: add `fish.rds` (build) to `.knw_archive_evidence_files`, held to the ledger's `md5_fish` as `sites.rds` is held to `md5_sites`.
- [ ] Update `scripts/0336-archive.R`'s header and the `CLAUDE.md` line saying PULL does not restore `fish.rds`. Name `0230` as the only remedy for a build archived before this change.
- [ ] **Rerun `0230` then `0240` on this host's database.** Confirm byte-identical `sites.rds`, `catch.rds` and `fish.rds` against the published run's ledger (`md5_sites`, `md5_fish`; `catch.rds` against the current file).
  - If `sites.rds` differs, stop: placement is not reproducing on this database, and nothing is archived or published from the rerun. The finding goes to #214 and the PR.
- [ ] **Re-archive** the published evidence:
  1. Make a scratch worktree at the branch tip.
  2. Restore evidence `3d907629…` with `PULL=TRUE` there.
  3. Copy in the verified `fish.rds`.
  4. Run `0336` to archive it, giving a new `evidence_id`.
  5. Commit `data/archive_index.csv`.
  6. Prove the round trip with a pull into a second empty worktree, `fish.rds` md5 equal.

## Phase 3: the site span and where the record sits (#23, cut)

- [ ] File the split issue (age-class counts per visit; the workbook second source after #21's parser), naming move 6. Rewrite #23's body to the cut scope, with a link to it.
- [ ] Tests first for the span: a span capped at the blue line's top, and a missing or sentinel fished length.
- [ ] Add the span columns to `0240`'s `fdis_sites.csv`. It already connects to the database for the basin; the same query reads each blue line's top measure.
  - `upstream_route_measure` is `downstream_route_measure + fished_length_m`, capped at the line's top.
  - `flag_span_capped`.
  - NA where the length is missing or a sentinel.
- [ ] `data-raw/fdis_downstream_end_check.R` (no database) runs on the published evidence's `bcfishobs_fdis_match.csv` and `fdis_sites.csv`:
  - match rates by species and class;
  - for one-to-one matches on the same blue line, where the bcfishobs point sits against the visit's span (below it, at the downstream end within 5 m, inside it, above it), with offsets as a share of fished length;
  - logged to `scripts/logs/fdis/<date>_fdis_downstream_end_check.txt`.
- [ ] `research/fdis_export.md`: a section on the site span and where a record sits, with the match rates and the check's verdict.

## Phase 4: one flow per segment (#137)

- [ ] `data-raw/segment_flow_resolution_check.R` runs on this host's database: the published build's network, the flow load read from the table comment and logged, and a logged `pg_stat_activity` check.
  - **Question 1.** Per FWA segment, the upstream area at its downstream end (`fwa_watersheds_upstream_area` through `fwa_streams_watersheds_lut`) against that minus its local fundamental watershed. That gives an area-scaled MAD at top against bottom: the share of change, province-wide, by edge type, and by MAD class (0.1–1 and 1–10 m³/s).
  - **Question 2.** At each published visit, the area-scaled flow change from the record's point to the top of its fished span, inside the segment and where the span crosses into the next one. Set against the segment value and against the two yardsticks: source error, and the two sources' disagreement.
  - **Question 3.** The share of visits whose class at each published flow threshold flips when flow is read at the record's point or at the span's midpoint instead of the segment. The thresholds are CH rearing 0.75, ST 0.5, BT 0.35 and CO 0.1 m³/s.
  - Batched queries; logged to `scripts/logs/flow/<date>_segment_flow_resolution_check.txt`.
- [ ] `research/discharge_resolution.md` (new), led by a plain-language walk then the numbers:
  - whether segment resolution adds error beyond placement and source error;
  - what point flow would move.

  Add it to `research/README.md`. If it matters, file the follow-up issue for point flow (it would regrade every key, so it waits on Al); otherwise #137 closes on the verdict.

## Phase 5: close out

- [ ] Update `CLAUDE.md`'s FDIS and archive lines, `scripts/README.md` (`0230` and `0240` outputs, the two data-raw checks) and `research/README.md`.
- [ ] `/code-check branch` (three-round floor); `lintr` per-file diff against main; `devtools::test()`; `pkgdown::check_pkgdown()` for the new export.
- [ ] `/planning-archive`, then `/gh-pr-push`.

## Owed at the end (reported, done after merge)

- [ ] #219's upload of v3 carries the two per-pass tables; tell the private consumer's issue that they exist.

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:

- **Per-pass rule.** Hand-written fixtures; on the real build, the per-pass tables against the visit tables:
  - every kept visit's pass count equals `n_pass`;
  - fishing time and area sum to the visit's;
  - every visit × species with catch has pass rows;
  - per-pass sums at or above the visit's `n_caught` only where the rule says so, counted and logged.
- **Nothing published moves.** `sites.rds`, `catch.rds` and `fish.rds` are byte-identical after the rerun; the evidence md5s in `thresholds.csv` are untouched.
- **Archive.** Each new guard shown red by restoring the defect. The round-trip pull from the bucket gives an equal md5.
- **Span and downstream-end.** Fixture tests; the check's counts sum to the matched population.
- **Flow resolution.** Each logged figure is re-derivable from the log's queries. The flip counts use the published `thresholds.csv` values, read, not typed.

