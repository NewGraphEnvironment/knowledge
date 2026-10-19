# Review round 4: `git diff 146f799 1d3077e -- vignettes/chinook_rearing.Rmd data-raw/vignette_chinook.R`

Tree at 1d3077e, clean. I checked every value against `inst/vignette-data/chinook_rearing.rds`, `data/tune/grad_ext/*`,
the 0322 logs, `R/tune_score.R` (`.tune_sel`, `.tune_pick`), `R/tune_grid.R` and `scripts/0322-tune-grad-extend.R`.
I evaluated the article's `load` chunk against the inst/ rds in a temp session. Every `stopifnot` passes, and the
printed values are the ones below. `meta$md5` holds all 12 sources, the new `grad_ext/CH_rear_seeds.csv` included,
and each matches the file on disk.

## Findings

### 1. The seeds check cannot catch a seeds table from another run (data-raw/vignette_chinook.R:121). Low-medium
The check compares seed numbers only. Every run takes `seeds_more` from `knw_tune_run`'s formals (55:58), so a table
from any run built on the same spec passes. An example is on disk: the 0322 run on the ladder capped at 15 %
(`scripts/logs/habitat/20261018_tune_grad_extend-to15.txt`, committed as fc2ffc1). Its "more seeds" block has the same
seeds and the same picks, but `region_n` is 82/52/38/48 where the 30 % run has 136/107/73/80. That table would pass
line 121, and the article would print "4 of the 4 other seeds also pick a 15 % limit" under "limits up to 30 %", a
claim about a different ladder. The by_grad/summary pair gets a one-run check at line 126. The seeds file gets none:
not against the summary (`seeds_n`, `seeds_same_rec`), and not against 0322's log. The script never reads 0322's log,
although it checks the main seeds table against 0320's log at lines 109–110. Two fixes, either one:
- Track 0322's log in `src` and run `in_log("more seeds", out$grad_ext_seeds)` against it. This is the only check that
  tells the to-15 table apart.
- At a minimum, add `nrow(seeds) == ges$seeds_n` and `sum(seeds$recommended == ges$rule_recommended) == ges$seeds_same_rec`.
  These alone would still pass the to-15 table, because both runs recommend the same rule.

The md5 tracking is correct: `src <- c(src, f_ge)` at line 129 carries the new file into `meta$md5`.

### 2. The limits bullet drops the only out-of-selection check on steeper limits (vignettes/chinook_rearing.Rmd:524–526). Low
The bullet now reads "Steeper limits ... fit as well or slightly better, so 9 % is one choice among limits from 7 % to
30 % that the records cannot rank". Each limit's figure is its best rule's held-out score, picked out of 559 rules
after the fact. This round removed the clause about what happens when the choice among those limits is itself held
out. The rds shows something stronger than the passage says (line 304–306 says only that they lose to `default`):
`ges$honest_dev_rec` is 1389.4, which is worse than the model with no rule at all (`summ$honest_dev_null` 1382.5;
same folds, since seed 54 and the per-fold `dev_null` in `grad_ext/CH_rear_honest.csv` sum to 1382.516). Neither the
bullet nor the passage mentions this. The bullet's conclusion, that the limits cannot be ranked, still follows from
the region definition, so it is not false. But this is the section users read for caveats, and it now describes
steeper limits by their in-selection fit alone, which tilts the opposite way to earlier rounds. Fix: restore a short
clause, e.g. "though choosing among them on some groups and scoring on others does worse than `default`", guarded by
the existing line 57.

### 3. The 9 % rule's own gap in the extended run is no longer given (Rmd:298–311). Low
The removed paragraph printed the figure the new "gap against its noise" bullet would let a reader interpret: in the
extended run the 9 % rule is 19.7 behind the best, with an SE of 22.1. That is 0.89 SE, just inside the region, and
it is the only 9 % rule in the region (`ge$in_region` 1 at 9 %, against 22 at 15 %). The passage now says only
"every limit tried from 7 % to 30 % has rules in the region", which reads as if 9 % sat as comfortably as any other
limit. That tilts mildly toward the kept value. Fix: one clause, e.g. "the kept rule is `n1(ge_rec$ddev_best)` behind
with a standard error of `n1(ge_rec$se_diff)`", guarded by the existing `ge_rec$in_region > 0`.

### 4. "every species is tuned on one set of gradient limits" is overstated (Rmd:310). Low
`knw_tune_grid()` adds each species' own default to the shared ladder (`grid_grad <- sort(unique(c(grid_grad, g_def)))`).
The tables show it: BT_rear is tuned on 3–10.49 %, ST_rear adds 8.49 %, and CH_rear and CO_rear have only the base
five. The decision's reason holds for the shared ladder, so "one shared ladder of gradient limits" would be accurate.

## Sentence table

Guard key: L = Rmd line of `stopifnot`; DS = data script `stop()`.

