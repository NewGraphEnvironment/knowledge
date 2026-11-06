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
- Cold walk check: visit walks differ in target line on 12.6 % of rows, distance on 0.05 %; grade sample distance on 0.12 %. The host's own cold walk reproduces its cache, so the databases walk differently: an unordered tie at the walk's landing (filed #162). Same class as #161
- `SPECIES=CH RUN=20261106_0423 0320` (8 workers): 670 s wall, scoring 9.0 min, grading 1.9 min with every walk from the cache. Pick kept. tune, seeds, honest, curves, groups byte-identical; summary and grade record identical but context; smoke different only in its `previous` row (expected); grades different on 315 segments' size (#161's parent tie), moving 50 grades and 3 classes. Machine control skipped (reason in task_plan)
- `0330 SPECIES=CH` (6 workers, GPKG=FALSE): 836 s wall, 13.8 min compared (host 14.0). km drawn equal; change and checks equivalent (≤ 7.3e-12); compare different only in graded km (≤ 0.0495 km), the #161 grades
- `RUN=20261106_0423 0320` every key (8 workers): 3,020 s wall, scoring 40.0 min (host 17.8 on 14), every walk from the cache. 7 of 7 picks kept; every key's tune, seeds, honest, curves and groups byte-identical; grades differ in size on 40 to 443 segments per key, every one a parent tie (#161; two of BT's at equal non-zero distance); GR one rate on a 5-digit rounding edge (equivalent at 1e-5, the file's precision). CH pass 2 reproduced pass 1 byte for byte
- `0330 SPECIES=BT,CO,GR,ST,WCT` (6 workers, GPKG=FALSE): 2,186 s wall, 36.3 min. Every km drawn, lost and gained equal to the host's; change/checks equivalent (≤ 9.5e-11) and the composed change and checks identical; BT, CH, ST and the composed compare differ only in graded km (#161)
