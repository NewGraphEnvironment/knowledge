# Plan review for #93 (Plan agent, spawned 2026-10-27 05:02 UTC, delivered ~05:13 UTC)

Read-only review of task_plan.md and the Phase 1 commit `9ca40f3` and the in-progress Phase 2 CSVs. Summary of
findings, each with the parent's probe result. Full text was in the agent's reply.

| # | category | finding | probe | action |
|---|---|---|---|---|
| 1 | Blocker | one-SE region is hard-coded in `.tune_sel` (`R/tune_score.R:451-452`); `fn:knw_tune_repick:se_mult` stays green if it moves | read the code | repick-reproduces-recommended test over every key |
| 2 | Blocker | 1.96 literal had no name | already lifted to `se_strict` in `e388df4` | none |
| 3 | Gap | body/SQL literals (gradient clamp, log(dist+10), era breaks, walk hop cap, edge types, 1:50k form) have no `where` kind | read | add `code:` kind (anchored grep, `{value}` substitution) |
| 4 | Gap | missing defaults: link_width, link_place, link_regulated, spawner large_mm, rule_in targets, src, tuned_as, compare seed_boot, grade's gradient column | read formals | add rows |
| 5 | Gap | `script:` with `Sys.getenv(x, default)` must take the default | read | resolver takes the default |
| 6 | Gap | ext SHA source: bridge at compare's `config_sha` (102762d), wet at its loaded build; no wet SHA in ledger | read compare csv | per-row SHA source in render script |
| 7 | Gap | funnel: ledger in-range counts precede the no_link_segment drop; not_placed mixes no-UTM (1,037) and no stream (526); ws50 1,311 all vs 1,088 sequential; tune population filters not ledgered | reconcile.csv: 50,550 / 50,024 / 12,285 / 1,311 | recompute steps from visits tables, `md5_local` |
| 8 | Inaccurate (#89) | "kept only when ... in the 1:50k watershed" overstates: 12,285 of 50,024 placed carry a checkable code | reconcile.csv | reword |
| 9 | Incomplete (#89) | balance also picked where routed < 0.2 x balance (222,906 segments) | `wet_source_pick.R:30` | reword |
| 10 | Inaccurate (#89) | bcfishobs shapes link's segments (breaks at observations) and barrier overrides | `link/R/lnk_pipeline_break.R:23` | reword research; article "scored no rule" stands |
| 11 | Inaccurate | "link reads wet's table": `default` has no `discharge_source`, so reads fwapg's (`lnk_discharge.R:202-206`) | read | reword; register audit row |
| 12 | Stale | "40,552 placed" is kept; 50,024 placed | reconcile.csv | reword |
| 13 | Gap (#89) | bib's wet version comes from the live-manifest ledger row (`vignette_chinook.R:221`) | to check | fix the source of the version |
| 14 | Gap | new ledger row writes NA silently on no comment | read | guard |
| 15 | Ordering | `^vignettes/_` must land with the draft | — | same commit |
| 16 | Ordering | #87 changes formals of walks/compare/grade_species and adds `knw_discharge_load()` | — | pointer in #87's body |
| 17 | Acceptance | CI cannot see a leaked article | pkgdown.yaml guard is top-level only | add a CI check on `docs/articles/` |
| 18 | Assumption | fwapg has no sticker; viz.js poor with images; embed base64 | — | prototype |
| 19 | Assumption | `flow_far_low` tested: yes | already corrected to convention/no | none |
| 20 | Gap | 0320 logs `formals(knw_tune_score)$prior_sd`, not the run's value (`0320:153-154`) | to check | audit finding, fix the log line |
| 21 | Gap | placement records no fwapg version; `../fwapg` is on a feature branch | — | link upstream function; register note |
| 22 | Acceptance | completeness assertion for the settings #93 names | — | add test |
