# #44 — Flow needs by species and life stage

## Outcome

The evidence table now separates a **flow need** (`instream_flow`: the water a stage needs while in the stream)
from **stream size** (`discharge`: the MAD an IP model filters on). A need's unit is as written (`percent MAD`,
`percentile`, `percent exceedance`, m3/s, cfs), its `metric` names the flow statistic, and it carries no model
parameter. Depth and velocity keep the unit the source wrote, and bankfull depth is `m bankfull`.

Al decided two things at the gates:
- At the plan gate: a new variable, no month column (the stage gives the season), and ST added to the grid.
- Mid-run: a standard that names no species is coded `FISH`, `SALMON` or `SALMONIDS` and fills no cell.

Sources and gate:
- `0270 --collection flow` built `Fisheries/flow` (`FWTJDD8Z`, 35 items), and the `flow` store is pushed.
- Five sources were paywalled or archive-only and are gaps: Hatfield & Bruce 2000, Bradford & Heinonen 2008, and
  the coho, cutthroat and rainbow HSI models.
- `0280` gained a 60-cell flow grid.

Two drafters wrote 325 rows and three meaning-audit rounds corrected them. The verdict is in
[`research/flow_requirements.md`](../../../research/flow_requirements.md): Ptolemy's BC standards are the generic
floor, species flow needs exist for CH and ST (thin for BT), and none exist for GR or WCT.

What was learned:
- **The worst error came from the brief, not a row.** My drafter brief prescribed `seasonal_mean` for Tennant.
  Tennant asks for instantaneous flows, so 14 rows inherited the error. A convention in a brief needs the same
  check against its source as a row does.
- **Pooled curves get half-coded across drafters.** Steelhead/rainbow curves were each left to "the other
  family", which left 8 twin rows missing until the audit.
- **An auditor's wording repeats into the fix.** Round 2 found errors inside round 1's fixes, such as "item 4" for
  item 1 and "HSC sample" for "study sites". Round 3 then checked round 2's fixes against the pages and found none.
- **One auditor claim was false and was probed.** Round 2 said no Hagen & Weber BT spawning-velocity rows existed.
  Data rows 497 and 498 are those rows.

## Measurement

- **Evidence table:** 686 → 1014 rows, with 0 failing quotes throughout.
- **Flow grid:** 2/60 at baseline, 60/60 after drafting; coverage 48/48 and thermal 50/50 unchanged.
- **Negative run:** one `none` row removed from a frozen copy → `flow: 59 of 60`, exit 1.
- **Meaning audit:**
  - Round 1: 58 errors in 325 rows (ps 37/191, tc 21/134).
  - Round 2: 24 in the 77 rows round 1 touched; 33 of the 34 same-page mixed groups explained, the 34th fixed.
  - Round 3: 0 in the 44 rows round 2 changed. Terminal.
- **Rows changed variable or unit:**
  - row 121 → `instream_flow`, `SALMON`;
  - rows 250, 257 and 264 → `m bankfull` (a bankfull depth was filling a spawning-depth cell);
  - rows 497 and 498 → `cm/s` as quoted.

  The last two changes were found by the plan review and by code-check round 3.
- **Code checks, each ended by enumeration:**
  - Phase 1: 3 rounds; 4 of 686 rows rely on a unit rescale, all documented.
  - Phases 2–3: 3 rounds; every README and roxygen claim checked against the code. The m/km rescale is now scoped
    to bridge distance.
  - Phase 5: 2 rounds; 464 row references in the research file each resolved against its section.
- **Bugs fixed in `0280`:**
  - `table_pages()` crashed (`NA/NaN argument`) when a table quote began on a PDF's last token.
  - OCR refused digitally signed PDFs. govinfo signs its scans.
- **Store:** `flow`, 34 documents and 8,273 chunks. It verifies on a fresh connect. It was re-pushed after the
  input lists were committed, so the manifest names a commit that holds them.
- **Agents:** 15 spawned in all: the plan review, 8 code-check rounds, 2 drafters and 4 audit passes. That is past
  the ~5 the conventions treat as incidental. Each audit round past the first found defects inside the previous
  round's fixes.

## Evidence

- Gate logs: `scripts/logs/habitat/20261007_literature_verify*`.
- Collection, store build and pushes: `scripts/logs/habitat/20261007_flow_*`.
- In this directory: the brief, drafts, audits (`audit-*`), code reviews (`review-*`) and the scripts that applied
  each audit (`scratch_apply_audit{1,2}.py`). `draft-*-evidence.csv` are the drafters' output before the audit
  fixes, and the table supersedes them.

## After the PR opened (2026-10-08 to 10-11)

Al downloaded five of the paywalled or archive-only PDFs by hand. A code review found the sixth, Hickman & Raleigh
1982, on the Internet Archive.
- **Filing:** `0270` filed them, after gaining a thesis's `university` and `thesisType` fields. `Fisheries/flow` is
  now 40 items, all with a PDF; the store holds 40 documents.
- **Drafting:** one drafter wrote 56 rows (data rows 1015–1070):
  - Raleigh et al. 1984: 18;
  - Braithwaite 2011: 14;
  - Hatfield & Bruce 2000: 12, all `qual` with the regression coefficients;
  - Bradford & Heinonen 2008: 6;
  - McMahon 1983: 4;
  - Hickman & Raleigh 1982: 2.
- **The verdict did not change.** No late row fills a cell that held only a `none` row: coho flow, grayling and
  westslope cutthroat flow, and bull trout and westslope passage depth.
- **Ford et al. 1995 corrected.** Reading the originals showed Ford misstating five values. Those rows are now
  `qual`, and seven more notes say where Ford and the original agree or differ.
- **Audit:** 5 errors in 56 rows plus 12 second-hand changes, then 6 errors in 17, then 1 in 7. All seven errors
  inside fixes came from one cause: a note merging two nearly identical statements into one parenthesis. Row
  954's last fix was checked against the OCR'd page, which ended the audit.
- **Files:** `late/` holds the brief, the draft, the three audits and the apply scripts.
- **Gate:** `scripts/logs/habitat/20261009_literature_verify*`, 1070 rows, flow 60 of 60.

Closed by: PR (see `gh pr list --search 44`)
