# Progress — Westslope cutthroat store (#190)

## Session 2026-11-10

- Plan-mode exploration — phases approved by user (breadth: named series, Al)
- Created branch `190-westslope-cutthroat-store-gather-the-man` off origin/main
- Scaffolded PWF baseline from issue #190 with approved phases
- Next: start Phase 1

## Session 2026-11-10 (continued, 2026-11-11 UTC)

- Re-measured `TIDR3PNN` from a guarded copy: 30 / 30 keyed / 9 PDF, unchanged (findings)
- Plan review (Plan agent) and three search agents spawned at 00:49 and 00:51 UTC: members' PDFs; federal,
  provincial and EDF Elk Valley; the Upper Fording, Elk River Alliance and FWCP series. Results land in the scratchpad
  and are verified here before any row is written
- Plan review back (`review-plan.md`); its three data claims checked against the database (two confirmed and taken,
  one confirmed and not used: the ERA PDF comes from the item's own URL). Folded into Phases 1–3
- All three search agents back and verified; `data/westslope_cutthroat_additions.csv` (32) and the members CSV (36)
  committed; every PDF fetched through `0153`'s `fetch`. #190's body carries the corrected premises
- Waiting on Al: 11 hand downloads, and whether to keep the Evaluation of Cause set (20 rows, 417 MB) and add the
  Harmer and Grave Creek series. Phase 2's live run and the pushes need Al present
- Al (2026-11-11): keep the Upper Fording Evaluation of Cause set; add the Harmer Creek Evaluation of Cause, Grave and
  Harmer monitoring and calcite series (17 rows). Seven filed PDFs OCRed where pages had no text. 49 additions
- `0270` dry run 1 (`scripts/logs/rag/20261111_0270_westslope_cutthroat_dryrun1.log`): exit 0; collection exists;
  36 members resolve (30 member, 6 would add), 9 would upload, 12 no-pdf (Al's 11 and Hagen & Baxter), 49 would create,
  no `exists` hit to check
- Next: Al's 11 downloads, then dry run 2 and the live run with Al present

## Session 2026-11-11 UTC (live run)

- Al ran the live `0270` (`scripts/logs/rag/20261111_0270_westslope_cutthroat_live.log`, 04:00–04:16 UTC): 49
  created, 6 added, 58 PDFs uploaded or registered, 12 no-pdf, no failure line. Web API read-back: 85 top items in
  `TIDR3PNN`, no duplicate title and date; the 10 other group items filed that day are outside the collection (another
  session's); each of the 58 has one PDF attachment carrying an md5
- Dry run 2 (`scripts/logs/rag/20261111_0270_westslope_cutthroat_dryrun2.log`): exit 0, no `would` line, every
  addition `exists`: the no-op proof
- Guarded-copy re-measure after sync: 85 live, 85 keyed, 73 with a PDF on disk (findings, before/after table)
- Next: Al's 11 hand downloads (then set their `pdf` and re-run `0270`), or build now with the 12 as the gap

## Session 2026-11-11 UTC (build, queries, push)

- Al asked: cred updates a store in place since cred 0.7.0 (cred#44 closed 2026-10-31); CLAUDE.md's Zotero paragraph
  still said otherwise and was corrected (5d6b0979). So the build went ahead with the 12 as the gap, and the hand
  downloads moved to #191 (download, `0270` live, `0150 ACTION=update`, push; and `habitat_modelling` for Muhlfeld 2012
  and D'Angelo 2011). #190's body points to it
- Zotero quit by osascript, `-wal` 0 bytes. Build 04:35–04:46 UTC: 73 documents, 17,700 chunks, 232 MB; left out the
  12 without a PDF, exactly the recorded gap; no no-text PDF (Schwarz et al. 2013 and the OCRed Evaluation of Cause
  synthesis were read by pdftools). All 73 origins are live attachments of 73 live members
- Queries (expectations written first, `scripts/logs/rag/20261111_query_westslope_cutthroat.log`): thermal limits and
  Elk restoration hit; hybridization and EDF monitoring partial (Muhlfeld et al. 2016 and KNC's newsletter outside the
  top results). Reported, not tuned
- Push (CONFIRM=TRUE, 04:48 UTC): exit 0; bucket object 243,019,776 bytes, its multipart ETag recomputed from the local
  file (8 MiB parts, 29) matches; manifest entry md5 de28293c… = local md5, 73 documents, 17,700 chunks