| # | Where | Sentence (as rendered) | Verdict | Fails on a rerun that makes it false? |
|---|---|---|---|---|
| A1 | Rmd:268 | A gap in score is a real difference only when it is large against its noise and survives being checked again. | True as the article's stated criterion (not a data claim) | n/a |
| A2 | Rmd:269–270 | These checks, fixed before the run, ask whether the choice rests on chance or on reusing the same data to choose and to score. | True (`knw_tune_score` doc: the spec was fixed for CH before its first fit, the 1-SE region included) | n/a |
| A3 | Rmd:272–273 | Each gap between two rules has a standard error, from how much it varies between watershed groups. | True in kind. The code computes it only for each rule's gap to the best (`.tune_sel`), and the next sentence anchors it to that | n/a |
| A4 | Rmd:273–274 | A gap under one standard error cannot be told from noise: that is the region. | True (`region = tot - tot[best] <= se`) | definitional |
| A5 | Rmd:275 | `default` is 2.4 standard errors worse than the best rule. | True (196.29 / 81.63 = 2.40) | Yes: L90 `dflt$ddev_best > dflt$se_diff`; the number is computed |
| B1 | Rmd:298 | 9 % was the steepest limit in the rules tried. | True (`max(tune$grad_max)`) | computed |
| B2 | Rmd:298–301 | Scored again on the same records with limits up to 30 % among the rules from the start, the same procedure picks 15 %, with a smaller river in the exception: a gradient of at most 15 %, and either a MAD of at least 0.75 m³/s or a river of at least 1 m³/s within 1 km downstream. | True | Yes: DS:125 (same population), DS:122 (the extended ladder holds the main one), L89/L90 (`rule_pick` and `rule_recommended` are the best rule), L92–93 (same size and distance, smaller Q), L53 (best is steeper than rec) |
| B3a | Rmd:301–302 | 4 of the 4 other seeds also pick a 15 % limit | True (every seed's `recommended` is g<=0.15). Their river is Q3 on 3 of 4, but the sentence claims only the limit | Count computed. DS:121 checks the seed numbers only (finding 1). Nothing guards ≥1, but the literal sentence stays true at 0 |
| B3b | Rmd:302–303 | and redraws of the groups choose one in 43 % of draws and 9 % in 0 %. | True (`by_grad$boot_rec_share` = the sum over rules at that limit, 0322:194; the column sums to 1.000) | Computed. L91 (best has the max share, rec below it) goes beyond what the text needs; harmless |
| B4 | Rmd:304–306 | Chosen on four folds and scored on the fifth, the longer list's choices lose to `default` over all five together, 1389.4 against 1347.0, where choices from the rules up to 9 % beat it at 1234.5. | True. It understates: 1389.4 is also worse than the no-rule model's 1382.5 (finding 2) | Yes: L56–57 (same `default` total, both directions) |
| B5 | Rmd:308–309 | Every limit tried from 7 % to 30 % has rules in the region, so the records cannot place the limit in that range. | True. The inference follows from A4. It leaves out the 9 % rule's 0.89 SE margin (finding 3) | Yes: L54 (`ge_rec$in_region > 0`, every limit from `min(ge_reg)` up in the region) |
| B6 | Rmd:309–311 | The recommended rule keeps 9 %, the pick from the rules fixed before the run, because every species is tuned on one set of gradient limits, and a longer set is a change for all of them at once. | "the pick from the rules fixed before the run" is true (`summ$rule_pick` = rec; L54 `identical(ge_rec$best_rule, rec$rule)`). "one set" is overstated (finding 4). The reason is a decision and is presented as one | Partly (L54); the reason itself is not data |
| C | Rmd:343–345 | (paragraph cut to end at) "... each threshold is where habitat and non-habitat separate best on held-out groups, a cut across a slope." | Unchanged sentence; the cut removed text only | n/a |
| D1 | Rmd:524–526 | Steeper limits, scored later up to 30 %, fit as well or slightly better, so 9 % is one choice among limits from 7 % to 30 % that the records cannot rank. | True: every limit above 9 % has ddev 0–15.6 against 19.7 at 9 %, and "slightly" means within 1 SE, implied by the 9 % rule being in the region. It omits contrary evidence (finding 2) | Yes: L55 (as well or better), L54 (region span) |
| E1 | DS:27 | INPUT names `grad_ext/CH_rear_{by_grad,summary,seeds}.csv` | True | n/a |
| E2 | DS:114–120, 129 | Reads the seeds csv into `out$grad_ext_seeds`, and it enters `src`, so `meta$md5` | Correct. Verified in `meta$md5`, and the md5 matches the file on disk | `test-vignette-data.R` fails if the csv moves |
| E3 | DS:121 | Stop if the extended run's seeds differ from the main run's | Weak: it holds for any run on the same spec (finding 1) | Would not stop on the to-15 % run's seeds table |
| E4 | Rmd:53 | Removed `ge_best$grad_max < max(ge$grad_max)` | Correct. No remaining sentence says the best is inside the ladder | n/a |

## Answers
- **An inference the data does not support:** none outright. Every claim is true on the rds and guarded where it
  states a direction. The decision sentence is a policy reason, presented as one, though "one set" is overstated
  (finding 4).
- **Evidence about steeper limits that the rds holds and the passage omits:** two items, pointing opposite ways.
  - The longer list's nested-selection choices do worse than no rule (1389.4 against 1382.5), and the limits bullet
    no longer mentions the nested loss at all (finding 2). The omission favours steeper limits.
  - The 9 % rule sits at 0.89 SE in the extended run, the only 9 % rule in that region (finding 3). The omission
    favours 9 %.
  Neither changes a conclusion the text draws. Both are cheap to restate with the existing guards.
- **Data script:** the md5 tracking is right. `Rscript data-raw/vignette_chinook.R` stops on a seed-number mismatch, a
  different population, or a by_grad/summary split. It would write a seeds table from another run on the same spec
  (finding 1).
