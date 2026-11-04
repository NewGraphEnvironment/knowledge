# #120: tuning on link's minimal network — mechanics and the four-group test

## Outcome

The tuning pipeline can now build, score, grade and compare on a second link build beside the full one, and the
four-group test on link's proof schemas (`zz415_default`, `zz415_minimal`; BULK, SETN, MORK, COTR) shows the minimal
network removes the catch from the segment while leaving everything else the tuning reads unchanged. The mechanics:
`knw_build_record()` reads link's tokens from `<schema>.log` (they were never on `log_recompute`, so every tokened
build had recorded none); `0310` writes `EVIDENCE_DIR` with a tagged ledger and refuses the default directory to a test
build (asked of the disk by a sentinel file); `0300` and `0310` take `SCHEMA`, `POLL_MIN` and `SETTLE=`, the gate
staying the run id; `PARENT_DIR` joins link's parent table through `knw_parent_join()`, held to segment lengths
because link numbers each group's segments from 1; `0320` takes `DEV_DIR`, `GRADIENT=parent_gradient` and the
`MIN_WSG`/`FOLDS` floors, which promotion refuses; `0330` holds a staged evidence directory to the curves' md5s;
`access_check.csv` is per group. What was learned: four groups fit only bull trout rearing, and the smoke gate refuses
chinook rearing on three folds, so the chinook result waits for the province (link#441) and the transfer cost in km
for the parent table on link's full network (link#444). The durable verdict is
[`research/minimal_network_tuning.md`](../../../research/minimal_network_tuning.md); the issue body carries the province
and every-setup steps.

## Measurement

- Catch-start gap on the tuning's stream branch: full network 52.0 % of visits with fish against 5.8 % of empty ones
  start their own segment (median 298 / 458 m); minimal 2.8 % against 1.5 % (742 / 742 m). The premise held, so the
  test went on.
- Placement, walks (40,068 rows), species outcomes (22,902 rows) identical; accessible km equal per species × group;
  access codes differ at 141 visit × species pairs, all 1 → 2, none across zero; every visit's parent is the minimal
  segment it sits on, none straddling.
- `DEV=1 0320` at `MIN_WSG=4 FOLDS=4`, 0.2 min for 18 keys: bull trout rearing alone fitted; minimal and full-parent
  byte-identical; full the same rule from a narrower region (87 against 117 rules); Atlas line g ≤ 0.20 against 0.25.
- Chinook at `MIN_WSG=3 FOLDS=3`: refused by the smoke gate (rule coefficient 20.0, limit 5). Bull trout graded (4.3,
  4.1 min) and compared (0.6, 0.7 min): regenerated `default` equals link's stored km in every group, 0 km apart.
- The issue's chinook figures (BULK 2,205 …) are the minimal schema's stored rearing; the full schema stores 6–104 km
  less per group.
- Measured gradient (#121's check) on the same 1,178 visits: Spearman 0.696 on both networks; chinook flips at 11 %
  on 8.5 % against 8.7 %.
- A wrong turn: the first database probe (plan mode) reached the published build's database, found no `zz415_*`, and
  read link's stale README line as their removal; the schemas were on the local fwapg all along.

## Evidence

`scripts/logs/habitat/20261102_*` (settle logs, tagged ledgers, the minimal-network, segment-gradient and
site-gradient checks) and `scripts/logs/habitat/minimal_network_120/` (the DEV, grading and comparison logs). The
branch review is `review-round*.md` and `review-enumeration.md` here: five rounds, three of which found a defect inside
an earlier fix, closed by an enumeration of every path written and every guard added.

## Owed

- Phases 5 and 6 on their own branch when link#441 / link#444 land (carried in the issue body); before them,
      wet's current build loaded on m4 so the published and minimal setups share one flow load

Closed by: PR for #120 (branch `120-tune-chinook-rearing-on-minimal-segments`); #120 stays open for Phases 5–6.
