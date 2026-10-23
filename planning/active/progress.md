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

### Resume (written 2026-10-23 05:30 UTC, for the session that picks this up after a compact and clear)

The branch stays `73-rebuild-the-evidence-and-retune-on-the-r`; no new issue, no new plan-init. Resume with
`cd ~/Projects/repo/knowledge && git fetch -q origin && git checkout 73-rebuild-the-evidence-and-retune-on-the-r && git pull --ff-only`,
read this section and `task_plan.md`'s unticked boxes, and `findings.md`'s "The CH and CO tuning on the rebuilt
evidence" for the numbers' shape.

**What is running without a session (revised 2026-10-23 07:50 UTC).** The first chain
(`scripts/logs/habitat/20261023_chain_73.sh`, log `20261023_chain_73.out`) stopped at its first step: link#361's
provincial run renamed `fresh_default` to `fresh_default_20261017` at 07:41 UTC, after the two jobs it had waited on
(the chinook comparison and the bull trout tuning) exited at 07:40 and before the chain's bull trout comparison
connected (`20261023_chain_0330-bt_attempt1.out`: `relation "fresh_default.streams" does not exist`). The four-species
tuning was stopped six minutes in (exit 143, nothing cached) so the scripts could take the schema. `scripts/0320` and
`0330` now read `SCHEMA` (default `fresh_default`) and log it. **Every database step from here on sets
`SCHEMA=fresh_default_20261017`**, the run the evidence, grades and chinook/coho comparison were built on; the new
`fresh_default` is a different run (link 0.68.0, `20261023_074321-24d85e8c`) that link#361 is building over the next
day, and its before/after diff reads the archived schema, which is dropped later at the operator's call.
`scripts/logs/habitat/20261023_chain2_73.sh` (nohup at 07:48 UTC, pid 78023) runs `SPECIES=BT WORKERS=2 0330` beside
`SPECIES=GR,RB,ST,WCT WORKERS=6 0320`, moves the bull trout comparison's date-named logs to `<date>_compare-bt.txt`
and `<date>_compare-workers-bt.out` (the four-species run would overwrite them), then runs `SPECIES=GR,RB,ST,WCT 0330`
only if both exited 0 (the four-species comparison composes the saved bull trout tables). Its log is
`20261023_chain2_73.out` (one timestamped line per step, `FAILED:` on a stop); each step's stdout is
`20261023_chain2_0330-bt.out`, `20261023_chain2_0320-gr_rb_st_wct.out`, `20261023_chain2_0330-gr_rb_st_wct.out`.
The database is shared with the provincial run's primitive load and recompute on this machine, so expect every step
slower than the chinook timings. **Do not edit `scripts/0320-tune-run.R`, `scripts/0330-compare.R` or anything under
`R/` while the chain runs** (Rscript reads a file as it runs). Check the chain by its log and the per-key files on disk
(`data/tune/<key>_summary.csv`, `data/compare/<key>_compare.csv`), not by `ps`.

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
