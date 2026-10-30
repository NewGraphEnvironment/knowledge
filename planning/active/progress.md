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
- `/code-check branch` round 1 (`review-round1.md`): 9 findings. Fixed: ST's band on the default ladder (now each
  key's own ladder from its tune table; only ST's row moved, 48.0 → 42.4 %), the yardstick ratio's direction in the
  prose, the catch paragraph (one statistic carried the claim), "a third to two fifths" (34 to 42 %), the BT spawning
  population wording, "67 %" (zero sites now named), "tested on every rule" (the test had no visits; the log now says
  NA), the population refusal's log name (`_refused`), the stamp (now names uncommitted changes). Accepted: the
  log's `~` path, as the house checks write it (`home_rel()`).
- Tests: 298, one failure, `test-vignette-data.R` "every ignored source of the methodology article, where present, is
  unchanged": this checkout's ignored `data/fdis/derived` is the 2026-10-25 build (CLAUDE.md: it fails on a machine
  whose copies differ). Unrelated to the branch.
