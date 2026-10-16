# Code review, round 1 (#54)

Reviewed `git diff 59e1d2b...HEAD` at 244844b: scripts/sql/ch_dist_profile.sql, 0296, 0297, 0298, the research
write-up, the link issue draft, the README and CLAUDE.md rows. Every numbered or quantified sentence in
research/chinook_rearing_tuned.md and planning/active/link-issue-draft.md was checked against data/ch_rule_*.csv, the
three logs and the derived visit and walk files. Gaps were filled with read-only probes on local fwapg, using temp
tables in my own session. Scripts are in the session scratchpad under `rv/`.

The running 0298 finished at 03:32:48 UTC (EXIT 0). `ch_rule_compare.csv` and `ch_rule_checks.csv` are byte-identical
to the pre-run copies in `scratchpad/run/cmp3/`, so every side-by-side number in the write-up still stands. The new
`ch_rule_change.csv` and the "by reason" block in the compare log are used below as evidence.

## Findings

- **[severity: bug]** scripts/0298-ch-rule-compare.R:129 (same in 0297:192/205), research/chinook_rearing_tuned.md:36,
  link-issue-draft.md:54-58: **the tuned rule puts its MAD floor on the river-polygon branch.** The code sets
  `river_size <- ... else size`, so a MAD rule's river test is `mad >= 0.75`. The documents contradict this in three
  places:
  - The write-up says "Nothing else in `default` changes: river polygons, …".
  - The 0298 header (line 23) says only that the tuned rule "changes the gradient on the stream and river branches".
  - The link draft proposes a `mad:` on the stream rule only, so the R rule would keep its non-NULL-width test.

  The scoring never tested this branch, because B2 took river polygons out of the population. The finished run
  measures what it costs. Under "other (river-polygon branch or mixed)", **635.4 km are lost (7,412 segments) and
  119.7 km gained (904 segments)**, about 516 km net, or 8 % of the −6,454 km behind "−20 %". The probes give the
  mechanism:
  - 1,247 km of accessible river-polygon lines at ≤ 7 % have pick MAD < 0.75. Of these, 880 km are edge-1450 lines
    at a median of about 0.02 m³/s, the tributary's inflow carried across the polygon. LSKE alone has 255 km.
  - The pre-cluster estimate is 636 km lost and 120 km gained, which matches the run.
  - On visits, 32 river-polygon visits (12 CH) pass `default`'s river test and fail the tuned one.

  Either keep `default`'s river test for every rule (river_size = non-NULL width, plus g), or state the change
  everywhere and in the draft.
- **[severity: bug]** planning/active/link-issue-draft.md:55: **the proposed configuration does not encode the tuned
  rule.** fresh's `.frs_rule_to_sql()` adds a rule-level `mad:` and still inherits `channel_width` unless the rule has
  `thresholds: false`. Compiled with fresh 0.39.0 from link 62fae0bb's CH rules with the draft's edits, the predicate
  reads:
  `(s.edge_type IN (1000, 1100, 2000, 2300) AND s.gradient BETWEEN 0 AND 0.07 AND s.channel_width BETWEEN 1.5 AND 9999 AND s.mad_m3s BETWEEN 0.75 AND 9999) OR (… fwa_rivers_poly … AND s.gradient BETWEEN 0 AND 0.07 AND s.channel_width BETWEEN 0 AND 9999) …`
  That is width AND MAD on streams, and width only on rivers. Neither is the rule 0297 scored or the rule 0298
  measured, yet the draft quotes 0298's numbers: 25,494 km, 34.6 %/2.1 %, 4.4×.
  - On streams the difference is "gained: size: tuned passes, width fails or NULL", 77.2 km, which this configuration
    would not gain.
  - On rivers it is the finding above.

  The rule needs `thresholds: false` with an explicit `gradient: [0, 0.07]` and `mad: [0.75, 9999]`, and an explicit
  choice for the R rule.
- **[severity: bug]** scripts/0298-ch-rule-compare.R:369-380 (`lift()`, `ks()`): **the outside-check lift divides
  across two populations.** The numerator is the share of all 812 locations on `rearing`, which includes the river,
  lake and wetland branches. The denominator is rearing km over accessible km on stream edges only.
  - My replication of the 812 locations puts 326 on stream edges and 486 elsewhere: 379 on edge 1250, 70 on 1450, and
    451 inside river polygons.
  - Pre-cluster predicates reproduce the captures: 732/609/678 against the reported 724/607/674. Off-stream
    locations make up 457 of `default`'s captures and 433 of the tuned rule's. Their km never enter the denominator,
    and the inflation grows as a rule's km share shrinks.
  - With stream-edge locations only and the same km shares, lift is about 2.8 (`default`), 4.4 (`default_mad`) and
    3.9 (tuned), against the reported 2.97, 4.75 and 4.36. Tuned minus `default` is about 1.1, not 1.39. The ranking
    holds.
  - The write-up table, the 1.39 and −0.39 differences, and the draft's "4.4 times … against 3.0" (draft:41) all
    depend on this. Restrict locations to stream edges, or use all accessible rearing km in the denominator.
