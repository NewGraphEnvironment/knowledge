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

## Reader checks, enumerated by the rows each one sees (code-check round 2 -> 3)

Round 2 found the split-at-1-January check scoped to complete rows only, inside round 1's fix of
the same check. The mechanism is **row scope**: each check runs over a subset, and a subset chosen
for one check (overlap needs both ends) was reused for another (split does not). Every check in
`knw_timing_read()` and the subset it sees:

| check | rows seen | right scope? |
|---|---|---|
| column names | header | yes |
| trim, blank -> NA | every cell | yes |
| no wsg_code / species_code | all rows | yes |
| life_stage in vocabulary (NA refused) | all rows | yes |
| MM-DD, real date | every non-NA start/end | yes |
| neither start nor end | all rows | yes |
| start == end | rows with both | yes (needs both) |
| overlapping windows | rows with both | yes: a half window covers no defined days |
| split at 1 January | all rows (fixed round 2) | yes |
| filter code absent | requested codes vs all rows | yes |

Accepted: a half window beside a full one for the same key is not checked for overlap, because
its extent is unknown.

## Round 3 -> enumeration across both callers (terminal)

Round 3 named the mechanism: every check decides "absent" or "the case" with its own local
predicate, and the seed never normalized, so the reader's blank rule (round 2) did not reach it.
Fixes: the seed now applies the reader's blank rule once after `read.csv` (trim `[\h\v]`, "" -> NA);
the reader's overlap check counts a half window's known day; the whole-year exclusion is the same
in both callers; an empty filter is refused.

Every predicate in `scripts/0260-timing-seed.R` (grep of `is.na|%in%|duplicated|nzchar|stop|==|ifelse`),
all of which now read normalized cells:

| predicate | rows | notes |
|---|---|---|
| species / stage / citation_3..6 / downstream-displacement stopifnots | all source rows | loud |
| `dated`, `other_dated` | all area-rows | normalized, so whitespace is undated |
| citation destination (`dest`) and `lost` log | all area-rows, **before any drop** | replaces the post-drop `before_cite` |
| `across` | dated rows | same condition as `dest`'s cross-area branch |
| year / MM-DD / backwards | dated rows | loud |
| repeat drop | dated rows | carries cite **and note** |
| split merge | all rows per key, whole-year excluded from both halves | as the reader |
| invariants | day sets (full), half windows (identity), citations (token `%in%`, not substring) | plus round-trip through `knw_timing_read()`, which applies every reader check in the table above to the output |

The three cases round 3 measured were re-run on a mutated template copy: whitespace citation ->
unsourced with the "to confirm" note; one-area citation beside a cited dated area -> logged as not
carried; note on the dropped repeat -> carried. Real-data output unchanged byte for byte.
