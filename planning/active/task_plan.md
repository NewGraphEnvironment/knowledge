# Task: statistics store: the methods literature for detection and occupancy (#216)

**If we do it:** occupancy, detection and removal methods can be searched and cited from their sources in the same store as the Bayesian texts. **If we never do:** each analysis re-finds them, and cites what it remembers.

## Problem (issue body)

The `statistics` store (`data/rag/statistics.duckdb`) holds four general texts: McElreath 2020, BDA3, Hill 2025, and Toffolon & Piccolroaz 2015. It has nothing on imperfect detection, the base of any survey that can miss what is there.

## Context

The `statistics` store (built from top-level collection `LP4R4VYR` alone) holds general Bayesian texts and
nothing on imperfect detection. The issue asks to acquire 30 works (31 counting the two AHM volumes) (occupancy, removal, eDNA, camera,
diversity, plus the indented items added 2026-11-15), file them under `statistics/detection`, and rebuild
`statistics` with its whole build list. This follows #190/#194 step for step: a members CSV and an additions CSV
drive `0270`, and `0150` builds the store.

What exploration settled (read-only, 2026-11-16):
- `0270 --collection detection --parent LP4R4VYR` creates `statistics/detection` and reads
  `data/detection_members.csv` (required, even with few rows) and `data/detection_additions.csv`. No code change
  is expected.
- An additions row with `pdf = none` must carry a DOI whose CrossRef record has an abstract. Otherwise 0270 exits
  with `ABSTRACT-MISSING`, because it takes abstracts from CrossRef only. Old JSTOR papers such as Zippin 1958 and
  Moran 1951 may have no CrossRef abstract, which is why Phase 1 checks OpenAlex as a fallback.
- The group already holds MacKenzie & Royle 2005 (`CC22PHBQ`) and Guillera-Arroita et al. 2010 (`BC9RR2NP`), both
  with no PDF, filed on 2026-11-12 in `statistics/survey_design` (`Z7JP8UN2`). They become member rows. No other
  named author's work turned up in any library, but Phase 1 re-checks by DOI and title, trash included.
- `statistics` already has two subcollections that are in no store: `survey_design` (11 items, no PDFs; camera and
  occupancy design, filed by other work) and `model_selection` (`K2P7XGFG`; 5 items, 4 PDFs: ESL and the
  cross-validation papers).
- cred 0.7.0 is the newest tag, and ragnar is 0.3.1. Two cred issues are open:
  - cred#48: an update leaves freed space in the file, so the store is rebuilt before its push.
  - cred#45: cred reads Zotero `immutable`, so the build runs with Zotero quit and its `-wal` checkpointed.
