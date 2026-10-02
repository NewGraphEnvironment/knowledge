# Review p2/p4 round 2: the round-1 fixes

Scope: research/habitat_weights.md, planning/active/findings.md (Phase 2 section and the round-1
table), planning/active/link-issue-draft.md, the knowledge#28 issue body, and the `sources` column of
data/habitat_weight_bt_rear.csv. Every number was checked against data/bt_rear_use_curve.csv (CSV),
data/habitat_weight_bt_rear.csv (WCSV), scripts/logs/habitat/20261002_bt_use_curve.txt (LOG) or
scripts/logs/habitat/20261002_bt_use_build_ledger.csv (LEDGER). The literature figures were checked
against data/literature_evidence.csv rows 482–489, and the probes read data/fdis/derived/bt_use_visits.csv
read-only. Nothing was run in place.

## Findings

- **[severity: bug]** The access-code split is circular, and the fixes use it as independent evidence.
  Affected: research/habitat_weights.md, short answer bullet "Where BT are known upstream" and its
  sub-bullet ("detection is the same on steep and non-steep stream: 0.034 on both"; "The overall decline
  comes largely from where BT are known upstream (code 2)"); the driver table's `gradient` row
  ("BT-known-upstream share 30 % → 9 %") and the "where fish and BT live at all" row (evidence:
  "access split"); findings.md Phase 2 point 9 ("it is the same mechanism as F: whether BT live up there
  at all"); the #28 issue body ("On segments with no BT record upstream, detection is 0.034 on steep and
  non-steep stream alike"); and the link draft ("What falls with gradient is ... the share where BT are
  known upstream").
  - 0290's own header says code 2 is "defined from bcfishobs, mostly these same FDIS records". link breaks
    streams at every bcfishobs record, and a visit takes the segment starting at its site, so a visit's own
    BT record tends to put its segment in code 2.
  - The data show this directly. On steep segments (> 10.49 %), code 2 holds **2.6 %** of BT-absent visits
    (1,521) and **68.1 %** of BT-present visits (163). On non-steep segments the figures are 21.6 % (10,945)
    and 83.3 % (1,834). The steep pair can also be derived from the LOG: 150 × 0.740 = 111 of 163 BT
    visits are code 2, against 39 of 1,521 non-BT visits.
  - So within code 1, a BT catch is mostly a catch that never reached bcfishobs, and "0.034 on both"
    measures that recording gap rather than BT detection where BT are not known upstream.
  - For the same reason, the fall in code-2 share with gradient (0.50 to 0.05–0.10) is partly the BT catch
    rate falling, re-encoded. It cannot show that "the decline comes from where BT are known upstream"
    or "whether BT live up there at all".
  - The same holds for code 2's 0.74 steep rate, which is inflated by self-reference.
  - The F/C decomposition (F falls, C does not) still stands on its own. Only the access-code reading
    should go, or be restated as composition that is partly the outcome.
- **[severity: bug]** planning/active/link-issue-draft.md, "Not in scope": "An upper-fish-limit model,
  which is the real driver of the steep decline." This is the inference round 1 flagged, now asserted more
  strongly, and in the public draft. research/habitat_weights.md now says "Nothing here locates the upper
  limit of fish ... the analysis does not show which", and findings point 1 says the same. The link draft
  contradicts both.
- **[severity: fragile]** planning/active/link-issue-draft.md, "If we do it" bullet 2: "Stream just past
  the cutoff counts at its weight (0.5–0.64) rather than all or nothing". Under the recommended option
  (A), stream past the cutoff in force carries no weight and counts as 0, so this bullet describes
  option (B). Only the second half ("a cutoff change moves the weighted figure less than the cutoff
  figure") holds under (A). This is the round-1 finding 8 defect, moved one sentence up.
- **[severity: fragile]** #28 issue body, "If we do it": the parenthetical was added ("it turned out to
  measure expected use, not habitat quality"), but the next sentence still says "report
  quality-weighted km" and that it "stops jumping every time a threshold moves". The first contradicts
  the parenthetical and the Answer. The second is the claim round 1 found true only under option (B),
  and was fixed in the draft but not here.
- **[severity: fragile]** #28 issue body, Problem: "part of what reads as 'too steep' is 'higher up':
  colder, smaller, less sampled". The Answer now says step 5's taper "is detection, not sampling density"
  with even sampling. Read top to bottom, the body contradicts itself. The convention is to edit the
  body, with a note if the correction matters.

Rewritten claims checked and found supported (not overstated):
- **Elevation.** "Real in the held-out WSGs, per visit as well as per km ... sampling is even ... so step 5's
  taper is detection, not sampling density." 0290 defines the elevation third as the length-weighted
  tercile of each WSG's own default BT rearing, so each third holds equal rearing km per WSG. Flat core
  visit counts (942 / 818 / 913) are therefore flat visits per km, and the per-km taper must come from the
  per-visit rate.
  - The rates are raw. Round 1's adjusted held-out fit gave rate ratios of 0.765 and 0.360, the same
    direction and size, so the raw figures do not overstate it. "Regional" is supported by the calibration
    sign.
- **Spawner evidence.** The per-visit comparison is right. Pooled over the four steep classes it is
  19 / 163 = 11.7 %, against 23 / 791 = 2.9 % at core 0–2. "The data cannot separate the two" is properly
  hedged.
- **FDS against FDIS.** "Agree on the first steep step and diverge after it" matches the LOG.
- **"C ≈ 1 is not proof of equal quality"** is stated in all four documents.
- **The `sources` column of data/habitat_weight_bt_rear.csv** carries no private reference. The string is
  "BC FDIS electrofishing site visits on link default segments, effort-adjusted; context: Isaak et al.
  2015; Dunham and Chandler 2001; Porter et al. 2008".
- **The link draft** has no private identifiers: no knowledge#, no WSG codes, no client or project names.
  It cites only link#284 and #284.

## Enumeration

| claim (location) | value | source | match |
|---|---|---|---|
| F core 0–2 (R short, F2 #1, issue) | 1.16 | CSV all/any_fish 1.164 | yes |
| F 8–10.49 (R, F2) | 0.57 | CSV 0.574 | yes |
| F beyond cutoff (R, F2, issue) | 0.24–0.38 | CSV 0.384/0.342/0.242/0.292 | yes |
| C steep range (R, issue) | 0.88–1.27 | CSV 1.272/1.271/0.881/1.199 | yes |
| C steep intervals all include 1 (R, F2, issue) | 0.86–1.77, 0.63–2.03, 0.27–1.79, 0.81–1.79 | CSV | yes |
| C not rearing interval (F2) | 0.82–1.35 | CSV 0.816–1.351 | yes |
| code-1 BT rate steep / non-steep (R, F2, issue) | 0.034 / 0.034, 1,534 / 8,888 | LOG access block | yes (but circular: finding 1) |
| code-2 share non-steep / steep (R, F2) | 30 % / 9 % | LOG 3891/12779 = 0.304; 150/1684 = 0.089 | yes (circular) |
| code-1 rate range (F2 #9) | 0.016–0.067 | LOG | yes |
| code-2 rate range (F2 #9) | 0.30–0.85 | LOG 0.296–0.845 | yes |
| code-2 share core 0–2 → steep (F2 #9) | 0.50 → 0.05–0.10 | LOG 0.504; 0.084/0.099/0.051/0.099 | yes |
| fry+juvenile share steep (R, F2, issue) | 87–94 % | LOG 0.936/0.895/0.875/0.871 | yes |
| measured fish 10.49–12.49 / >14.49 (F2) | 249 / 294 | LOG | yes |
| visits with fry/juv steep (F2) | 80–100 %, 5 visits at 13.49–14.49 | LOG 1.000/0.923/0.800/0.931; 5 | yes |
| adults at core 0–2 (R, F2) | 511 of 3,195 | LOG | yes |
| spawner 10.49–12.49 (R, F2) | 9 of 63 | LOG 9; n_detect 63 | yes |
| spawner >14.49 (R, F2) | 9 of 75 | LOG | yes |
| spawner core 0–2 (R, F2) | 23 of 791 | LOG | yes |
| area coefficient (R Q3, dead ends, F2) | 0.07–0.19 | round 1 verified (0.070/0.192/0.193) | yes |
| time-effort max steep move (R Q3) | ≤ 0.1 | LOG 0.641→0.735 (0.094) is the largest | yes |
| sensitivities move ≤ ~0.1 (F2 #7) | ~0.1 | LOG max 0.094 (time), logit 0.052, others smaller | yes |
| Isaak App. S1 (R Q5) | 0.63/0.84/0.95 at 6/9/12 %, 1,102 sites | literature row 487 note | yes |
| Isaak Table 4 (R Q5) | −0.166 per % logit | row 482 | yes |
| Dunham & Chandler p. 30 (R table) | elevation–temperature relation is local | row 484 | yes |
| weight falls to ~0.5 beyond 12.49 (R table) | 0.5 | WCSV | yes |
| held-out elevation log-lik (R, F2) | −1,754 → −1,836; −82.4 | LOG −1754.2 / −1836.5 / −82.4 | yes |
| held-out core per-visit by third (R, F2, issue) | 0.40/0.28/0.11 | LOG 0.401/0.275/0.106 | yes |
| held-out core visits by third (R, F2) | 942/818/913 | LOG | yes |
| calibration core per-visit (R, F2) | 0.10/0.17/0.16 | LOG 0.101/0.169/0.156 | yes |
| all-WSG elevation ratios (R dead ends, F2) | 1.27 / 1.01 | LOG 1.273 / 1.010 | yes |
| log(width) coefficient (R, F2) | +0.229, SE 0.028 | LOG | yes |
| width lift (R) | 0.10–0.15 | LOG 0.151/0.141/0.096/0.138 | yes |
| width subset before → after (F2 #4) | 0.73/0.50/0.40 → 0.88/0.64/0.49 | LOG (three of four steep classes; >14.49 0.55→0.69 omitted) | yes |
| MAD lift (R, F2) | 0.15–0.43 | LOG 0.392/0.300/0.150/0.434 | yes |
| MAD before → after (F2) | 0.50→0.89, 0.34→0.64, 0.15→0.30, 0.51→0.94 | LOG | yes |
| null shares (R, F2, draft) | width 12.7 %, measured width 57.1 %, MAD 25.3 % (draft: ~13 %, ~25 %) | LOG | yes |
| code-0 BT catches (R) | 28 | LEDGER bt_present_on_access_bt_0 | yes |
| not rearing ≤10.49 U / C / F (R) | 0.50 / 1.07 / 0.36 | CSV 0.498/1.066/0.362 | yes |
| candidate table, all 8 rows (R) | weight, U (interval), C, F, visits | WCSV | yes (0.065 printed as 0.07) |
| underpowered class (R) | 157 visits, 7 BT | CSV | yes |
| core 0–2 no-river-polygons (R) | 0.93 | LOG 0.929 | yes |
| held-out vs cal U at 10.49–12.49 (R, F2) | 0.42 vs 0.75 | CSV 0.416 / 0.745 | yes |
| held-out vs cal C at 10.49–12.49 (R, F2) | 0.79 vs 1.55 | CSV 0.787 / 1.547 | yes |
| held-out vs cal U / C at >14.49 (F2) | 0.50 vs 0.63; 0.77 vs 1.81 | CSV 0.495/0.628; 0.768/1.81 | yes |
| intervals overlap (R, F2) | — | CSV 0.185–0.756 vs 0.516–0.971; 0.29–1.488 vs 1.036–2.145; >14.49 likewise | yes |
| step-5 band visits (R, F2) | 85/34/20 | LOG | yes |
| FDS vs FDIS at 10.49–12.49 (R, F2) | 0.60 / 0.61 | LOG 0.600 / 0.605 | yes |
| FDS steeper (R, F2) | 0.91/0.50/1.12 | LOG 0.907/0.499/1.117 | yes |
| FDIS steeper (R, F2) | 0.44/0.31/0.50 | LOG 0.443/0.307/0.497 | yes |
| FDS "two under the power rule" (F2) | 2 | round 1 probe (6 and 2 detections) | yes |
| link-modelled WSGs (R coverage) | 63 = 55 + 8 | 0290 header (55 in fresh_default) + 8 held out | yes |
| U fit coverage (R, F2, draft) | 53 WSGs, 13,161 visits | LOG | yes |
| any-fish / C fit WSGs (F2) | 57 / 52 | LOG | yes |
| visits outside link's WSGs (R) | 19,691 placed | LEDGER wsg_not_in_link (after placement drops) | yes |
| population (F2) | 17,606 / 16,729 / 14,463 / 1,997 | LOG | yes |
| placement nudge (R dead ends) | 817 visits, 171 change band | review-p1-round2.md | yes |
| segmentation agreement (F2) | 98.1 % of 1,698 | LOG | yes |
| F2 Phase 2 weights table, 9 rows × U (interval), F, C (interval) | — | CSV | yes |
| draft weight table and 0.5–0.64 | — | WCSV | yes |
| issue weight table | — | WCSV | yes |
| issue step-5 band share "101 of 422 km" (R) | 101 km | issue body Problem | yes |
