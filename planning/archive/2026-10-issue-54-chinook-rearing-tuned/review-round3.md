# Code review, round 3 (#54)

Reviewed at 35cfe95 (2026-10-16, 05:05–05:27 UTC): the round-2 fixes, the four scripts, research/chinook_rearing_tuned.md,
planning/active/link-issue-draft.md, the CLAUDE.md note and data-list row, and the README rows. Every share, rate,
"x of y", "x times" and range in the write-up, the draft and the CLAUDE.md note is in the enumeration table at the
end, with the population of its numerator and its denominator. The table was built from a regex sweep of each file,
not from memory, and each row was checked against `data/ch_rule_*.csv`, the three logs and the private visit and walk
tables. The gaps were filled with read-only probes on local fwapg, using temp tables in my own session. The probe
scripts are in the session scratchpad under `r3/`. Nothing in the repository was edited except this file.

## Mechanism

Every figure on these pages comes out of a filter in code. The prose names its population with a noun the page
defines somewhere else: "the tuning visits", "the recommended rule", "visits placed on a link segment", "visits where
both sources exist", "`default`", "river-polygon lines". The filters and the nouns are two lists, and they are kept
equal by hand. They agree on the main reading, where most sentences were first written. They drift wherever a figure
comes from a sub-population: the modelled WSGs, one branch of the rule, one reading's own pick, or one edge type.

Round 1's "4,516 … scored" and round 2's "702 of the 978 (23.3 %)" were this mechanism. So were the lift's two filters,
which were edge type in round 1 and access in round 2. The code still has the same shape in two places, and the
draft's configuration in one:
- `loc_s` and `ks()` in 0298 each filter "accessible stream edge". They agree since round 2.
- 0297 and 0298 each carry their own edge lists, area filter and waterbody thresholds. They agree by inspection.
  Only 0298's `default` is checked mechanically against fresh.
- The draft's configuration puts one gradient threshold in two places (finding 4).

Where the mechanism reaches in this round:
- **Population nouns.** "Tuning" means 4,516 but is used for 3,434 (finding 2). "Visits placed on a link segment" is
  3,544 in one place and 2,826 in another, and "visits where both sources exist" is 4,085 and 3,028 (finding 6). "The
  groups the visits are in" is 103, but 97 on the stream branch (note N2).
- **Rule nouns.** "The recommended rule" means the page's rule in one place and each reading's own pick in another
  (finding 1). "`default`" is used for the whole rule where only its stream branch holds (finding 3). "River-polygon
  lines" covers three edge types where the mechanism holds for one (finding 8). And the headline rule sentence leaves
  the gradient's scope open (finding 5).
- **Quantity attachments.** "69 %" follows the 2,471 km but measures the 2,900 km (finding 7). "+955" is a net figure
  beside a gross 4,584 (note N6).
- **Scope.** The Short answer's ranges are the main reading's, but they sit beside a clause about all 15 readings
  (note N1).

What ends the loop is the table at the end. Every row has its two populations written out, and every row not marked
✓ is a finding or a note below.

## Findings

- **[severity: bug]** research/chinook_rearing_tuned.md:244 and :260. **Inside round-1 fix 8.** "The recommended rule
  is the best." The page defines "the recommended rule" at :169-171 as MAD ≥ 0.75, 7 %, Q 3 @ 1,000 m. Both
  sentences use the term for each reading's own fewest-departures pick instead.
  - **Link's segment gradient (:244).** The page's rule is outside this region. It is absent from the 25 in-region
    rows of `ch_rule_tune.csv` for `link_gradient`, and that table keeps every in-region row. MAD ≥ 0.75 appears in
    the region only at 9 % (+11.5, SE 17.4) and at 9 % with Q3@D5000. On the FWA gradient for the same 2,826 visits,
    the page's rule is outside the region too.
  - So :244, read with the page's own term, says the opposite of the output, on the reading closest to link's
    inputs. Nowhere does the page say its rule falls outside both link-placed regions. This is the caveat a link
    vignette needs.
  - **Flow table (:260).** "The recommended rule is the best rule in all three." The page's rule is in all three
    regions, but it is the best only on the balance. It is +0.3 on `pick` where both sources exist, +1.6 on routed and
    0.0 on balance.
  - Fix: say "that reading's own pick is its best rule" in both places. Add to "link's own gradient" that the page's
    rule is outside the region on both gradients for the link-placed visits, while MAD ≥ 0.75 at 9 % is inside on
    link's.
- **[severity: bug]** research/chinook_rearing_tuned.md:57-58. "On the tuning visits it admits 731 visits against
  1,788 and takes in 128 CH against 130 (raw rates 17.5 % against 7.3 %)."
  - The counts are over the 3,434 modelled visits. My replication reproduces 731/128 and 1,788/130 on them.
  - The page defines the tuning population at :18-19 as 4,516 visits in 45 WSGs. On those 4,516, the recommended
    rule admits 1,120 visits (128 CH, 11.4 %, out 1.1 %), and `default` admits 2,360 (130 CH, 5.5 %, out 1.7 %).
  - The sentence predates the reviews. Round 1's population list made it contradict the page. The Results table at
    :173 names its population correctly.
  - Fix: "On the 3,434 modelled visits".
