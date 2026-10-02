# Review — Phase 1 (`scripts/0290-bt-use-build.R`), round 2

I reviewed the rewritten script, the ledger, the output (`data/fdis/derived/bt_use_visits.csv`,
17,592 rows) and the findings. I checked them against local fwapg (`fresh_default`,
`score284_default`, `score284_bt_rear_*`), `fdis_species_codes.csv` and link's
`lnk_species_pooling()`. All probes ran from the scratchpad and used temp tables only.

## Findings

- **[severity: bug]** scripts/0290-bt-use-build.R:133 (`m = downstream_route_measure + nudge_m`)
  with :136-155. A fixed 5 m nudge jumps over the segment that starts at the site whenever
  that segment is shorter than 5 m. The header (:10-14) says the nudge gives "the one
  starting at the site as link#284 step 5 did". Short segments are common at sites, because
  link breaks at every bcfishobs record and repeat records sit a few metres apart.
  - Measured on the output: 9,291 nudged visits have a segment break within 1 m of their own
    point, and for **817** of them (509 calibration, 308 held out) the chosen segment is not
    that segment.
  - The skipped segments are 1.0 to 5.8 m long (median 2 m), so these visits take the next
    record's segment upstream instead.
  - **171** of the 817 change gradient band (cuts at 2, 5, 8, 10.49, 12.49, 13.49 and
    14.49 %). Gradient band is the curve's main covariate.

  Fix: when a segment starts within a tolerance of the site's measure (say ±1 m), take that
  segment. Nudge only when no such segment exists, or nudge by less than the shortest
  segment. A deliberate choice to skip sub-5 m segments, for their degenerate gradient, is
  defensible too, but then the header and findings must say so, because the current text
  claims step-5 equivalence.

- **[severity: fragile]** scripts/0290-bt-use-build.R:125. `bt_n = n_bt + n_dv` where DV is
  pooled, but `bt_present` there also counts `BT/DV`, `DV/BT` and `DVxBT`, which sit only in
  `n_char`. This is the inverse of round 1's SLV defect. The output has **27 rows** with
  `bt_present = TRUE` and `bt_n = 0`, all in BT+DV WSGs (FIRE 12, LFRA 12, BABL, KISP and
  MORR 1 each). Their `species_caught` values include `DV/BT`, `BT/DV`, `DV/BT;RB` and
  others. 0291 does not read `bt_n` today, so there is no current analysis impact. Any count
  or abundance use of the column would read these visits as BT present with zero BT. Either
  derive `bt_n` from the same code set as `bt_present`, or blank it where the two disagree.

- **[severity: fragile]** scripts/0290-bt-use-build.R:169-184. The overlap guard runs once,
  at the nudged points, before the fallback `UPDATE … SET m = m0`. The visits re-placed at
  their own point are therefore never overlap-checked, and the second `place()` resolves any
  multi-match there silently through `DISTINCT ON`. That contradicts the header's "any
  overlap longer than `overlap_max_m` stops the run".
  - Measured: the 21 kept fallback visits each match exactly one segment, so there is no
    current impact.
  - They do sit 0.07 mm to 4.4 m below the top of their segment. Most are within 1 mm, which
    is the "just below a break" case, unavoidable here because no upstream segment exists in
    the WSG.

  Fix: run the guard again after the `UPDATE`, or run it on the final point set.

- **[severity: fragile]** planning/active/findings.md, "Plan review disposition", G1. The G1
  figures do not reproduce from the current output under the class definitions given.
  Recomputed with core = `rearing`, non-rearing ≤ 10.49 %, 10.49–14.49 % and > 14.49 %, the
  share of visits with any fish is:

  | class | all edges | connectors 1200/1410/1450/1475 dropped | findings |
  |---|---:|---:|---:|
  | core | 0.775 | 0.771 | 0.75 |
  | non-rearing ≤ 10.49 % | 0.421 | 0.349 | 0.33 |
  | 10.49–14.49 % | 0.385 | 0.385 | 0.35–0.37 |
  | > 14.49 % | 0.361 | 0.360 | 0.35–0.37 |

  BT given fish:

  | class | all edges | connectors dropped | findings |
  |---|---:|---:|---:|
  | core | 0.231 | 0.233 | 0.23 |
  | non-rearing ≤ 10.49 % | 0.188 | 0.179 | 0.18 |
  | 10.49–14.49 % | 0.265 | 0.265 | 0.24 |
  | > 14.49 % | 0.306 | 0.305 | 0.30 |

  The figures look as if they came from an earlier run, before the nudge and the ws50 drop.
  Recompute them from the current output, and state the class definition and edge filter
  used.

  Separately, the Phase 1 bullet "the union adds no double count" contradicts B2 in the same
  file (a union of the two schemas double-places 11,421 visits).

## Checked and fine

- **Step-5 join.** Each `score284_bt_rear_*` schema has its own `streams`. For all 543,242
  held-out segments its `(wsg, id_segment)` maps one-to-one onto `score284_default`, with
  identical `blue_line_key` and measures (checked for 0p1249 and 0p1449).
  `streams_habitat_bt` is unique on `(wsg, id_segment)` in every variant, and every variant
  holds all 8 held-out WSGs. `Reduce(..., step5, v)` puts `v` first, in the correct order.
- **Absence logic.**
  - The char group in the codes file is exactly BT, BT/DV, DV, DV/BT, DVxBT and SLV. No other
    trout or char is in it, so the blocking sets are right.
  - Pooled WSGs: SLV blocks the absence. Non-pooled WSGs: BT/DV, DV/BT, DVxBT and SLV block it.
  - `blocks_absence_of` "char" picks up AF, SP and TR.
  - `bt_present = FALSE` with `bt_n > 0` occurs nowhere.
- **Fallback.** `UPDATE … NOT IN (tmp_bt_use_placed)` is correct, and no visit is placed
  twice.
- **Overlap SQL.** sum(lengths) − (max urm − min drm) gives the pairwise overlap, and the
  whole length for a duplicated segment. `coalesce` handles the no-row case.
- **Ledger.** It partitions the input: 53,018 = drops + 17,592 kept. Every number in the
  findings ledger table matches the file. 17,592 kept, 2,616 with BT, 4,080 held out,
  21,915 nudged and 31 BT on code 0 all match the output.
- **In-sample columns.** All 1,807 in-sample visits carry `segment_gradient_score284`, and
  no other visit does.
- **Types.** `access_bt` is an integer in the database.
- **Pooling.** `lnk_species_pooling()` returns `self` rows only for WSGs where BT is
  present, so the `bt_absent_from_wsg` drop is right.
