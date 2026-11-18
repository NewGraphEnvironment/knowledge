# Progress — Backlog move 9: Access gradients and gradient on the ground (#178)

## Session 2026-11-18

- Plan-mode exploration — phases approved by user (two tracks and two moves, a `fish_passage` store, gradient rows with their leap and speed basis)
- Created branch `178-backlog-move-9-access-gradients-and-grad` off origin/main; claimed #178
- Scaffolded PWF baseline from issue #178 with approved phases
- Next: start Phase 1
- Phase 1: filed #234 (fish-passage literature, this branch) and #235 (PSCIS stream slope against link's gradient); #132 is the `track:access` umbrella and #70 the `track:gradient` umbrella; move 15 is #236 (batch 24); #178 narrowed to batch 14; backlog rewritten, lanes rechecked (move 9 and move 15 free of each other; move 10 waits on 9 over `CLAUDE.md`), every open move ticks cleanly on a copy
- Found: the PSCIS habitat-confirmation layer has no gradient field; #235 reads the assessment layer's `STREAM_SLOPE`
- Phase 4, vocabulary: `leap_height` (m, cm, ft; no metric) and `swim_speed` (m/s, cm/s, ft/s; metric burst, prolonged, sustained, critical, unstated) in `knw_literature_vocab()` and its unit and metric fits; `0280` reads them through `knw_literature_read()`. Two tests written red first; 47 pass
- Plan review folded (`review-178.md`): the collection is `Fisheries/Fish Passage/passage_limits` (Al), the store is built after the audit, an access grid in `0280`, a parameter guard on leap and speed rows; #131, #71, #234, #235 labelled and pointing at their tracks; #70's and #235's bodies corrected
- Phase 4: the capability guard in `knw_literature_read()` (test red first, 3 assertions; 48 pass; the 1,153-row table reads); the variable notes in `scripts/README.md` and CLAUDE.md
- Phase 4: `0280`'s ACCESS grid over link's 13 species (met by any `access_gradient_max` row); before the new rows it reports CT, DV, GR, KO, RB and WCT with none
- Phase 3: `Fisheries/Fish Passage/passage_limits` is `HJZKI75D`. `0270`: 19 members filed, 6 created (Mount et al. 2011, the 1998 Fish-stream Identification Guidebook, WDFW 2019, Powers and Orsborn 1985, Bell 1986, MacPhee and Watts 1976) and WDFW 2009's PDF uploaded; the guidebook's first create failed on `edition` (not a report field) and went in on the rerun with it in `reportType`; a no-op dry run after. `0275` merged `BUYCVFJG` into `VDT8YQJT` and `9EAU75IL` into `TK4PDDE2` (it refused the first until `0270` had given `VDT8YQJT` its PDF). Zotero was not running; opened, the six keys arrived within a minute. Four uploads answered "exists": each file is held only by its new item (checked by md5), so the server already had the bytes
- Dropped Mesa et al. 2008 (bull trout sprints) and Lauritzen et al. 2010 (kokanee jumping): paywalled, and CrossRef holds no abstract to quote (OpenAlex's are no fallback, CLAUDE.md)
