# Progress — White Sturgeon store (#124)

## Session 2026-10-31

- Plan-mode exploration; phases approved by Al with three gate decisions (order behind #127, one curated collection,
  every NWSRI report with a PDF)
- Created branch `124-white-sturgeon-store-gather-the-recovery` off origin/main (`9e10a19`, after #128's merge)
- Scaffolded PWF baseline from issue #124 with approved phases
- Next: start Phase 1 (no Zotero writes); Plan review runs concurrently
- Baseline `9c10882`. Plan review ran concurrently (`review-plan.md`); its two blockers were confirmed and folded in
- Phase 1: 61 NWSRI PDFs, the recovery plan, CSAS 2007/014, DFO's 1987 geomorphology volume and Hay & Co 2000
  (OCRed) gathered. `data/sturgeon_members.csv` (15, every key one live group item) and
  `data/sturgeon_additions.csv` (64). #124's body corrected, with "blocked by #127" in its plan
- Al's downloads (the action plan, McAdam 2005, Babey 2022) and two registry-HTML prints added: 69 additions. Waiting on #127 only
- Next: parked 2026-10-31 on #127; paste the block under ### Resume into a fresh session

### Resume

```
Continue knowledge#124 from its parked PWF baseline. Repo ~/Projects/repo/knowledge, branch `124-white-sturgeon-store-gather-the-recovery`,
parked 2026-10-31 after Phase 1, waiting on #127, branched from origin/main at 9e10a19.
Run these in order, and stop at the first that fails; each failure means what it says:

cd ~/Projects/repo/knowledge && git fetch -q origin
git worktree list | grep -F '[124-white-sturgeon-store-gather-the-recovery]' || echo none   # a path printed: that tree holds the branch; cd to it and skip the checkout
git branch --show-current; git status --porcelain --untracked-files=no   # another branch with changes, or one another session may be on: do not check out here; git worktree add ../knowledge-124 124-white-sturgeon-store-gather-the-recovery and cd there
git checkout 124-white-sturgeon-store-gather-the-recovery   # fails: the branch is not on origin
git pull --ff-only   # fails: this machine has commits origin lacks; resume where they were made
git merge origin/main   # a conflict: main moved meanwhile; resolve it, commit, and go on

Then read planning/active/task_plan.md, findings.md, progress.md and review-plan.md if present.
The gate decisions, the measurements and the Plan-agent review are already folded in:
do not re-plan and do not re-ask them.
Phase 1 is done. Its local PDFs sit in data/rag/pdf/sturgeon/ (git-ignored) in ~/Projects/repo/knowledge: run 0270 there, or copy them.
Phases 2-3 start only once #127 has merged and the Phase 2 gate holds; if it has not merged, stop and say so.
Otherwise run every phase to the PR (/code-check branch, /planning-archive,
/gh-pr-push). This message is the resume instruction that starts the run-to-PR
mandate; the merge stays with me.
```

## Session 2026-11-01

- #127 merged (PR #129); `git merge origin/main` (8a12013). `0270`'s `db()` and `0150`'s `collection_keys()` now
  copy the `-wal`; cred still reads immutable (cred#45 open), so the Phase 3 build runs with Zotero quit and the
  `-wal` absent or empty.
- First dry run: 25 of 69 addition lookups failed with 429 (`0153`'s `api` had no retry). Added a 429/503 retry on
  Retry-After and a Backoff pause to `api`; second dry run exit 0: the collection exists, 3 members, 12 would add
  (one with an upload, PH5REA3P), 69 would create, no `exists`/`copy exists` line.
- `%PDF` check: 70 of 70 sources (URLs, paths, `zotero:`) are PDFs, 222.8 MB.
- Next: Al confirms the group's storage has room for ~223 MB, then the live run.

## Session 2026-11-04 (UTC 2026-11-05)

- Synced: `git merge origin/main` (4c34c33, 128 commits, no conflict; none touch `0150`, `0153`, `0270` or the
  sturgeon CSVs). The Zotero key moved to `~/.config/newgraph/`; storage is unlimited (Al).
- Phase 4's `scripts/README.md` lines (ecfbc50).
- Live `0270` (04:57–05:07 UTC): exit 0, added 12, created 69, 84 members; 43 PDFs uploaded, 27 `exists` (the
  server already held a file with that md5), 14 present. Second dry run exit 0, no `would` line: the no-op proof.
- Re-measure from a WAL-inclusive guarded copy: 84 live items, 84 keyed, 84 with a PDF on disk (319.0 MB). Two
  trashed 2024 entries (`J7V2YWA7`, an older Challenger 2021 copy, and its `.bib` attachment) sit in the
  collection, as before this branch; the build skips them.
- md5 check of every member's PDF against every other attachment: Helm 1980, Tredger 1984 and Albers 2015 match
  their personal-library copies (expected); NFCP 2023 matches a trashed group standalone; the 2016 watershed
  strategy (`B2UZ32FE`) matches the personal standalone it came from and a live group standalone, `VS4P4TG6`
  (2023, in `Nechako - NECR`, no parent, so Phase 1's title dedupe could not see it). A merge (add `B2UZ32FE` to
  `Nechako - NECR`, `dc:replaces`, trash `VS4P4TG6`) was refused by auto mode as an external write: left for Al.
- cred upgraded 0.5.0 -> 0.7.0 (0.6.0: one unreadable PDF or refused chunk no longer loses the build).
- Next: Zotero quit (cred#45: cred reads immutable and the `-wal` held 1.5 MB after the run), then the build.

## Session 2026-11-05

- Zotero quit; `-wal` 0 bytes, so cred's immutable read saw every write (cred#45 gate).
- Build (07:10–07:19 UTC, cred 0.7.0, ragnar 0.3.1): 84 keys, no member left out for want of a PDF; 83
  documents, 10,964 chunks, nomic-embed-text, 151.5 MB, md5 `7c8359e5…`. Log
  `scripts/logs/rag/20261105_build_sturgeon.log`, home paths as `~/`.
- Skipped: Tredger et al. 1984 (`AHE9BFQQ`), a 49-page DigiPath scan with no text layer. `ocrmypdf --deskew` gives
  7,531 readable words (`data/rag/pdf/sturgeon/tredger1984_nechako_reconnaissance_ocr.pdf`, ignored). Getting it in
  needs the OCR copy attached to the group item (a Web API write, left for Al), then `crd_store_update()` and a push.
- The 1984 Vanderhoof floodplain map read through pdftools: 2 chunks (a map sheet, little text).
- Every one of the 83 origins maps to one live group attachment of a live `WEUFTSDC` member.
- Queries (top keys in the log):
  - side channels near Vanderhoof: Rood & Neill 1987 (×4) and three NHC reports. **Pass.**
  - Fraser–Nechako confluence: Triton 2010, Liebe 2007, DFO 2023, RLL 2000. **Miss** against the keys fixed in
    advance (a Lheidli T'enneh critical-habitat report or Williamson et al. 2021). All three are in the store; the
    confluence is named in many reports (`nechako%confluence` hits 46 chunks of the 2007 database summary, 45 of
    the DFO strategy, none of the Lheidli reports in the top eight), so the expectation was a guess about ranking.
  - recruitment failure: Korman & Walters 2001, McAdam 2005, the 2004 recovery plan. **Pass.**
