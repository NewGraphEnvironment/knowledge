# Findings — Validate the fieldwork-prep pipeline on UPCE from the M1 (#4)

All of this was measured on 2026-09-03 during planning, before any phase ran. Nothing here has
been fixed yet.

## Machine state (m1, arm64)

| | |
|---|---|
| **We are already on the M1** | `hostname` = `m1`. The issue is framed as "from the M1"; no remote driving is needed. |
| R / packages | R 4.5.2; `cred` 0.3.0, `ragnar` 0.3.0, `duckdb` 1.5.2, `sf` 1.1.2, `bcdata` 0.5.3, `RPostgres` 1.4.10 all present. |
| `knowledge` pkg | **not installed** — `0100`/`0110` use `pkgload::load_all("pkg")`, so cwd must be the repo root. |
| Ollama | present, `nomic-embed-text` installed. A rebuild is therefore *possible*, which is the silent-rebuild risk the issue names. |
| Databases | bcfishpass tunnel `:63333` **OK**; local fresh-db `:5432` **OK**. Both verified through R, launched from `~` (see B1 — from the repo root they fail). |
| Shell `psql` | cannot connect: the fresh-db credentials live in `~/.Renviron`, which is R-only. Undocumented. |
| Zotero | `~/.config/newgraph/zotero-api-key` present, 0600, 24 bytes. `~/Zotero/zotero.sqlite` present, 152 MB, synced today. `ZOTERO_API_KEY` is **not** set in `~/.Renviron` — the file fallback is the only path. |
| AWS | `aws` 2.34.34; identity is `arn:aws:iam::<acct>:user/airvine` — the **full** identity, not a scoped read-only field key. rtj#194 item 3 remains open. Record, do not block. |

## Dependency state

- **template#207 (the sync this issue blocks on) is CLOSED** — 2026-09-03T00:34Z. The blocker is cleared.
- cred#22 (`crd_store_build`/`crd_search`/`crd_store_connect`) and cred#24 (`crd_store_push()`
  merge-on-write) both **closed**. `cred` 0.3.0 is installed, so the manifest-merge fix is
  available and Phase 5 is its first real exercise.
- rtj#194 **open** — items 3 (M1 scoped read-only IAM) and 4 (field runbook) outstanding.
- knowledge#3 **open** — content tagging / `zotero_key_map`.

## The store cache is already warm, so the pull path is unreachable

`s3://fresh-bc/rag/` holds `fraser` (734 MB), `peace` (227 MB), `pine` (28.6 MB),
`vca_refs` (46 MB) and `log.json`. Local `data/rag/` holds the first three, and **all three
md5s match the manifest**:

```
fraser  MATCH  642d874e42b3f7a07dd8b202ec0ecfb5
peace   MATCH  970dc5caa87d3681728099fc93375d23
pine    MATCH  f8356685bc0104f952353cd52daf9e26
```

`0150-store.R:87` sets `verify <- !file.exists(store_path) || VERIFY=="TRUE"`, and
`crd_store_connect()` only downloads on absence or md5 mismatch. So on this machine the connect
**always takes the warm no-op path** and the acceptance criterion "M1 pulls rather than
rebuilds" cannot be tested as-is. Phase 2 forces the cold path by moving the file aside — the
standard cold/create-path rule from `code-check.md`.

Also worth knowing: no script in this repo ever falls back to building. `0152`, `0154` and
`0156` all hard-stop with "pull it -- do not rebuild". The only rebuild path is a human or
agent reaching for `ACTION=build` after hitting that stop, which on a partially-synced Zotero
library produces a *smaller* store that looks healthy and then overwrites the bucket copy.

## UPCE is genuinely untouched

Zero hits for `UPCE`/`upper peace` in `scripts/`, `pkg/`, `CLAUDE.md` or `README.md`. No
`data/upce/`. It appears only as:

- an unrun target in `planning/archive/2026-07-issue-198-fieldwork-prep-pipeline/README.md:66`
- an FWA code appearing incidentally inside PINE's FISS rows (`00000UPCE`/`01273UPCE` on
  Shangweshi, Maurice, Dinosaur Lake records) and in `data/pine/gnis_seed_ambiguity.csv:4`

`data/` currently carries 11 group dirs: `bowr cotr fran lchl mcgr necr pcea pine tabr ufra will`.

## The six blockers

Each is silent, which is why none has been noticed.

### B1 — a project `.Renviron` shadows `~/.Renviron` entirely

`/Users/airvine/Projects/repo/knowledge/.Renviron` (untracked, gitignored via the global
`~/.gitignore:19`, created 2026-09-02 during the repo seeding) contains exactly one line:
`CRED_STORE_SOURCE=<value>`.

