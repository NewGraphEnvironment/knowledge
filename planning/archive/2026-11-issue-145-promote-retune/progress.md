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
- `0330`, 06:35 to 07:26Z (50.9 min, with GeoPackages). Tuned km against regenerated `default`: BT_rear −23.5 %,
  BT_spawn +23.8 %, CH_rear −14.1 %, CO_rear −3.2 %, ST_rear −24.6 %, GR_rear +11.1 %, WCT_rear +19.1 %.
- The first `DRY=1 0335` refused: `grad_fwa/` (the Atlas-gradient sensitivity) on the old evidence. `GRADIENT=fwa_gradient
  RUN=20261104_0543 0320` (5.4 min): all seven keys keep the published pick on the Atlas line. The second dry run:
  228 files written, 43 removed (RB_rear's tables, comparison, GeoPackage and 24 maps).
- `0335`, 07:34 to 07:44Z: promoted (91ae2f5). Articles' three failed checks revised (fc02fd1), research and CLAUDE.md
  prose (9756e6e, 5d3a746). Code-check: round 1 nine findings (8c14181), round 2 six, four inside round 1's fixes
  (d047635); ended on round 2's per-claim enumeration, the "published" sweep and a check of the numbers its fixes added.
  Full suite: 1914 pass, 1 failure (`test-link_place.R:39`, fails on main too).
