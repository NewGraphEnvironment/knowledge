# Progress — Stream size where Chinook are caught: CH detection by MAD class across all watershed groups, and distance to a large river (#52)

## Session 2026-10-15

- Plan-mode exploration — phases approved by user
- Created branch `52-stream-size-where-chinook-are-caught-ch` off main
- Scaffolded PWF baseline from issue #52 with approved phases
- Next: start Phase 1
- 22:20Z plan review spawned (Plan agent); 0294 first design built and run (5 min of traces), then stopped
  when the review landed at ~22:31Z: B1–B4 changed the build (findings.md)
- 0294 reworked: explicit path walk (`scripts/sql/ch_dist_large.sql`), parent flow for side channels,
  regulated and ambiguous flags, link's range rule. Final run 21,862 visits kept, 1,186 CH; walks 0.4 min
- 0295 reworked per review (three responses, leave-outs, fixed reference for distance); 2- and 6-worker runs
  byte-identical
- Next: research/chinook_stream_size.md, issue bodies, code-check branch, archive, PR
- Restore-the-bug on 0294 (mutated copy): blocked-absence drop off -> ledger 389 -> 0; dedupe key without
  area -> flagged 568 -> 688; kept 21,862 -> 22,051
- research/chinook_stream_size.md written and its numbers re-checked against ch_mad_use.csv (four
  corrections: sensitivity range, WSG count, parent-flow rate, the 0.1-0.28 comparison); README row;
  #52 body gained a Result section, #42's scope note points at it
- /code-check branch round 1 (spawned 22:54Z, delivered ~23:03Z): code clean; 5 write-up findings, all real.
  The regulated column was a visit share labelled as a detection share; 0295 now writes both
  (`regulated_detect_share`, `regulated_visit_share`), re-run with the same seed, relative rates unchanged.
  Four wording and number fixes; #52 body "a third to a seventh" corrected to "a seventh to three-fifths"
- /code-check round 2 (spawned 23:05Z, delivered ~23:11Z): code clean; round-1 fixes hold; 5 wording findings,
  none inside a round-1 fix. Fixed: the 0.1-0.28 floor bullet rested on regulated side channels and mixed
  bases (now the clean 52 of 107, plus the regulated-out rates), an unmeasured "fits better" claim, the `none`
  class's meaning (558 direct, 685 via smaller lines; checked), the README row for 30-100, two stale comments
