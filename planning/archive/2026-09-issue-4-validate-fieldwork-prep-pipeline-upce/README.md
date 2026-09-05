# 2026-09 — Validate the fieldwork-prep pipeline cold on UPCE (#4) — PARKED

**Status: parked after Phase 3 of 8, by decision on 2026-09-04. Issue #4 stays open.**

## Outcome

Phases 1-3 ran the cheap half of the report/PDF track cold on the M1 against an unharvested
group and produced what the issue calls its primary deliverable: the list of setup, script and
doc defects that are invisible on the machine the pipeline was written on. Banked: the project
`.Renviron` that silently shadowed `~/.Renviron` (B1) removed and the mechanism written into
CLAUDE.md; the per-report approval wall diagnosed and fixed; the cold-path ragnar store pull
proven (27 s, md5-verified three ways); a `cred::crd_search()` bug filed as
NewGraphEnvironment/cred#27; Zotero collection-naming drift recorded; the `upper peace - UPCE`
collection created. The structural finding is that `0100` writes a header-only `reports.csv`,
no crossings and no gpkg, and still exits 0 when a group has no PSCIS assessments in any of the
four layers, which UPCE does not. Phases 4-8 (harvest, ingest, filing, farm, reconcile,
spatialize) are not started: they are the expensive LLM half, over reports about mainstem dam
and reservoir monitoring, the wrong scale for crossing work. B2-B6 remain unfixed. If resumed,
pick a group with PSCIS assessments or anchor on `bcfishpass.crossings` (3,328 modelled
crossings in UPCE).

## Measurement

UPCE has 0 rows in all four PSCIS layers (positive control: PINE returns rows on the same
query) and 18,383 FISS observations linked to 52 distinct reports. The first read of that
figure as "17,200 files" was wrong by ~300x; report count, not observation count, is the cost
and relevance metric (LNTH: 5,920 observations, 58 reports). That correction is what scoped
the successor issue #5 to include UPCE on the deterministic FISS `.xls` track.

Parked at: commit 942785b. Successor: #5.
