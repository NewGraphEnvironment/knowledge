# Task: Quick read of the North Thompson fish-passage reports from PSCIS links and EcoCat (#11)

## Problem

There is no past-report knowledge for the North Thompson. No ragnar store covers LNTH or UNTH
(S3 holds `fraser`, `peace`, `pine`, `vca_refs` only), the Zotero group library has no
collection for either group, and the full report track (`0100` → harvest workflow → `0152`
ingest → Zotero filing → farm) is the expensive half of the pipeline and parked with #4's
blockers B2–B6 unfixed. What is wanted right now is much smaller: **a general summary of what
the fish-passage reports for the region say**, produced quickly and without a chain of
permission prompts.

## Phase 1 — Links from PSCIS, resolved to report ids
- [x] `pkg`: `knw_pscis_reports()` accepts `habconf_ecocat_url` as the link column (a
      `.first_col(df, "ecocat_url$")` lookup); one testthat case with a confirmation layer
      named that way, red before the change.
- [x] `0100`: `WSG_TARGET` required (no `PCEA` default) and tunnel-first with the down-only
      local `fwapg` fallback, copied from `0200`. Run it for LNTH and UNTH →
      `data/<wsg>/{reports,crossings}.csv`, `pscis_<wsg>.gpkg`.
- [x] New `scripts/0105-reports-resolve-fetch.R` (WSG_TARGET): for each `[PSCISnn]` search
      URL in `reports.csv`, fetch the search page and parse `reportId` + title; write
      `data/<wsg>/reports_resolved.csv` (`pscis_layer`, `pscis_tag`, `report_id`, `title`,
      `n_crossings`, `source = pscis`). Assert every tag resolved to ≥1 id, or name the ones
      that did not.

## Phase 2 — EcoCat keyword search, geo-filtered
- [x] Same script: 4–5 keyword queries ("fish passage north thompson", "fish passage
      thompson", "habitat confirmation north thompson", "culvert north thompson", "PSCIS
      north thompson"), parse hits, keep titles matching the region regex, drop ids already
      resolved; append with `source = ecocat_search`. Record every hit and the filter
      verdict in `reports_search_hits.csv` so the exclusions are auditable.

## Phase 3 — Fetch the PDFs locally
- [x] Same script: for each report id, fetch `viewReport.do`, list the PDF documents, pick
      the main report by `0153`'s rule, `curl` it to `data/<wsg>/reports_pdf/<id>.pdf` with the
      HTTP status recorded; `pdftotext -layout` beside it. Manifest `reports_fetch.csv`
      (`report_id`, `title`, `pdf_url`, `http`, `bytes`, `is_pdf`, `n_docs`, `txt_chars`).
      Fail loud on any id with no PDF document or a non-200; retry once on 5xx.
- [x] Reconcile: `nrow(reports_resolved ∪ search)` == `nrow(reports_fetch)`; every row
      `is_pdf` or named.

## Phase 4 — Read and summarise
- [x] Three or four unnamed reader subagents, ~6 reports each, given the `.txt` paths and a
      fixed note template (who / when / where — streams and crossing ids named / what was
      done — assessments, habitat confirmations, designs, remediations / findings /
      recommendations / anything about fish presence or barriers). Each writes
      `data/thompson/report_notes/<id>.md`. No subagent spawns subagents.
- [x] Write `data/<wsg>/reports_summary.md` per group from the notes: a general account of
      what people said, by theme and by sub-basin, citing each report by EcoCat id and year,
      with the link table at the end. Note reports that turned out to be off-region or not
      about fish passage.

## Phase 5 — Close out
- [x] `scripts/README.md`: one paragraph on `0105` as the quick path (links → resolve →
      fetch → read) and the `habconf_ecocat_url` gotcha; run-order line for `0105`.
- [ ] Commit per phase; `/planning-archive`; `/gh-pr-push`.

## Validation
- [ ] Every one of the 24 PSCIS tags resolves or is named as unresolved
- [ ] Every report id has a PDF on disk with text, or is named
- [ ] Summaries cite only ids in `reports_fetch.csv`
- [ ] `/code-check` on the script commits