- **[severity: bug]** research/chinook_rearing_tuned.md:91-92, :62-63 (**inside round-1 fix**) and
  scripts/0297-ch-rule-tune.R:21-22. "fwapg models width only where `stream_order > 1`, so `default` never rears CH on
  an unmeasured first-order stream", and at :63 "which `default` never rears unmeasured".
  - The first half holds. fwapg has 3 MODELLED order-1 widths province-wide.
  - The conclusion holds only for the stream branch. `default`'s wetland and lake branches carry no width test (the
    table at :78-83, and fresh's `.frs_rule_to_sql()`, which skips inheritance for L and W rules).
  - In the 31 groups, 3,911 km of accessible order-1 segments with no width pass the wetland or lake branch. The
    stored flags rear CH on about 1,430 km of them through the wetland branch, and 814 km of that is edge-1000
    single-line streams.
  - This sentence is in "What `default` does", which the page says lifts into the vignette as the rule table.
  - Fix: "`default`'s stream branch never admits an unmeasured first-order stream".
- **[severity: fragile]** research/chinook_rearing_tuned.md:37-38 and link-issue-draft.md:66-73. **Inside round-1
  fixes 1 and 2.**
  - The write-up says the river branch's "gradient maximum moves with the stream branch's, as one threshold in link's
    CSV would move both".
  - In the draft's configuration that is no longer one threshold. `thresholds: false`, which the stream rule needs to
    drop the width test, also stops it inheriting the CSV gradient. fresh's `.frs_rule_to_sql()` inherits gradient,
    width and MAD only when `thresholds` is unset or true. So the stream rule carries `gradient: [0, 0.07]` itself,
    and the river rule inherits `rear_gradient_max` from the CSV.
  - Compiled with fresh 0.39.0 from link 62fae0bb plus the draft's edits, both branches read 0.07 today, under `cw`
    and under `mad`. A later edit of `rear_gradient_max` alone would move the river branch and not the stream branch.
  - These are two lists that agree by hand, inside a proposal for a public repo. Fix: the draft states that the
    stream rule's gradient and `rear_gradient_max` move together. The write-up's sentence describes `default`'s
    structure, not the proposed one.
- **[severity: fragile]** research/chinook_rearing_tuned.md:44 and :171, link-issue-draft.md:30-31, and
  research/README.md:18. The rule is stated as "MAD ≥ 0.75 m³/s, gradient ≤ 7 %, or a ≥ 3 m³/s river within 1,000 m
  downstream".
  - The scored and applied rule is: stream edge AND gradient ≤ 7 % AND (MAD ≥ 0.75 OR the exception). See
    `rule_in` at 0297:210 and `rule_sql` at 0298:136.
  - "A, B, or C" reads either as three alternatives or as "(A and B) or C". Under both readings the exception escapes
    the gradient maximum.
  - The draft's configuration is explicit: "a second stream rule with the same edges and gradient". But the headline
    sentence is what a vignette or a link maintainer lifts.
  - Fix: "gradient ≤ 7 %, and MAD ≥ 0.75 m³/s or a ≥ 3 m³/s river within 1,000 m downstream".
- **[severity: bug]** research/chinook_rearing_tuned.md:242 and :252. Each sentence names a sub-population as the
  whole.
  - :242 says "On the 2,826 visits placed on a link segment (131 CH, 16 WSGs)", while :398 says "the 3,544 tuning
    visits placed on a link segment". The 2,826 are the modelled subset (16 WSGs with both outcomes) of the 3,544.
  - :252 says "Visits where both wet sources exist (3,028 visits, 163 CH)", while :265 says "the 4,085
    tuning-population visits where both sources exist". The 3,028 are the modelled subset.
  - The figures are right. The nouns give one population two sizes. Fix: add "in the WSGs with both outcomes".
- **[severity: bug]** research/chinook_rearing_tuned.md:62. **Inside round-1 fix.** "2,900 km are gained. 2,471 km of
  that comes through the exception, and 69 % is on order-1 streams."
  - The 69 % is 1,990.5 of the 2,900.4 km gained, over all reasons. Of the 2,471 km through the exception, order 1 is
    1,905.8 km, or 77.1 %.
  - In the parallel loss bullet, "98 %" holds for both readings: 98.0 % of 8,756 and 98.3 % of 8,660. This one holds
    only for the total, and the sentence sets it after the 2,471.
  - Fix: "and 69 % of the gain is on order-1 streams".
