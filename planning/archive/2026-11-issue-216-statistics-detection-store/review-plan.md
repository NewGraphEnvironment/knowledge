# Plan review — #216 (Plan agent, 2026-11-16)

Verified by probe before folding: B1 (0150-store.R:188-189 stops on a listed collection with no keyed PDF item),
G5 (CC22PHBQ = `mackenzie_royle2005Designingoccupancy`, BC9RR2NP = `guillera-arroita_etal2010Designoccupancy`).
B2 dropped: cred#35 (oversize chunk / NUL byte) was closed 2026-10-31, before cred 0.7.0.

## Blocker
- B1. 0150 aborts when a listed collection has no keyed PDF item; `survey_design` (Z7JP8UN2) has 0 PDFs. It gets one
  only if CC22PHBQ or BC9RR2NP gets a PDF through detection. Gate: drop Z7JP8UN2 from the list otherwise.
- B2. `model_selection` crashed a build before (ESL oversize chunk, Bates NUL byte; cred#35). → closed upstream.

## Gap
- G1. Trash restore has no mechanism in 0270 (local_items and /items/top skip the trash): Web API PATCH `deleted: 0`
  with Al present, before the first dry run, then a member row.
- G2. Books cannot be abstract-only: a DOI row is built as a journal article (0270:400), the non-DOI path sets no
  DOI or abstract, so a no-PDF book ends ABSTRACT-MISSING. Book DOI goes in `why`; a book is a PDF or a gap.
- G3. The dry run returns before the abstract step for new items (0270:457), so ABSTRACT-MISSING shows only in the
  live run. Phase 1's abstract check is the only gate.
- G4. #194 rules missing: web pages printed to PDF as `report`; no-text page count and `data/rag/ocr/detection/`;
  documents = keys − no-text PDFs; count and MB per source.
- G5. Pin the two members' citation keys.
- G6. CLAUDE.md:125-126 calls `statistics_*` the sole input of the store; reword.

## Ordering
- O1. Enumeration of every row against CrossRef / title page before the first dry run, not in Validation.
- O2. Push the branch before the store push; never rewrite history after (manifest head_sha); commit the push log.
- O3. Trash restore and any 0270 code commit land before the Phase 2 dry run.

## Assumption
- A1. `--parent LP4R4VYR` works; 0270 exits if a `detection` collection exists elsewhere in the group; items tagged
  `detection`.
- A2. An OpenAlex fallback conflicts with the publisher-abstract rule (CLAUDE.md:391-393, 0280:27-28, 0270:27-29);
  a fallback in crossref_item() reaches every collection; abstract drift breaks the no-op proof.
- A3. The issue lists 30 works (31 counting AHM as two volumes), not "about 37".

## Scope
- S1. Abstract-only rows add nothing to the store (0150 leaves out no-PDF items); the OpenAlex change risks 0270 for
  works never searchable.
- S2. survey_design and model_selection belong to other work; say so in #216's body.

## Acceptance
- X1. "Left-out list equals the recorded gap" is false by construction: write the expected left-out list (abstract-
  only, no-PDF members, survey_design's and model_selection's no-PDF items, BGVWWBV6) in the log before the build.
- X2. 0150 prints no chunk counts: say where they come from; expect #217 drops of image-only scans; measure the
  before state.
- X3. A fixture test for 0270 has no harness: name a path and runner.
- X4. Query checks need a pass rule or "reported only".
