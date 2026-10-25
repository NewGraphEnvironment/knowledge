# Coho rearing rule tuned on the province-wide run

**Verified:** 2026-10-24 (rescored after the intercept fix, the curve refit with the grid's prior, regraded under the
grade gate and recompared, #73; tuned on the evidence rebuilt on wet's 2026-10-19 flows, with the walk ending at the
river's bank and the gradient ladder to 30 %, 2026-10-23; first tuned 2026-10-17, #57; regraded 2026-10-19, #65) ·
**Issues:** #57, #65, #73 (folding #68, #80 and #81's run-time pieces) · **Produced by:** `scripts/0310` (evidence
build, ledger `scripts/logs/habitat/20261022_evidence_build_ledger.csv`), `scripts/0320` (`data/tune/CO_rear_*`, log
`scripts/logs/habitat/20261024_tune_run.txt`), `scripts/0330` (`data/compare/CO_rear_*`, log
`scripts/logs/habitat/20261024_compare.txt`), `scripts/0325` (`data/thresholds.csv` row `CO_rear_v1`; no grades, see
"No grade") · **Status:** measured; nothing applied in link. The method and the cross-species table
are `habitat_thresholds_tuned.md`.

## What to expect of juvenile coho

Coho fry and parr rear in small streams and in pools, side channels and off-channel water, and the intrinsic-potential
models size their streams accordingly. Burnett et al. (2007) start the coho flow curve at modelled mean annual flows
under 0.06 m³/s, the Oregon "small stream" class, and let it decline only above 21.24 m³/s, to 0.5 above 76.45
(`data/literature_evidence.csv` rows 191–193); Agrawal's model, as Sheer et al. (2009) summarise it, puts the floor at
0.01 m³/s (row 287); Woll et al. (2017) give stream orders 1–4 the top class (row 456). On gradient the same models
agree on a low optimum and a limit near 5–7 %: Burnett's curve is highest at 0 % and falls linearly to no use above
7 % (rows 201–202), Agrawal's ends at 7 % with "very low" potential above 5 % (rows 285–286), Woll (2015) rates streams
over 5 % no potential (row 426), and Porter et al. (2008), from FDIS catch in the Thompson, put the top class at
2.45–3.25 % (row 472). The expectation, then, is a rule with the smallest size floor the data can carry and a gradient
limit at or below link's `default` (width ≥ 1.5 m, gradient ≤ 5.49 %).

## Evidence

5,442 stream-branch electrofishing visits (1,107 with CO) in 85 groups in link's CO range with no natural barrier
downstream; 4,263 of them, in the 62 groups where coho were both caught and missed, are modelled. Half the modelled
visits are on streams under 0.15 m³/s (a quarter under 0.04). Coho were caught on 40 % of the visits at 3 % or less,
23 % at 3–4 %, 14 % at 4–5.49 %, and still on 18 % of the 802 visits above 9 % (148 detections).

## Recommended rule: MAD ≥ 0.03 m³/s, gradient ≤ 4 %, no exception

Two departures from `default` (the size test moves from width to flow; the gradient falls from 5.49 to 4 %), and the
same rule from link's flow start (`default_tuned`'s MAD ≥ 0.03 m³/s at 5.49 %, link#331; from there it is one departure).
It sits 11.8 deviance behind the best rule (MAD ≥ 0.1, 4 %, a ≥ 3 m³/s river within 2 km; held-out deviance 3,855.9
against 4,024.0 for no rule) with an SE of 17.3, inside the region. The region holds 89 rules, all MAD rules: MAD
0.03–0.2 m³/s, gradient 3 or 4 % (one rule at 7 %), with or without an exception (87 have one, at every Q and D on the
ladder, because the exception admits almost nothing a 0.03 floor refuses). Coho are caught on 41.2 % of the visits the
rule admits against 15.2 % outside (`default`: 33.0 % against 19.2 %).

**`default` is outside the region**, 111.8 behind the best (SE 47.4, 2.36 SEs), on all four extra fold seeds; so is link's
`default_tuned` floor at `default`'s gradient (72.5, SE 28.5). The 1.96 SE pick (#79) is width ≥ 1.5 m at 4 %, from a
region of 1,511 rules: at the stricter bar the size test cannot be told from `default`'s and the gradient still can.

**What the checks say** (each listed with its direction):
- *Nested selection* (the pick chosen on four folds, scored on the fifth): 3,877.3 against `default`'s 3,967.7 and
  4,024.0 for no rule; folds 1–3 pick 3 %, folds 4 and 5 pick 4 %. For the rule.
- *Four more fold seeds*: all four recommend this exact rule; `default` outside on all four. For.
- *Group bootstrap* (200 resamples, width start | flow start): a MAD floor in 86 | 97 %, 0.03 in 69 | 86 %; gradient
  4 % in 53.5 | 50 %, 3 % in 38 | 42 %, 5.49 % in 6 | 6.5 %; no exception in 55.5 | 59 %. The exact rule in 26.5 %.
  For the size variable and the gradient; the exact rule is one of several the resamples spread over.
- *Profiles* (best rule at each value, as deviance behind the best, SE): size 0.1 best, 0.03 +4.4 (15.6), 0.15 +25.5,
  0.2 +27.6, every width floor +27.9 to +37.3; gradient 4 % best, 3 % +11.2 (35.8), 7 % +35.3 (37.7), 5.49 % +47.4
  (25.9), 9–30 % +62 to +76. For a floor at the bottom of the ladder and against 5.49 %.