R's startup rule: when a project `.Renviron` exists, R reads it **instead of** the user one.
So every `PG_*_SHARE`, `PG*`, `AWS_*` and `GITHUB_PAT` is invisible to any R process launched
from the repo root. Measured: `PGPORT` is `5432` from `~`, empty from here.

It is also redundant — `.Rprofile:3` already sets `options(cred.store_source = "s3://fresh-bc/rag/")`,
and its comment explains that it lives there *because* `~/.gitignore` drops `.Renviron`. Someone
then added the `.Renviron` anyway.

Being untracked, it affects only this machine. It was found precisely *because* this is the cold
run. Fix in Phase 1; assert afterwards rather than assuming.

### B2 — `0153-reports-to-zotero.py:43-47` cannot accept a new group

`COLLECTIONS` is a hardcoded 9-entry dict of Fraser codes → Zotero collection keys, with
`GROUP = "4733734"` at line 37. The script never creates a collection.

- `--reports UPCE:...` → `coll = COLLECTIONS[code]` at line 294 raises an uncaught `KeyError`.
- `--from-store` → line 270 tests `m.group(1).upper() in COLLECTIONS`, so UPCE is **silently
  filtered to zero targets** with no error at all.

The Peace codes (PINE/PCEA/PARA) are missing too — filing any Peace harvest already requires
editing the source. This is the step `scripts/README.md:79-85` calls out as **"Never skip"**.

Separate hazard at line 50: the key is read at import time, so if `ZOTERO_API_KEY` is unset
*and* the file is missing, an uncaught `FileNotFoundError` fires before `argparse` — even
`--help` and `--dry-run` fail. Only the empty-file case gets the friendly exit.

### B3 — `0161-priority-farm-reconcile.R:77-79` hardcodes the Fraser group set

```r
FRASER <- c("BOWR","MCGR","COTR","WILL","UFRA","TABR","FRAN","LCHL","NECR")
cross_files <- cross_files[toupper(basename(dirname(cross_files))) %in% FRASER]
```

A new group's `data/<wsg>/crossings.csv` is filtered out of the reconciliation union, so every
UPCE farmed row stays `unmatched` and keeps only the harvest tag. Silent. This is the same
mechanism as the Hooft 2015 multi-watershed bug the archived README calls "the single most
important lesson in the module" — the fix generalized the *matching* but left the *group set*
a literal.

### B4 — `0162-priority-spatialize.R:28,164-167` hardcodes the same vector

Used to build the `ST_Union` clip polygon. Every UPCE point falls outside it and is dropped at
line 167. Silent, apart from a "dropped N point(s) outside the Fraser watershed-group union"
message that reads as normal.

### B5 — `gnis_seed.csv` has no producer

`0110-gnis-collision-check.R:18` reads `data/<wsg>/gnis_seed.csv` and its own header says
"(from the PSCIS pull)". But `0100` writes only `reports.csv`, `crossings.csv` and
`pscis_<wsg>.gpkg` (lines 58-62). Grep across the repo finds only readers, never a writer — the
committed seeds were produced by hand, and their schemas disagree (`gnis_base,n` in `bowr`,
`gnis_base,n_crossings` in `pine`).

So **step 2 of the documented run order cannot run for a new group.** `scripts/README.md` never
mentions the file, nor that it is also the source of `gnis_names` for the harvest workflows.

### B6 — the cross-group deliverables are overwritten wholesale, and one is not reproducible

| script:line | writes | mode |
|---|---|---|
| `0161:129` | `data/priority_farmed_all.csv` (~9,257 records) | `write_csv` — full overwrite |
| `0154:116` | `data/corpus_tags.csv` (283 rows) | full overwrite, from a **single** `STORE` |
| `0162:175-177` | `data/rag_priorities.{gpkg,kml}` | `delete_dsn=TRUE` / `delete_layer=TRUE` |

Running any of these for UPCE alone destroys the committed Fraser deliverables. All four files
are git-tracked, so git is the recovery path — but:

**`priority_farmed_all.csv` cannot be regenerated.** `0161` rebuilds it from `FARM_JSON`
(workflow task `.output` files or `journal.jsonl`), and on this machine there are **zero**
journals and exactly **one** surviving farm extract out of ~218. So the correct-looking
remedy — "re-run 0161 with every group's FARM_JSON" — is not available. `0161` has to be made
to merge.

`0154` has the same shape one axis over: it tags one store, and UPCE is going into `peace`
while the committed `corpus_tags.csv` is fraser-derived.

