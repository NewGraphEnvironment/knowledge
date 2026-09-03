# Progress

## Session 2026-07-10
- Explored template repo + ecosystem (skeena_2022_planning, guidebook, bcfishpass.sqlite, Zotero).
- Confirmed: ecocat_url on all 4 PSCIS layers; PCEA/PARA/PINE codes; CLIR = EcoCat+EIRS+BCSEE+Fyles;
  PCEA Zotero collection exists (9QAJJJQW).
- Filed tracking issue #198.
- Created branch `198-fieldwork-prep-pipeline`.
- Wrote PWF baseline (task_plan.md, findings.md, progress.md).
- Scaffolded `scripts/04_planning/0100-pscis-acat-reports.R`; tunnel :63333 up, used live DB.
- PCEA PSCIS pull: **22 assessments, all "Trib to Clearwater Creek" (2010, ref PSCIS77), 20 BARRIER**;
  no confirmations/designs/remediations → PCEA formal FP work is thin.
- **Access proven (answers "can you access all that?"):** EcoCat keyword search (WebFetch) ✓,
  Google/web search ✓, direct EcoCat PDF download via curl ✓ (HTTP 200, real %PDF, verified on disk),
  viewReport.do → direct documents/rNNNNN PDF links ✓. PSCIS `ecocat_url` unreliable (PSCIS77 → 0 hits).
  CLIR search app likely needs the browser tool (session/form-based).
- **Recalibrated per Al:** don't gold-plate old skeena scripts; the *gold* is area-context intel.
  Wrote `data/planning/pcea/context_pcea.md` — nations/territory (Tsay Keh Dene, Kwadacha, McLeod Lake,
  Treaty 8; Ingenika relocation), FWCP/PWFWCP + Arctic Grayling program, IPCAs (Ingenika IPCA 2020,
  Chuyaza Conservancy), parks (Omineca PP), listed species (bull trout DU2 Special Concern, grayling,
  Chase caribou), connectivity corridors, local groups (Mackenzie Fish & Game Assoc.).
- Connectivity lit flags **Pine + Halfway** as recruitment-source coldwater habitat → confirms PINE richer.
- Pulled PINE: 307 assessments / 137 barriers / 55 named systems (Sukunka 69, Pine 44, Hasler 17...).
  Coverage: ALL 307 = Guppy 2006-07 (funding_project "2006-07 Peace River Assessments", project_id 71,
  ecocat [PSCIS71]) → one inventory covers the WSG (Al called it).
- Discovery engine proven: EcoCat keyword search "Sukunka River" → 36 reports (grayling, barrier recon,
  restoration, crossing inventories). GNIS-name + funding_project search is the real engine, not ecocat_url.
- Report acquisition proven end-to-end: 5 marquee PINE PDFs downloaded (curl) + uploaded to Zotero
  **pine - PINE (B5XW948R)** via Web API S3 flow, all verified attached.
- Ultracode assessment: NOT worth it for the pilot (harvest dedups to a small unique set); reserve for
  the all-WSG / all-years amalgamation sweep.
- PDF-table farming DONE (scripts/04_planning/0140-extract-guppy-priority.R): pulled Guppy's
  "Table 8. Priority 1 Sites" (17 sites) from the 499-pg PDF; **PSCIS external_crossing_reference ==
  Guppy `2006.NNN` verbatim** → exact reconciliation, no spatial snap. **10 of 17 P1 barriers fall in
  PINE** → data/planning/pine/priority_guppy_p1.csv (PSCIS id + coords + stream + barrier). This is
  the field priority-table v1 (Sukunka tribs, Wildmare, Bissette, Windrem, Rocky Ck, Pine oxbow, Silver Sands).
- Ragnar DONE (scripts/04_planning/0150-rag-build.R + 0155-rag-query.R): data/rag/pine.duckdb,
  5 docs / 1795 chunks, local Ollama nomic-embed-text. Verified queries: "Wildmare remediation" →
  Guppy Table 8 recs + prioritization matrix; "grayling Sukunka" → FWCP synthesis (fry rearing,
  tributary spawning) + Stuart & Chislett 1979. Results-section gold now queryable. (ragnar backend
  auto-installs a python PDF stack on first run; ~3 min for 540 pp.)
