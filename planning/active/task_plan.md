# Task: Westslope cutthroat store: gather the management plans, East Kootenay monitoring and EDF Elk Valley reports, build it, and push it (#190)

## Problem (issue body)


Measured 2026-11-10 (an `immutable` read of the local Zotero database): group collection `species/westslope_cutthroat` (`TIDR3PNN`) holds 30 items, 9 of them with a PDF. It is in no store; `habitat_modelling`'s build list does not include it.

- Without a PDF: the 2014 BC management plan, the 2017 COSEWIC assessment and status report, the 2008 East Kootenay abundance monitoring of classified waters, the Upper Fording River assessments (2016, 2017), the 2020 evaluation of hybridization in the upper Kootenay, and the Elk River WCT Research Initiative's 2019 report.
- Not in the collection, to search for: the federal management plan for the BC population and any progress report on it, the provincial plan's progress reporting, and recent Elk and Kootenay monitoring and restoration reports where they are public.
- The Environmental Damages Fund's Elk Valley (Qukin ʔamakʔis) projects: the call and applicant guides, and the plans, monitoring and final reports of funded projects where they are public. ECCC administers the fund and Ktunaxa Nation Council reviews the competitive call with it; what each project reports, and against what baseline, is part of what the store should let us read.


## Context

The westslope cutthroat management and recovery documents and the East Kootenay monitoring reports should be
searchable in one ragnar store and quotable verbatim, for habitat, floodplain and restoration-effectiveness work in the
Kootenay and the Elk. Group collection `species/westslope_cutthroat` (`TIDR3PNN`, under `species` `9U54XAND`) holds
30 items, 9 with a PDF, every one with a Better BibTeX key (immutable read, 2026-11-10; the `-wal` is 2.1 MB, so the
count is re-taken from a guarded copy before filing). It is in no store. The work follows #124 (sturgeon) step for
step: a members CSV and an additions CSV drive `0270`, and `0150` builds from the one collection.

