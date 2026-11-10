# Findings — Fieldwork-prep pipeline

## Watershed group codes (Peace / FWCP), from `data/inputs_raw/xref_fwa_wsg.csv`

| Code | Name | This round |
|------|------|-----------|
| PCEA | Peace Arm | pilot (1st) |
| PINE | Pine River | 2nd (many assessments) |
| PARA | Parsnip Arm | 3rd |

Nearby (not this round): PARS Parsnip River, CRKD Crooked River, CARP Carp Lake, MURR Murray River,
KISK Kiskatinaw, LBTN/UBTN Beatton, LHAF/UHAF Halfway, LPCE/UPCE Lower/Upper Peace, GRAI Graham I.

Note: in dictation the names were swapped — codes PCEA/PARA/PINE are correct; PCEA=Peace Arm,
PARA=Parsnip Arm (not the reverse).

## PSCIS layers + EcoCat (confirmed)

Four PSCIS SVW layers, **each carries `ecocat_url`** (link to the upstream report):
- `whse_fish.pscis_assessment_svw` (BCDC `pscis-assessments`)
- `whse_fish.pscis_habitat_confirmation_svw` (`pscis-habitat-confirmations`)
- `whse_fish.pscis_design_proposal_svw` (`pscis-design-proposal`)
- `whse_fish.pscis_remediation_svw` (`pscis-remediation`)

Plus standalone `whse_fish.acat_report_point_pub_svw` (`ecological-catalogue-formerly-aquacat`).

**DB probe (2026-07-10, tunnel 63333):** all 4 PSCIS SVW layers ARE in the newgraph DB
(`whse_fish.pscis_assessment_svw`, `pscis_habitat_confirmation_svw`, `pscis_design_proposal_svw`,
`pscis_remediation_svw`). `acat_report_point_pub_svw` is **NOT** loaded → pull via `bcdata`.
Also present for Phase 5: `whse_fish.fiss_fish_obsrvtn_pnt_sp`, `fiss_obstacles_pnt_sp`,
`fiss_stream_sample_sites_sp`, `bcfishobs.fiss_fish_obsrvtn_events_vw`.
`fwa_watershed_groups_poly` has `watershed_group_code` + `geom`; PCEA/PARA/PINE all present
(names: Peace Arm / Parsnip Arm / Pine River). pscis_assessment_svw geom col = `geom`.
**PCEA = 22 PSCIS assessments** (thin — good pilot).

Local `data/bcfishpass.sqlite` holds only `pscis_assessment_svw` and only for **Fraser** wsgs
(FRAN, LCHL, LSAL, MORK, NECR, TABR, UFRA, WILL). So Peace data must come from the live DB or bcdata.
Confirmed cols present in the local svw: `stream_crossing_id`, `external_crossing_reference`,
`ecocat_url` (col 56), `image_view_url` (57), `watershed_group_code` (67).

EcoCat report URL form: `http://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=NNNNN`.
Gotcha (from skeena extract-pg.R comment): the ecocat_url stored in PSCIS is sometimes **wrong** —
verify the report actually matches the crossing.

## Holistic coverage finding (PINE) — one inventory covers the WSG

