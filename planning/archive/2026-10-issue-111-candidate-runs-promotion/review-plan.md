# Plan review — #111 (Plan agent, 2026-10-28)

Spawned 18:06 UTC on the baseline plan; it read the working tree mid-Phase 2. Findings, with what was done:

## Blocker
1. 0330 still wrote `data/compare/<key>_*` (lines 225-228) and read segments from it (253, 425). **Fixed**: the run
   directory; `gpkg_one()` takes `dir_seg`.
2. By-key refusal compared only evidence and link run; 0325 and the bundles also hold the set to one gradient, ledger,
   reference edges, flow load (live), walk (this tree's), link config and tuned structure, and the Atlas-gradient
   sensitivity to the evidence. **Fixed**: `knw_tune_promote()` checks every field across promoted and kept keys, and
   the live values `0335` passes. By-key promotion therefore only works on the kept keys' build; documented.
3. A by-key promotion's log could be taken by the chinook bundle for a key it did not promote. **Fixed**: summaries
   record `tune_run`; the bundle reads its run's logs only.
4. Promotion overwrote ignored files git cannot restore. **Fixed**: archived to `candidate/replaced_<stamp>/`, undo by
   promoting it; every refusal runs before anything moves.

## Gap
5. grad_fwa, smoke/seeds/honest, floodplain, gpkg, stale figures. **Done** (prefix copy per key; figures and
   GeoPackages by key; floodplain merged by row).
6. The newest ledger is what 0325 and the method bundle read, so a checked, unpromoted build breaks them. **Fixed**:
   `knw_run_ledger()` and `evidence_ledger` in the summaries.
7. A same-day resume overwrote the grading log. **Fixed**: numbered passes, UTC dates.
8. Compare tables carry no evidence. **Answered** by pairing on the run name, the rule and an mtime order check.
9. `copy.date`. **Done**.
10. Recomposing the combined tables byte-for-byte. **Avoided**: rows come from the run's own combined tables, spliced
    by key in place.
11. Skip unfitted keys. **Done** (NA records are ignored).

## Ordering
12. Rebuild order; `vignette_bib.R` and `readme_figure.R` were missing. **Added**; chinook always reruns.

## Assumption
13. `git status` was not empty before; compared before and after. 14. CH came from the dev cache; reported.
15. Run names: hyphen now refused. 16. Seeding candidate caches: **not taken** (see task_plan.md). 17. First-line
    phrases kept.

## Scope
18. Pins that move with a real promotion: listed in 0335's header and CLAUDE.md as a manual step.
19. 0330 STAGE=maps/gpkg now only on a candidate: intended.

## Acceptance
20. Round trip strengthened: real layout and log names, md5 of ignored files, a by-key round trip, 0325 run locally.
