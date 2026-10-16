# Code review, round 2 (#54)

Reviewed at aff2a28: the round-1 fixes (e273731, aff2a28), the four scripts, research/chinook_rearing_tuned.md,
planning/active/link-issue-draft.md, and the README, CLAUDE.md and chinook_stream_size.md rows. Every numbered or
quantified sentence in the write-up and the draft was checked against data/ch_rule_*.csv, the three logs and the
derived visit and walk files. The author's own probes were reproduced, and the gaps were filled with read-only probes on
local fwapg, using temp tables in my own session. The probe scripts are in the session scratchpad under `r2/`.

My replication of 0298's outside-check location pipeline gives the logged counts (1,344 / 1,215 / 812 / 326) and the
logged lifts to four decimals (2.7280 / 4.3864 / 3.8611). Findings 1 and 9 rest on it.

## Findings

- **[severity: bug]** scripts/0298-ch-rule-compare.R:373-379, research/chinook_rearing_tuned.md:344-356,
  planning/active/link-issue-draft.md:49-50. **Inside round-1 fix 3.** The lift still divides two populations, now
  on a different axis. `loc_s` keeps stream-edge locations on inaccessible segments, while `ks()` divides rearing km
  by accessible stream-edge km.
  - 11 of the 326 stream-edge locations are on inaccessible segments: BBAR 2, COTR 2, KLUM 3, LFRA 3 and TABR 1. Across
    all 812 locations the count is 17.
  - No rule can capture these 11. Rearing is `accessible AND predicate`, and the connectivity pass only removes. link's
    24 CH rows with `rearing = 1` are all in HORS and QUES, outside the 31 groups. The stored flags are FALSE on all
    11.
  - Every capture and lift is therefore biased low by 315/326, about 3.4 %. On the 315 accessible stream-edge
    locations the figures are:

    | rule | capture | lift |
    |---|---|---|
    | `default` | 84.8 % | 2.82 |
    | `default_mad` | 71.4 % | 4.54 |
    | tuned | 76.5 % | 4.00 |

    The reported lifts are 2.73, 4.39 and 3.86. Tuned minus `default` is 1.17 (reported 1.13), and tuned minus
    `default_mad` is −0.54 (reported −0.53).
  - The ranking holds. The draft's "3.9 times … against 2.7" would become 4.0 against 2.8.
  - Fix: filter `loc_s` on `accessible` and re-run the bootstrap, or put all stream-edge km in the denominator.
- **[severity: bug]** planning/active/link-issue-draft.md:43-44. The draft says "8,660 km of it is streams of order 2
  and above that pass the 1.5 m width…". In `ch_rule_change.csv`, 147.2 km (478 segments) of the 8,660 km in that
  reason are order 1, so order 2 and above is 8,512.8 km (98.3 %). The write-up (line 59-60) words this correctly:
  "… and 98 % is on order 2 and above". The draft text was written in aff2a28 with the round-1 prose fixes.
