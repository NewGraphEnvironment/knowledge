# Review round 3: vignettes/chinook_rearing.Rmd, 146f799..027ee8f

The vignette renders: a copy knitted under `pkgload::load_all()` into the scratchpad, and every stopifnot passes.
Data read: `inst/vignette-data/chinook_rearing.rds`, `data/tune/grad_ext/CH_rear_{seeds,honest,by_grad,summary}.csv`,
`R/tune_score.R` (pick, bootstrap, nested selection, seeds), `scripts/0322-tune-grad-extend.R` (by_grad).

## The mechanism

The five earlier findings come from one cause. **The prose was written to justify a decision already made (keep 9 %), and
the data was then sorted by which side of that decision it supports.** That is how the earlier errors arose:

- a check's verdict was described as being about whatever the conclusion needed. The nested check tests the
  *choosing procedure on a ladder*, but the prose reads it as a verdict on *steeper limits*.
- quantifiers ("every check", "the same answer", "one check") were counted from the favourable side, never
  enumerated over every check.
- evidence that cuts the other way (seeds, redraws) was left out or played down.
- guards were written for the numbers a sentence prints, not for the inference the sentence draws. They pass
  whenever the arithmetic holds, even when the reading of it is wrong.

Each round fixed the sentence the reviewer named and kept the inference behind it. Three of this round's findings
are that same inference again: the nested check presented as evidence against steeper limits.

## Findings

### F1 (high). The decision's first reason misreads the nested check. Its guard tests a proxy. (L306, also L520-521)

"a steeper choice does not hold up on groups left out of the choice" (L306). The bullet says the same at L520-521:
"choosing among them does not hold up on groups left out of the choice".

How the check works: `knw_tune_score()`'s nested selection (R/tune_score.R:139-147) runs `.tune_pick()` on the other
folds' held-out deviances, over **the whole grid** (all 6,149 rules, gradient limits from 3 % to 30 %), and scores
the one rule it picks on the fold that was left out. So it tests **the procedure of choosing from the longer
ladder**. It does not test steeper limits, and it does not test "choosing among" the steeper limits. The folds and
`dev_default` are identical in the two runs, so the two runs compare fold by fold
(`data/tune/grad_ext/CH_rear_honest.csv` against `x$honest`):

| fold | longer ladder's choice | its deviance | default | the 9 % ladder's choice |
|---|---|---|---|---|
| 1 | mad>=1, 11 %, Q3@D1000 | 299.6 | 238.8 | 201.7 |
| 2 | mad>=0.75, **15 %**, Q1@D1000 | 181.8 | 233.8 | 203.9 |
| 3 | mad>=1, **15 %**, Q1@D2000 | 258.5 | 257.2 | 254.2 |
| 4 | mad>=0.75, 30 %, Q3@D1000 | 333.9 | 230.3 | 233.9 |
| 5 | mad>=0.2, **15 %**, Q1@D1000 | 315.6 | 386.9 | 340.8 |

- On the three folds where the procedure chose 15 %, its choices **beat** `default` (755.9 against 877.9) **and**
  beat the 9 % ladder's choices (798.9). They win outright on 2 folds and lose on fold 3 by 1.3.
- The net loss of 42.4 comes from the folds where the choice was 11 % with a 1 m³/s floor (+60.8) and 30 %
  (+103.6). Fold 4 alone loses by more than the whole net loss.

What the data shows is that **choosing from the longer ladder is unstable**: five folds picked four different gradients
and four different size floors. It does not show that a steeper limit fails on groups the choice has not seen. For the
limit the procedure actually picks, the data points the other way.

The guard, `ges$honest_dev_rec > ges$honest_dev_default` (L57), tests the five-fold sum. That sum is the procedure's
result, so the guard fits the L299-302 sentence ("choices from the longer set lose to default"), which is correct.
It is only a proxy for the L306 and L520 claims about steeper choices: it passes on today's data, where those claims
are already contradicted by the 15 % folds.

