# #40: Bear et al. 2005 and 2007 read into the evidence table

## Outcome

Both Bear documents are now in the library, the `temperature` store and the evidence table. The issue expected both
PDFs to need a hand download. The 2007 TAFS paper turned out to be on the authors' lab site, so it is fetched from
there; the 2005 WFHI report came from ResearchGate by hand. 32 rows were appended (data rows 1071–1102): WCT and
rainbow trout 60-d and 7-d UUILTs, growth optima, optimal ranges, zero-growth edges, fundamental niches, the report's
field associations (Sloat 2001) and daily-mean and daily-maximum criteria, and the paper's 13–15 °C criterion. The
expected degree-days are not in either document, so the WCT degree-day cells stay `none`, with notes naming what was
read. The Cleator and Thorley secondaries now point at the primary row. The verdict is in
[`research/thermal_requirements.md`](../../../research/thermal_requirements.md).

What was learned:
- **The report and the paper are one set of estimates, but not uniformly.** The paper's survival and growth curves
  carry the report's coefficients exactly. The report's growth curves use one experiment per species, and its
  survival data pool all of them, including fixed sub-satiation rations. Its LD50-regression UUILTs (19.7, 24.2 °C)
  appear only in the report.
- **Cross-source claims were the defect class.** Five review rounds (counts under Measurement) kept finding errors, and every round
  after the first found one inside the previous round's fix. Each was a sentence relating the two documents, or
  describing a method, written by reasoning from a methods paragraph or a caption rather than read off the data. The
  loop ended on an enumeration: all 128 note sentences on the touched rows, each with a verdict.
- **`kind` for an optimum:** a growth optimum the source measured at held temperatures is `lab`
  (`pkg/R/literature.R`), and one a source states or reviews is `pref`. Selong's BT row was recoded to match. A
  narrower `pref` gloss tried mid-run contradicted eight #38 rows and was withdrawn.

## Measurement

- Evidence table: 1,070 → 1,102 data rows. Gate: 0 failing quotes (12 OCR from the paper, 20 text from the report); thermal grid
  50/50 throughout. One OCR quote passes only because the gate reads a number after a stray dash either way
  (`10.6—-14.6`).
- `temperature` store: 38 → 40 documents, 7,892 → 8,013 chunks. `habitat_modelling`: 220 → 222 documents, 38,653
  chunks (the same three keys without an attachment as #38). Both pushed and md5-verified on connect.
- Review: meaning rounds 1–3 found 14, 9 and 6. Code-check round 1 found 1, and round 2 found 10 wrong of 128
  enumerated claims, all in one shared sentence. One round-1 claim (that the text layer verifies the WCT niche) was
  disproved at the gate; its conclusion was right by another route (OCR).
- Agents: five reviewers (three meaning, two code-check), plus none for planning.

## Evidence

- Collection, store build and push: `scripts/logs/habitat/20261011_{temperature,habitat}_*`.
- Gate: `scripts/logs/habitat/20261011_literature_verify*.csv`.
- Rows: `draft_rows.py`, run from the repo root, regenerates data rows 1071–1102 byte for byte (it writes to
  `planning/active/`, where it lived). Audits: `audit-round*.md`, `review-round*.md`,
  `claims-enumeration.tsv`.

Closed by: PR (see `gh pr list --search 40`)
