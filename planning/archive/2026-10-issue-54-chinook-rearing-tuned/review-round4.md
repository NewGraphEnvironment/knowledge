# Code review, round 4 (#54)

Reviewed at 6ef8648 (2026-10-16, 05:36–05:55 UTC). Scope: every line the round-3 fix commit added or changed
(`diff_round3_fixes.patch`, 252 lines). That covers research/chinook_rearing_tuned.md, planning/active/link-issue-draft.md,
CLAUDE.md, research/README.md, research/chinook_stream_size.md and the 0297 header. Unchanged sentences in the
same files were read only to check for contradictions with the fixes.

Every number, ratio, range and quantifier on a changed line is in the table at the end. Each row gives the
populations of its numerator and denominator, and each number was rebuilt from the outputs:
- `data/ch_rule_tune.csv`, `ch_rule_change.csv` and `ch_rule_compare.csv`, and the tune log;
- the private visit table, replicating 0297's `base` / `sb_all` / `v` / `lk` / `both` / `old` filters and
  `modelled()`, and 0298's `vis`;
- read-only SELECTs on local fwapg (`fresh_default`, `discharge`, `whse_basemapping`). No temp tables were made.

The probe scripts are in the session scratchpad under `r4/`. Nothing in the repository was edited except this file.

## Findings

- **R4-1 [severity: bug]** research/chinook_rearing_tuned.md:62-63 and planning/active/link-issue-draft.md:34. **Inside
  round 3's F1 fix.** The write-up says the recommended rule "is outside both readings on the 16 link-placed groups,
  where MAD ≥ 0.75 is in the region only at 9 %". The draft says "The 0.75 floor drops out on the 16 groups placed
  on link's segments, where MAD ≥ 0.75 stays in only at 9 %".
  - **"only at 9 %" holds for one of the two readings.**
    - On `link_gradient`, the two MAD ≥ 0.75 rules in the region are both at 9 %: Q3@D1000, +11.5 (SE 17.4), and
      Q3@D5000, +38.5 (SE 39.4).
    - On `link_visits_fwa_gradient` (the same 2,826 visits, on FWA gradients), MAD ≥ 0.75 is in the region at 5.49 %
      (Q3@D1000, +32.4, SE 37.3; Q3@D5000, +60.5, SE 61.9) and at 7 % (Q3@D2000, +36.3, SE 37.7). It is never in at
      9 %.
    - Both readings keep every in-region row, so this is the complete list.
    - The page's own unchanged line :50-51 says 5.49 % is in the region of that reading.
  - **"The 0.75 floor drops out" (draft) is false on both readings.** The floor stays in the region on each, at
    9 % on link's gradient and at 5.49 % and 7 % on the FWA gradient. What drops out of both regions is the
    recommended rule itself (0.75, 7 %, Q3@D1000), so the bullet also contradicts its own second clause.
  - **"the 16 link-placed groups" / "the 16 groups placed on link's segments" is round 3's F6 mechanism again.** The
    3,544 placed tuning visits are in 25 WSGs. 16 is the number the models use (both outcomes, 2,826 visits), as
    :250 says.
  - **Origin.** Round 3's suggested wording scoped "MAD ≥ 0.75 at 9 %" to link's gradient. The fix widened it to
    both readings. The bullet at :252-253, which keeps it to link's gradient, is right.
  - **Fix.** Write: "It is outside both regions for the link-placed visits (the 16 WSGs with both outcomes). On
    link's segment gradient MAD ≥ 0.75 is in the region only at 9 %; on the FWA gradient only at 5.49 % and 7 %."
    In the draft, make the subject the rule, not the floor: "The recommended rule falls outside the region for the
    visits placed on link's segments (16 groups modelled). On link's own segment gradient, MAD ≥ 0.75 stays in only
    at 9 %."
- **R4-2 [severity: fragile]** research/chinook_rearing_tuned.md:287-289. **Round 3's F1 is not fully resolved.** Its
  finding was that "the recommended rule" names the page's rule in one place and each reading's own pick in
  another. The fix corrected the two places round 3 cited (:252, :264). The sensitivity section still opens "The
  recommended rule:" over a column headed "recommended" whose cells are each sensitivity's own pick.
  - For example, it gives `sens_all_stream_branch` → MAD ≥ 0.75, 7 %, Q3@D2000, and `sens_regulated_out` → MAD ≥ 0.5,
    7 %, Q3@D1000. These match the CSV's per-reading `recommended` column, which equals `pick` in every reading.
  - The page now defines "the recommended rule" as the main reading's pick (:45-46) and uses it that way at :62,
    :186, :276 and :403.
  - Every cell is right, and the "unchanged" cells show the reader which sense is meant. But one noun again carries
    two rules.
  - Fix: "Each sensitivity's own pick:" and a column headed "pick".
