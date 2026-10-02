# Plan review — #33 (Plan agent, 2026-10-02, read-only; written here by the parent)

The counts are prototype numbers from the reviewer's own read-only computation, using 0291's population filter: 14,463 visits, 1,997 with BT.

## Blockers
- **B1. Spawner evidence is mostly small fish.**
  - Of 119 BT evidence visits, 112 are M Aug–Oct and 7 are SP/ST. Median length is 177–210 mm in every class; 8–23 % are ≥ 350 mm.
  - Visits with a large spawner: ≤2: 8; 2–4: 9; 4–5.49: 6; 5.49–8: 5; 8–10.49: 3; >10.49: 3. Every steep class fails the power rule.
  - The plan called transit "likelier", which overstates it.
  - → Split by size. Make resident spawning in place an explicit competing hypothesis.
- **B2. The response measures maturity coding.**
  - Only 712 of 1,997 BT visits have any BT maturity code.
  - The coded share is 27 % at ≤2 % against 40–45 % in steeper classes.
  - FDS: 144 of 1,050 coded. FDIS: 568 of 947.
  - 106 of 119 evidence visits are from 1995–2004. Two agencies hold 38 of the 119.
  - → Restrict to Aug–Oct visits with ≥ 1 BT maturity-coded. Add log(n coded BT) and month terms; run an agency sensitivity.
  - Restricted rates: 0.146, 0.188, 0.182, 0.293, 0.302, 0.352 on 178, 133, 77, 75, 43 and 54 visits.
- **B3. The transit test as specified is invalid.**
  - Searches are mostly censored at the blue-line end.
  - Sliver segments: 36 % of BT visits sit on segments under 50 m.
  - Network position differs between the evidence and null groups.
  - The direction is not pre-registered, and same-blue-line search misses tributary spawning.
  - A prototype showed no upstream separation.

## Assumptions
- **A1.** Aug mixes migration with spawning; the steep signal is mostly August. → Report Aug and Sep–Oct separately. Non-Aug–Oct M fish form a migrant class.
- **A2.** Month confounds class. → Month is a nuisance term.
- **A3.** The link `spawning` flag sits on access_bt = 2 for 1,237 of 1,329 BT visits on spawning segments. → Never a covariate. Patches are defined access-independently.
- **A4.** The plan's rule must reproduce 0240's spawner rows. → Assert it.
- **A5.** Width sources are mixed; river polygons dominate > 10 m. → Report by source and edge type.
- **A6.** link installed is 0.50.0. → Read the existing visit table, log its md5, and do not re-run 0290.
- **A7.** `data/fiss_evidence.csv` `gradient_pct` is a fraction, not a percent. This is a 0250 defect.
- **A8.** The Williston layer likely comes from Hagen's surveys, which skipped streams < 2 m wetted. → The width share is ~0 by design; state the provenance.
- **A9.** gpkg is not ignored, and WLRS terms are unconfirmed. → Use an ignored path first.

## Gaps / Ordering / Scope / Acceptance
- **G1.** U cannot reuse 0291's classes. → Refit on the spawning ladder.
- **G2.** Missing from the plan: Pearce 2019, Montana FWP redd counts, and reading the newly acquired PDFs.
- **G3.** 0270 needs a `%PDF` URL. Paywalled items need a manual standalone attachment. 0150 reads local Zotero, so it needs a sync first.
- **G4.** Report US evidence by region.
- **G5.** Record the USFWS critical-habitat GIS and the state layers as pending.
- **G6.** Define the strongest-kind order.
- **O1.** Disclose that class rates were seen before the spec was fixed.
- **O2.** Phase 2 order: file → sync → read → build → rows → gate.
- **O3.** Fix the transit statistic before computing.
- **S1.** Label output as evidence rates, not habitat weights. Propose nothing for link until B1/B3.
- **S2.** Run a measured-site-gradient sensitivity.
- **AC1.** Every number traces to a log line.
- **AC2.** A pre-registered decision rule for transit vs in-place.
- **AC3.** A power check on the actual cells.
- **AC4.** Phase 3 provenance statement.

## Disposition (parent)
- All accepted.
- The transit test is cut to a descriptive large-fish table with censoring reported, labelled underpowered. The data cannot carry a test: 11 large-spawner visits above 5.49 %.
- A7 is filed as a repo issue, not fixed here.
