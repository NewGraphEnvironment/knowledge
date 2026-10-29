# Code-check round 3, branch `112-compare-only-default-and-the-reported-st` (diff against e064b61, planning/ excluded)

## Checklist read

- code-check-python.md (7,237 bytes): in full.
- code-check-r.md (179 KB): read the full sections "Postgres row order is never fixed unless the query fixes it",
  "`[[` on a named ATOMIC vector with an absent key is an error", "Rscript reads a script as it runs",
  "A `data-raw/` script must load the source tree", "A `function(...)` mock hides arguments", and
  "Under `R CMD check`, tests run from a temp dir against the INSTALLED package" (6 headings); the other ~100 headings
  were not read, because their index lines name tools or shapes this diff does not use.
- code-check-shell.md (125 KB): 0 headings read in full. The diff has no shell code; its `system2("git", ...)` lines
  are copied from a sibling script, which the brief accepts.
- code-check-spatial.md (156 KB): 0 headings read in full. The diff adds no spatial code.
- code-check.md (331 KB): read the prose of all 14 H3s under `## Mechanisms`, without the table rows or the evidence
  blocks; none of the standalone rules.

## The mechanism

Round 2's four gaps came from one shared assumption: **a statement of what `0330` runs, or what it costs, is true of
whatever `0330` does today, and a derived number holds without saying what it was derived from.** #112 changed the
default from every structure to `default` plus TUNED_AS. Each sentence that restates either what `0330` compares or
how long it takes was written when the two were the same. A sentence that reads in the present tense ("now takes",
"under each rule structure") flips from true to false with no edit to it, and a grep for structure names never finds
it, because it names minutes or uses a generic phrase. The second half of the mechanism is a borrowed share stated as
if it had been measured. I swept both halves across the tracked files outside planning/ and scripts/logs/ (greps for
"each rule structure", "every structure", "free | door", "door_wetland", "three structures", "each structure",
"STRUCTURES=", "2.9 h", "162.9", "4 to 37", "recompare"), and below are the places they still reach.

## Findings

- **[prose]** research/database_builds.md:13-15 ("The answer"): says "A retune ... now takes ... 4 to 37 min to
  recompare it ... and a recompare of every key 2.9 h with its GeoPackages". These are #87's every-structure minutes
  (`20261026_compare.txt`: WCT 4.5 to CH 37.1, 162.9 min in all). This branch moves `0330`'s default to
  `default` + `door`, and the file's own new section estimates that drops about 28 % of classify, overlay and connect.
  The present-tense "now takes" therefore no longer describes the default run. The **Verified** line was moved to
  2026-10-28 "for the structures a comparison runs", so the header now vouches for this paragraph too. CLAUDE.md
  fixed the same restatement ("Those minutes are every structure's"), and this one needs the same qualifier.

- **[prose]** scripts/README.md:94 (the `0330` row this branch edited): "every key 162.9 min with GPKG=FALSE, BT
  rearing alone 33.4". The row now says `0330` runs TUNED_AS by default, so these figures, which are every-structure
  minutes, read as the default run's. This is the same restatement CLAUDE.md:424 was fixed for. (Pre-existing: the
  row dates them "2026-10-27", but 162.9 and 33.4 come from `20261026_compare.txt`; `20261027_compare.txt` is #92's
  remote run, 466.1 min.)

- **[prose]** research/database_builds.md:115-118: "That last share is an assumption about two keys not measured."
  The sentence implies the other estimates were measured, but RB rearing's share is borrowed too: "BT rearing's 29 %
  for RB". No log times RB, so at least three keys rest on a borrowed share (RB, CO, ST), not two. CH and BT were also
  measured on their 20 largest groups and applied to all 125 and 158. The 46-of-164 figure checks out
  (9.9 + 10.8 + 4.8 + 1.5 + 10.6 + 8.7 = 46.4 of 164.3, 28 %). Only the label over its inputs is off.

