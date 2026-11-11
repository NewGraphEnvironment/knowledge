# Plan review — #190 (Plan agent, 2026-11-11 ~00:55 UTC)

Answers to the specific checks (0270 file:line as the reviewer read them):
1. A member row's `pdf` is read only when the group item has no stored PDF and no same-key, same-title local PDF
   (`ensure` 324-364). It may be a URL (must start `%PDF`), a repo-relative path, or `zotero:<attachment key>`. An
   empty `pdf` with nothing local is `no-pdf: none local`, exit 0; a non-empty one that cannot be resolved fails
   (exit 1), and `none` in a member row is read as a path. A dry run does fetch member PDFs; it does not fetch an
   addition it would create.
2. `find_collection` matches `westslope_cutthroat` exactly under `9U54XAND` (16 subcollections, page of 100): `exists`.
3. `0150`: no store-name allow-list; `COLLECTIONS=TIDR3PNN` by key; logs free-named. Nothing to change.
4. No test enumerates `data/*_members.csv` or CLAUDE.md layout lines.

Findings, with the verdict after checking each (immutable read, 2026-11-11):
- **Gap: the group already holds Upper Fording reports with PDFs outside `TIDR3PNN`** (`cope2020UpperFording`,
  `thorley_etal2021UpperFording`, `faulkner_etal2021SubjectMatter`; the reviewer also names
  `hocking_etal2022SubjectMatter`, `thorley_branton2022SubjectMatter`). CONFIRMED for the first three. They become
  member rows, not additions: `group_copy` drops a match whose first creator differs, so an addition could duplicate.
- **Gap: another group library holds the ERA 2019 PDF.** CONFIRMED. Not used: the item's own URL already returns the
  same 7.9 MB `%PDF`, and naming that library or its key in a tracked file would read as a project identifier.
- **Gap: two PDF-less members are also in `habitat_modelling`** (`JEKVL99X`, `ZBHC36HB`). CONFIRMED. If their PDFs are
  attached, `habitat_modelling` goes stale: Phase 3 runs `ACTION=update` on it.
- **Gap: no rule for additions with no PDF.** Taken: `pdf=none` only for a DOI whose CrossRef record has an abstract;
  anything else goes to the gap list, not the CSV. A member with no PDF gets an empty `pdf`.
- **Gap: item types and URLs.** Taken: web pages are printed to PDF as `report`; URLs percent-encoded.
- **Assumption: curl vs 0153's fetcher.** Taken: the Phase 2 `%PDF` check runs through `z.fetch`.
- **Assumption: the federal plan may adopt the provincial plan in one PDF.** To check by content in Phase 1.
- **Assumption: the Alberta-population recovery documents are not the BC federal plan.** Noted for the dedupe.
- **Ordering:** Al's downloads before the first dry run (or the rows' `pdf` empty until then); commit before the push
  (the manifest records the head sha); files on disk before quitting Zotero. Taken.
- **Acceptance:** documents = keys − no-text PDFs, no-text keys named; `0270` output logged; per-source counts and MB
  recorded at the Phase 1 gate. Taken.
- **Scope:** no creep.