- `model_selection` crashed a build before (ESL oversize chunk, Bates NUL byte, #79): cred#35 was closed
  2026-10-31, before cred 0.7.0.
- The two members' keys: `mackenzie_royle2005Designingoccupancy` (CC22PHBQ) and
  `guillera-arroita_etal2010Designoccupancy` (BC9RR2NP).
- This worktree has no local `statistics.duckdb`. The bucket copy is pulled first and is the before state.
- Web API writes and the S3 push need Al present: auto mode refused such writes before.

## Decided at the gate (Al, 2026-11-16)

1. **Build list: the whole statistics tree.** `COLLECTIONS="LP4R4VYR,<detection>,Z7JP8UN2,K2P7XGFG"`. A later
   subcollection under statistics joins the list when it appears.
2. Collection `statistics/detection`; CSVs `data/detection_{members,additions}.csv` (0270's name = prefix rule).
3. **(Al, 2026-11-16, revising the issue's "noted, not chased")** Before a work counts as paywalled, look for a
   free copy with the same text: "<title> pdf", "<title> researchgate", the authors' and institutions' pages, and
   the open-access locations OpenAlex and Semantic Scholar list. Fetch ResearchGate and other script-blocked pages
   through the Claude in Chrome skill, or hand Al the URLs to click. Where no full text can be had and an abstract
   is usable, file the work abstract-only. Only a work with neither is a gap.

4. **(Al, 2026-11-16, after the search)** The 7 works with no PDF (Zippin 1958, Carle & Strub 1978, Moran 1951,
   Riley & Fausch 1992, MacKenzie et al. 2018, Kéry & Royle 2016 and 2021) are the gap: listed in #216's body, not
   filed. There is no OpenAlex fallback, because Zippin's OpenAlex abstract is another paper's.

## Phase 1: inventory, PDFs and the two CSVs (no Zotero writes)
- [x] Resolve every listed work against CrossRef, including those the issue gives without a DOI (MacKenzie 2002,
      Royle & Nichols 2003, Tyre 2003, Zippin 1958, Carle & Strub 1978, Hedger 2013, Schmidt 2013, Dorazio &
      Erickson 2018, Rowcliffe 2014, Ridout & Linkie 2009, Burton 2015, Chao 2014, Hsieh 2016). Record the DOI,
      title, year and whether CrossRef has an abstract. Books (the MacKenzie et al. 2018 occupancy book, Kéry &
      Royle's *Applied Hierarchical Modeling* vols 1–2) carry their metadata as rows, since 0270 reads a book
      without its CrossRef DOI
- [x] BC RISC wildlife camera standard: find the current RISC document on gov.bc.ca (not the Western Canada or
      Alberta guidelines already in `survey_design`)
- [x] Dedupe every work by DOI and title against every library, trash included, from a guarded WAL-inclusive copy
      (0270's `db()` path). A live group copy becomes a member row. A personal-only copy becomes a member row,
      which 0270 copies into the group. A trashed group copy is restored, not recreated
- [x] Find a PDF for each work, trying the routes in order and recording which one gave it:
      1. the publisher's free archive (BES journals, Ecology/ESA, *Animal Biodiversity and Conservation*, *J. Plant
         Ecology*);
      2. the OA locations OpenAlex and Semantic Scholar list (no contact details in the requests);
      3. a web search for "<title> pdf" and "<title> researchgate";
      4. the authors' lab pages and institutional repositories.
      A URL a script can fetch goes in as a URL whose body starts with `%PDF` (through 0153's `fetch`).
- [x] Script-blocked copies (ResearchGate, Academia, some lab pages): load the Claude in Chrome skill and download
      them in a new tab. If a click or sign-in is needed, hand Al the URL list. Browser downloads land in
      `~/Downloads`, which this process cannot read (probed 2026-11-16), so Al runs one copy command per batch into
      the ignored `data/rag/pdf/detection/`, and the rows name those paths
- [x] Each alternative copy is checked against the published version: title page, journal pagination and the
      abstract's wording. An accepted manuscript or preprint is used only when no version of record can be had, and
      its `why` says so, because quotes and page numbers come from it
- [x] (Decision 4: none filed.) Abstract-only: a work with no full text is filed `pdf = none` when CrossRef has its abstract. Where CrossRef
      has none, an OpenAlex fallback would break the publisher-abstract rule (CLAUDE.md, 0280:27, 0270:27; plan
      review A2) and reach every collection. So once the PDF search is done, the remaining works that have no
      CrossRef abstract are put to Al as a question: leave them as the gap, or add the fallback with the rule
      reworded and a test whose path and runner are named. A book or report cannot be abstract-only: 0270's
      non-DOI path sets no abstract (review G2), so its book DOI goes in `why`, and it is either a PDF or a gap.
      A work with neither a PDF nor an abstract is the gap. The dry run never reaches the abstract step for a new
      item (review G3), so this check is the only gate
- [x] (None needed.) OCR any scan with no text layer (pages under 30 characters) with `ocrmypdf` into `data/rag/ocr/detection/`;
      web pages are printed to PDF and filed as `report`
- [x] (None found.) A trashed group copy is restored with a Web API PATCH `deleted: 0` (Al present) before the first dry run,
      then filed as a member row by its key (review G1)
- [x] Write `data/detection_members.csv` (the group's 2 items plus any found copies) and
      `data/detection_additions.csv` (rows with a DOI, or book or report metadata from the title page). Abstract-only
      rows (`pdf = none`) go in only when an abstract is available to 0270. URLs are percent-encoded, and no other
      library's name or key goes in a tracked file
- [x] Enumeration before any filing (review O1): every row against its CrossRef record or title page, in
      `planning/active/enumeration_round0.tsv`, so fixes are CSV edits
- [x] Record per-family counts and MB in findings (filed with PDF, and from which route; abstract only; gap); edit #216's body with the
      inventory and the decided build list

## Phase 2: file `statistics/detection` through 0270 (Al present for the live run)
- [x] The browser downloads are copied into `data/rag/pdf/detection/` and every one opens as `%PDF` before the
      first dry run
- [x] `0270 --collection detection --parent LP4R4VYR --dry-run`. Check every `exists` / `copy exists` hit against
      the intended item
- [ ] Live run, then wait for Zotero to sync. A second dry run with no `would` lines and exit 0 is the no-op
      proof. Each run's log goes to `scripts/logs/rag/<date>_0270_detection*.log`
- [ ] Re-measure from a guarded copy: a before/after table (items, keyed, PDF on disk) for detection and the
      statistics tree

## Phase 3: rebuild and push `statistics`
- [ ] Pull the bucket's `statistics` (verified connect) and measure its documents and chunks with a duckdb query
      (0150 prints no chunk counts). This is the before state, measured rather than assumed
- [ ] B1 gate: 0150 stops on a listed collection with no keyed PDF item (`0150-store.R:188`). If neither
      CC22PHBQ nor BC9RR2NP got a PDF, take `Z7JP8UN2` out of the list and say so in #216's body
- [ ] Before the build, write the expected left-out list in its log: the abstract-only works, no-PDF members,
      `survey_design`'s and `model_selection`'s no-PDF items, and BGVWWBV6 (review X1)
- [ ] Hard gate: every PDF of the four collections is on disk, Zotero is quit, and the `-wal` is empty or absent.
      Then run `ACTION=build OVERWRITE=TRUE STORE=statistics COLLECTIONS="LP4R4VYR,<detection>,Z7JP8UN2,K2P7XGFG"`,
      logged with home paths as `~/`. Checks on the result:
      - the left-out list equals the expected list written before the build;
      - documents = keys − no-text PDFs;
      - the dropped list (documents the old store held and the rebuild loses) is read and explained, with #217's
        image-only scans expected;
      - every origin maps to a live group attachment
- [ ] Four `ACTION=query` checks, each with its expected documents written in the log before it runs and the top 5
      keys recorded after: occupancy goodness of fit; removal estimates when capture probability falls across
      passes; eDNA multi-scale occupancy; richness as a lower bound and sample coverage. A miss is reported, not
      tuned away (reported only, as #194's were)
- [ ] Commit the CSVs and logs and push the branch before the store push; never rewrite history after it (the
      manifest records the head sha; review O2)
- [ ] `ACTION=push` dry run, then `CONFIRM=TRUE` (Al present). Read the push's result before any verified connect,
      and check its ETag against the file. Commit the trimmed push log

## Phase 4: docs and issue
- [ ] `scripts/README.md`:
      - add the `0270 --collection detection --parent LP4R4VYR` line;
      - set the `0150 STORE=statistics` line to the four keys;
      - revise the statistics bullet (the tree, and that a new subcollection joins the list);
      - drop or update "MacKenzie et al.'s occupancy book joins when a PDF is in hand"
- [ ] `CLAUDE.md` layout: `detection_{members,additions}.csv` beside `statistics_*`, and reword "sole input of the
      `statistics` store" (now the statistics tree: LP4R4VYR and its subcollections; review G6)
- [ ] `inst/NOTICE.md`: confirm that no row is needed (the CSVs are our bibliography)
- [ ] #216's body: the outcome, the abstract-only works, the gap (works with neither a PDF nor an abstract), and
      that `survey_design` and `model_selection` are filled by other work, so the store's freshness follows them
      (review S2)

## Owed at the end (reported, done after merge)

None expected: the collection, the store and its push land before the PR. Paywalled PDFs Al later supplies join
the store at a future update, which is noted in the body rather than owed. A PDF found later for an abstract-only
work also joins at a future update.

## Validation

- [ ] Tests pass (`devtools::test()`; no `R/` change expected; `test-data-dir.R` covers `data/`)
- [ ] `/code-check branch` (three-round floor, ending on a re-check of the round-0 enumeration against the filed
      items) and the #56 `public_sweep.py` over the branch
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- **CSV rows:** each DOI is resolved against CrossRef and each title matched. The enumeration is
  `planning/active/enumeration_*.tsv`.
- **Filing:** the no-op second dry run, and the before/after re-measure.
- **Store:** the build log's left-out and dropped lists against the recorded gap, the query checks against
  expectations written first, and the push's ETag against the file.
