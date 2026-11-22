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

- Completed: `data-raw/chinook_window_evidence.R` and its run on the database's host (round trip 1.0 ms, no other
  active session): `data/fdis/derived_window/` (ignored) with `flow_0801_0930` on all 45,529 visits and 258,496
  window-walk rows on `pick@0815-0915` beside the 775,488 published; record
  `data/tune/flow_window/ch_rear_window_evidence_run.csv`; log
  `scripts/logs/flow_window/20261122_chinook_window_evidence.txt`.
- Measured: 4,532,843 picked segments in the load, none short of a window month or on two sources. Phase 1's median
  window share of MAD reproduced (0.590271; largest gap in a group's median 4.9e-15). The window walk: 500 starts in
  7.3 s uncached on 8 workers, all 36,928 in 1.0 min cold (the committed log is the fourth pass, which read them from
  `knw.walk_cache_window`). Found 233,984 of 258,496 rows, against 240,312 for the annual walk. The exact walk puts
  a river within 1 km of 980 scored visits where Phase 1's ladder reading had 969: 11 more, none with chinook.
- Three passes stopped, each on a check: 4 visits hold a tied parent's flow from before #161 (none scored); readr
  does not round-trip 17 digits; md5 vectors named by path (`planning/active/findings.md`).
- 1 visit has a MAD and no window flow above zero; 66 have no MAD above zero.
- Filed #255 (`knw_link_flow()` takes minutes on a few segments).
- Next: Phase 5, the smoke gates, then the four readings.
