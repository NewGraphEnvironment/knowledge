# Findings — Tune chinook rearing on minimal segments and map how the cuts move the result (#120)

## Issue context

**If we do it:** we learn how much the places link cuts streams (fish records, crossings, habitat end points) move each species' tuned thresholds, starting with chinook rearing, and we can map where the habitat drawn differs, so the trade-off between tuning on an ideal network and deploying on a connectivity network is measured and stated. **If we never do:** every threshold rests on segments partly cut at the catches that score it, and nobody can say whether that matters or where.

## Problem

From #92 the tuning reads link's segment gradient. link cuts a segment at fish records of the species it models, so the gradient at a site that caught fish is averaged over a stretch that starts there: on the tuning's stream branch 86 % of visits with a catch start a segment of their own against 10 % of empty ones (median 113 m against 305 m; link 0.66.0's build, every observation a break). Crossings and habitat end points cut segments too: not at catches, but at places unrelated to the stream's form. Chinook rearing's rule moved when the gradient source changed (#92), so the tuning is sensitive to how segments are cut.

Tuning on segments cut only at barriers and access gradients removes the catch from the predictor. But link deploys a rule on its full network, where segments are shorter and their gradients differ, so a rule tuned on the minimal network does not transfer cleanly unless each full segment carries its minimal parent's gradient. That is link's half: NewGraphEnvironment/link#415, with outputs named from NewGraphEnvironment/link#414. The minimal network still cuts at access gradients, and those cuts depend on which species link models and at which classes (0.15, 0.20, 0.25), so pausing a species (NewGraphEnvironment/link#432, NewGraphEnvironment/link#433) or changing a class moves the segments a minimal-network tuning reads; #132 reviews the classes themselves.

## Proposed

- [x] The minimal network: NewGraphEnvironment/link#415 (closed) built `default_minimal` (link 0.78.0, fresh 0.52.0). Parent attributes on the full network moved to NewGraphEnvironment/link#444 (open); its prototype is link's `data-raw/logs/minimal_breaks_415/parent_<wsg>.csv.gz`, each full segment with its minimal parent's gradient and length.

### Before the province-wide minimal run: test on link's four groups

link's proof schema `zz415_minimal` holds the minimal network for BULK, SETN, MORK and COTR, recomputed, with the tables a provincial build writes, and every log row carries the tokens `cut-min acc-v5 grad-seg q-fwapg`. `zz415_default` holds the same groups on the full network from the same commit. Both are scratch: pass the schema as `SCHEMA=`, never hard-code it, and point at `fresh_default_minimal` once the provincial run lands. link's caveat: each group was built without its downstream neighbours, so only access read through another group's dams may be incomplete. Species: the run's list, BT, CH, CM, CO, GR, PK, SK, ST and WCT (no RB or KO). Four groups hold too few records for a threshold, so these check mechanics, not results.

Clear first (from the code, 2026-11-02):
- [ ] `0310` runs only after `0300` released, and `knw_build_record()` refuses a schema built by another run: give the test run an explicit, logged override that is never the default
- [ ] The test database holds what `0310` reads besides the schema: wet's segment flows with a table comment naming `scenario historical` (`knw_discharge_load()`), cabd, bcfishobs and the FDIS tables. Run on the database's own host
- [ ] link's tokens land in `log_recompute`'s `token_cut`, `token_acc`, `token_grad` and `token_flow`, which `knw_build_record()` reads, and the grade record writes them

Checks, `zz415_minimal` against `zz415_default`:
- [ ] Placement: every FDIS visit in the four groups lands on both networks at the same stream and measure; only the segment id differs
- [ ] The premise: `data-raw/segment_gradient_check.R` on both networks. On link 0.66.0's full network 86 % of visits with a catch started a segment of their own against 10 % of empty ones; on the minimal network that gap should close. If it does not, stop here
- [ ] Access: `knw_link_access_check()` per species. A difference anywhere but at dams read through a neighbouring group is a finding
- [ ] Walks: the cache is keyed on stream and measure, so visit walks are reused, and walks from a segment's downstream end miss where segments lengthen. The walk results themselves do not change
- [ ] `DEV=1 SCHEMA=zz415_minimal SPECIES=BT,CH,CM,CO,GR,PK,SK,ST,WCT 0320`: all four smoke gates pass for every key, a key with no records in these groups says so rather than failing, and minutes per key are logged to time the provincial run
- [ ] `0330` for CH rearing on the minimal schema: does `default`, regenerated through all three stages, reproduce link's stored km (rearing BULK 2,205, COTR 1,419, MORK 2,528, SETN 1,018)? If not, know why before the province
- [ ] The parent join: every full segment gets a parent from `parent_<wsg>.csv.gz`, and "full, parent gradient" picks the same rule as "minimal" (the setups below)

