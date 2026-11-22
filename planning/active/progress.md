# Progress — Backlog move 14: Window flow follow-ups (#233)

## Session 2026-11-22 (UTC)

- Plan-mode exploration — phases approved by user (four gate decisions answered: a separate window walk, the
  published evidence augmented into a tagged directory, #226 only, the verdict rule set before scoring)
- Created branch `233-backlog-move-14-window-flow-follow-ups` off origin/main
- Scaffolded PWF baseline from issue #233 with approved phases
- Next: start Phase 1

## Phase 1, 2026-11-22

- Completed: Phase 2's four readings and the verdict rule written into `research/chinook_window_flow.md` before any
  scoring; #227's body (what is wet's, what is left, the split) and #233's body (the gate decisions); batch 21 of
  `planning/backlog.md`; wet 0.4.33 to 0.4.39 (`github::NewGraphEnvironment/wet@e4716b9`).
- Plan review spawned in the background at 04:58 UTC, findings to `planning/active/review-plan.md` when it reports.
- Next: Phase 2, the window flow at a segment.

## Phase 2, 2026-11-22

- Completed: `knw_link_flow_window()` (the window flow on the segment MAD came from, on its pick source, by
  `wet::wet_flow_window()`), `.knw_windows()` (labels by date) and `.knw_window_weights()` (month weights taken from
  wet); four tests in `test-link_flow.R`, 21 expectations passing on the database's host; wet declared in `Suggests`
  and `Remotes` (the package had no declared use of it); pkgdown index.
- Next: Phase 3, the window walk.

## Phase 3, 2026-11-22

- Plan review reported at 05:04 UTC: two blockers (the score cache does not know the reading; one grid of every
  reading's rules does not give the paired SE), five gaps and a scope cut, each probed and folded into Phases 3 to 5
  (`planning/active/review-plan.md`).
- Completed: `inst/sql/ch_dist_profile_window.sql` (generated from the annual walk: its text outside three marked
  regions); `knw_link_walks(window = )` with the query built by `.knw_walk_sql()`, the bare source to SQL and the
  window in the row's `src`; `knw_walk_md5(window = )`; six tests added to `test-link_walks.R` (all 13 in the file
  pass on the database's host, 126 expectations).
- Measured: the window walk given month 0 at weight 1 returns the annual walk's rows on 3 starts x 3 sources x 4
  sizes; with the annual-flow read put back into the window file the window test fails (2 expectations), and the
  file was restored to md5 `6f584e5f...`. The annual walk's md5 is unchanged (`c3f7bdbe...`, the grade records').
- Found: `knw_link_flow()`'s query on an unanalysed temporary table of two segments took 168 s on this database
  (3 s once analysed). `.knw_link_flow_window()` analyses its own; the existing function is left as it is, an issue
  to file.
- Next: Phase 4, the evidence with a window.

## Phase 4, 2026-11-22

- Completed: `data-raw/chinook_window_evidence.R` and its run on the database's host (round trip 0.9 ms in the
  committed log, no other active session): `data/fdis/derived_window/` (ignored) with `flow_0801_0930` on all 45,529 visits and 258,496
  window-walk rows on `pick@0815-0915` beside the 775,488 published; record
  `data/tune/flow_window/ch_rear_window_evidence_run.csv`; log
  `scripts/logs/flow_window/20261122_chinook_window_evidence.txt`.
