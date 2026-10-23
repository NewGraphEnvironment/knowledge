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

### Resume (revised 2026-10-23, for the session that picks this up after a compact and clear)

The branch stays `73-rebuild-the-evidence-and-retune-on-the-r`; no new branch and no `/planning-init`: #84 and #83 are
Phase 6a of this plan. Resume with
`cd ~/Projects/repo/knowledge && git fetch -q origin && git checkout 73-rebuild-the-evidence-and-retune-on-the-r && git pull --ff-only`,
then read `task_plan.md` Phase 6a, #84's and #83's bodies, and `findings.md`'s "The intercept minimiser sticks on a
flat clamp" and "Rainbow deferred".

**Nothing is running.** The second chain was stopped at 15:55 UTC and its four-species `0320` at 16:14 UTC; both chain
logs are committed (`scripts/logs/habitat/20261023_chain2_*`). The broken run's `data/tune/{GR,RB,ST,WCT}_*` tables
were restored to HEAD and their score and curve caches removed. `data/tune/{CH,CO,BT}_*_score.rds` are stale caches of
the old intercept search: remove them before any `0320`. Every database step of this retune sets
`SCHEMA=fresh_default_20261017`.

**Next, in order:** Phase 6a (#84's smoke run and gates, proved on `84c3c78` and `ca78ca6`; then #83's fit, proved
against a dense-fit reference on the current scorer); then Phase 7's rescore of every key, its grades and the
comparisons it needs; then the write-ups below. The probes that found the defect are in the old session's scratchpad
(gone after it ends): `probe_null.R` captured the scorer's input `d` by overriding `knw_tune_score` in the namespace and
replayed `.tune_fold_setup()` and the no-rule fit per fold; rebuild that as the gate's test, not as a scratch file.

The write-up guidance below still holds for after the rescore; its "what is running" paragraph is gone.

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
