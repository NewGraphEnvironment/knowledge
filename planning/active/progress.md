# Progress — Tune habitat thresholds for every species and life stage in one run, as package functions (#57)

## Session 2026-10-17

- Plan-mode exploration (scripts 0290–0299, R/, research/, link and fresh checkouts, the floodplain catalog,
  a read-only probe of `fresh_default`); phases approved by user, four plan-gate decisions taken
- Plan-agent review: 31 findings, all folded into the phases (`findings.md`)
- Created branch `57-tune-habitat-thresholds-for-every-specie` off main
- Scaffolded PWF baseline from issue #57 with approved phases
- Next: Phase 0 waiter in the background; Phase 1's fixture-driven functions meanwhile

## Session 2026-10-17 (continued)

- Phase 0: `0300` released at 10:54:24Z (run_uid `20261017_004619-3f4c713b`); record in `scripts/logs/habitat/`
- Phase 1: `knw_fdis_quality()`, `knw_fdis_species()`, `knw_species()`, `knw_link_place()`, `knw_link_flow()`,
  `knw_link_width()`, `knw_link_regulated()`, `knw_link_barrier_dnstr()`, `knw_link_walks()`,
  `knw_link_access_check()`, `knw_bcfishobs_match()`, `knw_fiss_visits()`; `scripts/0310`; `0290`/`0294`/`0296`
  reduced to calls; `0299` versioned (v3). The build ran four times before its walks: size classes for
  species the breaks do not tile, `integer64` ids, an unqualified connector on the workers; fourth run in flight
- Phase 2: `knw_tune_grid()`, `knw_walk_index()`, `knw_rule_in()`, `knw_tune_score()`, `knw_tune_curve()`,
  `knw_grade()`, `knw_spawner_evidence()`, `knw_link_segments()`, `knw_grade_species()`, `knw_tune_run()`;
  `scripts/0320`; run host upgraded to link 0.66.0, fresh 0.39.0, flooded 0.8.2
- Phase 3: `knw_publish()`, `knw_thresholds_table()`, `scripts/0325`
- Phase 4: flooded#89 filed and PR #90 opened (`fl_valley_join()` returns `seg`); `knw_compare_rules()`,
  `knw_floodplain_ha()` (LARL smoke run: 417,232 cells, all owned), `knw_compare_map()`, `scripts/0330`
- Commits: f3e74c0 … 428105c on `57-tune-habitat-thresholds-for-every-specie` (pushed)
- Next: build output → `0290`/`0294`/`0296` → `0299` v3 locally → data to the run host → `0320` there →
  `0325` → `0330` → research files → Phase 5 → lint pass → `/code-check branch` → `/planning-archive` → PR

## Session 2026-10-17 (results)

- `0310` ran on the released run (fourth attempt; three fixes on the way): 40,552 visits placed, ledger committed
- `0320`: scoring of 22 species x stage in 104 min on the run host; its grading hung (connections without a
  timeout) and finished here: RB's 210 groups in 3.2 min against the host's 54 min for BT. Eight fitted; `default`
  outside the region for all but GR; CH's floor settles at 0.75 m3/s
- `0325`: `data/thresholds.csv` (46 rows), `data/thresholds_groups.csv` (374), grade table 47.4 M rows (local Parquet)
- research: `habitat_thresholds_tuned.md` and one file per species; CH, BT files point at them
- `0330` in flight (compare + floodplain + maps)
- Next: `0330` results into the research files; lint/code-check branch; planning-archive; PR
