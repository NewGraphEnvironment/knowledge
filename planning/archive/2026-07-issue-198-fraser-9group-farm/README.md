# 2026-07 — Fraser 9-group report harvest + priority farm (#198 follow-on)

## Outcome

Extended the fieldwork-prep pipeline from the Peace pilot to all nine Fraser-project watershed groups
(BOWR, MCGR, COTR, WILL, UFRA, TABR + the Nechako cluster FRAN, LCHL, NECR). Harvested the past-report
corpus for each via the geo-filtered multi-axis search, ingested to `fraser.duckdb` (**304 documents**),
filed BOWR/MCGR into their Zotero collections with PDFs attached, then farmed the priority/crossing
tables out of **218 report extracts (~9,100 rows)** and exported a single field layer,
`data/planning/rag_priorities.gpkg` — **256 fish-passage crossing standouts**, each traceable to a named
report table with explicit coordinate provenance. Landed as [PR #203](https://github.com/NewGraphEnvironment/fish_passage_template_reporting/pull/203)
(commit `04e4655`), on top of [PR #202](https://github.com/NewGraphEnvironment/fish_passage_template_reporting/pull/202) (v0.6.0) which carried the BOWR/MCGR half.

## The find that mattered: multi-watershed reports were being silently dropped

Al asked why Hooft's Willow priorities weren't in the layer. They were genuinely missing, and the cause
was structural rather than a harvest gap. **Hooft 2015** (`hooft2015Fishpassage`, EcoCat **50797**)
covers *Willow, Tabor and Bowron — 787 locations*, and its Table 4 flags 15 priority-replacement sites,
five in each watershed. The harvest stamps each report with **one** extent; a Bowron FISS point pulled
this one in as `BOWR`. Reconciliation then matched its rows only against *Bowron* crossings, so the five
Willow and five Tabor sites matched nothing, received no coordinates, and disappeared — and the
per-group polygon clip in the spatializer would have discarded them even if they had. Archer Creek was
one of the lost sites.

Fix: reconcile every farmed row against the **union** of all groups' crossings and stamp
`watershed_group_code` from the crossing it actually matches. Hooft now distributes 5 BOWR / 5 TABR /
5 WILL. The naive version of this over-matched badly (2,465 rows leaked to the wrong groups) because
recon reports number their reaches 1, 2, 3… and those collide with small-integer crossing references in
big groups — so cross-group moves are only allowed when unambiguous, and habitat-inventory rows never
reconcile at all. That brought it to 65 genuine moves.

Two smaller findings fell out of the same thread:

- **The `[PSCISnn]` axis had never been harvested.** PSCIS `ecocat_url` values are often
  `advancedSearch.do?keywords=[PSCIS1180]` rather than a `reportId`; resolving all 53 Fraser project ids
  yielded only two genuinely new reports (Tête Jaune `24169`, stats `51884`) — a small gap overall, but
  Hooft's report sat in it.
- **"Priority" is domain-specific.** Road-deactivation prescriptions, riparian reaches and sediment-hazard
  inventories all use high/moderate wording. Counting them made BOWR look like 192 priorities when it has
  five fish-passage standouts. `rag_priorities` is now filtered to the crossing domain; everything else
  stays queryable in `rag_sites_all` via `table_source`.

## Coordinate provenance

Report tables place sites three different ways, and the field user needs to know which they are looking
at, so `coord_source` is explicit: `pscis` (surveyed crossing, 191) > `report-utm` (transcribed from the
report, 35) > `stream-snap` / `stream-snap-parent` (approximate — placed on the named FWA stream when a
report flags a standout by name with no UTM, 30). The snap tier recovered COTR 0→21 and BOWR 5→14, but
these are stream-level, not site-level: several standouts on one creek share a coordinate. They say which
stream to go look at, not where the culvert is.

## Loose ends

- 2 crossing-domain standouts remain unplaced (blank / "Unnamed" stream names).
- ~170 FRAN points sit on the UTM zone 9/10 boundary (Francois Lake straddles 126°W); the parser defaults
  to zone 10, so western Nadina/Endako sites land east and get clipped. Needs a zone-9 retry in `0162`.
- Zotero filing was done for BOWR/MCGR only; the other seven groups' harvests are not yet filed, so a
  `0151` Zotero-sourced rebuild would not reproduce the full store.
- Cross-machine artifact sync (M4 builds, M1 in the field) designed but not built —
  an internal issue, a private `rag/` prefix in `fresh-bc`.

## Notes

The general lesson — *a report tagged to one watershed group may cover several; reconcile per-crossing,
not per-report* — applies to the harvest pattern beyond fish passage and is worth promoting to soul.
Run order and per-script detail now live in `scripts/04_planning/README.md`; the why-decisions stay in
each script's header block.
