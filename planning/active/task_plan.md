# Task: Arctic grayling and bull trout store: clean the two species collections, build it, and add grayling to habitat_modelling (#122)

Measured 2026-10-30 in the group library (issue body): `species/grayling` 19 of 30 items carry a PDF; `species/bull_trout`
6 of 18, and several have no Better BibTeX key, including both copies of Hagen and Weber (2019); `0150 build` drops an item
with no key or no PDF without saying so; the recorded `habitat_modelling` build does not take `grayling`; CLAUDE.md says
`0150 ACTION=query` is broken, though cred#27 fixed it and under cred 0.4.0 it returns hybrid results.

Exploration moved some premises (findings.md, "Exploration"): the issue's counts include trashed items; Hagen & Weber
is already merged to one keyed copy with its PDF (`YC3EQ8T8`) that is not yet in bull_trout; and cred's PDF pick
(`crd_zot_src_lookup()`) resolves keys across libraries, takes trashed attachments and takes the newest of several PDFs.

## Decided at the gate

Approved by Al, 2026-10-30, with the plan:

1. **Store name `bull_trout_grayling`.**
2. **Clean through `0270`, not one-off API calls**: `--parent` (default Fisheries) so
   `0270 --collection grayling --parent 9U54XAND` works, with `data/{grayling,bull_trout}_members.csv` (every keyed
   member, a `pdf` URL where one was found) and `data/{grayling,bull_trout}_additions.csv` (the four standalones as
   `zotero:<key>` rows). The CSVs are the record of the cleanup; a re-run is a no-op.
3. **Remove `YQVI79FL` from grayling** (collection PATCH; not trashed). Bottoms et al. 2023 keeps both PDFs: picking
   among several is cred's to fix.
4. **cred is fixed first, concurrently, in its own session**: one cred issue for the three pick defects, worked with
   cred#35 (and cred#26 for a `notes` field naming each store's collections) toward a cred tag. Phases 1–3 run now;
   the builds (Phases 4–5) wait for the tag, recorded in #122's body. "Members left out" reporting goes in `0150`
   only if cred does not take it.
5. Versions (Al, 2026-10-30: check latest before diagnosing; cred is not on CRAN): cred 0.4.0 is its latest tag and
   `main` has no `R/` change since; ragnar 0.3.0 installed, 0.3.1 on CRAN, upgraded before any build.

## Phase 1: `0270` targets a collection under any parent
- [x] `--parent` argument (default `TRXPJHQE`), used by `find_collection()`; header and `scripts/README.md` say so
- [x] A name missing under the parent but present elsewhere in the group is refused, with its key (plan review):
      without `--parent`, `--collection grayling` would otherwise create a second `grayling` under Fisheries
- [x] `--dry-run` against `--collection habitat_modelling` unchanged (all `member`/`pdf present`): no regression

## Phase 2: clean `species/bull_trout` and `species/grayling`
- [ ] Find a PDF for every no-PDF member (URL must return `%PDF`; ACAT/EcoCat for Williamson & Zimmerman 2005);
      record each miss and why (web page, paywalled) in findings
- [ ] Rekey `hagen_weber2019Limitingfactorsa` -> `hagen_weber2019Limitingfactors` (today's merge re-keyed the survivor
      `YC3EQ8T8`): 22 rows of `literature_evidence.csv`, the habitat_modelling, temperature and flow members; `0280` passes
- [ ] `data/bull_trout_members.csv` (+ `hagen_weber2019Limitingfactors`, + `gill2006Bulltrout`, the guide's existing
      parent), `data/grayling_members.csv` (+ `beaudry2014Assessmentassignment`), `data/grayling_additions.csv` for the
      three grayling standalones (metadata from the PDFs' title pages); no `pdf` URL that returns HTML
- [ ] Every `exists` / `copy exists` gkey in the dry run checked against the intended item before the live run
- [ ] `0270 --dry-run` for both, then live; wait for sync; a second dry run is the no-op proof (no `would*`, exit 0)
- [ ] `YQVI79FL` removal from grayling (decision 3), recorded in findings
- [ ] Re-measure from a guarded copy: members, keyed, PDF on disk (check Zotero downloads group files at sync);
      confirm the new items got BBT keys
- [ ] CLAUDE.md layout line for the new CSVs

## Phase 3: cred, upstream (decision 4)
- [x] File the cred issue: cross-library key, trashed attachment, newest-of-several; reprex on the three keys
      (cred#40, filed 2026-10-30 at Al's request; he works it)
- [ ] Re-run cred#35's reprex on ragnar 0.3.1 and note the result on cred#35
- [ ] #122's body: the builds are blocked by the cred issue (a task in its plan, not a comment)
- [ ] With the cred tag, not before (cred 0.4.0 is unproven on ragnar 0.3.1's mirai ingest): upgrade ragnar to 0.3.1
      (`pak::pak("ragnar")`, CRAN) and cred from GitHub
      (`pak::pak("NewGraphEnvironment/cred")`; cred is not on CRAN, so "latest" is its GitHub tag and `main`)
- [ ] `0150 collection_keys()` prints each member it drops (no key, no PDF, standalone attachment; a standalone
      whose PDF a keyed parent also holds marked as covered). Unconditional: 0150 hands cred keys, so cred never sees
      a keyless or PDF-less member (plan review)

## Phase 4 (after the cred tag): build and push `bull_trout_grayling`
- [ ] `ACTION=build STORE=bull_trout_grayling COLLECTIONS="VHWEK6RE,GELFSUTU"`; read the left-out and origin reports
- [ ] `ACTION=query` on it (Williston spawning question returns Hagen & Weber 2019 / Hagen et al. 2020)
- [ ] `ACTION=push` dry run, then `CONFIRM=TRUE`; manifest entry checked

## Phase 5 (after the cred tag): rebuild and push `habitat_modelling` with grayling
- [ ] `ACTION=build STORE=habitat_modelling OVERWRITE=TRUE COLLECTIONS="U9ZCZ6RN,RXNFPBPH,VHWEK6RE,GELFSUTU,9U54XAND,SW2RXUJC,DQP29KU7,X29BX4U8,W4425VK5,545K8HP4"`
      (the recorded set by key, plus grayling); pull the current store first and diff document origins against the
      rebuild, each added or removed origin accounted for (grayling, the cleanup, cred#40's picks)
- [ ] Query check; push dry run, then `CONFIRM=TRUE`
- [ ] `scripts/README.md`: the build line with grayling, a line for the new store

## Phase 6: docs (lands before the cred tag, except the README build lines in Phase 5)
- [ ] CLAUDE.md: `ACTION=query` works under cred ≥ 0.4.0 (cred#27); drop the "broken" note and the draft-issue pointer
- [ ] `0150` header/README: cred 0.4.0 floor for query (and a version check in the script's query branch)
- [ ] Issue #122 body: correct the trash-inflated counts and the Hagen & Weber state

Phases 1–3 run to a commit now. If the cred tag is not out when they are done, the branch is pushed and parked with a
resume block; Phases 4–6 resume on it after the tag, and the PR opens then.

## Validation

- [ ] Tests pass (`devtools::test()`; no `R/` change)
- [ ] `/code-check branch` clean (three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved: `0270` by its dry run on an unchanged collection and a no-op re-run after the live run; the
cleanup by the guarded-copy re-measure (counts before/after in findings); the cred fix by the three keys resolving to
the group's live, intended PDF; the stores by their manifest entries (documents, chunks, md5), every document's origin
mapped back to a group attachment, and a query each.
