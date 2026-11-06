# #158: a retune reproduced on a second database

## Outcome

The published retune (run `20261104_0543`) was rerun on a second database holding the same link build, flow load and walk
cache: `0310` into `data/fdis/derived_second`, a full `0320` candidate (`20261106_0423`, chinook rearing first, then every
key) and `0330` for every key. Each output was compared with the published copy, one verdict per output, by
`data-raw/database_compare.R`. Every pick and every tuning score, curve and nested selection came out as published, and so
did every km drawn. The grade tables, three visits' flows and cold walks differ through two "nearest row" lookups with no
tiebreak, which each database breaks its own way: `knw_link_flow()`'s parent flow (#161) and the walk's landing (#162).
crate 0.12.0's receipt comparison (`data-raw/database_receipts.R`) agrees with the hand verdicts on every table it could
read, and found two gaps of its own (crate#49 `IDate`, crate#50 tables past 2^31-1 bytes of canonical form). The durable
verdict is `research/database_builds.md`, "A second database"; #154's body carries the tolerances measured here.

## Measurement

- Verdicts (`scripts/logs/habitat/database_second/20261106_database_compare-*.csv`): evidence 5 identical, 1 equivalent
  (access check, 6.0e-11 km), 1 different (`visits_link`'s `mad_pick` on 3 of 45,529 visits, at most 0.0029 m³/s, #161).
  Tuning: 7 of 7 picks kept; every key's tune, seeds, honest, curves and groups byte-identical; grades different in size on
  40 to 441 segments in five keys, moving up to 276 grades and 9 grade classes (#161); BT spawning identical, GR equivalent.
  Comparison: every km drawn, lost and gained equal; graded km different by up to 0.41 km per group on BT, CH and ST.
- Cold walk on this database against the host's tables: the target line differs on 12.6 % of 775,488 visit-walk rows and the
  distance by more than 5 mm on 0.05 %; 0.12 % of 20,000 chinook grade starts move 44 to 529 m (#162).
- Minutes (second database against host): `0310` 11.5 wall; `0320` every key 50.1 against 51.7 (scoring 40.0 on 8 workers
  against 17.8 on 14); `0330` CH 13.8 against 14.0 and the other six 36.2 against 32.9 summed per key. Every grade read its
  walks from the cache (0 misses), so only the cold check exercised the walk.
- crate: 85 of 109 outputs agree outright; 22 equivalent by hand are identical to crate, which fingerprints doubles rounded
  to the tolerance (a difference of definition); 2 not read (crate#50). 43 min.

What changed because of them: a promotion takes all its keys from one database until #161 and #162 land (CLAUDE.md,
"Database access"), and #154 starts from the tolerances in its body.

Wrong turns, kept: the walk's distance gaps were first read as the host landing on a non-nearest segment (the target pairs are
exactly as far apart as the gaps); the isolated landing query, even forced onto the GiST index, returns the same order on both
databases, and the walk's own diagnostics showed the tie at a shared vertex where one tied segment has no flow row. Walks were
also first read as stored to the centimetre, from a truncated data.table print; they are full doubles, so 0.005 m is a chosen
tolerance. The review rounds found the comparison's tolerances finer than the writers' rounding and a key (access check, per
group since #120) that paired rows by position; both are now measured from the writers and guarded.

## Evidence

`scripts/logs/habitat/database_second/20261106_*` (verdicts, tune and compare logs, sessionInfo) and
`scripts/logs/habitat/20261105_evidence_build_ledger-derived_second.csv`.

## Owed

- Delete the candidate (`data/tune/candidate/<stamp>/`, `data/compare/candidate/<stamp>/`) and the restored reference copies, on Al's word

Closed by: the PR for #158
