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

**Key result for both:** **zero habitat confirmations, designs, or remediations on record** — like Pine, essentially all first-touch. Many Bowron/McGregor "barriers" are **natural** (high-gradient step-pool reaches, cascades) rather than culverts — e.g., Kruger Creek barriers are mostly natural morphology with one 1.0 m culvert. Consultants active: **DWB Forestry, Davis Environmental, Cascadia Biological, EDI, AGRA, Guppy**; permit-driven forestry work (Canfor, West Fraser, TFL 30).

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
