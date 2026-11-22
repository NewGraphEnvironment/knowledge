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
