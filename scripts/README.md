Fieldwork-prep: harvest the past-reports corpus for a watershed group, make it searchable, farm the
priority tables out of those reports, and export a field layer.

Run per watershed group (`WSG_TARGET`), or across a whole project region. Proven on Peace
(PINE/PCEA/PARA) and Fraser (BOWR/MCGR/COTR/WILL/UFRA/TABR/FRAN/LCHL/NECR).

**Why-decisions live in each script's header block**, not here — they stale-check with the code.
This file is the run order and the wiring.

<br>

## Run order

```
0100  PSCIS pull per watershed group          WSG_TARGET=COTR
0110  GNIS name-collision QA (before any name search)
wf_report_harvest.js / wf_bowr_mcgr_harvest.js   harvest reports  -> <extent>__<reportId>.pdf
0152  dedup-ingest the harvested PDFs into a ragnar store
0153  file the reports to Zotero (ALL documents)  <- do not skip; see below
wf_farm_priority.js                          farm priority/crossing tables out of the PDFs
0161  reconcile farmed rows -> PSCIS, stamp watershed_group_code
0162  spatialize -> rag_priorities.gpkg
0150  query the rag store            ACTION=query STORE=fraser QUERY="..."

0154  content-tag the corpus (any time after 0152)
0156  dedup the store        (before pushing it)
0150  push the store         ACTION=push STORE=fraser CONFIRM=TRUE  <- after ANY local write

--- FISS .xls track (independent of the report/PDF flow above; opt-in) ---
0200  enumerate the data-only .xls submissions per group   WSG_TARGET=PINE
0210  fetch them            FISS_FETCH=TRUE   <- deliberate; pulls dozens-to-hundreds
0220  parse -> normalize -> flag No-Fish-Captured -> GPKG + CSV clipped to the group
```

## Report discovery — four axes

A report is reachable from more than one place; using only one axis misses reports.

1. **FISS `acat_report_url`** — the biggest source. `fiss_stream_sample_sites_sp`,
   `fiss_fish_obsrvtn_pnt_sp`, `fiss_obstacles_pnt_sp`, clipped to the watershed-group poly.
2. **Region-unique GNIS stream names** — run `0110` first; names repeat across BC.
3. **Thematic keyword phrases** — "fish passage \<group\>", "habitat confirmation \<name\>". Finds
   planning/priority reports the other axes structurally miss.
4. **`[PSCISnn]` project ids** — the `ecocat_url` on PSCIS assessments is often
   `advancedSearch.do?keywords=[PSCIS1180]`, not a `reportId`. Resolve it by fetching that search
   URL and reading the `viewReport.do?reportId=` out of the result. Low yield overall, but this is
   the only axis that reaches some reports (Hooft 2015 / EcoCat 50797 came in this way).

**Geo-filter every name/keyword hit** — EcoCat matches same-named streams province-wide.

<br>

## 0100-pscis-acat-reports.R
- Pulls the 4 PSCIS SVW layers (assessment / habitat confirmation / design proposal / remediation),
  spatially clipped to a watershed group (the raw layers carry no `watershed_group_code`)
- Emits `data/<wsg>/crossings.csv` (+ `reports.csv`, `pscis_<wsg>.gpkg`)
- `crossings.csv` is the reconciliation target for 0161 — `external_crossing_reference` is the key

## 0110-gnis-collision-check.R
- Counts how many watershed groups province-wide share each stream name
- Run BEFORE any name-based report search; "Boulder Creek" is in 12 groups

## wf_report_harvest.js / wf_bowr_mcgr_harvest.js
- `wf_peace_report_harvest.js` is the region-specific ancestor of `wf_report_harvest.js`, kept for the
  record; `wf_keyword_backfill.js` re-harvests by keyword for groups whose first pass ran thin
- Multi-agent harvest: geo-filtered EcoCat search + batched resolve/download/verify
- `wf_report_harvest.js` takes one group; `wf_bowr_mcgr_harvest.js` takes several at once
- Writes `<EXTENT>__<reportId>.pdf` into a harvest dir

## 0152-rag-add-harvest.R
- Ingests a harvest dir into an existing ragnar store, deduped by EcoCat reportId
- `STORE=fraser HARVEST_DIR=/path/to/harvest`
- Needs Ollama up (`nomic-embed-text`)

## 0153-reports-to-zotero.py
- Files each harvested report into its watershed-group Zotero collection, **with every document
  EcoCat serves for it attached** — main report + appendices + map sheets + data files
