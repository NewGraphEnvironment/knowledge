# Progress — Run a retune on the second database (#158)

## Session 2026-11-06

- Plan-mode exploration — phases approved by user
- Created branch `158-run-a-retune-on-the-second-database-chin` off origin/main
- Scaffolded PWF baseline from issue #158 with approved phases
- Owner, mid-planning: crate PR #44 merging; install it once merged and run the provenance task in this run (Phase 4)
- Next: start Phase 1
- link 0.78.1 installed (fresh 0.52.0 kept). Restored evidence md5s match the ledger (visits_link, visits_species, walks, sites.rds); fish/catch copied (md5s match); the archive lacks bcfishobs_fdis_match, access_check and workbook_*, copied from the host's checkout of the published build
- `data-raw/database_compare.R`: verdict per output; self-test of 15 fixtures, three planted defects each turn it red
- `0310` on the second database: 690 s wall (11.5 min, 4 workers, walks all cache hits as on the host). Verdicts: visits_species, walks, bcfishobs_fdis_match, workbook_sites, workbook_species identical (workbook_sites bytes differ, content equal); access_check equivalent (6.0e-11 km); visits_link different in mad_pick on 3 visits (max 0.0029 m³/s), caused by an unordered tie in `knw_link_flow()` (filed #161), not the database; the ledger identical but context and #120's two new rows (zone zip md5 equal)
