# Plan review (#101), Plan agent, 2026-10-28 21:50-21:53 UTC

Findings as returned, with the verdict after each probe.

- **Blocker — identity check cannot pass.** Tracked `data/compare/{CH,BT}_rear_compare.csv` are #92's run (picks CH
  `mad>=0.75|g<=0.11|Q3@D1000`, BT `mad>=0.1|g<=0.3|none`, fresh 0.43.0); the ignored local `data/tune/*_curve.rds` and
  `*_grades.csv` are 2026-10-25 (CH `g<=0.13`, BT `mad>=0.35|g<=0.25`), and fresh is now 0.44.0. Hold only the
  pick-independent columns (`accessible_km`, `access_gate_differ_km`, `stored_km`, `default_km`,
  `stored_vs_default_differ_km`) and gate on fresh's version. **Confirmed** (picks read from both; #92 graded on the
  remote machine). Fixed: the script holds those columns, gated on flow load and fresh.
- **Assumption — GR duplicate stale.** #92's GR pick is `width>=2|g<=0.0549`, not `default`'s; CO and ST now run four
  rules. **Confirmed**; the duplicate depends on the pick. Plan and issue text say so.
- **Assumption — near-river claim** checked at link origin/main, not `102762da`; tuned tables also read `pr$other`.
  The run's own log line (every predicate, `other` included, on the run's configs) settles it. Kept.
- **Gap — BT spawn may reuse BT rear's `default`** (same SQL but the stage's waterbody floors). Noted; stage stays in the
  key until proven.
- **Acceptance — summed worker-minutes vs wall × workers** is the wrong cross-check (idle tail of the slowest bin).
  Fixed: per-bin timed totals logged beside the stage's wall minutes.
- **Honesty — projection** must use the slowest bin, not the summed share; baselines 37.1/33.4 min were fresh 0.42.0;
  a cache saves nothing on its first fill. Fixed: the log projects the slowest bin without `default`'s steps.
- **Scope — #112** also saves on summaries, the bootstrap and GeoPackage columns: the measured saving is a lower bound.
  Stated in #112's body.
- **Test — OK**, but `all.names()` sees variable names too: prefix the worker's new names. Fixed (`bin_`).
- **Ordering — ledger vs grades' run_uid.** Grades carry `run_uid` 20261017_004619-3f4c713b, the ledger's. Checked.
