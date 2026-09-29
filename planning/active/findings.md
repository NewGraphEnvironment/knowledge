# Findings — Life-history timing table per watershed group (#25)

## Issue context

**If we do it:** life-history timing (when each species migrates, spawns, incubates, emerges and outmigrates) becomes a per-watershed-group table with sources, readable by reports and by flow and temperature analyses that ask "what were conditions during spawning migration". **If we never do:** timing stays in one report template's CSV, hard-wired to two areas, and each consumer re-types it.

## Problem

`fish_passage_template_reporting/data/inputs_raw/fish_species_life_history_gantt.csv` holds the only structured timing table we have:
- It is wide, with one start/end column pair per area (`bulkley_start1`, `morice_start2`).
- Dates sit on a dummy 1900 year.
- Windows crossing 1 January are encoded two ways: split into two rows, or given an end date in 1901.
- Citations are Zotero keys spread over six columns.

Reports use it only to draw a Gantt chart.

## Proposed Solution

A long table under `data/`, one row per `wsg_code` × `species_code` × `life_stage` × window:

| column | notes |
|---|---|
| `wsg_code` | `BULK` and `MORR` to seed |
| `species_code` | bcfishpass codes (`CH`, `CO`, `ST`, `SK`, `BT`, `CT`) |
| `life_stage` | controlled vocabulary: migration, spawning, incubation, emergence, rearing, overwintering, outmigration |
| `start`, `end` | month-day (`MM-DD`); `start > end` means the window crosses 1 January; one row per window |
| `source` | Zotero key(s) |
| `note` | free text, including "to confirm with knowledge holders" |

- Seed it from the template CSV, with a script that records the reshaping.
- Add a small reader in `pkg/` that filters by group and species. Its `start`/`end` columns go straight into a date-window function, such as the one planned in NewGraphEnvironment/wet#25.
- Once this lands, the template's Gantt chunk can read from here instead (separate template issue).

The table is not gospel. It is an example of a CSV-driven system, and every row carries its source so it can be challenged.


Part of #19, which covers life-cycle timing (item 4) alongside habitat thresholds in one literature store. This issue is the timing table. #19's Zotero collection and ragnar store supply its citations.

## Source CSV, read 2026-09-28

What the source actually contains (read directly):
- Year-crossing windows encoded **three** ways: split pairs (`08-01..12-31` + `01-01..03-31`), a 1901
  end date (BT Bulkley incubation `09-01..1901-04-30`), and that 1901 row **duplicated** because its
  sibling row exists only to split the Morice window.
- Stages outside the issue's vocabulary: `Downstream displacement` (no dates anywhere → drops out) and
  `Upstream fry migration` (CH Bulkley 07-15..09-07 has dates).
- A half window: CO Migration Bulkley start 08-15, no end.
- Pacific Lamprey (one dated row, MORR spawning) — not in the issue's six species; FISS code `PL`.
- Citations are positional: `citation_1` = Bulkley, `citation_2` = Morice in every dated row but one
  (CH upstream fry migration: Bulkley dates, key in `citation_2`). Cols 3-6 are empty.

## Errors Encountered

| Error | Resolution |
|-------|------------|
