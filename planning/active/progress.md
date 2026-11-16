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
- Sourcing: scripts, web search, Chrome (m4) and Al's ResearchGate downloads into m4's `~/Projects/repo/store_stats`
  (pulled over ssh). 23 of 30 works have PDFs.
- 0270 `override` column (440ebcbf) for five CrossRef records wrong against their title pages.
- Wrote `data/detection_{members,additions}.csv` (2 + 21 rows) and `enumeration_round0.tsv`.
- Next: Al's call on the 7 no-PDF works (abstract-only vs gap), then the Phase 2 dry run.
