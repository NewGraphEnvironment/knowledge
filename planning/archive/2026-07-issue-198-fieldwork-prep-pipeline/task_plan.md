# Task Plan — Fieldwork-prep pipeline

Issue: NewGraphEnvironment/fish_passage_template_reporting#198
Branch: `198-fieldwork-prep-pipeline` | Live log: `progress.md` | Research: `findings.md`

Goal: reusable, `wsg_code`-parameterized `scripts/04_planning/` module that, per watershed group,
produces (1) a **priority table** of best-bet sites and (2) a **past-reports** corpus harvested to
Zotero + searchable in a Ragnar store. **Scope grew far beyond the original PCEA pilot** — see progress.md.

## DONE (pilot → 8 watershed groups)
- [x] PWF baseline + `scripts/04_planning/` module (scripts-first header convention)
- [x] `0100-pscis-acat-reports.R` — PSCIS pull (spatial clip), any WSG via `WSG_TARGET`
- [x] `0110-gnis-collision-check.R` — QA gate (name-collision, province-wide)
- [x] `0140-extract-guppy-priority.R` — farm priority table from PDF, reconcile to PSCIS
- [x] `0150-rag-build.R` / `0155-rag-query.R` — Ragnar build + query (local Ollama)
- [x] `0151-rag-build-from-zotero.R` — **portable** build (M1-reproducible from cloud Zotero)
- [x] `0160-priority-enrich.R` — enriched priority table + Phase-2 xref + KML/GPKG (PINE)
- [x] **3-axis geo-filtered harvest** `wf_report_harvest.js` (FISS links + GNIS names + thematic keywords)
- [x] `wf_keyword_backfill.js` — backfill thematic reports across groups (skip already-harvested)
- [x] Harvested + filed + ingested: **Peace** (PINE, PCEA, PARA → peace.duckdb 117 docs) +
      **Fraser** (BOWR, MCGR, UFRA, WILL, TABR → fraser.duckdb 87 docs). ~135+ reports in Zotero.
- [x] Field deliverables: PINE priority_pine_enriched.csv + .kml/.gpkg
- [x] Context briefs: context_pcea.md, context_pine.md, context_bowron_mcgregor.md

## OPEN
- [ ] Context briefs for UFRA / WILL / TABR (nations, fisheries, FP history, floodplain)
- [ ] `0160` enrich + KML/GPKG for Bowron/McGregor + UFRA/WILL/TABR (like PINE)
- [ ] **Floodplain literature pass** — add floodplain keyword_queries + `floodplain` tag (cheap; do at
      harvest time). Keep floodplain DATA/extents (flooded → stac_floodplains_bc → drift) SEPARATE.
- [ ] **NGE own reports**: do NOT harvest from EcoCat (stale). Build repo→Zotero sync Action
      (drift pattern soul#48 + citation-cff + zotero-api), pin citekeys. Test on 2025 Peace report.
- [ ] **Citekey hygiene**: dedup duplicate NGE Zotero entries; pin canonical keys (soul#40).
- [ ] Reconcile peace.duckdb (still holds 5 stale NGE PDFs until next 0151 rebuild).
- [ ] Dedup EcoCat duplicate records in harvest (prefer PDF-bearing F-code over record-only twin).
- [ ] Architecture decision: which reporting repo owns final output; PR/merge the branch; archive PWF.

## Verification (met)
reports filed + attached in Zotero by extent ✓ | ragnar_retrieve returns chunks ✓ |
PINE priority table has coords + PSCIS ids + Phase-2 xref (all first-touch) ✓ | KML/GPKG exported ✓
