## Outcome

FDIS site visits are now placed with `fresh::frs_point_snap()` twice, to the nearest stream and to each 20k stream the
visit's 1:50k watershed code names (passed as a per-point hint), and `knw_fdis_place()` picks the nearest named
stream in reach, else the nearest stream. That replaces `fwa_indexpoint()`'s nearest snap and the 100 m and code
rejections. The limits were set by a rule fixed before the run: 200 m for an unconfirmed pick, 500 m for a
code-confirmed one. `0310` takes `SCHEMA`, checks it with `knw_build_record()`, ledgers the limits `0230` used and
caches its visit walks. What was learned: most of the old link-step losses were visits `fwa_indexpoint()` put on
unmapped or placeholder lines, which link's segments lack; those visits' new streams agree with their codes as
often as any snap at the same distance. The plan first excluded subsurface flow (1425) as fresh does; review round 3
showed that lost visits link places, so only the group-boundary connector (6010) is excluded. The retune is #92's.
`research/fdis_export.md`, "Placement", holds the verdict.

## Measurement

- Probe (2.1 min, remote link): the stored `fwa_indexpoint()` placement reproduces the old build's 1,491
  `no_link_segment` drops; 1,645 of the old snap's 2,038 link misses were unmapped or placeholder picks. The hint
  route snapped 58,269 hinted rows in 8.5 s, so no candidates-then-pick and no fresh issue were needed.
- Code-checked disagreement by the nearest stream's distance: 7.5 / 16.6 / 27.1 / 33.2 / 55.8 % in the bands to 25,
  50, 100, 200 and 500 m. The 100–200 m band clears one in three by 0.1 point, which set the unconfirmed limit at
  200 m. No CH or BT rearing region moved in the five pairs the rule compares; the regions hold 51–244 rules, so the
  check constrained little.
- Evidence ledger before (2026-10-22) and after (2026-10-27): far snap 5,242 → 1,941, code mismatch 1,088 → 377, no
  link segment 1,491 → 178, kept 40,552 → 45,529 (10,210 confirmed, 748 moved).
- `0310`'s visit walks: 113,658 start-and-source pairs cold in 6.4 min from a remote link, then 0.7 min from the cache.
- Wrong turns kept: the 1425 exclusion (reversed after round 3, with every run repeated); a `wet` dev install that
  could not run `0310` (installed v0.4.23); four review rounds of prose claims taken from the wrong artifact.

## Evidence

`scripts/logs/fdis/20261027_*` (the probe, the 500 m and final loads, the sensitivity and its build's ledger) and
`scripts/logs/habitat/20261027_evidence_build_ledger.csv`.

Closed by: PR for #91 (branch `91-place-fdis-sites-with-candidate-snapping`)