Note on counting: `wc -l` gives 6,258 for `priority_farmed_all.csv` against ~9,257 records —
embedded newlines in the free-text fields. Any before/after guard must count by **parsing**.

## Recorded, out of scope for this issue

The FISS `.xls` track (`0200`/`0210`/`0220`) is not in the acceptance criteria.

- `0220:324` hard-`stop()`s without the `:63333` tunnel, no 5432 fallback — while
  `scripts/README.md:167-170` implies the tunnel may be droppable for that track.
- `wf_peace_report_harvest.js:11` hardcodes `/private/tmp/claude-501/-Users-airvine-Projects-repo-fish-passage-template-reporting/...`
  — uid, user, a different repo and a dead session id. Unrunnable; the README calls it "kept for
  the record" without saying so. A plain `grep /Users/` misses it because the path is
  dash-encoded.
- `0160-priority-enrich.R:19,27,92-97` is hardcoded to `data/pine/`, not `WSG_TARGET`.
- `data/<wsg>/priority_farmed.{gpkg,kml}` in the 9 Fraser dirs are **orphans** — no script in
  any commit ever wrote those filenames. A new group's run will not produce them and should not.
- `0100`'s header comment (line 15) is stale: it claims `acat_report_point_pub_svw` is pulled
  via bcdata; the script does no bcdata pull.
- `0110:27` falls back to "the first `information_schema` table carrying both `gnis_name` and
  `watershed_group_code`" — on a machine with only the local fresh-db this **silently picks an
  arbitrary table**.
- `fraser.duckdb` holds 21 documents with extents `fraser` (20) and `FRAS` (1). `0154`/`0156`
  accept them; `0152`'s uppercase-only glob and `0153`'s `COLLECTIONS` test do not, so they are
  invisible to filing.
- `data/zotero_key_map.csv` joins on `basename(origin)` = `<ATTACHMENT_KEY>.pdf`, matching the
  legacy `0151` layout. The current `crd_store_build()` produces `~/Zotero/storage/<KEY>/<original
  filename>.pdf` — a **third** naming shape that matches neither. A freshly rebuilt store's
  key-named half silently drops out of both `0154` attribution and `0156` dedup.
- The manifest's `built_by` for `fraser` still points at `fish_passage_template_reporting`
  script paths, and `peace`/`pine` reference `scripts/0151-rag-build-from-zotero.R`, which this
  repo no longer has (superseded by `0150-store.R`).

## Undocumented in `scripts/README.md`

Env vars read by scripts but absent from the README: `MAX_MB` (nowhere in the repo),
`SOFFICE_BIN`, `VERIFY`, `DRY_RUN`, `TOPK`, `PDF_PATH`, `OVERWRITE`. Also absent: the
`ZOTERO_API_KEY` / key-file requirement, AWS credential setup, `pdftotext` (poppler), the
postgres authentication for `user=newgraph` on `:63333` and the tunnel command itself, the R
package set beyond `pkg/DESCRIPTION`'s eight imports, Python 3 for `0153`, that **cwd must be
the repo root**, and that the `WSG_TARGET` default differs between scripts (`PCEA` in `0100`,
`PINE` in the other five) so an unset variable silently pulls the wrong group.

## Subagent / model economics

Neither workflow script passes a `model` option, so both run at the session default:

- `wf_report_harvest.js:35,77` — one search agent plus N batched acquire agents.
- `wf_farm_priority.js:88-89` — **one agent per PDF**, against `ROW_SCHEMA`.

The README puts farming at ~4M subagent tokens per ~120 reports. The mechanical half
(`pdftotext` → grep → schema-valid JSON) looks like a good Haiku fit; the judgment half — which
table is a priority table, which of 26 free-text `table_source` values applies, mapping report
wording to high/moderate — is where a smaller model would degrade **silently**, returning
well-formed JSON with wrong rows while every schema check passes.

Testable rather than guessable: the Fraser farm is already done, so Haiku can be run over a
handful of already-farmed PDFs and diffed against the known-good rows in
`priority_farmed_all.csv`. Cheap, and it settles the question with ground truth. Not yet
verified whether `agent()` inside a Workflow script accepts a model override the way the
`Agent` tool does — confirm before relying on it.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `psql: fe_sendauth: no password supplied` on `localhost:5432` while `nc` reported the port open | The fresh-db credentials are in `~/.Renviron`, which only R reads. Connect through R, or export explicitly. An open port is not a usable connection. |
| `Error: invalid integer value "NA" for connection option "port"` from `Rscript` at the repo root | B1 — the project `.Renviron` shadows `~/.Renviron`, so `PGPORT` was empty. Diagnosed by running the same command from `~`, where it returns `5432`. |

