# Progress — Backlog move 2: Public articles: a tuning series, one vocabulary, a build that cannot stall (#171)

## Session 2026-11-12

- Plan-mode exploration — phases approved by user (titles, stream-splits placement, fwapg citation and redirects decided at the gate)
- Created branch `171-backlog-move-2-public-articles-a-tuning` off origin/main
- Scaffolded PWF baseline from issue #171 with approved phases
- Next: start Phase 1
- Phase 1: register check narrowed to the printed columns (all but `where`, `note`), mutation table in findings
- Phase 2: three articles and .bib renamed to tuning-*, references rewritten, _pkgdown.yml groups and redirects; tests 0 failed
- Phase 3: titles, life-history openings, "fish habitat definition" through the three articles, README, DESCRIPTION and the map labels; README figure regenerated; plan review folded in (review-plan.md)
- Phase 5: stalls read (8 runs, 3 days, all apt DNS in setup-r); pkgdown.yaml gets apt retries and timed second tries; flows#3 body carries the evidence
- Code-check round 1: 1 finding (Kirsch claim overstated its page), fixed; the uncommitted vignette_bib.R change committed; readability pass: 5 sentences fixed here, the rest filed as #202; pkgdown/favicon (an artifact of the local build) removed
- Code-check round 2: 3 findings, all fixed: the apt-retries step was overridden by the runner image (dropped; flows#3, #159 and findings corrected), the method opening dropped "mostly where those join a river", stream splits credited every flow to the fwapg fork
- Code-check round 3: 5 findings, all fixed (one inside round 1's fix); ended by enumeration of every factual sentence the branch added; #159 body corrected (not every stall was DNS)
- lintr against main per file: the branch added 4 long lines, wrapped; a design-note sentence the fwapg edit had displaced moved back
- Phase 4: Zotero's "empty reply" was `~/.curlrc`'s browser user agent, not Zotero; three `.bib` regenerated, shared keys unchanged but upstream fwapg's version; Kirsch et al. (2014) record corrected in the group library (ADF&G FDS 14-04, URL); site rebuilt with every citation resolved
