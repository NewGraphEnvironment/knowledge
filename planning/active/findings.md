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
| `aws` not found over ssh to m1 (`0150 ACTION=query VERIFY=TRUE`) | m1's non-login shell lacks `/opt/homebrew/bin`; export it on `PATH` first. The AWS keys come from `~/.Renviron`, so read the bucket through `Rscript`, not the shell's `aws` |

## Phase 1, 2026-11-21

- m1: cred 0.8.0, ragnar 0.4.0, `cred.store_source` `s3://fresh-bc/rag/`, Ollama `nomic-embed-text`, checkout clean on
  `main` at `e126a7f6`, `storage/CBBACKUJ/hedger_etal2013_accepted.pdf` present.
- The bucket's `statistics`: 31 documents, 11,113 chunks, 153,890,816 bytes, pushed 2026-11-17 under cred 0.7.0; its
  manifest entry has no `ragnar_version` or `store_schema`.
- Membership (a copy of m1's `zotero.sqlite` with its `-wal`): 47 distinct members, 32 keys with one live PDF each,
  the same 15 left out as #216's. Expected: 1 added (Hedger), 0 dropped.
- The pulled store's origins are `/Users/airvine/Zotero/storage/...`, m1's own paths, so the build's before/after
  comparison by origin is valid there.
- cred records the manifest's `repo`, `branch` and `head_sha` with `.crd_git_provenance(dirname(store_path))`
  (`.crd_store_describe()`), which is why the build and push move to a worktree of this branch.

## Phase 2, 2026-11-21

- The rebuild on m1 (2026-11-21T19:23Z to 19:31Z, cred 0.8.0, ragnar 0.4.0) matched the expected file: 32 keys,
  15 left out (the same 15), 32 documents and 11,182 chunks, "31 documents before, 32 after: 1 added, 0 dropped", no
  Skipped warning, no `-wal` warning. The 69 chunks it gained are the 69 the issue measured for Hedger under 0.4.0.
  Bates 2024 was read with pdftools again, and ESL's two oversized chunks were split again, as in #216.
