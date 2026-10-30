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
- `/code-check branch` round 2 (`review-round2.md`): 8 fragile, 0 bugs; three inside round 1's fixes (the BT spawning
  wording still named one filter; the stamp missed the tune tables and data/thresholds.csv and read a failed git as
  clean; the `_refused` name was not freed). All fixed: git calls checked, TUNE_DIR logged, refused names through
  `.knw_free_path()`, negatives subset NA-safe, the edge-type tabulation now in the log, the outcome block rearing
  only, the zero-pair count per row.
- `/code-check branch` round 3 (`review-round3.md`), asked for the mechanism: every definition and number is written
  twice by hand (script against the tuning, prose against the log), and only `n_visits` and the md5s compare a copy
  with its source. It enumerated 34 prose claims and 13 restated definitions. Three findings fixed: the key set read
  `status == "fitted"` and dropped WCT rearing (`underpowered`, published at 0.25); it now takes every gradient row
  with a value from the table itself. The BT spawning population sentence (now the filters it passes, 11,805). The
  stamp's `git status` on a TUNE_DIR outside the repo (now stamped only when it is the tracked `data/tune`, named
  otherwise; tested on a copy). WCT adds a row; the band range is now 33 to 42 %.
- `/code-check branch` round 4 (`review-round4.md`): Clean, on two enumerations of the current files (41 prose
  claims, 13 restated definitions), each against its source; a copy of the script reproduced the committed log from
  line 2 on. The loop ended by enumeration after four rounds (plus the plan review: five reviewer agents).
