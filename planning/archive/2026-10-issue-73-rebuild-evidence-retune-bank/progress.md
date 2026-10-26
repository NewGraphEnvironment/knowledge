# Progress — Rebuild the evidence and retune on the republished flows, with the walk ending at the river's bank (#73)

## Session 2026-10-22

- Plan-mode exploration — phases approved by user (folds in #68 and #80; #81's run-time pieces; #72's record)
- Created branch `73-rebuild-the-evidence-and-retune-on-the-r` off main
- Scaffolded PWF baseline from issue #73 with approved phases
- Plan review (Plan agent, background) folded in: `review-plan.md`; two defects in Phase 1's first draft fixed from it
- Phase 1 done: the walk ends at the bank and counts hop gaps; checked against fresh 0.42.0 on BULK (`bank` 0 of 2,460)
- Phases 2–5 committed: ladder and flow-start picks, grade provenance, the comparison under three structures against
  link 0.67.0's default, the evidence rebuilt (0310, species tables, local v3 Parquet)
- 0320 SPECIES=CH,CO (8 workers, 67.6 min), then the curve defect: a held-out group's intercept refit ran away
  (`84c3c78`), its helper exported to the workers (`44d0822`), and the rescoring (6 workers, 91.2 min) moved 2,269 CH
  rules and the CH pick (`ca771ca`)
- 0330 SPECIES=CH,CO stopped once the CH pick moved (CO written); 0330 now composes per-species runs; CH rerun alone
- Phase 6 write-up: `coho_rearing_tuned.md` rewritten prior-first; `chinook_rearing_tuned.md`'s head rewritten with
  #54's record kept below; CH and CO rows of `habitat_thresholds_tuned.md`; `research/README.md`
- CH 0330 alone (153.1 min; compose check: CO's rows joined, the six pre-#73 keys left out as intended); the chinook
  comparison section written, structure `both` stated as a decision; CH and CO rows of the changes table
- The hand-off committed (`f00ef42`): the detached chain and the Resume brief below
- Next: the chain (BT 0330, then GR,RB,ST,WCT 0320 and 0330); write-ups per the Resume section

## Session 2026-10-23

- The chinook gradient bands corrected (`cd4084d`: the curve object clamps gradient at 0.2; the bands read `fwa_gradient`)
- link#361's provincial run renamed `fresh_default` to `fresh_default_20261017` at 07:41 UTC under the first chain:
  the bull trout comparison failed on connect and the four-species tuning was stopped; `0320` and `0330` now take
  `SCHEMA` (`468153d`); the second chain (`20261023_chain2_73.sh`) relaunched both at 07:48 UTC on the archived schema
- Bull trout through the comparison (206.9 min, exit 0 at 11:15 UTC; rearing under free and door, spawning under its
  one structure); `research/bull_trout_tuned.md` rewritten prior-first for both stages (227 lines in place of #57/#65's
  72); BT rows of `habitat_thresholds_tuned.md` (Results, 1.96, Grades, changes table, points 1–4's BT figures);
  `research/README.md`'s row; Phase 7's BT box ticked
- Next: the four-species tuning (running since 07:48 UTC) and comparison under the chain; their write-ups per the Resume
  section; then the `habitat_thresholds_tuned.md` rewrite and Phase 8

- Rainbow deferred (Al, 2026-10-23): its scoring alone took 07:48–15:52 UTC on 6 workers, the scorer's fold fit
  carrying one dense column per group (#83 filed). The chain's wrapper stopped at 15:55 UTC before its four-species
  `0330`, the `0320` run (pid 78028) left to finish and grade all four; the comparison then runs by hand as
  `SCHEMA=fresh_default_20261017 SPECIES=GR,ST,WCT 0330`, its stdout `20261023_0330-gr_st_wct.out`. #73's body
  and the plan say so; findings, "Rainbow deferred"

- The four-species scores were impossible (GR no-rule 8,397 against #57's 848); replayed, the intercept minimiser
  sticks on the clamp's plateau when a fold's offsets are large. `0320` stopped while grading GR at 16:14 UTC, its
  orphaned workers stopped, no queries left; the fix and a test that fails on the old search (`ca78ca6`); the broken
  tables restored and their caches removed. Rescoring is on hold while the tuning is organized (Al)

- Organizing before any rescore (Al): #84 filed (a minutes-long gate `0320` must pass before the full grid, a
  development setting, the gates proved on `84c3c78` against `ca78ca6`); #83's body says it is blocked by #84 and needs
  a dense-fit reference on the current scorer; #73's body says the rescore is blocked by both; the plan gains Phase 6a
  before Phase 7's remaining boxes. Both issues' work lands on this branch

## Session 2026-10-23, Phase 6a (Fable)

- #84 built: `knw_tune_smoke()` (`R/tune_smoke.R`) scores no rule, `default`, link's `default_tuned` row and the
  previous pick on the main seed and checks `null_ratio`, `clamp`, `behind_null` and `coef`; `.tune_score_one()`
  returns each fold's non-group coefficients; `knw_tune_run()` preps every key, smokes every key, refuses the grid on a
  failure (`smoke`, `smoke_only`, `previous`, `extra`); `0320` runs the smoke pass first, writes `<key>_smoke.csv`,
  refuses with the log written, and `DEV=1` runs the main seed only with no grades under `data/tune/dev/`. Tests:
  `test-tune_smoke.R` (the probe rebuilt: the `84c3c78` search mocked in fails `null_ratio` and `clamp` on a held-out
  group with large offsets, the current one passes; the `behind_null` and `coef` checks on crafted fits; the run's
  refusal), `sim_build()` moved to `helper-tune_sim.R`.
- The mutation table on the real data (findings, "The smoke run's mutation table") found that `ca78ca6` had not fixed
  the search: ST's no-rule model 3,372 on both golden sections, its previous pick 586.5 on one and 810.0 on the other.
  The search is now the root of the deviance's derivative (`R/tune_score.R`), which leaves no visit at the clamp on
  any key and agrees with #57's IRLS scorer to four decimals where that was sane. BT_rear's committed scores carried
  the old search (no rule 6,180.6 → 6,031.2). Every failure left is the training fit's separated `data_set`/`era`
  coefficient on GR, RB, ST and WCT (limit 5); the options are in the finding, for Al.
- Stale `data/tune/{CH,CO,BT}_*_score.rds` removed. Pre-existing test failures on this branch, not touched:
  `test-tune_repick.R:79` (#79's pin against the rescored CH table) and `test-vignette-data.R` (md5s moved by Phase 7's
  runs), both Phase 8's. Committed as `8a20461`.
- #83 built: `.tune_glm_fe()` (`R/tune_score.R`), `glm.fit`'s IRLS with the groups projected out of each least-squares
  step; `fit = "fe"` (default) or `"dense"` through `knw_tune_score()`, `knw_tune_smoke()` and `knw_tune_run()`; a fold
  where the two fits would drop different columns falls back to the dense fit. The dense reference
  (`planning/active/scratch/ref_fit.R` on `8a20461`, six species, 110 min) is reproduced by the fe fit (17 min): every
  region, pick, recommended rule and convergence flag the same, deviances to 1e-9 relative except six CH rules at
  3e-7 (`compare_fit.R`, `fit_compare.csv`). The first reproduction run fell back on every chinook fold (an era dummy
  both fits drop) and was stopped; the test now asks what the dense fit's own QR would drop. Rainbow's timing with the
  extras (`EXTRA=1`) is running; the box flips with it. Committed as `9d8f136`.
- Rainbow's timing moved to m4 (16 cores, idle) when a virtual machine here, link's provincial run, left my workers a
  fifth of a core each: m4 got the branch, the two evidence files that differed (md5s checked), and already had link's
  commits and the database; 16.6 min with every extra against 8.1 h here. #83's box flipped.
- Al chose option A for the coefficient finding: a normal prior, SD 2.5 on the cloglog scale, on the `data_set` and
  `era` coefficients (`.tune_glm_fe(ridge = )`, `prior_sd` through the scorer, smoke and run; the dense fit takes none).
  Measured on every key at no prior, 5, 2.5 and 1.5 (`planning/active/scratch/prior_smoke.R`): every gate passes at
  every prior; without one the coefficient gate fails on GR, RB, ST and WCT and steelhead's null ratio too. Phase 7's
  hold lifted; the rescore runs on m4. Al's rule for the write-ups, 2026-10-23: teach the principle beside each result.

## Session 2026-10-24 (Opus 5.5)

- m4's grading stopped after 7.5 h (104 ms round trip to the database against 1.6 ms here); Al chose to reuse m4's
  scores and grade here (option A). Filed #85 (one walk pass per river size), linked from #73's plan.
- `0320` graded here from a frozen copy at `fa638f2`: 224.6 min, exit 0, no `FAILED`. Picks moved on BT_rear, RB_rear
  and WCT_rear; five held. Curves refit slightly differently from m4's on RB, ST and WCT; steelhead's curve is far
  behind its grid (findings, "Phase 7's rescore").
- `0330` here from a frozen copy at `eb7b382`, one species at a time, 10:23 to 15:13 UTC: GR 38.3 min, WCT 17.6,
  ST 53.8, RB 40.4, BT 140.1 (rear and spawn), every one exit 0 with no `FAILED`; 6 workers. The combined tables are
  composed with the saved CH and CO comparisons. Each run overwrote the script's log, so `scripts/logs/habitat/` keeps
  BT's (`20261024_compare-bt.txt`, `20261024_compare-workers-bt.out`); every species' stdout is in
  `planning/active/scratch/logs/20261024_0330_<sp>.log` (findings, "Phase 7's recompare").
- Steelhead's curve measured (findings, "Why steelhead's curve trails its grid"): `data_set` and `era` aliased with no
  prior in the curve (860.8 to 553.8 with the grid's prior), and the joint smooth overfits NIMP, which holds a third
  of its detections. The prior also moves grayling's curve (786.9 to 743.6). Probe kept at
  `planning/active/scratch/curve_prior_probe.R`. Asked Al whether the curve takes the prior (every key regrades).
- Al chose A (2026-10-24): the curve takes the grid's prior, and steelhead's rule is published without grades.
  `knw_tune_curve(prior_sd = 2.5)` (the run passes its own), a test that fails without the prior (2 of 7 checks red
  with the penalty removed), and `0320`'s grade tables record `curve_prior_sd`, which the keep-check compares, so
  every key regrades on the next run. On steelhead's cached population the new code gives 553.8 with the prior and
  860.8 with `prior_sd = Inf` (the cached value).
- Found while choosing the gate: coho's curve (4092.5) and WCT's (1454.5) also score worse on held-out groups than no
  rule at all (4024.0, 1329.7), and the prior moves them by about 1. Asked Al whether "worse than no rule" is the gate
  for publishing grades (it would drop steelhead, coho and WCT), before the regrade.
- Al chose the gate (2026-10-24): a key whose curve scores no better on held-out groups than no rule gets no grades.
  `knw_tune_run()` records `null_heldout` and `grade_withheld`; `0320` logs it, writes it to the summary, and still
  walks and writes the key's grade table with `rate`, `grade` and `grade_class` blank (0330 reads its sizes and
  distances to apply the rule); `knw_compare_rules()` reports NA graded km for such a key, not 0; `0325` leaves it out
  of the published grades; `0330` refuses grade tables made before the prior. With the prior, the gate should withhold
  steelhead, coho and WCT. The test fails with the gate disabled.
- Next: `0320` here (scores cached from `fa638f2`, whose scoring code is unchanged; curves refit; every key regraded),
  then `0330` on every key (graded km and the GeoPackages carry the grades), then the write-ups.
- `0320` with the prior and the gate, here from a frozen copy at `1d4ceb8` (`SCHEMA=fresh_default_20261017 WORKERS=8`),
  16:47 to 19:58 UTC: 190.9 min, exit 0, no `FAILED`; scores reused from the `fa638f2` caches (scoring code unchanged),
  curves refit with `prior_sd = 2.5` and every key regraded. Curve held-out scores match the probe (ST 553.8, GR 743.6,
  BT_spawn 397.3); grades withheld from CO_rear (4092.0 against no rule's 4024.0), ST_rear (553.8 against 420.8) and
  WCT_rear (1453.4 against 1329.7). Checked on the grade tables: the three withheld keys carry no rate, grade or class
  and `grade_withheld = TRUE`, with size and distance kept; the other five are graded; all eight record
  `curve_prior_sd = 2.5`; `q_walk` is BT 10, CH 3 (and 10 for the rest). The log's `graded=` count for a withheld key
  counts segments with a size and a gradient, not grades. Picks and rule scores did not move. Stdout in
  `planning/active/scratch/logs/20261024_0320_prior.log`; script log `scripts/logs/habitat/20261024_tune_run.txt`.
- `0330` on all eight keys here from a frozen copy at `d02af54` (md5 29a34f3…), link's config pinned at `102762d`
  (`CONFIG_SHA`; CH and CO were last compared at `67a410e`, whose `configs/default` lacks only
  `cabd_additions_barriers`, which link says never moves access): WCT alone, 20:00 to 20:19 UTC, 18.4 min, exit 0; then,
  after one species at a time was seen to hold the database at one core of six, the runner was stopped two minutes
  into GR and the other seven keys ran in one process on 6 workers, 20:21 to 23:01 UTC, 160.1 min, exit 0, no
  `FAILED` (database at 578 % CPU). Default and tuned km match the morning's comparison on BT, RB, ST, GR and WCT (picks
  unchanged); graded km is NA on CO and ST, as the gate means. Stdout in
  `planning/active/scratch/logs/20261024_0330_prior_{WCT,par}.log`; the script log `20261024_compare.txt` is the
  seven-key run's (WCT's was overwritten; its stdout carries its lines).
- Speed: one species at a time used one database core. Filed #86 (the comparison's groups in parallel) and #87 (batch
  and cache the walks, parallel compare, any machine with the build; Al: plan it separately with `/planning-init`
  later); #85 and #86 point to #87. CLAUDE.md now says to run database-bound steps on the database's host (`d2c7071`).
- `research/coho_rearing_tuned.md` revised: its grade section replaced by "No grade" (the gate and why), the tuning
  numbers that moved in the rescore (best 3,855.9, no rule 4,024.0, nested 3,877.3, 1.96 region 1,511, bootstrap
  gradient shares, exact rule 26.5 %, curve 4,092.0) and the baseline commit (`102762d`; every kilometre and check
  the same as at `67a410e`); the pick, profiles, seeds, folds and gradient curve are unchanged.
- `research/chinook_rearing_tuned.md` revised to the rescore (fit with the groups absorbed), the curve's prior and the
  regrade: region 84 rules, best 1,120.1 against 1,380.5 for no rule, `default` 224.7 behind (SE 91.6), 1.96 region
  2,102, bootstrap and profile decimals, curve 1,052.7 (graded: below no rule), reference rate 0.146, 61,491
  grade-weighted km, graded km in the comparison 48,134 → 53,957 under the door; km, checks and picks unchanged.
  The vignette data (Phase 8) still carries the old grades.
- GR, RB, ST and WCT write-ups started on four Sonnet agents (model plan), each with a claims audit to check before
  commit.
- The four write-ups checked and committed: ST (`d1ccfcb`; `FDS` corrected to the export's own data-set code, not the
  FISS workbooks), WCT (`da0150d`), GR (`c3ad47a`; one first-person sentence), RB (this commit; the gradient-curve
  sentence, which rises to a peak near 4 % before it falls). Spot checks against the tables held on every file:
  folds, seeds, bootstrap shares, regions, the 1.96 regions, the cross-key superlatives. Each agent's claims audit is
  in the session scratchpad, not the repo. Flagged and left: `data/thresholds.csv` rows hold the pre-#73 picks until
  `0325` (Phase 8); RB has 1,592 accessible segments with a width and no rate (cause untraced).
- Was next: check and commit the four write-ups; then BT, `habitat_thresholds_tuned.md` and CH (on Fable, per the model
  plan).

## Session 2026-10-25 (Fable, m4)

- Picked up on m4: the checkout at `fa638f2` carried 48 modified `data/tune` tables and 8 untracked smoke tables from the
  2026-10-23 rescore scored here, every one superseded by the regrade commits, so `git pull --ff-only` refused; stashed
  (`stash@{0}`, not to be popped) and fast-forwarded to `a3f59a3`. The table bundle unpacked from
  `knowledge_bundle_20261025` and every one of its 38 md5s matched. Three untracked `20261017_tune_run-attempt*.out`
  logs (a #57 run on this machine) left alone.
- `research/bull_trout_tuned.md` rewritten on #73's tables (363 lines in place of 227): "In plain words" for both stages
  (Al's rule, the principle beside each result), the rearing pick's move from the 2026-10-23 reading (MAD ≥ 0.1 at
  10.49 %, a one-departure tie-break inside the old search's 594-rule region) to the grid's best (MAD ≥ 0.35 at 25 %,
  316 rules, no one-departure rule inside), every check with its direction, the grade (unchanged to the kilometre by the
  curve's prior), the recompare under both structures (door 142,015 km, −41.9 %); spawning unchanged in rule and
  recompare, its grade's margin over no rule (4.2) named as the narrowest of the graded keys. Numbers from `tune_summ.R`,
  `grade_summ.R` and `compare_summ2.R` (the first two now take a full key, so `BT_spawn` runs), the honest, seeds and
  curves tables, and a population rebuild (`bt_pop.R`, session scratchpad; the modelled populations reproduced to the
  visit, 8,717 and 475) for the cross-tabulations and the descriptive bands. The spawning visits are not
  "August–October": #33's rule reads the month for what counts as evidence, and the modelled visits run June to October
  (July 65, August 197, September 170).
- `research/habitat_thresholds_tuned.md` rewritten (356 lines in place of 300): every row of Results, the 1.96 table,
  Grades and the comparison table is #73's, recomputed from the eight summaries and tune tables (`region196` counted
  from each tune csv), the grade tables (`grade_summ.R`, which fails on a withheld key because duckdb reads an all-NA
  `grade` as text: run it on graded keys only), the per-key compare and change tables and `checks.csv`; the Method
  names the fit, the prior, the smoke gates, the two starts, the bank walk and the grade gate; the Limits say the
  distance is to the bank (the BULK check), which rows have no grade and why, and label #65's off-branch and
  floodplain measurements as #65's. Found while summing `compare.csv`: each key × structure carries a totals row
  beside its group rows, so a plain sum over the file double-counts; the per-key files are what `compare_summ2.R`
  reads. `research/README.md`: the eight tuned-rule rows rewritten to the #73 picks (GR, RB, ST and WCT's had carried
  #57's).
- Phase 8 begun. `knw_thresholds_table(compare_dir = )` adds `near_river_scope` from the comparison's `tuned_structure`
  (door → `both`, door_wetland → `wetland_flow`, `NA` where the rule has no pair or no directory is given; a pair
  compared under `free`, or with no comparison on file, is an error), pinned in `test-thresholds_table.R`; `0325`
  passes `data/compare`. `data-raw/vignette_chinook.R` reads `SCHEMA` (default `fresh_default`) for the map's geometry
  and records it in `meta$schema`; `0325` reads no schema and `readme_figure.R` no database. `test-tune_repick.R`'s
  1.96 table is #73's. `scripts/README.md`: 0320's gates, fit, prior and grade gate; grading and 0330 on the
  database's host. The build's database is reachable from here (the `~/.Renviron` the 2026-10-23 grading used; its
  discharge comment names wet `94deeb5` and both schemas exist); a trivial query takes 123 ms.
- `0325` run locally at `a91309e` (6.4 min; the discharge comment named wet `94deeb5`): `data/thresholds.csv` 46 rows with
  `near_river_scope` (`both` on CH's four rows, empty elsewhere), `thresholds_groups.csv` unchanged, the grade set 37.1 M
  segment rows for BT rear and spawn, CH, GR and RB with CO, ST and WCT withheld. `data-raw/vignette_chinook.R` with
  `SCHEMA=fresh_default_20261017` (45 s): the bundle's versions equal the committed bib's (wet's token is the flow set,
  not its build time), so `vignette_bib.R` was not rerun; `readme_figure.R` redrew `man/figures/readme-bulk.png`. The
  article: the 1.96 passages (the floor rises to 1 m³/s, the slope goes back to 5.49 %, the allowance stays), the
  slope-ladder bullet (the close calls run 7–30 % on the shared ladder; #67's run is told as what lengthened it), the
  through-wetland bullet (the comparison now carries one row per structure, so `wl` is the tuned row: 2,495 km at a
  median grade of 0.29 under the door against 10,257 km at 0.03 let through), the distance bullet (to the bank), and
  the FDIS check, whose `rate("tuned", …)` printed empty because the checks table names the structures: it reads
  `meta$tuned_structure` and asserts one row. Rendered locally with every guard passing. README example and sentence
  (13 %); the seven species and cross-species files no longer say the thresholds table awaits `0325`.
- `devtools::test()`: 926 pass, 0 fail, 1 skip (1.5 min); `test-vignette-data.R` and `test-tune_repick.R` green again.
  `lintr::lint_package()` reports only the article's pre-existing style notes; `devtools::document()` rewrote
  `knw_thresholds_table.Rd`; `pkgdown::check_pkgdown()` clean.
- `/code-check branch`, round 1 (`review-round1.md`, 14.6 min, 6 findings): one bug, the grade gate compared the
  curve's held-out deviance over its own visits (those with a size) with no rule's over every modelled visit, so for
  the width-ruled keys it favoured publishing. Reproduced by scoring no rule on each curve's visits with the scorer's
  own functions (`gate_probe.R`, scratchpad): BT spawning 397.3 against 378.8, withheld (it had passed by 4.2 against
  401.4); GR's margin 20.3 not 84.4, RB's 906.1 not 3,207.6; the other five verdicts stand. Fixed in `87266b2` with a
  test that restores the defect; the regrade of BT_spawn and its recompare need the database's host (plan, "Owed
  before merge"); the eight research files say what moved. Also fixed: `0330` composing a failed job's saved table,
  the score cache not keyed on fit/prior/seed/folds/d_floor/extra (recorded as `spec`), home paths in the two chain
  scripts, `previous <- character()`; accepted: the `coef` gate reading the rule term (for Al). Round 2 running.
- Rounds 2–5 (`review-round{2..5}.md`): every finding one mechanism, a record written by one run and read back by a
  later run on its presence alone, each round finding it one axis over inside the previous fix. Round 2: the gate's
  written verdicts (fixed: `null_heldout_curve` on every grade table, required by `0325` and `0330`, so every table on
  disk is refused until the host regrades them all, about 190 min); a saved comparison under another baseline (fixed).
  Round 3: the evidence's content in no record (fixed: `evidence_md5` in the score cache's settings and on every grade
  table); the pick unchecked by the readers (fixed in `0325`, `0330`, the compose and the vignette script); the
  vignette's log selector matching the kept line (fixed). Round 4: the pick's evidence on no record the readers hold a
  grade to (fixed: on the summary and curve records, carried through `knw_thresholds_table()`; a fitted row with no
  grade table refused). Round 5: `0325`'s checks ran after the thresholds publish (fixed: every refusing check before
  any write); a summary beside another run's tune table (fixed in `knw_thresholds_table()`); the compare rows'
  evidence identity accepted as low. Ended by the mechanical enumeration in `review-round5.md`. Five reviewer agents,
  about 15 min each; `devtools::test()` 942 pass, 0 fail, 1 skip at `bcbe155`.
- Next: `/planning-archive`, `/gh-pr-push` with `NewGraphEnvironment/sred#41` (Al, 2026-10-25).

### Resume (revised 2026-10-25 15:10 UTC: parked here, picked up on m4 under another account, on Fable)

**Where it stands.** Every run of #73 is done and committed: the rescore (`0320` at `fa638f2`), the regrade with the
curve's prior and the grade gate (`d02af54`), and the recompare of all eight keys (`b8d3fbd`). The write-ups for CO,
CH, GR, RB, ST and WCT are rewritten on those tables and committed (`6f9cb8a` to `384d4d8`). Left, in order:
1. `research/bull_trout_tuned.md` (BT_rear's pick moved in the rescore; BT_spawn graded too; brief below).
2. `research/habitat_thresholds_tuned.md` (Phase 7's last box) and `research/README.md`'s rows.
3. Phase 8 as `task_plan.md` lists it. Its first box is stale: RB is no longer deferred (#83 landed; RB was tuned,
   graded, compared and written up on 2026-10-24), so `0325` includes RB; that box becomes "RB in, no deferral".
4. Validation: `devtools::test()` (the two known failures, `test-tune_repick.R:79` and `test-vignette-data.R`, are
   Phase 8's), `/code-check branch`, `/planning-archive`, `/gh-pr-push`.
No new branch and no `/planning-init` for any of it: it is #73's own plan. The speed work is #87 (with #85 and #86),
a separate `/planning-init` after #73 merges (Al, 2026-10-24).

**Getting started on m4.** From the repo root: `git fetch -q origin && git checkout
73-rebuild-the-evidence-and-retune-on-the-r && git pull --ff-only` (m4's checkout was at `fa638f2`). The ignored
tables live only on the machine that ran the regrade, so they were bundled and copied to m4 on 2026-10-25:
`~/Projects/repo_aside/knowledge_bundle_20261025/` holds `knowledge_tables_20261025.tar.zst` (every
`data/tune/*_grades.csv`, `*_curve.rds` and `data/compare/*_segments.rds`, paths relative to the repo root) and
`MANIFEST.md5` (each file's md5 before bundling). Unpack from the repo root with
`zstd -dc ~/Projects/repo_aside/knowledge_bundle_20261025/knowledge_tables_20261025.tar.zst | tar -xf -`, then check
with `/sbin/md5 -r $(cut -d' ' -f2 ~/Projects/repo_aside/knowledge_bundle_20261025/MANIFEST.md5) | diff -
~/Projects/repo_aside/knowledge_bundle_20261025/MANIFEST.md5` (no output means every file matches). m4's own
`data/tune/*_score.rds` caches are from `fa638f2` and are not needed for anything left.

**The database.** Only the build's own database holds `fresh_default_20261017` and the flow load the tables were
graded on (the table comment names wet `94deeb5`, built 2026-10-19). m4's local database is a partial build on an older
flow load, so every database step points `PG*` at the build's database, as m4's grading did on 2026-10-23. What is left
is light on the database: `0325` makes one call and `data-raw/vignette_chinook.R` three, so 104 ms a round trip costs
seconds. Never rerun grading or `0330` from m4 (CLAUDE.md, "Database access"); if one is needed, run it on the
database's host. `0325` publishes the flow-load comment of the database it reads, so check it names `94deeb5` first:
`obj_description('discharge.fwa_v1_segment_monthly'::regclass)`.

**Rules for every step.** `SCHEMA=fresh_default_20261017` for every database step; judge a run by its files and log
lines, never by `ps`; a log that shows `FAILED` means stop and report the error lines; never edit a script or `R/` while
a run reads it; everything committed is public (no home paths, hosts or private links; planning may name a machine
that is the subject of a measurement); commit each task with its box flip and a progress entry, and push. Al's rule
for the write-ups (2026-10-23): teach the principle beside each result, in plain words first, the specification below.
The grade gate (Al, 2026-10-24): a key whose curve scores no better on held-out groups than no rule gets no grades
(withheld: CO_rear, ST_rear, WCT_rear); its file has a section saying why instead of a Grade section (the coho file is
the model), and its graded km in the comparison is NA.

**How the six write-ups were checked** (repeat it for bull trout). Numbers come from
`KEYS=<KEY> Rscript planning/active/scratch/tune_summ.R`, `grade_summ.R` and `compare_summ2.R` (the last errors at its
change-reasons step when a key's change table is empty, as GR's is; the totals print first), the summary and honest
and seeds csvs, `planning/active/scratch/logs/20261024_0320_prior.log` (status, gate, picks and `<KEY> grades:` lines)
and `planning/active/scratch/logs/20261024_0330_prior_par.log` (per-key km lines). Four were drafted by Sonnet agents
with a claims audit each and every file was spot-checked against the tables before commit; the corrections are in the
2026-10-24 bullets above. Read "Reading the tuning's stability checks" in CLAUDE.md before writing a check's
direction: the exact rule and any rule at a value are different numbers.

**Bull trout (Fable):** `research/bull_trout_tuned.md` (72 lines; keys `BT_rear` and `BT_spawn`), the same pattern for
each stage, with link's `default_tuned` floor (0.043 m³/s on wet, link#331) scored in the grid and named, and the
earlier weights work (`research/habitat_weights.md`, `bt_spawning.md`) as the prior. Literature rows: rearing gradient
18 rows, channel width 6, discharge 2, stream order 4; spawning gradient 20, channel width 5, discharge 1, stream order 7
(list them with the same filter).

**Then (Fable):** `habitat_thresholds_tuned.md` rewrite, from the eight committed research files and the tables (each
key's row marked as #73's, CO, ST and WCT with no grades) (Results, "At 1.96 SE", Grades, "What each rule changes",
Limits: the distance bullet now says bank); Phase 8 as listed in `task_plan.md` (the Rmd guards that will break are in
the compaction summary's Phase 8 notes and in `findings.md` if copied there: `ch196$size_min == rec$size_min`,
`is.na(ch196$exc_q)`, `abs(wl$km_tuned - 10200) < 200`, `ge_best$grad_max > rec$grad_max`); `/code-check branch`
(three-round floor); `/planning-archive`; `/gh-pr-push` (the PR body's R&D tracking cross-reference is not in this public repo: ask Al for it
if the session's memory lacks it). The final report must name: the curve-intercept defect and fix (CH curve 2,434 →
1,053), that the rule scorer was affected after all (2,269 CH rules, the pick moved), the worker-export follow-up, the
rescoring, the stopped and relaunched 0330 with its compose change, the detached chain.

## Host batch for PR #88 (2026-10-25, on the database's host)

- `0320` from a frozen copy at `fc85758` (md5 a48fd4c…), `SCHEMA=fresh_default_20261017 WORKERS=8`, 20:09 to 23:21 UTC:
  191.1 min, exit 0, no `FAILED`. Every score cache was read as scored with fit `fe`, prior SD 2.5, seed 54, five folds
  (the settings of `fa638f2`'s scoring), so nothing rescored; every key regraded, because no grade table carried
  `null_heldout_curve` or `evidence_md5`. The corrected gate withholds BT_spawn: no rule scores 377.9 on the curve's 450
  visits (401.4 on the grid's 475) against the curve's 397.3. CO_rear, ST_rear and WCT_rear stay withheld (no rule
  4,021.4, 413.9 and 1,329.7 on their curves' visits). Grade tables checked: BT_spawn carries no rate, grade or class
  and `grade_withheld = TRUE`; BT_rear is graded; both carry the two new columns. Stdout in
  `scratch/logs/20261025_0320_host.log`; script log `scripts/logs/habitat/20261025_tune_run.txt`.
- `0330 SPECIES=BT` from a frozen copy at `9492ea2` (md5 05f7434…), link's configs pinned at `102762d`, 6 workers,
  23:21 UTC to 01:45 UTC: 143.3 min, exit 0, no `FAILED`. BT_rear unchanged (`default` 244,328 km, tuned 142,015 under
  the door, −41.9 %); BT_spawn gains 36,034 km (+27.0 %) with graded km NA now its grades are withheld. The other six
  keys composed. Stdout in `scratch/logs/20261025_0330_BT_host.log`; script log `scripts/logs/habitat/20261025_compare.txt`.
- `0325` at `bf41ebd`, 01:45 to 01:53 UTC, exit 0 (local; `PUBLISH` not set): 46 threshold rows for 8 fitted keys,
  374 group rows; grades withheld from BT_spawn, CO_rear, ST_rear and WCT_rear, so `habitat_grade/v1` carries
  28,710,335 segment rows for 4 keys. `data/thresholds.csv` gains `evidence_md5`; every other value is unchanged.
  Stdout in `scratch/logs/20261025_0325_host.log`.