- *The joint curve* (size × distance to a 10 m³/s river, gradient; edf 23.1, 3.75, group effect 48.7, with the grid's
  prior on the data-set and era terms) scores 4,092.0 held-out, above the grid's best and above no rule: the surface
  overfits the 62 groups. Against reading more than a cut into the curve, and the reason coho has no grades (below).

## What it is not

- **Not a lower bound on coho streams.** 0.03 m³/s is the bottom of the ladder (`default`'s own MAD floor), and the
  visits below it still catch coho on 10 % (96 of 922): the floor is the smallest the grid offers, not a value the data
  placed.
- **Not a limit of use at 4 %.** The cut best separates held-out detection, and the gradient curve falls steadily
  (relative rate 1.7 at 0.5 %, 1.0 at 4 %, 0.76 at 5.5 %, about 0.6 from 7 to 15 %) with no step; coho are caught above
  9 % on 18 % of visits. Porter's 3.25 % and Burnett's 7 % bracket it.
- **Not a change to river polygons, wetlands or lakes**, which keep `default`'s tests under every rule.
- **A rate per standard electrofishing visit, not capacity or density.**

## No grade

The rule is a yes or no for each segment. A grade would go further and rank the segments, from the joint curve's
predicted rate relative to a reference, so the question is whether the curve knows more than the rule. It is judged
the way every rule was: fitted on most watershed groups and scored on the groups left out (held-out deviance, lower is
better). Coho's curve scores 4,092.0 there against 4,024.0 for no rule at all, one constant rate everywhere: on groups
it has not seen, it predicts worse than not ranking, so a ranking from it would mislead. The gate Al set for every
species on 2026-10-24 follows: a curve no better than no rule on held-out groups gets no grades.
For coho, then, `0320` still walks every accessible segment and records its size and its distance to a 10 m³/s river,
because `0330` needs them to apply the rule, but writes no rate, grade or class, and `0325` leaves coho out of
`knowledge/habitat_grade/v1`. Graded kilometres are blank in the comparison below.

The gate touches only the grade. The rule comes from the grid of cut rules, each scored on the same held-out groups,
and its best beats no rule by 168 (3,855.9 against 4,024.0). The curve's failure is the surface, not the data-set and
era terms: giving those the grid's prior (normal, SD 2.5) moved its score by 0.5 (4,092.5 without it).

## What the rule changes on link's segments (`scripts/0330`, `data/compare/CO_rear_*`)

The baseline is link's `default` (configs at `102762da`, which every species' comparison used on 2026-10-24; the
`67a410e2` configs of the earlier coho comparison lack only `cabd_additions_barriers`, which never moves access, and
every kilometre below is the same under both), regenerated through fresh's predicate, the user-habitat overlay and connectivity on link's 100 CO groups: through-wetland lines (edge 1050/1150) go
through the gradient and size door (link#364), so it draws 79,829 km where the stored flags, from the run's older
configs, hold 81,750 (#65's regeneration under the run's configs drew 81,629, so the door takes about 1,800 km). The tuned rule is set beside it under two structures;
having no exception, it has no third:

| structure | tuned km | change | lost | gained | of the gain, through-wetland lines |
|---|---|---|---|---|---|
| free pass on through-wetland lines (as the rule was scored) | 77,602 | −2.8 % | 9,149 | 6,922 | 1,679 |
| door on through-wetland lines (link's `stream`) | 75,430 | −5.5 % | 9,945 | 5,546 | 403 |

Under the door, 5,045 km are lost to the 4 % gradient maximum, 3,613 km of streams over 1.5 m wide under 0.03 m³/s, 805
km of through-wetland lines that pass `default`'s door and fail the tuned one, and under 500 km to connectivity and the
river-polygon branch; 5,063 km are gained where the flow passes and the width fails or is unmeasured (5,048 of the
5,546 km gained are order-1 streams), and 403 km of through-wetland lines that pass the tuned door and not `default`'s.
Across groups the change runs from −35.9 % (UDEN) to +22.9 % (COMX), median −4.0 %; 32 of 100 groups gain.

**Checks.** FDIS detection on each rule's segments against accessible segments outside it: `default` 29.1 % against
12.9 % (1,407 of 4,829 visits, 399 of 3,101); the tuned rule 32.5 % against 11.2 % with the free pass, 33.0 % against
11.1 % with the door. On the bcfishobs records FDIS does not hold (presence only, never scored), the share of
locations on the rule's segments over the rule's share of accessible stream-edge km is 1.750 (1.714–1.787) for
`default`, 1.815 (1.770–1.862) with the free pass and 1.818 (1.773–1.864) with the door; the door's lift over `default`
is 0.068 (0.033–0.098). **The two structures cannot be told apart by either check**, and the scoring never saw a
through-wetland line (its visits are on edge 1000/1100/2000/2300), so the structure is link's call: `door` is what
link#364 chose for coho and what the thresholds table records (`data/thresholds.csv`, `0325` on 2026-10-25: coho's
`near_river_scope` is empty, the rule having no pair).

The floodplain table (`data/compare/floodplain.csv`) and the maps were not redrawn for #73 (`0330 STAGE=maps`); their
coho figures are #65's, on the run's own configs. Maps: `research/fig/compare_co_rear_*.png`.
