# Review p5, round 2: round 1's fixes, then every number in research/flow_requirements.md again

How I checked: data/literature_evidence.csv read with Python csv (data row N = list index N-1; 1014 data
rows), compared with `git show main:data/literature_evidence.csv` (686 rows). I reimplemented 0280's
`meets_flow()` with per-cell row lists, split into valued and `none`. I read pkg/R/literature.R on this
branch and on main, and the scratch pdftotext of Hatfield et al. 2002 p. 92 to check the new notes on rows
825 and 837. I edited nothing in the repo.

## Findings

- **[severity: bug]** research/flow_requirements.md:55-59. The section is headed "The generic floor (fills no
  cell)" and names "Hatfield et al. 2002 Table 5 (rows 819–825 ...)" and "Ptolemy & Lewis 2002 (rows
  803–818)". Nine of those rows are species-coded and do fill cells:
  - 825 is `ST`, migration, 50–100 % MAD. It is one of the four rows in the ST migration cell (825, 836, 837,
    842).
  - 810–817 are `ST`, rearing: the PHABSIM optima the By species table cites for ST. They are 8 of the 11
    rows in the ST rearing cell.

  Round 1's fix (819–826 → 819–825) kept 825 inside the heading. The group-coded rows that fill no cell are:
  - Table 5: 819–824, plus 826 (p. 43).
  - Ptolemy & Lewis: 803–809 and 818.

  Suggested wording: "Table 5 (rows 819–824; 825, summer steelhead passage, is coded ST and fills that cell;
  826 is the p. 43 linear stand-in)" and "Ptolemy & Lewis 2002 (rows 803–809 and 818; their steelhead optima,
  810–817, are ST rows)".

- **[severity: fragile]** research/flow_requirements.md:88, ST flow-need column. It describes the ST rows as
  the Ash and Cheakamus charts (836–846) plus the Ptolemy & Lewis optima (810–817). Five gate rows are not
  mentioned:
  - 825: Table 5 summer steelhead passage, 50–100 %.
  - 827: Hatfield & Bruce, Salmon River, 5.5 m3/s `optimum`, "flow of least risk".
  - 859, 860, 861: Clear Creek WUA peaks for steelhead spawning at 350 and 600 cfs, and the 200 cfs
    January–June recommendation.

  859–861 are three of the five rows in the ST spawning cell (838, 843, 859, 860, 861). The CH row names its
  Clear Creek rows (857, 858); the ST row does not, so a reader would conclude ST has no Clear Creek flow
  rows.

- **[severity: fragile]** research/flow_requirements.md:133. Round 1's fix files all four blank-bound rows
  (881–883, 900) under "means with no bound". Rows 881, 882 and 883 are means: their notes say "a mean, not a
  limit". Row 900's note says "The table does not say whether this is a mean." Round 1's own premise, that
  all four notes say a mean, was wrong for 900. Suggest: "(the trout draft wrote four as `dist` rows with no
  bound, which fill no cell: three means, 881–883, and 900, which the table does not call a mean)".

- **[severity: fragile]** research/flow_requirements.md:91, BT spawning depth: "redd means 24–58 cm, 30–60
  cm". Row 876 (24–58 cm) is a range of redd-depth means. Row 886 (30–60 cm) is not: Roberge's quote is
  "in shallow (30 - 60 cm) low gradient areas", the depth of spawning areas, and its note says "Depth of
  spawning areas". Suggest "redd means 24–58 cm (876), spawning areas 30–60 cm (886)".

- **[severity: fragile]** research/flow_requirements.md:87, CH spawning depth: "15 rows: criteria ≥24–30 cm
  (Bjornn & Reiser, Levy & Slaney), HSI zero edges at 9–15 cm (Raleigh), observed redd depths". These
  categories account for 11 of the 15 rows (698, 720, 721; 731, 738, 740, 742, 744; 703, 704, 777). Four HSI
  rows fit none of them:
  - Beecher & Caldwell's zero edges 762 (0.55 ft), 763 (1.55 ft) and 766 (0.35 ft);
  - Clear Creek's 0.8–7.0 ft range (849).

  This is the same class as round 1's last fragile finding. That fix covered only the three instances round 1
  named.

