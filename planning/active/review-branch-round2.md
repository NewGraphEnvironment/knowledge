# Code-check, branch round 2 (#65): `78a427d...HEAD` (3bae189)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: index in full; the prose of all 14 H3s under `## Mechanisms` in full (table rows and evidence
  blocks skipped). Stand-alone, Security and Spreadsheet sections from their index lines only (none names a tool or
  shape this diff uses).
- `code-check-r.md`: index in full; 4 sections read in full: "`ifelse()` with an all-NA test", "A `function(...)`
  mock hides arguments", "`match()` treats NA as a matchable VALUE", "Inside a dplyr verb, a column named like a
  local variable wins". About 115 headings not read past their index line (round 1 read the DBI-type, read-back
  shape, Rscript-in-flight and `identical()`-on-readers sections for the same diff).
- `code-check-shell.md`: index only; 0 sections (the diff has no shell).
- `code-check-spatial.md`: index only; 0 sections ("FWA main flow is not edge type 1000 alone" read in round 1; the
  edge-type claims below were measured instead).

## What was run (read only; no database; 0325 left alone)

- Round 1's fix diff (`branch2_since_round1.patch`) re-checked line by line; then every number and quantified claim
  the branch adds or changes in `NEWS.md`, `research/*.md`, `vignettes/chinook_rearing.Rmd` and the roxygen of
  `R/grade.R` / `R/grade_species.R`, against `compare_before_after.txt`, `grades_summary_{before,after}.csv`, the
  `grades:` lines of `20261017_tune_run*.txt` and `20261019_tune_run{,-ch}.txt`, `rule_changes_explained.csv`,
  `findings.md`'s measurements, `R/tune_curve.R` / `R/tune_run.R` / `R/link_walks.R`, and `awk` passes over
  `data/tune/{CH,GR,RB,BT_spawn,WCT}_*_grades.csv` (edge-type distance and grade shares, class shares, the stream
  share under the superseded reference, which edge types sat above the all-accessible reference).

## Findings

- **[false-statement]** `R/grade_species.R:19` (and `man/knw_grade_species.Rd:69`): "a river-polygon **or wetland**
  segment reads it near 0 m and at sizes few visits had". Measured on `data/tune/CH_rear_grades.csv` (accessible):
  wetland lines are far from a 3 m³/s river, not near it: edge 1050 has 2.7 % of its 14,750 km within 1 m and 3.5 %
  within 100 m (1150: 1.7 % / 7.5 %), and only 4.0 % of 1050's graded km grades 0.8–1, against 6.4 % on edge 1000.
  River-polygon edges (1250/1350/1450) hold 78.6 % of their km within 1 m (1250 91 %, 1450 70 %, 1350 5 %). The
  sentence generalises the river-polygon case to wetlands; wetland segments are an extrapolation because the curve's
  visits excluded wetlands, not because they sit at 0 m. Fix: "a river-polygon segment mostly reads it near 0 m,
  and a wetland segment lies outside the visits it was fitted on".

- **[false-statement, minor]** `NEWS.md:10`: "in place of its **unused** `edge_stream`". In 0.4.5 (`78a427d`)
  `edge_stream` was used: it restricted the walk candidates (`cand <- seg$accessible & seg$edge_type %in%
  edge_stream & ...`). It was never passed by a caller, but a reader of the release note is told the argument did
  nothing. "in place of `edge_stream`, which restricted the old walk to the stream branch" is true.

## Mechanism

Round 1's three false numbers, and the one above, share one mechanism: **prose restated from an intermediate
summary instead of recomputed at the grain the sentence names.** "about half of their km" came from a findings
column computed by segment count over a wider group (all off-branch edges) than the sentence named (river polygons,
by km); "under 1 % (CO, GR)" came from a table that rounds GR's reference to 0.034 on both sides; "every rule's km
do not move" came from the pre-flow-republish expectation (the scratch check written before wet#103), not from
the comparison that ran after it. This round's wetland sentence is the same shape one axis over: a property measured
on one member of a set (river polygons, the CH case that set the 0.52 reference: 89 % of the segments above it
were 1250/1450 at 0 m) written as a property of the whole set the code names (`river polygons and wetlands`).
The defence is the one used below: compute each claim from the artifact, over exactly the population and unit
(km vs segments, member vs group) the sentence states.

## Enumeration (every number or quantified claim the branch adds or changes)

Verdict ✓ = recomputed and holds. Sources: CBA = `compare_before_after.txt`; GSA/GSB = `grades_summary_after/before.csv`;
LOG19/LOG17 = the 2026-10-19 / 2026-10-17 tune logs' `grades:` lines; CSV = an `awk` pass over the grade table.

### NEWS.md
1. "every key was affected, and six of the eight walked nothing at all": LOG17 `walked=0` for BT rear, CO, GR, RB,
   ST, WCT; BT spawn 682,254 and CH 373,133 walked, the rest capped ✓
