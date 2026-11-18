# Findings — Backlog move 5: Chinook flow windows and timing (#174)

## Issue context

**If we do it:** life-stage timing comes from cited sources and NuSEDS for more groups, and we learn whether flow in the months chinook use a stream sizes it better than MAD. **If we never do:** the timing table stays two groups with one open row, each repo keeps its own NuSEDS copy, and the CH rearing rule stays on MAD untested.

### Batch 8. Timing table and NuSEDS
- **Why here:** one table (`data/life_history_timing.csv`) and one new source; NuSEDS spawn dates are #96's main input.
- **Touches:** `data/life_history_timing.csv`, a new NuSEDS fetcher in `R/`, a records table under `data/`, `inst/NOTICE.md` (a new tracked source needs its row).
- **Decided at the gate:** where the NuSEDS table lives and what it publishes; NuSEDS's licence read from its catalogue record.

| issue | title |
|---|---|
| #31 | BULK coho migration has no end date |
| #96 | Chinook timing for UFRA (Swift Creek) and COTR |
| #108 | Salmon records per stream: NuSEDS, provincial fish observations and literature, in one table |

### Batch 9. Flow in windows
- **Why here:** #105's Phase 1 needs #42's window mean per segment; both read wet's monthly segment flows on the database's host.
- **Touches:** `research/chinook_window_flow.md`, `research/chinook_stream_size.md`, a `data-raw/` script; nothing under `data/tune/` outside `flow_window/`.
- **Decided at the gate:** #105's stop rule, set before Phase 1 runs; Phase 2 and anything that publishes wait on Al's word. Daily flow (#42's 7-day minimum) is no longer blocked upstream.

| issue | title |
|---|---|
| #42 | Flow in Chinook life-stage windows on FWA segments |
| #105 | Chinook rearing: does flow in a seasonal window size streams better than MAD? |


---

Backlog: `planning/backlog.md`, move 5. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.





## Errors Encountered

| Error | Resolution |
|-------|------------|
