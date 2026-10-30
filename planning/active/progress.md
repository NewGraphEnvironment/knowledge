# Progress — Measured site gradient against link's segment and Atlas-line gradients at FDIS visits (#121)

## Session 2026-10-30

- Plan-mode exploration — phases approved by user
- Created branch `121-measured-site-gradient-against-link-s-se` off origin/main
- Scaffolded PWF baseline from issue #121 with approved phases
- Next: start Phase 1
- Phase 1: the RISC site card field guide (2008, p. 13) defines the gradient box; the FDIS model holds two method
  codes and a measurement table; the second reading does not run higher on the published build. Decision recorded.
- Plan review (Plan agent, background) returned; verdicts in `review-plan.md`. Its blocker (a negative gradient fails
  every rule, so at 0 it can move in) was right; on the published build no negative is in any key population.
- Phase 2: `data-raw/site_gradient_check.R` written; the evidence guard refused the 2026-10-25 build in this checkout
  (refused log not kept); the population guard caught a missing groups filter on the first published run.
- Phase 3: answered from the code (rule test `g >= 0`; curve and grade clamp to [0, 0.2]).
- Phase 4: "Measured vs modelled gradient" section in `research/fdis_export.md` (header's Verified, Issues and
  Produced by lines revised; the #121 pointer bullet now points to it); `data-raw/README.md` entry.
