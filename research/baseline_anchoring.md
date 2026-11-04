# How much the starting point chooses the published rule

**Verified:** 2026-11-04 · **Issues:** #141 (this measure), for #139 (the baseline review) and #140 (grayling's
baseline, read against the "before" below); the second start is #80, where the anchoring showed is #120 ·
**Produced by:** `data-raw/tune_anchor_check.R` over the saved tuning tables, through `knw_tune_anchor()`; logs
`scripts/logs/habitat/20261104_tune_anchor_check-*` · **Status:** measured on #92's published tables (published until #145's promotion of 2026-11-04) and on the
minimal-network candidate; every later run of `scripts/0320` writes the same columns into each summary and its pick
report.

## What was asked

The tuning scores every candidate rule by how well it predicts where fish were caught in watershed groups held out of
the fit. Many rules score within one standard error of the best, and the data cannot rank those apart: that set is the
rule's **region**. From the region the tuning publishes the rule that changes the fewest parts of link's `default` (a
size test, a gradient limit and a near-river exception, one part each). The region does not depend on `default`; the
choice inside it does. So where the region is wide, the starting point, not the data, decides which of several equally
good rules is published.

This measures that choice for every tuned key. For each of the two starting points (link's `default`, and its flow
version, the same rule with its width floor written as the MAD it stands for, #80) it sets the published pick beside
the rule the data score best, and counts:

- how far the pick sits behind the best, in deviance and in standard errors (always under one, by construction);
- how many parts separate the pick from the best, and which (`rec_moved` from `default`, `flow_moved` from the flow
  start);
- how many parts separate the two starts' picks (`starts_apart`).

One limit is not the start's. No pick may carry a near-river exception closer than 200 m (`d_floor`: at that distance a
catch on a mainstem snapped to a tributary's mouth cannot be told from one in the tributary), but the best-scoring rule
may. Where it does, no start could reach it, so each pick is also measured against the **best allowed** rule, the
best-scoring rule a pick may be: in the region, and with no exception or one at 200 m or more (`rec_moved_allowed`,
`flow_moved_allowed`). It is the best itself wherever the best is such a rule (on all fifteen tables read here, every
rule converged, so the floor is the only reason it is not).

A pick 0 parts from the best is the best: the start chose nothing. A pick several parts away is a rule the data accept
but did not choose; the parts it kept from `default` are there because `default` had them.

Rules with the same in or out on every visit are one fit and tie at the best (2 to 4 rules on six of the fifteen
tables). The best is then the first of them in grid order, as the summary already names it, and a pick's distance is
to the nearest of them.

## What the tables say

On #92's published tables (link's full network), four of eight picks are the best-scoring rule (chinook rearing,
bull trout spawning, rainbow trout rearing, westslope cutthroat rearing). The other four are not:

| key | pick from `default` | best-scoring rule | pick behind the best (deviance / SE) | parts apart | flow start picks |
|---|---|---|---|---|---|
| steelhead rearing | `mad>=1\|g<=0.0849\|Q1@D250` | `mad>=0.28\|g<=0.25\|Q1@D100` | 7.2 / 17.9 | size, gradient, exception | the same |
| grayling rearing | `width>=2\|g<=0.0549\|none` | `width>=1\|g<=0.0549\|Q50@D500` | 5.7 / 10.4 | size, exception | `mad>=0.021\|g<=0.0549\|none` (11.6 / 13.9) |
| coho rearing | `mad>=0.1\|g<=0.0549\|Q3@D2000` | `mad>=0.1\|g<=0.04\|Q3@D2000` | 7.7 / 29.9 | gradient | the same |
| bull trout rearing | `mad>=0.1\|g<=0.3\|none` | `mad>=0.1\|g<=0.3\|Q20@D100` | 0.6 / 9.9 | exception | the same |

Two of those bests carry an exception at 100 m, which no pick may. Bull trout rearing's pick is the best rule a pick
may be (0.6 behind the best), so its start chose nothing. Steelhead rearing's best allowed rule is
`mad>=1|g<=0.07|Q1@D250` (3.5 behind the best; two rules that score better clear of the floor are outside the region),
and its pick is one part from it (the gradient), not three.

The two starts pick the same rule on six of eight keys. They differ on chinook rearing, where the flow start keeps
`default`'s MAD floor of 0.28 m³/s (24.8 behind, SE 26.9) and the width start reaches the best's 0.75, and on grayling
rearing, where the flow start keeps a MAD floor and the width start a width floor.

