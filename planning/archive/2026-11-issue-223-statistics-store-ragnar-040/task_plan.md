# Task: statistics store: rebuild under ragnar 0.4.0 so Hedger et al. 2013 joins (#223)

#216's rebuild of `statistics` skipped one of its 32 PDFs. ragnar 0.3.1's `markdown_chunk()` fails on the
line-numbered accepted manuscript of Hedger et al. 2013 (`snap_nearest()` → `findInterval()`: "'vec' must be sorted
non-decreasingly and not contain NAs"). ragnar 0.4.0, the CRAN release, chunks the same markdown into 69 chunks.

## Decided at the gate

- Al approved the plan, 2026-11-21.
- Run host: m1 (cred 0.8.0 already there, #217's builds ran there); m4's cred upgrade stays #217's owed item.
- No code or doc change: no tracked prose says Hedger is missing (only `data/detection_additions.csv` names its PDF).
- The issue comment of 2026-11-19 (cred updated everywhere before the push; a fresh build writes the 0.4.0 schema;
  the manifest records `ragnar_version` and `store_schema`) is taken in under Context and Phase 3.

## Context

#216's build of the `statistics` store (2026-11-16) ingested 31 of its 32 live PDFs: ragnar 0.3.1's
`markdown_chunk()` failed on Hedger et al. 2013's line-numbered accepted manuscript
(`hedger_etal2013Improvingabundance`, attachment `CBBACKUJ`, in `detection` `73PNRGJF`). ragnar 0.4.0 chunks it.
cred 0.8.0 (supports ragnar 0.4.0 only) is released, and the issue's first two boxes are ticked. The comment of
2026-11-19 asks two things: cred updated everywhere before the push (#217's archive carries that as owed for the
machines it did not reach; the push here does not depend on it, since every ragnar reads a 0.4.0 store), and it
notes that a fresh build writes the 0.4.0 schema directly with no size growth, and that the push's manifest entry
now records `ragnar_version` and `store_schema`. Both are taken in below.

Outcome: the bucket's `statistics` store holds 32 documents (Hedger added, none dropped), built fresh under
ragnar 0.4.0, with the build and push logs committed.

## Where it runs (found in exploration)

- **m1**, which rebuilt and pushed #217's five stores on 2026-11-21: cred 0.8.0, ragnar 0.4.0, Ollama with
  `nomic-embed-text`, Zotero synced with `storage/CBBACKUJ/hedger_etal2013_accepted.pdf`. Its checkout is on `main`
  at `e126a7f6`, clean; its `data/rag/statistics.duckdb` is the 4-document copy of 2026-11-10.
- m4 (this session) has cred 0.7.0 and no `data/rag/`, so it does not build. The branch, logs and PR live on m4;
  the logs are copied back with `scp`.
- Tailscale SSH exits 0 whatever ran: every remote step is gated on printed text, the long build runs under
  `nohup` with a `DONE_*` marker holding its exit code, waited on by a remote-side `until` loop in the background.
- The pull (Phase 1) runs from m1's `~/Projects/repo/knowledge`. The build and the push run from a worktree of this
  branch on m1 (`~/knw223/wt`), with a real `data/rag/` holding a copy of the pulled store: cred records the
  manifest's `branch` and `head_sha` from `git -C dirname(store)`, so a run from m1's `main` checkout, or through a
  symlinked `data/rag`, would record `main` (review). Logs are written to `~/knw223/` and copied back; the worktree
  and its local branch are removed at the end. m1's non-login ssh shell needs `/opt/homebrew/bin` on `PATH` for `aws`.

## Phase 1: Before the build (m1)

- [x] Confirm on m1: cred 0.8.0 and ragnar 0.4.0, Ollama answering, the checkout clean on `main`, Hedger's PDF present
- [x] Pull the bucket copy: `ACTION=query VERIFY=TRUE STORE=statistics` with a removal-estimator query (Zippin,
      Carle & Strub, Seber), logged as the before state; read the manifest entry's documents, chunks,
      `ragnar_version`/`store_schema`
- [x] Write `scripts/logs/rag/20261121_rebuild_statistics_expected.txt` the way #216's expected file is written:
      32 keys with a live PDF (the 31 in the bucket plus Hedger), the 15 left out with no live PDF, none dropped,
      checked against the four collections' current membership (anything filed since 2026-11-16 is named there)
- [x] Wait for m1's Zotero to finish syncing, quit it, and confirm a 0-byte `zotero.sqlite-wal` (cred reads
      immutable, cred#45)

## Phase 2: Rebuild (m1)

- [x] Push this branch; on m1 fetch it, `git worktree add ~/knw223/wt <branch>`, copy the pulled store into its
      `data/rag/`, and confirm `git -C ~/knw223/wt/data/rag rev-parse --abbrev-ref HEAD` names the branch

- [x] `ACTION=build OVERWRITE=TRUE STORE=statistics COLLECTIONS="LP4R4VYR,73PNRGJF,Z7JP8UN2,K2P7XGFG"` (the build
      list in `scripts/README.md`), run in the worktree, header lines naming #223, the expected file, the before-state log and cred/ragnar versions, start and
      end times, as #217's `20261121_rebuild_*.log` do → `scripts/logs/rag/20261121_rebuild_statistics.log`
- [x] Check the log against the expected file: 32 documents, "31 before, 32 after: 1 added, 0 dropped",
      no "Skipped" warning and no `zotero.sqlite-wal` warning; any difference is explained in findings before the push
- [x] Same removal-estimator query on the rebuilt store, logged: Hedger is returned
- [x] Reopen Zotero on m1

## Phase 3: Push and record

- [x] Dry run `ACTION=push STORE=statistics` (no `CONFIRM`): the manifest entry shows `ragnar_version` 0.4.0 and
      `store_schema` 0.4.0
- [x] `CONFIRM=TRUE` push; read its result before any verified connect (CLAUDE.md, the #172 case)
- [x] `scripts/logs/rag/20261121_push_statistics.log` in #217's form: the other stores' manifest entries left out,
      this store's entry kept (`documents: 32`, `branch` this branch, `ragnar_version`, `store_schema`)
- [x] Commit the logs on the branch; tick the issue's remaining boxes in its body, saying the comment's "update cred
      everywhere before pushing" was deferred to #217's owed item (m4 still has cred 0.7.0), not met
- [x] Remove the m1 worktree and its local branch

## Validation

- [x] The build log says 32 documents, Hedger added, 0 dropped, nothing skipped
- [x] The after-query returns Hedger; the push log records `documents: 32`, this branch, `ragnar_version: 0.4.0`
- [x] `/code-check`: the branch adds logs and planning files only, nothing that runs; a review of the logs for host
      names, home paths and private repository names stands in for it (the public-repo rule, the #217 rewrite)
- [x] PWF checkboxes match landed work; `/planning-archive`, then `/gh-pr-push`

