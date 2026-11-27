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