On the minimal-network candidate (run `20261103_0838`, #120), three of seven picks are the best. The other four are
not:

| key | pick from `default` | best-scoring rule | pick behind the best (deviance / SE) | parts apart | flow start picks |
|---|---|---|---|---|---|
| bull trout rearing | `mad>=0.35\|g<=0.1049\|none` | `mad>=0.1\|g<=0.2\|Q20@D100` | 65.3 / 73.7 | size, gradient, exception | the same |
| grayling rearing | `width>=1.5\|g<=0.0549\|none` | `width>=2\|g<=0.0549\|Q50@D500` | 9.3 / 10.9 | size, exception | `width>=2\|g<=0.0549\|none` (3.9 / 5.3) |
| steelhead rearing | `mad>=0.5\|g<=0.0849\|Q1@D250` | `mad>=0.5\|g<=0.0549\|Q1@D250` | 11.7 / 18.9 | gradient | the same |
| coho rearing | `mad>=0.1\|g<=0.0549\|Q3@D2000` | `mad>=0.1\|g<=0.04\|Q3@D2000` | 11.7 / 30.5 | gradient | the same |

Bull trout rearing's best carries an exception at 100 m again. Its best allowed rule is `mad>=0.1|g<=0.2|none` (0.7
behind the best), and its pick is two parts from that (size and gradient): the start chose those two, the floor the
third.

The starts disagree on three keys here: grayling rearing, chinook rearing (MAD 0.28 against 0.75 again) and bull trout
spawning, where the width start's pick is the best and the flow start's `width>=1.5|g<=0.13|none` differs from it in
all three parts (4.8 behind, SE 4.9).

The two readings differ in the network, the flow load and each species' range at once (`minimal_network_tuning.md`),
so a key's change between them is not the network's alone.

## Where the baseline review starts

Ordered by the parts the `default` pick sits from the best rule a pick may be, then by how near the region's edge it
sits (its distance behind the best in SEs), then by whether the two starts disagree:

- **Published:** grayling rearing (2 parts, 0.55 SE), steelhead rearing (1, 0.40), coho rearing (1, 0.26). Bull trout
  rearing's and the other four keys' picks are the best a pick may be.
- **Minimal network:** bull trout rearing (2, 0.89), grayling rearing (2, 0.85), steelhead rearing (1, 0.62), coho
  rearing (1, 0.38).

Grayling rearing is in the first two on both readings, two parts from the best both times, and the only key whose two
starts pick different kinds of size test (a MAD floor and a width floor on #92's tables). Bull trout rearing,
next in #139's order, is steered on the minimal network and not on #92's tables, so it is the key whose
reading moves most with the build; its pick on the minimal network is the furthest of any from its best in deviance.

## Grayling rearing: the "before" for #140

`default` is `width>=1.5|g<=0.0349|none` on both readings, outside the region (19.3 behind, SE 6.7, on #92's tables; 14.4,
SE 11.8, minimal).

| reading | best-scoring rule (tied) | pick from `default` | parts from the best | pick from the flow start | parts from the best |
|---|---|---|---|---|---|
| #92's published tables | `width>=1\|g<=0.0549\|Q50@D500` (2) | `width>=2\|g<=0.0549\|none`, 5.7 behind (SE 10.4) | size, exception | `mad>=0.021\|g<=0.0549\|none`, 11.6 behind (SE 13.9) | size, exception |
| minimal network | `width>=2\|g<=0.0549\|Q50@D500` (2) | `width>=1.5\|g<=0.0549\|none`, 9.3 behind (SE 10.9) | size, exception | `width>=2\|g<=0.0549\|none`, 3.9 behind (SE 5.3) | exception |

Both readings move `default`'s gradient limit to 5.49 % and leave the near-river exception the best carries (a river of
50 m³/s within 500 m) off the pick, because `default` has none. The size floor is where the start shows: the best sits
at 1 m on one reading and 2 m on the other, and the picks at 2 and 1.5 m. A rebuilt baseline (#140) is read by
running the same check on its tuning: if the pick moves fewer parts from the best, the start chooses less.

## What this is not

A moved pick is not a wrong rule. It is inside the region by construction, and the data cannot tell it from the best;
the measure says how much of the choice between equals came from the start. Nor is a pick at the best proof that its
baseline is grounded: the region may simply be narrow, or the baseline far enough out that every region rule departs in
every part.