All **307** PINE PSCIS assessments were done by **GUPPY (2006–2007)**, 100% carrying one EcoCat
reference `[PSCIS71]` = Guppy's **Peace River Stream Crossing Structure Inventory** (EcoCat id
**11786**). So the PSCIS-side "report harvest" for a WSG often collapses to a *single* source
inventory (Al's call: "Guppy may have done 90% of what we know" — here it's 100%). Implication:
don't fan out 55 searches expecting 55 sources — the PSCIS inputs trace to 1 report; the extra value
is the *non-PSCIS* literature (grayling, restoration, barrier recon) found by GNIS-name search, whose
**results sections** carry the ecological/priority gold. `ecocat_url` is 100% populated but is a
keyword-SEARCH link (`[PSCISnn]`) that may not resolve in EcoCat (PCEA's `[PSCIS77]` → 0 hits) — the
report itself is retrievable by name/id.

## The precise report-discovery key: `funding_project` (Al's steer)

PSCIS report/project fields: **`funding_project`** (project name), **`project_id`** (the number in the
`[PSCISnn]` ecocat_url), `funding_source`, `consultant_name`, `responsible_party_name`.
- **PINE**: funding_project = **"2006-07 Peace River Assessments"**, project_id **71**, source MOE, all 307 →
  = Guppy's Peace River Stream Crossing Structure Inventory (EcoCat 11786). `[PSCIS71]` = project_id 71.
- **PCEA**: funding_project = **"Compliance and Enforcement 2010"**, project_id **77**, source MFLNRO →
  explains why `[PSCIS77]` returns 0 in EcoCat: it was a compliance/enforcement action, not a report.
→ Search EcoCat/CLIR by **`funding_project`** (name), not the `[PSCISnn]` code. `project_id` links the code.

## Zotero harvest (PINE) — DONE

Collection **`pine - PINE` = B5XW948R** (under mackenzie 5USQ8DRG, group 4733734). 5 marquee reports
uploaded via Web API S3 flow, PDFs verified attached (cross-filed to grayling GELFSUTU / Fish Passage ESNB4BQB):
- Guppy 2007 Peace River Stream Crossing Inventory (JVN2N7DW) — PSCIS source, has crossing table for reconciliation
- Stuart & Chislett 1979 Arctic Grayling life history, Sukunka (6JK88BUF)
- Tredger & Wightman 1977 NE Coal Block fish-passage barrier recon (BJBQ92HP)
- Culling 1999 Burnt River Grayling Assessment (4C2MRQJ5)
- FWCP 2017 Arctic Grayling Synthesis – Peace (WVTFGPUT)
Reusable uploader: scratchpad/zotero_upload.py (create report items + S3 upload). Creator gotcha:
institutional authors use `{"name":"..."}` (no `lastName`, no `fieldMode`).

## QA: don't conflate Peace-wide syntheses with a watershed group

The FWCP Arctic Grayling Synthesis is **Peace-wide** and dominated by the best-studied **Parsnip/Finlay**
populations (Table R, Anzac, Reynolds/Firth/Bill's/Wichcika, Missinka, Upper Finlay = **PARS + Williston
core**, NOT Pine). So ragnar retrieval surfaces Parsnip content even for Sukunka queries. **Pine-specific
grayling** = Stuart & Chislett 1979 (Sukunka drainage) + Culling 1999 (Burnt River) + Guppy's per-crossing
GR flags. Attribute population specifics to the right WSG; regional syntheses are context only. TODO:
tag ragnar chunks by source-watershed to prevent cross-WSG misattribution. Synthesis caveat: grayling
abundance monitoring "has not occurred anywhere" in the watershed — presence/absence + barriers > abundance.

## FISS/obs/obstacle layers carry DIRECT report links (big missed source)

All three layers have **`acat_report_url` + `source_ref` + `agency_name`**:
`whse_fish.fiss_stream_sample_sites_sp`, `fiss_fish_obsrvtn_pnt_sp`, `fiss_obstacles_pnt_sp`.
Unlike PSCIS `[PSCISnn]` keyword codes, these are **real `viewReport.do?reportId=NNNNN` links** →
resolve straight to PDFs. **PINE alone = 86 distinct linked reports** (78 via observations, 20 via
sample sites). These are the 1:20,000 fish inventories that carry **non-fish-bearing determinations**
by past bios (can downgrade a barrier's priority) + point-level fish presence/absence. MUST be a
harvest step (0160-fiss-reports.R): distinct acat_report_url per layer, spatially clipped to WSG.
Also pull the observation/sample points themselves for fish-bearing status, not just the reports.

## Zotero filing by STUDY-AREA EXTENT (Al's rule)

Reports whose study area spans multiple watershed groups get filed at the **region** level
(`mackenzie` 5USQ8DRG), not a single WSG (e.g. PCEA). The data signals extent: harvest acat_report_url
across ALL target WSGs and count how many WSGs each report's points/crossings touch →
- appears in 1 WSG  → file in that WSG collection (e.g. pine - PINE)
- appears in >=2 WSG → file at mackenzie (region), tag the WSGs it covers.
Refile accordingly: FWCP Grayling Synthesis (Peace-wide) and Guppy's inventory (whole Peace District,
many WSGs) belong at **mackenzie**, not just pine - PINE. Currently mis-filed WSG-only — fix in sweep.

## Ultracode harvest run (2026-07-11) — outcome + the big lesson

Workflow `scripts/04_planning/wf_peace_report_harvest.js` (75 agents, ~6.7 hr, 3.9M tokens):
- targets 879 (145 FISS-linked + 734 GNIS-keyword-search) → 554 PDFs downloaded.
- **Only 78 are Peace-relevant** (24 FISS reports + 54 title-verified GNIS); **476 were off-target
  noise**; 121 FISS "no-PDF" are **data-only `.xls`** fish-collection submissions (not reports).
- Filed the 78 by extent (PINE 66 / PCEA 8 / PARA 2 / mackenzie 2); built `data/rag/peace.duckdb`.

**LESSON (critical for future runs):** EcoCat keyword search **ignores geography** — searching common
GNIS names ("Pine River", "Murray River", "Willow", "Boulder") matched reports across all BC
(Lillooet, Seton, Naver, Herrick, Kincolith, Koocanusa, Libby). FWA-name-uniqueness (0110 check) is
NOT sufficient — a name unique in the FWA can still be a common EcoCat keyword. Fix before the
PARA/PCEA/other-region runs: constrain the GNIS phase — require a Peace/WSC token in the title
(`00000PINE|00000PARA|234-4439|TFL 48|Chetwynd|Dawson Creek FD|Sukunka|Williston|Peace Region`), or
verify each hit's coordinates in-WSG, AT SEARCH TIME. Triage regex + clean-manifest approach in
scratchpad/harvest_triage.py. FISS-linked reports (spatially verified) are the trustworthy core.

## TODO — Pine floodplains → stac_floodplains_bc FIRST, then pull

Ragnar surfaced real Pine floodplain value (off-channel/side-channel rearing + oxbows): **Callazon Ck**
groundwater-fed side channels in the active floodplain (rpt 8053), **Pine River oxbow** cut off by Hwy 97
fill (Guppy P1 2006.072), **Bullmoose/Wolverine** floodplain side channels for juvenile salmonids (2243),
**Young Creek oxbow lake** in the Pine floodplain (2275). **Sequence (Al):** delineate these extents
(flooded/DEM) → register to **`stac_floodplains_bc`** (the STAC floodplains repo — create if absent, per
the stac_dem_bc/stac_orthophoto_bc pattern) → THEN pull into the report. Do not pull raw into the report first.

## Next expansion — Bowron + McGregor (Fraser region)

Next watershed groups to run the pipeline on: **Bowron (BOWR)** and **McGregor (MCGR)** — Fraser drainage,
now added to the Fraser QGIS field project (`sern_fraser_2024`). File Zotero under `Fisheries > regions >
fraser` (new `bowron - BOWR`, `mcgregor - MCGR` collections). **Fix the workflow GNIS geo-filter first**
(Peace/WSC token at search time) so the sweep doesn't pull the off-target noise again — for Fraser use
Fraser WSC tokens / `00000BOWR|00000MCGR|Bowron|McGregor|Fraser` etc.

## Rag stores — inventory

- `data/rag/pine.duckdb` — 5 marquee PINE reports (initial pilot store).
- `data/rag/peace.duckdb` — 78 clean reports across PINE/PCEA/PARA/mackenzie (the working store; WSG
  encoded in each origin filename). **No separate `pcea.duckdb`** — PCEA is thin (~8 reports) and lives
  inside peace.duckdb; query PCEA by filtering origins `PCEA__*`. Standalone per-WSG stores only warranted
  for rich groups (PINE, and future BOWR/MCGR if they return enough).

## Search needs a THIRD axis: thematic keyword search (Al, confirmed)

Our two harvest axes — FISS `acat_report_url` (spatially-tied) + GNIS **stream-name** searches — both
MISS thematic/watershed-level reports: fish-passage **planning** reports, **Phase 1/2/3 inventories**,
**design** reports, and **habitat-confirmation** follow-ups that aren't tied to a FISS point or a single
named stream. Proof: a straight EcoCat search `keywords="fish passage McGregor"` returned 12 reports —
incl. the Masse 2017 priority-ID planning exercise (52620), DWB/Triton Phase 1/2/3 inventories
(24085/24141/24178/24184/24181), Herrick Rd designs (24816), Pre-Code pilot (51883) — almost NONE of
which were in our 34 FISS reportIds. **Add a keyword axis to the workflow:** per WSG, run EcoCat/CLIR
searches for `"fish passage <WatershedName>"`, `"<WatershedName> watershed fish"`, `"culvert <Name>"`,
`"habitat confirmation <Name>"`, geo-filter, dedup. CLIR (enterCLIR.do) spans EcoCat+EIRS+BCSEE+Fyles —
likely needs the browser tool. Also re-run this axis for PINE/PCEA/PARA/BOWR (retrospective).

## Data bug fixed: bigint counts read as denormal doubles

`DBI::dbGetQuery(... "SELECT count(*) ...")` on the confirmation xref returned `4.446591e-323` — the
integer **9** mis-read as a double bit-pattern. MCGR actually has **9 habitat confirmations** (not 0).
Fix: cast counts `::int` in SQL. Corrected the Bowron/McGregor brief accordingly.

## NGE own reports in EcoCat — PDFs ARE attached (under F-codes); duplicate records

Correction (WebFetch summary was wrong; curl+grep is truth): the FWCP deliverables DO have PDFs on
EcoCat — Restoring FP Peace 60017 (F22), 62435 (F23), 63072 (F24), 63248 (F25), + Parsnip hab-con 59039
(F20). The "record-only" hits (62211, 64828, 64864, 58790) are **DUPLICATE EcoCat records** of the same
reports cross-filed under PG-codes, with no PDF. **Harvest gotcha:** dedup EcoCat's duplicate records —
prefer the PDF-bearing F-code entry over the record-only PG-code twin (the backfill grabbed the empty
twins). Filed the 4 real ones to mackenzie + peace.duckdb.

**Versioning:** the EcoCat PDF is the OFFICIAL SUBMITTED snapshot at deliverable time — it
LAGS the repo's latest render (reports are living/versioned via NEWS.md).

**DECISION (Al): do NOT harvest NGE's own reports from EcoCat — those PDFs are STALE and clutter Zotero.**
I deleted the 5 I'd dumped (60017/62435/63072/63248/59039). NGE reports must be **repo-sourced (latest
render), version-stamped, and BBT-keyed**, managed via a release-triggered sync (the "drift" GH Action
pattern an internal issue + citation-cff an internal issue/#56 + zotero-api). EcoCat keeps the frozen annual official copy;
our working Zotero holds the current repo version. **Harvest rule:** EXCLUDE author "New Graph
Environment" / "Irvine" (and the FWCP F-code deliverables) from the EcoCat harvest so we don't re-clutter.
NOTE: peace.duckdb still contains the 5 stale NGE PDFs until its next Zotero-sourced rebuild (0151) —
reconcile then. Related: xciter (citekeys), an internal issue (versioning), Zenodo (per-version DOIs, optional).

## CLIR

BC [Cross-Linked Information Resources](https://www2.gov.bc.ca/gov/content/environment/research-monitoring-reporting/libraries-publication-catalogues/cross-linked-information-resources-clir)
= meta-search over **EcoCat + EIRS + BCSEE + J.T. Fyles Library**. Superset of EcoCat; use for the
GNIS-name / non-PSCIS report hunt.

## ID reconciliation keys

- `stream_crossing_id` — PSCIS official ID (aka pscis_crossing_id)
- `external_crossing_reference` — field-assigned ID stored in PSCIS (what external reports often use)
- `my_crossing_reference` — our local Phase-1 ID (pre-PSCIS-submission)
- `aggregated_crossings_id` — bcfishpass superset (modelled + assessed)

Reconciliation precedent: `scripts/db-load.Rmd:222-275` joins by
`c("my_crossing_reference" = "external_crossing_reference")` then case_when to pick the ID.
Xref build: `scripts/02_reporting/0100-load-bcfishpass-data.R:147-153`.
Fallback when a report only gives coords: spatial snap to nearest PSCIS crossing / FWA stream via
PostGIS KNN `<->` (db-newgraph skill recipe).

## Precedent repos

- **`fish_passage_skeena_2022_planning`** (branch `master`) — THE precedent.
  - `scripts/extract-pg.R`: `SELECT p.* FROM whse_fish.pscis_assessment_svw p INNER JOIN working.misc wsg
    ON ST_Intersects(wsg.geometry, p.geom)` then `group_by(consultant_name, year, ecocat_url)`.
  - `0100-intro.Rmd`: external reports use their own `map_ref_number` (matches McCarthy & Fernando
    2015 inventory), not PSCIS IDs; new cols added (works_completed, priority_rank_for_restoration,
    species_presence_from_lit_review, etc.).
  - `0200-results.Rmd`: priority filters (in key report OR >1km steelhead rearing modelled OR >10ha
    wetland/lake upstream OR high-value PSCIS OR Phase-2 done) → `sites_results` table with
    `followup_priority`, `source`, `sfc_map_ref_number`, lon/lat.
  - `scripts/outgoing-mapping.R`: make_geopackage() + KML/GPX tracks for field nav.
- **`fish_passage_guidebook`** — modern method. `0200-planning-field-GIS.Rmd` (QGIS/Mergin planning),
  `scripts/extract-pg.R` uses `fpr_db_conn()` + `fpr_db_query("... WHERE watershed_group_code IN (...)")`.

## DB access (db-newgraph skill)

- Remote tunnel: DB `bcfishpass`, host localhost, port **63333**, user `newgraph`, trust auth.
  `fpr::fpr_db_conn()` (reads PG_*_SHARE from ~/.Renviron) or direct RPostgres. Needed for bcfishpass
  model metrics (crossings_vw: linear habitat, accessibility).
- `bcdata::bcdc_query_geodata()` — pulls PSCIS/FWA SVW layers direct from BCDC WFS, **no tunnel**.
  Good for getting the pilot moving. `0100-load-bcfishpass-data.R:117-130` has the commented pattern.
- Key FWA: `whse_basemapping.fwa_watershed_groups_poly` (watershed polys),
  `whse_basemapping.fwa_streams_vw` (gnis_name).

## Reusable functions

- `fpr::fpr_db_conn()`, `fpr::fpr_db_query(query=...)`
- `fpr::fpr_my_pscis_info(col_pull=, site=)`, `fpr::fpr_my_bcfishpass(col_pull=, site=, dat=)`
- `readwritesqlite::rws_connect/rws_write/rws_read_table` + local `lngr_drop_table_if_exists()` (scripts/functions.R)
- `ngr::ngr_str_link_url()`
- Skills: `zotero-api` (S3 PDF upload), `lit-search` (ragnar), `zotero-lookup`, `cartography`, `db-newgraph`

## Zotero targets

`Fisheries` (TRXPJHQE) > `regions` (T48Z6Z3T) > `mackenzie` (5USQ8DRG):
- `peace arm - PCEA` = **9QAJJJQW** (exists; already has 5 reports incl. Carbon Creek surveys/design,
  Peace reach lake trout movements)
- `parsnip` = 7UFY2AG3 (Parsnip River — NOT Parsnip Arm)
- create for this work: `pine - PINE`, `parsnip arm - PARA` under mackenzie
General FP refs → `Fisheries` > `Fish Passage` (ESNB4BQB) and subcollections (references JPYFPKLT,
Background QQGI49VN, methods TP39CLFG). Grayling species collection: `Fisheries > species > grayling` (GELFSUTU).

## PDF acquisition escalation ladder

1. M4 automated: WebFetch on a100 viewReport page → PDF link; `curl -A "Mozilla/5.0"` for the PDF.
2. Claude-in-Chrome: navigate + click download (load browser tools via ToolSearch).
3. M1 screen-control: manual grab, drop from Downloads → Zotero. Log every report needing this.
