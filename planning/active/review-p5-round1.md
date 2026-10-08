# Review p5, round 1: staged diff plus 3fdf236's pkg change

How I checked: every number, row, range, count, unit list and metric list in the new prose (research/flow_requirements.md, the research/README.md row, the modelled_discharge.md back-link, NEWS 0.4.0, the new CLAUDE.md lines) was compared with data/literature_evidence.csv (Python csv, data row N = list index N-1), with the pre-branch table (`git show main:data/literature_evidence.csv`, 686 rows), pkg/R/literature.R, scripts/0280-literature-verify.R (I reimplemented `meets_flow()` to get per-cell counts), data/flow_*.csv, scripts/logs/habitat/20261007_*, data/life_history_timing.csv and planning/active/*. Where a note needed a source, I read the PDF page with pdftotext. I edited nothing in the repo; the guard probe ran in the scratchpad.

## Findings

- **[severity: bug]** research/flow_requirements.md, By species table, ST row. It says "Ash and Cheakamus charts (836–846: 20 % rearing, incubation and overwintering; 34–45 % spawning and passage)". Row 837 (Ash, summer adult passage) is `range` 50–100 % MAD, which is the very row whose note this diff rewrites. Correct: "34–45 % spawning and passage, and 50–100 % for summer adult passage (837)".

- **[severity: bug]** research/flow_requirements.md, By species table, CH row: "Clear Creek WUA peaks (857, 858, California)". Only 857 is a WUA peak (`optimum` 650 cfs, `hsi`). Row 858 is the authors' recommendation (`expert`, `min`, "flows exceeding 600 cfs ... are needed throughout September-December"). Correct: "a Clear Creek WUA peak (857) and the authors' ≥600 cfs September–December recommendation (858)".

- **[severity: bug]** research/flow_requirements.md, "Out of scope, not written: ... means with no bound". Four rows are means with a blank bound: 881 (BT redd depth 56.5 cm), 882 (BT nose velocity 0.35 m/s), 883 (BT redd depth 30.5 cm) and 900 (BT rearing 9 cm/s). Their notes say "a mean, not a limit". Either drop "means with no bound" from the not-written list, or say that four BT means were kept (881–883, 900) and fill no cell.

- **[severity: bug]** research/flow_requirements.md, Status: "Depth and velocity are covered for every species." The table directly below gives `none` for BT and WCT passage depth (rows 995 and 1006), and SK has no rearing-velocity cell. What holds is that every depth and velocity cell has a value or a `none` row (gate: flow 60/60). Correct along the lines of: "Every depth and velocity cell has a row; BT and WCT passage depth are `none`."

- **[severity: fragile]** research/flow_requirements.md, generic floor: "Hatfield et al. 2002 Table 5 (rows 819–826)". Row 826 is p. 43 running text (the 55 % linear stand-in), not Table 5. Table 5 is rows 819–825 (p. 41).

- **[severity: fragile]** research/flow_requirements.md, ST row: "PHABSIM optima of 12–128 % MAD from Ptolemy & Lewis (810–817)". Four of the eight rows are in m3/s: 812 (4.0), 813 (9.0), 815 (0.19) and 816 (1.06). The 12–128 % span covers only 810, 811, 814 and 817. Rows 812 and 813 are site PHABSIM riffle peaks; 810, 811 and 815–817 are Hatfield & Bruce's meta-analysis, as Ptolemy & Lewis report it. Suggest "PHABSIM optima (810–817), 12–128 % MAD where given as a percent".

- **[severity: fragile]** research/flow_requirements.md header: "data rows 687–1014 are #44's, plus 121, 497 and 498 from earlier issues". Two counts are right: there are 328 new rows (main has 686 data rows), and 121, 497 and 498 did change. The header's own definition is rows with variable `instream_flow`, `depth` or `velocity`, and four more pre-#44 rows meet it: 250, 257 and 264 (depth; this branch recoded them to `m bankfull`, and NEWS lists them) and 407 (ST spawning velocity, `qual`). Name them, or say "plus 121, 497 and 498 (and the bankfull depths 250, 257, 264, which fill no cell)".

- **[severity: fragile]** research/flow_requirements.md, `metric` bullet: "Warkentin et al. use mean August flow and Gottesfeld & Rabnett average September flow, both `monthly_mean`". This is true of rows 862–866. But the Gottesfeld row that modelled_discharge.md cites (row 121, the p. 6 "flows of less than 1m3/sec often prevent upstream migration") is `metric = unstated`, and this diff adds the new back-link directly under that citation. A reader moving between the two files meets the same 1 m3/s as `unstated` in one and `monthly_mean` in the other. Name the rows: "(865, 866; row 121's p. 6 statement names no statistic)".

- **[severity: fragile]** CLAUDE.md, new data-line clause: "`instream_flow` a flow need, which names its `metric`". 22 `instream_flow` rows have a blank metric: 19 `none` rows and 3 `qual` rows (809, 824, 885). The reader allows that, since a `none` or valueless row needs no metric. The temperature clause just before it says "a ... value names its `metric`"; this one does not say "value", so read literally it is false for 22 rows. Suggest "an `instream_flow` value (a flow need) names its `metric`".

- **[severity: fragile]** The By species table's descriptive lists leave out gate rows. The counts are right; the lists of what makes them up are not complete. BT spawning depth "4 rows (redd means 24–58 cm, 30–60 cm, Ford's 0.15–0.84 m)" names 3 of the 4 (it omits 894, Beecher 0.15 ft HSI). ST spawning depth omits 782 (Roberge, observed 0.2–1.5 m). GR passage "Hubert's 0.3 ft passage edge" omits 923 (0.4 ft, where SI reaches 1.0). Low priority.

- **[severity: fragile]** seasonal_mean leftover: planning/active/task_plan.md:43 still gives Phase 1's metric vocabulary as `"seasonal_mean", "annual_mean", "unstated"`. It will be archived as a spec that disagrees with the code (`annual_mean` was never in the instream_flow list either). Every other remaining hit is historical: the struck-through line in drafter-brief.md, the audit and progress files, scratch_apply_audit1.py's assertions, and draft-ps-evidence.csv. That draft CSV would now fail `knw_literature_read()`, but nothing reads it any more.

## Checked and correct

- NEWS 0.4.0:
  - The units (`m3/s`, `cfs`, `percent MAD`, `percentile`, `percent exceedance`) match `fits$instream_flow`.
  - The metrics match `.knw_metric_fits()$instream_flow` exactly.
  - "no `parameter` or `model_id`" and "`*_mad_*` on discharge only" are both enforced (literature.R 253–263); all 31 `_mad_` rows are discharge.
  - The `7day_low` note rule is enforced (line 310).
  - Depth takes `m`/`cm`/`ft`/`m bankfull` and velocity `m/s`/`cm/s`/`ft/s`.
  - The changed rows are exactly 121, 250, 257, 264, 497 and 498, by a full diff against main. Row 121 also changed metric to `unstated`; NEWS lists variable and unit changes only, which is fine.
  - DESCRIPTION goes 0.3.1 → 0.4.0.
- research/flow_requirements.md:
  - The grid is 7 species × 9 cells − 3 SK skips = 60.
  - There were 45 discharge rows before #44 and 44 now.
  - Boughton & Goslin are rows 310, 311, 318 and 319; Isaak is row 122 (mean August flow).
  - The `qual` equation rows are 809 and 824. The 30–200 % rows 807, 808, 822 and 823 have a blank bound.
  - Tennant is rows 791–802, with classes 40/60, 30/50, 20/40, 10/30, 10/10 and optimum 60–100. All are `instantaneous`, and the PDF's p. 10 Recommendations item 1 says so.
  - Neuman & Newcombe: rows 788 and 789 hold 15 % and 30 %; the PDF says "reduced to half of what is considered adequate for use in Montana" (its Montana figures are 30 % and 60 %).
  - Raleigh is rows 760 (≥50 %, `optimum`) and 761 (<25 %).
  - Hatfield 2003 is row 847: 90th percentile, falling to the 20th, interpolated by monthly median (PDF p. 68).
  - DFO is row 848 (30 % MAD, `instantaneous`).
  - Nechako CH is rows 832–835 (22/20/20/20). Hatfield's MAD 5.8 example is rows 828–831.
  - Warkentin is rows 862–864: 10.6 m3/s, 36 % MAD, August, `monthly_mean`.
  - The upper Bulkley rows are 865 (CO) and 866 (SK), September, `monthly_mean`.
  - BT is rows 901 (40–80 range) and 902 (55 %, adult rearing standard). The CT fry row (<1 cm/s, Cascade cutthroat) is 928. Row 777 is the 4.0–8.1 m spawning beside dam outfalls.
  - The `none` rows are exactly 870–875 and 992–1006.
  - Every per-cell count in the table (CH 15 and 18/17; ST 4 and 4/4; CO 2 and 2/4; SK 2 and 2; BT 4 and 5/6; GR 6/5; WCT 3 and 3/4) equals the gate's `meets_flow()` count.
  - The flow collection has 35 items (26 members + 9 additions), and 34 PDFs went into the store. Raleigh 1984 has no PDF.
  - Audit figures: round 1 found 58 errors in 325 rows (37/191 + 21/134), round 2 found 24 in 77, round 3 found 0 in 44. There are 34 mixed groups (`^== ` lines in audit-round2-mixed-groups.txt).
  - The timing table has no `rearing` rows and no GR, uses CT, and covers only BULK and MORR.
  - 0280 rescales m and km for `bridge_distance` only and has no cm/s → m/s rescale.
- Staged note edits:
  - Row 742: on PDF p. 53, Figure 12's depth curve has an extra 121.9 cm / 4.0 ft coordinate at SI 1.0; otherwise it equals Figure 5's category one (row 731, PDF p. 45).
  - Rows 825 and 837: PDF p. 92 has "Summer Steelhead passage 50-100%mad or up to 27.8 cms", with general adult passage and spawning at 45 %mad.
- CLAUDE.md data line: `0270 --collection flow` exists, and `FWTJDD8Z` matches the build log.

## 0280 guard: Clean

- `if (at >= length(s$tok)) { ok <- FALSE; break }` is correct. Once it passes, `at + 1 <= n`, so `(at + 1):min(n, at + 1 + TABLE_HOP)` cannot count down.
- I proved it in a scratch copy of table_pages(). With the guard off, a quote whose prefix matches the last tokens fails: one more token gives "missing value where TRUE/FALSE needed", and more tokens give "NA/NaN argument" on the next `(NA + 1):`. With the guard on, the same quote returns no page. Positive matches return the same pages either way.
- No other countdown exists. The only other range operators are in `occurs()`:
  - `tok[from:(to - n + 1)]` is behind `if (to - from + 1 < n) return(integer(0))`. This also covers `find_quote()` passing `from = at = length(tok) + 1`.
  - `tok[i:(i + n - 1)]` has `i` bounded by the candidate set.
  - There is no function named `text_pages()`; text quotes go through `find_quote()` and `occurs()`, checked above.
- The re-wrapped comment says the same thing as before.

## seasonal_mean removal (3fdf236): Clean in shipped code

There are no references in pkg/R, pkg/man, pkg/tests, pkg/NEWS.md, scripts/, research/, CLAUDE.md or data/literature_evidence.csv. The roxygen and the Rd agree ("a daily or monthly mean, a monthly median, a `7day_low` average"). The only live-looking leftover is task_plan.md:43 (above).
