# Task: Bull trout: build a store, research its life history, and find the datasets (#194)

## Problem (issue body)


Measured 2026-11-11 by a read-only query of the local Zotero database:
- The group collection `species/bull_trout` (`VHWEK6RE`) holds 20 items, 11 of them with a PDF.
- It is in no store. The local stores are flow, fraser, habitat_modelling, peace, pine, sturgeon and temperature.

Bull trout already shows up in several places:
- Its spawning evidence is #33 and `research/bt_spawning.md`.
- Its age-0 growth is part of #51.
- Two bull trout units are listed under SARA: South Coast and Western Arctic, both Special Concern. Their management plans have not been read here.
- #33's literature track names the Hagen redd-count and critical-habitat series, Baxter's spawning-site work, and the US redd-survey and critical-habitat literature as under-read or missing.


## Context

#194 wants bull trout on the same footing as cutthroat (#190) and sturgeon (#124). That means one ragnar store of the
recovery, management and monitoring documents, quotable verbatim, followed by a life-history research file and a
dataset inventory. Exploration corrected one premise: bull trout **is** in a store already.
- #122 built `bull_trout_grayling` from `VHWEK6RE` (species/bull_trout) and `GELFSUTU` (species/grayling). It holds
  35 documents (#172 merged one) and is in the bucket as of 2026-11-10.
- `habitat_modelling`'s build list includes `VHWEK6RE`.
- What is missing is the documents themselves: the collection held 16 items, 11 with a PDF, after #122. The issue
  counts 20 and 11, and Phase 1 re-measures.

This PR carries piece 1, the store. Pieces 2 and 3 are filed as their own issues.

What exploration settled:
- `scripts/0270-habitat-collection-build.py --collection bull_trout --parent 9U54XAND` reads the existing
  `data/bull_trout_members.csv` (16 rows from #122, kept and appended to) and a new `data/bull_trout_additions.csv`,
  read when it exists. One code change: `addition_item` gains `publicationTitle`, `volume` and `issue`, so a journal
  article with no DOI (Fraley & Shepard 1989) is filed whole (plan review G2).
- `0150` reads only items filed directly in a collection.
- The tools are the same as #190's: cred 0.7.0 (`ACTION=update` in place) and ragnar 0.3.1. cred#45 is open, so the
  build runs with Zotero quit and its `-wal` checkpointed.
- Web API writes and S3 pushes need Al present.

## Decided at the gate (Al, 2026-11-12)

1. **Split.** This PR gathers the documents, files the collection, and builds and pushes the store. Life history
   (piece 2, which reads the store) and the dataset hunt (piece 3) become two new issues. #194's body is edited to
   name them.
2. **Store.** A new `bull_trout` store built from `VHWEK6RE` alone. `bull_trout_grayling` stays, and is updated in
   place over its own build list (`VHWEK6RE,GELFSUTU`) and pushed, so it is not left stale.
3. **habitat_modelling.** `VHWEK6RE` stays in its list. The management and monitoring documents join it: run
   `ACTION=update` over its whole list on this branch, then push.
4. **Breadth: the named series plus the US core.**
   - Federal management plans and COSEWIC assessments for both SARA units (South Coast; Western Arctic).
   - Provincial status and management documents.
   - The Hagen Williston series and Baxter's spawning-site work.
   - FWCP Peace and Columbia bull trout reports.
   - Kootenay and Arrow Lakes monitoring, including BC Hydro's.
   - The US core: the USFWS 2015 recovery plan, the 2010 critical habitat rule and Fraley & Shepard 1989.
   - Whole public series, capped at what their sites link. EcoCat is out.
5. **(Al, 2026-11-12, after the three searches)**
   - EcoCat is allowed for named third-party FWCP and provincial bull trout reports whose only public host it is: the
     Hagen Williston series, Hagen & Decker 2011 and FWCP Columbia's reports. Our own reports stay excluded.
   - Documents that need a browser (fwcp.ca, bchydro.com, publications.gc.ca, JS-only and Cloudflare-checked hosts,
     the Wayback Machine) are fetched through Claude in Chrome, pausing on any login or check.
   - Marginal: Rodtka 2009 (Alberta's status update), the 11 Streamkeepers reports through the Wayback Machine and the
     2015 Salmo scoping report are in, the scoping report's metadata from the page that links it. The Kootenay Lake
     bulletins are out.

## Phase 0: split the issue (no data writes)
- [x] (#198 and #199.) File the life-history issue (piece 2, blocked by this store) and the dataset-hunt issue (piece 3), each with
      #194's text for its piece and "Relates to #33, #51"
- [x] Edit #194's body:
  - the corrected premise (`bull_trout_grayling` exists, and `habitat_modelling` reads `VHWEK6RE`);
  - this PR's scope;
  - the two new issues, as tasks.

## Phase 1: inventory, PDFs and the two CSVs (no Zotero writes)
- [x] (16 live, 16 keyed, 11 on disk.) Re-measure `VHWEK6RE` from a guarded copy that includes the `-wal` (the path `0270`'s `db()` uses): live
      members, keyed, and with a PDF on disk
- [ ] Members without a PDF: try each one (the item's URL, an open-access copy of the DOI, the publisher, the catalogue,
      a "researchgate pdf" title search). Every body must start `%PDF`. Paywalled ones go on a list for Al to download
      into the ignored `data/rag/pdf/bull_trout/`; scans are OCRed
- [ ] Federal: the SARA management plans for South Coast and Western Arctic bull trout and the COSEWIC assessments
      (2012 is already a member); printed from the registry's HTML where no PDF is served. Decide from the text whether
      a federal plan adopts the 2023 BC plan (a member); if it does, file the front matter and Part 1 only (G4). The
      Saskatchewan–Nelson (Alberta) documents are outside the two units
- [ ] Provincial: status reports, the management plan (2023 is already a member) and any progress reporting
- [ ] Series:
  - the Hagen Williston series (redd counts, critical spawning habitat, limiting factors);
  - Baxter's spawning-site work (Baxter & Hauer 2000, Baxter & McPhail 1999, and others);
  - FWCP Peace and Columbia bull trout reports;
  - Kootenay and Arrow Lakes monitoring (BC Hydro WLR/CLBMON and others).
- [ ] US core: the USFWS 2015 recovery plan (with its unit implementation plans where the plan links them), the 2010
      critical habitat final rule, and Fraley & Shepard 1989
- [ ] Metadata for each addition comes from its own title page or "cite as" line, never from a listing page or a
      sibling year (#190's review)
- [ ] Dedupe every addition by title and DOI against every library, trash included:
  - a live group copy in another collection becomes a member row;
  - a copy only in the personal library is filed into the group;
  - a trashed group copy is restored only when no live group copy exists: a Web API PATCH `deleted: 0`, Al present,
    before the first dry run, after which it is a member row by its key (`0270` cannot see the trash; G5).
- [ ] Rules for the rows:
  - a member with no PDF has an empty `pdf`;
  - an addition with no PDF is listed only with a DOI whose CrossRef record has an abstract;
  - web pages are printed to PDF as `report`;
  - URLs are percent-encoded;
  - no tracked file names another library or its keys;
  - a DOI row is for a journal article only (CrossRef reads every DOI as one); a report, book or thesis with a DOI goes
    in without it, its series in `reportType`/`reportNumber` (G2).
- [ ] `0270`'s `addition_item` takes `publicationTitle`, `volume` and `issue` (G2), checked in the dry run on Fraley &
      Shepard 1989
- [ ] No-text check: count the pages under 30 characters of text in every PDF to be filed; `ocrmypdf --skip-text` those
      into `data/rag/ocr/bull_trout/` and point the row at the copy (G3)
- [ ] Write `data/bull_trout_members.csv` (appended) and `data/bull_trout_additions.csv`. Record the count and MB per
      source in findings before filing (the scope check), with the 14 group items found outside the collection as
      their own source line (S1). A3's quota check is settled: the group's file storage is unlimited (Al,
      2026-11-12; now in soul's `/zotero-api`), so the MB is recorded for upload time only
- [ ] The enumeration, before the first dry run: every field of every row against a verbatim snippet of its own title
      page (#190's `review-round3-evidence.tsv` form), so fixes are CSV edits (O2). From the first live run on, a fix
      is a CSV row, a PATCH and a no-op dry run; then the PATCHed items' keys are re-read from a guarded copy, and a key
      that moved means the CSVs and evidence rows, `0280`, and `ACTION=update` plus a push on all three stores. Members
      with unpinned keys are never edited

## Phase 2: file the collection through `0270` (Al present for the live run)
- [ ] Al's hand downloads land in `data/rag/pdf/bull_trout/` (or those rows keep an empty `pdf`, owed in an issue)
- [ ] Check every URL in both CSVs again for `%PDF`, through `0153`'s `fetch`
- [ ] `0270 --collection bull_trout --parent 9U54XAND --dry-run`: check every `exists` and `copy exists` hit against
      the intended item
- [ ] Live run, then wait for the sync. A second dry run with no `would` lines and exit 0 is the no-op proof. Logs go
      to `scripts/logs/rag/<date>_0270_bull_trout*.log`
- [ ] Re-measure from a guarded copy: a before/after table

## Phase 3: build, query and push the stores
- [ ] Gate: every member's PDF is on disk, Zotero is quit, and the `-wal` is empty. Zotero stays quit through the updates
- [ ] Verified pull before any local write: `ACTION=query VERIFY=TRUE` on `habitat_modelling` (the local copy is stale,
      `b28ad0ed…` against the bucket's `4fcc6700…`) and on `bull_trout_grayling`; each md5 recorded against the
      manifest (G1)
- [ ] `ACTION=build STORE=bull_trout COLLECTIONS=VHWEK6RE`, logged. The left-out list equals the recorded gap, and
      every origin maps to a live group attachment; documents = keys − no-text PDFs, with those keys named (G3)
- [ ] Four `ACTION=query` checks, each with its expected documents written in the log before it runs and the top 5
      keys recorded after:
  - Williston spawning-site selection and redd counts;
  - thermal limits;
  - South Coast unit management objectives;
  - US critical habitat primary constituent elements.

  A miss is reported, not tuned away
- [ ] `ACTION=update STORE=bull_trout_grayling COLLECTIONS="VHWEK6RE,GELFSUTU"` (35 documents before) and
      `ACTION=update STORE=habitat_modelling` over its whole list (`scripts/README.md`; 266 before). Before each, write
      the expected added keys in its log; after, the `N added, M dropped` line must match, and every surprise is
      explained before any push (A1)
- [ ] Commit the CSVs and the build, query and update logs, home paths as `~/` (G6); then **push the branch**, and
      never amend, rebase or rewrite after it, since the manifests record `head_sha` (O1)
- [ ] Push one store at a time (`ACTION=push`: a dry run, then `CONFIRM=TRUE`): `bull_trout`, then `bull_trout_grayling`,
      then `habitat_modelling` last. Read each push's result and check its multipart ETag before the next push or any
      verified connect (O1)
- [ ] Commit the push logs, each trimmed to its own manifest entry (G6)

## Phase 4: docs and issue
- [ ] (Drafted in `7a9f4c7a`; checked against the built store here.) `scripts/README.md`:
  - the `bull_trout` build line;
  - the `0270 --collection bull_trout --parent 9U54XAND` line;
  - that `VHWEK6RE` feeds `bull_trout`, `bull_trout_grayling` and `habitat_modelling`.
- [ ] (Drafted in `7a9f4c7a`.) `CLAUDE.md` layout: `bull_trout_{members,additions}.csv` as the inputs of `bull_trout` (and of
      `bull_trout_grayling` with grayling's)
- [ ] `inst/NOTICE.md`: no row expected; confirm
- [ ] #194's body: the gap and the outcome

## Owed at the end (reported, done after merge)

- [ ] Pieces 2 and 3: #198 (life history, blocked by this store) and #199 (datasets), filed in Phase 0

## Validation

- [ ] Tests pass (`devtools::test()`; no `R/` change expected)
- [ ] `/code-check branch` (three-round floor, ending on an enumeration of every CSV field against its own title page),
      and the #56 `public_sweep.py` over the branch
- [ ] The PWF checkboxes match the landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- The CSVs: each PDF source starts `%PDF`, and each row is read against its title page.
- `0270`: the no-op second dry run.
- The collection: the before/after counts from a guarded copy.
- The stores:
  - the manifest entries (documents, chunks, md5);
  - every origin maps to a live attachment;
  - the left-out list equals the gap;
  - the queries' expectations were written first;
  - the multipart ETag matches each local file.