- **[severity: fragile]** CLAUDE.md, new convention bullet: "A standard that names no species is coded for the
  scope it states ..., one row per statement, and fills no grid cell." Taken literally, "one row per
  statement" is false for the group-coded rows. Each of these statements is split into two rows by stage,
  with one shared quote:
  - 805/806 (rearing and overwintering);
  - 807/808 and 822/823 (spawning and migration).

  That split is what the convention two bullets earlier requires ("a statement that bears on two variables is
  two rows sharing one quote"). The intended rule seems to be "not one row per species". Suggest "one row per
  statement and stage, not one per species".

- **[severity: fragile, low]** research/flow_requirements.md:36-37, `optimum` definition: "a PHABSIM or WUA
  peak, Tennant's optimum range, or the best class of a three-class scheme". Two `optimum` rows fit none of
  these:
  - 804: Ptolemy & Lewis, "Optimum rearing flows in these habitats are about 10% MAD", a confined-channel
    expert value.
  - 861: Clear Creek, a recommended 200 cfs that "may be close to" the maximum, a hedged recommendation.

  Either add "or a value the source calls optimum", or leave it, since neither row fills a cell that would
  change.

## Round 1's 11 findings: re-check

1. ST charts / row 837: **fixed.** 836–846 hold 20 % for incubation, rearing and overwintering (839–841,
   844–846) and 34–45 % for spawning and passage (836, 838, 842, 843). Row 837 is 50–100 %.
2. CH Clear Creek: **fixed.** Row 857 is the WUA peak at 650 cfs. Row 858 is the ≥600 cfs September–December
   recommendation.
3. Means with no bound: **fixed, with a new inaccuracy** (900 is not a mean; above).
4. Status line: **fixed.**
   - Spawning depth and spawning velocity have values for all 7 species.
   - Rearing velocity has values for the 6 species that have that cell; SK has none, because it is skipped.
   - BT passage depth is `none` (995), and so is WCT's (1006).
   - All 60 cells are met.
5. Table 5 rows: **fixed as far as it went.** 819–825 are on p. 41 and 826 is the p. 43 stand-in. The new
   wording still files 825 under "fills no cell" (above).
6. Ptolemy & Lewis optima: **fixed.** The percent rows are 12, 29, 48 and 128 (810, 811, 814, 817). The m3/s
   rows are 0.19, 1.06, 4.0 and 9.0 (815, 816, 812, 813).
7. Header row list: **fixed.** Pre-#44 rows with variable `instream_flow`, `depth` or `velocity` are exactly
   121, 250, 257, 264, 407, 497 and 498. A diff against main changes 121, 250, 257, 264, 497 and 498, and not
   407. Rows 687–1014 are all one of the three variables (328 rows).
8. `metric` bullet: **fixed.** Rows 865 and 866 are `monthly_mean`. Row 121 is `unstated`, and its note says
   the sentence names no statistic.
9. CLAUDE.md "a valued one names its `metric`": **fixed.** It matches `.literature_check()`: the `bare` check
   applies to valued rows only, and the 22 blank-metric `instream_flow` rows are `none` or `qual`.
10. Omitted gate rows: **fixed for the three named.** 894 is now in BT, 782 in ST and 923 in GR. The CH depth
    list has the same gap (above).
11. task_plan.md:43: **addressed.** The line now says `annual_mean` and `seasonal_mean` were dropped.

## Everything else in research/flow_requirements.md: checked and correct

- **Header and sources:**
  - 35 collection items (26 members + 9 additions), 34 with a PDF.
  - 45 `discharge` rows on main, 44 now. Row 121 moved and is coded `SALMON`.
- **Units, metrics, bounds and codes:**
  - The `qual` equation rows are 809 and 824.
  - The no-bound 30–200 % rows are 807, 808, 822 and 823.
  - `instantaneous` rows are exactly Tennant 791–802 plus DFO 848.
  - The only `percentile` row is 847. No row uses `percent exceedance`.
  - 56 of the 70 `percent MAD` rows are `unstated`, and 77 of the 98 valued `instream_flow` rows are.
  - Ford's "excellent" `optimum` rows are 961 and 963. Raleigh's is 760, and its note says "best of three".
  - Row 928 is CT, <1 cm/s.
  - DFO 848 and Hatfield 2003 847 are both `rearing` and `FISH`.
- **Generic floor:**
  - Table 5 values: 20 % for rearing, overwintering and incubation; 30–200 % for migration and spawning;
    50–100 % for summer steelhead passage "Days".
  - Appendix A charts cover the Nechako, Ash, Cheakamus and Sinmax (977–981).
  - Tennant 791–802 classes are 40/60, 30/50, 20/40, 10/30, 10/10, plus the 60–100 optimum.
  - Neuman & Newcombe are 788 (15 %) and 789 (30 %).
  - Raleigh 760 is ≥50 % excellent and 761 is <25 % poor.
  - Keeley & Slaney (867, 868) and Bjornn & Reiser (706–709) group rows exist.
- **By species: every count matches the gate.**
  - CH: 15, 18 and 17. Nechako 832–835 are 22/20/20/20. Rows 828–831 are the 5.8 m3/s example. Warkentin
    862–864 give 10.6 m3/s and 36 %. Passage depth is 0.24 m (687–689).
  - ST: 4 / 4 / 4. Depth: ≥24 cm (724), HSI edges 0.4 ft (853) and 0.65 ft (773), 0.2–1.5 m (782); passage
    0.18 m (726).
  - CO: 2 (722 ≥18 cm, 769 0.15 ft), 0.18 m (692), velocity 2 and 4. Row 865 is September, 1 m3/s.
  - SK: 2 (723 ≥15 cm, 771 0.15 ft), 0.18 m (725), velocity 2. Row 866 is a migration flow; its spawning and
    incubation rows are `none` (874, 875).
  - BT:
    - Flow needs: 901 (40–80 %) and 902 (55 %).
    - Spawning depth: 4 rows (876, 886, 889, 894); passage depth `none` (995).
    - Velocity: 5 rows, including 498 at 65 cm/s; rearing velocity: 6 rows, including 879 at 30 cm/s.
  - GR: depth 3 rows; passage 924 is the 0.3 ft zero edge and 923 is 0.4 ft at SI 1.0; velocity 6 and 5. All
    five flow cells are `none` (996–1000).
  - WCT: depth 926, 929 and 933, all within 0.10–0.75 m. Velocity 3 and 4. Flow cells and passage depth are
    `none` (1001–1006).
- **Notes and `none` rows:**
  - Row 777 is 4.0–8.1 m at the Columbia dam outfalls.
  - The `none` rows in these three variables are exactly 870–875 and 992–1006.
  - The coho `none` notes (870, 871, 873) cite the Ash p. 92 general standards as naming no species.
- **#42 comparison:**
  - `monthly_mean` m3/s rows are 862, 864, 865 and 866, plus the Davidson Creek RB rows 989 and 990. The file
    names the Warkentin and Gottesfeld rows as examples, which is true.
  - The timing claims stand as round 1 verified them.
- **Not obtained:**
  - Five sources are listed.
  - Hatfield & Bruce 2000 is reported via 810, 811, 814–817 and 827.
  - Raleigh et al. 1984 is reported via 954, 955 and 960–964.
  - Hickman & Raleigh is reported via 942 and 943.
  - McMahon is reported via pre-#44 coho rows.
  - Bradford & Heinonen 2008 is cited in no row, so "cited only where another document reports them" is
    vacuous for it, but not false.
- **Audit counts** (58/325, 24/77, 0/44, 34 groups): unchanged from round 1's verification.
- **Staged notes on 825 and 837:** PDF p. 92 has "Summer Steelhead passage 50-100%mad or up to 27.8 cms",
  "Adult passage (general) 45%mad" and "Spawning 45%mad". The new note is accurate.

## CLAUDE.md and NEWS 0.4.0 against pkg/R/literature.R

- The CLAUDE.md data line is true, and the convention bullet is true apart from the "one row per statement"
  wording above:
  - Valued `instream_flow` rows need a metric (`bare`).
  - `instream_flow` rows may carry no `parameter` or `model_id` (lines 253-258).
  - `depth` fits include `m bankfull`.
  - The units and metric lists match `fits$instream_flow` and `.knw_metric_fits()$instream_flow`.
- NEWS 0.4.0 is true:
  - The units and metrics match.
  - "no parameter or model_id" and "`*_mad_*` on discharge only" are both enforced (lines 253-263).
  - The `7day_low` note rule is enforced (line 310).
  - On main, `depth` took only `m` and `velocity` only `m/s`; both now also take `cm`/`ft` and `cm/s`/`ft/s`.
  - The changed rows are exactly 121 (`CH` → `SALMON`, `discharge` → `instream_flow`), 250, 257 and 264
    (`m` → `m bankfull`), and 497 and 498 (`m/s` → `cm/s`, rescaled ×100).
  - DESCRIPTION goes 0.3.1 → 0.4.0.
