# Progress — Internal article: the tuning against Bayesian practice, and where it goes next (#204)

## Session 2026-11-13

- Plan-mode exploration — phases approved by user
- Created branch `204-internal-article-the-tuning-against-baye` off origin/main
- Scaffolded PWF baseline from issue #204 with approved phases
- Next: start Phase 1
- Phase 1 done: `scope` in `method.rds` (1745fba5 for the script), bundle rebuilt, test added; 20 tests in
  test-vignette-data.R pass (2 skipped: opt-in grade check, cut-points stage)
- Plan review folded (87af2689): navbar written out, scope check allows a failed curve; bundle rebuilt at it
- Phase 2: article, `_pkgdown.yml` internal section, link from `#se`, bib; Zotero item fixed. Quote check extended.
- Phase 3: blind readability pass and meaning audit (round 1), then two more audit rounds on the fixes
  (524d8a9d, 9ca32daa, ab564504); round 2 found an error inside round 1's effort fix, round 3 two inside round 2's.
- Validation so far: devtools::test() FAIL 0 / PASS 2322 / SKIP 3 (before the article revisions; tests read none of
  them); check_pkgdown clean; articles index lists the three public articles only; menu HTML identical to main's;
  `#se` links the article; quote check PASS on both files; no "rule" in the article's prose.
- /code-check branch round 1 spawned 2026-11-13T08:07:02Z
