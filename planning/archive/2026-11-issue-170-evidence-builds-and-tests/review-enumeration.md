# Code check, #170: the enumeration that ended the loop

Round 3 found a defect inside round 1's fix: the sites refusals' remedy ("rerun scripts/0240, or set SITES_DIR")
is wrong for a staged build (0240 writes only `data/fdis/{build,derived}`) and for 0335 (which reads no `SITES_DIR`).
Its mechanism, as round 3 named it: the check and its callers rebuild 0240's output contract (paths, bytes) from their
own side. Fixed: the remedy is "rerun scripts/0240" only when `f_rds` is the checkout's `data/fdis/build/sites.rds`,
else "set SITES_DIR"; an infinite double now equals only itself (round 3's latent `Inf <= Inf`).

The set: every refusal and skip the branch adds (`git diff <base> -- R/ scripts/ data-raw/ tests/testthat/test-link_place.R`,
grep `stop(` and `skip`), against every caller (`grep knw_archive_plan( .knw_archive_sites_check(`: 0336:100,
0335:114, 0335:147, the tests). 7 members:

| refusal | callers | remedy holds? |
|---|---|---|
| sites: rows / site set (`R/archive.R`) | 0336 default; 0336 staged; 0335 (`build_dir` fixed at `data/fdis/build`, 0335:89); tests | yes: the checkout's build gets "rerun 0240", any other "set SITES_DIR", which only 0336 reads and only 0336 can reach with another build (0336's guard) |
| sites: a column differs | same | yes, the same `fix` |
| sites: integer64 column | same | names the cause; no caller remedies it but code (by design) |
| pull: a target with other bytes | `knw_archive_pull` (0336 PULL) | yes: "move it aside", before anything is written |
| 0336: staged `BUILD_DIR` without `SITES_DIR` | 0336 archive path only (PULL skips it) | yes: 0336 reads `SITES_DIR`; `./` or a trailing slash fails closed (accepted) |
| skip: a table missing | live placement test | names the table |
| skip: no BULK BT rearing row | live placement test | names an empty or partial build |

Mutations, each red on its own test, none red on the tree: reading from `evidence_dir`; no sites check; no restore
pass; no NA-pattern check; no `encoding`; `Inf` compared by tolerance; the remedy always "rerun 0240". The real build
passes under its default locale and `LC_ALL=C`.
