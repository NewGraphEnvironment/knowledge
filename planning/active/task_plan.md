# Task: Tune chinook rearing on minimal segments and map how the cuts move the result (#120)

From #92 the tuning reads link's segment gradient. link cuts a segment at fish records of the species it models, so
the gradient at a site that caught fish is averaged over a stretch that starts there: on the tuning's stream branch
86 % of visits with a catch start a segment of their own against 10 % of empty ones (median 113 m against 305 m;
link 0.66.0's build, every observation a break). Crossings and habitat end points cut segments too: not at catches,
but at places unrelated to the stream's form. Chinook rearing's rule moved when the gradient source changed (#92),
so the tuning is sensitive to how segments are cut.

Tuning on segments cut only at barriers and access gradients removes the catch from the predictor. But link deploys
a rule on its full network, where segments are shorter and their gradients differ, so a rule tuned on the minimal
network does not transfer cleanly unless each full segment carries its minimal parent's gradient. That is link's
half: link#415 built `default_minimal` (link 0.78.0, fresh 0.52.0, token `cut-min`) and proved it on BULK, SETN,
MORK and COTR; the parent attributes on the full network are link#444 (open); the province-wide
`fresh_default_minimal` is link#441 (open, not yet run).

Branch `120-tune-chinook-rearing-on-minimal-segments` off `origin/main` at `6b7c31d` (v0.4.22). Parked at the
baseline on 2026-11-02; the resume block is in `progress.md`.

## Decided at the gate (Al, 2026-11-02)

- **D1. The four-group test runs on m4's local fwapg**, where link's proof schemas `zz415_default` and
  `zz415_minimal` live (`localhost:5432`, 2.6 ms), reached with `PGSERVICE=fresh_local`; they stay until the
  provincial run fills `fresh_default_minimal`. Not rebuilt, not dropped by us. (My first probe reached m1 through
  `~/.Renviron`'s `PG*` and read link's stale README line "dropped when the write-up lands" as a fact.)
- **D2. Scope:** Phases 1–4 (mechanics, the four-group test, its write-up) land as this PR; the province and the
  every-setup chinook report (Phases 5–6) run on a second branch of this issue when link#441 and link#444 land, the
  issue staying open with those checkboxes.
- **D3. link to the latest (0.78.1) on both machines**, this one and m1 (installed 0.75.0 here; `0310` reads the
  installed `default` config for species range and pooling, and the minimal build's `species_modelled.csv` is
  0.76.0+).
- **D4. Fully local: no step of this issue reaches m1.** Every database command carries `PGSERVICE=fresh_local`; the
  latency check (#110) refuses `0310`, a grading `0320` and every `0330` stage that lands on m1 by accident (51 ms
  from here); `DEV=1 0320` needs no database. The one remnant of m1 is the flow load: m4's `discharge` is wet's
  2026-10-15 build, m1's the 2026-10-19 one the published grades name, so Phases 5–6's "one flow load" means
  loading wet's current build on m4 (`wet_db_load()`), never reaching across.
- Mechanism (mine): `MIN_WSG=4 FOLDS=4` for the four-group runs, named in every log and summary; the tagged-ledger
  naming; `DEV_DIR=`; `POLL_MIN=` on `0300`.

## What the exploration found (changes the issue's plan; the evidence is in findings.md)

1. link's tokens are on `<schema>.log`, not `log_recompute`; `knw_build_record()` reads the wrong table and
   `test-build_record.R` could not see it. The read cannot be keyed on `log_recompute`'s run (a proof build's `log`
   run_uid is `415_default`, its recompute's `415_recompute_default`).
2. Four groups cannot be fitted as the code stands: `knw_tune_run()`'s floor is `max(min_wsg, folds)` = 5.
3. `0310` and `0320` hard-code `data/fdis/derived` and "the newest ledger"; the local `data/fdis/derived` is
   byte-identical to the published build's evidence, so a test build there would destroy it. Every DEV run writes
   `data/tune/dev`.
4. `0300` is hard-coded to `fresh_default` and polls 10 min × 3. The settle log's schema is a record, never a
   gate (the published build ran `SCHEMA=fresh_default_20261017` against a `fresh_default` settle log): `run_uid`
   is the gate.
5. `0330` already reports `stored_km` and `stored_vs_default_differ_km` per group.
6. `knw_link_access_check()` has no group column, so it cannot say where two networks differ.
7. The parent-gradient setup's grade and comparison need link#444's `streams_parent`; its pick needs only the csv
   join, and a visit on a straddling full segment can read the other minimal segment's gradient (count those).
   "Minimal, other access classes" needs a link build that does not exist; "fixed window" waits on fresh#257 (#70).
8. `grad_parent/` is never promoted (`knw_tune_promote()` knows `grad_fwa/` only); nothing in this branch archives
   a setup. Default-directory readers (`0325`, `0330`, `0335`, `vignette_method.R`) go through `knw_run_ledger()`
   and stay unchanged under a tagged ledger name.

## Phase 1: Read link's tokens from `log`, and name a build's evidence directory

- [x] `knw_build_record()` reads `token_cut/acc/grad/flow` from `<schema>.log`: one distinct value per axis over
      every row; two values refused; a mix of NULL and valued rows refused ("n of m rows carry no cut token: not
      one build"); a `log` without the columns gives `NA` (before link 0.70.0); the run check stays on
      `log_recompute`; roxygen names which table carries what
- [x] `test-build_record.R`: the mock answers by table name for both the column query and the token query, so a
      reader asking `log_recompute` gets nothing; restore the defect and show the test goes red
- [ ] `EVIDENCE_DIR` on `0310` (default `data/fdis/derived`): the ledger gains an `evidence_dir` info row and is
      named `<date>_evidence_build_ledger.csv` for the default directory and
      `<date>_evidence_build_ledger-<basename>.csv` otherwise (the `_refused.csv` pattern), outside today's
      readers' pattern; its `_refused` twin follows
- [ ] `.knw_evidence_ledger(evidence_dir)` (internal): the newest ledger by that pattern; `0320`, `0330` and
      `data-raw/segment_gradient_check.R` take `EVIDENCE_DIR` and find their ledger through it; `0320` writes
      `evidence_dir` into each key's summary (no grade-record column: `knw_grade_record_read()` would refuse the 8
      tracked records); `knw_run_ledger()` unchanged
- [ ] `DEV_DIR=` on `0320` (default `data/tune/dev`), so two DEV runs on two schemas keep their tables
- [ ] Tests on fixtures: the ledger finder (two ledgers one day, tagged and plain); `scripts/README.md` rows; the
      `CLAUDE.md` paragraph "A run's record travels with its table"

## Phase 2: The settle gate, the floors, and the gradient reads the setups need

- [ ] `0300` takes `SCHEMA` (default `fresh_default`) and `POLL_MIN=` (default 10, logged), writes a `schema`
      column, names its log `<date>_link_settle-<schema>.csv` when not the default
- [ ] `0310` takes `SETTLE=<path>` (default the newest `_link_settle.csv`), ledgers the path, the settle log's
      `schema` (a log without the column is `fresh_default`'s) and whether it was overridden; the gate stays
      `run_uid` (`knw_build_record()`), never the schema name (the rename path); link floor 0.78.1
- [ ] `0310` ledgers the schema's own species (`log.species`) beside `knw_species()`
- [ ] `knw_link_access_check(by_group = )`: the cross-tabulation per group, so two networks' km can be set beside
      each other where they differ; `0310` writes the per-group table to `access_check.csv` (+ test)
- [ ] `0310` takes `PARENT_DIR=` (link's `data-raw/logs/minimal_breaks_415/`, later link#444's export): joins
      `parent_<wsg>.csv.gz` on `id_segment` + `wsg` to add `parent_gradient`, `parent_length_m` and
      `parent_straddle_m` to `visits_link.csv`; a placed visit with no parent row stops the run; counts ledgered.
      Pure `knw_parent_join(visits, parent)` + test. Without `PARENT_DIR` the columns are absent
- [ ] `0320`: `GRADIENT=parent_gradient` joins `grad_dirs` as `grad_parent` (main seed only, no grades, like
      `grad_fwa`; never promoted, said in the header); refused when the evidence has no such column
- [ ] `0320`: `MIN_WSG=` and `FOLDS=` (defaults 5), passed to `knw_tune_run()`, named in the log and written to the
      summary; `knw_tune_promote()` refuses a summary whose floors are not the defaults (+ test)
- [ ] `data-raw/segment_gradient_check.R`: `EVIDENCE_DIR`, and its log name through `.knw_free_path()`
- [ ] `scripts/README.md` rows for `0300`, `0310`, `0320`

## Phase 3: The four-group test on m4 (`zz415_minimal` against `zz415_default`)

`PGSERVICE=fresh_local`, `SPECIES=BT,CH,CM,CO,GR,PK,SK,ST,WCT`, `MIN_WSG=4 FOLDS=4`; every log says so. link 0.78.1
and fresh 0.52.0 installed first (D3).

- [ ] Before anything: `pg_stat_activity` quiet; both schemas' `log_recompute.date_end` set on all four groups
      (they are, 2026-11-02); the installed link is 0.78.1
- [ ] `SCHEMA=zz415_default` then `zz415_minimal` through `POLL_MIN=1 0300` → `0310`
      (`EVIDENCE_DIR=data/fdis/derived_zz415_{default,minimal}`, `PARENT_DIR` on the full one); ledgers committed
- [ ] Placement: `data-raw/minimal_network_check.R` (new) reads both `visits_link.csv`: every visit on both
      networks at one `blue_line_key` and measure, only `id_segment` differing; `walks.csv` identical rows
      (the walk reads FWA and discharge only); the per-group access tables beside each other; visits on straddling
      full segments counted → `scripts/logs/habitat/<date>_minimal_network_check.txt`
- [ ] The premise: `segment_gradient_check.R` on both builds; the 86 % / 10 % gap must close on the minimal
      network; if it does not, stop here and report
- [ ] `DEV=1 0320` on each build (`DEV_DIR=data/tune/dev_zz415_{default,minimal}`): four smoke gates pass for every
      key, a key with no records says `too_few_groups`, minutes per key logged; `GRADIENT=parent_gradient` and
      `GRADIENT=fwa_gradient` on the full build: the picks of four setups side by side, "minimal" against
      "full, parent gradient" with the straddling visits named
- [ ] `RUN=<stamp> SPECIES=CH 0320` (grades) then `0330 TUNE_DIR=… SPECIES=CH` on each schema:
      `CH_rear_compare.csv`'s `stored_km` against the issue's figures (BULK 2,205, COTR 1,419, MORK 2,528,
      SETN 1,018) and `stored_vs_default_differ_km`; the GeoPackages for QGIS
- [ ] `EVIDENCE_CHECK=FALSE EVIDENCE_DIR=… data-raw/site_gradient_check.R` on the minimal build beside
      `scripts/logs/habitat/20261030_site_gradient_check.txt`

## Phase 4: Write-up of the test, and the issue body

- [ ] `research/minimal_network_tuning.md` (new; `research/README.md` row): each check's result with its log
      prefix, in the order they were run, including the ones that found nothing; what four groups cannot show;
      the setups table with which this branch scored and what each other waits on; the floors used
- [ ] `data-raw/README.md` rows; `CLAUDE.md` working notes: tokens on `log`, a build names its evidence directory,
      the settle log names its schema, the floors are the test's, m4's local database through `PGSERVICE`
- [ ] Issue #120 body: "clear first" items ticked with what was found, Phases 5–6 kept as checkboxes, D1–D4 recorded;
      link#444's acceptance line answered in link#444's body in words

## Phase 5 (second branch of #120, after link#441): the province

- [ ] `0300` → `0310` on `fresh_default_minimal` (`EVIDENCE_DIR=data/fdis/derived_minimal`), `DEV=1 0320` on the
      nine species, the pick report beside the published one, reported; the full retune and any promotion on Al's word

## Phase 6 (second branch, after link#444): chinook rearing on every setup

- [ ] published / minimal / full-parent / Atlas-line picks from one evidence build and flow load; km drawn and
      graded through `0330` where a grade exists; the GeoPackage and one static figure of where the habitat drawn
      differs (`knw_compare_map()`); each archived by #119's layout with link's tokens (a knowledge-side gradient
      read gets its token from link's vocabulary, not invented here); `research/` and a short section of the
      methodology article

## Owed at the end (reported, done after merge)

- [ ] Phases 5 and 6 on their own branch when link#441 / link#444 land (carried in the issue body); before them,
      wet's current build loaded on m4 so the published and minimal setups share one flow load
- [ ] Memory `db-host-runs-from-worktree` revised: this issue's database is m4's local fwapg
      (`PGSERVICE=fresh_local`); m1 is not reached

## Validation

- [ ] Tests pass (`devtools::test()`: build record by table, ledger finder, settle schema and override, parent
      join, `GRADIENT` value, floors refused by promotion, access check by group); `lintr::lint_package()`;
      `R CMD check` in CI
- [ ] Mutations: the `log_recompute` token query put back fails `test-build_record.R`; a summary with `folds = 4`
      fails `test-tune_promote.R`
- [ ] Phase 3's artefacts: ledgers and check logs under `scripts/logs/habitat/` (committed), DEV tables and
      candidates (ignored) listed in `progress.md` with md5s; every acceptance line names the floor it ran under
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
