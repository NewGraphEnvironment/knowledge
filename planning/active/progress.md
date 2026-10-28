# Progress — Compare only default and the reported structure unless asked (#112)

## Session 2026-10-28

- Plan-mode exploration — phases approved by user; Al chose to drop the other structures' sentences
- Created branch `112-compare-only-default-and-the-reported-st` off main
- Scaffolded PWF baseline from issue #112 with approved phases
- Next: start Phase 1
- Phase 1: per-rule and per-group setup minutes in `.knw_compare_bin()`, summed and logged by `knw_compare_rules()`
  (`worker_minutes`); `data-raw/compare_structures_check.R` with TUNE_DIR/COMPARE_DIR/EVIDENCE_DIR, because the
  database host's ignored inputs are an older build (visits md5 d3a434e2/bc71243b against #92's 1bd35829/009698d7;
  grade tables of 2026-10-25) while the remote-link machine holds #92's
- Plan review (`planning/active/review-plan.md`): B1 confirmed (settings.csv is md5-pinned in method.rds, so the
  register is left for the next bundle rebuild); G1 fixed (`structures = "reported"` resolved and held to the
  species' set inside knw_compare_rules()); G3/G4 folded into the check (tracked comparison a report; saving from
  worker minutes); fresh is 0.44.0 here and on the host, #92 ran 0.43.0
- Phase 2: `0330` reads `STRUCTURES` (default `reported`); register row deferred to #115
- Phase 3: chinook article drops the free-pass clause and `wl_free` (renders on the current bundle after installing the branch: "about 2,500 km ... median grade of 0.34, against 8,400 km under link's rule. Lakes keep their own condition."); research note on #92's structure figures
- Host run (22:00–22:55 UTC, knowledge 731b21f, `scripts/logs/habitat/20261028_compare_structures_check*`): every
  reported-only table equals the every-structure run's default/door rows on WCT (all 16 groups), CH and BT rearing
  (20 largest each); WCT's every-structure run equals #92's tracked tables row for row (1.7e-14) on fresh 0.44.0.
  Gate passed: dropped rules 29–35 % of worker minutes, wall 19–29 % less. Recorded in research/database_builds.md,
  CLAUDE.md. Tests: 1645 passed, 0 failed, 1 skipped; lint adds only the new data-raw script's sibling-style lines.
