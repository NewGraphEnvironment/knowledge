# Review round 2: vignettes/chinook_rearing.Rmd (146f799..2f7dbdf)

A copy renders cleanly (`rmarkdown::render` on a scratch copy after `load_all`), and every `stopifnot` passes on
the committed rds. The findings below are about claims. Data was read from `inst/vignette-data/chinook_rearing.rds`
and the rds's sources under `data/tune/grad_ext/`.

## 1. Lines 293 and 304-305: "Steeper limits do not change the choice" / "so the recommended rule keeps 9 %" is still false under the article's own procedure

Line 249 says the choice is fixed: "from the region, the rule closest to `default`". In code that is `.tune_pick`
(R/tune_score.R:260-265): the region rule with the fewest departures, with ties going to the lower score. In the extended run,
all 91 region rules have `departures == 3` (the same situation line 250 describes for the first run), so the pick is
the best scorer. The extended run's own summary records that pick:
`x$grad_ext_summary$rule_pick == rule_recommended == "mad>=0.75|g<=0.15|Q1@D1000"`. So steeper limits **do** change
the choice the fixed procedure makes. The 9 % rule is kept by a decision made after the extended run was seen, not
by the procedure.

"The records cannot rank any limit from 7 % to 30 %, so the recommended rule keeps 9 %" does not follow either. When
the records cannot rank rules, the procedure goes to closeness to `default` and then to score, and that gives 15 %.
If inability to rank were the reason, 7 % (in the extended region, 6 rules, and closer to `default`'s 5.49 %) would
have the same claim as 9 %.

No guard reads `ges$rule_pick`. Adding `identical(ges$rule_pick, ges$rule_recommended)` would fail if the heading
were made true, which shows the heading is backed by nothing. The prose needs to say that the first run's choice is
kept, and why, as a decision. It should not say the choice is unchanged.

## 2. Lines 296-299: the first "check" does not set the 15 % rule apart; it is true of both rules

"Its gap over the recommended rule is 19.7, with a standard error of 22.1, so it is noise." This says the two rules
are tied: the recommended rule is in the extended run's region (`ge_rec$in_region > 0`, guarded at line 54). A tie
does not separate either rule from the other. The same check applied in the first run gives the recommended rule's
own lead the same verdict: its gap over `mad>=0.75|g<=0.07|Q3@D1000` is 1.6 with an SE of 14.2. The lead-in "set it
apart" and the bullet's "so it is noise" contradict each other. The guard `ge_rec$ddev_best < ge_rec$se_diff`
(line 87) proves the tie, not a separation.

## 3. Line 296: "Two of the checks above set it apart" reports the checks against the 15 % rule and leaves out the two that favour it

The extended run also ran the other two checks, and both point toward the steeper limit:

- **Other random splits** (`data/tune/grad_ext/CH_rear_seeds.csv`): every one of the 4 seeds picks a rule at a
  15 % limit. In the first run's seeds, 9 % was picked on 0 of 4 (three picked 7 %, one 5.49 %).
- **Drawing the groups again**: in the extended run's redraws, a 15 % limit is chosen in 43 % of draws and 9 % in
  **0 %**. That figure is already in the vignette data: `x$grad_ext$boot_rec_share` is 0.430 at 0.15 and 0.000 at
  0.09 (and the recommended rule's own `boot_rec_share` in `data/tune/grad_ext/CH_rear_tune.csv` is 0). In the first
  run, 9 % came back in 40.5 % of draws.

So of the four checks, one is a tie (finding 2), one counts against the longer set, and two favour the 15 % limit.
"Two of the checks above set it apart", with the other two left unmentioned, claims more than the data supports.

The one check that does count against it (lines 300-302) tests the choosing procedure on the longer grid, not the
15 % rule. Its fold choices were 11 %, 15 %, 15 %, 30 % and 15 % rules (`data/tune/grad_ext/CH_rear_honest.csv`).
The two 15 % picks that met `default` with the same rule (folds 2 and 5) beat it, and fold 3's 15 % pick lost by
1.3. That is not evidence about the 15 % rule specifically.

Using this check as a veto over the fixed pick was also not fixed before the run, unlike the region rule. This is
the same class as round 1's removed "two standard errors" line: a decision criterion chosen after the result.

## Checked and found sound

- "The records cannot rank any limit from 7 % to 30 %": `ge_reg` is every limit with at least one rule within one SE
  of the extended best. The guard at line 54 checks that the limits from `min(ge_reg)` up are contiguous, and the
  wording matches the article's definition of the region at line 198 ("the rules the records cannot rank"). The
  region is defined against the best rule only, and the article uses that definition throughout.
- Lines 268-270, the new noise bullet: 196.3 / 81.6 = 2.4, and `dflt$ddev_best > dflt$se_diff` backs "outside the
  region". The region in code is `<=` one SE (tune_score.R:255) and the prose says "under". This matters only exactly at the
  boundary and does not apply to any number printed.
- Lines 294-296, "with a smaller river in the exception": `rule_parts` parses correctly, and the guards pin the same
  size variable, floor and D and a smaller Q, so the one-clause description is complete.
- Lines 300-302: `ges$honest_dev_rec > ges$honest_dev_default` and `summ$honest_dev_rec < summ$honest_dev_default`
  back the comparison, and `summ$honest_dev_rec` equals `sum(honest$dev_rec)` (1234.49).
