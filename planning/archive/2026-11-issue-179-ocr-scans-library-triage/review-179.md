# Plan review — #179 (Plan agent, 2026-11-21, written here from its reply)

- **Blocker:** a sixth store. Stuart & Chislett (6JK88BUF) is also in `pine - PINE` (B5XW948R); `data/rag/peace.duckdb`
  holds it as `data/rag/_pdfs/peace/XDKIU3UA.pdf`, an old Web-API build named by key. `0150 ACTION=update` refuses
  `peace`. Say it is left out and why, or rebuild it.
- **Ordering:** cred#45. cred reads the live `zotero.sqlite` immutable, and a `replace` keeps the citation key, so with
  the sync still in the `-wal` a build takes the old attachment and skips it again as "no text". Quit Zotero (or wait
  for a 0-byte `-wal`) before each build, and check each new `storage/<newkey>/<file>` exists with the OCR file's md5.
- **Gap:** the backlog edit. #14 is still named in batch 22's row and section and elsewhere; an issue is unplaced only
  where the file names it nowhere. Say whether the PR closes #13 once the rest of #13 has moved.
- **Gap:** the BBT-named sentence is also in `scripts/0150-store.R:36-37` and `scripts/README.md`.
- **Gap:** the triage script's guarded copy: importing 0270 imports 0153, which exits without an API key.
- **Assumption:** cred 0.8.0 is installed now (the plan's first step is done); gates and signatures unchanged; push
  refuses while a `<store>.duckdb.wal` exists; manifest records `ragnar_version` and `store_schema`.
- **Assumption:** public-repo leakage: the CSV must carry groupIDs, not libraryIDs; check each satellite group is
  private on zotero.org; keep names and titles out of the research file, issue bodies, PR text and `progress.md`.
- **Scope:** run `0275 --only <ten keys>`; commit verdict rows before pushing stores.
- **Acceptance:** scans per store (10, 2, 4, 1, 1); origins hold none of the old attachment keys and all the new ones;
  no `-wal` warning in a build log; manifest `store_schema: "0.4.0"`; a verified connect after the push; a read of one rebuilt store on another machine.

## Verdicts

- Sixth store: **confirmed** (`peace` holds `_pdfs/peace/XDKIU3UA.pdf`, 117 docs). Left out, with the reason, in the plan.
- cred#45 ordering: **taken** into Phase 1 (quit Zotero before the builds; check the new files' md5).
- Backlog naming: **taken** into the backlog task; the PR closes #13 and #217.
- Other copies of the sentence: **confirmed** and fixed (`0150-store.R:36`, `scripts/README.md:301`).
- Triage script's key: **confirmed**; the script sets a placeholder key before loading 0270 (it makes no Web API call)
  rather than adding a fourth copy of the guarded reader.
- cred already upgraded: **confirmed**; ticked.
- Public leakage: the CSV carries group ids (`groups.groupID`); all five groups answer 404 to an unauthenticated read
  (private); the research file names groups by id only and no titles.
- `--only` and commit before push: **taken**. Acceptance checks: **taken** (a read on another machine owed after merge).