2. walks "every accessible segment with a gradient to the pick's exception river (10 m³/s where it has none)":
   code, `q_default = 10` (`R/tune_curve.R:48,55`); LOG19 walked = accessible for all 8 ✓
3. "river-polygon and lake segments, about 0 m from their river, would otherwise set it": of the 42,616 segments at
   or above 0.5156 (the 95th percentile over every accessible CH segment), 1250/1450 are 88.6 %, 1200 5.2 %, and
   99 % are within 1 m (CSV) ✓ as a description of the segments that set it (lake segments in general are not at
   0 m: 18 % of edge-1200 km within 1 m)
4. "chinook's 0.52 over every accessible segment against 0.14": `20261019_tune_run-ch.txt` 0.5156; LOG19 0.1388 ✓
5. "in place of its unused `edge_stream`": ✗ (finding 2)
6. "`habitat_grade/v1`, never uploaded": findings (bucket holds only `fdis/`) ✓ (not re-probed: no S3 access used)
7. "The thresholds, `default`'s km and the width rules' km do not move": `git diff 78a427d -- data/thresholds*.csv`
   empty; CBA default km identical for all 8; RB, WCT, GR tuned km identical ✓
8. "the flow-ruled tuned rules move by under 0.3 %": BT spawn −231/99,786 = 0.23 %, ST +60/45,214 = 0.13 %, BT rear
   0.03 %, CH 0.04 %, CO 0.01 % ✓

### R/grade.R, R/grade_species.R roxygen (and man/)
9. "a segment reads the cap only for that reason" (`knw_grade`): grade_species walks every accessible segment with a
   gradient; `knw_link_walks()` returns exactly one row per start, so `no_walk` is only outside the walk set ✓
10. "For the pick the curve was fitted on, the two rivers are the same": `R/tune_curve.R:55` ✓
11. "fitted on stream-branch visits outside lakes, wetlands and river polygons": `R/tune_run.R:68` (edge_stream,
    `!wb_river`, `!wb_wetland`) ✓
12. "a river-polygon or wetland segment reads it near 0 m": ✗ for wetlands (finding 1)
13. "over every accessible segment, river polygons at 0 m set it, and chinook's rose from 0.14 to 0.52": item 3, 4 ✓
14. `ref_edge` default "is `knw_tune_run()`'s default `edge_stream`": both `c(1000L, 1100L, 2000L, 2300L)` ✓
15. counts description matches the returned vector ✓

### research/habitat_thresholds_tuned.md
16. Grade bullet: walked "to the first river of the pick's exception flow (10 m³/s where the pick has no exception)",
    "a walk that reaches the sea first, or stops, reads the 50 km cap, as the curve's visits did": code,
    `R/tune_curve.R:64` ✓
17. Intro and floodplain paragraph, "#57 ... read most segments at the distance cap": 6 of 8 keys all, CH 483 k of
    856 k, BT spawn 2.0 M of 2.68 M ✓
18. Grades table, every changed cell (graded km, grade-weighted km, reference, km < 0.2, km 0.8–1, 8 rows): GSA and
    LOG19 ✓ (BT 571,305; 151,418; 392,475; 0.226/0.210; 63/10 %; 0.2/23 %; CH 63,059, 0.139, 67/21 %; CO 70,905,
    0.512, 22/22 %; GR 72,867, 0.034, 25/25 %; RB 121,816, 0.445, 27/15 %; ST 32,290, 0.201, 76/14 %; WCT 18,671,
    0.473, 6/52 %)
19. "BT: 33,992 segments with no flow" LOG19 ✓; "BT gains 4 segments with no flow" 33,988 → 33,992 ✓
20. "about ±5 % on most segments": findings, new/old 0.94–1.04 between the 5th and 95th percentiles ✓
21. "references move by under 1 % (CO) and 2 % (GR) to 25 % (BT rearing, up)": CO −0.3 %, GR −1.7 %, CH −4.7 %,
    RB +8.3 %, WCT +10.1 %, BT spawn −12.1 %, ST −14.7 %, BT rear +25.3 % ✓
22. "CH's grade-weighted km nearly doubles (36,149 → 63,059)": 1.74×. Imprecise rather than false; noted, not a
    finding. "its km at 0.8–1 triples": 16,198 → 47,864 km, 2.95× ✓
23. Change table, all changed cells, and items 1–4 (93,376 of 94,199; 26,284 of 26,677; 24,532 of 24,832; 5,047;
    21,807 / 15,617; 9,665 / 6,948; 5,077 / 4,653; 88,641 / 54,443 / 49,434; "5 % ... to 37 %" with ST −36.8 %;
    "under 1,000 km" max 823; FDIS shares; lifts 5.21, 3.26, 4.08): CBA ✓
