# Plan review — #65 (Plan agent, spawned 2026-10-19 20:35 UTC, returned ~20:39 UTC)

Findings as returned, each with the verdict after a probe.

| # | Class | Finding | Verdict |
|---|---|---|---|
| 1 | Blocker | The new walk set (`size > 0`) is not a superset of the old (`!size_ok` included NA and 0 sizes). `knw_compare_rules()` reads `knw_dist` for the exception, so no-size segments near a river would drop out of the tuned rule (up to 3,813 CH and 25,109 BT accessible segments with no size, #57 log L1445-1446). | **Real.** Probed against HEAD `R/grade_species.R:49-51`. Fix: walk every accessible segment with a gradient, whatever its size; grading unchanged. Test: a no-size accessible segment is walked. |
| 2 | Blocker | `0322` grades candidates whose `exc_q` differs from the curve's `q`; walking to `curve$q` gives their exception the wrong river. | **Already fixed** before the review read it: the walk goes to the pick's `exc_q`, else `curve$q`; tested. |
| 3 | Blocker | On a regrade, `0320` logs two lines starting `CH_rear grades:` (the "on file … regraded" notice and the result), and `data-raw/vignette_chinook.R:142-143` stops unless exactly one matches. | **Real.** Fix: the regrade notice no longer starts `<key> grades:`. |
| 4 | Gap | The CH rerun writes `<key>_{seeds,honest}.csv`; `vignette_chinook.R` then reads them and pins their md5, so they must be committed. `git diff --stat` misses untracked files. | **Accepted** into Phase 2: check `git status --short data/tune` and commit what the vignette pins. |
| 5 | Gap | `WORKERS=14` does not speed walks: 0320 caps them at 8. | **Accepted, no change**: run locally (10 cores) at 8. |
| 6 | Gap | Add `*_checks.csv` to the identical-to-main assertion. | **Already covered**: the scratch check walks every tracked `data/compare` csv. |
| 7 | Gap | A shared `q_grid = c(3, 10)` walk would break `match()` (first row per start). | **Noted**; only relevant to the BT fallback, which needs a `qmin` filter if taken. |
| 8 | Assumption | A lost segment between the two gradient maxima now carries a distance, so its reason could move from "no exception" to "gradient: tuned maximum lower" where the tuned maximum is below default's. | **Real but bounded**: the change-table check catches any move; the condition is written into findings. |
| 9 | Assumption | Confirm the score cache is hit (seconds, not a rescore), and that refit tune/curves/groups/summary files come back unchanged. | **Accepted** into Phase 2 (log line + empty diff). |
| 10 | Assumption | 2.5 h is linear; q = 10 walks are longer and there is no checkpoint. | **Accepted**: CH first to measure; budget more. |
| 11 | Scope | River-polygon and wetland segments now read the surface near 0 m with sizes beyond the curve's training population (stream-branch visits outside waterbodies), raising the reference. | **Decided at the gate** (all edge types). Record it in roxygen and the research Limits, with the measured effect on the reference. |
| 12 | Acceptance | The restore-the-bug test misses item 1; old wording also in `R/tune_curve.R` and `scripts/0294`. | **Accepted** (new test). `0294:11` describes 0294's own walk, not the grade; `R/tune_curve.R` checked below. |
