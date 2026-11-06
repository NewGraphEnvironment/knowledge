# Code-check round 2 (#161)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: every H3 under `## Mechanisms` (prose, table rows skipped); in full "Written data outlives the fix",
  "A guard that fails toward pass", "A fixture that cannot reach the failure mode", "Verification that reads its own
  output", "One fact derived twice", "Zero-length, empty, and unset are three different things". Rules that stand
  alone: headings only (none matched the diff's shapes).
- code-check-r.md: "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a presence
  check can each depend on it", "A database driver's value is not a base R type — and it fails twice", "CSV
  whitespace: `trim_ws` and `strip.white` do not do what the name suggests", "`identical()` on two reader results tests
  the reader, not the file". About 140 headings not read (no matching tool or shape).
- code-check-shell.md, code-check-spatial.md: index only; no heading names a tool or shape the diff uses beyond what
  the R sections cover (0 sections read in each).

## What was checked and held

- research/database_builds.md's numbers against the committed logs: 2,831 parent lines and 1,800 tied
  (`n_parent_lines`, `n_tied_parent_lines`); 614 lines and 2 dams old-vs-old; 0 and 0 new-vs-new with equal flow and
  dam md5s; 632 and 636 old-vs-new ("about 630"), `flow_differ_all_tied` TRUE on every row. "No slower": flow
  228/183 s against 178/176 s on the host, 47/16 s against 46/14 s on the second database; the dam snap is under 0.2 s
  on every run. All hold.
- The non-exact tie: one line (201045724) has d1 and d2 differing by about 6e-14 m, identical on both databases, so it
  is ordered by distance, not by the tie rule; no effect on the claim.
- `diff_keys()`: every column is read as character, NA is written `""` on both sides, numbers at `%.17g`, both files
  sorted by key, and `stopifnot(identical(keys))` refuses a different row set, so a difference cannot be hidden by
  type, rounding or NA. An empty difference makes `all()` TRUE only where the row count is also 0, which the log shows.
  The tie set is restricted to parent lines on both sides of the intersection, so it cannot widen the pass.
- The tests: the fixture's segment 10 is its own candidate in the lookup, but has no flow row, so the join to `q`
  excludes it; the live dam test's `DISTINCT ON ... ORDER BY cabd_id, linear_feature_id` ends on a unique key; integer64
  columns are converted before `expect_identical`. No `code:` phrase in `inst/method/settings.csv` sits on a changed
  line.
- No host or machine name in tracked text outside `planning/`.

## Findings

- **[severity: fragile]** research/database_builds.md:241-242 (and CLAUDE.md:549-550) — "The published evidence and
  grades were made with the old code, so the change reaches them only with the next build" is wrong for the grades.
  `knw_grade_species()` (R/grade_species.R:96) reads its segments through `knw_link_segments()`, and that function
  calls `knw_link_flow()` live on every segment with no own flow (R/link_segments.R:83). So the first grading `0320` on
  0.4.32, even on the current build, moves the roughly 630 tied segments' size. The check's own population shows it:
  the 34,812 lines are the 8,167 flow-less `fresh_default.streams` segments (the grade's set) plus the visit lines, and
  #158's grade differences (CLAUDE.md: up to 441 segments, 276 grades) came from a regrade, not a rebuild. The
  consequence the prose hides: `0320`'s keep-check (scripts/0320-tune-run.R:603-613) keys a kept grade table on rule,
  run_uid, walk, walk_md5, ref_edge, discharge_load, prior, withheld, evidence and gradient, not on the code that read
  the segment flows. So a candidate resumed with `RUN=` after the merge keeps its pre-0.4.32 grade tables and regrades
  only the keys whose fields moved, and a by-key promotion onto the current build puts keys graded under the two tie
  rules side by side. Each passes every reader's check, and the tie rule they were graded under is in no field (only
  `knowledge_commit` in the record, which nothing compares). The same unit error is in CLAUDE.md's "until ... a build
  made with 0.4.32 or later is promoted": the evidence is a set of copied files and does not depend on the database,
  so what removes the cross-database difference is grades made with 0.4.32, not a build. That wording errs toward
  caution and is safe; the research sentence errs the other way. The fix is to say that the change reaches the grades
  at their next grading on any build, and the visit evidence at the next `0310`. A pre-merge candidate must also be
  regraded rather than resumed, unless the keep-check gains a field for the tie rule.
  - **Rule:** code-check.md "Written data outlives the fix"