- **R4-3 [severity: fragile]** research/chinook_rearing_tuned.md:38-40 and planning/active/link-issue-draft.md:77-78.
  **Inside round 3's F4 fix.** Both now say that in the draft's configuration the gradient sits in "two settings": the
  stream rule's own gradient and the CSV's `rear_gradient_max`. The draft's configuration puts it in three.
  - The MAD stream rule carries `gradient: [0, 0.07]`.
  - The second stream rule has "the same edges and gradient" (:74). The draft says "the stream rules" (plural) no
    longer inherit, so it also has `thresholds: false`, and with that it must carry its own `gradient`.
    `.frs_rule_to_sql()` in fresh 0.39.0 inherits gradient, width and MAD only when `thresholds` is unset or TRUE,
    and an explicit rule-level `gradient` always wins.
  - The river-polygon rule inherits the CSV's `rear_gradient_max`.
  - So an edit to one stream rule alone splits the stream branch, which is the case round 3's F4 was written to prevent.
  - Fix: "three settings (each stream rule's gradient and the CSV's `rear_gradient_max`)".

## Notes (no figure is wrong)

- **N1.** CLAUDE.md:219, "At `default`'s gradient". This is correct, and round 3's suggested "at 7 %" was not. The
  636 km is the accessible river-polygon km that `default`'s river branch admits (0–5.49 %, a width) and a MAD
  ≥ 0.75 test fails:
  - total 636.3 km, of which 22.0 km have no MAD: 1450 364.4 km, 1250 152.3 km, 1350 119.7 km;
  - at 0–7 % with MAD < 0.75 (round 3's population) it is 624.1 km;
  - accessible river-polygon segments in the 31 groups are only those three edge types (8,840 km), so "of edge
    1450, 1250 and 1350 lines" is exhaustive.

  Under the first-run rule (floor at 7 %), the km lost were exactly these, because only segments at or below
  5.49 % were in under `default`. That matches round 1's 636 km pre-cluster.
- **N2.** CLAUDE.md:218-219, "carry their tributary's own small wet flow, and so do the main lines (1250) of some small
  double-line rivers". The measured mechanism:
  - 1450: 317.3 of the 364.4 km lie in polygons whose main line carries ≥ 10 m³/s (median 0.059 m³/s).
  - 1250: 114.1 of the 152.3 km lie in polygons whose main line carries < 0.75 m³/s or has no 1250 line here
    (median 0.347).

  So the 1250 lines carry a small river's own flow, and the sentence is right if "so do" means "carry small flow"
  rather than "carry their tributary's flow". The 1350 lines (119.7 km, all in such polygons) are counted but not
  described. Optional: "the main lines (1250) of some small double-line rivers carry their own small flow".
- **N3.** link-issue-draft.md:48-49 (unchanged), "mostly on order-1 streams, which `default` leaves out because fwapg
  models no width there". This is the whole-rule wording round 3's F3 corrected in the write-up.
  - It is true of the km gained, none of which `default` rears.
  - As a clause about order-1 streams in general it is not: 1,430.5 km of stored order-1, no-width CH rearing
    comes through the wetland branch (814.4 km of it on edge 1000). This reproduces round 3.
  - Round 3 passed it as D11. The write-up's "`default`'s stream branch" could be carried over into this public-bound
    text.
- **N4.** research:271, "On fwapg's old MAD (2,695 visits, 112 CH, 18 WSGs". These are the modelled visits among the
  3,227 tuning visits with fwapg MAD, which are in 29 WSGs. Unlike the two places in round 3's F6, the page gives no second size
  for this set, and "18 WSGs" marks it as modelled. F6's fix wording ("The models use …") could be applied for
  consistency.
- **N5.** link-issue-draft.md:32, "Across 15 readings (sensitivities, flow sources, link's own segment gradient)".
  The parenthetical names 13 of the 15. The main reading and the FWA-gradient reading of the link-placed visits
  are not named, and the second is the one :34 misdescribes.
- **N6.** research:257, "the floor leans to 0.5 m³/s". This rests on the best floor in each link reading:
  - on link's gradient: 0.5 at 0, 0.28 at +4.0, 0.35 at +8.8, 0.75 at +11.5;
  - on the FWA gradient: 0.5 at 0, 0.28 at +13.0, 0.75 at +32.4.

  The region's floors run 0.15–1 m³/s on link's gradient, with 17 of 25 rules below 0.5. "Leans" is supported as a
  statement about the best floor, not about the spread.

## Round-3 items, checked

| item | where | resolved? |
|---|---|---|
| F1 | research:252-253, :264, :270-271 | yes in the three places cited (pick = best on `link_gradient`, `src_pick_where_both`, `src_routed` and `src_balance`; the main rule is +0.3 and +1.6, inside both). The sensitivity table keeps the old usage (R4-2). The new Short-answer sentence brings in a new error (R4-1). |
| F2 | research:64 | yes. 731 / 128 / 17.5 % and 1,788 / 130 / 7.3 % on the 3,434 |
| F3 | research:69-70, :98-100, 0297:22-23 | yes. In the 31 groups, every order-1 stream-edge segment with a width is FIELD_MEASURMENT (7,550 segments). 3,910.8 km of order-1 no-width km pass the wetland or lake branch. The draft's parallel clause is N3. |
| F4 | research:37-40, draft:77-78 | partly. The inheritance claim is right; the count of settings is short by one (R4-3) |
| F5 | research:46, :179; draft:31; README:18; chinook_stream_size.md:155-156 | yes. Matches `rule_in` (0297) and `rule_sql` (0298): stream edge AND gradient AND (size OR exception) |
| F6 | research:250, :262 | yes. 3,544 → 2,826 (131 CH, 16 WSGs); 4,085 → 3,028 (163 CH, 26 WSGs). The noun reappears at :62 and in the draft (R4-1) |
| F7 | research:69 | yes. 1,990.5 / 2,900.4 = 68.6 %; 1,905.8 / 2,470.9 = 77.1 % |
| F8 | CLAUDE.md:218-220 | yes (N1, N2) |
| N1 | research:46 | yes, "on the main reading" |
| N2 | research:404-405 | yes. 51 of 103, and 48 of 97 (27 `fresh_default` + 21 `fresh`) |
| N3 | research:382 | yes. SETN 341 visits, 87.7 %; SETN is one of the 31 |
| N4 | research:341 | yes, "modelled" removed |
| N5 | research:273 | yes. The log: "2344 distinct in/out patterns; 6 not converged" |
| N6 | research:312 | yes. FRAN 1,017.9 km gross, +955.1 net; HARR 546.8 km gross, +546.6 net; top two both ways (MORR next, 478.3 / 448.0) |
| N7 | CLAUDE.md:41-42 | yes. 2,795 main rows. The other readings keep the region, `default`, best, pick and recommended rows (and `recommended` = `pick` in all 15) |

## Enumeration table (changed lines only)

Legend: ✓ = the wording names the populations the outputs use, and the number reproduces. R4-*n* = this round's finding *n*;
N*n* = this round's note *n*; F*n* in the round-3 table = round 3's finding *n*. "Modelled" means the WSGs with both outcomes. Line numbers are the files' current ones.

### research/chinook_rearing_tuned.md

| # | line | statement | numerator | denominator | names it | reproduces | verdict |
|---|---|---|---|---|---|---|---|
| 1 | 37-40 | river test any non-NULL width under every rule; gradient moves with the stream branch's here; two settings in the draft's configuration | — | 0297 `rule_in` and 0298 `rule_sql`: one `g` on both branches | partly | "two": the configuration has three | **R4-3** |
| 2 | 45-46 | recommended, by the rule fixed before the run (the main reading's pick): ≤ 7 % and (MAD ≥ 0.75 or ≥ 3 m³/s within 1,000 m) | main `pick` = `recommended` = best | main | ✓ (0297 spec, fixed before the first fit) | ✓ | ✓ |
| 3 | 46-47 | ranges on the main reading, within one SE | 27 region rules | main | ✓ | ✓ | ✓ |
| 4 | 60 | two rules inside the region of all 15 readings: MAD ≥ 0.5, Q3@D1000, 7 % or 9 % | intersection of the 15 in-region sets = exactly those two | 15 readings | ✓ | ✓ | ✓ |
| 5 | 61 | 4.1 (SE 17.0) and 2.8 (SE 18.2) | 4.13 (16.98) at 7 %; 2.84 (18.20) at 9 % | main | ✓ | ✓ | ✓ |
| 6 | 61-62 | recommended rule inside 13 regions | 13 with `in_region` TRUE | 15 readings | ✓ | ✓ | ✓ |
| 7 | 62 | outside both readings on "the 16 link-placed groups" | absent from both link readings' region rows | 2,826 modelled visits in 16 WSGs; placed tuning visits are in 25 | no | number ✓ | **R4-1** |
| 8 | 62-63 | MAD ≥ 0.75 in the region only at 9 % | `link_gradient`: 2 rules, both 9 % ✓; FWA: 3 rules, at 5.49 % ×2 and 7 % ×1, none at 9 % | both link readings | no | no | **R4-1** |
| 9 | 64-66 | 731 vs 1,788; 128 vs 130; 17.5 vs 7.3 % | `n_in`, `n_detect_in`, `raw_rate_in` | 3,434 modelled | ✓ | ✓ | ✓ |
| 10 | 69 | 2,471 of 2,900 gained via the exception | 2,470.9 | 2,900.4 | ✓ | ✓ | ✓ |
| 11 | 69 | 69 % of the gain on order 1 | 1,990.5 | 2,900.4 (68.6 %) | ✓ | ✓ | ✓ |
| 12 | 69 | 77 % of the exception's gain on order 1 | 1,905.8 | 2,470.9 (77.1 %) | ✓ | ✓ | ✓ |
| 13 | 70 | `default`'s stream branch never admits order 1 unmeasured | 0 non-field widths on order-1 stream edges (31 groups) | — | ✓ | ✓ | ✓ |
| 14 | 98-100 | stream branch never admits unmeasured order 1; wetland and lake branches can | 3,910.8 km pass the W/L branch; 1,430.5 km stored via wetland | accessible order-1 no-width segments, 31 groups | ✓ | ✓ | ✓ |
| 15 | 179 | the rule, with the gradient scoping both alternatives | — | `rule_in`, `rule_sql` | ✓ | ✓ | ✓ |
| 16 | 250 | 3,544 tuning visits placed; models use 2,826 (131 CH, 16 WSGs) | placed: 3,544 (131 CH, 25 WSGs); modelled 2,826 / 131 / 16 | tuning population | ✓ | ✓ | ✓ |
| 17 | 250-251 | best MAD ≥ 0.5, 9 %, Q3@D1000 with either gradient | `ddev_best` 0 in both | both link readings | ✓ | ✓ | ✓ |
| 18 | 252 | 25 rules, all at 7–9 %; that reading's pick is its best | 25 (6 at 7 %, 19 at 9 %); `pick` = best | `link_gradient` | ✓ | ✓ | ✓ |
| 19 | 252-253 | main rule outside; MAD ≥ 0.75 in only at 9 % (+11.5, SE 17.4) | Q3@D1000 11.52 (17.38); also Q3@D5000 +38.5 | `link_gradient` | ✓ (the better of two) | ✓ | ✓ |
| 20 | 257-258 | gradient settles at 7–9 %; floor leans to 0.5; `default` out on both | best per floor (N6); `default` out in both | two link readings | ✓ | ✓ | ✓ (N6) |
| 21 | 262 | 3,028 (163 CH) modelled; 4,085 before the both-outcomes filter | `both` = 4,085 (163 CH, 45 WSGs); modelled 3,028 / 163 / 26 | tuning population | ✓ | ✓ | ✓ |
| 22 | 264 | "best rule (that reading's pick)" | `pick` = best in all three flow readings | each reading | ✓ | ✓ | ✓ |
| 23 | 270-271 | main rule best on balance; +0.3 on `pick`, +1.6 on routed, inside both | 0.33 (17.71); 1.55 (17.76); `in_region` TRUE | 3,028 | ✓ | ✓ | ✓ |
| 24 | 271-272 | fwapg old MAD: 2,695 visits, 112 CH, 18 WSGs; best = `pick`'s on those visits | best `mad>=0.5\|g<=0.09\|Q3@D1000` in both | modelled 2,695 of 3,227 (29 WSGs) | ✓ (18 WSGs marks it) | ✓ | ✓ (N4) |
| 25 | 272-274 | 62 rules, 5.49–9 %; 6 in/out patterns with a non-converged fit; pick +55.8 | 62; {5.49, 7, 9}; "6 not converged"; 55.84 | `src_fwapg_old_mad` | ✓ | ✓ | ✓ |
| 26 | 312 | FRAN 1,018 km, +955 net; HARR 547, +547; differ most | 1,017.9 / 955.1; 546.8 / 546.6 | per group, regenerated against stored | ✓ | ✓ | ✓ |
| 27 | 341-342 | 98 % on order 2+, at least 1.5 m wide, wet flow < 0.75 | 8,581.8 km | 8,755.5 (98.0 %); 98.3 % of the 8,660 | ✓ | ✓ | ✓ |
| 28 | 382 | NARC 320, 99.7 %, −42.6 %; SETN 341, 87.7 %; far better sampled | `vis` per group; interior share | 0298 `vis` (0295 filters, placed), 31 groups | ✓ | ✓ | ✓ |
| 29 | 404-405 | barrier known in 51 of 103 groups; 48 of the 97 with stream-branch visits | groups with any known status | 103 groups (21,862 visits); 97 (15,178 stream-branch visits) | ✓ | ✓ | ✓ |

Unchanged lines checked for contradiction with the fixes:
- :49-51, :55-58, :74-75, :226-227, :254-255, :276, :409-410 and :414-416 agree with the changed lines, except
  where R4-1 conflicts with :50-51.
- :287-289 is R4-2.

### planning/active/link-issue-draft.md

| # | line | statement | numerator | denominator | names it | reproduces | verdict |
|---|---|---|---|---|---|---|---|
| D1 | 29-31 | every main-reading region rule has the exception and MAD 0.28–1, 7–9 %, Q 1–10, D 1–2 km; best = pick = the rule | 27 rules: all MAD, floors 0.28–1, g {7, 9}, Q {1, 3, 5, 10}, D {1000, 2000} | main | ✓ | ✓ | ✓ |
| D2 | 32-33 | across 15 readings, two rules stay within one SE of each reading's best | intersection = those two | 15 | ✓ | ✓ | ✓ (N5) |
| D3 | 34 | "the 0.75 floor drops out" on "the 16 groups placed", stays in only at 9 % | 0.75 in at 9 % (link gradient), at 5.49 and 7 % (FWA) | 16 modelled of 25 | no | no | **R4-1** |
| D4 | 68-69 | main pick's values; the 0.5 floor that holds across every reading | the two all-reading rules have MAD 0.5 | 15 | ✓ | ✓ | ✓ |
| D5 | 77-78 | `thresholds: false` stops inheritance; two settings to move together | fresh 0.39.0 `.frs_rule_to_sql` | the draft's configuration | inheritance ✓ | "two" ✗ | **R4-3** |

Unchanged lines :21-22, :36-39 and :43-53 agree with the changed lines. N3 is about :48-49.

### CLAUDE.md, research/README.md, research/chinook_stream_size.md, scripts/0297

| # | line | statement | numerator | denominator | names it | reproduces | verdict |
|---|---|---|---|---|---|---|---|
| C1 | CLAUDE.md:41-42 | every rule's score on the main reading; each other reading's region and picks | 2,795 main rows; region, `default`, best, pick and recommended rows elsewhere | 15 readings (+33 profile rows) | ✓ | ✓ | ✓ |
| C2 | CLAUDE.md:218-219 | 1450 lines carry the tributary's flow; so do some small double-line rivers' 1250 lines | 1450: 317.3 of 364.4 km in polygons with a main line ≥ 10 m³/s; 1250: 114.1 of 152.3 km in polygons with a main line < 0.75 m³/s | the dropped 636.3 km | ✓ (loose reading) | ✓ | ✓ (N2) |
| C3 | CLAUDE.md:219-220 | at `default`'s gradient a 0.75 floor drops 636 km of 1450, 1250 and 1350 lines in the 31 groups | 636.3 km (22.0 km NULL MAD) | accessible river-polygon segments, 0–5.49 %, with a width, 31 groups (all three edge types and no others) | ✓ | ✓ | ✓ (N1) |
| R1 | README:18 | the rule; MAD ≥ 0.5 at 7–9 % in every reading's region; `default` and its MAD bounds outside | the two all-reading rules; no no-exception rule in any region | 15 | ✓ (Q 3 at 1 km implicit) | ✓ | ✓ |
| S1 | chinook_stream_size.md:155-156 | the data prefer ≤ 7 % and (MAD ≥ 0.75 or ≥ 3 m³/s within 1,000 m) | main pick | main | ✓ | ✓ | ✓ |
| K1 | 0297:22-23 | stream branch never admits unmeasured order 1; wetland and lake branches carry no width test | `rule_in`: W and L terms have no width atom | — | ✓ | ✓ | ✓ |
