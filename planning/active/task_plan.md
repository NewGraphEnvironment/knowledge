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
- [ ] Federal documents: find each PDF (SAR registry, publications.gc.ca, DFO library). #122 found that
      publications.gc.ca answers a scripted request with 202/HTML, so a PDF only a browser can fetch goes to Al, is
      saved under the ignored `data/rag/pdf/`, and its row takes that path
- [ ] NWSRI: the recovery plan, plus every technical report with a PDF (curl, check the body starts `%PDF`). For each
      journal-article row with no PDF there (McAdam 2005 and the others), add it by DOI through CrossRef with an OA
      PDF where Unpaywall has one, otherwise `pdf = none`, listed in findings. Antill 2013 is already keyed: no duplicate
- [ ] Rood & Neill 1987 and Hay & Company 2000: search ACAT/EcoCat, NWSRI and the DFO library. Record each find or
      miss and why
- [ ] Dedupe every addition against the group by title and DOI, trashed copies included (CLAUDE.md's
      duplicate-item note). The UFFCA personal PDF against `levy_nicklin2018ChinookSockeye`'s, and Ferrington
      `PPMDY4K7` against `farrington_lance2014`'s, by md5
- [ ] Personal standalones `Chronology-NFCP.pdf` and the 2016 Nechako Watershed Strategy: additions rows with
      metadata from their title pages, the PDF copied to `data/rag/pdf/`
- [ ] `data/sturgeon_members.csv`: the three current members, Antill 2013, Pfleger 2016, Farrington & Lance 2014, the
      curated Nechako items (decision 2), and `PH5REA3P` with its PDF URL. Each row gives `source` as `#124: <why>`
- [ ] `data/sturgeon_additions.csv`: one row per new work, with metadata from the page and checked against the title
      page (authors, year, institution, report number), `pdf` as a URL, path, `zotero:` or `none`, and `why`. No
      `pdf` URL may return HTML

## Phase 2 (after #127 merges): file the collection through `0270`
- [ ] `git merge origin/main`. Confirm `0270`'s `db()` and `0150` read the WAL (or follow whatever #127 settled for
      cred)
- [ ] `0270 --collection sturgeon --parent 9U54XAND --dry-run`. Check every `exists` / `copy exists` gkey against the
      intended item before going live
- [ ] Live run, then wait for Zotero to sync. A second dry run with no `would*` lines and exit 0 is the no-op proof
- [ ] Re-measure from a WAL-inclusive guarded copy: members, keyed, PDF on disk, and BBT keys on the new items. Merge
      any duplicate the dry run exposes through the Web API (CLAUDE.md recipe)

## Phase 3 (after Phase 2): build, query, push `sturgeon`
- [ ] cred ≥ 0.5.0 and ragnar 0.3.1 installed (check latest first)
- [ ] `ACTION=build STORE=sturgeon COLLECTIONS=WEUFTSDC`, logged to `scripts/logs/rag/<date>_build_sturgeon.log`. The
      left-out list must equal Phase 1's no-PDF list. Map every document origin to a live group attachment
- [ ] Three `ACTION=query` checks: side-channel loss near Vanderhoof; habitat use at the Fraser–Nechako confluence;
      recruitment-failure hypotheses. Record each one's top citation keys in the build log
- [ ] `ACTION=push` dry run, then `CONFIRM=TRUE`. The push log keeps only this store's manifest entry (#122 round 2)

## Phase 4: docs and issue
- [ ] `scripts/README.md`: the `0150 ACTION=build STORE=sturgeon COLLECTIONS=WEUFTSDC` line beside temperature,
      flow and bull_trout_grayling, and the `0270 --collection sturgeon --parent 9U54XAND` line
- [ ] CLAUDE.md layout: `sturgeon_{members,additions}.csv` beside the grayling and bull_trout ones
- [ ] #124 body: correct the premises above, put "blocked by #127" in the plan as a task, and list the gap of
      documents with no PDF anywhere

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
