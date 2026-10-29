## Outcome

`scripts/0330-compare.R` now regenerates link's flags under `default` and the reported structure (`TUNED_AS`, `door`)
alone; `STRUCTURES=all` brings back `free` and `door_wetland`. `knw_compare_rules(structures = "reported")` resolves
the structure and refuses one outside the species x rule's own set (the plan review found an explicit subset bypassed
that). `.knw_compare_bin()` now times each rule and the shared per-group setup (`worker_minutes`), and
`data-raw/compare_structures_check.R` proves the change: a reported-only run returns exactly the every-structure run's
`default` and `door` rows. Al chose at the gate to drop the other structures' sentences: the chinook article lost its
free-pass clause (its bundle not rebuilt, #111), and the research files keep #92's figures as a record. The settings
register's `STRUCTURES` row could not land, because `settings.csv` is md5-pinned in the methodology bundle; it is
#115. A parallel session started #101 on the same lines mid-run; Al ruled #112 first, #101 reads its measurement.

## Measurement

On the database's host, idle (`research/database_builds.md`, "Comparing only the structure that is published"):
WCT rearing (16 groups) 4.5 -> 3.2 min, CH rearing (20 largest) 16.6 -> 12.6, BT rearing (20 largest) 9.9 -> 7.0;
the dropped rules were 33, 31 and 29 % of the every-structure run's worker minutes; about 46 of #92's 164 classify
minutes on all keys, by borrowed shares for RB, CO and ST. Every reported-only table equalled the every-structure
rows (largest relative difference 9.9e-14, flags identical), and WCT's every-structure run equalled #92's tracked
tables row for row (1.7e-14) on fresh 0.44.0. Wrong turn kept: the first pass overlapped a link run from another
session on the same database until 22:18 UTC (found in #101's notes after the fact), so CH and WCT were rerun on an
idle database; the shares barely moved (CH 31 both times, WCT 35 then 33, on different inputs). The host's ignored
inputs were an older build than #92's, so #92's WCT inputs were staged beside the repo for the tracked-table check.

## Evidence

`scripts/logs/habitat/20261028_compare_structures_check*`

Closed by: PR for #112 (branch `112-compare-only-default-and-the-reported-st`)