What exploration settled:
- `0270 --collection westslope_cutthroat --parent 9U54XAND` reads `data/westslope_cutthroat_members.csv`
  (`citation_key,source,pdf`: a member row's `pdf` attaches a PDF to an item that lacks one) and
  `data/westslope_cutthroat_additions.csv` (sturgeon's columns). No code change is expected.
- 21 members lack a PDF, not only the 7 the issue lists: 14 more are journal articles, a Banff protocol, Alberta
  reports and a webpage. Each is tried; a paywalled article goes on a list for Al to download, as #124 did.
- The collection also holds Alberta and Montana work. It stays: the store is the collection whole.
- `0150` reads only items filed directly in a collection, so `species` in `habitat_modelling`'s list does not pull
  `TIDR3PNN` in; `scripts/README.md` says so, as for sturgeon.
- cred 0.7.0 and ragnar 0.3.1 are installed (cred's newest tag is v0.7.0). cred#45 is open: cred reads Zotero
  `immutable`, so the build runs with Zotero quit and its `-wal` checkpointed, as #124's did.
- Web API writes and the S3 push need Al present: auto mode refused #124's Zotero merge (#172's plan).

## Decided at the gate (Al, 2026-11-10)

1. **Breadth: named series.** The documents the issue names, plus whole public series: the Upper Fording River WCT
   monitoring reports (2018 on, beside the 2016, 2017 and 2021 held), the Elk River Alliance WCT research reports,
   FWCP Columbia WCT reports in the Kootenay, and the EDF Elk Valley call, applicant guides and funded-project plans,
   monitoring and final reports, capped at what those sites link. EcoCat is out.
2. Store name `westslope_cutthroat`, built from `TIDR3PNN` alone. Threshold tuning is out (#186).

## Phase 1: inventory, PDFs and the two CSVs (no Zotero writes)
- [x] Re-measure `TIDR3PNN` from a WAL-inclusive guarded copy (`0270`'s `db()` path): members, keyed, PDF on disk
- [ ] Members without a PDF: find each one's PDF (the item's URL, the DOI's open-access copy, the publisher or
      catalogue); every URL's body must start `%PDF`. Paywalled ones listed for Al to download into the ignored
      `data/rag/pdf/westslope_cutthroat/`; scans OCRed (`ocrmypdf`)
- [ ] Federal: the management plan for the BC (Pacific) population under SARA and any progress report on it
      (registry, publications.gc.ca; printed from the registry's HTML where no PDF is served, as #124 did)
- [ ] Provincial: progress reporting on the 2014 BC management plan, where public
- [ ] Series: Upper Fording River WCT monitoring (Teck's public reports, 2018 on), Elk River Alliance WCT reports,
      FWCP Columbia WCT reports for the Kootenay
- [ ] EDF Elk Valley (Qukin ʔamakʔis): ECCC's Elk Valley funds page, the call and applicant guides, KNC's EDF
      newsletters, and the plans, monitoring and final reports of funded projects they link
- [ ] Metadata for each addition from its own title page or "cite as" line, never a listing page or a sibling year
      (#124 round 3)
- [ ] Dedupe every addition by title and DOI against the group and personal libraries, trash included; a
      personal-only copy is filed into the group, a trashed group copy restored, not recreated
- [ ] Write `data/westslope_cutthroat_members.csv` (30 rows) and `data/westslope_cutthroat_additions.csv`
- [ ] #190's body: corrected premises (21 members without a PDF) and the decided breadth

## Phase 2: file the collection through `0270` (Al present for the live run)
- [ ] Re-run the `%PDF` check on every URL in both CSVs
- [ ] `0270 --collection westslope_cutthroat --parent 9U54XAND --dry-run`; check every `exists` / `copy exists` hit
      against the intended item (generic titles under one corporate author)
- [ ] Live run, wait for Zotero to sync; a second dry run with no `would` lines and exit 0 is the no-op proof
- [ ] Re-measure from a guarded copy: before/after table (live items, keyed, PDF on disk, MB uploaded)

## Phase 3: build, query, push `westslope_cutthroat`
- [ ] Zotero quit, `-wal` empty or absent; `ACTION=build STORE=westslope_cutthroat COLLECTIONS=TIDR3PNN`, logged to
      `scripts/logs/rag/<date>_build_westslope_cutthroat.log` with home paths as `~/`. The left-out list must equal
      the recorded gap; every origin maps to a live group attachment of a live member
- [ ] Four `ACTION=query` checks, expected documents written in the log before each runs, top 5 keys recorded after:
      thermal limits; hybridization with rainbow trout in the upper Kootenay; restoration effectiveness in the Elk;
      monitoring required of EDF-funded projects. A miss is reported, not tuned away
- [ ] `ACTION=push` dry run, then `CONFIRM=TRUE` (Al present); read the push's result before any verified connect;
      the push log keeps only this store's manifest entry

## Phase 4: docs and issue
- [ ] `scripts/README.md`: the `0150 ACTION=build STORE=westslope_cutthroat COLLECTIONS=TIDR3PNN` line, the `0270
      --collection westslope_cutthroat --parent 9U54XAND` line, and that `TIDR3PNN` does not feed `habitat_modelling`
- [ ] `CLAUDE.md` layout: `westslope_cutthroat_{members,additions}.csv` beside the sturgeon ones
- [ ] `inst/NOTICE.md`: no row expected (the CSVs are our bibliography, not a source's data); confirm
- [ ] #190's body: the gap (documents with no PDF anywhere) and the outcome

## Owed at the end (reported, done after merge)

None: the collection, the store and its push land before the PR.

## Validation

- [ ] Tests pass (`devtools::test()`; no `R/` change expected)
- [ ] `/code-check branch` (three-round floor, ends on an enumeration of every CSV row against its title page) and the
      #56 `public_sweep.py` over the branch
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- The CSVs: each PDF source starts `%PDF`; each metadata row read against its title page.
- `0270`: the no-op second dry run.
- The collection: the guarded-copy before/after counts.
- The store: its manifest entry (documents, chunks, md5), every origin mapped to a live attachment, the left-out list
  equal to the gap, and four queries with expectations written first and top keys on record.

