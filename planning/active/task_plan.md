# Task: Validate the fieldwork-prep pipeline end-to-end on an unharvested group (UPCE) from the M1 (#4)

## Status: Phases 1-2 complete 2026-09-04

Preflight passed and B1 is fixed. The cold-path store pull is proven (27s, md5-verified
three ways). Open: `crd_search` is broken in cred 0.3.0 (list columns) so `0150 ACTION=query`
cannot complete — surfaced, not worked around. Next: Phase 3, `0100` for UPCE.

## Problem

The fieldwork-prep pipeline (`scripts/`) has only ever been run on one machine, by the agent
that built it, while it was being built. Every watershed group harvested so far went through
mid-development, with a lot of tacit knowledge that never reached the docs. So three things are
untested:

1. Is `scripts/README.md` sufficient to run the pipeline cold?
2. Does it generalize to a group with no prior artifacts?
3. Can a second machine work from *synced* artifacts instead of rebuilding?

**The primary deliverable is the list of corrections.** UPCE data is in scope for upcoming
fieldwork and is genuinely wanted, but what this issue exists to produce is the set of doc,
script and setup defects that are obvious on the machine where the pipeline was written and
invisible everywhere else. If nothing breaks, the docs are proven — also a real result.

## Decisions taken (user, 2026-09-03)

1. **Fix forward and generalize** — parameterize the hardcoded group lists rather than appending
   `UPCE` to them.
2. **Ingest into `peace.duckdb`** and push — gives the correctly-named `UPCE__<id>.pdf` contrast
   against its 113/117 Zotero-key-named documents.
3. **Harvest workflow authorized; the farm is gated** — report the real report count and an
   estimated cost after the harvest, then wait for go-ahead.

## Phase 1 — Preflight: prove the machine, record every gap

- [x] Resolve B1: remove the redundant project `.Renviron` (its one variable is already set by
      `.Rprofile:3`), or fold the needed vars in. Then assert from repo root that `PG_*_SHARE`,
      `PG*`, `AWS_ACCESS_KEY_ID` and `getOption("cred.store_source")` are visible to R.
- [x] Assert binaries: `pdftotext`, `ollama` serving `nomic-embed-text`, `python3`, `aws`.
- [x] Assert both DBs from **repo root** (not `~`), and that `UPCE` exists in
      `whse_basemapping.fwa_watershed_groups_poly`.
- [x] Assert Zotero: `~/.config/newgraph/zotero-api-key` non-empty, group `4733734` reachable.
- [x] Every gap into `findings.md`. This phase's output *is* deliverable content.

## Phase 2 — Cold-path store pull (the sync claim, currently untestable)

- [x] Move `data/rag/peace.duckdb` aside (md5 `970dc5caa87d3681728099fc93375d23`).
- [x] `ACTION=query STORE=peace VERIFY=TRUE Rscript scripts/0150-store.R`.
- [x] Assert it **downloaded**: pulled md5 == manifest md5 == the moved-aside copy,
      byte-identical, and no embedding pass ran. Then restore/remove the aside copy.
- [x] Record why the cold path had to be forced — see findings.md "the warm path proves nothing".

## Phase 3 — 0100 + 0110 for UPCE (first real outputs)

- [ ] `WSG_TARGET=UPCE Rscript scripts/0100-pscis-acat-reports.R` →
      `data/upce/{crossings.csv,reports.csv,pscis_upce.gpkg}`.
- [ ] Fix B5: give `gnis_seed.csv` a producer, derived from `crossings.csv$stream_name`, with one
      settled schema. Reconcile the two existing variants.
- [ ] `WSG_TARGET=UPCE Rscript scripts/0110-gnis-collision-check.R` →
      `data/upce/gnis_seed_ambiguity.csv`.
- [ ] Record whether 0100's hardcoded `:63333` (no fallback) could use the local fresh-db.

## Phase 4 — Harvest UPCE, then check in

- [ ] Run `wf_report_harvest.js` for UPCE across all four discovery axes, geo-filtered.
      Produces `UPCE__<reportId>.pdf`.
- [ ] **Stop.** Report the actual report count and an estimated farm cost; wait for go-ahead
      before Phase 7.

## Phase 5 — Ingest, push, dedup, tag

- [ ] `STORE=peace HARVEST_DIR=... Rscript scripts/0152-rag-add-harvest.R`.
- [ ] Push immediately (`ACTION=push STORE=peace CONFIRM=TRUE`) — an unpushed ingest is silently
      replaced by the next verified connect.
- [ ] Assert the manifest **merged**: all four store entries survive. First real exercise of
      cred#24; the pre-fix behaviour orphaned a store.
- [ ] `0156` dedup — `peace` has never been deduped — then push again.
- [ ] Fix B6 for `0154` (single-`STORE` overwrite of the repo-global `corpus_tags.csv`), then run
      it and confirm the UPCE slice carries correct `EXTENT__reportId` attribution and a real
      farm join.

## Phase 6 — 0153 Zotero filing

- [ ] Fix B2: resolve the collection by name against the group library and create
      `upper peace - UPCE` if absent, replacing the hardcoded dict. Add the missing Peace codes.
- [ ] File every UPCE report with all its documents attached; verify item and attachment counts.

## Phase 7 — Farm, reconcile, spatialize (gated on Phase 4)

- [ ] **Model A/B before the full farm.** Run the farm agent on a handful of already-farmed
      Fraser PDFs at Haiku and diff the rows against the known-good output in
      `priority_farmed_all.csv`. Ground truth exists; use it. Confirm first whether `agent()`
      inside a Workflow script accepts a model override — fall back to per-PDF `Agent` calls if
      not.
- [ ] Run `wf_farm_priority.js` on the UPCE PDFs.
- [ ] Fix B3, B4, B6: parameterize the group set in `0161`/`0162`, and make `0161` merge rather
      than overwrite.
- [ ] `0162` → `rag_priorities` including UPCE, `coord_source` populated.
- [ ] **Assert no Fraser loss**: record counts before/after, counted by **parsing**, not
      `wc -l` (6,258 lines vs ~9,257 records — embedded newlines).

## Phase 8 — The actual deliverable

- [ ] Fold `findings.md` into `scripts/README.md` — every undocumented prerequisite found in
      Phase 1, the differing `WSG_TARGET` defaults (`PCEA` in 0100, `PINE` everywhere else),
      `MAX_MB`, `SOFFICE_BIN`, `VERIFY`, `DRY_RUN`, `TOPK`, `PDF_PATH`, and the tunnel / AWS /
      Zotero credential requirements.
- [ ] File issues for what was recorded but not fixed.
- [ ] `/planning-archive` with a README carrying **Measurement** and **Evidence** sections.

## Validation

- [ ] `0100` → harvest → `0152` → `0153` → farm → `0161` → `0162` completes for UPCE from
      `scripts/README.md` alone, every deviation recorded
- [ ] Store **pulled**, md5-verified, cold path forced and proven
- [ ] `upper peace - UPCE` Zotero collection exists with attachments
- [ ] `0154` yields a UPCE slice with correct attribution and a farm join
- [ ] A UPCE priority layer with `coord_source` populated
- [ ] Fraser deliverables provably unharmed (parsed record counts)
- [ ] `/code-check` clean on each commit; PWF checkboxes match landed work
