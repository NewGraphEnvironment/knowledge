# Code-check, branch round 1 (#65): `78a427d...HEAD` (4534f40)

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: index in full; the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks
  skipped). The stand-alone, Security and Spreadsheet sections were read from their index lines only (none names a
  tool or shape this diff uses).
- `code-check-r.md`: index in full; 7 sections read in full: "A database driver's value is not a base R type" (0325's
  new `obj_description()` read), "Read-back shape must match write-back shape", "`ifelse()` with an all-NA test",
  "A `function(...)` mock hides arguments", "`match()` treats NA as a matchable VALUE", "Rscript reads a script as it
  runs", "`identical()` on two reader results". About 108 headings not read past their index line.
- `code-check-spatial.md`: index in full; 1 section read in full ("FWA main flow is not edge type 1000 alone"). The rest
  index only.
- `code-check-shell.md`: index in full; 0 sections read (the diff has no shell).

## What was run

- In a temp copy (`rsync` of the checkout, big ignored data excluded), `NOT_CRAN=true`, `load_all()`:
  `test-grade_species.R` 22 expectations, `test-vignette-data.R` 43, `test-tune_curve.R` 23; 0 failed, 0 errors,
  0 skipped.
- Every number in the changed `research/` text and `NEWS.md` checked against `compare_before_after.txt`,
  `grades_summary_after.csv`, the 2026-10-17/18 and 2026-10-19 tuning logs' `grades:` lines, `data/compare/compare.csv`
  (all-group and catalog-group km, recomputed), `checks.csv` (BT spawning lift), `floodplain.csv`, and two `awk`
  passes over `data/tune/{CH_rear,BT_spawn}_grades.csv` (read only). All agree except the three findings below.
  Recomputed and holding, among others: BT spawning 71.9 % of graded km in 0.4–0.8; flow-republish km moves
  BT rear −49.1, BT spawn −231.0, CH +34.2, CO −9.3, ST +59.5 (all under 0.3 %); catalog-group km changes BT rear
  −37.5, BT spawn −19.2, CH −18.9, CO −14.2, RB −20.4, ST −45.0, WCT −24.1 %; BT rearing reference 0.1800 → 0.2255
  (+25 %); CO 0.5138 → 0.5121 (−0.3 %).
- Round 3's 48-place enumeration re-walked on the final tree: every row it marked consistent still is; its findings
  are fixed (the Grade bullet now says "exception flow", the species files and the CH file carry the regrade, NEWS
  names the reference change and both new arguments, 0322's header, the `ref_edge` roxygen, 0330's maps-only
  mtime refusal, data-raw's log path and `ref_population` refusal), except that the "most read 1" fix introduced
  the first finding below.

## Findings

- **[false-statement]** `NEWS.md:11-12`: "the thresholds and every rule's km do not move." The rule km did move: the
  committed `data/compare/compare.csv` against `78a427d` has tuned km BT rearing −49 km, BT spawning −231, CH +34,
  CO −9, ST +60 (the flow republish), and #65's own Decisions say "Rule km therefore move by a few hundred km per
  flow-ruled species"; the research files say the same. Only the thresholds and `default`'s km (and the width
  rules') are unchanged. The release note should say the km moved slightly because the comparison reads the flows
  wet republished (#73 retunes), not that they did not move.

- **[false-statement]** `research/habitat_thresholds_tuned.md` Limits, new bullet: "a river-polygon segment reads it at
  0 m ... so its grade rests on the surface past its data, and about half of their km reads 0.8 or more (CH)."
  Measured on the committed-run `data/tune/CH_rear_grades.csv` (accessible, graded): river-polygon edges
  (1250/1350/1450) 42,181 km, **76.7 %** in the 0.8–1 class and 69.3 % at exactly 1; river and lake edges together
  (findings' grouping, 60,628 km) **61.0 %** by km. About half (50.4 %) holds only for river and lake edges **by segment
  count**, which is apparently what `findings.md`'s "river/lake km ≥ 0.8 … 49.0 %" column measured despite its
  header. So the sentence understates the extrapolation it warns about, and round 3's original wording ("most such
  segments read 1") was in fact true by km for river polygons. Reword to the measured share (about three quarters of
  river-polygon km reads 0.8 or more, most of it exactly 1) and correct the findings column header.

- **[false-statement]** `research/habitat_thresholds_tuned.md`, the "Revised 2026-10-19 (#65)" paragraph after the Grades
  table: "The references move by under 1 % (CO, GR) to 25 % (BT rearing, up)." GR's reference moved 0.0344 → 0.0338
  (`20261017_tune_run*.txt` / `20261019_tune_run.txt` `GR_rear grades:` lines), −1.7 % (−1.45 to −2.0 % allowing for
  the logs' 4-decimal rounding); only CO (−0.3 %) is under 1 %. Both research tables print GR as 0.034, which hides it.

- **[fragile]** `scripts/0325-publish.R:52-60`: `discharge_load` is read from the database when 0325 runs, and the
  manifest presents it as "the segment flows the grade read". The grade tables were made earlier by 0320 and record
  no load, so if wet reloads `discharge.fwa_v1_segment_monthly` again between a 0320 regrade and 0325 (it did so once
  on 2026-10-19, mid-branch), the published manifest names a load the grades never read, and nothing can detect it.
  This is "Provenance, and repair" in `code-check.md` (a stamp read at write time describes the world as it
  finished, not as it ran). Today it is correct: every run on the branch started after the 16:40 UTC reload. A fix
  is 0320 writing the comment into the grade table (or its log line) at grade time and 0325 refusing when it differs
  from the live one; it fits #72's scope, which today covers `ref_edge` and `q` only.

## Notes (not findings)

- `research/chinook_rearing_tuned.md:97` (#67 bullet) sets the 0322 candidates "beside `CH_rear_v1`'s 88,607 km",
  while the same file's head now gives the regenerated rule as 88,641. The 88,607 is true of the named
  `data/compare/grad_ext/CH_rear_beside_v1.csv` (2026-10-18, old flows, not rerun on this branch), so it is not false,
  but a reader meets two km for one rule; a "(on the 17 October flows)" qualifier would remove the doubt. Nothing
  that publishes reads `grad_ext/`, and 0322's `done_rule()` will regrade all five candidates on its next run.
- `tests/testthat/test-grade_species.R:19,1209` label edge 2000 "wetland line" and call it off-branch; the repo's own
  records (#57 and #62 archives) give 2000 as canal, and it is inside `ref_edge`, so segment e is in the reference.
  The assertions still pass and still test what the code does; only the river polygon (d) actually exercises an
  off-branch segment being graded. `R/grade_species.R`'s "wetland lines" (1050/1150) is correct.
- `knw_grade_species()`'s signature drops `edge_stream` from position 7, so a positional call written for 0.4.5 would
  now pass the edge vector as `workers`. No caller in the repo does; the NEWS entry names the replacement.
