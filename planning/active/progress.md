# Progress — Growing-season degree-day thresholds for BC salmonids: search beyond the temperature collection (#47)

## Session 2026-10-13

- Plan-mode exploration; phases approved by Al. Plan gate: size thresholds get a new `fish_length` variable (mm, metric fork/total/unstated)
- Created branch `47-growing-season-degree-day-thresholds-for` off main
- Scaffolded PWF baseline from issue #47 with approved phases
- Next: start Phase 1
- Phase 1: `fish_length` variable (mm; metric fork_length/total_length/unstated) in `pkg/R/literature.R`, tests. Mutation: dropping the metric fit fails 2 tests, widening the unit fit fails 1. Full suite 0 failing of 103 files; `0280` on the unchanged table passes, thermal 50/50.
- Phase 2: two background searchers spawned 23:31 UTC (trout/char → `search-tc.md`, salmon/steelhead → `search-ps.md`).
- Phase 2: both searchers delivered (`search-tc.md` 13 candidates, `search-ps.md` 21). Merged in `findings.md` with the keep/drop reasons. No independent GSDD threshold outside Colorado.
- Phase 3 (part): 9 items with direct PDFs into `Fisheries/temperature` (`0270` log `scripts/logs/habitat/20261013_temperature_collection-build.txt`); a dry re-run is a no-op; all 9 synced locally with citation keys and a PDF. 7 browser/paywalled items opened in Chrome for Al.
- Phase 4: `drafter-brief.md` (from #38's, with the #47 rules) to two background drafters. tc 19 rows → data rows 1103–1121, ps 15 → 1122–1136, merged tc first so tc's row cross-references hold. No row fills a growing-season cell (the valued degree-day rows are on other windows), so all ten `none` rows stay; their notes now name the wider search and point to what it found. `0280`: 1136 rows, 0 failing, thermal 50/50, flow 60/60, coverage 48/48. The seven browser items, if Al saves them, get rows in a second pass.
- Phase 5: round 1, two Plan auditors (tc, ps+none notes): 14 findings, all in notes or cited_source, each reproduced before its fix (`audit-{tc,ps}-round1.md`, commit 432e3ab). Round 2 on the fixed notes is running, with a sentence-by-sentence enumeration.
- Phase 6: `research/thermal_requirements.md` gains a First-winter size section and the BT and ST degree-day rows; status, WCT paragraph and consumer guidance revised; README row; CLAUDE.md names `fish_length`, the additions file and a size-row drafting rule (432e3ab).
- Phase 3: temperature store rebuild started in the background.
- Phase 5: round 2 found defects inside round-1 fixes (1112, pointer wording, log path) plus two drafter sentences (1115, 1122); fixed; ended by the sentence enumeration (`audit-round2.md`). `0280` passes: 1136 rows, thermal 50/50.
