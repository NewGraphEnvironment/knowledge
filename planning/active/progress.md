# Progress — Bull trout: build a store, research its life history, and find the datasets (#194)

## Session 2026-11-12

- Plan-mode exploration; Al approved the phases and four gate decisions (split, store shape, habitat_modelling,
  breadth)
- Created branch `194-bull-trout-build-a-store-research-its-li` off origin/main (89ee4d3a)
- Scaffolded the PWF baseline from issue #194 with the approved phases
- Next: Phase 0, splitting the issue
- Phase 0: filed #198 (life history) and #199 (datasets); rewrote #194's body (corrected premise, split, decided
  breadth and store shape). Plan review spawned in the background at 07:18Z
- Plan review back (~07:25Z): 13 findings, 3 verified by probe, all folded in (`review-plan.md`)
- Browser downloads (16:45–18:05 UTC): 49 files through Claude in Chrome and Al's hand saves, COSEWIC 2025 and seven
  registry and CDC pages printed to PDF; three EcoCat reports restricted, owed to an access-request issue
- Next: OCR the two partly scanned files, then draft rows from the title pages
- `data/bull_trout_members.csv`: 14 group items appended; the three web-page members get the printed registry and CDC
  pages (their URLs are 1202-869, elcode AFCHA05020 and AFCHA05122, read from a guarded copy), McMahon 2007 the
  montana.edu author copy. Metolius 1996 still has none
- Three drafting agents spawned at 18:05Z (EcoCat ×2, browser), title pages only, into scratchpad `draft/`
  (seven agents on this issue in all)
- Drafts back (18:10–18:13Z); merged, deduped (fuzzy and by bytes), 146 additions written with their PDFs staged in the
  ignored `data/rag/pdf/bull_trout/`; round-0 enumeration (789 checks, two fixes). Next: Metolius to #209, then the
  Phase 2 gate (URLs rechecked, dry run)
- Metolius 1996 added to #209. Dry run 1 (`scripts/logs/rag/20261112_0270_bull_trout_dryrun1.log`, exit 0): 16 members
  in place, 14 to add, 4 member PDFs to upload, 1 without (Metolius), 146 additions to create, no `exists` or `copy
  exists` hit. Fraley & Shepard's item JSON checked (G2); a `pages` column added for its 133-143
- Meaning audit round 1 folded in (144 additions); dry run 2 exit 0, 162 would. Next: the live run, with Al


## Session 2026-11-13

- Al said go (2026-11-12). PDF sources rechecked: 3 URLs and 147 local files start `%PDF`; the one missing path
  (`post_etal2012`) is a member whose item already holds its PDF
- Live run 05:47Z stopped with its session after 117 creates; the 65 `exists` uploads traced to their own new items
- Hammond 2004's `CREATE-FAIL` fixed (`document` to `report`); all rows' fields checked against Zotero's schema
- Dry run before resuming (118 exists, 27 to do); two re-runs finished it; the empty Sheep Creek attachment trashed
- No-op dry run 3c exit 0; collection audited through the Web API; re-measured 174 / 174 / 172
- Next: Phase 3 once Baxter 2002's attachment has synced and Zotero is quit