Rewording that fits the data: "choosing from the longer ladder does not hold up on groups left out of the choice:
its five folds chose four different limits, and the two folds that chose 11 % and 30 % lost to default."

### F2 (medium). "One check goes against the steeper limits" (L299) is an uncomputed count. It names the wrong subject and leaves out the seeds.

- **The count has no source.** "One" is a number in prose, but nothing in the rds can produce it. `x$seeds` is the
  main run's table; the longer run's seeds (`data/tune/grad_ext/CH_rear_seeds.csv`) were never written into
  `chinook_rearing.rds`. No guard backs it either: if a rerun's seeds went to 9 %, the sentence would still print.
- **Enumerated, checking each against the steeper limits:**

  | check | verdict |
  |---|---|
  | gap against noise | neutral: the 9 % rule is 19.7 behind with an SE of 22.1, so in the region |
  | seeds | **for**: all 4 pick a 15 % limit |
  | redraws | **for**: 15 % in 43 % of draws, 9 % in 0 % |
  | nested selection | against **the procedure**, not the limits (F1) |

  So "one against" holds only in the literal sense, and the one check it names is the one check that does not test
  the limits.
- **Finding (5) is half closed.** The passage now gives the redraws but never mentions seeds, although the article
  treats seeds as a check fixed before the run (L272-276). The seeds also bear on the passage's own detail, "with a
  smaller river in the exception" (L296). The longer run's exact pick (Q1) comes back on **0 of 4** seeds
  (`seeds_same_rec = 0`). **3 of 4** seeds keep the 9 % rule's 3 m³/s river at 15 % (`mad>=0.75|g<=0.15|Q3@D1000`
  on seeds 55 and 57, `Q3@D2000` on seed 58). The exact rule's redraw share is 11.5 % (`ges$boot_rec_share`),
  against 22 % for the 9 % rule.

  So the stable part of the steeper result is the 15 % limit, not the smaller river. The passage reports the river,
  the unstable part, and omits what shows it unstable.

### F3 (medium). "keeps 9 % by decision, not because the procedure picks it" (L305-306) contradicts L250-252

L250-252 says "The choice was fixed before any rule was scored ... so the best scorer is recommended". On the ladder
fixed before the run, the procedure **does** pick 9 % (`summ$rule_pick`). What was decided is to stay on the shared
ladder rather than adopt the longer run's result.

As written, a reader is told first that the rule came from a pre-set procedure, then that it did not. The guards
(`identical(ges$rule_pick, ge_best$best_rule)`, `ge_best$grad_max > rec$grad_max`) establish that the *longer* ladder
picks 15 %, which is true. They do not establish the sentence's claim about where the recommended rule came from.

A fix: "keeps 9 %, the procedure's pick on the shared ladder, by deciding not to adopt the longer ladder's pick".

### F4 (low). "A gap under one standard error is noise" (L270) claims more than the region rule

The region is the rules the records cannot tell apart from the best (L198-199: "the rules the records cannot rank").
A gap under one SE can be real; the data does not show it is noise. The same overstatement was behind round 1's
item (4).

"cannot be told from noise" keeps the bullet true. The guard `dflt$ddev_best > dflt$se_diff` fits the default
sentence and has no bearing on this one.

### F5 (low). "Every limit from 7 % to 30 % has rules in the region" (L304) reads as a continuous range

The limits tried between those two are 7, 9, 11, 13, 15, 20, 25 and 30 %. The guard at L54 checks those eight
only. "Every limit tried from 7 % to 30 %" matches what was measured.

Also worth knowing: 9 % has 1 rule of 559 in the region (the recommended rule itself), against 22 at 15 %. That fits
"cannot place". It is thin, and the sentence does not need to say so.

## Enumeration: every new or changed sentence the mechanism could reach

