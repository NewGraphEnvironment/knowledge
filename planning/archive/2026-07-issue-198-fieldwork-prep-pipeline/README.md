# 2026-07 — Fieldwork-prep pipeline (#198)

## Outcome

Built `scripts/04_planning/` — a reusable, `wsg_code`-parameterized module that, per watershed group,
harvests the past-report corpus into Zotero and a searchable ragnar store, farms priority tables out of
those reports, reconciles them to PSCIS, and exports a field layer. Started as a PCEA pilot; ended up
run across **12 watershed groups** — Peace (PINE, PCEA, PARA) and the full Fraser project (BOWR, MCGR,
COTR, WILL, UFRA, TABR, FRAN, LCHL, NECR).

Shipped through releases **v0.5.0 → v0.10.0**. Principal PRs: #201, #202, #203, #204, #206, #209.

Where things landed:

| | |
|---|---|
| `fraser.duckdb` | 283 unique documents, all 9 Fraser groups, synced to `s3://fresh-bc/rag/` with `log.json` |
| Zotero | 234 reports filed across 9 collections, with attachments |
| `rag_priorities.gpkg` | 256 fish-passage crossing standouts + `rag_sites_all` (1,601 placed sites) |
| `priority_farmed_all.csv` | ~9,100 farmed rows from 218 report extracts |
| `corpus_tags.csv` | content tags over the whole corpus |

## What was learned the hard way

**A report tagged to one watershed group may cover several.** Hooft 2015 (EcoCat `50797`) spans
Willow/Tabor/Bowron — 787 locations, 15 priority-replacement sites, five per watershed. The harvest
stamps one extent per report, so reconciliation matched its rows only against *Bowron* crossings and
the 5 Willow + 5 Tabor sites silently vanished. Fixed by reconciling against the union of all groups
and stamping `watershed_group_code` from the crossing actually matched (`0161`). This is the single
most important lesson in the module and generalizes beyond fish passage.

**"Priority" is domain-specific.** Road-deactivation prescriptions, riparian reaches and sediment-hazard
inventories all use high/moderate wording. Counting them made BOWR look like 192 priorities when it has
five fish-passage standouts. `rag_priorities` is filtered to the crossing domain; everything else stays
queryable in `rag_sites_all` via `table_source`.

**An EcoCat report is 3–19 documents, not one PDF.** The harvest takes only the first, which is
sometimes an appendix rather than the report body (`52264`), and which dropped the FPCI spreadsheets
carrying per-site *no fish captured* comments and the shapefiles. `0153` now files every document to
Zotero — but the **rag still holds only one document's text per report**, which remains open.

**Filing to Zotero has to be a numbered step or it gets skipped.** It was done by an ad-hoc script for
BOWR/MCGR and simply not run for COTR/FRAN/LCHL/NECR; since the harvest dir is `/tmp` (later reaped),
162 documents existed only as text in a local DuckDB file. Backfilled from EcoCat and made `0153`.

**Two ingest paths meant duplicates.** 21 EcoCat reports were in `fraser.duckdb` under both
`EXTENT__reportId.pdf` and a Zotero attachment key — two chances at every retrieval. Deduped in `0156`.

## Disposition of the 8 unchecked boxes

| Item | Status |
|---|---|
| Context briefs for UFRA / WILL / TABR | **Open** — BOWR/MCGR/PCEA/PINE have them; the Fraser reporting groups do not |
| `0160` enrich + KML/GPKG per group | **Superseded** — replaced by `0161` unified reconcile + `0162` single-layer spatialize covering all 9 groups at once |
| Floodplain literature pass | **Partial** — `0154` tagging surfaces 10 floodplain-tagged documents; the dedicated `keyword_queries` sweep was never run |
| NGE own reports: don't harvest from EcoCat | **Policy done** (CLAUDE.md + memory), **Action not built** — repo→Zotero sync with pinned citekeys still open |
| Citekey hygiene (dedup NGE entries, pin keys) | **Open** — an internal issue |
| Reconcile `peace.duckdb` (5 stale NGE PDFs) | **Open**, and now compounded: the store is 113/117 Zotero-key-named with no group attribution, so it was deliberately excluded from the S3 sync |
| Dedup EcoCat duplicate records in harvest | **Partial** — `0156` dedups the *store*; the harvest-level F-code vs record-only PG-code twin dedup is not done |
| Architecture decision + PR/merge + archive PWF | **PRs merged, PWF archived (this commit). Architecture decision NOT made** — which reporting repo owns the final output is still undecided |

## Live follow-on issues

- **#205** — content-tag the corpus (partially delivered in `0154`; Zotero tag push open)
- **#207** — sync derived products to `s3://fresh-bc` with `log.json` (RAG half delivered in `0157`; FISS GPKG half open)
- **#208** — clean-room pipeline validation on UPCE from the M1; blocked on the scoped read key
- **#199** — FISS `.xls` → spatial No-Fish-Captured layer; `0154` shows 50 documents carrying NFC signals
- **an internal issue** — read-only IAM key scoped to `rag/*`; the hard blocker for #208

## Note

`planning/active/` sat on this plan with a last progress entry of **2026-07-10** while the work ran to
2026-07-30, because archiving was assigned to a second machine that never pushed. Archived here instead.
Run order and per-script detail live in `scripts/04_planning/README.md`; the Fraser 9-group chunk has its
own archive entry at `planning/archive/2026-07-issue-198-fraser-9group-farm/`.
