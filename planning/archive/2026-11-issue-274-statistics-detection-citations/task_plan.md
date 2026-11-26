# Task: statistics store: seven cited works of the detection methods that the library does not hold (#274)

**If we do it:** every work the detection models' documentation cites can be searched and read on its page in the
`statistics` store, so a claim about a method is checked against the paper and not against a memory of it. **If we
never do:** seven cited works stay outside the store, three of them read only from copies nothing here holds, and
four not read at all.

## Problem (issue body)

The `statistics/detection` collection (#216) holds the methods literature for occupancy, removal, eDNA, camera
surveys and diversity. A read of the citations that rest on it found seven cited works that are not in the group
library: Morris, White & Crowther 2019 (`10.1002/sim.8086`), Kellner et al. 2023 (`10.1111/2041-210X.14123`),
Taylor 2008 (`10.1016/j.csda.2007.11.003`), Best & Fisher 1979 (`10.2307/2346732`), O'Brien, Kinnaird & Wibisono
2003 (`10.1017/S1367943003003172`), Albert & Anderson 1984 (`10.1093/biomet/71.1.1`) and Seber 1982 (a book). The
issue's table gives what each is cited for and the free copy found for it, if any.

## Context

This is #216's workflow on seven rows, with no code change.

What exploration settled (read-only, 2026-11-24):
- `0270 --collection detection --parent LP4R4VYR` reads `data/detection_{members,additions}.csv` (22 additions rows,
  2 members). A DOI row takes CrossRef metadata plus `override`. `pdf` is a URL (body must start `%PDF`), a repo path
  under the ignored `data/rag/pdf/detection/`, or `none` (needs a CrossRef abstract, else `ABSTRACT-MISSING`). A book
  carries its metadata in the row and goes in without its DOI. It cannot be abstract-only: 0270's non-DOI path sets
  no abstract.
- #216's precedent: a work with neither a PDF nor an abstract is a gap, listed in the issue body and not filed (Al,
  #216 decision 4). A search for free identical copies comes before anything counts as paywalled.
- Requirements: 0270 runs beside the PDFs and a synced Zotero; the build and push need cred 0.8.0, ragnar 0.4.0
  and a real `data/rag/`, and run from a worktree of this branch.
- #223 (Hedger 2013 under ragnar 0.4.0) is closed, so the current bucket `statistics` is the before state.
- cred's open issue on space an update leaves in the file: after a library change the store is rebuilt
  (`ACTION=build OVERWRITE=TRUE`), not updated, before the push. cred reads Zotero immutable: build with Zotero quit
  and a 0-byte `-wal`.

## Decided at the gate

Plan approved by Al, 2026-11-24. The four below are mechanism, decided in the plan:
1. **Same workflow, CSVs and collection as #216.** Seven rows appended to `data/detection_additions.csv`; no new
   collection, so the `0150 STORE=statistics` build list (`LP4R4VYR,73PNRGJF,Z7JP8UN2,K2P7XGFG`) is unchanged.
2. **Version rule as #216:** a version of record wherever one can be had; an accepted manuscript only where none
   can, with `why` saying so (Taylor 2008 would be the collection's third).
3. **Where each step runs:** sourcing and 0270 beside the browser's downloads; build and push wherever the
   requirements above hold, from a worktree of this branch.
4. **No abstract fallback outside CrossRef** (#216's plan): an abstract comes only from CrossRef, so a work with
   neither a PDF nor a CrossRef abstract is a gap, and Seber 1982 (a book) is a PDF or a gap. Withdrawn from the
   approved plan after the Plan review (A1): it also said a closed work with a CrossRef abstract is filed
   abstract-only, but #216's decision 4 made every no-PDF work a gap. That choice is Al's, under Open decisions.

## Settled after the search

- **A no-PDF work with a CrossRef abstract** (file it abstract-only, or list it as the gap): moot (2026-11-24):
  O'Brien et al. 2003, the only closed work with a CrossRef abstract, was found on ResearchGate as the version of
  record. The works still without a PDF (Best & Fisher 1979, Albert & Anderson 1984, Seber 1982) have no CrossRef
  abstract, so by decision 4 each is a PDF or a gap.

## Phase 1: inventory, sources and the CSV rows (no Zotero writes)
- [x] Resolve each of the six DOIs against CrossRef: title, creators, year, and whether it carries an abstract.
      Seber 1982's metadata (publisher, place, edition, ISBN) from a catalogue record (not needed: Seber is the gap)
- [x] Dedupe all seven by DOI and title against every library, trash included, from 0270's guarded WAL-inclusive
      copy. A live group copy becomes a member row; a personal-only copy a member row; a trashed group copy is
      restored (Web API PATCH, Al present) and filed as a member
- [x] Fetch the scriptable copies: Kellner 2023 from Zenodo 11371966; Taylor 2008's accepted manuscript from White
      Rose eprint 3793. Each must start `%PDF`
- [x] Morris 2019 (PMC6492164) and any copy a script cannot fetch: load the Claude in Chrome skill and download in a
      new tab; hand Al the URLs where a click or check is needed
- [x] Search open copies for Best & Fisher 1979, O'Brien et al. 2003, Albert & Anderson 1984 and Seber 1982:
      "<title> pdf", "<title> researchgate", the authors' and institutions' pages, OpenAlex and Semantic Scholar OA
      locations. Record the routes tried per work. Lawful copies only: no unlicensed full-text site is used or
      recorded in a tracked file (review S2; Seber's book is in print)
- [x] Move each browser download into `data/rag/pdf/detection/` (Chrome saves to the folder last used for a save,
      not `~/Downloads`), named `<key-stem>.pdf`, or `<key-stem>_accepted.pdf` for a manuscript (review G3, O2)
- [x] Check every copy against the published version (title page, pagination, abstract wording); a manuscript's
      `why` says it is one
- [x] OCR any scan whose pages have no text layer (`ocrmypdf` into `data/rag/ocr/detection/`) (none needed)
- [x] Put the Open decision to Al with the search's result (moot: see Open decisions)
- [x] Append the rows (append only; each `why` opens `#274` and names what it is cited for), with `override` where
      CrossRef disagrees with the title page (Albert & Anderson's creators are in capitals). Abstract-only rows only
      as Al decides, and only where CrossRef has the abstract. If Seber is filed, extend the header with
      `publisher,edition,ISBN` as `statistics_additions.csv` has them, existing rows unchanged (review B1).
      Enumerate every new row in `planning/active/enumeration_round0.tsv` against its title page, comparing what
      0270 files (CrossRef's title after `plain()`, review G5). No other library's name or key in any tracked file
      (review P1)
- [x] Record in findings: per work, the route that gave it, version, MB, or abstract-only or gap

## Phase 2: file under `statistics/detection` through 0270 (Al present for the live run)
- [x] Every PDF opens as `%PDF` in `data/rag/pdf/detection/` before the first dry run. This and the CrossRef abstract
      check are the only gates on a new row: the dry run returns before 0270's PDF and abstract steps for a new item
      (review G2)
- [x] Measure the four collections (`LP4R4VYR`, `73PNRGJF`, `Z7JP8UN2`, `K2P7XGFG`) from a guarded copy: items,
      keyed, PDF on disk. The before state (review G4)
- [x] `0270 --collection detection --parent LP4R4VYR --dry-run`: check each `exists` / `copy exists` hit; only the
      new rows produce `would` lines
- [x] Live run; wait for the sync; a second dry run with 0 `would` lines and exit 0. Logs to
      `scripts/logs/rag/<date>_0270_detection*.log`, home paths written as `~/` (review P1)
- [x] Re-measure the four collections: the after state

## Phase 3: rebuild and push `statistics` (a worktree of this branch)
- [x] Push the branch; make a worktree of it with a real `data/rag/` (not a symlink:
      `git -C <wt>/data/rag rev-parse --abbrev-ref HEAD` names this branch, review X4); pull the bucket `statistics`
      (verified connect) and measure documents and chunks with duckdb: the before state
- [x] Three `ACTION=query` checks, expected hits written first as author and year (keys exist only after the sync),
      run on the pulled store before the build and again after it (review X1, X2): simulation-study bias, coverage
      and Monte Carlo error (Morris et al. 2019); a von Mises kernel density with a plug-in bandwidth for circular
      data (Taylor 2008; Ridout & Linkie 2009 and Rowcliffe et al. 2014, which apply it, count as acceptable hits);
      fitting occupancy and abundance models in the unmarked package (Kellner et al. 2023). Report the top 5; a
      miss is reported, not tuned away
- [x] Write the expected outcome in the log before the build: documents expected (before + new PDFs, given the
      other three collections' membership measured in Phase 2), the left-out list (no-PDF items of the four
      collections, any abstract-only rows)
- [x] Gate: Zotero synced, every PDF of the four collections on disk, Zotero quit, a 0-byte `-wal` (review G1).
      `0150 ACTION=build OVERWRITE=TRUE STORE=statistics COLLECTIONS="LP4R4VYR,73PNRGJF,Z7JP8UN2,K2P7XGFG"`,
      logged with home paths as `~/`. Check left-out = expected, documents = keys minus no-text PDFs, the dropped
      list read and explained, every origin a live group attachment
- [x] Commit CSV and logs and push the branch before the store push (manifest records the head sha)
- [x] `ACTION=push` dry run, then `CONFIRM=TRUE` (Al present). Read the result before any verified connect; check
      the multipart ETag against the file. Commit the trimmed push log

## Phase 4: docs and issue
- [x] `scripts/README.md`'s statistics line: revise only if what it says the collection holds changes (Seber's book
      joining, say)
- [x] #274's body: the outcome per work (filed with PDF and from where, abstract-only, gap), and that an
      abstract-only work is in the library but not in the store (review S1)

A PDF Al later supplies for a gap or abstract-only work joins at a future rebuild, noted in the body rather than
owed.

## Validation

- [ ] Tests pass (`devtools::test()`; no `R/` change; `test-data-dir.R` covers `data/`)
      (2026-11-25: 466 tests, 0 failed, 1 error, `test-link_flow.R:67`, raised by the database server, not by R
      code; reported to Al; left unticked)
- [x] `/code-check branch` (three-round floor, ending on a re-check of `enumeration_round0.tsv` against the filed
      items, review X3) and the #56 `public_sweep.py` over the branch
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- **Rows:** each DOI resolved against CrossRef and matched to its title page (`enumeration_round0.tsv`).
- **Filing:** the no-op second dry run, and the before/after re-measure.
- **Store:** left-out and dropped lists against the expectations written first; the query checks; the push's ETag
  against the file.