- Measured: 4,532,843 picked segments in the load, none short of a window month or on two sources. Phase 1's median
  window share of MAD reproduced (0.590271; largest gap in a group's median 4.9e-15). The window walk: 500 starts in
  7.0 s uncached on 8 workers in the committed log, which is the fourth pass and read the full walk from
  `knw.walk_cache_window`. The cold walk of all 36,928 starts took 1.0 min on the second pass (after 7.3 s for its
  500), whose log the later passes overwrote: that figure is from this session, not from a committed file. Found 233,984 of 258,496 rows, against 240,312 for the annual walk. The exact walk puts
  a river within 1 km of 980 scored visits where Phase 1's ladder reading had 969: 11 more, none with chinook.
- Three passes stopped, each on a check: 4 visits hold a tied parent's flow from before #161 (none scored); readr
  does not round-trip 17 digits; md5 vectors named by path (`planning/active/findings.md`).
- 1 visit has a MAD and no window flow above zero; 66 have no MAD above zero.
- Filed #255 (`knw_link_flow()` takes minutes on a few segments).
- Next: Phase 5, the smoke gates, then the four readings.

## Phase 5, 2026-11-22

- Completed: `data-raw/chinook_window_tune.R`; smoke gates passed on all four readings (10 s,
  `scripts/logs/flow_window/20261122_chinook_window_tune-smoke.txt`); the four readings scored with every check and
  again without LFRA in 17 min on 12 workers (3.3 min a reading, 0.8 to 0.9 without the extras;
  `scripts/logs/flow_window/20261122_chinook_window_tune.txt`); outputs under `data/tune/flow_window/`.
- The verdict rule's commit (`267fcd06`) precedes the scoring's HEAD (`662eb1e7`), which the log names.
- Measured: the control gave back all 6,149 rules of run `20261103_0838` (held-out deviance to 1e-6, the pick, the
  recommended rule, the region, nested selection 1322.677, 4 of 4 seeds, bootstrap share 0.095). All four readings
  scored the same 4,858 visits of 45 groups in the same folds.
- Verdict: no window reading beats MAD. Recommended rule less the control's: stream +0.7 (SE 22.7), river +49.5
  (SE 43.8), both +40.1 (SE 41.2); seeds lower 2, 0 and 0 of 4; without LFRA -0.2, +53.9, +45.2.
- Next: Phase 6, the write-up.

## Phase 6, 2026-11-22

- Completed: `research/chinook_window_flow.md` revised in place (the plain-language answer and table first, Phase
  2's checks with the way each points, the reading, the caveats); the limit in `research/chinook_stream_size.md` and
  in the methodology article (rendered to a scratch directory: it builds, and the sentence links #226); #226's body
  carries the result; `CLAUDE.md`, `scripts/README.md`, `research/README.md`.
- By the verdict, no follow-up is filed for link, the evidence build or group windows.
- Next: the full tests, lint against main, `/code-check branch`, the archive and the PR.

## Review round 1, 2026-11-22

- Full test suite on the database's host before the round: 463 tests, 2,654 expectations passed, 0 failed, 0 errors,
  2 skipped (the live build-record schema test and the ignored grade tables).
- Round 1, code (`review-round1.md`): 4 findings, all fragile, none moving a committed number; all fixed. `r$curve`
  partial-matched `curve_error` in the tune script's error path (`[[ ]]` now); the window walk's month check counted
  rows, so a NULL flow or weight would read a window short (it counts flows and refuses a NULL month or weight); no
  test reached that check (a month no segment carries now does, and with the check deleted that test fails); the
  window cache was not keyed on the month weights (the key now carries the months and weights).
- Round 1b, claims (`review-round1b.md`): every cell of the result tables matched the committed CSVs; 4 overclaims in
  the prose around them, all fixed (the article's sentence on stream size, "most" for 138 of 300, a "points to" cell
  that left out "both", three timings from passes whose logs were overwritten).
- The window walk's file changed, so the evidence and the scoring are run again on it.
- Rerun on the corrected window walk (md5 `53d2c1ff...`), after deleting the 258,496 rows this session had kept in
  `knw.walk_cache_window` under the earlier file's md5: the evidence build walked cold again (1.0 min, 6.8 s for its
  500; the committed evidence log is now this cold pass) and wrote byte-identical tables (`out_md5` unchanged); the
  scoring, read back from its caches in 46 s, changed nothing but the run record's `head` and `evidence_head`. The
  cold scoring's log stays as `20261122_chinook_window_tune.txt`; the rerun's is `...-rerun.txt`.

## Review round 2, 2026-11-22

- Round 2 (`review-round2.md`): no bug; 2 fragile findings, both fixed. One sat inside round 1's fix: the month
  check held the number of flows to the number of months, not each month once (August twice and no September
  passed). The other: the weighted sum had no order, so its last bit could depend on row order for three months or
  more. It confirmed round 1's other fixes by mutation and the rule-commit guard on six states of a scratch clone.
- Because a finding sat inside a fix, the loop ends on an enumeration: `review-enumeration.md` lists the 14 ways a
  window's flow can be wrong at a segment with each one's guard, and a mutation table over the walk file (14
  mutations, each red; unmutated 15 of 15 green). New: a fixture test that runs the walk's own text, table names
  swapped, on a line of five malformed segments and one whole one; the walk refuses a repeated month and weights
  that are not positive shares summing to 1; the evidence pre-count holds the same three row conditions and counts
  flows that are not numbers.
