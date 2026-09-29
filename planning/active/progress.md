# Progress — FISS .xls: parse Step 2 life stage and Step 3 individual fish into the size-class evidence (#21)

## Session 2026-09-28

- Plan-mode exploration — probed all 247 fetched workbooks for Step 2/3 headers and values; phases approved by user
- Created branch `21-fiss-xls-parse-step-2-life-stage-and-step` off main
- Scaffolded PWF baseline from issue #21 with approved phases
- Next: start Phase 1
- Prior-art check in fish_passage_template_reporting + org: producers only, nothing to reuse (findings)
- Phases 1-2: 0220 reads edition variants, Step 2 stage, Step 3 per fish; re-run on 5 groups, reconcile passes (logs `scripts/logs/fiss/20260928_*`)
- Phase 3: `knw_size_class()` in pkg with tests (restore-the-bug: `<=` on the upper break turns the boundary test red); 0240 switched to it, its three outputs byte-identical to HEAD
