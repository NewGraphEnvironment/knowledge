# Findings — Bull trout life history: one research file quoted from the store (#198)

## Issue context

**What changes if we do it:** the bull trout habitat definitions (spawning and rearing) and species-at-risk work on both listed units stand on one written account of the species' life history, quoted from the documents rather than restated from memory. **If we never do:** each proposal and tuning pass restates life history from memory, one PDF at a time.

Split from #194, which builds the `bull_trout` store this reads. **Blocked by #194.**

## Proposed Solution

One `research/` file covering:
- forms: resident, fluvial and adfluvial;
- migration and spawning timing;
- redd and spawning-site selection;
- thermal limits;
- juvenile rearing;
- how the forms are split across BC.

Every claim is quoted from the `bull_trout` store with its citation key.

Relates to #33 and #51.


## Exploration at the gate (2026-11-16)

- The `bull_trout` store is local (`data/rag/bull_trout.duckdb`, 366 MiB, pushed 2026-11-15); cred 0.7.0.
- BT evidence rows: 181 in `data/literature_evidence.csv` (33 keys). Temperature 40, gradient 38, timing 10,
  groundwater 9, substrate 4, and others; forms tagged on 35 rows (adfluvial 15, migratory 15, resident 4, fluvial 1).
- `data/life_history_timing.csv` has no BT rows; `habitat_literature.md` "Timing" says the BULK BT windows once
  there were unsourced.
- 0280 already checks a second population (the IP registry) through `quote_row()` and `check_row()`; research quotes
  join as a third population the same way. `check_row()` records the PDF pages a quote matched and never checks the
  cited page, so the page is audited by meaning.
- Precedent for a quoted research file: `research/bayesian_alignment.md` with `data-raw/bayesian_alignment_check.R`
  (stray-quote guard: blank checked quotes, then any quote mark left near a citation fails).

## Drafting (2026-11-16)

- A source's own square brackets are read by 0280's `fragments()` as an editorial insert. COSEWIC 2012's
  `DU1 [Genetic Lineage 1: ...]` therefore leaves a one-word fragment, so a quote must start or stop around such
  brackets.
- The registry pages and COSEWIC 2025 are prints of web pages with no printed page numbers, so their cited pages are
  PDF pages. The COSEWIC 2012 cover is unnumbered too.
- Sentences repeated within a report (the 2025 assessment summary and the technical summaries) match on several
  pages. The research log flags each one, and the cited page must be among the pages it lists.
