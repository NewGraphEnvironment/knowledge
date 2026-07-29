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
wf_farm_priority.js                          farm priority/crossing tables out of the PDFs
0161  reconcile farmed rows -> PSCIS, stamp watershed_group_code
0162  spatialize -> rag_priorities.gpkg
0155  query the rag store
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
- Emits `data/planning/<wsg>/crossings.csv` (+ `reports.csv`, `pscis_<wsg>.gpkg`)
- `crossings.csv` is the reconciliation target for 0161 — `external_crossing_reference` is the key

## 0110-gnis-collision-check.R
- Counts how many watershed groups province-wide share each stream name
- Run BEFORE any name-based report search; "Boulder Creek" is in 12 groups

## wf_report_harvest.js / wf_bowr_mcgr_harvest.js
- Multi-agent harvest: geo-filtered EcoCat search + batched resolve/download/verify
- `wf_report_harvest.js` takes one group; `wf_bowr_mcgr_harvest.js` takes several at once
- Writes `<EXTENT>__<reportId>.pdf` into a harvest dir

## 0152-rag-add-harvest.R
- Ingests a harvest dir into an existing ragnar store, deduped by EcoCat reportId
- `STORE=fraser HARVEST_DIR=/path/to/harvest`
- Needs Ollama up (`nomic-embed-text`)

## 0150 / 0151 / 0155 — rag store build + query
- `0150` builds from local PDFs; **`0151` builds from Zotero** (portable/reproducible — prefer it)
- `0155` queries: `WSG_TARGET=fraser QUERY="..." TOPK=5 Rscript 0155-rag-query.R`
- Semantic search is weak on proper nouns — for a specific creek name, grep the PDFs

## wf_farm_priority.js
- One agent per report PDF; lifts priority / crossing / habitat-reach tables into structured rows
- Rows carry the report's OWN crossing id (+ the PSCIS id when the report prints one)
- `kind` per target picks the extraction hint: crossing / recon / restoration / habitat / permit

## 0161-priority-farm-reconcile.R
- Reconciles farmed rows against the **union of all groups' crossings** and stamps the true
  `watershed_group_code` — a report tagged to one group often covers several
- `FARM_JSON=` accepts task `.output` files **or** workflow `journal.jsonl` (journals outlive outputs)
- Emits `data/planning/priority_farmed_all.csv`

## 0162-priority-spatialize.R
- Writes `data/planning/rag_priorities.gpkg` (gitignored — a deliverable, not source):
  - `rag_priorities` — report-flagged **fish-passage crossing** standouts only
  - `rag_sites_all` — every placed site; filter by `table_source` for deactivation / riparian /
    habitat priorities
- `priority_rank` 1=high 2=moderate 3=low 4=ruled-out, NULL=no priority stated
- `coord_source` records provenance: `pscis` (surveyed) > `report-utm` (transcribed) >
  `stream-snap` / `stream-snap-parent` (approximate — placed on the named FWA stream)

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
