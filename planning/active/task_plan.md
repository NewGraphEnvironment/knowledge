# Task: White Sturgeon store: gather the recovery documents and Nechako reports into one collection, build it, and push it (#124)

## Problem (issue body)

Measured 2026-10-30 in the local Zotero database:

- Group library `species/sturgeon` holds 3 items, all with a PDF and a Better BibTeX key: the 2019 Fraser River White Sturgeon provincial action framework, the 2020 lower Fraser status report (Challenger et al. 2021) and the 2023 lower Fraser monitoring program summary. All three are about the lower Fraser.
- Other sturgeon items sit in other group collections. `Nechako - NECR` holds Antill et al. 2013, a recruitment biochronology of Nechako White Sturgeon with its PDF, and two NWSRI webpages with no PDF. `eDNA` holds two sturgeon eDNA papers with PDFs (Pfleger et al. 2016, Farrington and Lance 2014).
- A personal-library `fraser/nechako` collection holds Nechako habitat history. Four of its ten items carry a PDF: Helm et al. 1980, Tredger et al. 1984, Albers et al. 2015 on Nechako flooding, and an Upper Fraser Fisheries Conservation Alliance report. `0150` resolves collections in the group library only, so none of them can reach a store.
- The federal documents with the numbered measures are absent: the recovery strategy for the four White Sturgeon populations (Upper Fraser, Nechako, Upper Columbia, Kootenay) and the 2024 action plan. So are the NWSRI recovery plan and technical reports, and the side-channel history the strategy cites (Rood and Neill 1987; Hay and Company Consultants 2000).
- `0150 build` drops an item with no key or no PDF without saying so, so the webpage items add nothing as they stand.

## Context (exploration, 2026-10-31)

White Sturgeon recovery documents and the Nechako White Sturgeon Recovery Initiative (NWSRI) reports should be
searchable in one ragnar store and quotable verbatim, for side-channel and floodplain work on the Nechako and Upper
Fraser. Today `species/sturgeon` (group, `WEUFTSDC`) holds three lower-Fraser documents only. #122 (PR #128, merged)
built the same thing for grayling and bull trout and left the tooling this needs: `0270 --parent`, `0150 build` naming
every member it leaves out, the cred 0.5.0 floor. This branch follows #122's pattern: a members CSV and an additions
CSV drive `0270`, and `0150` builds from the collection.

Exploration moved some premises (immutable read of `zotero.sqlite`, 2026-10-31, so it misses unflushed WAL writes):
- **Helm 1980, Tredger 1984 and Albers 2015 are already in the group** (`Nechako - NECR`, with PDFs and the same keys
  as the personal copies). Only the UFFCA report (`levy_nicklinreportprepared`, personal) is personal-only. It may
  be the same document as the group's `levy_nicklin2018ChinookSockeye`. The personal `nechako` collection also holds
  two standalone PDFs (`Chronology-NFCP.pdf`, `Nechako_Watershed_Strategy-31Oct2016-FINAL.pdf`).
- `farrington_lance2014DevelopmentGenetic` is keyed in the group with a PDF. `eDNA` also holds a standalone copy
  (`PPMDY4K7`, "Ferrington 2014").
- `Nechako - NECR` has more mainstem context than the issue lists: the 1984 Nechako River at Vanderhoof floodplain
  mapping, Macdonald et al. 2007 (discharge, temperature), the NFCP 2023 review and the 2015 watershed health report.
  NWSRI's 2023–24 annual report is keyed (`PH5REA3P`), but it has no PDF.
- The federal set is now the **2023 amended recovery strategy** (it replaces 2014), the **2024 action plan**, the
  2014–2020 progress report and CSAS's 2007 recovery potential assessment.
- NWSRI's Technical Reports page lists **68 items**, about 62 with a PDF. A few are journal articles with no PDF
  there (McAdam et al. 2005 on recruitment and substrate, Smith et al. 2002, French & Chambers 1996/1997) or a thesis
  (Babey). The recovery plan has its own page.
