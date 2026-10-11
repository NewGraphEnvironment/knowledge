# Meaning audit, round 2 (Plan-type reader, 2026-10-11)

Scope: the round-1 fixes (`git diff db3e451 5c040cd`), the three round-1 dispositions that were not plain
fixes, and the research file edits. Nine findings, four of them inside round-1 work.

| # | finding | disposition |
|---|---|---|
| 1 | the WCT 2007 niche was left out on a false premise: the 20-character minimum applies to `text` quotes only, and an OCR quote that runs past the `10.1-14.1` range verifies | fixed: row appended (data row 1102), sharing its quote with the RB niche |
| 2 | "the 2007 paper pools all experiments" is contradicted by identical fit coefficients; the 7-d values differ by method | fixed in every note and in findings.md; RB 31.1 °C noted as an extrapolation |
| 3 | the research file cited a gate log written before the Bear rows | fixed: gate rerun to the default log |
| 4 | `pkg/R/literature.R` defines `lab` to include growth at held temperatures | Bear optima back to `lab`; Selong recoded `lab`; the research file gloss for `pref` corrected |
| 5 | wrong stated reason for leaving out the secondary values | fixed in research "Left out" and round-1 record |
| 6 | "1.7 C lower (same page)" points at p. 1115; it is p. 1118 | fixed |
| 7 | "average daily stream temperatures less than 12/13 °C" is a period average, not a cap on each day's mean | metric `unstated`, note says so |
| 8 | research file overstated the paper's remark on brief daily exposures | fixed: conditional, citing others, a stated limitation |
| 9 | the size range is a range of experiment means | fixed |

Checked and correct by the reader: every data-row cross-reference, every shared quote, the 2007 and 2005 page
references, the Sloat 2001 region, the notes on data rows 521, 522, 531–533 and 553–555, and the research header.
