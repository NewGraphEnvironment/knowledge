# Findings — Backlog move 14: Window flow follow-ups (#233)

## Issue context

**If we do it:** we learn whether chinook rearing picks its streams better by late-summer flow than by MAD, and what low flow looks like inside each life-stage window at the gauges, from one set of window-flow outputs. **If we never do:** the rule stays on MAD although #105's Phase 1 found a window reading moves 6.2 % of scored visits, and the window flows stay 30-year means that cannot say how low a stream gets.

Batch 21 of `planning/backlog.md`. Run `/planning-init <this issue>`: one phase per batch, one PR.
When the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue naming move 14, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` places it in another move.

## Batch 21: window flow follow-ups

**Why here:** both are the rest of move 5 (#174): #226 is #105's Phase 2 and #227 the rest of #42. Both read `data/flow_window/` and write `research/chinook_window_flow.md`, and #227's gauge result says whether dry years belong in #226's reading or stay out of it.

**Touches:** `R/link_walks.R`, `inst/sql/`, `scripts/0310-evidence-build.R`, `data-raw/segment_window_flow.R`, `data/flow_window/`, `data/tune/flow_window/`, `research/chinook_window_flow.md`, `research/chinook_stream_size.md`

**Decide at the gate:** #226's walk: edit the published walk (its md5 moves and every key regrades) or add a separate window walk; whether the window column enters the published evidence build or a tagged `EVIDENCE_DIR`; and how much of #227 is wet's (its open work on monthly error by region and season, and on donor departures at ungauged sites). Scoring only: grading, comparing or publishing a window rule waits on Al's word.

| issue | title |
|---|---|
| #226 | Chinook rearing on window flow: tune the rule on late-summer flow beside MAD (#105 Phase 2) |
| #227 | Low flow in life-stage windows: 7-day minimums and dry-year departures (rest of #42) |


## Errors Encountered

| Error | Resolution |
|-------|------------|

## The flow query is slow on a few segments (2026-11-22)

`knw_link_flow(conn, <2 ids>)` took 168 s on the published build's database: `dbWriteTable()` leaves the temporary
table without statistics, the planner assumes thousands of rows and joins the whole network. `ANALYZE` on the table
brought `.knw_link_flow_sql()` to 3 s. `test-link_flow.R`'s live tie test (two lines) takes 160 s for the same reason.
`.knw_link_flow_window()` analyses its table; `knw_link_flow()` is unchanged on this branch.

## The monthly flow table's key holds `forcing` and `period` (2026-11-22)

`discharge.fwa_v1_segment_monthly`'s primary key is (scenario, forcing, source, linear_feature_id, month, period), so
one row per source and month under `historical` is a property of the load, not of the table. The window walk takes a
segment only where it finds exactly the window's months on one source; Phase 4 counts the picked segments that fail
that before walking.

## Four visits hold a tied parent's flow from before #161 (2026-11-22)

The evidence run stopped on its first pass: 4 of 45,529 visits' MAD, read again, was not the published `mad_pick`
(`172777_1_1` TABR, `95183_49_1` and `97120_75_1` LHAF, `95796_73_1` UPCE). Each sits on a river-polygon line (edge
1250) with no flow of its own and two parents 0 m away; the published evidence (built 2026-11-03) took one, and the
query since #161 (0.4.32) takes the lower id. None is in a stream-branch scoring population. The script now requires
equality at every visit with a flow of its own and at every scored visit, and counts the tied ones.

| Error | Resolution |
|-------|------------|
| `Error: 4 visits' MAD, read again, is not the evidence's mad_pick` | parent ties from before #161; equality is required where the flow is the visit's own and at scored visits, the rest counted |

## readr does not round-trip a double (2026-11-22)

The evidence tables are written by `readr::write_csv()`, which writes 15 significant digits
(`0.0512872131147541`), and read by `readr::read_csv()`, whose parse of a 17-digit number is not the nearest double:
13,936 of 45,529 window flows written with `%.17g` read back 1 to 8 units in the last place away. So a number in the
evidence is a 15-digit value as readr reads it, which is why Phase 1 held MAD to `1e-9` and not to equality. The
window column is written at 15 digits like every other number of the table, and held to what it reads back as within
`1e-12` of its size; the published columns' text is unchanged, so they read back identical.

| Error | Resolution |
|-------|------------|
| `Error: the window flow does not read back as it was computed` | `%.17g` through readr is not exact; write 15 digits as readr does, hold the read-back to 1e-12 |
