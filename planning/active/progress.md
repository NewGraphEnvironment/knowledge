# Progress — promotion of #145's retune

## Session 2026-11-04 (UTC)

- Plan written (76323e8); `not_modelled` (6a420e1).
- Settle under the default name released 05:25:22Z (same run and link commit). Plain `0310` into `data/fdis/derived`,
  05:25 to 05:42Z: `visits_link`, `visits_species`, `walks` and the other tables byte-identical to the tagged build's;
  `access_check.csv` differs only in float summation order (max 9.5e-11 km, same rows and counts).
- The published evidence directory copied to `data/fdis/derived_published_20261017` (ignored) before the rebuild.
- Next: full `0320`.
- Full `0320`, run `20261104_0543`, 05:42 to 06:34Z (51.7 min; scoring 17.8 min on 14 workers): KO and RB
  `not_modelled`; seven keys fitted, picks identical to the `DEV=1` run's. Grades withheld for BT_spawn (new: the
  published run graded it), CO_rear and WCT_rear (as published).
- `0330 TUNE_DIR=data/tune/candidate/20261104_0543` started 06:36Z on this host.
