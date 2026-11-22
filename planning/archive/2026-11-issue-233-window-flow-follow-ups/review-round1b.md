# Review round 1b: written claims against the committed tables and logs (#233, #226)

Reviewer of prose only, 2026-11-22 UTC, on `233-backlog-move-14-window-flow-follow-ups` at `ffdeee52`. Read-only:
nothing was run but small reads of the committed CSVs and logs, one read of the ignored local evidence copy, and two
`gh issue view` calls.

## What was checked

- `research/chinook_window_flow.md` (header, Short answer and its table, all of Phase 2, Caveats, What next): about
  150 numbers, quantifiers and directions against `data/tune/flow_window/ch_rear_{readings,pairs,verdict,tune_run,
  window_evidence_run}.csv`, the four `<reading>/CH_rear_{honest,seeds,region,groups}.csv`, Phase 1's
  `ch_rear_{run,flips,flips_by_group,ratio_by_group}.csv`, `data/tune/CH_rear_{summary,tune,honest,seeds}.csv`, the
  three `20261122_chinook_window_*` logs, `data-raw/chinook_window_tune.R` (`reading_row()`, `pair()`, the verdict
  block), `R/tune_score.R` (`.tune_sel()`, `.tune_pick()`, the nested selection, the bootstrap) and `R/tune_grid.R`.
  - Every cell of the Short answer table, the verdict table and the 14-row checks table matches its source to the
    digits shown (signs, rounding, which reading is which). The nested-fold and seed counts were recounted from the
    `honest` and `seeds` files and agree with `reading_row()`'s columns.
  - "How to read it": 1,211 (189) against 1,400 (197); two folds and 34 % against five folds and 54 %; 56 against
    102; 43.2 and 34.9 behind; within 6.3 with MAD's the lowest; 980 against 969, 11 more, none with chinook;
    233,984 of 258,496 against 240,312: all match.
  - Caveats: the grid's MAD steps are 0.1, 0.15, 0.2, 0.28, 0.35, 0.5, 0.75, 1 (`R/tune_grid.R:50`), so 0.75 is one
    step under the top and 0.44 lies between 0.35 and 0.5. 4 tied visits, 1 dry visit, 4,855 curve visits on every
    reading: match.
  - Order in time: `267fcd06` (04:59:03Z) precedes the smoke run (05:31:26Z) and the scoring (05:31:44Z, HEAD
    `662eb1e7`); the tune log and `ch_rear_tune_run.csv` name `267fcd06` as the rule's commit; the sections "The four
    readings" and "The verdict rule" are byte-identical at `267fcd06` and at HEAD. The control's 104 written rows
    equal `data/tune/CH_rear_tune.csv` (largest gap 0, the same region of 102, pick and recommended rule), and its
    `honest` and `seeds` files equal the published ones.
- `research/chinook_stream_size.md` (header, the new Limits bullet): 4 claims against `ch_rear_verdict.csv`; hold.
- `vignettes/tuning-method.Rmd` (last Limits bullet): 3 claims against `ch_rear_verdict.csv` and
  `data/thresholds.csv`; one finding below.
- `CLAUDE.md` (the `data/flow_window/` bullet and the two added paragraphs): about 15 claims against
  `inst/sql/ch_dist_profile_window.sql` (three marked regions), `R/link_walks.R`, `R/tune_run.R:221` (the cache's
  settings), `data-raw/chinook_window_evidence.R` (the `1e-9` tolerance, the tied-visit check), the evidence log and
  `.gitignore`; hold.
- `scripts/README.md`, `research/README.md`: the changed lines against the scripts' headers and the verdict; hold.
- `planning/active/progress.md`, `findings.md`: about 45 numbers against the logs, the run records, the commit log,
  `planning/active/review-plan.md` (2 blockers, 5 gaps, a scope section) and the test files (4 tests added to
  `test-link_flow.R`, 6 to `test-link_walks.R`, 13 in that file); one finding below.

Not checkable from committed files:

- **wet's gauge figures** (`research/chinook_window_flow.md:332-333`, "17 % high in July and August", "within
  6 %"): nothing in this repository carries them. Read from the body of `NewGraphEnvironment/wet#6` with `gh`: routed
  PCIC "+17 % in July-August" over 283 shared gauges, and the balance "no season off by more than 6 %". The sentence
  agrees with that body; the body's own source (wet's `gauge_monthly_compare` output) was not opened.
