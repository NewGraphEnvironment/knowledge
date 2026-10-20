# Code-check, branch round 3 (#65): round 2's fixes (5603712) and the final tree

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: index in full. Read in full: the prose of all 14 H3s under `## Mechanisms` (table rows and
  evidence blocks skipped), plus "Documentation Staleness" and "An assertion that matches an interpolated value
  cannot see the claim around it". Not read past the index line: 21 H3s (the other stand-alone rules, Security,
  Spreadsheets and PDFs; none names a tool or shape this diff uses).
- `code-check-r.md`: index in full. 1 section read in full ("Inserting a helper between a roxygen block and its
  function rebinds `@export`", since the diff edits roxygen). 110 not read past the index line.
- `code-check-shell.md`: index only. 0 of 67 sections (the diff has no shell).
- `code-check-spatial.md`: index only. 0 of 92 sections. The FWA edge-type claims were measured from the data instead.

## What was run (read only, no database, no repo file edited except this one)

- `branch3_since_round2.patch` read line by line. The changed prose was checked against
  `git show 78a427d:R/grade_species.R`, the callers at `78a427d` (`git grep knw_grade_species( 78a427d`),
  `R/tune_run.R:68-70` (the visit filter), `R/grade.R:67-73` (the reference), `R/grade_species.R:57-84`,
  `planning/archive/2026-10-issue-65-grade-walks-every-segment/grades_summary_{before,after}.csv`, and passes over all eight `data/tune/*_grades.csv` (awk, and
  `data.table` from the scratchpad). The pass recomputed each key's reference over the stream branch and over every
  accessible segment, with `quantile(rate, 0.95)` on `accessible & !is.na(rate)` as `knw_grade()` takes it. It
  reproduces CH 0.1388 / 0.5156 and CO 0.5121, so the recomputation is faithful. The pass also measured which edge
  types sit at or above the all-accessible reference, and the river-polygon km and segments (edges 1250/1350/1450)
  within 1 m. The `*_curve.rds` visit data gave the size quantiles.

## Findings

- **[false-statement]** `R/grade_species.R:20` (and `man/knw_grade_species.Rd:70`): "a river-polygon segment
  **mostly** reads the curve near 0 m". The sentence documents `knw_grade_species()` for every key, but its number
  was measured on CH alone. Accessible river-polygon km within 1 m of the walk river: CH 78.1 %, BT spawn 74.7 %,
  CO 61.6 %, WCT 61.4 %, ST 57.1 %, RB 56.6 %, BT rear 56.3 %, **GR 48.2 %** (16,715 of 34,644 km; within 100 m
  49.7 %; 11,623 km lie 10 km or more away). Counted by segment instead of km, BT rear (45.1 %) and GR (45.5 %) are
  also under half, and WCT is at 50.3 %. So "mostly" is false for grayling by either unit, and false for BT rearing by
  segment. The other half of the clause, "at sizes few visits had", holds as a tendency: 41–77 % of river-polygon
  segments (45–85 % of their km) are above the visits' 95th-percentile size, against 1–8 % of stream-branch segments.
  A true form: "a river-polygon segment often reads the curve near 0 m (half to four fifths of their km, by key) and
  at sizes few visits had".

- **[false-statement]** `NEWS.md:8-10` "river-polygon segments, mostly about 0 m from their river, would otherwise
  set it (chinook's 0.52 …)", and the unchanged roxygen beside the fix, `R/grade_species.R:23-24`, "over every
  accessible segment, river polygons at 0 m set it". Both are written as the general reason for `ref_edge`, but they
  hold for only four of the eight keys. These are the references over the stream branch → every accessible segment,
  and the river-polygon share of the segments at or above the second figure:

  | key | stream branch → every accessible | river-polygon share of the top 5 % | top within 1 m |
  |---|---|---|---|
  | CH | 0.139 → 0.516 | 88.9 % | 98.7 % |
  | CO | 0.512 → 0.872 | 89.1 % | 99.7 % |
  | ST | 0.201 → 0.798 | 73.4 % | 76.1 % |
  | WCT | 0.473 → 0.681 | 66.0 % | 100 % |
  | BT rear | 0.226 → 0.240 (+6.4 %) | 31.3 % | 4.8 % |
  | BT spawn | 0.210 → 0.209 | 19.0 % | 21.8 % |
  | GR | 0.0338 → 0.0345 | 31.8 % | 32.9 % |
  | RB | 0.445 → 0.454 | 33.6 % | 0.0 % |

  For BT, GR and RB the reference would barely move, and the segments that would set it are mostly not river
  polygons and mostly not near 0 m (for RB, none is within 1 m). A true form names the scope, for example: "for CH,
  CO, ST and WCT, river-polygon segments, mostly about 0 m from their river, would otherwise set it (chinook's 0.52
  …); for BT, GR and RB the two references are within 7 %". The roxygen sentence needs the same scope.

## Verified (holds on the final tree)

1. NEWS "its `edge_stream`, which limited the walk to the stream branch": at `78a427d`, `cand <- seg$accessible &
   seg$edge_type %in% edge_stream & …` (`R/grade_species.R:50`) ✓. "which no caller set": the `78a427d` callers
   (`scripts/0320:190`, `scripts/0322:273`, the `@examples`) pass no `edge_stream` ✓. "goes with the walk's old
   limits": the final signature (`R/grade_species.R:57`) has `ref_edge` and no `edge_stream`, and the walk set is
   `accessible & !is.na(gradient)` ✓.
2. Roxygen "a wetland or lake segment lies outside the visits it was fitted on": the visit filter
   (`R/tune_run.R:68-69`) keeps only `edge_stream` edge types with `wb_river`, `wb_wetland` and `wb_lake` all FALSE ✓.
   "fitted on stream-branch visits outside lakes, wetlands and river polygons" ✓.
3. Roxygen "at sizes few visits had": holds as a tendency (see finding 1) ✓.
4. NEWS "chinook's 0.52 over every accessible segment against 0.14": recomputed 0.5156 / 0.1388 ✓. "mostly about 0
   m" for the CH segments that set it: 98.7 % within 1 m ✓.
5. Research "CH's grade-weighted km grows by three quarters (36,149 → 63,059)": `grades_summary_{before,after}.csv`
   36,149.25 → 63,058.83, ×1.744 ✓. "its km at 0.8–1 triples": 16,198 → 47,864 km, ×2.95 ✓.
6. WCT "52 % of graded km is in the 0.8–1 class … most graded stream reads as near the top": 52.2 % of 25,932 graded
   km; stream branch alone 51.0 % of 17,237 km ✓.
7. `man/knw_grade_species.Rd` text is identical to the roxygen ✓. No roxygen block moved, and the NAMESPACE is
   untouched by 5603712 ✓.
8. Quantifiers the latest commit touched ("mostly" ×2, "most graded", "three quarters", "no caller", "triples"): each
   checked above. Only the two "mostly" or "set it" sentences fail, and both fail through scope, not their CH numbers.

## Mechanism

This is the same mechanism round 2 named, one axis over. Round 2 measured its prescribed wording on the CH grade
table and wrote it into a sentence that covers every key (the `knw_grade_species()` docs and a NEWS line about the
reference in general). Within CH the fixes are exact. Across keys, where the grain of the sentence is, they do not
hold. The defence: before writing a claim into a function's docs or a package-wide note, compute it per key.
