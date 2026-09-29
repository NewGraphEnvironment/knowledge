## Outcome

The only structured life-history timing table, the reporting template's wide Gantt CSV, is now
`data/life_history_timing.csv`: one row per watershed group × species × life stage × window, with
`MM-DD` dates (`start > end` crosses 1 January) and a citation per row. BULK and MORR are seeded from
it. `scripts/0260` records the reshape, and `knw_timing_read()` in `pkg/` reads and filters the
table. The reader validates the whole file, so a hand edit cannot reintroduce the things the seed
had to undo: overlapping windows, windows split at 1 January, off-vocabulary stages and blank codes.
Decisions taken at the plan gate:
- `fry_migration` added to the stage vocabulary;
- Pacific Lamprey kept as `PL`;
- citations mapped by column position (citation_1 to Bulkley, citation_2 to Morice);
- a half window kept with an NA end.

What we learned:
- The template encodes a year-crossing window three ways, one of them a duplicate row.
- The Gantt chunk that consumes the table lives in the report repos, not the template.
  That work is filed as fish_passage_template_reporting#238.

## Measurement

- 41 template rows became 38 table rows:
  - 6 split pairs merged;
  - 1 repeated 1901 row dropped;
  - 1 half window (BULK CO migration) kept.
- 27 citations were carried. One citation on an undated row (CH rearing, Skeena Fish) was logged as
  not carried. One was taken across columns (BULK CH fry migration).
- 11 rows have no source in the template and are flagged "to confirm with knowledge holders".
- The day coverage invariant held for 37 keys. Two deliberate mutations of the script tripped it:
  skipping the repeat drop, and a mis-merged end date.
- Code-check ran 3 rounds with 13 findings, all fixed. Rounds 2 and 3 each found a defect in the
  previous fix, in the same mechanism: each check tested "blank", "a split" or "doubled" with its own
  local predicate, and the seed script never normalized blanks. The loop ended on an enumeration of
  every predicate in both callers (`findings.md`), not on a quiet round. Every guard was shown to go
  red when disabled.

## Evidence

`scripts/logs/timing/20260928_*` — template commit 49f90154 read, and the rows merged, dropped and
re-cited.

Closed by: PR (this branch, `25-life-history-timing-table-per-watershed`)
