# Progress — Habitat-thresholds literature store and evidence table (CH, BT first) (#19)

## Session 2026-09-29

- Plan-mode exploration — phases approved by user (collection renamed to `Fisheries/habitat_modelling` at the gate; group library searched before anything external)
- Created branch `19-habitat-thresholds-literature-store-and` off main
- Scaffolded PWF baseline from issue #19 with approved phases
- Next: start Phase 1
- Phase 1 committed (reader, `0150` scoping), after code-check rounds 1–2 and an enumeration of the reader's 23 `stop()` calls
- Plan review arrived after the first live `0270` run. B1 (the `D:\` links) was already fixed; the rest is folded in per `review-plan.md`
- Phase 2: `Fisheries/habitat_modelling` built (87 members, 72 stored PDFs); 10 new items created and keyed; the reruns are no-ops
- Phase 3: store built (202 docs, 33,746 chunks), pushed, verified against the manifest; `crd_search()` found broken upstream (ragnar 0.3.0 list column), cred issue drafted
- Phase 4: `0280` gate written first; 3 drafting agents; merged table of 186 rows, gate green, 3 mutations red; timing key corrected
- Phase 4 code-check round 1: gate hardened against 8 fabrications; 7 genuine rows re-quoted or split; table is now 190 rows, gate green
