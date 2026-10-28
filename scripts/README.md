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
0200  enumerate the data-only .xls submissions per group   WSG_TARGET=COTR  (required, no default)
0210  fetch them            FISS_FETCH=TRUE   <- deliberate; pulls dozens-to-hundreds
0220  parse -> normalize -> flag No-Fish-Captured -> GPKG + CSV clipped to the group; reconcile gate
      (also writes Step 2 life stage and Step 3 individual fish, raw, per group)

--- FDIS electrofishing export (province-wide, not per group) ---
0230  sync s3://fresh-bc/fdis/, QA, roll passes to site visits, place on FWA with fresh's snap and the 1:50k code
      (#91; fwapg database (PG* env vars), fresh >= 0.40.0; SNAP_LIMIT / SNAP_LIMIT_CODE override the limits)
0240  size classes + CH / char evidence + summary vs thresholds -> data/fdis_*.csv

--- FISS individual fish -> size-class evidence (after 0220 on each group, and 0230) ---
0250  Step 3 fish + Step 2 counts, deduped against FDIS -> data/fiss_evidence.csv (fwapg database (PG* env vars))

--- Life-history timing (independent; re-run only when the template's Gantt CSV changes) ---
0260  reshape the template's Gantt CSV -> data/life_history_timing.csv   (read with knw_timing_read())

--- One evidence build and one tuning run for every species (#57; needs link >= 0.66.0, fresh, wet's flow,
    fresh_default province-wide, and the link repo at LINK_REPO) ---
0300  wait until link's run has settled in fresh_default (log_recompute ended for every group, churn
      unchanged over three polls, no active session) -> scripts/logs/habitat/<date>_link_settle.csv (released row)
0310  one evidence build: quality-passed FDIS visits x every species (catch, size classes, presence, blocked
      absence, DV pooling), placed on link's segments with every species' access and re-gated habitat flags,
      wet's flow by source, cw_deploy, regulated reach, natural barriers downstream per species, walks to
      rivers of 1-50 m3/s on each source (to the river's bank, counting every hop's gap, fresh's convention; #73),
      hydrologic zone, the bcfishobs match, link#349's access check, the
      workbook sites -> data/fdis/derived/{visits_link,visits_species,walks,bcfishobs_fdis_match,access_check,
      workbook_sites,workbook_species}.csv (+ ledger; 4 socket workers). SCHEMA names link's schema (default
      fresh_default; knw_build_record() refuses one another run built); the visit walks are kept in knw.walk_cache
      from #91, so the first run walks them cold; knw_db_latency_check() at connect stops a run off the
      database's host (round trip over 20 ms) unless REMOTE=TRUE (#110)
0290  bt_use_visits.csv written from 0310 (BT's rows and the columns 0291-0293 read; no held-out columns)
0294  ch_mad_visits.csv written from 0310 (+ two database reads: ambiguous placement, barriers without USER_DEFINITE)
0296  ch_rule_visits.csv and ch_rule_walks.csv written from 0294 and 0310
0320  a smoke run on four gates first, for every key (#84; a failure scores nothing), then score every rule of each
      species x stage on held-out groups (the shared gradient ladder to 30 %, #68; link's default_tuned row as a
      candidate; the fit absorbs the group intercepts and holds the data-set and era terms under a normal prior,
      #83, #84), pick from link's width default and from its flow version (#80), fit the joint curve with the same
      prior, grade every segment of the species' groups, each accessible one at its own walked distance to the bank
      of the pick's river (#65, #73), each grade table recording its reference edges, river size, walk, flow build
      and curve prior (#72); a key whose curve is no better than no rule on held-out groups gets no grade (#73)
      -> data/tune/ (+ log; SCHEMA names the run's schema, refused when its run is not the evidence's; scoring runs
      on any machine with the build, WORKERS=14; grading walks 500 segments per query and keeps every walk in
      knw.walk_cache, keyed on the flow load and the walk's md5 (#87): on the database's host a cold regrade of
      every key took 53.4 min and one key regraded with the walks cached 4.1 min, 2026-10-27; CLAUDE.md
      "Database access"; a grading run stops off the database's host unless REMOTE=TRUE, #110)
0322  #67's record: CH rearing alone on the ladder extended to 30 %, on the evidence build before #73 (the main
      run carries that ladder for every species since #68): the scores -> data/tune/grad_ext/; STAGE=compare
      sets CH_rear_v1's parts at 11, 13, 15 and 30 % beside default and beside CH_rear_v1 -> data/compare/grad_ext/
      (+ logs). Writes nothing 0325 or 0330 reads; not rerun
0325  thresholds table (the near-river pair in link's parameter names since link 0.67.0, the picks from both
      starts), the groups each rule was scored on, and the grade table as Parquet + manifest
      -> data/publish/{thresholds_v1,habitat_grade_v1}/, data/thresholds*.csv; refuses a grade graded on another
      flow build than the live one; PUBLISH=TRUE uploads to s3://fresh-bc/knowledge/{thresholds,habitat_grade}/v1/
      (after the bucket policy of #56)
0330  link's current default (the configs at CONFIG_SHA, origin/main by default; link >= 0.67.0, whose near-river
      pair is walked on the scratch copy with fresh's walk) against the recommended rule on link's segments for
      every species x stage and group, under each rule structure for the through-wetland lines and the pair (#73:
      free | door | door_wetland; `tuned` is TUNED_AS, door by default): km, graded km, km by grade class, change by
      reason, FDIS and bcfishobs checks -> data/compare/, one GeoPackage per species x stage for QGIS
      (data/compare/gpkg/, #81; GPKG=FALSE skips them while iterating, STAGE=gpkg writes them afterwards from the
      saved segments) (+ log; SCHEMA as 0320; on the database's host, keys in turn, each key's groups split across
      WORKERS=6 connections, #87: every key 162.9 min with GPKG=FALSE, BT rearing alone 33.4, the GeoPackages
      14.0, 2026-10-27; every STAGE stops off the database's host unless REMOTE=TRUE, #110). No maps in this run.
      STAGE=maps: floodplain ha beside each rule's habitat in the catalog's groups, and the maps, from the saved
      tables -> data/compare/floodplain.csv, research/fig/compare_*.png
      then SCHEMA=... Rscript data-raw/vignette_chinook.R refreshes the chinook article's data (inst/vignette-data/),
      after 0325 has rewritten data/thresholds.csv; tests/testthat/test-vignette-data.R fails until it does

--- Frozen on the published v2 tables (0299 PULL=TRUE VERSION=v2): the one-species analyses #57 superseded ---
0291  BT use curve (#28)   0292  BT candidate weight   0293  BT spawner evidence (#33)
0295  CH detection by MAD class (#52)   0297  CH rule tuning (#54)   0298  CH rule beside default (#54)
      They read the v2 bt_use_visits / ch_mad_visits / ch_rule_* tables and are not run on v3's.

--- Publish the FDIS visit tables (after any of 0240, 0290, 0294, 0296 changes its table) ---
0299  data/fdis/derived/*.csv -> Parquet + manifest.json in data/fdis/publish/; with PUBLISH=TRUE (clean
      tree) uploads them to s3://fresh-bc/knowledge/fdis/<VERSION>/ (default v3; v2 is the pre-#57 set) and
      data/fdis_README.md to s3://fresh-bc/fdis/README.md
      PULL=TRUE [VERSION=v2] restores data/fdis/derived/*.csv from the published Parquet (NO_SIGN=TRUE: no credentials)

--- Habitat literature (independent of the watershed-group flow) ---
0270  build the group's Fisheries/habitat_modelling collection   --dry-run first, then live
      (--collection temperature: Fisheries/temperature, from data/temperature_members.csv)
      (--collection flow: Fisheries/flow, from data/flow_members.csv and data/flow_additions.csv)
0150  ACTION=build STORE=habitat_modelling COLLECTIONS="U9ZCZ6RN,chinook,bull_trout,..."  then ACTION=push
0150  ACTION=build STORE=temperature COLLECTIONS=SW2RXUJC                                  then ACTION=push
0150  ACTION=build STORE=flow COLLECTIONS=FWTJDD8Z                                         then ACTION=push
      (a rebuild over an existing local store needs OVERWRITE=TRUE; ACTION=push needs CONFIRM=TRUE to upload)
0280  verify data/literature_evidence.csv and data/ip_model_registry.csv against their PDFs, and the
      model_id link between them (gate; read with knw_literature_read() / knw_ip_read())
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
- `COLLECTIONS` takes names or 8-character Zotero collection keys and resolves them **inside the NGE group
  library only** (`GROUP_ID=` for another group), skipping trashed collections. A name that occurs twice in
  the group (`hydrology`, `salmon`) is refused and its keys are printed; pass a key. A name that exists only
  in a personal library no longer resolves (it used to, and a name in both was refused).
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

## 0230 / 0240 — FDIS electrofishing export → size-class evidence

Province-wide, from the FDIS export the Province supplied (`s3://fresh-bc/fdis/`, published as received
with the Province's agreement; `research/fdis_export.md` documents it). Electrofishing only. Individual fish lengths, weights
and maturity, per-pass effort, measured channel width and gradient, and explicit zero catch
(`NFC`): none of it is in the public FISS layers.

- **Grain is the site visit**, not the pass: depletion passes repeat one population.
- **Abundance comes from `counts`**; `details` is a length subsample (87% of counted CH have no length).
- **Placement (#91):** `fresh::frs_point_snap()` (500 m radius), to the nearest stream and to each stream
  FDIS's own 1:50k watershed code names; `knw_fdis_place()` takes the nearest named stream in reach, else the
  nearest stream. A pick beyond its limit (one for a code-confirmed pick, one for the rest) and a code naming no
  stream in reach are flagged here and dropped by `knw_fdis_quality()` in `0310`.
- **CH gives rearing evidence only**; EF caught no adult CH. Char spawner evidence is maturity
  (SP/ST, or M in Aug–Oct), not length.
- Outputs: `data/fdis_evidence.csv`, `data/fdis_summary_ch_bt.csv`, `data/fdis_size_breaks.csv`,
  `data/fdis_maturity_check.csv` (tracked), and `fdis_sites.{csv,gpkg}` (17 MB each, ignored), which `0299`
  publishes as Parquet to `s3://fresh-bc/knowledge/fdis/v2/`.
- Logs: `scripts/logs/fdis/`.

## 0200 / 0210 / 0220 — FISS `.xls` → No-Fish-Captured layer

A separate track from the report/PDF flow: the FISS layers link to **data-only `.xls` submissions**
(fish-collection permit data), not narrative reports. Those carry site-level effort and survey
comments — including the negative results ("electrofished 1200 m, caught nothing") that no standard
product gives you, and that should stop a crossing being prioritized on a reach already sampled
fishless. Run on five groups (PINE, COTR, UNTH, LNTH, UPCE; #5).

**Prerequisites**

- `WSG_TARGET=<code>` is **required** on all three (or `wsg_target` in an interactive session).
  There is no default: an unset variable used to run PINE silently and overwrite its outputs.
- LibreOffice: `soffice` on PATH (Homebrew puts it at `/opt/homebrew/bin/soffice`), or
  `SOFFICE_BIN=/path/to/soffice`. ~40% of legacy `.xls` fail readxl/libxls with *unsupported
  encryption*; `0210` converts those to `.xlsx` headless. Run groups **sequentially** — parallel
  headless conversions contend for one LibreOffice profile lock.
- Database: `0200` and `0220` connect to the database the `PG*` environment variables name. Point
  them at a bcfishpass database where one is available: its FISS snapshot was a superset of a plain
  fwapg load (measured 2026-09-04, 5 report ids across COTR/UNTH/UPCE existed only there), and `0200`
  says so when the database has no `bcfishpass` schema. `0220` needs only the group polygon. `0200`
  records the database name (`db_source` in `fiss_xls_reports.csv`) so a short manifest is
  explainable; rows written before 2026-10-16 say `tunnel` (a bcfishpass database) or `local_fwapg`
  (an fwapg load).
- R: `curl` (page fetch with explicit HTTP status), `readxl`, `janitor`, `rvest`, `xml2`, `sf`, `RPostgres`.

**What each step writes to `data/<wsg>/`**

- `0200` — `acat_report_url` on `fiss_fish_obsrvtn_pnt_sp` is a `viewReport.do?reportId=N` **page**,
  not a file; the `.xls` are attachments on it. Writes `fiss_xls_manifest.csv` (one row per
  attachment) and `fiss_xls_reports.csv` (one row per page: `page_status` ok / no_xls / http_403 …,
  `n_xls`, `db_source`). ACAT returns **403** for restricted reports (COTR 3 of 47, UPCE 1, PINE 2);
  that is recorded, not retried. A transport failure, 5xx, 408 or 429 is retried once and then
  **stops the run** and removes the manifest, so it can never be silently short.
- `0210` — **opt-in** (`FISS_FETCH=TRUE`). `fiss_xls_fetch_log.csv` carries `idx` + `xls_url` so it
  joins the manifest by key (`file_name` collides across attachments), one row per manifest URL,
  `status` ok / converted / unreadable / download_failed. Two dead links (HTTP 404 on ACAT's side)
  are the only failures across ~230 files.
- `0220` — column set is **passed config** (`wanted_cols`), not hardcoded. Header is auto-detected by
  anchoring on the `REFERENCE NUMBER` label row (rows 26, 31 or 17 across the 2009–2022 editions),
  because row 1 of the provincial template is a title banner. UTM zone is parsed as its leading
  digits (`"11U"` is common on North Thompson submissions and used to drop the site). NFC is taken
  from the sheet's own `No Fish Caught` value, or a zero-catch code from `data/fdis_species_codes.csv`
  (`NFC`, `ZZZ`) in the editions that record codes (`nfc_source = "submitted"`); a real zero count
  with recorded effort is `"derived"`. Blank counts are **not** treated as zero. Either way a site
  is NFC only if **no record there caught anything**: editions before 2016 record NFC per trap or
  pass, and a site with one empty trap beside a full one is `nfc_conflict`, not NFC. **`nfc = NA` means the
  site has no Step 2 record at all** (a location with no fish-collection rows), not FALSE.
  Writes `fiss_xls_parse_log.csv` (one row per workbook × step, with a `status` naming why a step
  yielded nothing: no_sheet_match for tissue-data and summary workbooks, no_header, no_rows …,
  plus `header_row` and the edition `banner`), then the site tables, then `fiss_xls_reconcile.csv`.
  Template editions name columns differently (`species_code`/`species`, `method`/`sampling_method`,
  `haul_or_pass`/`haul_number_pass_number`, `date_yyyy_mm_day`/`survey_date`); `variant_map` folds
  them to one name. Step 3 (Individual Fish Data) is written raw to `fiss_step3_fish_<wsg>.csv`, and
  a per-fish sheet filed under a Step 2 name is read as Step 3 (`fish_layout` in the parse log).
  The reconciliation is a **gate**: manifest ↔ reports ↔ fetch log ↔ parse log are checked before
  any site table is written and site counts after; any failed check exits non-zero.

**Results (inside-group layer; 2026-09-04/05)**

| | PINE | COTR | UNTH | LNTH | UPCE |
|---|---|---|---|---|---|
| report pages / with `.xls` | 78 / 69 | 47 / 30 | 42 / 37 | 58 / 54 | 53 / 45 |
| `.xls` fetched | 77 | 30 | 38 (1 dead) | 56 (1 dead) | 48 |
| workbooks yielding a step | 72 | 29 | 34 | 52 | 45 |
| sites parsed (`_all`) | 1,610 | 736 | 996 | 1,429 | 7,023 |
| inside the group | 411 | 154 | 531 | 619 | 4,921 |
| NFC inside (submitted / derived) | 142 (128 / 14) | 62 (62 / 0) | 136 | 136 | 228 (218 / 10) |
| `nfc` NA inside | 31 | 31 | 0 | 12 | 383 |

Re-run 2026-09-28 (#21) after the edition-variant and NFC roll-up fixes, inside-group NFC:
PINE 142 → 146, COTR 62 → 67, UNTH 136 → 106, LNTH 136 → 90, UPCE 228 → 251. The falls are mixed
sites (a no-fish trap beside a catch) that the old roll-up flagged; the rises are pre-2016 `NFC`
codes it never read. Derived NFC fell (PINE 14 → 2) because a species entered with no count is now
presence, not a zero.

UNTH and LNTH share 10 submissions (both clip the same workbooks). UPCE's inside-group layer is
76% mainstem-named (Peace, Moberly, Dinosaur); 97 of its 228 NFC sites are on tributaries.
Sites outside the linked group are expected — a submission spans groups — and are kept in
`fiss_sites_<wsg>_all.csv`. Run logs: `scripts/logs/fiss/`.

## 0250 — FISS individual fish → size-class evidence

Supplements `0240` (#21). The FDIS export stops at 2020/2022 and at electrofishing; submission
workbooks carry every method.

- **Grain:** site (`site_key`) × species × size class × **method**. Rows match
  `data/fdis_evidence.csv` column for column, with `source` and `method` on both, so the two bind.
- **One group per report:** a report parsed under several groups is taken from the first.
- **Dedupe against FDIS:** no shared key exists. A FISS site is the same survey as an FDIS site visit
  when date and UTM zone agree, the sites are within 50 m, and at least one fish matches on species
  and length (a multiset match: repeated FDIS rows are distinct fish). Only the **electrofishing**
  rows at such a site are dropped. 45 of 68 reports with electrofished fish match ≥ 90 %, 13 match
  none; the radius is not sensitive (50 m → 2 km adds ~1.5 % of matched sites, mostly weak).
- **Life stage vs length:** `data/fiss_stage_vs_class.csv` compares the Step 2 label with the length
  class per fish and per Step 2 row.
- Outputs: `data/fiss_evidence.csv`, `data/fiss_fdis_overlap.csv`, `data/fiss_stage_vs_class.csv`,
  `data/fiss_evidence_reconcile.csv` (a gate: every Step 3 fish lands in one bucket).
- Logs: `scripts/logs/fiss/`.

<br>

## 0260 — life-history timing table

Seeds `data/life_history_timing.csv` from the fish-passage reporting template's
`data/inputs_raw/fish_species_life_history_gantt.csv` (#25). Reads a checkout of it named by
`TEMPLATE_DIR`; the log records its commit SHA.

- **Grain:** `wsg_code` × `species_code` × `life_stage` × window. `start`/`end` are `MM-DD`;
  `start > end` crosses 1 January. Stages are `knw_timing_stages()`.
- **Citations** are positional in the template (`citation_1` Bulkley, `citation_2` Morice).
  `source` holds Better BibTeX citation keys, `"; "`-separated.
- **Split windows** (`..12-31` + `01-01..`) are merged into one row, and 1901 end dates become
  `start > end`. Invariants: day coverage per key unchanged, no day covered twice, half windows and
  citations carried. `knw_timing_read()` refuses overlapping or split windows, so a hand edit
  cannot reintroduce them.
- The table is meant to be edited and challenged. Once edited by hand, do not re-run `0260` over it.
- Logs: `scripts/logs/timing/`.

<br>

## 0270 / 0280 — habitat literature: collection, store, evidence table

The cited basis for CH and BT habitat thresholds (#19). Not per watershed group.

- `0270` builds the group library's `Fisheries/habitat_modelling` collection (`U9ZCZ6RN`). It takes a curated
  key list (`data/habitat_modelling_members.csv`) and adds works no library held
  (`data/habitat_modelling_additions.csv`: CrossRef by DOI, or grey-literature metadata, with a PDF URL or a
  standalone group attachment). `--collection <name>` builds another collection under Fisheries the same
  way, from `data/<name>_members.csv` (and `_additions.csv` if present); `Fisheries/temperature`
  (`SW2RXUJC`, #38) and `Fisheries/flow` (`FWTJDD8Z`, #44) are built that way. An additions `pdf` may also
  be a path from the repo root, for a PDF only a browser can fetch; such copies sit in the ignored
  `data/rag/pdf/flow/`. A member row may give a `pdf` (a URL, or a path from the repo root)
  for an item no local library holds a PDF of, such as an analytic appendix printed from the web.
  A member whose group copy lacks a PDF gets one uploaded from any local library, with three limits:
  - only from an item with the same title, because citation keys are not unique across libraries;
  - linked files from the old Windows machine (`D:\...\storage\...`) are rebased onto Zotero's
    `baseAttachmentPath`;
  - a PDF counts only when the server has its md5.

  Live state is read from the Web API. The local database is read from a **checked copy**, because Zotero
  locks the live file and an `immutable` read during a sync sees half-written pages. Re-runs are no-ops.
- The store is built from that collection plus the species, temperature, hydrology and Wedzin Kwa collections,
  by `0150`. Wait for Zotero to sync `0270`'s writes, and check that the files are on disk, before building.
  The `temperature` store is built from `Fisheries/temperature` alone (`COLLECTIONS=SW2RXUJC`), and the `flow`
  store from `Fisheries/flow` alone (`COLLECTIONS=FWTJDD8Z`). `Fisheries/flow` does not feed `habitat_modelling`
  (the temperature collection does).
- `data/literature_evidence.csv` has one row per value a source gives: species, stage, form, variable, the
  model parameter it bears on, bound, value, unit, `metric`, kind, region, key, page, verbatim quote,
  `quote_source`, scale, cited source and `model_id`. `kind = none` records a search that found nothing.
  Gradient is in percent. `metric` says which statistic a `temperature` or `air_temperature` value is, or the
  window of a `degree_days` total (whose note gives the base temperature), or the flow statistic an
  `instream_flow` need is held to. `discharge` is stream size (usually MAD, the filter an IP model applies);
  `instream_flow` is a flow need, in m3/s, cfs, `percent MAD`, a `percentile` or a `percent exceedance`, and
  carries no model parameter. Depth and velocity are what a fish meets at a site, in the unit the source wrote
  (`m`, `cm`, `ft`; `m/s`, `cm/s`, `ft/s`); a bankfull depth is `m bankfull`. `groundwater` (upwelling,
  hyporheic exchange, springs) takes no unit, so its rows are statements with no value.
- `data/ip_model_registry.csv` has one row per intrinsic-potential model × species × stage. It records how the
  model sizes streams (`flow_metric`, `flow_source`, `flow_inputs`, `flow_surrogate`), its valley-confinement
  variable, and its validation; its flow claim and any validation claimed are each quoted. It holds no
  threshold values: a model's thresholds are the evidence rows carrying its `model_id`.
- `0280` is the gate. Every key must name one live item in the group library with a PDF on disk. Every quote
  must be found in that PDF: normalized text, the numbers of a table cell on one page, or an OCR of a scan,
  cached in `data/rag/ocr/`. Registry quotes (flow and validation) are checked the same way. The `model_id`
  link must hold both ways on model × species × stage × life-history form: no tagged evidence row without a registry row, and no
  registry row without a tagged evidence row. Every timing-table source must resolve, and every species ×
  parameter cell in its `COVERAGE` list must have a row, and every species × cell of its `THERMAL` grid
  (water-temperature upper and lower limits for spawning, incubation and rearing; degree-days to hatch, to
  emergence, and over the growing season for rearing and overwintering) must be met by a value, or by a
  `none` row naming the bound or window searched. So must every species × cell of its `FLOW` grid (CH, CO, SK,
  BT, GR, WCT, ST): a flow need for spawning, incubation, rearing, overwintering and migration, met by a
  minimum, a span or an optimum; depth lower limits for spawning and migration (never a bankfull depth); and
  velocity upper limits for spawning and rearing. SK has no rearing or overwintering flow cell and no rearing
  velocity cell, because it rears in lakes. `EVIDENCE=`, `REGISTRY=` and `LOG=` check drafts
  without touching the committed logs.
- Logs: `scripts/logs/habitat/`.

<br>

## 0140 / 0160 — Guppy-specific (Peace)
- `0140` farms the Guppy 2006 Table 8 priority list; `0160` enriches it with bcfishpass metrics
- Predate the generalized farm; kept for the Peace pipeline

<br>

## Data sources

- **PostgreSQL.** Every script connects with `DBI::dbConnect(RPostgres::Postgres())`, so libpq
  reads the standard `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER` and `PGPASSWORD` (or `~/.pgpass`);
  nothing in the code names a server. Point them per run at the database the script's header names:
  - an [fwapg](https://github.com/NewGraphEnvironment/fwapg) load with the BCGW layers (`fwapg`) carries the
    PSCIS SVW layers, FISS fish observations (`acat_report_url`), `fwa_watershed_groups_poly` and
    `fwa_named_streams`, so most of this runs against it;
  - a [bcfishpass](https://github.com/NewGraphEnvironment/bcfishpass) database adds
    `fiss_stream_sample_sites_sp` / `fiss_obstacles_pnt_sp` and the bcfishpass model columns
    (`0100`, `0110`, `0160`; `0200` prefers it, above);
  - the CH and BT work (`0290`–`0298`) also needs wet's flow and link's `fresh_default` loaded.

  R reads `~/.Renviron` at startup and its values **replace** the shell's, so where it sets `PG*`, a
  `PGDATABASE=… Rscript …` on the command line is ignored. Either set the database there, or name a
  `~/.pg_service.conf` entry with `PGSERVICE=<entry> Rscript …`: libpq takes a service's settings over
  the `PG*` variables. Set `PGCONNECT_TIMEOUT` so an unreachable server fails instead of hanging.

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
  `Appendix1`; (b) the FPCI form spreadsheets carrying per-site *no fish captured* comments and the
  inventory map sheets are **not** in the rag. Widening the harvest to all documents is open work.
