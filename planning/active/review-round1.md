# Code-check round 1: #19 phase 1 (literature reader, 0150 collection scoping)

Reviewer: subagent, 2026-09-29. Suite: `devtools::test(filter = "literature")` gives 31 pass, 0 fail.
`collection_keys()` was run against the local zotero.sqlite (immutable, read-only), using a copy of the function.

## Findings

- **[bug] pkg/R/literature.R:69-70**: `read.csv(..., fileEncoding = "UTF-8-BOM")` stops at the first byte
  that is not valid UTF-8. It raises only warnings, and the truncated table then validates clean.
  The warnings are `invalid input found on input connection` and `incomplete final line` / `EOF within quoted string`.
  Measured on a scratch copy by putting one cp1252 degree sign (0xB0) into a `quote` cell:
  - Bad byte in data row 3 of 4: **0 rows returned**. With `species_code = "BT"` the extra warning is
    "species_code not in the evidence table: BT", so the loss reads as "no evidence for BT".
  - Bad byte in row 8 of 10: **8 rows returned**. Rows 9-10 are dropped silently, and row 8's quote is cut short.

  This table is more exposed to it than the timing table. `quote` is verbatim text from PDFs, so it will
  carry degree signs, micro signs, en dashes, <= and curly quotes. A hand edit saved as Excel "CSV" (not
  "CSV UTF-8") writes cp1252/MacRoman bytes. `knw_timing_read()` (timing.R) has the same read line, so it
  is pre-existing there, and the fix belongs in both.

  Fix: check the bytes before parsing. Read them with `readBin(path, "raw", file.size(path))`, drop a
  leading `EF BB BF`, and `stop()` unless `validUTF8(rawToChar(b))`. Alternatively, turn the connection
  warnings into an error. The error should name the file and the fix
  ("re-save as CSV UTF-8").

- **[fragile] pkg/R/literature.R:46-48 vs .literature_check()**: the docs say a `none` row "carries a
  `note` ... and no value, key or quote". The code refuses only a value or unit on a `none` row. A `none`
  row with a stray `citation_key`/`quote` passes (measured). A downstream count of "sources per variable"
  would then count a search that found nothing as a citing source. Either refuse it or reword the doc.

- **[fragile] pkg/R/literature.R:103 (`first()`)**: "(row N)" is the data-frame row index. In a
  spreadsheet or text editor that row is N+1 (the header), and it is further off after any `quote` cell
  holding an embedded newline. The comment says the number exists "so a hand edit can be found", and it
  points one row early. Say "data row N", or report `N + 1` as the file line.

- **[fragile] scripts/0150-store.R:59-62**: collections are resolved without excluding
  `deletedCollections`. Library 9 currently has one trashed collection (`3XZYB9D8`). If a trashed
  collection is the only match for a name, the build quietly uses it. If a trashed duplicate exists, a
  live name is refused as ambiguous. Low impact today. `AND c.collectionID NOT IN (SELECT collectionID FROM deletedCollections)` closes it.

## Not a defect in this diff, but it will stop the planned build

- The Phase 2 build command in `task_plan.md` passes `JI7EBZNF` (group `aquatic/hydrology`). That
  collection holds only **2 standalone attachments**: no parent item, so no citation key. With the
  current collection list, `collection_keys()` aborts the whole build with
  `No keyed PDF items in collection(s): JI7EBZNF` (reproduced).
  Drop it from `COLLECTIONS`, or file those PDFs under parent items first.

## Checked and fine
- Name/key resolution: `pine - PINE`, `species,temperature`, `chinook`, `bull_trout`, `wedzin_kwa_chinook`
  and `X29BX4U8` all resolve. `hydrology` is refused, and the refusal lists both keys with their parents.
  A personal-library key (`RGCKKU25`) is refused, and so is a non-numeric `GROUP_ID`.
- No collection name in the database equals another collection's key, so name/key matching cannot cross.
  The SQL is parameterised or takes numeric ids, and the old string-interpolated `IN (...)` on names is gone.
- NA handling in the vocab loop (`%in%`, required vs optional), the numeric/`MM-DD` checks and the
  `value_min > value_max` check. Each new test goes red when its guard is removed, because the fixture
  reaches every refusal.
- Roxygen block placement and NAMESPACE exports are correct, and `get(arg)` resolves the formals.
