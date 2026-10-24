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

### Resume (revised 2026-10-24 15:20 UTC, for the session that picks this up, on any model)

The branch stays `73-rebuild-the-evidence-and-retune-on-the-r`; no new branch and no `/planning-init`. From the repo
root: `git fetch -q origin && git checkout 73-rebuild-the-evidence-and-retune-on-the-r && git pull --ff-only`, then
read `task_plan.md` Phase 6a (done) and Phase 7, and `findings.md`'s last three sections ("The smoke run's mutation
table", "The fit with the groups absorbed", "The prior on the data-set and era coefficients"). Rules that hold for
every step: `SCHEMA=fresh_default_20261017` for every database step; no chained tuning and comparison; judge a run by
its files and log lines, never by `ps`; a log that shows `FAILED` means stop and report the error lines; never edit a
script or `R/` while a run reads it (run long jobs from a frozen copy); everything committed is public; commit each
task with its box flip and a progress entry, and push. Al's rule for the write-ups (2026-10-23): teach the principle
beside each result, in plain words, the specification below.

**Done: the regrade with the curve prior and the grade gate (2026-10-24, 190.9 min, exit 0; progress above).** Next:
`0330` on every key (CH, CO, BT, GR, RB, ST, WCT), one species at a time, because the grade tables changed; then the
write-ups, where CO, ST and WCT have no grade section. (The recompare is done too, 2026-10-24 23:01 UTC.) Before that: **Done: `0330` here, one species at a time (GR, WCT, ST, RB, BT), 10:23 to 15:13 UTC 2026-10-24**, every species
exit 0 (findings, "Phase 7's recompare"); next are the write-ups. Phase 7's rescore is done and committed (2026-10-24 10:20 UTC, exit 0; findings, "Phase 7's rescore"). How it went: The rescore ran on m4 from
21:21 UTC 2026-10-23 (`fa638f2`, every species, 12 workers) and scored every key with no `FAILED` by 22:26 UTC, then
graded so slowly that it was stopped at 06:33 UTC (`exit 143`): grading sends one walk query per segment, and a round
trip to the database costs 104 ms from m4 against 1.6 ms here, so BT rearing had not finished walking after 7.5 h
(about an hour here). The fix is #85. Al chose to reuse m4's scores (2026-10-24, option A): m4's 100 output files
(scores, curves, summaries, tune tables) were copied into `data/tune/` here, md5s checked, and the earlier grade tables
here were moved to `repo_aside/knowledge_grades_pre_fa638f2_20261024/` beside the clones so every key grades fresh.
The run: `repo_aside/run_0320_local.sh`, a frozen copy of `0320` at `fa638f2` (md5 7720439…), `SCHEMA=fresh_default_20261017
WORKERS=8`; stdout `repo_aside/0320_local.log`, which ends with `exit <code>` and a date; the script's own log is
`scripts/logs/habitat/<date>_tune_run.txt`, dated by the machine's local day. It took 224.6 min. Both stdout logs are in
`planning/active/scratch/logs/` (`20261023_0320_m4.log`, `20261024_0320_grade_local.log`).

**Caches:** the caches (`data/tune/*_score.rds`, `*_curve.rds`, ignored) are from `fa638f2`; remove them
before any rerun of `0320` on changed code, because the cache is keyed on the grid.

**Steelhead's curve (measured 2026-10-24, findings "Why steelhead's curve trails its grid"; decision with Al):** its held-out score is 840.2 against the grid's best 357.5 (every other key's curve is within 13 %
of its grid's best or below it, on m4's log). The curve's GAM carries data-set and era terms with no prior;
measure it before any write-up uses steelhead's grades (its pick comes from the grid, not the curve).

**Then, in order:** `0330` one species at a time here, not on m4, which is too far from the database (`SCHEMA=fresh_default_20261017 SPECIES=<sp> Rscript
scripts/0330-compare.R`, never chained with `0320`; the combined tables are composed per key, see the last bullet
below); the keep-check on the grades compares rule, run_uid, walk, ref_edge and discharge_load, not `q`, so check `q`
by hand; then the write-ups per the model plan below, every number recomputed from the new tables; then Phase 8.
Which picks moved against the committed tables is the first thing to read off the new `*_tune.csv` (`recommended`).

**This machine** was loaded by link's provincial run (a virtual machine at two cores) all afternoon on 2026-10-23,
which is why the timing moved to m4. The dense and fe reference caches are under
`data/tune/ref_*/` (ignored); their logs and the prior measurement's are in `planning/active/scratch/logs/`.
Pre-existing test failures on the branch, Phase 8's, not touched: `test-tune_repick.R:79` (#79's pin) and
`test-vignette-data.R` (md5s moved by Phase 7's runs); everything else passes (full suite 2026-10-23 before the prior;
the three tune files after it). m4's old #57 tune outputs were moved to `repo_aside/knowledge_tune_57_20261023/`
beside the clones, not deleted.

**Model plan (Al, 2026-10-22 evening).** The four smaller species' research files on a cheaper model; the bull trout
file, the `habitat_thresholds_tuned.md` rewrite, Phase 8, the branch review and the PR on Fable.