- **[prose]** CLAUDE.md:425: "which took 24 to 29 % less on three keys". The figure is the wall-time difference:
  WCT 4.5→3.2 (29 %), CH 16.6→12.6 (24 %), BT 9.9→7.0 (29 %) in `-4`, `-3` and `-2`. The check's own header
  (data-raw/compare_structures_check.R:21-23) and research/database_builds.md:108-110 both say the `door`-alone run
  went second on a warm cache, so this difference "overstates it", and that the worker-minute shares (29 to 33 %) are
  the measure to trust. CLAUDE.md quotes the warm-cache figure without that condition: a compression that dropped the
  qualifier its source states.

- **[prose, low]** scripts/0330-compare.R:5, the header's first paragraph: "... change by reason), under each rule
  structure (#73)". By default a run is now under TUNED_AS alone; lines 23-25 of the same header say so, so the
  opening line contradicts the design note below it. Lines 53 and 299 ("every segment's verdict under each rule and
  structure") are ambiguous in the same way, but they hold if read as "each structure the run compared".

- **[prose, low]** data-raw/vignette_chinook.R:120: "the comparison under every structure is kept (#73)". Under
  the new default, the compare table holds `door` alone. The branch updated the comment at :289-290 in the same file
  for exactly this ("the tuned one alone unless 0330 ran with STRUCTURES=all") but left this one.

## Checked and holding

- Every number in research/database_builds.md's new section against the logs: the table rows (WCT `-4` 4.5/3.2,
  6.1 of 18.4 = 33 %; CH `-3` 16.6/12.6, 17.6 of 56.6 = 31 %; BT `-2` 9.9/7.0, 13.2 of 44.9 = 29 %); "5 to 19" worker
  minutes per rule (5.3 to 19.2); copies and indexes "0.7 to 1.4"; CH walks "about 20" (19.5, 20.0); contended
  WCT 35 % against 33 %, and CH 31 % in both runs; 47 % = 17.6 of (56.6 − 19.5 = 37.1); #92's classify minutes sum
  to 164.3; the largest difference, 9.9e-14 (CH `-3`), with segments' flags identical on every key; WCT matched the
  tracked tables to 1.7e-14 on fresh 0.44.0 against #92's 0.43.0. CO and ST walk no river in #92's log (0.0 min), and
  each ran 4 rules. BT spawning and GR ran 2 rules, i.e. `door` only.
- The habitat_thresholds_tuned.md and CLAUDE.md notes on the `free`/`door_wetland` figures; data-raw/README.md's four
  checks, which the qualifier "each proves that a faster or different path returns what the reference path returns"
  bounds (segment_gradient_check.R, snap_candidate_check.R and snap_limit_sensitivity.R are measurements, outside that
  set); scripts/README.md:89-90; man/knw_compare_rules.Rd against the roxygen.
- Code: `.knw_compare_structures()` refuses a structure outside the pick before `knw_compare_rules()`'s own
  `tuned_as` check, and the tests cover reported, door_wetland and the refusals. `assert_default` loses nothing,
  because `is_default_rule` requires no exception, and then `door_wetland` is never in the pick. `rule_s` and
  `setup_s` are carried on the error path. `Reduce` over the per-bin named vectors keeps the names. `0330`'s
  `STRUCTURES` validation lets `""` through as reported. `vignette_chinook.R`'s wetland rows and test-vignette-data's
  `sum(as_tuned) == 1` hold with one structure. knw_thresholds_table() reads only `tuned_structure`. Composition in
  `0330` can mix a reported-only key with an every-structure key in one compare.csv, but no reader depends on every
  key having the same structure set.
- Issue numbers #101, #112 and #115 resolve to this work.

## Disposition (main session)

All six fixed. Finding 3 sat inside round 2's fix, so the loop ended by enumeration, not a further round:
- every tracked restatement of what 0330 compares or how long it takes (grep for `each rule structure`, `every
  structure`, `under each structure`, `free | door`, `three structures`, `every through-wetland structure`, `162.9`,
  `2.9 h`, `4 to 37`, `33.4 min`, `per structure`, outside planning/archive and scripts/logs): 14 prose hits, each
  now true (NEWS.md:40 a past release; research/chinook_rearing_tuned.md:177 and database_builds.md's #87 table
  records of their runs; settings.csv:68 is #115);
- every number in the new prose (database_builds.md, CLAUDE.md, scripts/README.md) against its log: 17 values, all
  matching.
