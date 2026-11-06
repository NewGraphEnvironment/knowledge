# Plan review (Plan agent, 2026-11-06), with verdicts

Delivered as reply text (Plan agents cannot write); summarised here with the verdict on each.

| # | Finding | Verdict |
|---|---|---|
| 1 | Dam test can pass on old code (tied segments share a vertex, same measure); compare wscode/localcode too; assert a tie was found | Disproved by the restore check: on m1 the old code gave measures 18319.28380 / 1651.96479 against the lower id's 18319.28361 / 1651.96526, and the test failed. Kept the cheap part: also compare `wscode` and `localcode`. The `skip_if` on no tie stays a skip (visible, not a pass) |
| 1b | Flow live test should compute the tie explicitly and assert it | Already does: it reads both parents' distance by id and asserts them equal with different flows |
| 2 | Fixture can pass vacuously (merge join orders by id) | Disproved by the restore check: order 30, 20 took 30 on the old code. Parent and flow rows are inserted together per id, flows differ, value asserted exactly |
| 3 | One parent with two picked rows would re-open the tie | Declined: wet's `pick` is one row per segment by design and the probe found 0 duplicates; recorded in findings |
| 4 | Near (non-zero) ties hold only on identical data and PostGIS | Taken into Phase 3: the check counts lines whose two nearest eligible parents are within 1e-6 m |
| 5 | Dam lookup has no blue-line filter; second sort key could lose the KNN index path | Taken into Phase 3: time old and new twice on each database, and EXPLAIN the dam lookup |
| 6 | Say which version carries the fix, not just "fixed" | Taken: CLAUDE.md and research name the release (0.4.32, the patch `/gh-pr-merge` cuts) |
| 7 | Phase 3: old code may not reproduce #158; pass = old-vs-new differences are a subset of tied lines; include visit lines | Taken |
| 8 | No register `code:` phrase breaks | Confirmed by test-settings-register in the full suite |
| 9 | `scripts/sql/ch_dist_large.sql:91` has the same untied lookup, frozen with removed 0294 | Mention in PR, no change |
