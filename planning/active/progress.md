# Progress — Validate the fieldwork-prep pipeline on UPCE from the M1 (#4)

## Session 2026-09-03 — planning only, PARKED

- Synced `CLAUDE.md` with soul conventions (no change — already current at `c6a3110`).
- Planned #4 in plan mode. Three `Explore` agents mapped the run order, the store/Zotero
  lifecycle, and the farm/reconcile + `data/` layout.
- Probed the machine directly rather than trusting the issue's framing. Two things the issue
  assumed turned out different:
  - **We are already on the M1** (`hostname` = `m1`), so no remote driving is needed.
  - **template#207, the stated blocker, is closed** (2026-09-03T00:34Z), as are cred#22 and
    cred#24. The sync exists.
- Found six blockers, all silent, recorded in `findings.md` as B1-B6. B1 (a project `.Renviron`
  shadowing `~/.Renviron`) was found only because this is a cold run, and would have produced a
  confusing auth failure at `0100`.
- Established that the store cache is already warm — all three local md5s match `log.json` — so
  the "M1 pulls rather than rebuilds" criterion is untestable without forcing the cold path.
- Established that `priority_farmed_all.csv` is **not reproducible**: zero workflow journals on
  this machine and 1 of ~218 farm extracts surviving, so `0161` must be made to merge rather
  than overwrite.
- Decisions taken with the user: fix forward and generalize; ingest into `peace.duckdb` and
  push; harvest authorized, farm gated on a real report count.
- **Parked before Phase 1** to reserve weekly token budget. Nothing has run and nothing is
  fixed.
- Commits: this baseline.
- Next: Phase 1 (preflight), starting with B1.

### Note on this directory

`review-round{1,2,3}.md` here are code-check records from the repo-seeding work (`d29809f`),
not part of this issue. They predate this branch and were left in place.