- **#127 is in the path.** Zotero is now WAL. `0270`'s `db()` copies only the main file, and `0150` and cred read
  `immutable=1`, so all three miss writes that have not been checkpointed. Another worktree is on #127 now.

## Decided at the gate (Al, 2026-10-31)

1. **Order:** #128 is merged. #127 is being worked in another worktree, so this branch does not fix it. The work that
   needs no Zotero write or read-back (Phase 1) runs now. The `0270` live run and the build (Phases 2–3) wait for
   #127 to merge, then `git merge origin/main`. #124's body records that as a task.
2. **One collection:** `species/sturgeon` holds the sturgeon literature **plus a curated list of Nechako mainstem
   habitat items**: Helm 1980, Tredger 1984, Albers 2015, the 1984 Vanderhoof floodplain mapping, Macdonald 2007, the
   NFCP 2023 review, and the UFFCA report if it is distinct. The store is built from `WEUFTSDC` alone.
3. **NWSRI breadth:** every technical report on the page that has a PDF, with no topic filter.
4. Store name `sturgeon` (the issue's). Federal set: the 2023 amended strategy, the 2024 action plan, the 2014–2020
   progress report and the 2007 RPA. The 2014 strategy is superseded and stays out. Annual reports stay out beyond
   the 2023–24 one already keyed.

## Phase 1: inventory, PDFs and the two CSVs (no Zotero writes; runs now)
- [x] NWSRI: the recovery plan (2004) and every technical report linked to a PDF. Of 63 links, 61 return `%PDF`
      (168 MB). Triton's "3812 Sturgeon Report Final" is a 404, and the CSAS 2007 link points at a URL DFO moved
- [x] Metadata for each report from its title page or its own "should be cited as" line, not from the page listing,
      which misattributes some (findings)
- [x] Antill 2013 and French 2005 are on the page and already keyed in the group: members, not additions
- [x] CSAS SAR 2007/014 from DFO's library (`328792.pdf`)
- [x] Rood & Neill 1987: no copy of the cited "A study of some aspects of the geomorphology of the Nechako River".
      Added instead DFO's court-action volume 7 (1987), which holds Rood's and Neill's geomorphology expert reports
- [x] Hay & Company 2000 ("Options for passing flows through the Cheslatta Fan", MENV-022) from NEEF's library. The
      copy is a scan, so it is OCRed (`ocrmypdf`) into the ignored `data/rag/pdf/sturgeon/`
- [x] Dedupe every addition by title against the group and personal libraries, trash included (an `immutable` read,
      which never invents rows): no copy exists. The UFFCA personal PDF has the same 77 pages and text as
      `levy_nicklin2018ChinookSockeye`, so that key is the member and `levy_nicklinreportprepared` is never used
      (plan review). `PPMDY4K7` is a second copy of Farrington & Lance 2014: nothing to do
- [x] Personal standalones: the 2016 Nechako Watershed Strategy goes in as `zotero:733T5ZJV`. `Chronology-NFCP.pdf`
      is a one-page timeline with no title page or date: left out, recorded
- [x] `data/sturgeon_members.csv` (15) and `data/sturgeon_additions.csv` (64)
- [x] The federal set: Al downloaded the 2024 action plan (the official PDF). publications.gc.ca served no PDF for
      the amended strategy or the 2014–2020 progress report, even to a browser, so both are printed to PDF from the
      registry's HTML (main content only; the strategy's twelve pages in order), each page's opening and closing text
      checked present in the PDF. The rows name the catalogue numbers and the registry URLs
- [x] McAdam et al. 2005 (DOI row) and Babey 2022 (thesis row), both downloaded by Al. Smith et al. 2002 and French &
      Chambers 1996, 1997 have no PDF: they go to the gap list (decision 3)
