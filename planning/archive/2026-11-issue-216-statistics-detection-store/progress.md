# Progress — statistics store: the methods literature for detection and occupancy (#216)

## Session 2026-11-16

- Plan-mode exploration; phases approved by Al (build list: the whole statistics tree; open-copy sourcing routes
  and abstract-only filing added at the first rejection)
- Created branch `216-statistics-store-the-methods-literature` off origin/main
- Scaffolded PWF baseline from issue #216 with approved phases
- Next: start Phase 1
- Plan review (Plan agent) folded: `planning/active/review-plan.md`. B1 (empty survey_design aborts 0150) is a gate
  in Phase 3. B2 dropped (cred#35 closed). The OpenAlex abstract fallback became a question for Al once the PDF
  search is done (A2, S1). Enumeration moved before filing (O1). Branch pushed before the store push (O2).
- Sourcing: scripts, web search, Chrome (m4) and Al's ResearchGate downloads into a download folder on m4
  (pulled over ssh). 23 of 30 works have PDFs.
- 0270 `override` column (440ebcbf) for five CrossRef records wrong against their title pages.
- Wrote `data/detection_{members,additions}.csv` (2 + 21 rows) and `enumeration_round0.tsv`.
- Next: Al's call on the 7 no-PDF works (abstract-only vs gap), then the Phase 2 dry run.

## Session 2026-11-17

- Hutchinson et al. 2015 added mid-run (Al's issue edit); filed as `CVVUQZR5`.
- Built `statistics` with Zotero quit: 31 docs, 11,113 chunks. Hedger was skipped by ragnar 0.3.1, and decision 5
  sends it to knowledge#223. Pushed; the ETag matches at 8 MiB parts.
- Code-check: round 1 clean; round 2 found Hsieh's title and creation-only overrides (fixed, live patch); round 3
  found the identity mechanism, fixed by matching the DOI first. The loop ended on the enumeration in
  `enumeration_round3.md` (11 sites).
- Public sweep: tree (branch-only hits), commits and GitHub. The one new hit, a home path in this file, is fixed.
- Next: /planning-archive, /gh-pr-push.
