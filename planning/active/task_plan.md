# Task: Life-history timing table per watershed group (#25)

`fish_passage_template_reporting/data/inputs_raw/fish_species_life_history_gantt.csv` holds the only structured timing table we have:
- It is wide, with one start/end column pair per area (`bulkley_start1`, `morice_start2`).
- Dates sit on a dummy 1900 year.
- Windows crossing 1 January are encoded two ways: split into two rows, or given an end date in 1901.
- Citations are Zotero keys spread over six columns.

Reports use it only to draw a Gantt chart.

## Decisions (recommended defaults — approving the plan takes these; say if any should change)
1. **Vocabulary** adds `fry_migration` (upstream) to the issue's seven; `Downstream displacement` has no
   dates and is not carried.
2. **Pacific Lamprey kept** as `PL`.
3. **Citations positional** (col1→BULK, col2→MORR); the CH fry-migration row takes `citation_2` for
   BULK with a `note` saying so.
4. **Half window kept** with `end` NA and a note; the reader returns it, documented. Rows with no source
   get note "no source in template; to confirm with knowledge holders".

## Phase 1: Reader in pkg (tests first)
- [x] `pkg/tests/testthat/test-timing.R`: filters by wsg and species (vector or NULL = all); refuses an
      unknown `life_stage`, a malformed `MM-DD`, an impossible date (`02-30`), missing columns; accepts
      `start > end` (crosses 1 Jan) and an NA end; zero-row filter returns the typed empty frame
- [x] `pkg/R/timing.R`: `knw_timing_read(path, wsg_code = NULL, species_code = NULL)` — reads CSV as
      character, validates schema + vocabulary + `MM-DD` (checked against a leap year so `02-29` is
      legal), filters, returns a tibble. Style follows `knw_size_class()` (`chk`, `stop(call. = FALSE)`);
      vocabulary exported as `knw_timing_stages()`, like `knw_pscis_layers()`
- [x] roxygen + runnable `@examples` (tempfile CSV), `devtools::document()`; DESCRIPTION Description
      line mentions the timing table; add `readr`/`utils` only if needed (prefer `utils::read.csv`)

## Phase 2: Seed script + table
- [ ] `scripts/0260-timing-seed.R`: header block (why/design, input, output); reads the template CSV
      from the sibling checkout (`TEMPLATE_DIR`, default `~/Projects/repo/fish_passage_template_reporting`,
      stops if absent) and logs its commit SHA
- [ ] Reshape: pivot areas → `wsg_code`; species names → codes; stages → vocab; strip year to `MM-DD`,
      1901 end → crossing window; merge a `..12-31` + `01-01..` pair within wsg×species×stage into one
      `start > end` row; drop exact duplicates and all-NA windows; attach sources and notes
- [ ] **Invariant check in the script**: per wsg×species×stage, the set of covered days-of-year before
      and after reshaping is identical (catches a lost, doubled or mis-merged window); plus every
      non-empty citation cell in a dated row lands in some `source`
- [ ] Write `data/life_history_timing.csv`; round-trip it through `knw_timing_read()`
- [ ] Commit the run log under `scripts/logs/` (evidence: source SHA, row counts, invariant result);
      add 0260 to `scripts/README.md` run order + section

## Phase 3: Wiring
- [ ] File a template issue (fish_passage_template_reporting): Gantt chunk reads from
      `knowledge/data/life_history_timing.csv`; note the vocabulary/code mapping
- [ ] CLAUDE.md `data/` root list gains `life_history_timing.csv`

## Validation

- [ ] Tests pass; restore one validator and see its test go red
- [ ] `/code-check` clean on each commit
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
