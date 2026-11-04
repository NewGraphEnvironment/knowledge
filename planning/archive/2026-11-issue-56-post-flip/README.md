## Outcome

The post-flip remainder of #56, after the repository went public on 2026-11-01:

- The README links the pkgdown site's two articles (the chinook rearing article and, newly, the methodology
  article), its function reference and its news page.
- The last pre-flip wording is cleared from CLAUDE.md's repository line, the headers of `0299` and `0325`,
  `scripts/README.md` and `research/fdis_export.md` ("Where it lives", re-verified 2026-11-01).
- link#346 now names this repo and links #57.
- #76 and #56 point each open item at its home: the licences go to #76 (now with a modelled-flows task); the post goes
  to new_graphiti#8; the comms peer list goes to the conventions repo, as its own PR there, which also removes
  knowledge from that repo's private-repo leak floor. The floor's test had been failing since the flip.

What was learned: a parallel session's PR (#133, #76's PSCIS notice) rewrote the same two CLAUDE.md lines. This
branch takes #133's repository line verbatim, so the two merge cleanly in either order, and leaves the licence
sentence to #133. Code-check also showed that the open-sources list ("EcoCat and bcfishpass") had been copied from
place to place by hand and had dropped NOTICE's modelled-flows row. The fix was to point each copy at
`inst/NOTICE.md`'s "Terms not yet settled" section and list all three sources.

## Measurement

- Site: `newgraphenvironment.github.io/knowledge/` answers 301 to `www.newgraphenvironment.com/knowledge/`. Every new
  README link answers 200.
- Bucket: anonymous reads of `fdis/README.md` and `knowledge/fdis/v2/manifest.json` answer 200, and
  `aws s3 cp --no-sign-request` of the v2 manifest works. `knowledge/thresholds/v1` and `fdis/v3` answer 403
  because they are not uploaded: the bucket does not list, so a missing key reads 403.
- Tests: `devtools::test()`, 1802 passed, 0 failed, 1 skipped.
- Code-check: three rounds on this branch.
  - Round 2 found a defect inside round 1's fix, and round 3 one inside round 2's.
  - The loop ended on an enumeration of pre-flip wording: 254 tracked text files, 10 hits, 9 correct as they are and
    1 owed.
  - A second enumeration covered the six places that state which sources are still unsettled.
  - The soul change had four clean rounds, and its test suite passed.

## Owed

- After this PR merges, confirm that the site's home page (built from README) carries the new Learn more links
  by fetching the page, not by reading the run status
- soul PR for #438 merged (Al)
- After #133 merges: merge origin/main here (or follow up), and drop CLAUDE.md's "to settle before the repo is
  public" clause, which #133 keeps: the repo went public with the EcoCat and bcfishpass rows open (Al, 2026-11-01).
  This item is a task in #76's body, which also names the modelled flows.

Closed by: the PR that fixes #56