| line | sentence (short) | against the data | guard tests the claim? |
|---|---|---|---|
| 265 | "A gap ... is a real difference only when it is large against its noise and survives being checked again" | a general principle, applied consistently: the 15 %/9 % gap fails it | n/a |
| 266 | the gap check is among "These checks, fixed before the run" | true: the 1-SE region comes from 0297's spec, fixed before the first fit (R/tune_score.R:2-3, 15-17) | n/a |
| 269-270 | "Each gap ... has a standard error, from how much it varies between watershed groups" | true: sqrt(n groups) × sd of the per-group differences | n/a |
| 270 | "A gap under one standard error is noise" | **overstated (F4)** | no guard |
| 271 | "`default` is 2.4 standard errors worse" | true (196.3 / 81.6) | yes: `dflt$ddev_best > dflt$se_diff` fails if it is under 1 |
| 294 | "9 % was the steepest limit in the rules tried" | true | computed inline |
| 294-297 | "the same procedure picks 15 %, with a smaller river in the exception: ..." | true of the main seed. The river is the unstable part: 0/4 seeds give the exact rule, 3/4 keep 3 m³/s (F2) | yes, as written: `rule_pick == ge_best`, `exc_q <`, size and distance equal |
| 297-298 | "Redraws ... choose a 15 % limit in 43 % of draws and 9 % in 0 %" | true. `boot_rec_share` in by_grad is the sum over rules at each gradient of the share of the 200 draws whose recommended rule (the full `.tune_pick`, `d_floor` included, region recomputed per draw) has that gradient; the column sums to 1. 43 % is a plurality, not a majority (30 % gets 17.5 %, 11 % gets 17 %), and the sentence does not claim one | yes: `ge_best == max`, `ge_rec < ge_best` |
| 299 | "One check goes against the steeper limits" | **uncomputed count; names a check that tests the procedure; seeds omitted (F2)** | no guard can fire: the seeds are not in the rds |
| 299-302 | "choices from the longer set lose to `default`, 1,389.4 against 1,347.0, where ... up to 9 % beat it at 1,234.5" | true | yes: L56-57 |
| 304-305 | "Every limit from 7 % to 30 % has rules in the region" | true for the 8 limits tried; the wording suggests a continuous range (F5) | yes, for the tried limits (L54) |
| 305 | "so the records cannot place the limit within that range" | true by the region's definition | follows from L54 |
| 305-306 | "keeps 9 % by decision, not because the procedure picks it" | **contradicts L250-252 (F3)** | tests the longer ladder's pick, not the provenance claim |
| 306 | reason 1: "a steeper choice does not hold up on groups left out of the choice" | **wrong: the 15 % choices held up; the loss is from the 11 % and 30 % choices (F1)** | proxy: the five-fold sum |
| 306-307 | reason 2: "every species is tuned on one set of gradient limits" | true (`knw_tune_grid()`; 0322's header, plan gate 2026-10-18) | policy, nothing to compute |
| 520-521 | "Steeper limits ... fit as well or slightly better" | true: every limit above 9 % has a best ≤ 19.7, and 9 % stays within 1 SE | yes: L55 plus `ge_rec$in_region > 0` |
| 520-521 | "though choosing among them does not hold up on groups left out of the choice" | **wrong twice (F1)**: the nested check chose among the whole 3-30 % grid, not among the steeper limits, and its 15 % choices held up | proxy |
| 522 | "so 9 % is one choice among limits from 7 % to 30 %" | true, and consistent with L304-307. Unlike the new passage, it does not say the procedure picks 15 % | yes (L54) |

## Notes, not findings

- **L53, `ge_best$grad_max < max(ge$grad_max)`.** No sentence states this premise any more; the old "the best is
  not at the ladder's top" prose was removed. It cannot let a false sentence through, but it could stop a rerun
  whose prose would still be true.
- **L119, "The records support a different rule from `default`: 9 % ...".** This is outside the diff. It is true if
  "support" means "in the region of both runs". With F3 fixed it reads better beside L305.
