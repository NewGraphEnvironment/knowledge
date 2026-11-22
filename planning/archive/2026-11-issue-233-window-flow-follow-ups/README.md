# Backlog move 14: window flow follow-ups (#233, carrying #226)

## Outcome

#226 (#105's Phase 2) asked whether the chinook rearing rule picks chinook streams better when a stream's and a
river's size is their flow in late summer instead of mean annual discharge. It does not: by a verdict rule written
into `research/chinook_window_flow.md` and committed before any score was made, no window reading beats MAD, so the
rule stays on MAD and no follow-up is filed for link, the evidence build or windows that move by group. To score it,
the branch added `knw_link_flow_window()` (wet's flow in a window on the segment MAD came from), a window walk
(`inst/sql/ch_dist_profile_window.sql`, `knw_link_walks(window = )`) beside the annual walk, whose text and md5 did not
move, a copy of the published evidence with the window column and window walks (`data-raw/chinook_window_evidence.R`),
and the scoring of four readings (`data-raw/chinook_window_tune.R`). Nothing was graded, compared or published.
#227 (low flow at gauges) was split out at the plan gate for its own `/planning-init`. The durable verdict, every
check with the way it points, and the caveats are in `research/chinook_window_flow.md`.

Four gate decisions (Al, 2026-11-21): a separate window walk; the published evidence augmented, not `0310`; #226
only; the verdict rule set before scoring.

## Measurement

- **The verdict.** Each window reading's recommended rule less the control's, held-out deviance over 4,858 visits
  (234 with chinook) in 45 groups, lower is better: window at the stream +0.7 (SE 22.7), at the river +49.5
  (SE 43.8), both +40.1 (SE 41.2). Lower than MAD on 2, 0 and 0 of four other fold seeds. Without the lower Fraser:
  -0.2, +53.9, +45.2. None meets the three conditions. It kept the rule on MAD and closed the question #105 opened.
- **The control is the published run.** All 6,149 rules' held-out deviance of run `20261103_0838` to 1e-6, the pick,
  the recommended rule, the region, nested selection 1,322.7, 4 of 4 seeds, bootstrap share 0.095. All four
  readings scored the same visits in the same folds.
- **What the stream window does change.** How steadily the size is chosen: every nested fold and 54 % of bootstrap
  redraws pick 0.75 m³/s on window flow, against two folds and 34 % on MAD; its gain in the curve (21.7 lower) turns
  to a loss (12.8 higher) without the lower Fraser.
- **Phase 1 reproduced.** The median window share of MAD at the scored visits is 0.590271, Phase 1's, and no group's
  median moved (largest gap 4.9e-15). The exact window walk puts a river within 1 km of 980 scored visits where
  Phase 1's ladder reading had 969: 11 more, none with chinook.
- **The load is whole.** 4,532,843 picked segments, none short of a window month, with a month twice, on two sources
  or with a flow that is not a number.
- **Run times, on the database's host.** The window walk: 36,928 starts x 7 sizes in 1.0 min cold on 8 workers
  (6.8 s for 500 uncached). Scoring: 3.3 min a reading with the bootstrap, nested selection and four more seeds on
  12 workers, 0.8 to 0.9 min without them; the whole scoring 17 min. A rerun from the score caches takes 46 s.
- **`knw_link_flow()` on two segments: 168 s; 3 s once its temporary table is analysed** (filed as #255).
- **Wrong turns kept.** The evidence script stopped on its first three passes, each on a check doing its job: 4 of
  45,529 visits hold a tied parent's flow from before #161 (river-polygon lines, none scored); `%.17g` through readr
  does not read back to the same double (13,936 of 45,529 off by 1 to 8 units in the last place), so the column is
  written at readr's 15 digits and held to 1e-12; md5 vectors are named by path. The plan's first paired comparison
  (one grid of every reading's rules) would have given an SE against that grid's best, not the pair's: the plan
  review caught it before it was built, and that the score cache records neither the size column nor the walk source.
- **The review.** Plan review: 2 blockers, 5 gaps, all folded in before the phases they touched. Code check: three
  rounds and a claims pass, 13 findings, all fixed, none moving a committed number. Each of rounds 2 and 3 found a
  defect inside the round before's fix, all in one place: the window walk's condition that a segment carries the
  window's months. Round 1: it counted rows, not flows. Round 2: it held the number of flows to the number of months,
  not each month once. Round 3: its counts ranged over different rows, so a segment breaking two conditions at once
  passed (of 225 row shapes the walk took 16, 14 malformed). The condition is now a one-to-one match, and the loop
  ended on an enumeration: a test that holds the walk to all 225 row shapes of a two-month window (it takes exactly
  the 2 whole ones) and 18 mutations of the walk file (16 red; 2 green, an equivalent condition and the sum's order)
  (`review-enumeration.md`, `review-verdict.md`). After each round's change to the walk file the evidence was rebuilt
  (byte-identical tables, three times) and the scoring rerun (outputs unchanged, three times). Five reviewer agents
  in all.
- **Tests, on the final tree:** 466 tests, 2,678 expectations passed, 0 failed, 0 errors, 2 skipped (the live
  build-record schema test and the ignored grade tables), on the database's host. Lint on the changed files adds only
  the repo's standing header-line note on the two new scripts and three "no visible function" notes that come from
  the older installed copy of the package.

## Evidence

- `scripts/logs/flow_window/20261122_chinook_window_*` (the evidence build, the smoke gates, the cold scoring, and the
  rerun from caches).
- `data/tune/flow_window/ch_rear_{readings,pairs,verdict,tune_run,window_evidence_run}.csv` and
  `data/tune/flow_window/{control,stream,river,both}/`.
- `planning/archive/2026-11-issue-233-window-flow-follow-ups/review-*.md`.

## Left for a sweep

- `research/chinook_window_flow.md` is flagged by soul's research check for its length (about 3,500 words) and for a
  section headed with an issue number (`## Phase 2: ... (#226)`). The heading was left: `data-raw/chinook_window_tune.R`
  holds the block from that heading to the end of "The verdict rule" to its text at the commit that first held the
  rule (`267fcd06`), which is the record that the rule preceded the scores. Folding the section means moving that
  guard's anchor first.
- `knw_link_flow()` on a few segments takes minutes: #255.

## Owed

- [ ] Grading, comparing or publishing any window rule: each waits on Al's word.
- [ ] #227 under its own `/planning-init`.

Closed by: PR for #233
