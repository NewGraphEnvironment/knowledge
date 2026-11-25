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
- Machines: the browser runs on one machine, so its downloads land there; store builds and pushes run on the machine
  that holds `data/rag/` with cred 0.8.0 and ragnar 0.4.0, from a worktree of this branch. The machine this plan was
  made on has cred 0.7.0 and no `data/rag/`, so 0270 runs here, beside the PDFs, against its synced Zotero.
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
3. **Machines:** sourcing and 0270 where the browser runs; build and push on the store-build machine from a
   worktree of this branch. Upgrading cred on the browser machine is #217's, not this issue's.
4. **No abstract fallback outside CrossRef** (#216 decision 4): a closed article with no free copy is filed
   abstract-only when CrossRef holds its abstract, otherwise listed as the gap. Seber 1982 is a PDF or a gap.

## Phase 1: inventory, sources and the CSV rows (no Zotero writes)
- [ ] Resolve each of the six DOIs against CrossRef: title, creators, year, and whether it carries an abstract.
      Seber 1982's metadata (publisher, place, edition, ISBN) from a catalogue record
- [ ] Dedupe all seven by DOI and title against every library, trash included, from 0270's guarded WAL-inclusive
      copy. A live group copy becomes a member row; a personal-only copy a member row; a trashed group copy is
      restored (Web API PATCH, Al present) and filed as a member
- [ ] Fetch the scriptable copies: Kellner 2023 from Zenodo 11371966; Taylor 2008's accepted manuscript from White
      Rose eprint 3793. Each must start `%PDF`
- [ ] Morris 2019 (PMC6492164) and any copy a script cannot fetch: load the Claude in Chrome skill and download in a
      new tab; hand Al the URLs where a click or check is needed
- [ ] Search open copies for Best & Fisher 1979, O'Brien et al. 2003, Albert & Anderson 1984 and Seber 1982:
      "<title> pdf", "<title> researchgate", the authors' and institutions' pages, OpenAlex and Semantic Scholar OA
      locations. Record the routes tried per work
- [ ] Check every copy against the published version (title page, pagination, abstract wording); a manuscript's
      `why` says it is one
- [ ] OCR any scan whose pages have no text layer (`ocrmypdf` into `data/rag/ocr/detection/`)
- [ ] Append the rows (append only; each `why` opens `#274` and names what it is cited for), with `override` where
      CrossRef disagrees with the title page. Abstract-only rows only where CrossRef has the abstract. Enumerate
      every new row against its record or title page in `planning/active/enumeration_round0.tsv`
- [ ] Record in findings: per work, the route that gave it, version, MB, or abstract-only or gap

## Phase 2: file under `statistics/detection` through 0270 (Al present for the live run)
- [ ] Every PDF opens as `%PDF` in `data/rag/pdf/detection/` before the first dry run
- [ ] `0270 --collection detection --parent LP4R4VYR --dry-run`: check each `exists` / `copy exists` hit; only the
      new rows produce `would` lines
- [ ] Live run; wait for the sync; a second dry run with 0 `would` lines and exit 0. Logs to
      `scripts/logs/rag/<date>_0270_detection*.log`
- [ ] Re-measure from a guarded copy: detection items, keyed, PDF on disk, before and after

## Phase 3: rebuild and push `statistics` (store-build machine, worktree of this branch)
- [ ] Push the branch; on the store-build machine make a worktree of it with a real `data/rag/`; pull the bucket
      `statistics` (verified connect) and measure documents and chunks with duckdb: the before state
- [ ] Write the expected outcome in the log before the build: documents expected (before + new PDFs), the left-out
      list (no-PDF items of the four collections, any abstract-only rows)
- [ ] Gate: Zotero synced, then quit, with a 0-byte `-wal`. `0150 ACTION=build OVERWRITE=TRUE STORE=statistics
      COLLECTIONS="LP4R4VYR,73PNRGJF,Z7JP8UN2,K2P7XGFG"`. Check left-out = expected, documents = keys minus no-text
      PDFs, the dropped list read and explained, every origin a live group attachment
- [ ] Two `ACTION=query` checks with their expected keys written first: simulation-study bias and coverage (Morris
      2019); circular kernel bandwidth for activity patterns (Taylor 2008). Report the top 5; a miss is reported,
      not tuned away
- [ ] Commit CSV and logs and push the branch before the store push (manifest records the head sha)
- [ ] `ACTION=push` dry run, then `CONFIRM=TRUE` (Al present). Read the result before any verified connect; check
      the multipart ETag against the file. Commit the trimmed push log

## Phase 4: docs and issue
- [ ] `scripts/README.md`'s statistics line: revise only if what it says the collection holds changes (Seber's book
      joining, say)
- [ ] #274's body: the outcome per work (filed with PDF and from where, abstract-only, gap)

A PDF Al later supplies for a gap or abstract-only work joins at a future rebuild, noted in the body rather than
owed.

## Validation

- [ ] Tests pass (`devtools::test()`; no `R/` change; `test-data-dir.R` covers `data/`)
- [ ] `/code-check branch` (three-round floor) and the #56 `public_sweep.py` over the branch
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- **Rows:** each DOI resolved against CrossRef and matched to its title page (`enumeration_round0.tsv`).
- **Filing:** the no-op second dry run, and the before/after re-measure.
- **Store:** left-out and dropped lists against the expectations written first; the query checks; the push's ETag
  against the file.
