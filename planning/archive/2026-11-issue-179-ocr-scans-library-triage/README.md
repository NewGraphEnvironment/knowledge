## Outcome

Backlog move 10 (#179) carried all of batch 22 (#217) and the first piece of batch 16 (#13); the rest was split or left
for the next sweep at the gate (Al, 2026-11-21). **#217:** twelve image-only scans in the group library (the ten #217
named, and two HSI models the first `flow` rebuild turned up) were OCRed, replaced in Zotero through `0275`'s `replace`
verdicts, and the five cred-built stores that hold them were rebuilt under cred 0.8.0 / ragnar 0.4.0 and pushed, so
Bjornn & Reiser 1991, Ford et al. 1995 and the rest are searchable for the first time. `peace` keeps its old scan of
Stuart & Chislett 1979, since rebuilding it renames all its documents, which is #14's change. **#13:** the
single-library policy is in `CLAUDE.md`, and `data-raw/zotero_library_triage.py` records, per item of the five
satellite group libraries, whether the central library holds it (by PDF bytes, DOI, title), whether it holds the item's
file, and the verdict on the rest (`research/zotero_libraries.md`). The merges, the personal library and retirement are
#251; #14 waits on NewGraphEnvironment/cred#53 (document identity on parent item, library, version); #16 takes a separate
store for our own prose. What was learned: cred reads `zotero.sqlite` immutable, so after a Zotero write a build sees
nothing of it until Zotero checkpoints its `-wal` (quitting Zotero did it); a `0150` push prints the whole bucket
manifest, whose other entries name other repositories, so a public push log keeps only its own store's entry; and a
CSV that holds both derived values and human decisions needs a column saying which is which, or every re-run guesses
(four review rounds of fixes inside fixes until `decided_by` ended it).

## Measurement

- OCR: 1,453 pages in 21 min (`ocrmypdf --deskew`), 4,817 words (Hartman et al. 1987) to 97,071 (Ford et al. 1995);
  two more scans of 40 and 44 pages, 11,421 and 11,144 words. Every OCR run failed at first because the sandbox kept
  tesseract out of `/tmp`; `TMPDIR` in the session scratchpad fixed it.
- Stores, documents before → after: `habitat_modelling` 404 → 414, `temperature` 53 → 54 (it also gained #194's OCRed
  Metolius scan), `fish_passage` 24 → 25, `bull_trout_grayling` 196 → 197, `flow` 43 → 41 → 43 (the first rebuild
  dropped the two textless HSI scans its October build had kept as empty documents). Each OCRed document has at least
  57 chunks; no old attachment key is left in any store. Rebuilds took 6 min (`fish_passage`) to 52 min
  (`habitat_modelling`).
- Triage of the five satellite libraries: 168 items; 113 present (110 by evidence: 43 by PDF bytes, 27 by DOI, 40 by
  title; 3 by hand), 51 merge, 4 discard. #13's title-only count of 65 unmatched became 57, then 58 once #217's OCR
  replaced a central scan a satellite copy had matched by its bytes, which is how the first review round found the
  stale-verdict defect. 27 present items hold a file the central library has no copy of (code-check round 1 found that
  `present` had been read as "the file is held").
- Code check: five rounds, ended on an enumeration (`review-enumeration.md`, `review-verdict.md`). The branch's history
  was rewritten twice before its first push (a private repository name in the push logs, a host name in early planning
  commits) and all five stores re-pushed so each manifest `head_sha` names a branch commit.

## Evidence

`scripts/logs/rag/20261121_*` (rebuild and push logs); `review-round*.md` in this directory.

## Owed

- cred 0.8.0 installed on every machine that updates stores (the database's host included)
- Al reviews the `discard` verdicts before the new issue carries out any merge or retirement
- A read of one rebuilt store on another machine once its cred is 0.8.0

Closed by: the PR from branch `179-backlog-move-10-report-corpus-one-librar` (closes #13, #217; move 10 of `planning/backlog.md`)