- `python3 0153-reports-to-zotero.py --from-store data/rag/fraser.duckdb` (or `--reports COTR:137,157`)
- Idempotent: reports already in the collection are skipped; Zotero dedups files by md5
- **Never skip this step.** The rag store holds only extracted text and the harvest dir is in `/tmp`;
  Zotero is what a store rebuild (`0150-store.R`) reads. A group harvested + ingested but not filed silently vanishes
  on the next rebuild or on another machine. (Learned the hard way — COTR/FRAN/LCHL/NECR were
  ingested in July 2026 and had to be re-downloaded from EcoCat to be filed.)
- Reads the store's `EXTENT__reportId.pdf` origins, so reportIds are recoverable even after the
  harvest dir is reaped

## 0154-corpus-tag.R
- Content-tags every document in the store from **table captions, headings and opening text** —
  not the title — and writes `data/corpus_tags.csv`
  (`report_id, watershed_group_code, tags, n_table_captions, farmed, n_priority_rows`)
- Regex over stored text, no LLM pass; runs in seconds
- Answers "what do we actually have?" without farming. Farming is expensive (~4M subagent tokens per
  ~120 reports) and most reports yield no priority rows, so tag first and farm deliberately
- Joins the farm outcome, which is what surfaces **table-dense reports that were never farmed** —
  the class of miss that a title-keyword triage produces (EcoCat `53762` ranks 28 salmon streams by
  10 sensitivity indices and was skipped as "narrative")
- Uses `data/zotero_key_map.csv` to resolve legacy Zotero-attachment-key origins to
  reportIds; without it those documents look un-farmed even when they were farmed

## 0156-rag-dedup.R
- Removes duplicate documents before a store is published or synced. The same report can enter under
  two names — `EXTENT__<reportId>.pdf` (harvest) and `<ATTACHMENT_KEY>.pdf` (a Zotero build) —
  and a duplicated report gets **two chances at every retrieval**, biasing search
- Keeps the harvest-named copy (it carries the watershed group)
- Two store internals it has to work around, both recorded in the script: `embeddings` has an **HNSW
  index** so a connection must `INSTALL/LOAD vss` before `DELETE`, and **`chunks` is a VIEW** so
  deletes must target `documents` + `embeddings`

## 0150-store.R — build / query / push through `cred`
- The ragnar stores live in `s3://fresh-bc/rag/` with a `log.json` provenance manifest;
  `.Rprofile` points `cred` at it. Pull: `Rscript -e 'cred::crd_store_connect("fraser", dir = "data/rag")'`
  (md5-verified against the manifest). Push: `ACTION=push STORE=fraser CONFIRM=TRUE Rscript scripts/0150-store.R`
- **Push after every local write** (`0152` ingest, `0156` dedup, a rebuild). The next verified
  connect replaces a local file whose md5 no longer matches the manifest with the bucket copy —
  an unpushed ingest is simply gone
- `ACTION=build STORE=<name> COLLECTIONS="<zotero collection>[,...]"` builds a **citation-key-named**
  store from the local `~/Zotero` (no API key). That naming carries no watershed group and no
  reportId; it needs `data/zotero_key_map.csv` to join the farm. Group-scoped work goes through the
  harvest (`wf_report_harvest.js` → `0152`), which names documents `<EXTENT>__<reportId>.pdf`
- The manifest records document/chunk counts, **embedding model + size**, bytes, md5 and the
  `head_sha` that produced it. A store built with a different embedding model is not comparable, so
  pull rather than rebuild. The `rag/` prefix stays **private permanently**: these stores accumulate
  unpublished reports, at-risk-species and culturally-important-site locations
- Semantic search is weak on proper nouns — for a specific creek name, grep the PDFs
- Replaced `0150`/`0151` (build), `0155` (query) and `0157` (sync) in September 2026; `cred` 0.3.0

## wf_farm_priority.js
- One agent per report PDF; lifts priority / crossing / habitat-reach tables into structured rows
- Rows carry the report's OWN crossing id (+ the PSCIS id when the report prints one)
- `kind` per target picks the extraction hint: crossing / recon / restoration / habitat / permit

## 0161-priority-farm-reconcile.R
- Reconciles farmed rows against the **union of all groups' crossings** and stamps the true
  `watershed_group_code` — a report tagged to one group often covers several
- `FARM_JSON=` accepts task `.output` files **or** workflow `journal.jsonl` (journals outlive outputs)
- Emits `data/priority_farmed_all.csv`