24. Floodplain table, all changed cells, and the −24/−22/−20/−11/−31 % changes: CBA ✓; "(20 against 19)" CH −18.9 %,
    "(22 against 19)" BT spawn −19.2 % (round 1's catalog-group recompute) ✓
25. "Graded ha follows graded km, rising only for CH": CBA graded ha default → tuned falls or is flat for all others ✓
26. "every moved verdict is a segment whose flow crossed the floor or whose exception distance crossed its limit, or
    a connectivity cascade from one": `rule_changes_explained.csv` has only `size`, `distance`, `cascade` causes, no
    `other` on or off the branch ✓; "Width rules did not move" ✓
27. Limits: "for CH, 77 % of river-polygon km grades 0.8 or more and 69 % reads 1": CSV 76.7 % / 69.3 % ✓;
    "a river-polygon segment reads it at 0 m": 78.6 % of river-polygon km within 1 m (1350: 5 %); holds as the
    typical case ✓; "over every accessible segment, CH's rose from 0.14 to 0.52 and left 0.4 % of stream km at 0.8 or
    more": CSV, stream km above 0.8 × 0.5156 = 0.44 % ✓
28. Header log paths (`20261019_tune_run.{txt,out}`, `-ch.txt`, `20261019_compare.txt`): exist and tracked ✓

### Species files
29. bull_trout: grade paragraph (33,992; 0.226; 571,305; 151,418; 63 %; 10 %) ✓; spawning reference 0.210, "72 % in
    0.4–0.8" (CSV 72.0 %), "0.2 % under 0.2" ✓; comparison (156,091, −37.3 %, 94,199, 93,376, 1,363, 1,094,
    105,605 → 77,856, 21/8 %, 5.21, 99,555, −25.4 %, 56,411, 22,585, 21,807, 15,617, 88,070 → 62,266, 3.70,
    565,706, 260,172 → 216,596, 275,002, 253,726 → 199,664, −49, −231) ✓
30. chinook: 0.139, 67 %, 21 %, "≥ 3 m³/s river" (exc_q 3) ✓; 88,641, 24,832, 24,532, 12,289, 9,665, 6,948, 1,411,
    49,434 → 54,443 "the only species where it does", 17 %/1.5 %, 3.26, 340,929, −18.9 %, 206,011 → 207,639, +34 ✓;
    #67 bullet "88,607 ... (88,641 after it)" ✓
31. coho: 0.512 "the highest of any species" (next WCT 0.473), 22 %/22 %, 70,905; −9 km; 77,603, 9,215, 5,047,
    3,643, 5,189, 4,653, 49,790 → 49,570, 32/11 %, 1.82, 242,163, 168,866 → 158,795 ✓
32. grayling: 72,867; 25 %/25 %; "spread evenly" (CSV 25/18/17/15/25 %) ✓; 44,602 (46,831 before) ✓
33. rainbow: 121,816; 0.445; 27 %/15 %; "spread evenly" (27/24/18/16/15 %) ✓; 103,160 → 90,429; 273,535 → 243,741 ✓
34. steelhead: 0.201; 32,290; 76 %; +60; 45,274; −36.8 %; 26,677; 26,284; 332; 22,498 → 20,730; 4.08 "the largest
    rise after BT rearing" (+1.88 against BT rear +2.76, next CH +0.80); 74,948; 35,822 → 34,802 ✓
35. westslope cutthroat: 0.473; 18,671; 52 % ✓; 14,939 → 11,277; 89,778 → 85,858 ✓

### vignettes/chinook_rearing.Rmd, data-raw, scripts headers
36. Caption "the recommended rule reads it only where the flow falls short" (`R/compare_rules.R` exception arm) ✓;
    the distance column's "no river found" for any missing distance: `bulk_segments.rds` holds accessible segments
    only, all walked, so missing means `none`/other ✓
37. data-raw comment "measured on every accessible segment with a gradient" (the `knw_dist` of 0330's segments, from
    the grade table) ✓; its `"^CH_rear grades:"` grep matches exactly one line of `20261019_tune_run.txt` (0320's
    "regraded" lines now read `<key>: grades on file`) ✓
38. 0320, 0322, 0325 headers and the 0325 published description ("10 m3/s where the rule has none", edge types
    1000, 1100, 2000, 2300) ✓; 0325's `discharge_load_at_publish` has no other consumer in the tree ✓

## Notes (not findings: pre-existing, outside the branch's changes)

- The Grades table's and the species files' "accessible km" (BT 577,130, CH 225,326, CO 147,962, GR 258,724, RB
  510,150, ST 155,481, WCT 35,320) are km with `access > 0`, not km with `accessible = TRUE` (WCT: 35,320.3 against
  35,285.3, measured), while the comparison table's "accessible km" (576,908 ...) is `accessible`. The branch kept that
  column unchanged; the two tables name different populations with one column title.
- `westslope_cutthroat_rearing_tuned.md:24` "most accessible stream reads as near the top" rests on 52 % of graded km;
  of the 35,320 accessible km about 38 % grades 0.8–1, since a quarter is ungraded. The sentence predates the branch
  (it then rested on 47 %).
- The same file's "(−4 %, against −22 % in km)" compares catalog-group floodplain with all-group km (catalog-group km
  −24.1 %), the comparison #62 corrected in the main file; unchanged by this branch.
