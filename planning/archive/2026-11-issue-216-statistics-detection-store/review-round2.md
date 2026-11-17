# Code-check round 2: #216 branch (86088f67...cd77b27b)

## Checklist read

- code-check-python.md: in full.
- code-check.md: every H3 under `## Mechanisms`, prose only (tables and evidence blocks skipped); and of the
  standalone rules, "A preview flag is only safe if it previews", "Documentation Staleness", and in Spreadsheets and
  PDFs "Verify PDF links from the annotations, not the extracted text" and "Extracted PDF text carries corrupted
  glyphs...". The other 18 standalone, Security and Spreadsheet headings were not read (no tool, shape or pattern in
  this diff).
- code-check-r.md: no heading read (the diff has no R; 0150's `collection_keys()` was read as code, not changed).
- code-check-shell.md: no heading read (no shell in the diff).
- code-check-spatial.md: no heading read (nothing spatial).

## What was checked

- Every additions and members row against its PDF's title page (`pdftotext`), the item 0270 created in the group
  library (title, creators by `orderIndex`, date, DOI; read from a copy of `zotero.sqlite` with its `-wal`), and
  CrossRef's record for each override row. All six override rows match their reason: MacKenzie et al. 2002 (CrossRef
  splits "J. / Andrew Royle", title in capitals), Royle & Nichols 2003 and Tyre et al. 2003 (capitals), Dorazio &
  Erickson 2018 (`<scp>` mangling, issued 2017-12-02 against print 2018-03), Royle 2004 (CrossRef's first author is
  the USGS centre).
- `why` texts against the PDFs: Hedger (Zippin, Seber, Carle & Strub all named), Peterson (efficiency 1.71 times
  lower with successive passes, removal underestimates), Chao 1987 (lower bound), iNEXT's appendix (pages 7 on),
  Ridout & Linkie preprint dated 2008-05-09, Tyre via UQ eSpace (CORE banner), MacKenzie 2002 JSTOR copy, RISC
  title page, ISBN, publisher line and version. The RISC URL answers 200 with a PDF.
- The statistics tree in the group library is exactly LP4R4VYR, 73PNRGJF (24 items), Z7JP8UN2, K2P7XGFG; 0150's
  `collection_keys()` reads `collectionItems` for the named ids only and returns `unique()` keys, so the README's
  "only items filed directly" holds and the two members filed in both `survey_design` and `detection` are ingested
  once. 4 + 4 + 23 PDFs = the 31 documents the log reports.
- The override parser, exercised offline on the functions extracted by AST (no 0153 import, no key read):
  whitespace around names and values is stripped, a repeated name is harmless, a wrong-case name, an unknown name or
  a blank value raises (caught per row by `main()`, tallied `ERROR`, and the run exits "problems", in `--dry-run`
  too), `;;` and a missing column are no-ops.

## Findings

- **[severity: bug]** data/detection_additions.csv:17 (the `10.1111/2041-210X.12613` row) — the item 0270 created
  for Hsieh et al. 2016 (group key `5BP2PEU4`) is titled "iNEXT: an R package for rarefaction and extrapolation of
  species diversity (H ill numbers)"; the PDF's title page reads "(Hill numbers)". CrossRef deposits the title as
  `(\n   <scp>H</scp>\n   ill numbers)`, and `plain()` drops the inline tags without a gap but keeps the whitespace
  around them, so the indent becomes a space inside the word. It is the case the branch's `override` column was added
  for, but the row carries none, and the dry run could not show it: `do_addition()` prints only `title[:60]`, and the
  break sits past character 60. The title prints wrongly in any reference list that cites the item. (The key,
  `hsieh_etal2016iNEXTpackage`, is unaffected.) Because the item already exists, adding `override=title` now would not
  fix it (next finding): it needs a PATCH of the title, then the override on the row so a rebuild from the CSV agrees.
  - **Rule:** none

- **[severity: fragile]** scripts/0270-habitat-collection-build.py:410-416 (with the docstring at 29-31, and
  scripts/README.md:160-161) — the override reaches only an item 0270 creates. When `group_copy()` finds the item
  (`exists`), `do_addition()` never compares or patches the overridden fields, and says nothing, so adding an
  override to fix an item already filed (the Hsieh row above is exactly that) reads as done and changes nothing. The
  docstring and the README describe the override as taking "those fields from the row" with no creation-only
  qualifier, while the same function does bring an existing item's abstract to CrossRef's current form, so a reader
  has reason to expect the same of the override. Either patch the overridden fields on `exists` the way the abstract
  is patched (If-Unmodified-Since-Version, a `would set` step on a dry run), or say in the docstring and README that an
  override applies at creation only and an existing item is fixed by hand.
  - **Rule:** code-check.md "Written data outlives the fix"

## Outside the diff (not a finding on this branch)

`crossref_item()` maps a CrossRef author that has only `name` (an organisation, as on Royle 2004's record) to a
creator with empty first and last names. This branch's Royle 2004 row avoids it with `override=creators`; a future
DOI row with such a record and no override would file an empty creator.
