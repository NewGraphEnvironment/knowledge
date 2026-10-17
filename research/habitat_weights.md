# Habitat weights for BT rearing: what use by gradient, elevation, size and effort means

**Verified:** 2026-10-02; figures rerun 2026-10-17 without repeated surveys (#35) · **Issues:** #28 (this); from NewGraphEnvironment/link#284 step 5; uses #18
(FDIS export), #19 (literature) and #35 · **Produced by:**
- `scripts/0290-bt-use-build.R`: visits on link segments; ledger `scripts/logs/habitat/20261002_bt_use_build_ledger.csv`.
  Since #35 the table is that build less the repeated-survey copies 0230 drops
  (`scripts/logs/habitat/20261017_fdis_repeat_filter.txt`; a rebuild on the current `fresh_default` is part of #57);
- `scripts/0291-bt-use-curve.R`: `data/bt_rear_use_curve.csv`, with log `scripts/logs/habitat/20261017_bt_use_curve.txt`;
- `scripts/0292-bt-weight-candidate.R`: `data/habitat_weight_bt_rear.csv`;
- literature rows 482–489 of `data/literature_evidence.csv`.

**Status:** candidate weight drafted; nothing applied in link.

link draws BT rearing as on/off at a gradient cutoff (`rear_gradient_max`, 0.1049 in `default`, 0.1349 in
`default_tuned`). link#284 step 5 showed sightings per km taper across that line rather than stop. This
file says what the taper is made of and what a weight in its place should mean.

## The short answer

**Use falls with gradient. Most of the fall is in where BT and fish are found at all, not in how often
BT turn up where fish are.** The evidence is electrofishing visits on BT-accessible stream in link's own
segments, adjusted for effort.

- **Any fish caught** (F). The share of visits that catch any fish falls: 1.16 on 0–2 % core, 0.58 at
  8–10.49 %, 0.24–0.38 beyond the cutoff.
- **BT given any fish** (C). Among visits that caught any fish, the BT share does not fall. Its weight
  on the steep classes is 0.88–1.33, and every interval includes 1.
  - This is not proof the steep classes are as good as core. A visit catching only BT counts as a fish
    visit, so the share can hold up as other species drop out.
- **Fish size.** The BT caught on steep stream are mostly small: 87–94 % of measured BT in the steep
  classes are fry or parr.

So a weight on gradient is a weight on **expected use**: whether BT, and fish at all, are present in that
part of the network, times how often BT are among the fish. It is not a measure of habitat preference.
Nothing here locates the upper limit of fish. A fishless steep visit is consistent with being above it,
or on a fishless stream, but the analysis does not show which.

## Answers to the issue's five questions

1. **Intrinsic potential or observed use? Observed use, corrected for effort, and labelled as such.**
   - Presence data cannot separate potential from use.
   - The weight is the relative rate of catching BT on a standard electrofishing visit, on BT-accessible
     stream, after fished area, data set, era and watershed group are accounted for.
   - Detectability is folded in, as it is in any presence model.
   - Access is folded in twice, and both parts are named. One is the modelled barriers, through
     `access_bt`. The other is where in the network BT and fish live at all, including any upper fish
     limit, which link does not model.
2. **Which driver belongs in which weight?** See the table below.
3. **Can effort be corrected for? Yes, and it matters less than expected.**
   - FDIS site visits carry fished area, time and zero catch, which bcfishobs presence records do not.
   - Area enters as a covariate. Detection scales only weakly with it: the coefficient is 0.07–0.19 on
     the cloglog scale, where proportionality would be 1.
   - Swapping area for fishing time moves no steep weight by more than 0.1.
   - What effort data really buy is the zero-catch visit. That is what separates "no fish here" from
     "BT absent among fish".
4. **Rearing or adults moving through? Mostly rearing, with some spawning in the same streams.**
   - Size classes (`data/fdis_size_breaks.csv`): fry and juveniles are 87–94 % of measured BT in every
     class from 10.49 % up.
   - Large adults sit on low-gradient core (510 of 3,174 measured fish at 0–2 %).
   - Spawner evidence (maturity code or season) is more frequent per BT visit on steep stream than on
     low-gradient core:
     - 9 of 63 BT visits at 10.49–12.49 %, and 8 of 72 above 14.49 %;
     - against 23 of 774 at 0–2 %.

     Small resident spawners in steep headwaters would do this; so would mature fish moving through. The
     data cannot separate the two.
5. **A use curve in the literature? Not at reach or segment scale.**
   - The store holds the following (rows 482–489):
     - a use-only cumulative distribution of juvenile sites by reach slope (Isaak et al. 2015 App. S1:
       about 0.63, 0.84 and 0.95 of 1,102 sites by 6, 9 and 12 %);
     - an occupancy coefficient on slope at whole-habitat scale (Isaak 2015 Table 4, −0.166 per % on
       the logit scale);
     - a site-scale null (Dunham & Chandler 2001: temperature carried the model, gradient did not);
     - a macroreach model that did not select gradient (Porter et al. 2008).
   - None is a graded reach-scale occupancy curve.
   - Porter's watershed model has a positive elevation term, at watershed scale. Here elevation acts
     with opposite signs in different groups of WSGs (below), so no single provincial elevation term
     is expected.

## Each driver, and where it belongs

| driver | position | evidence |
|---|---|---|
| **gradient** | **In the weight, as expected use.** The weight falls to about 0.5 beyond 12.49 %. The fall sits in whether fish and BT are present at all (any-fish weight 0.24–0.38), not in BT's share among fish (BT-given-fish about 1). | `data/bt_rear_use_curve.csv` |
| **where fish and BT live at all** (fishless steep visits, BT range) | **Bias to correct in link, eventually by modelling it** (an upper-fish-limit model, as FDS surveys are designed to find) rather than leaving gradient to stand in for it. Until then it rides inside the gradient weight, and the weight says so. | F weights |
| **elevation / temperature** | **Handled elsewhere, regionally.** Temperature belongs to link#21's GSDD work and, for the Fraser, #20. A single elevation term does not earn a place: added to the model, it makes held-out prediction worse (log-likelihood −1,707 → −1,784). That is because elevation acts with opposite signs in different groups of WSGs, not because it has no effect. | 0291 log; probe below; Dunham & Chandler 2001 p. 30 (the elevation–temperature relation is local) |
| **step 5's per-km elevation taper** | **Real in the held-out WSGs, per visit as well as per km.** On held-out core, BT per visit falls by elevation third: 0.41, 0.28, 0.11, on 895, 789 and 901 visits, so sampling is even. The calibration WSGs go the other way: 0.10, 0.17, 0.15. So step 5's taper is detection, not sampling density, and it is regional. | raw core rates by role and elevation third (0291 inputs) |
| **channel size** (width, MAD) | **Bias to correct; a candidate second axis.** Larger streams have more BT: log(width) +0.230, SE 0.029. Steep streams are small, so adding width lifts the steep weights by 0.10–0.16 (width subset), and MAD lifts them by 0.15–0.43 (MAD subset). Segment width is null on 12.6 % of visits and MAD on 25.0 %. A width term in link waits for the null share to fall. | width and MAD sensitivities |
| **sampling effort** | **Corrected in the weight** (area covariate, data set, era). | effort sensitivities |
| **access, modelled barriers** | **Handled by link's access model.** The population is `access_bt` 1 or 2. Code 2 ("BT observed upstream") is defined from bcfishobs records, mostly these same FDIS visits. A visit's own BT catch therefore tends to put its segment in code 2, so the code is circular and is neither a covariate nor evidence here. 28 BT catches sat on code-0 segments (0290's ledger, before #35 dropped repeated surveys): barrier-model evidence for link. | 0290 ledger |
| **spawning connection** (step 5's 101 km of non-steep band-1 stream) | **Not a gradient question.** Accessible low-gradient stream that link does not rear has a BT-caught weight of 0.50 and a BT-given-fish weight of 1.07. Its visits are often fishless (any-fish weight 0.36). Its weight belongs to the clustering and bridge rule, so it is reported and not given a gradient weight. | class `not rearing <= 10.49` |

## The candidate weight

`data/habitat_weight_bt_rear.csv`: one row per class on link's ladder, holding aggregates only.

The rule, fixed in `scripts/0292` before it ran:
- take the BT-caught weight;
- cap it at 1;
- pool adjacent violators, weighted by visits, so the weight never rises with gradient;
- carry the BT-given-fish and any-fish weights beside it.

| class | rearing under `default` | candidate weight | BT caught (95 % interval) | BT given fish | any fish | visits |
|---|---|---:|---|---:|---:|---:|
| core 0-2 % | yes | **0.95** | 0.92 (0.81–1.03) | 0.79 | 1.16 | 4,920 |
| core 2-5 % | yes | **0.95** | 1.24 (1.08–1.43) | 1.30 | 0.94 | 2,531 |
| core 5-8 % | yes | **0.90** | 0.90 (0.72–1.11) | 1.18 | 0.69 | 1,320 |
| core 8-10.49 % | yes | **0.76** | 0.76 (0.54–1.01) | 1.20 | 0.58 | 531 |
| 10.49-12.49 % | no | **0.66** | 0.66 (0.46–0.87) | 1.33 | 0.38 | 595 |
| 12.49-13.49 % | no | **0.52** | 0.52 (0.26–0.83) | 1.30 | 0.35 | 199 |
| 13.49-14.49 % | no | **0.51** | 0.28 (0.09–0.49) (underpowered) | 0.88 | 0.24 | 156 |
| >14.49 % | no | **0.51** | 0.56 (0.38–0.75) | 1.19 | 0.29 | 698 |

Before #35 dropped repeated surveys (2026-10-02), the candidate weights were 0.95, 0.95, 0.89, 0.74,
0.64, 0.50, 0.50 and 0.50: none moved by more than 0.02.

Core 0–2 % sits at 0.95, not 1.
- Its own estimate is 0.92, below 2–5 % at 1.24. Pooling the two (2–5 % capped at 1) keeps the weight from rising with gradient.
- Low-gradient core has the most fish-bearing visits (any-fish weight 1.16) but the fewest BT among them (0.79): other species dominate there.
- Dropping river polygons barely moves it (0.93), so large rivers are not the reason.

How it should be read in link:
- **Apply to BT-accessible stream.** Core classes are already rearing. The steeper classes are stream
  that a looser cutoff, or a weight, would add.
- **Report it as expected use, beside cutoff km.** Do not call it habitat quality. The decline sits in
  where fish and BT are present, not in BT's share among fish.
- **The 13.49–14.49 % class is underpowered** (156 visits, 7 with BT). Its weight is pooled with its
  neighbours.

## What this does not say

- **Not independent of step 5.** About 72 % of bcfishobs BT records are FDIS (#23). This curve and link's
  taper share much of their data, so their agreement is consistency, not corroboration. Porter 2008 also
  used FDIS.
- **Electrofishing only.** Large rivers and lakes are under-sampled. Fished areas over 10,000 m² were
  trimmed.
- **The held-out WSGs run lower than calibration** in both U and C at the steep end:
  - U: 0.41 against 0.78 at 10.49–12.49 %;
  - C: 0.77 against 1.67.

  The intervals overlap, but the shape is not identical. The held-out step-5 bands hold too few visits to
  read: 82, 33 and 20.
- **FDS and FDIS agree on the first steep step and diverge after it.**
  - At 10.49–12.49 %, FDS and FDIS are 0.60 and 0.63.
  - The FDS-only steeper classes run 0.93, 0.50 and 1.13 on few detections, where FDIS gives 0.47, 0.31
    and 0.49.
  - The pooled weight mixes two sampling designs.
- **Coverage.** link has modelled 63 WSGs (fresh_default's 55 plus the 8 step-5 held-out). After the
  area trim and the both-outcomes rule, the BT-caught fit uses 53 of them (12,764 visits). 19,691 placed
  visits outside link's WSGs were not used (0290's ledger, before #35).

## Dead ends, kept because they are evidence

- **Effort as an offset.** P = 1 − exp(−λ·area) assumes detection proportional to area. The any-fish
  and BT-given-fish fits diverged (coefficients near 1e14), and every bootstrap interval ran from 0 to
  Inf. With area free, its exponent is 0.07–0.19. The spec was changed from the convergence failure,
  before any weight from it was read (0291 header, Change 1).
- **A forked bootstrap.** It segfaults in `glm.fit` under macOS's Accelerate BLAS. Socket workers fit the
  same resamples.
- **A 5 m placement nudge.** It skipped short segments starting at the site: 817 visits, 171 of them
  changing band. Placement now takes the segment starting within −1 to +5 m of the site.
- **"Detection is 0.034 where BT are not known upstream, on steep and non-steep stream alike."** Round 1 of
  review asked for the access-code mix to be quantified, and a fix used it as evidence that the decline is
  where BT live. Round 2 showed it is circular:
  - code 2 is built from these visits' own records;
  - on steep segments code 2 holds 68 % of visits that caught BT, against 2.6 % of those that did not.

  The split stays in 0291's log, labelled circular, and nothing rests on it.
- **"Step 5's elevation taper is sampling density."** A first draft said this from the all-WSG elevation
  ratios (mid 1.27, high 1.01). Review split them by role: held-out falls, calibration rises, and the
  all-WSG figure averages two opposite signs.
- **"Steep classes are as good as core."** A first draft read BT-given-fish ≈ 1 this way. Review pointed
  out that a BT-only visit is a fish visit, so the share can hold up as other species drop out.
- **The first per-visit taper.** It read like gradient avoidance, until the zero-fish share was split out
  (plan review, `planning/archive/2026-10-issue-28-habitat-weights/review-plan.md`, G1).
