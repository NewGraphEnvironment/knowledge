# Plan review (Plan agent, 2026-10-28) — dispositions

- B1 settings.csv md5 pinned in method.rds (data-raw/vignette_method.R sources; test-vignette-data.R:97-107):
  CONFIRMED. Register left untouched; the `structures` row and the `tuned_as` note go in with the next method bundle
  rebuild (follow-up issue).
- G1 explicit `structures` bypasses the species' set: CONFIRMED. `structures = "reported"` resolves inside
  knw_compare_rules() to intersect(pick, tuned_as), refused when empty; an explicit subset outside the set is refused.
- G2 register literal form: moot after B1; 0330 still reads `Sys.getenv("STRUCTURES", "reported")` once, literal.
- G3 tracked comparison not pinned: CONFIRMED (fresh 0.44.0 here and on the host, #92 ran 0.43.0). Tracked
  comparison made informational, with flow load, evidence md5, schema run and fresh version reported beside it.
- G4 warm cache inflates the saving: CONFIRMED in principle. The gate reads the every-structure run's own per-rule
  worker minutes; wall times reported beside it.
- G5 mixed structure sets compose silently: accepted (no reader breaks); 0330 logs each composed key's structures.
- O1 commit before the host run: done (and again after these fixes). O2 log overwrite: .knw_free_path.
- S1 research free-pass rows: kept as #92's record; CLAUDE.md names STRUCTURES=all for refreshing them.
- S2 CH through-wetland log line loses free: accepted; research quotes #92's log.
- A1 unit tests for the resolution: added. A2 combined tables/GeoPackage: no tracked reader of the dropped columns.