- **[severity: fragile]** planning/active/link-issue-draft.md:65-73. **Inside round-1 fix 2.** The configuration
  encodes the scored rule only on a `cw` group, and the draft no longer says so. The round-1 version said "on a `cw`
  group". I compiled it with fresh 0.39.0, using link 62fae0bb's `configs/default` with the draft's stream rule and
  `rear_gradient_max` 0.07:
  - Under `cw`, the rear predicate is `(stream edges AND gradient BETWEEN 0 AND 0.07 AND mad_m3s BETWEEN 0.75 AND 9999)
    OR (rivers AND gradient BETWEEN 0 AND 0.07 AND channel_width BETWEEN 0 AND 9999) OR …`. That is 0298's tuned rule
    without the exception.
  - Under `mad`, `frs_habitat_predicates()`'s `model_rules()` strips the river rule's `channel_width: [0, 9999]`, and
    the river branch takes the CSV's `rear_mad` range: `(rivers AND gradient BETWEEN 0 AND 0.07 AND mad_m3s BETWEEN 0.28
    AND 100)`. That repeats round-1 finding 1, and adds the 100 m³/s cap that the draft's own lines 52-54 warn against
    (441 of the 699 FDIS CH).
  - A rule "sized by MAD" invites moving groups to `mad`. "There is no MAD maximum, so large rivers stay in" holds only
    under `cw`.
  - Fix: say that the habitat method stays `cw`, or set CH `rear_mad_min` and `rear_mad_max` to 0 and 9999 in the
    bundle's CSV.
- **[severity: bug]** research/chinook_rearing_tuned.md:100-101. **Inside round-1 fix 11.** The sentence "3,013 of
  0295's visits … with 702 of the 978 CH (23.3 %)" attaches 23.3 % to "702 of the 978", which is 71.8 %. The 23.3 %
  is the CH rate among the 3,013 visits (702/3,013). The log's "(702 CH, 23.3 %)" is `100 * mean(rv$U)`.
- **[severity: bug]** research/README.md:18. The new index row describes the rule beside `default` as "(−20 % CH
  rearing km)". After the re-run it is −18.3 % (`ch_rule_compare.csv`, row ALL), as the write-up and draft now say. The
  round-1 refill missed this row.
- **[severity: fragile]** research/chinook_rearing_tuned.md:361-363 (selection at
  scripts/0298-ch-rule-compare.R:405, 414). The interior map group is chosen on 2 visits.
  - TWAC has 2 analysed FDIS visits on link segments, both in zone 15, so its share is 1.0.
  - The next groups are NARC (320 visits, 99.7 %, zones 14 and 15) and SETN (341 visits, 87.7 %).
  - The pick follows the pre-fixed criterion. "TWAC has all of its visits in hydrologic zones 15, 17, 23 or 24" still
    reads as if TWAC were a well-sampled interior group. State n = 2, or give the criterion a minimum n.
  - Not a round-1 item. It is in the same class: a degenerate pick presented as the best.
- **[severity: fragile]** research/chinook_rearing_tuned.md:47-48. **Inside the round-1 rewrite (fixes 6 and 8).** The
  parenthesis says 5.49 % "falls inside a region only on FWA gradients for link-placed visits and on fwapg's old MAD".
  - That holds for the 15 readings: only `link_visits_fwa_gradient` and `src_fwapg_old_mad` have a 0.0549 rule in
    their region.
  - Two outputs the page itself cites contradict it. Seed 57's recommended rule, `mad>=0.75|g<=0.0549|Q3@D2000`, is in
    its region (line 212). The 23.5 % of bootstrap resamples that recommend 5.49 % (the same parenthesis) also have it
    in their regions.
  - Fix: "in the region of only two of the 15 readings".
- **[severity: fragile]** scripts/0297-ch-rule-tune.R:23. **Inside round-1 fix 15, incomplete.** The spec header still
  says the exception target is "a segment of flow >= Q, of any kind". The walk excludes edges 1100, 1150, 1300, 1350 and
  2300 as targets (`ch_dist_profile.sql:52`). Round 1 corrected the write-up's sentence but not this one.
- **[severity: fragile]** research/chinook_rearing_tuned.md:291. The same applies to the "connectivity or overlay" rows
  at 317 and 321, and to "overlay reaches out" at 341. The page cites "link's CH user-habitat overlay (1,949 rows)",
  but 0298 applies the overlay to `rearing` only.
  - Only the 24 CH rows with `rearing = 1` take part: HORS 23, QUES 1, none in the 31 groups.
  - In this comparison the overlay changes no segment and removes no location. The "connectivity or overlay" rows are
    therefore the connectivity pass alone.
  - The text is not wrong, but the 1,949 implies an effect that does not exist here.
- **[severity: fragile]** planning/active/findings.md:114-116 and 125-127 are stale after the re-run, and the archive
  README will be built from this file.
  - The "MAD-floor rules" note describes the pre-fix design: the tuned MAD floor on the river branch, with
    `rear_mad_max` set to 9999.
  - "Results" still gives tuned −20.2 % and lifts of 2.97, 4.75 and 4.36.
- Nits:
  - research:391 says "333 m at the 90th". R's default quantile gives 332.5, which rounds to 332.
  - research:358 says "A presence-only lift always favours fewer km". Not always: dropping km that are dense in
    locations lowers lift. The three rules here only show that it tends to.

## The round-1 fixes (A)

1. **River test.** Complete in 0297 (`rule_in`:198), 0298 (`rule_sql`:132), both headers and the write-up. The draft is
   right only under `cw` (finding 3).
   - 0297's new assertion (`run_grid`:310) cannot fire, because `sb_all` already filters `!wb_river`. The evidence that
     the scores did not change is the byte-identical `ch_rule_tune.csv`, and that holds.
   - 0298's change table no longer has a lost "other" row. The 635 km of river-polygon loss is gone, as intended.
2. **Draft config.** Compiles to the tuned rule under `cw`. The `mad` hazard is finding 3.
3. **Lift.** The edge-type mismatch is fixed. The access mismatch remains (finding 1).
4. **19 %.** Correct. `rise_share` is 0.810 on a falling curve. The log relative rate is +1.10, then 0, then −4.58,
   over 238 m to 38.6 km.
   - The width's 6 % (0.065) is on a curve that rises across its whole 5-95 % range (1.23–12.75 m), so it reads
     correctly.
   - No other rise share is quoted.
5. **Fixes 5-10 and 12.** Verified against the outputs. Fix 11 is finding 4.
13. **Positive control.** Now row-wise. An NA status would error rather than pass.
14. **SUBSURFACE_FLOW.** `fresh_default.barriers` holds none, and `fresh.barriers` holds 32,180. The figures 27 + 24 =
    51 of 103 groups reproduce from `barrier_schema`.
15. **Prose and README.** The README timings fit the file times, `ch_rule_change.csv` is listed, and the panels carry n.
    "Of any kind" is still in 0297's header (finding 8).

## Checked and supported (B)

- **Populations.**
  - 21,862 visits / 1,186 CH; 19,077 / 978; 3,013 / 702 (463 of them from the 2010 Nechako survey in CHES and NECR, so
    "dominates" holds).
  - 15,178 / 264; 4,774 / 25; 4,516 / 166 / 45 WSGs; 3,434 / 166 / 26; 9,742 / 263 / 46.
  - 2,100 field-measured, 223 NULL at order 1, 96.2 %, 12,932 starts.
- **Scores.**
  - 2,795 rules; the region's shape and its 27 rules.
  - 188.2 (SE 78.7); 211.8; 105.2 (SE 53.3); 61.5 (SE 28.4); 164–209 and 185–194.
  - The MAD form: 131.0 (SE 59.5), 737 visits / 98 CH, 13.3 % / 2.5 %, and in no region.
  - 731 / 128 / 17.5 % / 1.4 % against 1,788 / 130 / 7.3 % / 2.2 %, and 41 %.
  - Every profile value, every bootstrap share, the four seeds, nested 937.7 / 1,039.8 / 1,063.5 and the fold picks.
- **Readings.**
  - The best rule is at 7 or 9 % in all 15 readings, and in all four extra seeds.
  - `default` is outside the region in all 15. No rule without the exception is in any region.
  - Width rules are in a region only in `link_visits_fwa_gradient` (2 of 89).
  - link readings: 2,826 / 131 / 16 WSGs; regions of 25 rules (7–9 %) and 89 (5.49–9 %); pick +22.5.
  - Flow sources: the table; fwapg's old MAD at 2,695 / 112 / 18 WSGs, 62 rules, 6 not converged, pick +55.8.
  - Sensitivities: the table.
- **Flips.**
  - 4,085 visits. Routed: 55 flip, 50 of them in zone 26, all in the 1–3 m³/s class.
  - Balance: 47 flip, across 11 zones, up to 3.6 %, 32 in the 0.5–1 m³/s class.
  - Zone 15: 9 of 677. Zone 17: 1 of 28. Zone 23 has no visits in the tuning population (not only in `both`). Zone 24
    has 18.
- **Curves.** edf 1.0 / 3.3 / 2.3; p = 0.46; about 11 m; 6 %; 3,523 / 72 / 2,463; the distance curve keeps steepening
  (slope −0.37 to −1.40), with no plateau.
- **Side by side.**
  - The check covers 786,317 segments with 0 differ. Stored against regenerated differ on 4,584 km: 31,948 against
    27,953, with FRAN +955 and HARR +547.
  - Rearing km 31,948 / 21,548 / 26,092, or −32.6 % and −18.3 %.
  - Per group: from −42.6 % (NARC) to +13.5 % (UFRA), median −15.0 %, 5 of 31 gain. Lake and wetland 4,208 / 7,449 km.
  - Every row and order column of the change table; 98 % and 69 %.
- **FDIS detection.**
  - 4,944 visits / 699 CH, and the table.
  - 441 / 196 reproduced: 521 visits, all on edge-1250 river-polygon segments, none in a lake or wetland. 72 / 3,099
    then follows by arithmetic.
- **Outside check.**
  - 1,344 / 1,215 records, 1964–2007, 78 undated; 812 / 326 locations.
  - 40 / 14 and 40 / 24 locations; 10.9 and 3.4 km-share points.
  - Life stage is NULL on 1,203 of the 1,215 records, so "mostly unrecorded" holds.
- **Maps.**
  - Criteria 0.854 (SALR, ahead of LSAL at 0.845), 1.0 and 0.205. LFRA is the only group above 0.
  - Per group: SALR −17.1 %, TWAC −28.0 %, LFRA −15.0 %, with their km gained and lost.
  - The description of the three images holds.
- **Limits.**
  - 0 of 156 river-polygon visits above 5.49 % caught CH.
  - 3,544 offsets reproduce: median 0.875 m, p75 89.9 m, p90 332.5 m.
  - The 2 CH ≥ 150 mm figure comes from `fdis_export.md`.
- **Draft.** Every number holds apart from lines 43-44 (finding 2) and 49-50 (finding 1). The public-repo check is
  still clean.

## Code (C)

No further defects found. The following were checked:
- **Branch encoding.** `rule_in`, `rule_sql` and the draft (under `cw`) encode the same branches:
  - stream: edges 1000, 1100, 2000 and 2300; 0 ≤ g ≤ max; size OR exception;
  - river: non-NULL width, and g;
  - wetland and lake: unchanged.
- **`default_mad`** is fresh's `mad` predicate, as the log shows.
- **Connectivity and overlay.**
  - `.frs_run_connectivity()` reads only `params_fresh`'s cluster settings and the rules' `requires_connected`, so
    nothing in it depends on the rule.
  - `frs_habitat_overlay()` sets TRUE whatever the access, but it has no CH rearing rows in these groups.
- **Exception walks.** No segment can be its own target: a walked segment fails the 0.75 floor, so its flow is below
  Q = 3. The walk returns one row per Q. `src` is validated and no column name collides with it. The UPDATE's join on
  measures is exact, as round 1 found.
- **Joins and guards.** The `pivot_wider` and `anyNA` guards, the `tot` summarise, and the `case_when` reasons are
  sound. No column shadows a local variable inside a dplyr verb: I checked `grid`, `seg`, `vis` and `cand` against the
  locals they use.
- **Run order.** 0297 and 0298 ran concurrently (outputs at 21:16 and 21:14 PDT). 0298 reads `ch_rule_tune.csv` at its
  start, and 0296's visit and walk files only after its walks and classification. I did not establish when each read
  happened, but every input came out byte-identical, so the overlap changed nothing.
