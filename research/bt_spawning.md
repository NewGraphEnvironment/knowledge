# BT spawning: what the evidence says about gradient and channel size

**Verified:** 2026-10-02; groundwater rows 2026-10-07 (#36) · **Issues:** #33 (this); follows #28 (`habitat_weights.md`); spawned #34, #35, #36 ·
**Produced by:**
- `scripts/0293-bt-spawn-evidence.R`: `data/bt_spawn_evidence.csv`, log `scripts/logs/habitat/20261002_bt_spawn_evidence.txt`;
- literature rows 490–510 of `data/literature_evidence.csv`, gate `scripts/logs/habitat/20261002_literature_verify.csv`;
- groundwater rows 675–686 (#36), gate `scripts/logs/habitat/20261007_literature_verify.csv`.

**Status:** Tracks 1 and 2 done. Track 3 (the Williston critical spawning segments) is pending: the layer
is on m4, which was unreachable. Nothing is proposed for link yet.

link rears BT only where stream connects to spawning, and spawning is gated at `spawn_gradient_max` 0.0549
and `spawn_channel_width_min` 2 m. This file says what fish records and the literature can and cannot say
about those two numbers.

## The short answer

- **Electrofishing spawner evidence cannot settle spawning gradient.**
  - Among Aug–Oct visits that caught BT and maturity-coded at least one, the share with spawner evidence
    rises with segment gradient: 0.146, 0.188, 0.182, 0.293, 0.302, 0.352 across ≤ 2 to > 10.49 %.
  - The rise is between watershed groups, not within them. With a WSG term in the model the rate ratios
    are 0.75–1.22, with intervals of roughly 0–3.6 (zero lower bounds where sparse resamples separate). Without one they climb to 3.07 at > 10.49 %.
  - Coding effort and month do not remove the rise; the WSG term does.
  - So nothing detectable within WSGs, and nothing ruled out.
- **The spawners caught on steep stream are mostly small.**
  - Large spawners (≥ 350 mm) number 3–9 visits per class, too few to read.
  - Small mature fish appear on steep segments and in a few streams under 2 m wide: 10 spawner-evidence
    visits below 2 m, 8 of them small fish.
  - That fits resident spawning beyond link's thresholds. But "spawner" includes M-coded fish in August,
    which may be migrants.
- **The literature gives observed spawning gradients, but no limit.**
  - BC reach studies place BT spawning at 0.6–4 %: Cope & Morris 2001 0.6–1.0 %; O'Brien 1999 section
    averages of 1.3, 1.9 and 4 %; Bustard & Schell 2002 1–4 % (`habitat_literature.md`). Montana sources
    describe spawning in low-gradient areas (evidence data rows 73, 78).
  - No source gives a maximum or a minimum (rows 70–71). The 2010 critical habitat rule sets no gradient
    range: it is "unable to define a conclusive upper and lower range of conditions for specific PCEs,
    given this complexity" (p. 63931). It does still state water temperatures "ranging from 2 to 15 °C"
    for one of them.
  - The US documents' gradient statements are qualitative:
    - "preferred spawning habitat of bull trout consists of low-gradient stream reaches with loose, clean
      gravel" (Fraley & Shepard 1989, via the 2010 rule);
    - resident populations live in headwater streams that are smaller and have higher gradients (the
      2010 rule, restating McPhail & Baxter 1996).
  - Hagen & Spendlow 2019 report smaller populations of large-bodied spawners in shorter, steeper
    tributaries.

## "Do they push up steep water to reach low-gradient spawning?"

Not tested, and what can be described is mixed:
- Hagen et al. 2015 (p. 9, citing other authors) report much higher juvenile densities above chutes and
  bedrock canyons than below them. That is read there as spawners passing difficult reaches to natal reaches
  above them, but it gives no gradient for those spawning reaches.
- Of 10 distinct large-spawner surveys on segments steeper than 5.49 %, 5 have a low-gradient patch
  (≥ 200 m at ≤ 5.49 %, ≥ 2 m wide) upstream on the same blue line, at 780–5,394 m.
- 4 have no such patch anywhere upstream in their WSG, at segment gradients of 10.2–15.7 %. For those,
  these segments do not support transit, though segments with no modelled width cannot count as a patch.
- There is no baseline for how often a random steep site has a patch upstream. A prototype in the plan
  review found no upstream separation between spawner and non-spawner visits, but the same review judged
  that test design invalid (B3), so it is not a negative result either.

The counts are far too small for a test (`planning/archive/2026-10-issue-33-bt-spawning-evidence/review-plan.md`, B1 and B3), so this stays descriptive.

## Each question, and what answers it

| question | what answers it | status |
|---|---|---|
| Does BT spawning use fall past `spawn_gradient_max`? | redd locations on FWA (Track 3); not electrofishing | **pending**: the Williston critical spawning segments are on m4 |
| Is 2 m the right width floor? | redd locations; Hagen et al. 2020 p. 49 (redds of large migratory BT in sections as small as 2 m wetted, same lead author as the 2015 2 m row) | 2 m is the smallest stream with migratory redds in one author group's experience (rows 86, 496, not independent), and such streams held a small share of redds. Morice spawning sites were all in reaches wider than 7 m (row 189). Fish records show small mature BT below 2 m |
| Resident vs migratory spawning | size and maturity at the visit | resident-sized mature fish turn up on steep, small streams; migratory spawning is underpowered here |
| What drives site choice | literature | cold water, groundwater upwelling and alluvial (unconfined) reaches, in the Metolius report, Hagen & Sary 2023, the 2015 recovery plan and the 2010 rule. Since #36 these are `groundwater` rows (data rows 675–686, qualitative: no source read so far gives an upwelling measure). Spawning sites at springs and spring-influenced reaches (Metolius), groundwater infiltration in larger streams (Hagen & Weber 2019), hyporheic flow and groundwater influence in site selection (2010 rule). Two incubation rows report higher egg-to-alevin survival in groundwater or upwelling areas; they probably rest on one study (Baxter's thesis and paper), and the rows' notes say so. A third (Pratt 1992) says groundwater may offset fine sediment |

## What a Track 3 result needs to be read correctly

The Williston critical spawning segments probably come from Hagen's aerial and ground redd surveys, which
did not survey streams under 2 m wetted width (Hagen et al. 2015 p. 23; evidence data row 86). That would make
"share of critical spawning below `spawn_channel_width_min`" about 0 by design, and bias the gradient
distribution toward reaches where the bed was visible (data row 79, p. 33: steep, turbulent streams prevented viewing).
State the layer's delineation method beside any number taken from it.

## Gaps, so a person can close them

- **Not acquired:**
  - Baxter & Hauer 2000 (CJFAS, 10.1139/f00-056) and Baxter & McPhail 1999 (Can J Zool, 10.1139/z99-090),
    paywalled; the core papers on spawning-site selection and upwelling;
  - Shepard et al. 1984 (BHL blocks scripted downloads);
  - Fraley & Shepard 1989 (WSU repository, JavaScript download);
  - COSEWIC 2012;
  - Pearce et al. 2019 (in the library, no PDF);
  - Montana FWP redd counts.
- **Other sources not used:** the USFWS critical habitat GIS and state redd layers.
- **Upstream defects found:** FDIS surveys loaded under two collection ids (#35, 2.8 % of visits); FISS
  workbook site gradient read as a fraction (#34).

## Dead ends, kept because they are evidence

- **A transit test** on same-blue-line distance against "other BT visits in the class". The plan review
  showed searches mostly censored, sliver segments common (36 % of visits on segments under 50 m), and
  network position differing between the
  groups. A prototype found no upstream separation. Cut to a descriptive table.
- **Spawner evidence on all BT visits.** That measured who maturity-coded fish: the coded share is 0.27 at
  ≤ 2 % against 0.40–0.45 steeper. Restricted to coded Aug–Oct visits.
- **"Explained by where and how sampling was done."** A first write-up. Review showed coding effort and
  month leave the rise in place, and only the WSG term removes it.
