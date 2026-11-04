# Plan review (#141), Plan agent, 2026-11-04

Verdict: no blockers; the Context numbers recompute; adding summary and pick-report columns breaks no reader
(knw_tune_promote compares nine named fields; knw_thresholds_table binds on the union; log globs are `_tune_run.*\.txt`).

- Gap 1: a best with `exc_d < d_floor` can never be recommended (tune_score.R:460-461 against .tune_sel), so its
  exception part is forced by d_floor, not the start: published BT_rear, ST_rear and candidate BT_rear. Flag it, and
  report the distance to the best rule d_floor allows.
- Gap 2: `ddev / se` is 0/0 at the best; define it.
- Gap 3: `*_is_best` must mean in the tie set, not `== rule_best`; test a pick that is the second tied rule.
- Gap 4: which tied rule names the parts at equal counts: say the first in grid order.
- Gap 5: a flow start with no `recommended_flow` should be refused, not read as no flow start; pre-#80 columns optional;
  coerce text; NA-aware exceptions.
- Gap 6: tests: (a) parts against knw_tune_grid()'s `departures` and `departures_flow` on a real grid; (b) recommended
  differing from pick (d_floor); (c) ties differing only in exc_d; (d) Gaps 1 and 3.
- Gap 7: data-raw/README.md describes every check; add one for tune_anchor_check.R.
- Acceptance 1: add expected departure counts (published GR 2/2/1, CH 0/1/1; candidate GR 2/1/1, BT rear 3/3/0).
- Acceptance 2: DEV=1 needs no database (0320:206-208); it needs data/fdis/derived_minimal and LINK_REPO at the
  build's sha. Copy caches from data/tune/dev_minimal (same evidence, extra = FALSE), not the candidate; compare with
  knw_tune_anchor() on the DEV run's own tune.csv.
- Ordering 1: the check's .txt should name the knowledge commit it ran at.
- Ordering 2: check the guard before tune.csv is written (0320:333), so a stop leaves no new grid beside an old summary.
- Assumption 1: published summaries have no `tune_run`; allow NA; add each tune.csv's md5 to the log.
- Assumption 2: csv ddev rounded to 6 places could tie differently from the scored table; best need not be converged
  (every rule converges today). Low risk.
- Scope (optional): published anchor values in pick_report.csv; not needed (pick_report is never promoted).

## Disposition

Folded in after verifying each against the code: Gaps 1, 3 (already ddev == 0, tested), 4, 5, 6, 7; Acceptance 1 and
2; Ordering 1 and 2 (the guard moves before the write; it stays a plain stop() so no `_tune_run` log is written for a
code fault); Assumption 1. Gap 2 was already 0 in the check script. Assumption 2 and the scope item are not taken.
