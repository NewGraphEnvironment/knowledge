## Outcome

Al's word (2026-11-04) to grade, compare and promote #145's retune. The build models neither rainbow trout nor
kokanee (their access columns are empty on every segment), so `knw_tune_run(modelled =)` writes `not_modelled` for a
species with no access value, `0320` passes the species that have one (and stops on a missing column), and the
published rainbow trout rearing rule was retired (Al's choice at the question). The build's evidence became the default
directory (re-settled under the default name; the published evidence copied aside and archived), then full `0320`
(run `20261104_0543`), `0330`, the Atlas-gradient sensitivity the promotion's guard required, and `0335`. Four picks
moved against #92's: three outside #92's region (bull trout spawning, chinook rearing to 13 %, grayling rearing), one a
reshuffle (bull trout rearing). Both articles, the test pins, `research/` and `CLAUDE.md` follow it.

## Measurement

- Full `0320` 51.7 min (scoring 17.8 min on 14 workers); picks identical to the `DEV=1` run's. `0330` 50.9 min with
  GeoPackages; `GRADIENT=fwa_gradient` 5.4 min (all seven keys keep #92's sensitivity picks); `0335` 10 min.
- Tuned against regenerated `default`: BT rearing −23.5 %, BT spawning +23.8 %, CH −14.1 %, CO −3.2 %, ST −24.6 %,
  GR +11.1 %, WCT +19.1 %. Grades withheld for CO, WCT and, newly, BT spawning (curve 404.4 against 403.9 for no rule).
- At 1.96 SE four of seven keep `default`; chinook's pick does not move.
- The default evidence rebuilt from the same build is byte-identical to the tagged one but for `access_check.csv`'s
  float summation order (9.5e-11 km).

## Evidence

`scripts/logs/habitat/20261104_*20261104_0543*`, `scripts/logs/habitat/20261103_link_settle.csv`,
`scripts/logs/habitat/20261103_evidence_build_ledger.csv`, `scripts/logs/habitat/default_build_145/`; the reviews are
`review-promo-round*.md` here.

Closed by: PR #146 (closes #145)
