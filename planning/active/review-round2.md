# Code-check round 2 — #52 branch (e8d7bcf...HEAD, through 896bd89)

## Findings

- **[fragile]** research/chinook_stream_size.md:136-138 — the case that "a floor between 0.28 and 0.5 is too sharp" uses records that the write-up flags as unreliable everywhere else. The numbers are correct, but the population is not the one the reader assumes:
  - "31 of 57 at 0.1–0.28" includes **14 regulated side-channel detections in CHES** (the Nechako below Kenney Dam, edge 1350). By the doc's own reasoning, wet's natural flow is the wrong flow on those reaches. Without them the count is 17 of 41.
  - "82 of 153" is 52 clean near detections + 13 ambiguous placements (all < 0.1; the distance analysis leaves these out as possibly sampled in the large river) + 17 side channels. The short answer's "52 of 107" excludes both groups, and this paragraph does not say that it includes them.
  - "relative 0.47 against 0.61; raw 3.2 % against 3.3 %" is likewise propped up by the regulated side channels. With regulated reaches out (`sens_regulated_out`), 0.1–0.28 reads 0.46 against 0.72 for 0.28–0.5, and raw 2.4 % against 3.3 %.
  - The "nearly the rate" argument therefore leans on 16 of the 57 detections (28 %), whose flow class the write-up says is wrong in kind. The paragraph should state this, or quote the regulated-out figures.
- **[fragile]** research/chinook_stream_size.md:140-142 — "It would fit these records better than either single floor" is a claim nothing measured. Neither 0295 nor the log fits or scores that rule against a 0.28 or a 0.5 floor. Either measure it, or reword it as what the class rates suggest.
- **[fragile]** research/chinook_stream_size.md:102-103 — "Coastal small streams draining straight to the sea (`none`)" overstates what `none` means.
  - Of the 1,243 `none` walks in the distance population, 685 (55 %) pass through 1–5 other lines below 10 m³/s before reaching the sea. Only 558 drain directly.
  - Among the 11 `none` CH detections, 2 (LFRA, hops 1 and 2) are not direct.
  - `none` means "reached the sea without meeting a ≥ 10 m³/s segment".
- **[fragile]** research/README.md:17 (index row) — "one survey dominating > 30 m³/s" is wrong for 30–100 m³/s. That class's largest project (top_project_share 0.507) is FDS / BC Hydro 2007 on the **Bridge River** (blk 356363618, regulated by Terzaghi). The Nechako 2010 survey dominates only ≥ 100. The body of the write-up is correct here: its short answer and Limits name only the top class.
- **[fragile]** Code-comment quantities disagree with the measured outputs:
  - scripts/0294-ch-mad-build.R:25 says parent-flow segments are "where CH are caught at four times the overall rate". The ledger gives 140/445 = 31.5 % against 1,186/21,862 = 5.4 %, which is 5.8×; the write-up says "about six times".
  - scripts/0295-ch-mad-use.R:32-33 says the Nechako survey "holds about a third of all detections". The log gives 432 of 978 analysed (44 %); a third holds only against 0294's 1,186.

## Verified (no finding)

- **Every other number and quantifier** in research/chinook_stream_size.md matches data/ch_mad_use.csv, the use log, the build ledger, the visits table, the DB or the evidence rows. This covers:
  - all nine MAD-table rows (visits, CH, raw, U rel and CI, C rel, regulated detect share, top project);
  - the distance table, including the `none` upper bound (2.7e7, "unbounded");
  - 53,018 / 106 / 20,832 (3 CH) / 21,862 (1,186) / 19,077 (978) / 102 / 507 / 67 / 15,626;
  - 17,289 + 1,788; 445 / 140 / 31 % / 5.4 %; 101 dams; 38 dams with a degree of regulation;
  - the 1.5 % / 28 % / 66 % / 81 % regulated shares, and CHES 14 + NECR 2 (both side channels with `flow_from = own`);
  - F from 0.42 to 3.0 (monotone); the 32 WSGs as 11 / 8 / 13; the sensitivity envelope 0.08–0.74 (min 0.082 barrier, max 0.743 old MAD), all ≥ 0.5 classes > 1 except the two exceptions named;
  - balance 0.29 / 0.54 and routed 0.55 / 1.46; agreement 53–67 % against 75–99 %; regulated-out 149/41/27.5 %/3.2 and 153/12/7.8 %/8.3;
  - 72 % in river polygons (702 of 978) with no-river ranks rising 0.34 → 4.5; distance sensitivities 30.2 / 28.8 / 24.0;
  - cross-check 4,384, 13 % against 16 %, and 54 %; evidence data rows 118–119 (Rebellato, 0.28 / 100) and 412 (Woll, 0.5); Kenney 621 %.
- **The round-1 fixes hold:**
  - `regulated_detect_share` is `sum(resp * regulated) / n_detect` per class, with `n_detect` already summarised. It is NA where a class has no detections (old MAD ≥ 100 is blank in the csv).
  - In C it is computed over fish-bearing visits with y = U, so it equals U's share, as it should.
  - In the distance analyses it is 0, which is correct: no non-side-channel small-stream visit is regulated.
  - `regulated_visit_share` is `mean(regulated)` over the class's visits, and NA when the class is empty.
- **0295 joins and levels:**
  - `dm` keeps every class level and the fit drops empty ones.
  - `rr` and bootstrap columns are re-indexed by `lv` names.
  - `with_cls` vectors are aligned to the frames they come from.
  - `dist_class` has no NA statuses in the data (found 11,431 + none 1,246 = all 12,677).
- **SQL walk:**
  - Measure arithmetic is correct: `cur_m - urm`, floored at 0, plus `cur_m` to the mouth.
  - Parent resolution is correct: a side channel goes to the main line by key, a main line to the parent code.
  - `none` versus `no_parent` holds: every WSG ending `none` is coastal (TSAY checked: codes 910.x).
  - The loop terminates (hop cap 60).
  - 0294 `regulated` puts the dam in fwa_downstream's A role and the visit in its B role, with the `@>` prefilter in the right direction.
- **0294 ledger:** the drops and the kept rows sum to 53,018.
