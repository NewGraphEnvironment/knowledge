# Code-check round 1 — staged diff (cred port of the rag scripts)

Reviewed `git diff --cached` (12 files: 4 deletions, 1 addition, 7 modifications) against the
Code Check Conventions in `CLAUDE.md`. Checks were run, not reasoned about: all four staged R files
parse; the `stop()` guard message was rendered; `match.arg` and `COLLECTIONS` parsing were probed on
every input shape; the `collection_keys()` SQL was executed read-only against the real
`~/Zotero/zotero.sqlite` as a positive control (84 keys from two collections, no junk `file:` path
created by the URI); duckdb 1.5.2 was checked for a leftover WAL after `dbDisconnect()` without
`shutdown = TRUE` (none — so `ACTION=push` straight after 0152 is not blocked).

## Findings

- **[fragile — data loss]** `scripts/0150-store.R:70-71` — `ACTION=query` always calls
  `crd_store_connect(store, dir = ...)` with cred's default `verify = TRUE`. For any store name
  already in `log.json`, a local file whose md5 differs from the manifest is re-downloaded and
  `file.rename()`d over it (`cred/R/store.R:227-264`). That is exactly the state after
  `ACTION=build OVERWRITE=TRUE`, after a 0152 ingest, and after a 0156 dedup — so the natural
  "build/ingest -> query to check it -> push" sequence destroys the unpushed embedding run, and the
  only signal is cred's `does not match the manifest — re-downloading` message. The 0152/0156
  trailers warn about "anything else [that] opens this store verified", but the script's own query
  action is that thing and offers no unverified path. (A brand-new store name is safe: cred stops
  with "not described in the manifest".) Side effect of the same default: every query now needs
  network + AWS credentials; the deleted `0155` opened the local file directly.
  Fix: pass through an env flag, e.g.
  `verify = !identical(Sys.getenv("VERIFY"), "FALSE")`, and name it in the post-build message and
  the 0152/0156 trailers ("query with VERIFY=FALSE until pushed").

- **[fragile]** `scripts/0150-store.R` (query + push paths), `scripts/README.md:109-112` — the
  `AWS_PROFILE` default was dropped in the port. Deleted `0157-rag-sync.R` had
  `Sys.getenv("AWS_PROFILE", "airvine")`; cred reads `Sys.getenv("AWS_PROFILE")` with no default
  (`store.R:80,86`). On this machine `aws configure list-profiles` returns only `airvine` and
  `AWS_PROFILE` is unset in the agent shell, so every invocation written in the header and README
  fails as written: push -> `Cannot reach the bucket ... profile (<none>)`, query ->
  `Could not fetch the store manifest`. Loud, but the message points at credentials rather than at
  the missing variable, and neither the header nor the README mentions it. Add `AWS_PROFILE=airvine`
  to the usage lines (or set it in `.Rprofile` beside `cred.store_source`).

- **[fragile]** `scripts/0153-reports-to-zotero.py:50` —
  `os.environ.get("ZOTERO_API_KEY") or open(...).read().strip()` has no non-empty guard. The
  poisoned-empty-file case from the conventions (`cmd > file` truncating before a failed `op read`)
  yields `API = ""`; every request then 403s and the first caller, `existing_report_ids()`, dies in
  `json.loads()` on the 403 body — reported as a JSON parse error, not an auth failure. Treating an
  empty env var as unset is correct here; the file needs the same treatment:
  `if not API: sys.exit("Zotero API key is empty: set ZOTERO_API_KEY or re-materialize ~/.config/newgraph/zotero-api-key")`.

- **[fragile]** `scripts/0150-store.R:43-55` `collection_keys()` SQL — two gaps, both inherited
  from cred's `.crd_zot_collection_pdfs()` (so not regressions), but this wrapper is the
  multi-collection path where they compound:
  (a) no `libraryID` filter, and Zotero permits the same `collectionName` under different parents and
  libraries — 84 collection names are duplicated in the local `zotero.sqlite`; `IN (...)` unions
  every collection carrying a matched name and the `%d keys across %d collections` message cannot
  show it.
  (b) trashed items are not excluded — measured 1 item in `deletedItems` still joined for
  `Francois - FRAN` / `Morkill - MORK`; it would be ingested. Cheap fix:
  `LEFT JOIN deletedItems dd ON dd.itemID = i.itemID ... AND dd.itemID IS NULL`.

## Verified clean (asked for specifically)

- SQL string construction: `gsub("'", "''", ...)` is correct SQLite escaping
  (`'O''Brien''s list'` probed); the format string carries no stray `%`; `SELECT DISTINCT` plus
  `unique()` collapses multi-attachment and multi-collection duplicates; the empty-vector case never
  reaches SQL because `COLLECTIONS=""` -> `character(0)` -> `stopifnot` fires; `"a,,b"` and `",a"`
  also refuse; a trailing comma is tolerated.
- `match.arg(Sys.getenv("ACTION", "query"), ...)`: exact and partial (`b`) match; `""`, `Build`
  and unknown values error loudly with the choices listed.
- The `stop()` guards in 0152/0154/0156 parse and render as
  `Pull it with cred::crd_store_connect("fraser", dir = "data/rag") -- do not rebuild.`
- The appended `message()` calls in 0152 (line 71) and 0156 (line 116) sit after the writes and
  after every `quit(save = "no")` early exit; neither script uses `on.exit()`.
- README run order names only scripts that still exist (0100, 0110, 0150, 0152, 0153, 0154, 0156,
  0161, 0162, 0200-0220, plus the wf_*.js). No reference to 0151/0155/0157 remains outside the
  "Replaced ..." history line.
- `data/planning/...` -> `data/...` repoint matches the tracked files (`zotero_key_map.csv`,
  `priority_farmed_all.csv`, `corpus_tags.csv`, `rag_priorities.gpkg/.kml`); `data/planning/` does
  not exist.
- `crd_store_build(store_path, citation_keys =, overwrite =)`, `crd_store_connect(store, dir =)`,
  `crd_search(store, query, top_k =)`, `crd_store_push(store_path, dry_run =)` all match the
  signatures in `cred/R/store.R`; installed cred is 0.3.0 and exports `crd_store_push`.

## Notes outside the diff (not findings)

- `data/pine/context_pine.md:78` still says `Rscript scripts/0155-rag-query.R` — a deleted script.
- `scripts/README.md:139` (unchanged line) says `data/rag_priorities.gpkg` is gitignored; it is
  tracked, as are the `.kml`, `priority_farmed_all.csv` and `corpus_tags.csv`.
