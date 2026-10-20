## Outcome

The grade now reads every accessible segment at its own walked distance to a river (#65). #57's
`knw_grade_species()` walked only the segments the rule's exception could admit, so on the joint size × distance
curve every other segment read the 50 km cap, and six of the eight keys walked nothing. The walk now covers every
accessible segment with a gradient, any edge type and any size, to the pick's exception river (10 m³/s where it
has none), with `dist_status`. Missing sizes stay in the walk because the comparison's exception reads their
distance: the plan review and the first code review found that independently. The first CH regrade showed
river-polygon segments, about 0 m from their river, setting the 95th-percentile reference (0.146 → 0.516), so Al
chose the stream branch as the reference population (`knw_grade(ref_rows =)`, `knw_grade_species(ref_edge =)`).
That matters for CH, CO, ST and WCT, whose references would rise 1.4–4×; for BT, GR and RB the two references are
within 7 %. Mid-run, the segment flows turned out to have been republished by wet the same day
(NewGraphEnvironment/wet#103), after #57 tuned; Al chose to proceed on them, so the rule-unchanged check became a
check that every moved verdict is explained (it passed), and retuning on the new flows is #73. Grade provenance
recorded from the call that made the grade is #72. All eight keys were regraded and recompared;
`habitat_grade/v1` (still not uploaded) is regraded before its first publication; the thresholds do not move.
After the PR opened, Al chose to flag the grade off the stream branch in `habitat_grade/v1` (`stream_branch`, 2026-10-20)
rather than blank it, and to leave the walk ending at the river's centreline until the retune (#73).
Lesson, from three review loops: prose restated from an intermediate summary, rather than recomputed at the grain
the sentence names, is where the errors were; the branch review found seven false statements (3, 2 and 2 by
round), two of them a chinook measurement written into an every-species sentence.

## Measurement

Reference rate and grade-weighted km, #57 → #65 (`grades_summary_{before,after}.csv`, findings.md):

| key | reference | grade-weighted km | km at 0.8–1 |
|---|---|---|---|
| BT rear | 0.180 → 0.226 | 175,327 → 151,418 | 9 → 10 % |
| BT spawn | 0.239 → 0.210 | 375,213 → 392,475 | 21 → 23 % |
| CH rear | 0.146 → 0.139 | 36,149 → 63,059 | 7 → 21 % |
| CO rear | 0.514 → 0.512 | 66,893 → 70,905 | 14 → 22 % |
| GR rear | 0.0344 → 0.0338 | 83,850 → 72,867 | 24 → 25 % |
| RB rear | 0.411 → 0.445 | 134,596 → 121,816 | 21 → 15 % |
| ST rear | 0.236 → 0.201 | 44,545 → 32,290 | 14 → 14 % |
| WCT rear | 0.429 → 0.473 | 16,871 → 18,671 | 47 → 52 % |

The reference over every accessible segment instead, as the first CH regrade took it: CH 0.516, CO 0.872,
ST 0.798, WCT 0.681 (river polygons 66–89 % of the top 5 %); BT, GR, RB within 7 % of the stream-branch value.
Walks ran at 52–77 k segments/min on 8 workers (CH 856,244 in 11.1–16.1 min; BT 2.68 M in 44.6–51.7 min); the
full regrade took 197.7 min and the comparison 262.6 min.

Rule km: `default` unchanged for every key; tuned km moved only for the five MAD-ruled keys and only through the
flow republish (BT rear −49, BT spawn −231, CH +34, CO −9, ST +60 km), every moved stream-branch verdict
explained by a floor or exception-distance crossing or a connectivity cascade (`rule_changes_explained.csv`).
The thresholds are unchanged. Graded km and ha (`compare_before_after.txt`): CH graded km 49,434 → 54,443 under
`default` → tuned (#57: 27,681 → 32,018), still the only species where the tuned rule raises it.

Wrong turns kept: the parked plan's "size > 0" walk set (would have dropped 638 CH and 2,700 BT spawning segments
from the tuned rules); the all-accessible reference (CH stream km at 0.8+ fell to 0.4 %); a rule-unchanged check
that the flow republish made impossible; and the seven false statements the branch review found.

Off the stream branch (`check_off_branch.txt`): 24–36 % of each key's graded km, 21–79 % of its km at 0.8 or more
(CH 79 %, ST 70 %, CO 66 %; below its km share for BT spawning, GR and RB). Edge-1200 lines (main flow through lakes
and wetlands) are 20 % at 0.8+ for CH. Connectors (`check_connector_share.txt`): of visit sites whose walk found a
river, 59–94 % end on a double-line river; of the traced ones, 89–96 % cross it on a connector, which adds a median
14–88 m (90th percentile 38–324 m), and the rest hop an uncounted gap; to the bank, 22 of 2,260 traced CH sites would
cross the 1 km exception.

Research revised: `research/habitat_thresholds_tuned.md` (method, Grades, rule-change and floodplain tables,
Limits), `research/chinook_rearing_tuned.md` and the six other species files.

## Evidence

- `scripts/logs/habitat/20261019_tune_run*` (the superseded CH regrade `-ch.txt`, the full regrade `.txt`/`.out`)
- `scripts/logs/habitat/20261019_compare*`
- this directory's `review-*.md` (thirteen reviewer rounds; `review-flag-round{1,2,3}.md` are on the `stream_branch` flag), `check_rule_changes_explained.R`, `compare_before_after.R`, `check_off_branch.R`, `check_connector_share.R`

Closed by: PR (this branch, `65-the-grade-reads-segments-that-pass-the-s`)