- **"All sit on river-polygon lines"** for the 4 tied visits (`research/chinook_window_flow.md:345-346`,
  `CLAUDE.md`, `findings.md:46-47` with edge 1250, the groups and "two parents 0 m away"): no committed table or log
  carries an edge type; the evidence log lists only the four site visits. The ignored local
  `data/fdis/derived_window/visits_link.csv` confirms all of it (edge type 1250, `flow_from` parent,
  `parent_dist_m` 0; TABR, LHAF, UPCE, LHAF). "None is scored" is the script's own stop
  (`data-raw/chinook_window_evidence.R:178-180`) and edge 1250 is outside the stream branch (1000, 1100, 2000, 2300).
- **Timings and counts from passes whose logs were not kept**: `findings.md`'s 168 s, 3 s and 160 s, and "13,936 of
  45,529 window flows ... 1 to 8 units in the last place away"; `progress.md`'s expectation counts (21, 126, 2) and
  the month-0 check on "3 starts x 3 sources x 4 sizes" (they need the database).
- **"Set at the plan gate (Al, 2026-11-21)"**: no committed file dates the gate.

## Findings

- **[severity: overclaim]** `vignettes/tuning-method.Rmd:458-459` — "A stream's size is its average flow over the
  whole year." Stated of every definition the article covers, but two of the seven published definitions size a
  stream by channel width: bull trout spawning (`width>=2|g<=0.25|Q1@D500`, `spawn_channel_width_min`, 2 m) and
  grayling rearing (`width>=1.5|g<=0.0549|none`, `rear_channel_width_min`, 1.5 m) in `data/thresholds.csv`; the
  article's own `rule_words()` (lines 57-61) prints "is at least X m wide" for them. The sentence holds for the five
  sized by MAD, and for the river in an exception.
  - **Rule:** none

- **[severity: overclaim]** `research/chinook_window_flow.md:342` — "**Most of Phase 1's change is one group's**".
  In the reading that passed the 5 % rule ("both"), LFRA holds 138 of the 300 visits that moved, 46 %
  (`data/tune/flow_window/ch_rear_flips_by_group.csv`, line 110; the file's own line 136 says "138 of the 300"). It
  holds more than half only in the stream reading (119 of 194, 61 %), 17 of 102 in the river reading, and 2 of the
  16 chinook visits that moved. The second half of the bullet (the stream reading's gain in the curve, -21.7 with
  LFRA and +12.8 without) holds.
  - **Rule:** none

- **[severity: overclaim]** `research/chinook_window_flow.md:257` — the checks table's row "the curve's score, on
  the same 4,855 visits | 1,167.6 | -21.7 | +12.1 | +8.5 | the window at the stream; MAD at the river". The "both"
  reading is +8.5 (`dev_curve` 1176.122948 less the control's 1167.621102, `ch_rear_readings.csv`), which points to
  MAD, and the cell does not say so. Two rows of the same table (lines 251 and 254) use "the window at the stream"
  for the stream and both readings together (5 and 5 folds; 0.535 and 0.645), so here the phrase reads as covering
  "both" too, the wrong way. The row is right for stream and river.
  - **Rule:** none

- **[severity: unsupported]** `planning/active/progress.md:46` and `:52-54` — three numbers of Phase 4 that the
  committed log and run record do not carry:
  - "round trip 1.0 ms": the log says "database round trip 0.9 ms" and `ch_rear_window_evidence_run.csv` has
    `round_trip_ms` 0.9.
  - "500 starts in 7.3 s uncached on 8 workers": the log says "500 starts x 7 sizes in 7.0 s on 8 workers,
    uncached" and the record has `walk_trial_s` 7.
  - "all 36,928 in 1.0 min cold": the committed log is the pass that read every walk from the cache ("walked 36928
    starts x 7 sizes in 0.0 min ... 0 walked"; `walk_min` 0.01), as the entry itself says, so no committed file
    holds the cold time.
  The first two read as an earlier pass's numbers beside a log from the fourth.
  - **Rule:** none