- **Ultracode harvest run (2026-07-11):** wf_peace_report_harvest.js, 75 agents, 879 targets → 554
  PDFs. Triaged: **78 Peace-relevant** (476 noise from broad EcoCat keyword search; 121 FISS = data-only
  .xls). Uploaded **76 new reports to Zotero by extent** (PINE 64 / PCEA 8 / PARA 2 / mackenzie 2), all
  PDFs attached. Built data/rag/peace.duckdb over the clean 78. Created parsnip arm - PARA (9TP5AFIG).
- LESSON: EcoCat keyword search ignores geography → GNIS phase needs a Peace/WSC title filter AT SEARCH
  TIME (see findings). FWA-uniqueness (0110) is necessary but not sufficient.
- Next: (a) fix workflow GNIS geo-filter before PARA/other regions; (b) Pine context brief; (c) enrich
  priority table (Guppy issue+rec + bcfishpass habitat) + KML/GPKG field-nav export; (d) recover FISS .xls data if wanted.

## Session 2026-07-11 (later) — Fraser leg: Bowron + McGregor
- Generalized the harvest workflow (scripts/04_planning/wf_report_harvest.js): GNIS phase now
  GEO-FILTERS (agent region-judgment + region_regex title backstop). **The fix worked**: GNIS returned
  only 8 hits (vs 734 noise for Peace). BOWR+MCGR run: 42 targets -> 19 PDFs (rest data-only .xls).
- Filed 19 reports to Zotero by extent: bowron-BOWR (KVAZMDU9) 8, mcgregor-MCGR (8PE924W9) 3,
  fraser (XC9H2B6Q) 8. Built data/rag/fraser.duckdb (19 docs / 1402 chunks).
- Verified: surfaced culvert barrier inspections, Indianpoint Creek inventory (Lhatako Dene Nation
  interest; timber + placer mining), and non-fish-bearing determinations (13m cascade, no fish capture).
- Zotero-sourced portable build (0151) validated: found 99 PDFs across the 4 Peace collections, rebuilt.
- Permissions cleaned: settings.local.json 101 -> 21 read-only entries; broad exec via session mode.

## Session 2026-07-12 — keyword-search axis (3rd axis) wired + backfilled all groups
- McGregor gap (Al): straight EcoCat "fish passage McGregor" found 12 reports (planning/phase/design/hab-con)
  our FISS+GNIS axes missed. Confirmed method needs a thematic keyword axis; fixed a bigint->double count
  bug (MCGR has 9 hab confirmations, not 0). Grabbed 8 McGregor FP reports.
- Wired keyword axis into wf_report_harvest.js (searchTerms = gnis_names + keyword_queries, geo-filtered).
- wf_keyword_backfill.js: fanned out 5 groups, geo-filtered thematic search, skip 108 already-harvested ->
  **31 found / 27 filed** by extent (PARA 10, BOWR 12, PCEA 4, MCGR 1). Found NGE/A.Irvine's own reports
  (Parsnip hab confirmations FWCP PEA-F20, Restoring Fish Passage Peace 2022/2023), Carbon Creek set (PCEA),
  Lheidli T'enneh Anzac inventories, 468-location Parsnip FP assessment (Hooft 2014). Zotero now ~135 reports.
- Store ingest timed out (2m) mid-embed -> rebuilding peace + fraser stores cleanly from Zotero (0151 portable
  build) to incorporate the backfill without WAL/dup risk (bg task b17plbp1i).

## Session 2026-07-12 (later) — UFRA + WILL + TABR (Fraser reporting groups)
- 3-axis geo-filtered harvest (wscaswd04): 161 targets (125 FISS + 36 keyword/GNIS) -> 38 PDFs.
  Geo-filter clean (no noise flood). Filed by extent: fraser 20, WILL 11, UFRA 4, TABR 3; 0 NGE/off-region.
  Ingesting into fraser.duckdb. Content: Ahbau/Willow inventory, Haggith Ck EIA, Salmon FSR culvert
  inspections, Dunster Bridge, Baer Ck culvert-removal monitoring, Hwy 97 Plett-Red Rock realignment.
- NGE own reports kept OUT of harvest (policy); handled via repo->Zotero sync path.
