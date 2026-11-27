# Progress — Coho store: grow species/coho, build and push it, and judge the upper Fraser coho records with it (#284)

## Session 2026-11-26

- Plan-mode exploration — phases approved by user
- Created branch `284-coho-store-grow-species-coho-build-and-p` off origin/main
- Scaffolded PWF baseline from issue #284 with approved phases
- Next: start Phase 1

## Phase 1, 2026-11-27
- Completed: plan review folded in (`review-284.md`); `data-raw/coho_upper_fraser_records.R` and its log
  (`scripts/logs/coho/20261127_coho_upper_fraser_records.*`): 24 bcfishobs records in 10 groups upstream of the
  Quesnel's mouth, one FDIS visit, five NuSEDS populations; the 2004 entries trace to the 2004 consultative draft
  recovery strategy; the 2018 FRAN collections are outside the electrofishing extract
- Commits: b37a32c9 (plan review), this one
- Next: Phase 2: the core literature and the Interior Fraser series (several PDFs already fetched to the scratchpad:
  Sandercock 1991, Decker & Irvine 2013, the 2019 RPA with its research document and proceedings, the 2014 SAR and
  research document, the 2013 proceedings, Bustard & Narver 1975, Solazzi et al. 2000, Peterson 1982 population
  characteristics)

## Phase 2, 2026-11-27
- Completed: core-literature inventory; `data/coho_members.csv` (40) and `data/coho_additions.csv` (21: 19 with a PDF,
  23.8 MB; 2 abstract only); COSEWIC 2002 and the 2026 SARA scenarios page printed from the registry into the ignored
  `data/rag/pdf/coho/`; dedupe moved Burnett et al. 2007 and the Westworth inventory to members; gap list in findings;
  #284's body carries the decisions and the corrected premises
- Next: Phase 3 needs Al: his downloads for the gap list (optional), then the live `0270` run (Web API writes)

## Phase 3, 2026-11-27
- Completed: live `0270` run and its retry (one 500); the no-op dry run; `49HFCT96` found to hold the same Sandercock
  scan and trashed; `ZPUIT73I` now 61 live, 61 keyed, 55 with a PDF; cred 0.8.1 (cred#48's fix) installed
- Next: Phase 4: build `coho` with Zotero quit, then update `habitat_modelling`

## Phase 4, 2026-11-27
- Completed: `coho` built (53 documents), queried (4 with expectations first) and pushed; `habitat_modelling` updated
  in place with `ZPUIT73I` on cred 0.8.1 (49 added, 0 dropped, 0 free blocks) and pushed; both ETags matched; `0150`
  needs cred >= 0.8.1 for an update and the rebuild-after-update rule is gone; #286 filed for `0270`'s failed upload
- Commits: 57c458bd and this one
- Next: Phase 5, the judgement of each record and `research/coho_upper_fraser.md`

## Phases 5 and 6, 2026-11-27
- Completed: `research/coho_upper_fraser.md` (30 verdicts, 5 quotes checked by `0280`, now in `QUOTED_DEFAULT`); NOTICE
  rows for the Province's observations and the coho log; `scripts/README.md`, `CLAUDE.md` and `research/README.md`
  entries; #285's body carries the PSF task; #287 filed; #284's body carries the outcome
- Next: tests, `/code-check branch`, archive, PR

## Validation, 2026-11-27
- Tests: `devtools::test()`, 466 blocks, 0 failed, 3 skipped
- `/code-check branch`: round 1 six findings (a dropped side-channel record, private repo names in two push logs before
  any push, text), round 2 two (NAZR outside link's range, a Gaps count), round 3 three, one inside round 2's fix (the
  In brief survey count), plus a stale `why` and an unestablished cause; ended on an enumeration
  (`review-enumeration.md`) deriving every summary from the records table
