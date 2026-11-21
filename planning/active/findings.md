# Findings — statistics store: rebuild under ragnar 0.4.0 so Hedger et al. 2013 joins (#223)

## Issue context

**If done:** Hedger et al. 2013 (`hedger_etal2013Improvingabundance`, the removal-estimator comparison filed under `statistics/detection`) is searchable in the `statistics` store with the rest of the detection literature. **If never:** the store holds every removal paper but that one, and a search for removal-estimator comparisons misses it.

## Problem

#216's rebuild of `statistics` skipped one of its 32 PDFs. ragnar 0.3.1's `markdown_chunk()` fails on the line-numbered accepted manuscript of Hedger et al. 2013 (`snap_nearest()` → `findInterval()`: "'vec' must be sorted non-decreasingly and not contain NAs"). The failure reproduces with ragnar alone: `read_as_markdown()`, then `markdown_chunk()`.

ragnar 0.4.0, the CRAN release, chunks the same markdown into 69 chunks, as tested in a scratch library on 2026-11-16. So upstream has already fixed it; the local ragnar is one release behind.

## Plan

- [x] Blocked by NewGraphEnvironment/cred#43: settle which ragnar cred supports, and whether a store built under 0.3.1 opens under 0.4.0. Settled by cred 0.8.0: it supports ragnar 0.4.0 (CRAN) only; every ragnar reads every store, but 0.4.0 upgrades an older store when it opens it read-write.
- [x] Install ragnar 0.4.0 (with cred 0.8.0, on the machine that rebuilt five stores for #217 on 2026-11-21, knowledge PR #252)
- [ ] Rebuild `statistics` with its whole build list (`scripts/README.md`), Zotero quit. Expect 32 documents, with Hedger added and nothing dropped.
- [ ] Push it, and record the ragnar version in the build log.



## Errors Encountered

| Error | Resolution |
|-------|------------|
