# Plan review, #256 (Plan agent, 2026-11-24, run beside Phase 1)

Findings as returned ([P] probed by the reviewer, [I] inferred), each with the verdict taken here.

## Blocker
1. Rule (a) requires both edges at once; measure the start edge and the end edge apart. NuSEDS keeps no per-visit counts, so a bracket is consistent with an edge, never proof of one. [P] **Folded:** Phase 1 reports start and end brackets separately (the script already counts `brackets_start` and `brackets_end` apart); Phase 2's wording says "consistent with".
2. Not every bin is ten days: 663 start bins wider than 11 days, 1,556 end bins of 11 to 30 days, some bins run backwards, 630 records have an end `to` without a `from`. [P] **Folded:** Phase 1 classifies bins by width and counts reversed bins; Phase 3 refuses a reversed bin or one over 31 days as a midpoint (the record keeps its as-recorded dates). Verify the counts in the run.

## Gap
3. Estimate method is not a candidate rule; "Area Under the Curve" (5,561 dated records) implies repeated surveys. **Folded:** rule (d), AUC.
4. Rule (b): "Fixed Site Census" is `estimate_method`, "Fence" is in `enumeration_methods`; a fence counts passage, which dates arrival, not spawning. **Folded:** rule (b) names both fields; Phase 1 sets its records' dates beside `stream_arrival_dt_*`.
5. Rule (c) proves little: one exact day can come from one visit. **Kept as a candidate** (it is measured, not adopted); Phase 2 reports it with that caveat.
6. 327 dated NOT INSPECTED records feed every window today. **Folded:** counted with NONE OBSERVED; Phase 3 decides whether the method's columns drop both (the `as_recorded` columns keep them).
7. The migration comparison uses "the day before the median start": which start after the change? **Folded:** Phase 3 names it.

## Assumption
8. Two-digit years: never `%y`. **Already so:** `nuseds_date()` takes the century nearest `analysis_yr`.
9. Season year: take a bin's midpoint after `season()` converts both ends; stop on a bin straddling the season start. **Folded** into Phase 3.
10. The hand check of a bin midpoint passes by round-half-even (11-20 August is day 228.5). **Folded:** check the numeric day; midpoints use integer halving (`%/% 2`), stated.
11. UFRA will barely move (records 1967-2000, before bins). **Noted** in Phase 4.

## Acceptance
12. `as_recorded` checks pass only if `start_day`/`end_day` stay, the dropped presence classes leave `x` untouched, and `check()` reads the renamed columns; diff every `as_recorded` row against `20261121_timing_nuseds_windows.csv`. **Folded** into Validation.
13. "Enough" is undefined: set it before the results. **Folded:** decided in the plan below.

## Ordering
14. Phase 4 edits #241, #242 and wet#182 to name where the method lives before the merge. **Folded:** those edits point to the PR, and the final wording moves to Owed at the end.
15. The UFRA and COTR notes should cite the new log too. **Folded.**

## Scope
16. Morice and Nanika reading is #241's ask: say #241 consumes it. KISP is read but compared nowhere. **Folded:** the #241 body edit says the reading is done here; KISP stays in the population reading only (it has chinook populations apart on the Skeena and Bulkley codes).