- [x] #124's body: corrected premises, and "blocked by #127" as a task in its plan (plan review: now, not Phase 4)

## Phase 2 (after #127 merges): file the collection through `0270`
- [x] `git merge origin/main`. **Hard gate:** `0270`'s `db()` and `0150` read the WAL, and cred's build does too (a
      released fix), or the WAL is confirmed checkpointed (Zotero quit, `-wal` absent or empty) before each read
- [ ] Ask Al to confirm the group's file storage has room for about 200 MB (plan review: a full quota fails each
      upload with 413)
- [x] Re-run the `%PDF` check on every addition URL (a dry run does not fetch them): 70 of 70 `%PDF`, 222.8 MB
- [x] `0270 --collection sturgeon --parent 9U54XAND --dry-run`. Check every `exists` / `copy exists` gkey against the
      intended item before going live (generic titles under one corporate author)
- [ ] Live run, then wait for Zotero to sync. A second dry run with no `would*` lines and exit 0 is the no-op proof.
      (`0153`'s `api` retries a 429/503 after Retry-After since 2026-11-01)
- [ ] A hit on a trashed copy is restored (PATCH `deleted: 0`) and made a member, not created again
- [ ] Re-measure from a WAL-inclusive guarded copy: members, keyed, PDF on disk, BBT keys on the new items. Before
      and after table (live items, items with a PDF, MB uploaded)

## Phase 3 (after Phase 2): build, query, push `sturgeon`
- [ ] cred ≥ 0.5.0 and ragnar 0.3.1 installed (check latest first)
- [ ] `ACTION=build STORE=sturgeon COLLECTIONS=WEUFTSDC`, logged to `scripts/logs/rag/<date>_build_sturgeon.log`, home
      paths written as `~/` and the #56 `local_path` pattern run over the logs by hand (the sweep skips
      `scripts/logs/`). The left-out list must equal the recorded gap. Map every origin to a live group attachment
- [ ] Three `ACTION=query` checks, each with keys it must return in its top 5:
      side-channel loss near Vanderhoof (an NHC geomorphic, sediment or substrate report, or the Rood/Neill volume);
      habitat use at the Fraser–Nechako confluence (a Lheidli T'enneh critical habitat report, or Williamson et al.
      2021); recruitment-failure hypotheses (Antill 2013, Korman & Walters 2001, or an NHC substrate report).
      Record each one's top keys in the build log
- [ ] `ACTION=push` dry run, then `CONFIRM=TRUE`. The push log keeps only this store's manifest entry (#122 round 2)

## Phase 4: docs and issue
- [ ] `scripts/README.md`: the `0150 ACTION=build STORE=sturgeon COLLECTIONS=WEUFTSDC` line beside temperature,
      flow and bull_trout_grayling, and the `0270 --collection sturgeon --parent 9U54XAND` line
- [x] CLAUDE.md layout: `sturgeon_{members,additions}.csv` beside the grayling and bull_trout ones
- [ ] #124 body: the gap of documents with no PDF anywhere, and the outcome
- [ ] Say in `scripts/README.md` that `WEUFTSDC` does not feed the `habitat_modelling` build (plan review)

## Owed at the end (reported, done after merge)

None: the collection, the store and its push all land before the PR.

## Validation

- [ ] Tests pass (`devtools::test()`; no `R/` change expected)
- [ ] `/code-check branch` (three-round floor; ends on an enumeration), plus the #56 `public_sweep.py`
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- The CSVs: each PDF URL's body starts `%PDF`, and each metadata row is read against its title page.
- `0270`: the no-op second dry run.
- The collection: the guarded-copy re-measure (before/after counts in findings).
- The store: its manifest entry (documents, chunks, md5), every origin mapped to a live group attachment, the
  left-out list equal to the recorded gap, and three queries whose top keys are on record.

If #127 has not merged when Phase 1 is done, the branch is pushed and parked with a resume block, and the PR opens
after Phase 4.
