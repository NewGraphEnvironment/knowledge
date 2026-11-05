# Plan review (#149), 2026-11-05

A Plan agent read `task_plan.md` against the code and the issue after the baseline (ceed6c9). Its findings, condensed,
each with what was done. Probed before acting.

| finding | disposition |
|---|---|
| B1 the maps had no water and no background (`setup_compare.R` reads both from the database) | taken: the stage carries lakes ≥ 10 ha and river polygons near each line and in the map group, and the map group's accessible full segments (from the published comparison's segments, held to setup_compare's md5) |
| B2 the concept profile needs elevations; `st_zm()` would drop them | taken: segment and Atlas-line ends carry `z_dn`/`z_up` as columns; the Atlas line's vertices are kept as (measure, Z) |
| G1 #92's network exists only in a tracked log | wrong: #92's evidence is on the host (`derived_published_20261017`, md5s equal its tune tables'), so it is staged and recomputed; all three networks are also held to their segment gradient check logs |
| G2 the six-key sentence comes from `20261104_pick_network_compare.csv` (the full network's DEV tables), not the promoted tune tables | taken: the bundle reads that tracked log; the minimal run's other keys are no longer staged |
| G3 transfer and the published rule's network had no bundle item | taken: transfer recomputed from the GeoPackage and held to the setups' km; each setup carries its tokens |
| G4 sites need map geometry | already done in the first stage (`fwa_locatealong`) |
| G5 the concept stream had no rule; "largest gap" picks slivers | taken: both rules written in the bundle script, with a 50 m floor on the full segment |
| G6 refusals weaker than `setup_compare.R`'s | taken in part: every staged run file is held to the md5 setup_compare logged, which carries all of its checks; evidence held to the grade records' md5s |
| B3 pinning `data/tune` and `data/compare` breaks at the next promotion | taken: the bundle pins only tracked logs written once and the staged copies |
| G7 NOTICE needs the new rds | taken |
| G8 no host names in tracked text | checked: logs and commits name none |
| A3 the Atlas run's tables survive only on the host | noted: the stage now holds them too, on the same disk; archiving waits on link#460 |
| O1, O2 commit `.gitignore` and each script before its run | done |
