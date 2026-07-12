# Bowron (BOWR) + McGregor (MCGR) — field-prep brief

Two adjacent **upper-Fraser** watershed groups now in the `sern_fraser_2024` QGIS project.
**Bowron** = the Bowron River / Bowron Lakes country east of Quesnel (Cariboo). **McGregor** = the
McGregor River east of Prince George (Robson Valley / Rocky Mountain foothills). Grounded in the
19-report Fraser corpus (`data/rag/fraser.duckdb`) + the PSCIS crossing data.

## Fish passage history — who did the work, and results

**McGregor is a heavily-inventoried, barrier-dense forestry watershed — 1,081 PSCIS crossings, ~700 barriers.** The bulk is one systematic effort:
- **McGregor Watershed Fish Passage Inventory, Phase 2 & 3** — split across **TFL 30 (521 crossings / 354 barriers)** and **TSA 24 (425 / 293)**. This is the dominant dataset.
- Plus **2006 Carp–McGregor Pre-Code Culvert Assessments** (64 / 53), **Seebach Creek** reassessment + a **bridge replacement** (28 crossings), and recent **FSW/PSCIS 2024** work (7). Seebach is the one system with documented follow-up (reassessment → replacement).

**Bowron is smaller — 152 crossings, ~88 barriers**, from:
- **Fish Passage Assessments in the Prince George District** (119 / 61 barriers),
- **Legacy Data – BCCC Bowron** (26 / 25 barriers), and
- a **Bowron & Quesnel Watershed Connectivity Restoration Plan** (6 crossings) — i.e., restoration *planning* has already been scoped here.

The core McGregor fish-passage literature (found via **straight EcoCat keyword search**, NOT FISS-links
or stream-names — see method note) is now in Zotero `mcgregor - MCGR`:
- **Analysis and Priority Identification for Existing Fish Passage Data, McGregor Watershed** (Masse
  Environmental, 2017, EcoCat 52620) — the **planning / priority-ID exercise**.
- **Phase 1 inventories** (DWB — Canfor TFL 30 2009 / excl-TFL30 2010 / Phase 1-to-3 2010; EcoCat
  24085/24141/24178) and **Phase 2 & 3 inventories** (Triton — TFL 30 24184 / TSA 24 24181, 2011).
- **Herrick Road Culvert Replacement Designs** (DWB, 2011, 24816) and the **Pre-Code Culvert
  Assessment Pilot** for Carp + McGregor (MoE / Mackinnon, 2007, 51883).

**Follow-up status (corrected):** McGregor has **9 habitat confirmations on record** — a government
Phase-2 follow-up after the planning exercise (an earlier count bug showed 0). Bowron has **0**
confirmations/designs/remediations (genuinely first-touch). Many Bowron/McGregor "barriers" are
**natural** (high-gradient step-pool, cascades) rather than culverts — e.g. Kruger Creek is mostly
natural morphology with one 1.0 m culvert. Consultants active: **DWB, Triton, Masse, Cascadia, Davis,
EDI, Guppy**; permit-driven forestry work (Canfor, West Fraser, TFL 30 / TSA 24).

## Fisheries context

Upper-Fraser salmonid systems. The best-documented population is **Indianpoint Creek + Indianpoint Lake** (Bowron) — **juvenile chinook salmon and rainbow trout** the notable species; McGregor systems add **bull trout** and mountain whitefish (Fraser headwaters). bcfishpass *does* model salmon/steelhead/bull trout here (unlike grayling in the Peace), so the model habitat metrics will be usable for prioritization. **Beaver influence is pervasive** and shapes fish habitat throughout (see floodplain, below).

## First Nations context

Both groups are **Dakelh (Carrier)** territory, upper Fraser:
- **Bowron / Indianpoint / Quesnel side:** **Lhtako Dene Nation** (formerly Red Bluff Band) is named as representing First Nations interests in the Indianpoint Creek watershed; broader Southern Dakelh (Nazko, Lhoosk'uz Dene) nearby.
- **McGregor / Herrick side (east of PG):** **Lheidli T'enneh** — a 1997 Herrick Creek 1:20,000 inventory was authored by the **Lheidli T'enneh Band** itself; **McLeod Lake (Tse'khene)** and **Simpcw** (Robson Valley) territories adjoin.
- Land-use overprint they care about: extensive **timber harvesting** (TFL 30, TSA 24, Canfor, West Fraser) and legacy **placer mining** (Cariboo goldfields — tailings documented in Indianpoint/Kruger floodplains).

## Floodplain / off-channel — what to know

- **Beaver-driven off-channel habitat is the dominant floodplain story.** Beaver dams/reservoirs repeatedly create rearing, over-wintering, and spring spawning habitat (Indianpoint, Red Rock Creek, Torpy River/Harvey Creek). **Fisheries Sensitive Zones** in the Indianpoint inventory were mostly logged *because of* beaver activity. Channels are "very variable due to damming."
- **Floodplain/wetland/seepage riparian** (alder–willow RVT9) at Kruger Creek; placer-mining tailings sit in some floodplains (historic disturbance).
- Same sequencing note as Pine: if we delineate any of these floodplain extents, **register to `stac_floodplains_bc` first**, then pull.

## Field-prep takeaways

1. McGregor is a big barrier backlog (~700, all first-touch) — the TFL 30 / TSA 24 inventory reports are the read-before-field priority; Seebach is the one with follow-up history.
2. Distinguish **natural vs anthropogenic** barriers early — many here are natural cascades/gradient, not culverts.
3. Salmon/bull-trout habitat *is* modelled → use bcfishpass metrics for prioritization (unlike Peace grayling).
4. Engagement: Lhtako Dene (Bowron/Quesnel) and Lheidli T'enneh (McGregor/PG); beaver-influenced FSZs and placer-mining legacy are recurring themes.
