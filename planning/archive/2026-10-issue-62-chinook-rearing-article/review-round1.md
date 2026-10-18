# Code-check round 1: branch 62-chinook-rearing-as-a-vignette-how-the-th against main

Reviewer: one subagent, 2026-10-18. Method: read every changed file in full; ran
`test-vignette-data.R` and `test-compare_map.R` (NOT_CRAN=true, load_all) on a copy of the tracked tree
(PASS 37 + 9, 0 fail); rendered `vignettes/chinook_rearing.Rmd` from that copy and checked every inline
number and hard-coded claim against `inst/vignette-data/chinook_rearing.rds`, `R/tune_score.R`,
`R/grade.R`, `R/compare_rules.R`, the tuning log and the other species' tune/compare tables; viewed all
three rendered figures; scanned the rds/tif outputs and the added lines for hosts, home paths and
private identifiers (none).

Verified correct (no action): 2,795 = 13 x 5 x 43 rules; region of 23, all MAD 0.35-1, all with the
exception (Q 1-10, D 1-2 km), gradients 7/9 %, so "departs from `default` in all three parts" holds; best
no-exception 136.9, best width 70.6; 166 vs 165 catches; seeds 0/4 same, 4/4 in region, 3 differ only in
gradient; nested selection loses only fold 4 by 3.6, every fold's choice is MAD + exception; bootstrap
shares (55/76/62/33/40/34/25 %, gradient least settled); "earlier tuning ... 7 %" matches
`chinook_rearing_tuned.md`; curve points (26 %, 2.6x, peak ~120 m, 1.7x at 300 m, 42 % at 3 km, 21 % at
10 km) and the gradient curve's log-linearity (edf 1.00); grade = rate / 95th percentile capped at 1
(`R/grade.R`), ungraded = no size (no_gradient = 0 in the log); km, graded km, change range/median/48 of 125,
loss/gain reasons (98.8 % / 79 %), BULK figures; floodplain -20 % vs km -12.4 % (and -18.8 % on the same 16
groups), graded +0.9 %; FDIS rates and bcfishobs lifts. `knw_compare_map(ncol = NULL)` reproduces the old
layout (nc = length(panels), nr = 1, same size). `grid::`/`stats::` in the vignette are base packages and
exempt from the unstated-dependency check. `habitat_thresholds_tuned.md`'s "In plain words" claims hold
against every species' summary and compare tables (only GR has `default` in region and a 0 % change).

## Findings

- **[fragile]** data-raw/vignette_chinook.R:56-57 (with :118-119) — the provenance ledger is chosen as the
  newest `*_evidence_build_ledger.csv` in `scripts/logs/habitat/`, independently of the tuning log, which is
  hard-coded at :45 and itself names the ledger it was built on (log line 1: "Evidence build
  scripts/logs/habitat/20261017_evidence_build_ledger.csv on link run 20261017_004619-3f4c713b"). After any
  later evidence build (a `0310` rerun) and a rerun of this script, `meta$link_run_uid` and `meta$link_sha`
  silently name a link run the article's tables were not scored on, and the article prints it as "Every
  figure is on link run ..." (vignette :518). Nothing stops it: the md5 guard covers only the ledger file
  chosen, not that it is the log's. Take the ledger path from the log's first line (or stop when they
  differ). Correct today.

- **[fragile]** tests/testthat/test-vignette-data.R:18-28 with data-raw/vignette_chinook.R:53-55,131 — the
  md5 guard hashes whole multi-species files, `data/thresholds.csv` and `data/compare/floodplain.csv`, of
  which the article reads only the CH rearing rows. Any rerun of `0325`/`0330` for another species (or a
  `thresholds.csv` edit to BT/CO rows) fails this test although nothing the article prints moved, and the only
  remedy offered is a rerun of `data-raw/vignette_chinook.R`, which needs the fwapg database and the catalog
  download. A guard that fires on unrelated changes trains people to rerun without looking. Hash the
  filtered CH rows (e.g. `digest` of the CH subset as read) for those two files instead of the file bytes.

- **[bug, wording]** vignettes/chinook_rearing.Rmd:492-497 — "On all FDIS visits on these groups' accessible
  segments, rivers included ... These are the visits the tuning learned from". (a) "these groups" follows
  directly on the floodplain paragraph about the 16 mapped groups, but `fdis_visits` in
  `R/compare_rules.R:307-325` pools all 125 groups compared; (b) the check counts 10,515 visits (5,717 + 4,798
  on `default`), more than twice the 4,490 stream-branch visits in 43 groups the tuning scored, because it
  adds river edges (1250/1350), edge 1050/1150/2100 and groups with no contrast. So it is not "the visits the
  tuning learned from" but a superset that contains them; (c) "all" overstates it slightly, since visits
  outside 10-10,000 m² and with no present/absent status are dropped. Suggest: "On the FDIS visits on
  accessible segments in all `r nrow(per_group)` groups, rivers included (`r n0(...)` visits, a superset of
  the ones the tuning scored) ...". The in-sample caveat itself stays right.

No other real issues found. Tests and render pass; no public-text leaks in the diff or the shipped data.