- **[severity: bug]** research/chinook_rearing_tuned.md:225: "1,000 m sits 81 % of the way down from the curve's
  5th-percentile end" is inverted. `rise_share_at_threshold` = (at − lo)/(hi − lo) = 0.81 on a falling curve.
  - Recomputed on the 2,463 modelled visits, the 5–95 % range is 238 m to 38.6 km. The log relative rate is +1.10 at
    the 5th percentile, 0 at 1,000 m and −4.58 at the 95th.
  - So 1,000 m is **19 %** of the way down from the 5th-percentile end, or 81 % of the way up from the far end.
- **[severity: bug]** research/chinook_rearing_tuned.md:155-156: "Width at 1.5 m with any exception is 187–188
  above" is wrong. In `ch_rule_tune.csv` (main), width ≥ 1.5 with an exception scores 164–209 above, and the
  `width>=1.5|g<=0.07|Q1@D1000` profile row is 164.0. At `default`'s 5.49 % alone the range is 185–194. 188 is
  `default` itself, which has no exception.
- **[severity: bug]** link-issue-draft.md:12: "In an out-of-sample test both sit well outside the rules the data
  cannot tell apart." That holds for width (best width ≥ 1.5 rule: +164, SE 69), not for the gradient. 5.49 % is +49.7
  (SE 25.5), and it is what the following recommend:
  - 23.5 % of bootstrap resamples;
  - seed 57;
  - the FWA-gradient reading on link-placed visits;
  - fwapg's MAD.

  Draft line 30 itself says "The gradient is the least settled component: 5.49–9 %".
- **[severity: bug]** link-issue-draft.md:20-21: "That is 4,516 visits and 166 CH, scored in the 26 watershed groups"
  is wrong. 3,434 visits (166 CH) in 26 WSGs were scored. The 4,516 are in 45 WSGs.
- **[severity: bug]** research/chinook_rearing_tuned.md:45 ("5.49–9 % … on link's segments") and :347-348. With
  link's own segment gradient (`link_gradient`), the region's gradient is 7–9 % across 25 rules, and best =
  recommended = MAD ≥ 0.5, 9 %, Q3@1000. 5.49 % appears only with the FWA gradient on those same visits, and only as
  the fewest-departures pick: 22.5 above a best that is the same 9 % rule, in an 89-rule region. link's segmentation
  narrows the gradient. The same applies to :244 and :353. On fwapg's old MAD the best is unchanged (MAD ≥ 0.5, 9 %,
  Q3@1000). "MAD ≥ 0.5, 5.49 %, Q 50 @ 2,000 m" is the fewest-departures pick, 55.8 above it in a 62-rule region with
  6 fits not converged. As written, these sentences present tie-break picks as the inputs moving the answer.
- **[severity: bug]** research/chinook_rearing_tuned.md:317: "loses 50 of `default`'s locations" is a net figure
  (724 − 674). The pre-cluster estimate is about 71 of `default`'s locations lost and 17 gained. "10.9 points less" is
  0.3002 − 0.1905 = **11.0**.
- **[severity: bug]** research/chinook_rearing_tuned.md:319: "dated 1926–2007". 1926 comes from match types C–E,
  which the check drops. The 1,215 A/B records it uses date 1964–2007, with 78 undated. This figure is in no output.
- **[severity: bug]** research/chinook_rearing_tuned.md:93: "about 22 %" is 702/3,010 = **23.3 %** on 0295's
  population, and no output carries the figure. The rationale "where every rule is 'in'" also fails for MAD rules:
  131 river-polygon visits (34 CH) fail the recommended rule's river test.
- **[severity: bug]** research/chinook_rearing_tuned.md:50: "No width rule … reaches the region" is true for `main`
  only. `link_visits_fwa_gradient` has 2 width rules in its region, and the sentence follows "in every analysis".
- **[severity: fragile]** research/chinook_rearing_tuned.md:344 ("measured from the segment's downstream end"). That
  is true of 0298 and the draft, but 0296 walks from the visit's indexed point, and that is what was tuned. The
  offset to the link segment's downstream end has a median of 1.9 m, but 117 m at p75 and 351 m at p90. The applied
  rule is therefore slightly looser than the tuned one, and the sentence misdescribes the tuning.
