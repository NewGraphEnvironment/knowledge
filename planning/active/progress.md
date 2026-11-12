# Progress — Order the species columns knw_link_place() writes (#197)

## Session 2026-11-12

- Plan-mode exploration — phases approved by user
- Created branch `197-order-the-species-columns-knw-link-place` off origin/main
- Scaffolded PWF baseline from issue #197 with approved phases
- Next: start Phase 1
- Phase 1: `.knw_place_species()` sorts both species lists (radix); new catalog-order test plus sorted assertions on
  the live test. Before the fix the new test errored and the live test failed (it ran: a `fresh_default` was
  reachable); with the helper replaced in the loaded namespace by an unsorted copy, the new test failed 5 times and
  the live test once, `R/link_place.R`'s md5 unchanged across the run. Lints on the two files: one removed, none added.
- Plan review (Plan agent) folded in: `review-plan.md`. The access list was never sorted in any ledger, so the next
  build moves both column blocks once on every database; `evidence.yaml`'s comment also cited #197; local seed;
  `_stored` order pinned in the live test.
- Phase 2: research/database_builds.md, research/run_archive.md and inst/receipt/evidence.yaml say the fix and the
  one-time move. NEWS line goes in the PR body for /gh-pr-merge.
- A full `devtools::test()` was stopped mid-run after a test edit (it would have described a mixed tree); rerun after
  this commit.
- Full `devtools::test()` on 85c4dda7: FAIL 0, WARN 0, SKIP 3 (stages not on this machine), PASS 2298 (2.1 min).
- /code-check branch round 1 (`review-round1.md`): two false claims, both confirmed and fixed. The research prose said
  the next build's two tables differ from the published build's "with the same values"; the published `visits_link`
  lacks #120's `segment_fwa_gradient` and #161's fix moves parent flows, so the md5 changes in any case. Now says the
  species columns move once and that databases then agree on column order. The test comment's fixture provenance was
  false; reworded.