- **[severity: bug]** CLAUDE.md:218-219. **Inside round-2 fix.** "River-polygon lines (edges 1450, 1250, 1350) carry a
  tributary's own small wet flow. A MAD floor on the river branch drops 636 km of them."
  - FWA's codes: 1250 is a double-line river's own main-flow line, 1350 its secondary flow, and 1450 a connection.
  - I took the 31 groups, accessible river-polygon segments at ≤ 7 % with a width and `pick` MAD < 0.75, before the
    connectivity pass. That gives 625 km: 1450 is 363 km (median 0.058 m³/s), 1250 is 144 km (median 0.36) and 1350
    is 118 km.
  - The tributary mechanism fits the 1450 connectors: 315 of their 363 km lie in polygons whose own main line carries
    ≥ 10 m³/s.
  - It does not fit the 1250 lines. 119 of their 144 km lie in polygons whose own main line carries < 0.75 m³/s.
    Those are small double-line rivers carrying their own small flow.
  - The 636 km is the figure for a 0.75 m³/s floor at 7 %, and the note does not name the floor.
  - This is a durable working note, so the mechanism it states should be the one measured. Fix: "connection lines
    (1450) carry a tributary's own small flow across a large river's polygon, and small double-line rivers (1250,
    1350) carry their own. A 0.75 m³/s floor on the river branch drops 636 km of them."

### Notes (wording, no figure is wrong)

- **N1.** research:43-51. "Ranges the data cannot tell apart" are the main reading's region. They sit in the same
  bullet as "the best rule's 7 or 9 % in all 15 readings". Across readings the regions reach a MAD floor of 0.1 m³/s,
  and D of 250 m in 5 readings and 5,000 m in 3. `link_gradient` has MAD 0.15–1 and D 250–5,000. The Limits say
  "main-reading" at :401, and the Short answer could say it too.
- **N2.** research:393. "Barrier status is known in 51 of 103 groups." That is over the groups of 0296's 21,862
  visits; for 0295's population it is 51 of 102. For the stream-branch visits that the barrier filter actually acts
  on, it is 48 of 97 (27 from `fresh_default`, 21 from `fresh`).
- **N3.** research:371. **Inside round-2 fix.** "The best-sampled interior group is NARC: 320 visits." SETN has 341
  visits, 87.7 % of them in those zones. This holds if "interior" means 90 % or more, so the sentence could state it.
- **N4.** research:330. "Streams modelled at least 1.5 m wide." About 13 % of the km that fail the 0.75 floor with a
  width of 1.5 m or more carry a field-measured width (a superset estimate that includes segments the exception
  rescues). The text could say "at least 1.5 m wide".
- **N5.** research:262. "6 fits did not converge" means 6 distinct in/out patterns, each with at least one fold or
  intercept fit that did not converge.
- **N6.** research:300-301. "FRAN (+955 km) and HARR (+547 km) differ most" gives net figures, regenerated minus
  stored, beside the gross 4,584 km. FRAN's gross difference is 1,017.9 km. FRAN and HARR are the top two both ways.
- **N7.** CLAUDE.md:41. "Every rule's held-out score" holds for the main reading only (2,795 rows). The other 14
  readings keep only the region, `default`, best, pick and recommended rows.

## Round-2 fixes, checked

- **`loc_s` and its log line** (0298:375-379). `loc_s` filters on stream edge and `accessible`, and `ks()` divides
  stream-edge rearing km by accessible stream-edge km. The two populations match.
  - The log line prints `nrow(loc)` = 812, `sum(loc$edge_type %in% edge_stream)` = 326 and `nrow(loc_s)` = 315, which
    are the logged values.
  - A replication of the location pipeline gives 1,058 deduplicated locations, then 812 once spawn-only locations are
    out. All 812 are placed, so the write-up's "812 locations once deduplicated…, with spawn-only locations out"
    omits no placement loss.
  - The 0298 header (lines 35-39) records both revisions.
- **Outside-check table and its two bullets** (research:350-362). Every cell matches `ch_rule_checks.csv`:
  - 267/315 = 84.8 %; 225/315 = 71.4 %; 241/315 = 76.5 %;
  - km shares 30.0 / 15.7 / 19.1 %; lifts and CIs;
  - 724 / 607 / 698 of 812;
  - +1.17 (0.94–1.37) with 40 lost and 14 gained;
  - −0.54 (CI −0.87 to −0.30, written as "lower by 0.54 (0.30–0.87)") with 40 and 24;
  - 10.9 and 3.4 points.
- **The draft's `cw` paragraph** (draft:74-76). Compiled with fresh 0.39.0 from link 62fae0bb's configs/default plus
  the draft's edits:
  - Under `cw`, the stream branch is `gradient 0–0.07 AND mad_m3s 0.75–9999`, and the river branch is `gradient 0–0.07
    AND channel_width 0–9999`. That is 0298's tuned rule without the exception.
  - Under `mad`, with `rear_mad_min` 0 and `rear_mad_max` 9999, the river branch is `gradient 0–0.07 AND mad_m3s
    0–9999`, so large rivers stay in, as the paragraph says. The stream branch is unchanged.
  - The paragraph is right. Finding 4 is about the same configuration's gradient.
- **Maps paragraph** (research:367-384). SALR's 0.85, TWAC's 2 visits, NARC's 320 visits, 99.7 % and −42.6 %, and
  LFRA's 0.21 all hold, as do the per-group −17.1 / −28.0 / −15.0 % with km gained and lost. Note N3 applies.