- **[severity: fragile]** scripts/0296-ch-rule-build.R:136: the positive control tests
  `chk$large_lfid.x %in% chk$large_lfid.y`, which is membership in the whole column, not row-wise equality. A wrong
  target passes if its lfid appears on any other row, and an NA x passes whenever y has any NA. The ledger and
  write-up still say "identical". Use
  `coalesce(chk$large_lfid.x == chk$large_lfid.y, is.na(chk$large_lfid.x) & is.na(chk$large_lfid.y))`.
- **[severity: bug]** research/chinook_rearing_tuned.md:97-99 lists SUBSURFACE_FLOW, but `fresh_default.barriers`
  holds none (`fresh.barriers` holds 32,180). So subsurface flow is tested only in the 46 groups taken from the
  bcfishpass bundle. The effect is small: 3 visits are excluded only by subsurface flow, and 160 kept
  `fresh_default` visits sit above one, all with 0 CH. The text should say so.
- **[severity: bug]** Smaller stated numbers:
  - scripts/README.md:65 says "~6 min" for 0296. The file times give 3.5 min (frozen copy 01:57:42, ledger 02:01:11).
  - scripts/README.md:67 says "~1 h" for 0297. The two runs took about 23 and 24 min.
  - scripts/README.md:68-70 and the write-up's "Produced by" omit `data/ch_rule_change.csv`, which 0298 now writes
    and CLAUDE.md lists.
  - 0297:522: the figure title prints 4,516 visits, but the GAMs are fit on 3,433, 2,677 and 2,463.
  - research:94 and :101 call two populations "the tuning population": 15,178 and 4,516.
  - research:114: "first segment of flow ≥ Q of any kind". The walk excludes secondary-flow edges as targets, as the
    draft says correctly.

## Checked and supported

The following hold against the outputs:
- All 0297 headline and stability figures: 2,795; 27-rule region; 188.2 (SE 78.7); 131.0 (SE 59.5, 737/98); 211.8;
  bootstrap shares; seeds; nested 937.7/1,039.8/1,063.5; profiles; flow-source table; flips (4,085, 55/50, 47/11
  zones/3.6 %/32; zones 15/17/23/24).
- Sensitivities.
- Curves: edf 1.0/3.3/2.3, p = 0.46, 6 %, about 11 m, 3,523/72/2,463 (all 72 are `none`).
- Population counts: 21,862/1,186; 19,077/978; 15,178/264; 4,774/25; 4,516/166/45; 51 of 103 groups; 2,100; 223;
  12,932.
- Side-by-side figures: 31,948/21,548/25,494; −20.2/−32.6 %; 9,399/32,906; 2,945/10,994; NARC/UFRA/median −17.5 %/5
  gain; 4,584 differing and FRAN/HARR; no `fresh_default.log` rows for the 31 groups; lake and wetland 4,208/7,449;
  FDIS 4,944/699, 2,582/24.7 %, 2.6 %, 1,834/34.6 %, 2.1 %, 1,324/14.0 %/14.2 %; 441/196/72/3,099 by probe; outside
  check 1,344/1,215/812 and the lift table as computed; map criteria 0.85/1/0.21.
- No visit is above 100 m³/s (maximum 84.5).
- link: all 188 groups are on `cw`, and CH has no stream-order bypass.

In the code:
- `ch_dist_profile.sql` is correct: per-q nearest primary-flow target, terminal rows for unfound q, statuses as in
  `ch_dist_large`.
- R↔Postgres float round trips are exact (17,747/17,747 and 20,000/20,000), so the join of the barrier result on
  `downstream_route_measure` and the walk UPDATE are safe.
- No discharge pick duplicates, and no NULL-MAD stream-edge segments in the 31 groups.
- `rule_in` and `rule_sql` encode the same predicate: 3-valued SQL with a final `coalesce` equals coalescing each
  atom, because the formula is monotone. Finding 1 is about what that shared predicate does on river polygons.
- The design and test matrices in `fold_setup`/`score_one`, `sel`, `pick_of`, the bootstrap, nested selection and
  `run_grid`'s pattern dedup are sound.
- The reason classification is sound, and its "other" bucket is the river-polygon branch (finding 1).

## Public-repo check (link-issue-draft.md)

Clean. `link`, `fresh` and `wet` are public (`gh repo view`). link#331 is "Read discharge from wet in classify and the
habitat export, and re-tune BT's MAD range on it". No private repo, client, project or host is named in the filed
body. The word "client" at line 3 is in the header note above the `---`.
