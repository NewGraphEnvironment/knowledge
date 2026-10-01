# Plan review (#29) — Plan agent, 2026-10-01

Returned as reply text (Plan agents have no Write tool); filed here verbatim in substance.

## Blockers
- **B1** COVERAGE CO/ST in Phase 1 makes the gate red (0 CO/ST rows). → moved the flip to Phase 3.
- **B2** Backfill set ≠ seed registry → referential check fails. → Phase 1 backfills only rebellato2024 and cooney_holzer2006, CH rows only, access stage included.
- **B3** "Busch 2013" (lib 6, `shallinbusch_etal2013…`) is the same paper (DOI 10.1002/rra.1597) as group `busch_etal2011LandscapeLevelModel`; 0270's group_copy would reject the match on creator/year and POST a duplicate. → dropped.

## Gaps
- **G1** Reuse matcher via a `check_quote()` / shim; separate long-format registry log; REGISTRY= env; extend exit; model_id in evidence log. → shim used (`quote_row()` into `check_row()`, value check returns TRUE with no values); registry log `<LOG>_ip_registry.csv`; model_id added to evidence log.
- **G2** Validation often in a separate paper → optional `validation_citation_key`.
- **G3** Flow claim from a secondary source (Sheer) → `cited_source` in registry.
- **G4** One flow_metric can't hold Rebellato (MAD + width surrogate) or C&H (width from drainage area + precip); `surrogate` ambiguous. → `flow_metric` (what is thresholded), `flow_source` (gauged/modelled/field), `flow_inputs` (`;` list), `flow_surrogate` (metric used where the primary is unavailable).
- **G5** `flow_metric = none` still needs a quote that could never be found → rule: the quote states the variables the model does use.
- **G6** Join on model × species × stage, ignore form; access rows need access registry rows; none rows can't carry model_id; qual rows for figure-only curves; breakpoint score goes in note. → as implemented; written into the drafter brief.
- **G7** Backfill rule: tag only values/variables the model itself uses (param/hsi/expert/qual), not data summaries (dist, max_obs) or literature it cites but did not adopt (row 8 WDFW).
- **G8** No cfs/mi2/ft units; no precipitation variable; valley width in m has no home. → add cfs, mi2, ft as written; skip-and-note the rest.
- **G9** Holzer (HTML only) and Bidlack (links only) have no PDF; 0270 prints `no-pdf` and exits 0. A matching additions row is the only route; dry-run must say `exists`.
- **G10** Record new items' BBT keys after sync; drafters use those.
- **G11** Parallel drafters: shared OCR work dir is deleted on exit by any run → per-run tempdir; drafters must set LOG=; gate a merged copy; drafts need model_id column.
- **G12** 0150 needs OVERWRITE=TRUE; push CONFIRM=TRUE; collection list is #19 task_plan.md:107.
- **G13** Docs: scripts/README.md:49 and :326-329, 0280 header, research/habitat_literature.md title/header, CLAUDE.md data bullets.

## Ordering
- O1 Phase 1 green needs B1/B2. O2 seed models' PDFs are in the group; Zotero is running. O3 reader + CSV column in one commit; column is required, value may be blank. O4 finish 0280 edits before drafters run it. O5 store rebuild can overlap drafting.

## Assumptions
- A1 Busch 2013 (B3). A2 Zotero state stale. A3 one flow metric (G4). A4 validation same doc (G2).
- A5 Sheer Table A1 cells must be quoted as text (table needs a number).
- A6 ST access can't come from Rebellato row 6 (no steelhead in the quote).
- A7 Stage-generic models need explicit per-stage rows.

## Scope
- S1 Agency layers, NetMap, Zimmerman & Reeves 2000 are not threshold-defining documents; landing-page URLs make 0270 exit 1.
- S2 Assign Sheer-secondary rows by the model they describe.
- S3 SK/CM rows uncounted by coverage — count them in the summary.

## Acceptance
- AC1 48/48 cells is satisfiable from Rebellato alone; add: links green, registry rows per model, every Table A1 model has rows or a findings line saying why not.
- AC2 First version bump; no NEWS; gh-pr-merge treats repo as non-versioned. → add pkg/NEWS.md.
- AC3 Guard proofs: unknown model_id; registry row with no evidence; registry quote not found; validation quote not found; empty CO/ST cell.
