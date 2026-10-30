# Plan review — #121 (Plan agent, spawned 2026-10-30T17:22:51Z, returned in reply; written here by the session)

Verdicts after checking each claim against the code and the first run (2026-10-30):

| Finding | Verdict | Action |
|---|---|---|
| Blocker: a negative gradient fails every rule (`R/rule_in.R:71`, `g >= 0`), so setting it to 0 can move a visit in, not "none" | Confirmed; the plan's expectation was wrong | The script tests every rule at those visits as they are and at 0. On the published build none of the 55 sits on the stream branch, so no key population holds one: 0 rules moved for every key |
| Curve and grade clamp the gradient to [0, 0.2] (`R/tune_curve.R:81`, `R/grade.R:59`) | Confirmed | Phase 3 answered from the code; the rule/curve mismatch is reported |
| Pick dependence needs a rescore | Moot on this build: no negative is in any key's population, so no score can change | Stated in the research file; the check reruns the count on any build |
| Band at 0.30 one-sided | Already symmetric in the script ((0.25, 0.35]); stated in the log | Also report a band picked by the measured value |
| Ties at the limit (readings to the nearest 0.5 %) | Accepted | Report the share of measured values exactly on each limit; the flip test uses the rule's `<=` |
| md5 guard details | The script takes the unique non-blank value, refuses unless it is one and equals all three md5s; only an explicit false disables it | Log says "NOT the published build" when it is not |
| Published build machine-local (v3 unpublished) | Accepted | Log names `knowledge/fdis/v3` via the tracked thresholds' `evidence_version`; EVIDENCE_DIR through `home_rel()` |
| `fwa_gradient` vs `fwa_gradient_pct` | The script reads `fwa_gradient` (fraction) | None |
| Zero slot halves some means (644 rows) | Accepted as a limit; not identifiable from visits_link | Named in the write-up |
| Measured value may be MAP or GIS | Accepted | Named in the write-up |
| All-visit population includes rivers, wetlands, lakes | Accepted | Block by waterbody class |
| Catch confounded with gradient | Accepted | Catch compared within measured-gradient and segment-length classes |
| Ordering: Phase 3 before Phase 2 | Phase 3's answer came from the code in parallel; no rework | None |
| Acceptance: stream branch exactly 29,335 | Confirmed equal to `20261027_segment_gradient_check.txt` | Verification line tightened |
| vignette_method.R must compute the article number the same way | Accepted | Into the owed #119 task |
