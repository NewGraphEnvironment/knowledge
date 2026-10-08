# Plan review (Plan agent, 2026-10-07) and dispositions

The reviewer (read-only) returned its findings as reply text; this file records them. Disposition after each.

## Blocker
- **B1. A stream-size depth already meets a FLOW cell.** Rows 250, 257 and 264 (Sloat et al. 2017; CO, PK and CM
  spawning, `depth` min 0.5 m) are bankfull depth, which is a channel-size criterion. `meets()` would count row 250
  for CO depth lower, spawning. Row 407 (ST velocity, Cooney & Holzer) is NHD mean annual velocity, but it is
  `qual`, so it meets no cell.
  → **Fixed in Phase 1.** `depth` takes `m bankfull`, and the three rows moved to it. The FLOW depth cells
  will not count `m bankfull`.
- **B2. The gate cannot verify depth in cm, or US-unit depth and velocity.** `depth` took only `m` and
  `velocity` only `m/s`, and `SCALE` has no cm → m rescale. #33 dropped two Hagen & Weber depth rows for this
  reason. The HSI models give depth in cm; the WA and Central Valley reports give ft and ft/s.
  → **Fixed in Phase 1.** Units are kept as the source wrote them: `depth` takes `cm` and `ft`, `velocity`
  takes `cm/s` and `ft/s`. Scale 1 fails closed.

## Gap
- **G1. The grid rewards only limits, but the main flow evidence is optima.** A PHABSIM optimum never meets a
  cell. → **Plan corrected:** an `instream_flow` cell is met by `min`, `range` or `optimum`, as the issue
  reads ("a minimum, an optimum, or a fraction of MAD"). Depth and velocity cells stay limits. The brief says
  an optimum span (Tennant's 60–100 %, an 80 %-of-WUA band) is `optimum`, never `range`.
- **G2. No rule for standards that name no species or stage** (Tennant, Hatfield 2003, Ptolemy & Lewis,
  DFO 2013). Row 121 says "salmon" and is coded CH. → **An identifier fork for Al**, asked at the start of
  Phase 4 with a recommendation. Phases 2 and 3 do not depend on it.
- **G3. Nothing tied `parameter` or `model_id` to the variable.** → **Fixed in Phase 1.** `instream_flow`
  carries neither, and `*_mad_*` parameters go on `discharge` only. Both have tests.
- **G4. The metric list may lack what the BC thresholds use** (percentiles or exceedance per month; 7Q2 and
  7Q10). → **Plan corrected:** a vocabulary checkpoint after the BC documents are read, before drafting. A
  `7day_low` row gives its return period in the note.
- **G5. `annual_mean` on `instream_flow` blurs need and size.** → **Fixed in Phase 1:** dropped.
- **G6. The timing table cannot place most cells in the year.** It has no `rearing` rows, has GR nowhere,
  writes `CT` not `WCT`, and covers only BULK and MORR. → **Research file states it** as the gap in the #42
  join.
- **G7. Whether `habitat_modelling` needs a rebuild.** → **Decided: no.** `Fisheries/flow` is not one of its
  input collections, so the `flow` store stands alone, as `temperature` does.
- **G8. The #38 brief carries dead scratchpad paths.** → **The brief names this session's copies** of the
  #29 archive's `scratch_keytext.py` and `scratch_merge_drafts.py`.
- **G9. `percent MAD` has no SCALE entry.** A quote written "0.2 MAD" cannot verify 20. → **Phase 3 adds
  `percent MAD = c(1, 100)`**, as `percent` has. `meets()` ignores units, so the write-up does not compare
  m3/s with percent MAD.

## Ordering
- **O1. `0270` exits non-zero on an additions row whose PDF is missing.** → Pending items stay out of
  `flow_additions.csv` until their PDFs are in the repo. Then `0270` is re-run, the store rebuilt and
  re-pushed, and the text re-extracted.
- **O2. Settle the vocabulary before drafting.** → Done for B1, B2, G3 and G5; G4 is a checkpoint before the
  brief.
- **O3. Record the grid baseline.** → Phase 3 records the baseline before any drafting.

## Assumption
- **A1.** Hickman & Raleigh 1982 is generic cutthroat, so `CT`, not WCT; Raleigh 1984 is `RB` unless it says
  steelhead. → Brief rule.
- **A2.** Bjornn & Reiser is an OCR scan, and OCR drops decimals. → Expect unverifiable rows; use the HSI
  originals where they exist.
- **A3.** HSI breakpoints are often figure-only. → Expect `none` or `qual`.
- **A4.** The Boughton & Goslin over-summer envelope stays `discharge`. → The research file cross-references
  it.
- **A5.** SK rears in lakes, so its instream-flow rearing and overwintering cells and its velocity rearing
  cell barely apply. → **Dropped from the grid.**

## Scope
- **S1.** Passage depth (Thompson 1972, via Bjornn & Reiser) has no cell. → **Added:** `depth` lower ×
  `migration`.
- **S2.** Most cells will be `none`. → The write-up does not read a full grid as covered.
- **S3.** Version bump. → NEWS says 0.4.0 is minor because row 121 left `discharge` and three depth rows
  changed unit, so a downstream filter on them now returns fewer rows.

## Acceptance
- **AC1.** Phase 3 pass/fail: `flow: N of M` printed, the exit condition, a negative run (delete one `none`
  row → exit 1), and an enumeration of `meets()` over variable × valued/none/qual × bound. → Added.
- **AC2.** Phase 1 tests: an `instream_flow` none row with bound and metric; a `qual` row refusing a metric; a
  parameter or model_id on `instream_flow` refused; units. → Added. A mutation run turns each guard red.
- **AC3.** The roxygen read "only `instream_flow` takes a `metric`". → Reworded "of the two".