- **Other round-2 items.**
  - 702/3,013 = 23.3 % with 702 of the 978.
  - The draft's "98 % of the loss".
  - The README's −18 %.
  - "In the region of only two of the 15 readings".
  - 0297's header no longer says "of any kind".
  - The overlay's 24 rearing rows replace the 1,949.
  - findings.md now gives −18.3 % and the 315-location lifts.

  All hold.

## Rule encodings, branch by branch

| branch | 0297 `rule_in` | 0298 `rule_sql` | 0298 reasons | draft config (fresh 0.39.0, `cw`) | write-up |
|---|---|---|---|---|---|
| stream edges | 1000/1100/2000/2300 | same | `edge_stream` | `edge_types_explicit` same | same (:80) |
| gradient | 0 ≤ g ≤ max (FWA; link's in that reading) | `BETWEEN 0 AND max` (link segment) | `g_def`, `g_tun` | stream: `gradient: [0, 0.07]` explicit; river: CSV `rear_gradient_max` 0.07 (finding 4) | ≤ 7 % |
| size | width in [w, 9999], or MAD ≥ m | same | `w_ok`, `size_tun` | `mad: [0.75, 9999]`, `thresholds: false` | MAD ≥ 0.75 |
| exception | walk from the visit point; dist ≤ D; Inf if not found | walk from the segment's downstream end; `coalesce(exc_dist <= D, FALSE)` | `ex_ok` | second stream rule, same edges and gradient (new shape) | gradient scope unstated (finding 5) |
| river | `wb_river` & g & width in [0, 9999] | river polygon & g & width in [0, 9999] | "other" | `channel_width: [0, 9999]`; under `mad`, `mad_m3s` 0–9999 | any non-NULL width (:81) |
| wetland | edges 1000/1100/1050/1150 & ≥ 1 ha | same | rule-independent | unchanged (two W rules) | same (:82) |
| lake | lake edges & lake or man-made ≥ 100 ha | same | rule-independent | unchanged | same (:83) |
| NULLs | each atom coalesced to FALSE | the whole OR coalesced | each part coalesced | `BETWEEN` NULL is not admitted | "a NULL width fails" |

**Agreement.** The encodings agree on every branch. The walk origin and the gradient source differ, and both
differences are stated tradeoffs. A whole-OR coalesce equals coalescing each atom, because the formula is monotone
(round 1). 0298's `default` equals fresh's predicate on 786,317 segments. The draft's configuration compiles to 0298's
tuned rule without the exception. fresh's own `lake_rear` reads lakes only, which matches 0298's `lake_rearing`
(t = 'L').

`.frs_run_connectivity()` in fresh 0.39.0 reads only `params[[sp]]$rules` (`requires_connected`) and `params_fresh`'s
cluster settings. So passing `default`'s params for all three rules is sound. The finding is about the prose and the
configuration's layout, not about any encoding disagreeing.

## Code (item 4)

No defects found. I checked the following:
- **0297, scoring.**
  - `fold_setup()` keeps the reference level out through `intersect()`, because `~ 0 + …` fully codes the first
    factor.
  - `score_one()` refits only the held-out intercepts.
  - The `packBits` keys do not collide.
  - `sel()`, `pick_of()`, the bootstrap, nested selection and the extra seeds are as described.
- **0297, NA paths.** `present_CH`, `catch_status`, `fwa_gradient`, `mad_pick` and `edge_type` have no NAs, so
  `d[d$F == 1L, ]` and `U` are safe.
- **0298, joins and checks.**
  - The walk starts, the UPDATE on measures (both `double precision`) and the per-group scratch tables are sound.
  - So are the overlay call, the `pivot_wider` and `anyNA` guards, `tot`, the reasons, `det`, the placement's
    `DISTINCT ON` order, the bootstrap, and the map criteria.
- **0296.** The row-wise positive control and the `cw_deploy` logic are sound.
- **What stays by hand.** The edge lists and filters in 0297 and 0298 agree by inspection, and the mechanism note
  above names them.

## Enumeration table

Legend: ✓ = the wording names the populations the outputs use; F*n* = finding *n*; N*n* = note *n*. "Modelled" means
the WSGs with both outcomes. Line numbers are the current files'.

### research/chinook_rearing_tuned.md

| # | line | statement | numerator | denominator | verdict |
|---|---|---|---|---|---|
| 1 | 18-20 | 4,516 visits (166 CH) in 45 WSGs; 26 WSGs: 3,434 visits, 166 CH | CH in the tuning population; CH in the modelled subset | stream-branch visits with no natural barrier downstream; modelled subset | ✓ |
| 2 | 21-22 | 15,178 (264 CH); 9,742 (263 CH) in 46 WSGs | CH among stream-branch visits; modelled subset | stream-branch visits; modelled | ✓ |
| 3 | 23-24 | 31 WSGs: 53,653 km of accessible stream edges | km of accessible edge 1000/1100/2000/2300 segments (`accessible_stream_km`, ALL) | — | ✓ |
| 4 | 46 | MAD floor 0.28–1 m³/s | MAD floors of the 27 region rules | main reading | ✓ (N1) |
| 5 | 46 | 0.5–0.75 in 86 % of bootstrap resamples | 172 resamples recommending 0.5 or 0.75 | 200 resamples | ✓ |
| 6 | 47 | gradient 7–9 % | gradients of the region rules | main reading | ✓ (N1) |
| 7 | 47 | the best rule's 7 or 9 % in all 15 readings | readings whose best is at 7 or 9 % (15) | 15 readings | ✓ |
| 8 | 47 | 5.49 % recommended in 23.5 % of resamples | 47 resamples | 200 | ✓ |
| 9 | 48 | on one of four extra fold seeds | seed 57 | seeds 55-58 | ✓ |
| 10 | 48-49 | in the region of only two of the 15 readings | `link_visits_fwa_gradient`, `src_fwapg_old_mad` | 15 readings | ✓ |
| 11 | 50 | Q 1–10 m³/s, mostly 3 | region Q values (13 of 27 at 3; 77.5 % of resamples) | main region | ✓ (N1) |
| 12 | 51 | D 1–2 km | region D | main region | ✓ main only (N1) |
| 13 | 53-54 | `default` outside in all 15; 188 (SE 79) | — | 15 readings; main | ✓ |
| 14 | 54 | MAD form 131 (SE 59) | — | main; outside in all 15 (no no-exception rule is in any region) | ✓ |
| 15 | 55 | no rule without the exception in any region | in-region rows with no exception (0) | 15 readings | ✓ |
| 16 | 55-56 | 2 width rules among the 89 | width rules in the region | `link_visits_fwa_gradient` region | ✓ |
| 17 | 57-58 | "On the tuning visits" 731 vs 1,788; 128 vs 130; 17.5 % vs 7.3 % | visits and CH in each rule | **3,434 modelled**; the wording names the 4,516 | **F2** |
| 18 | 59 | 31,948 → 26,092 km (−18 %) | tuned minus `default` rearing km | `default` km, same segments, 31 groups | ✓ (−18.3 %) |
| 19 | 60-61 | 8,660 km of the 8,756 lost | lost km for "width passes, tuned fails, no exception" | all lost km | ✓ (no NULL-MAD stream edges) |
| 20 | 61 | 98 % on order 2 and above | order ≥ 2 lost km | 8,756 (98.0 %) or 8,660 (98.3 %) | ✓ either way |
| 21 | 62 | 2,471 km of the 2,900 gained through the exception | exception-gained km | all gained km | ✓ |
| 22 | 62 | 69 % on order-1 | 1,990.5 km of order-1 gains | **2,900.4 (all gains)**; read after the 2,471, it would be 77.1 % | **F7** |
| 23 | 62-63 | `default` never rears unmeasured (order 1) | — | true of the stream branch only | **F3** |
| 24 | 67-68 | floor 0.5 or 0.75 by flow model | best rule per flow reading | 4 flow readings | ✓ |
| 25 | 70 | river branch takes 0.28–100 under `mad` | fresh's `mad` predicate (log) | — | ✓ |
| 26 | 70-71 | 441 of the 699 on > 100 m³/s, outside rearing | CH visits on accessible segments over 100 m³/s (all on edge-1250 river polygons) | CH visits on accessible link segments | ✓ |
| 27 | 80-83 | `default`'s branch table | — | — | ✓ (0 of 786,317 differ) except :91-92 (F3) |
| 28 | 88 | 10 km, bridging up to 5 % | `params_fresh` 10000, 0.05 | — | ✓ |
| 29 | 91-92 | width only where order > 1, so `default` never rears unmeasured order 1 | — | 1,430 km of stored CH rearing on order-1, no-width segments through the wetland branch | **F3** |
| 30 | 92-93 | MAD bounds never act; all 188 groups on width | — | link's 188 groups | ✓ (round 1) |
| 31 | 98 | 21,862 visits, 1,186 CH | CH | 0294's visits | ✓ |
| 32 | 98-99 | 19,077 visits, 978 CH | CH | 0295's population | ✓ |
| 33 | 101-102 | 3,013 visits; 702 of the 978 CH; rate 23.3 % | 702 CH on river polygons | 978 (CH in the population) and 3,013 (river-polygon visits) | ✓ |
| 34 | 103-104 | one Nechako survey dominates | 464 CH in CHES/NECR (463 from the 2010 survey) | 702 | ✓ |
| 35 | 105 | 15,178 visits, 264 CH | — | stream branch | ✓ |
| 36 | 107 | GRADIENT ≥ 15 % | CH `access_gradient_max` 0.15 | — | ✓ |
| 37 | 108-109 | 27 + 24 = 51 of the 103 groups | groups by barrier schema | groups of 0296's 21,862 visits | ✓ (N2) |
| 38 | 111-112 | 4,774 with a barrier, CH on 25 | — | stream-branch visits with a known status (9,290) | ✓ |
| 39 | 113 | tuning population = the 4,516 with none | 9,290 − 4,774 | — | ✓ |
| 40 | 119 | 2,100 of the 4,516 field-measured | FIELD_MEASURMENT widths | tuning population | ✓ |
| 41 | 121-122 | within 5 % on 96.2 % of segments | segments within 5 % | 3,645 distinct MODELLED segments at 0296 visits | ✓ |
| 42 | 122 | NULL at order 1: 223 of the population | field-measured order-1 visits | tuning population | ✓ |
| 43 | 124 | all 12,932 starts | — | 0294's walk starts | ✓ |
| 44 | 130-134 | 2,795 rules and the grid values | 65 size × gradient × 43 exception options | — | ✓ |
| 45 | 153 | 188.2 (SE 78.7); all-in 211.8 | — | main | ✓ |
| 46 | 155-162 | 27 rules; the region table | — | main region | ✓ |
| 47 | 164 | 105.2 (SE 53.3) | — | best no-exception rule, main | ✓ |
| 48 | 166 | 61.5 (SE 28.4) | — | best width rule, main | ✓ |
| 49 | 167 | 164–209 (185–194 at 5.49 %) | width ≥ 1.5 rules with an exception: 164.0–208.9 (184.5–193.7) | main | ✓ |
| 50 | 169 | every region rule departs in all three | departures = 3 for all 27 | main region | ✓ |
| 51 | 173-178 | rules on the 3,434 modelled: 1,788 / 130 / 7.3 / 2.2; 731 / 128 / 17.5 / 1.4 | CH in, visits in | 3,434 modelled | ✓ |
| 52 | 181 | on 41 % as many visits | 731 | 1,788 | ✓ (40.9 %) |
| 53 | 184-185 | 131.0 (SE 59.5) | — | main | ✓ |
| 54 | 185-186 | no tuning visit above 100 m³/s | max `pick` 84.5 | tuning population | ✓ |
| 55 | 186-187 | 737 visits, 98 CH (13.3 %; 2.5 % outside) | CH | 737 in; 2,697 out, of the 3,434 | ✓ |
| 56 | 195-201 | profile values (+2.8 … +174.7; +2.7, +49.7 (25.5), +111.7; Q +13.0 … +52; D +5.4 … +51.5) | best ddev per value | main | ✓ |
| 57 | 206-209 | bootstrap shares: 99.5 / 57.5 / 28.5 / 7.0; 44.5 / 32.0 / 23.5; 77.5 / 10.5 / 8.0; 57.5 / 40.0 | resamples per value | 200 | ✓ |
| 58 | 211-214 | two seeds the same, one at 0.5/9 %/2 km, one at 0.75/5.49 %/2 km | — | seeds 55-58 | ✓ |
| 59 | 215-216 | 937.7 vs 1,039.8 vs 1,063.5; fold picks MAD 0.5–0.75, Q 3 | — | 5 folds | ✓ |
| 60 | 218-219 | gradient 5.49–9 %; floor 0.5–0.75; Q 3 within 1–2 km | bootstrap | 200 resamples | ✓ |
| 61 | 226-228 | edf 1.0, no bend 0.01–50 m³/s; 0.5–0.75 | GAM on 3,433 | — | ✓ |
| 62 | 229-230 | edf 3.3; about 11 m; 6 % of the rise over the 5–95 % range | 0.065; 10.76 m | GAM on 2,677 | ✓ |
| 63 | 231 | p = 0.46 | — | m1 | ✓ |
| 64 | 231-232 | about 50 deviance (SE 26) | 49.7 (25.5) | main profile | ✓ |
| 65 | 233-235 | 3,523 fail; 72 have no target before the sea; 2,463 modelled | visits | 4,516; all 72 are `none` | ✓ |
| 66 | 234-235 | edf 2.3; steeper beyond 1–2 km | — | m3 | ✓ |
| 67 | 236-237 | 19 % of the way down; rise share 0.81 | 1 − 0.810 | 5-95 % of distance | ✓ |
| 68 | 242 | "the 2,826 visits placed on a link segment (131 CH, 16 WSGs)" | — | **modelled subset of the 3,544** placed tuning visits | **F6** |
| 69 | 243 | best rule MAD ≥ 0.5, 9 %, Q3@1000 with either gradient | — | `link_gradient`, `link_visits_fwa_gradient` | ✓ |
| 70 | 244 | 25 rules, all at 7–9 %; "The recommended rule is the best." | — | the page's rule is **outside** this region | **F1** |
| 71 | 245-246 | 89 rules, 5.49–9 %, 2 width rules; pick +22.5 | — | `link_visits_fwa_gradient` | ✓ |
| 72 | 248 | gradient settles at 7–9 %; `default` out on both | — | the two link readings | ✓ |
| 73 | 252 | "Visits where both wet sources exist (3,028, 163 CH)" | — | **modelled subset of the 4,085** | **F6** |
| 74 | 256-258 | 200.6 (73.7), 204.3, 191.5 | `default` ddev | each flow reading | ✓ |
| 75 | 260 | "The recommended rule is the best rule in all three." | each reading's pick = its best ✓; the page's rule +0.3 / +1.6 / 0.0 | three flow readings | **F1** |
| 76 | 260-261 | 2,695 visits, 112 CH, 18 WSGs; best = MAD ≥ 0.5, 9 %, Q3@1000, the same as `pick` | — | `src_fwapg_old_mad`, modelled | ✓ |
| 77 | 262 | 62 rules, 5.49–9 %; "6 fits did not converge" | 6 in/out patterns | — | ✓ (N5) |
| 78 | 263 | pick Q50@2000, +55.8 | — | `src_fwapg_old_mad` | ✓ |
| 79 | 265 | 4,085 tuning-population visits with both sources | — | tuning population | ✓ |
| 80 | 267 | 55 flip, 50 in zone 26, all 1–3 m³/s | flips | 4,085 | ✓ |
| 81 | 268 | 47 flip, 11 zones, up to 3.6 %, 32 in 0.5–1 | flips per zone | zone's visits within the 4,085 | ✓ |
| 82 | 271-272 | 9 of 677 (zone 15), 1 of 28 (zone 17); zone 23 none; zone 24 18 | balance flips | zone visits; zone 23 is 0 and zone 24 is 18 in the whole 4,516 as well | ✓ |
| 83 | 280-286 | sensitivity table | modelled visits (CH) | each sensitivity | ✓ |
| 84 | 294 | 24 CH rearing rows, in HORS and QUES | — | link's overlay | ✓ |
| 85 | 299 | 786,317 segments | 0 differ | 31 groups' segments | ✓ |
| 86 | 300 | differ on 4,584 km; 31,948 vs 27,953 | gross symmetric difference; the two totals | 31 groups | ✓ |
| 87 | 301 | FRAN +955 km, HARR +547 km | **net** regenerated − stored | — | ✓ (N6) |
| 88 | 307-308 | 31,948 / 21,548 / 26,092; −32.6 / −18.3 % | rule km minus `default` km | `default` km, same segments | ✓ |
| 89 | 310-311 | −42.6 % (NARC) to +13.5 % (UFRA), median −15.0 %, 5 of 31 gain | per-group change | per-group `default` km; 31 groups | ✓ |
| 90 | 311-312 | lake 4,208 and wetland 7,449 km, the same in every group | — | 31 groups | ✓ |
| 91 | 318-328 | change table rows and order columns | — | 31 groups | ✓ (sums check) |
| 92 | 330 | 98 % on order 2 and above; "modelled at least 1.5 m wide" | order ≥ 2 lost km | lost km | ✓ (N4) |
| 93 | 331 | gains mostly the exception's | 2,471 | 2,900 (85 %) | ✓ |
| 94 | 333 | 4,944 analysed visits on accessible link segments (699 CH) | — | 0295-filtered visits on accessible link segments in 31 groups | ✓ |
| 95 | 335-339 | 24.7 / 2.6; 14.0 / 14.2; 34.6 / 1.8 % | CH visits | visits on rearing; visits on accessible non-rearing | ✓ |
| 96 | 341-342 | 441 of 699; 196 in NECR; about 2.3 %, 72 CH among 3,099 | 513 − 441 = 72 | 3,620 − 521 = 3,099 | ✓ |
| 97 | 345 | 1,344 records; 1,215 A/B; 1964–2007; 78 undated | dates of the A/B records | — | ✓ |
| 98 | 346-347 | 812 locations after dedup and spawn-only out | 1,058 → 812, all placed | — | ✓ |
| 99 | 348 | 326 on stream edges, 315 accessible | — | 812 | ✓ |
| 100 | 350-351 | lift: share of the 315 on rearing over the share of accessible stream-edge km that rears | `loc_s` | `ks()`; both accessible stream edge | ✓ |
| 101 | 353-357 | 267 / 225 / 241 of 315 (84.8 / 71.4 / 76.5 %); km 30.0 / 15.7 / 19.1 %; lifts and CIs; 724 / 607 / 698 of 812 | locations on rearing | 315; accessible stream-edge km; 812 | ✓ |
| 102 | 359-360 | +1.17 (0.94–1.37); 40 lost and 14 gained; 10.9 points | — | the 315 | ✓ |
| 103 | 361-362 | −0.54 (0.30–0.87); 40 and 24; 3.4 points | — | the 315 | ✓ |
| 104 | 369 | SALR 0.85 | accessible stream km on order ≤ 2 | accessible stream km | ✓ |
| 105 | 370 | TWAC all visits interior, 2 visits | — | analysed visits on link segments | ✓ |
| 106 | 371 | NARC 320 visits, 99.7 %, −42.6 % | — | the same | ✓ (N3) |
| 107 | 372 | LFRA 0.21 | visits whose 10 m³/s walk is `none` | the group's analysed visits | ✓ |
| 108 | 379-381 | SALR −17.1 % (101 gained, 295 lost); TWAC −28.0 % (13, 81); LFRA −15.0 % (208, 449) | — | per group | ✓ |
| 109 | 388 | 2 CH ≥ 150 mm | — | whole export (`fdis_export.md`) | ✓ |
| 110 | 391-392 | 1.4 % vs 2.2 % of the visits left out | CH | visits out, of the 3,434 | ✓ |
| 111 | 393 | 26 WSGs with both outcomes and 166 CH | — | modelled | ✓ |
| 112 | 393 | barrier known in 51 of 103 groups | — | 0296 visits' groups | ✓ (N2) |
| 113 | 393-394 | all-stream-branch sensitivity (46 WSGs, 263 CH) agrees | — | modelled | ✓ |
| 114 | 398-399 | 3,544; median 0.9 m, p75 90 m, p90 332 m | offsets | tuning visits placed on a link segment | ✓ |
| 115 | 401 | no main-reading region rule under 200 m | — | main (and no reading has one under 250 m) | ✓ |
| 116 | 404 | 7–9 %; 5.49–9 % | — | the two link readings | ✓ |
| 117 | 405 | 0 of 156 above 5.49 % caught CH | CH | river-polygon visits above 5.49 % | ✓ |
| 118 | 409 | best rule unchanged on fwapg's MAD | — | `src_fwapg_old_mad` against `pick` on the same visits | ✓ |
| 119 | 425 | 18 % narrower | km | `default` km | ✓ |

### planning/active/link-issue-draft.md

| # | line | statement | numerator | denominator | verdict |
|---|---|---|---|---|---|
| D1 | 10-13 | that floor, and its MAD form, score well outside | +188 (SE 79), +131 (SE 59) | main | ✓ |
| D2 | 17-18 | 1.5–9999 width, 0–0.0549 gradient; MAD bounds 0.28–100 never act, every group on `cw` | — | link's configs/default | ✓ |
| D3 | 21-22 | 4,516 / 166 / 45; scored in the 26: 3,434 / 166 | — | tuning population; modelled | ✓ |
| D4 | 24-28 | MAD 0.1–1 or width 1–4 m; gradient 3–9 %; Q 1–50; D 100–5,000 | — | the grid | ✓ |
| D5 | 29-31 | every rule within one SE: exception, MAD 0.28–1, gradient 7–9 %, Q 1–10, D 1–2 km | — | main (the scoring just described) | ✓; the rule statement is F5 |
| D6 | 32 | 86 % floor at 0.5–0.75; 78 % Q at 3 | 172 and 155 resamples | 200 | ✓ |
| D7 | 33-34 | 5.49 % in 23.5 %; best rule at 7 or 9 % in every reading, including link's gradient | — | 200; 15 readings | ✓ |
| D8 | 35-36 | 188 (79); 131 (59); no no-exception rule in any reading's region | — | main; 15 readings | ✓ |
| D9 | 42 | 31,948 → 26,092 km (−18 %) | — | 31 groups | ✓ |
| D10 | 43-44 | 8,756; 8,660; 98 % of the loss on order 2+ | 8,581.7 km | 8,756 | ✓ |
| D11 | 45-46 | 2,900; 2,471 through the exception, mostly order 1, which `default` leaves out for want of a width | 1,905.8 km order 1 (77 %); 95 % of order-1 candidate km have no width | 2,471 | ✓ |
| D12 | 47-48 | 34.6 vs 24.7 %; 1.8 vs 2.6 % | CH visits | rearing; accessible non-rearing | ✓ |
| D13 | 49-50 | 315 locations; 4.0 times the km share, against 2.8 | location share over km share | accessible stream edges | ✓ |
| D14 | 52-54 | most FDIS CH detections on rivers over 100 m³/s | 441 | 699 (63 %) | ✓ |
| D15 | 66-77 | the configuration | compiled with fresh 0.39.0 under `cw` and `mad` | — | ✓ (F4 on its gradient layout) |
| D16 | 75 | the CSV's MAD range 0.28–100 | — | link CSV | ✓ |

### CLAUDE.md (data-list row and the new note)

| # | line | statement | numerator | denominator | verdict |
|---|---|---|---|---|---|
| C1 | 41-43 | "every rule's held-out score" | 2,795 rows | main reading only | ✓ (N7) |
| C2 | 207-209 | three stages; clusters with no spawning within 10 km | — | — | ✓ |
| C3 | 211 | no `fresh_default.log` rows for the 31 groups; differs on 4,584 km | gross | 31 groups | ✓ |
| C4 | 215-216 | width only where order > 1; an order-1 stream has a width only where measured | 3 MODELLED and 291 FWA_RIVERS_POLY order-1 rows province-wide | — | ✓ |
| C5 | 218-219 | edges 1450, 1250, 1350 carry a tributary's own flow; a MAD floor drops 636 km of them | 1450: 363 km (315 in large-river polygons); 1250: 144 km (119 in small-river polygons); 1350: 118 km | 625 km pre-connect; 636 at 0.75 m³/s, 7 % | **F8** |