Then the province, once `fresh_default_minimal` lands: `0310` and `DEV=1 0320` with the same species, and the pick report (each key's pick beside the published one). The full retune and any promotion wait on Al's word.

### Chinook rearing on every setup

- [ ] Chinook rearing, one key, scored on every setup from one evidence build and flow load, so the network and gradient are the only differences:

  | Setup | Segments | Gradient read |
  |---|---|---|
  | published | full | its own segment |
  | minimal | minimal | its own segment |
  | minimal, other access classes | minimal, cut at another access-gradient set (a species paused, or classes independent of species) | its own segment |
  | full, parent gradient | full | its minimal parent's |
  | Atlas line | full | the whole Atlas line (today's `grad_fwa`) |
  | fixed window | full | a fixed window (#70, when fresh provides it) |

  "Minimal" and "full, parent gradient" read the same gradient at every visit, so their picks should agree; where their drawn km differ is the transfer cost.
- [ ] Rerun #121's measured-gradient comparison on the minimal network's visit table, beside its full-network result: `EVIDENCE_CHECK=FALSE EVIDENCE_DIR=<minimal network's build> Rscript data-raw/site_gradient_check.R` (the full-network result is `scripts/logs/habitat/20261030_site_gradient_check.txt`). One run covers "full, parent gradient" too, since both read the same gradient at every visit. The difference is what link's cuts at catches do to how well the gradient a rule reads matches the gradient measured on site.
- [ ] Report per setup: the pick, whether the published rule is in its region, km drawn and graded, and a map of where the habitat drawn differs (a GeoPackage for QGIS, as `0330` writes, and one static figure).
- [ ] Each setup archived and indexed by #119's layout (`tune/CH_rear/<setup tokens>/`), its tokens from NewGraphEnvironment/link#414.
- [ ] `research/` gains what each break source does to the tuning, and the trade-off between the network a rule is tuned on and the one it is deployed on; the methodology article gets a short section once the result holds. Other species follow one at a time.

Relates to #70 (fixed-window gradients), #92 (segment gradient), #121 (measured gradient), #119 (storage layout and run index).


## Exploration, 2026-11-02 (plan mode; every probe read-only)

### link's tokens are on `log`, not `log_recompute`

- link `R/lnk_log.R:344-347` (origin/main, 0.78.1): `token_cut`, `token_acc`, `token_grad`, `token_flow` in
  `cols_log`, "one token per axis from lnk_vocabulary_resolve()"; `cols_log_recompute` (`:387`) has none.
- `R/build_record.R:40-56` queries `information_schema.columns … table_name = 'log_recompute'` for the token
  columns, so on every tokened build the record reads "none (before link 0.70.0)". `test-build_record.R:7,30`
  mocks on `information_schema` and `DISTINCT token_` without the table name.
- m4's `zz415_minimal.log`: run_uid `415_minimal`, tokens `cut-min acc-v5 grad-seg q-fwapg`, 4 rows, none NULL;
  its `log_recompute` run_uid is `415_recompute_minimal`. A provincial run (m1's `fresh_default`, 20261023)
  uses one uid for build and recompute. So the token read is over every `log` row, not keyed on the recompute's
  run.
- Consumers of `rec$tokens`: `0320:420-422` (the grade record). `0330:206` and `0336:64` call
  `knw_build_record()` for `run_uid`, `discharge_load`, `walk_md5`. `data-raw/archive_seed.R:63` hard-codes NA
  tokens. The published `CH_rear_grades_record.csv` carries blank tokens (`record_source = backfill`).

### Where the schemas are

- m1 (what `~/.Renviron`'s `PG*` reach; 51 ms round trip from here): `fresh_default` (run
  `20261023_074321-24d85e8c`, link 0.68.0, fresh 0.42.0, 241 groups, hosts m1 + three cloud workers),
  `fresh_default_20261017` (the published tune's, link 0.66.0), `knw` (walk cache 8,274,143 rows); wet's flows
  commented "built 2026-10-19T06:08:31Z, wet 94deeb5"; no `zz415_*`.
- m4, local fwapg (`PGSERVICE=fresh_local` → `localhost:5432`; 2.6 ms): `zz415_default` and `zz415_minimal`
  (BULK, SETN, MORK, COTR; link 0.78.0; `date_end` set on all four; `log.species` BT, CH, CM, CO, PK, SK, ST; all
  eleven `access_<sp>` columns present), `fresh_default_minimal` (no `log_recompute`: empty, awaiting link#441),
  `fresh_pretest_default_minimal` (11 log rows, the gate's), a 4–7 group `fresh_default` (0.68.6), many
  `working_*` and `zz*` scratch schemas; `discharge.fwa_v1_segment_monthly` commented "built
  2026-10-15T02:06:57Z, wet acb820f" (`scenario historical`); `cabd.dams`, `bcfishobs.*`, the FWA tables; no
  `knw.walk_cache` (created on first use, `R/link_walks.R:41`).
- link's proof README (`data-raw/logs/minimal_breaks_415/README.md:13`) says the schemas are "dropped when the
  write-up lands"; Al (2026-11-02): kept on m4 for review until the provincial run fills `fresh_default_minimal`;
  the line is stale and is link's one-line fix.
- `PGSERVICE=fresh_local` from the shell survives `~/.Renviron` (it sets `PGHOST`, `PGPORT`, `PGDATABASE`,
  `PGUSER`, `PGPASSWORD`, not `PGSERVICE`), and libpq takes the service entry over them: measured, the
  connection landed on the local database with `zz415_minimal` present.

### Four groups and the tuning's floors

- `knw_tune_run(min_wsg = 5L, folds = 5L)` (`R/tune_run.R:102-103`); `if (n_both < max(min_wsg, folds))
  rec$status <- "too_few_groups"` (`:183-186`); `0320` passes neither. The smoke run iterates `names(prep)`
  (`:194-198`), so on four groups nothing is scored, no `_curve.rds` or grade is written, and `0330` (`:139`,
  `fitted` keys) finds nothing. `folds` is in the score cache's `spec` (`:228`).

### Paths every build shares

- `0310:75` `dir_out <- "data/fdis/derived"`, `:77` the ledger `scripts/logs/habitat/<date>_evidence_build_ledger.csv`
  (`_refused.csv` twin, `:109`). `0320:161` the newest `_evidence_build_ledger\.csv$`, `:166-170` and `:195-198`
  the tables; `0330:143-145`; `data-raw/segment_gradient_check.R:38-39, 58-61` (also hard-codes `access_classes`
  `:30` and its log name `:31`). `0320:114` `dir_run <- "data/tune/dev"` for every DEV run.
- The local `data/fdis/derived` md5s (`visits_link`, `visits_species`, `walks`) equal the published
  `CH_rear_grades_record.csv`'s `evidence_md5` (`1bd35829…;009698d7…;99f499bb…`; tune_run `published_20261028`,
  ledger `20261027_evidence_build_ledger.csv`).
- Default-directory readers go through `knw_run_ledger()` (`R/run_ledger.R:24-41`: the path the summaries name,
  the newest plain ledger as fallback): `0325:40`, `0330:133`, `0335:169`, `data-raw/vignette_method.R:57`.
  `0335:70,96,115,146` and `vignette_method.R:59-61,105` hard-code `data/fdis/derived`; `0336:47` takes
  `EVIDENCE_DIR`; `data-raw/site_gradient_check.R:40-42` takes `EVIDENCE_DIR`, `TUNE_DIR`, `EVIDENCE_CHECK`.
- `knw_grade_record_read()` refuses a record lacking any of `.knw_cols_grade_record_extra`
  (`R/grade_record.R:104-105`); 8 tracked records are read by `test-vignette-data.R:122-129`, `R/archive.R:68`,
  `0336:56-58`. `knw_tune_promote()` compares only its `fields` list (`R/tune_promote.R:154`) and promotes
  `grad_fwa/` alone (`:172-181, 250`).

### The settle gate

- `0300:22-23` `poll_min <- 10; polls_stable <- 3`, `:25` `schema <- "fresh_default"`; its log has no schema column.
  `0310:92-98` reads the newest `_link_settle\.csv$`, requires the last row `released`, `:116` passes its
  `run_uid` to `knw_build_record()`, which refuses a schema built by another run. The published build ran
  `SCHEMA=fresh_default_20261017` against the `fresh_default` settle log of 2026-10-17 (the rename path, #73).

### Already answered by the code

- `knw_compare_rules()` writes `stored_km` and `stored_vs_default_differ_km` per group (`R/compare_rules.R:356-359`).
- `knw_link_place()` derives `species_access`/`species_habitat` from the schema's columns (`R/link_place.R:51-53`);
  `knw_link_access_check()` skips a species without both (`R/link_access_check.R:30-33`) but has no group column
  (`:34-44`); a `lnk_species_pooling()` error is caught and ledgered (`0310:147`); a key with no in-range visits is
  `too_few_groups`.
- `knw_tune_run()` takes any `grad` column (`R/tune_run.R:112, 121-123`); `0320:101-102`'s `grad_dirs` is what
  refuses a third `GRADIENT`. `.knw_grade_grad <- "segment_gradient"` (`R/grade_species.R:149`) pins grades to
  the schema's `streams.gradient` (`R/link_segments.R:38`).
- The walk starts from `blue_line_key` + `downstream_route_measure` (`R/link_walks.R:50-51`) and reads
  `discharge` and `whse_basemapping` only (`inst/sql/ch_dist_profile.sql:31-33`): segment-independent.

### link's side (origin/main at 0.78.1; local checkout main at 0.76.0, fetched)

- link#415 closed: `default_minimal` (`inst/extdata/configs/default_minimal/config.yaml`, `extends: default`,
  `schema: fresh_default_minimal`, `break_order` `gradient_minimal`, `falls`, `barriers_definite`); observation
  lifts can move a cut below a record (0 to 1.2 % of km, all bull trout); strict containment does not hold, the
  parent join takes the largest overlap. Proof tables under `data-raw/logs/minimal_breaks_415/` (`status.tsv`:
  builds 2.75–6.55 min per group; `builds.csv` the tokens).
- `parent_<wsg>.csv.gz` (lower case): `id_segment, wsg, id_segment_minimal, gradient_minimal, length_minimal,
  overlap_m, straddle_m`; built by `proof.R:130-185` (`DISTINCT ON (pc.fid) … ORDER BY pc.len DESC`).
- link#444 open: `<full schema>.streams_parent` (`id_segment, watershed_group_code, id_segment_minimal,
  gradient_minimal, length_minimal`, the minimal build's config hash and run); a new `grad` token for the parent's
  gradient; acceptance names knowledge#120's mechanics check.
- link#441 open (umbrella, `track:minimal-run`): phases 0–5 merged (0.78.0, 0.78.1); the run waits on m4's
  bcfishobs checkout and a bchamp check; row 6 is knowledge#120. link#432 (KO, RB paused, `acc-v5`), link#433
  ("off means off": a paused species adds no gradient breaks; 73 groups lose a class).
- `inst/extdata/vocabulary.csv`: `cut-min` (0.77.0), `acc-v5` (0.76.0), `grad-seg`, `q-fwapg`.

### Related knowledge issues

- #70 open (fixed-window gradients; waits on fresh#257). #92 closed (PR #109). #121 closed (PR #123;
  `20261030_site_gradient_check.txt`: CH_rear at 0.11, 4,858 visits, 2,453 measured, flips 6.4 % on the segment
  gradient against 11.6 % on the Atlas line). #119 closed (PR #125; `tune/<key>/<cut>.<acc>.<grad>.<flow>/`,
  `untokened/<tune_run>/` before tokens; `data/archive_index.csv` one row per object). #132 open (the access
  classes; "how the cuts move the tunings: carried in #120 as a setup").

### Stale installs (`check_pkg_stale.sh`, 2026-11-02)

- link 0.75.0 → 0.78.1 (RemoteType local), knowledge 0.4.20 → 0.4.22, cred 0.1.0 → 0.7.0, fly, mc, ngr, spacehakr,
  xciter stale; fresh 0.52.0 and wet 0.4.33 current. link is the one this work uses.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| First database probe reached m1 and found no `zz415_*`; link's README line "dropped when the write-up lands" read as fact | The schemas are on m4's local fwapg (Al); probe there with explicit connection arguments, then `PGSERVICE=fresh_local`; the README line is stale (link's fix) |