**The four smaller species: `research/grayling_rearing_tuned.md` (34 lines), `rainbow_rearing_tuned.md` (47),
`steelhead_rearing_tuned.md` (34), `westslope_cutthroat_rearing_tuned.md` (37)**, each rewritten in place on the pattern
of `research/coho_rearing_tuned.md` (111 lines, committed in `05d5faf`): header line (Verified, Issues, Produced by,
Status), "What to expect of juvenile <species>" from the literature rows, "Evidence", "Recommended rule: …" with the
flow-start pick and the 1.96 pick, "What the checks say" (every check, each with its direction, never sorted by side),
"What it is not", "Grade", "What the rule changes on link's segments" with the free/door table and the FDIS and
bcfishobs checks per structure, the structure the thresholds table records. Keep the old #57/#65 sections only where
they say something the new ones do not (the coho file dropped them; the chinook file keeps #54's record under its own
heading). Keys are `GR_rear`, `RB_rear`, `ST_rear`, `WCT_rear`.

- Numbers come from three scripts copied to `planning/active/scratch/` (run from the repo root with
  `pkgload::load_all()` available): `tune_summ.R` (edit its species vector; prints best, region, picks, profiles,
  bootstrap, seeds, honest, curve edf), `grade_summ.R` (edit its species vector; duckdb over
  `data/tune/<key>_grades.csv`: accessible, graded, km, grade-weighted km, grade classes, river-polygon split, dist 0,
  other-group walks), `compare_summ2.R` (`KEYS=GR_rear Rscript …`; reads the per-key compare, change and checks tables
  with their `structure` column). The grade meta line is `<key> grades:` in the species' `0320` log, and the
  `discharge_load` is on the grade table itself.
- Literature prior rows (`data/literature_evidence.csv`, data row N = file line N + 1): RB rearing gradient 475, 476,
  478 and channel width 477, instream flow 961–1040 (eleven rows); ST rearing gradient 204, 205, 233, 272, 292, 305,
  312, 313, 320, 321, 339, 362, 389–392, discharge 196–198, 235, 274, 304, 310, 311, 318, 319, 340, 341, channel width
  342, 387, 388, 393, bridge distance 363, 366; GR and WCT have **no** rearing gradient or size rows (GR: velocity,
  depth and one flow row 998; WCT: one flow row 1003), so their prior paragraphs say so and lean on the IP model
  registry (`data/ip_model_registry.csv`) and the species' life history rather than invent a bound. Re-list with the
  dplyr filter on `species_code`, `life_stage == "rearing"`, `variable` before writing; cite rows, quote nothing you
  have not read in the row's `quote`.
- Every quantified claim is recomputed from the tables at the grain of the sentence (the #65 lesson), and the
  "Reading the tuning's stability checks" notes in CLAUDE.md say what each check counts. `exact rule` and `any rule at
  a value` are different numbers.
- After the four files: their rows in `research/habitat_thresholds_tuned.md` (Results, 1.96, Grades, "What each rule
  changes") marked as #73's like the CH and CO rows, and `research/README.md`'s four rows. Commit per species with the
  Phase 7 box annotated, not flipped until all four are through.
- Verify the combined `data/compare/compare.csv`, `change.csv`, `checks.csv` hold every fitted key's rows after the
  chain's last 0330 (its log says "Composed with the saved comparison of …" per key composed, and "Left out of the
  combined tables…" if a per-key file's columns differ, which would be a defect to report, not paper over).

**Bull trout (Fable):** `research/bull_trout_tuned.md` (72 lines; keys `BT_rear` and `BT_spawn`), the same pattern for
each stage, with link's `default_tuned` floor (0.043 m³/s on wet, link#331) scored in the grid and named, and the
earlier weights work (`research/habitat_weights.md`, `bt_spawning.md`) as the prior. Literature rows: rearing gradient
18 rows, channel width 6, discharge 2, stream order 4; spawning gradient 20, channel width 5, discharge 1, stream order 7
(list them with the same filter).

**Then (Fable):** `habitat_thresholds_tuned.md` rewrite (Results, "At 1.96 SE", Grades, "What each rule changes",
Limits: the distance bullet now says bank); Phase 8 as listed in `task_plan.md` (the Rmd guards that will break are in
the compaction summary's Phase 8 notes and in `findings.md` if copied there: `ch196$size_min == rec$size_min`,
`is.na(ch196$exc_q)`, `abs(wl$km_tuned - 10200) < 200`, `ge_best$grad_max > rec$grad_max`); `/code-check branch`
(three-round floor); `/planning-archive`; `/gh-pr-push` (the PR body carries the R&D tracking cross-reference from the
memory file, not from CLAUDE.md). The final report must name: the curve-intercept defect and fix (CH curve 2,434 →
1,053), that the rule scorer was affected after all (2,269 CH rules, the pick moved), the worker-export follow-up, the
rescoring, the stopped and relaunched 0330 with its compose change, the detached chain.
