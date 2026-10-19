# Review: a5142dd, vignettes/chinook_rearing.Rmd (round 1)

The copy renders without error (load_all + rmarkdown::render into the scratchpad). Every rule string in
`x$tune$rule`, `x$grad_ext$best_rule` and `x$seeds$recommended` matches
`^(mad|width)>=[0-9.]+[|]g<=[0-9.]+[|](none|Q[0-9.]+@D[0-9]+)$`, so `rule_parts()` parses all of them. A
`none` exception gives `exc_q = NA`, which makes `ge_best_r$exc_q < rec$exc_q` NA, and `stopifnot` then
fails. That is the safe direction. Values were checked against `inst/vignette-data/chinook_rearing.rds`.

## Findings

- **[severity: bug]** vignettes/chinook_rearing.Rmd:298, 302-303, guard at :88. "It fails every check above"
  does not hold for two of the four checks, and both guards are proxies that the recommended rule passes too.
  - **Seeds.** The check above is "in the region on N seeds" (`main_rec_in_region`). The new bullet reports
    `ges$seeds_same_rec`, which is a different statistic: how many seeds' recommended rule equals the run's
    pick (0322:184). The recommended rule scores the same on that statistic, because `summ$seeds_same_rec`
    is also 0 of 4. The first run's seeds recommend 7 % on three seeds and 5.49 % on the fourth, never the
    recommended rule itself. "0 of 4" therefore cannot mark the steeper rule as failing. The guard
    `ges$seeds_same_rec < ges$seeds_n / 2` would be true of the recommended rule as well.
  - **Redraws.** The guard `ges$boot_rec_share < 0.5` is also true of the recommended rule, which comes back
    in only 22 % of redraws (`rec$boot_rec_share`); the article calls that result "its parts are steadier",
    not a failure. On the parts reading the article itself uses, the steeper limit does as well: 15 % is the
    recommended gradient in 43 % of the extended run's redraws (`sum(x$grad_ext$boot_rec_share[grad_max==0.15])`),
    and 9 % is in 40.5 % of the first run's (`share_of("grad_max", 0.09)`).
  - **What holds.** Only the noise gap (19.7 against an SE of 22.1) and the nested selection (1,389.4 against
    1,347.0) show something the recommended rule does not. The claim needs narrowing to those two, or each
    guard has to compare against the recommended rule's own value on the same statistic.

- **[severity: bug]** vignettes/chinook_rearing.Rmd:295. The heading "Steeper limits give the same answer."
  contradicts the code's own definition of the answer. The extended run recommends
  `mad>=0.75|g<=0.15|Q1@D1000` (`ges$rule_recommended`), a different gradient and a different river size, and
  the guard on line 86 (`identical(ge_best$best_rule, ges$rule_recommended)`) asserts that it differs. The
  passage actually shows that the extra limits cannot be told from 9 %, and that choosing among them does not
  hold up on held-out folds. It does not show that they give the same answer.

- **[severity: bug]** vignettes/chinook_rearing.Rmd:265-272. The new bullet "The gap against its noise",
  with "One over about two is a real difference", sits under "These checks, fixed before the run". The spec
  fixed only the one-SE region (`.tune_sel`: `tot - tot[best] <= se`; `knw_tune_score` roxygen). No
  two-SE criterion appears in `knw_tune_score`, scripts 0297, 0320 or 0322, or #62's and #67's planning
  files. The guard `dflt$ddev_best > 2 * dflt$se_diff` checks a threshold written after the results, so the
  prose misstates it as fixed before the run.

review-vig-round1.md