## 0162-priority-spatialize.R
- Writes `data/rag_priorities.gpkg` (tracked — a small deliverable):
  - `rag_priorities` — report-flagged **fish-passage crossing** standouts only
  - `rag_sites_all` — every placed site; filter by `table_source` for deactivation / riparian /
    habitat priorities
- `priority_rank` 1=high 2=moderate 3=low 4=ruled-out, NULL=no priority stated
- `coord_source` records provenance: `pscis` (surveyed) > `report-utm` (transcribed) >
  `stream-snap` / `stream-snap-parent` (approximate — placed on the named FWA stream)

## 0200 / 0210 / 0220 — FISS `.xls` → No-Fish-Captured layer

A separate track from the report/PDF flow: the FISS layers link to **data-only `.xls` submissions**
(fish-collection permit data), not narrative reports. Those carry site-level effort and survey
comments — including the negative results ("electrofished 1200 m, caught nothing") that no standard
product gives you, and that should stop a crossing being prioritized on a reach already sampled
fishless.

- `0200` — `acat_report_url` on `fiss_fish_obsrvtn_pnt_sp` is a `viewReport.do?reportId=N` **page**,
  not a file; the `.xls` are attachments on it. Scrapes them into a per-group manifest.
- `0210` — **opt-in** (`FISS_FETCH=TRUE`). ~40% of legacy `.xls` fail readxl/libxls with
  *unsupported encryption*; a LibreOffice `--convert-to xlsx` fallback recovers them (PINE: 44 ok +
  33 converted = 77/77).
- `0220` — column set is **passed config** (`wanted_cols`), not hardcoded. Header is auto-detected by
  anchoring on the `REFERENCE NUMBER` label row, because row 1 of the provincial template is a title
  banner (`fpr::fpr_import_hab_con()` assumes a row-1 header and yields `x, x_2, …` here).
  NFC is taken from the sheet's own `No Fish Caught` value (`nfc_source = "submitted"`); a real zero
  count with recorded effort is `"derived"`. Blank counts are **not** treated as zero.

PINE: 77 submissions → 1,610 site records → 411 clipped to PINE, 142 NFC (128 submitted, 14 derived).

**Note:** these three still connect on the bcfishpass tunnel (`:63333`). Per *Data sources* below the
layers they need (`fiss_fish_obsrvtn_pnt_sp`, `fwa_watershed_groups_poly`) are on the local `fwapg`
at 5432, so they could likely drop the tunnel dependency — untested, so not changed.

<br>

## 0140 / 0160 — Guppy-specific (Peace)
- `0140` farms the Guppy 2006 Table 8 priority list; `0160` enriches it with bcfishpass metrics
- Predate the generalized farm; kept for the Peace pipeline

<br>

## Data sources

- **Local fresh-db (`fwapg`, port 5432)** carries the PSCIS SVW layers, FISS fish observations
  (`acat_report_url`), `fwa_watershed_groups_poly` and `fwa_named_streams` — so most of this runs
  with **no SSH tunnel**. `fiss_stream_sample_sites_sp` / `fiss_obstacles_pnt_sp` and the bcfishpass
  model columns are remote-only (tunnel on 63333). See the `db-newgraph` skill.

## Gotchas worth knowing before you start

- **A report can span several watershed groups.** Harvest tags it with one extent; reconcile
  per-crossing or you silently lose the sibling groups' sites.
- **"Priority" is domain-specific.** Road-deactivation prescriptions and riparian reaches use the
  same high/moderate wording as fish-passage priorities. Filter by `table_source`.
- **Recon reports number reaches 1,2,3…** — those are not crossing ids; don't reconcile them.
- **Don't harvest NGE's own reports from EcoCat** — they're stale; sync from the repo instead.
- **An EcoCat report is usually SEVERAL documents** — 3 to 19 observed (report `163` has 19): main
  report, appendices, 1:20k map sheets, and `.xls`/`.zip` data files. The harvest workflows take only
  the **first** PDF, so the rag store holds one document's text per report; `0153` files all of them
  to Zotero. Two consequences: (a) the first PDF is not always the main report — report `52264`'s is
  `Appendix1`; (b) the FPCI form spreadsheets carrying per-site *no fish captured* comments (see
  [NewGraphEnvironment/fish_passage_template_reporting#199](https://github.com/NewGraphEnvironment/fish_passage_template_reporting/issues/199)) and the
  inventory map sheets are **not** in the rag. Widening the harvest to all documents is open work.