---

# Phase 1 — preflight results (2026-09-04)

## B1 fixed

`.Renviron` at the repo root held exactly one line, `CRED_STORE_SOURCE=s3://fresh-bc/rag/` —
byte-identical in effect to `.Rprofile:3`. Backed up, then removed. Asserted afterwards from the
repo root rather than assumed:

```
PGHOST/PGPORT/PGUSER/PGDATABASE/PGPASSWORD   SET
PG_{HOST,PORT,USER,DB,PASS}_SHARE            SET
AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY    SET
GITHUB_PAT                                   SET
cred.store_source                            s3://fresh-bc/rag/   (via .Rprofile option)
```

`ZOTERO_API_KEY` and `MAX_MB` remain empty — both expected: 0153 falls back to the key file, and
`MAX_MB` defaults to 25.

## Preflight assertions — all pass

| check | result |
|---|---|
| `pdftotext` | `/opt/homebrew/bin/pdftotext`, poppler 26.04.0 |
| `python3` / `aws` / `ollama` / `Rscript` | all present |
| `soffice` | **on PATH** at `/opt/homebrew/bin/soffice` — this **corrects** the earlier note that macOS keeps it inside the app bundle and off PATH. Homebrew put it there. `SOFFICE_BIN` is not needed on this machine. |
| ollama model | `nomic-embed-text` present |
| fresh-db `:5432` from repo root | OK |
| bcfishpass tunnel `:63333` from repo root | OK |
| **UPCE exists** | `UPCE` / **Upper Peace River** / **5,820 km²**, identical from both databases |
| Zotero key file | present, 0600, non-empty |
| Zotero group `4733734` | reachable, HTTP 200 |

## The click-per-report problem — diagnosed and fixed

The user's top constraint was not being asked to approve every report download. Cause found in
the code rather than guessed:

- **`wf_report_harvest.js:69,72` runs two `curl` calls per report** inside each harvest subagent.
  `curl` was not in the allowlist, so that is **two approval prompts per report** across
  dozens-to-hundreds of reports. This is the time sink.
- **`0153-reports-to-zotero.py` is not affected** — it uses Python `urllib` inside a single
  process (`0153:103,191,202`), so filing every report is **one** prompt total.
- Also unallowed: `python3`, `aws s3 cp` (store pull/push), `pdftotext`, `ollama` — one prompt
  per invocation each, not per item.

Fixed in `.claude/settings.local.json` (machine-local; gitignored via `~/.gitignore:28`).
Deliberately **not** tracked in git: a tracked settings file auto-applies on pull, which makes it
a privilege-escalation path via commit. Cross-machine sync is filed as
NewGraphEnvironment/rtj#272, which also raises that the same concern applies to the existing
`soul/settings/defaults.json` + `/claude-settings-init` mechanism.

## B2 groundwork — and a collection layer that has drifted

Paging mattered. A default `/collections` request returns **100**; the group actually has
**253**. Reading only the first page would have been the "paged API default reads as absence"
trap — the conclusion "UPCE is absent" was re-derived across all pages before anything was
written, and again immediately before the create.

Checked for pre-existing Peace-region collections under any name before creating (carp, crooked,
parsnip, halfway, beatton, moberly, kiskatinaw, graham, finlay, omineca, nation, williston).
Nothing covered Upper Peace, so the create is not a duplicate.

**Two naming conventions coexist under `Fisheries / regions / mackenzie`:**

| collection | key | items | follows `<name> - <CODE>`? |
|---|---|---|---|
| `pine - PINE` | B5XW948R | 69 | yes |
| `pine - PINE` … `peace arm - PCEA` | 9QAJJJQW | 16 | yes |
| `parsnip arm - PARA` | 9TP5AFIG | 11 | yes |
| `nation - NATR` | PZZRTUEA | 5 | yes |
| `parsnip` | 7UFY2AG3 | **28** | **no code** |
| `carp` | K3EY3KED | 0 | **no code**, empty |
| `crooked` | X5XMBBZU | 0 | **no code**, empty |

`0153` resolves a collection by watershed-group code, so the three code-less collections are
unreachable to it — including `parsnip`, which holds 28 items, more than `parsnip arm - PARA`'s
11. Whether those two overlap is unresolved and worth a look before any Parsnip run. `carp` and
`crooked` appear to be placeholders created and never filled.

**Created:** `upper peace - UPCE`, key `WKUMAXBK`, parent `5USQ8DRG` (`mackenzie`), to the
`<name> - <CODE>` convention. Verified by re-reading it back from the API.
