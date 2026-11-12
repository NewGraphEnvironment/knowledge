# How the tuning method stands against Bayesian practice

**Verified:** 2026-11-12 · **Issues:** #185 (this review); the store is #95's; it scopes #186 (a partially pooled
curve) and feeds the methodology article (#93) · **Produced by:** the code at this commit, read line by line; the
`statistics` store (McElreath 2020 and Gelman et al. 2013, searched through cred); every quoted page checked by
`data-raw/bayesian_alignment_check.R` (log `scripts/logs/habitat/*_bayesian_alignment_check.txt`) · **Status:**
review complete; the changes it recommends are filed as issues (end of file).

The two books are McElreath, *Statistical Rethinking*, 2nd ed. (2020; "Rethinking") and Gelman et al., *Bayesian
Data Analysis*, 3rd ed. (2013; "BDA3"). Pages are the printed ones. Quotes are short and only where a passage decides
a row.

## In brief

**What the tuning does.** For each species and stage it builds a grid of rules (a size floor, a gradient maximum and
an exception near a river), asks of every rule whether a visit was "in" or "out", and scores how well that in/out
predicts where fish were caught in watershed groups held out of the fit. The rules close to the best form a region;
the pick is the region rule closest to link's `default`. Then one smooth curve of use on size, distance to a river and
gradient is fitted, and every segment is graded by it, unless the curve predicts held-out groups no better than no
rule at all.

**What was asked.** Where does each step and setting sit against Bayesian practice as these two books teach it:
aligned, a defensible difference, or something to change?

**How it was judged.** Each statement about the method was read from the code (file and line), not from the
article. Each statement about the books was found through the store and read on its page.

**What stands.** The core of the method is what Rethinking's chapter 7 asks for: rules are compared by how well they
predict data they were not fitted to, with whole watershed groups held out, the standard error taken from the
difference between two rules rather than from each alone, and the near-ties kept together as a region beside the
pick. The prior on the sampling terms is a regularising prior in Rethinking's sense, at BDA3's default scale.
The curve already pools watershed groups as a random effect.

**Where it differs, and why that is defensible.** The scorer gives each watershed group a fixed intercept, refitted
for a held-out group on that group's own visits. So the score asks "within a group, does the rule put fish where they
were caught?", not "how many fish will a new group hold?". That is the right question for a rule that ranks streams,
and it is a different question from the one a multilevel model answers for a new group. The prior is a penalty that
finds one best value, not a posterior, and the thresholds are reported as a pick and a range, not as a distribution.

**What to change.** Three things: the curve treats a sampling level unseen in training differently from the scorer
(the scorer meets one such visit, in westslope cutthroat rearing; the curve's own count is not recorded); the
"nested" selection check is not nested; and the rules read a gradient that depends on where fish were caught (#70
already holds the fix). Neither of the first two moves a published pick: the curve sets no pick, and the nested check
is a diagnostic. A guard would also make sure the scorer never drops its prior, which today rests on an argument. And one experiment the review sharpens: #186's pooled curve, which must be scored both ways, by its
own group intercept and as a new group, and which can use the watershed groups the scorer drops for holding only one
outcome (66 of the 111 groups chinook rearing's visits fall in).

**What this is not.** A refit of anything, or a verdict that the method is wrong. Rethinking names occupancy models
(p. 499) without teaching them, and the smoothing penalty's scale is mgcv's; MacKenzie et al. and Wood are not in the
store, so those rows say what the two books say and stop.

## The questions, one at a time

Each subsection teaches the principle first, then says what the method does and where the books stand.

### Is the score an honest out-of-sample test? (Rethinking ch. 7, 13; BDA3 ch. 7)

*The principle.* A model judged on the data it was fitted to always looks better than it is; the honest test is data
it has not seen. Rethinking scores that by the log-pointwise-predictive-density, averaged over the posterior:

> "The Bayesian version of the log-probability score is called the log-pointwise-predictive-density." (mcelreath2020StatisticalRethinking, p. 210)

With clustered data the question splits in two, and the book is explicit that they are different tasks:

> "If we wish to validate a model against the specific clusters used to fit the model, that is one thing. But if we instead wish to compute predictions for new clusters, other than the ones observed in the sample, that is quite another." (mcelreath2020StatisticalRethinking, p. 426)

*What the method does.* Each fold of whole watershed groups is held out (`.tune_fold_setup`,
`R/tune_score.R:217`); the rule, effort, data-set and era coefficients come from the other folds; then each held-out
group refits its own intercept on its own visits (`.tune_group_dev`, `R/tune_score.R:408`, called at :280), and the
score is the summed binomial deviance at that point estimate, clamped at p = 10⁻¹² (`R/tune_score.R:410`). The curve
is scored the same way (`R/tune_curve.R:143-148`).

*Where it stands.* Holding out whole groups from the fit is the strict form, the one Rethinking describes for new
clusters ("imagine leaving out one of the clusters", p. 428); but the book then predicts the left-out cluster from the
population, which the scorer does not. Two things differ. The score is a plug-in, a deviance at one estimate,
where lppd averages over the posterior; BDA3 notes that AIC and DIC score the plug-in density while Bayesian
prediction uses the posterior predictive (p. 174). And because a held-out group's intercept is fitted on the outcomes
being scored, the score is conditional on that group's base rate: it measures how well a rule ranks visits within a
group, and is optimistic by about one fitted parameter per group. That optimism is about the same for every rule
(derived here; BDA3 notes that the effective number of parameters itself varies with the data, p. 174), so
comparisons between rules hold; the absolute score does not mean "prediction for a new group". **Differs, defensibly**: a rule's
job is to rank streams, and a group's base rate (how abundant the species is there) is not the rule's to predict.

### Is the region a comparison or a selection? (Rethinking ch. 7; BDA3 ch. 7)

*The principle.* Two scores are told apart by the uncertainty of their difference, not of each:

> "we don’t use their standard errors but rather the standard error of their difference." (mcelreath2020StatisticalRethinking, p. 227)

and picking the single lowest score throws away what the differences say:

> "This kind of selection procedure discards the information about relative model accuracy contained in the differences among the CV/PSIS/WAIC values." (mcelreath2020StatisticalRethinking, p. 225)

*What the method does.* The SE of each rule's difference from the best is √(groups) × the sd of the per-group
differences (`R/tune_score.R:451`), the book's `sqrt(n*var(diff))` (p. 228) with the group, the unit of
independence, in place of the observation. Every rule within one SE of the best is in the region; the pick is the
region rule with the fewest departures from `default` (`R/tune_score.R:458`). The published table carries the region's
range beside the pick, and a 1.96 reading (`knw_tune_repick`), which widens the region and moves the pick toward
`default`.

*Where it stands.* The SE of a difference is **aligned** (pp. 227-228), though the book warns that these standard
errors understate the uncertainty in small samples (p. 227, said of each score's SE), and the thinnest keys have 6 and
11 groups. The region's width of one SE is a
convention neither book sets: the code calls it a parsimony rule fixed before the run (`R/tune_repick.R:7-8`). It
keeps the near-ties in view, closer to what p. 225 asks than a single winner, though it reduces each difference to in
or out and still names one pick. The pick inside the region is a
choice the scores do not make: a preference for link's rule, a prior in decision form whose pull is measured by `research/baseline_anchoring.md`
(#141). That is honest when stated as a decision, which the article does ("the one that changes link's current rule least"). Choosing among thousands of rules also
biases the winner's score:

> "when these methods are used to choose a model selection, the predictive performance estimate of the selected model is biased due to the selection process." (gelman_etal2013Bayesiandata, p. 182)

The nested check (`honest`) was meant to measure that bias, and is not nested: fold *k*'s pick is chosen from the other
folds' scores, but those scores came from fits that trained on fold *k* (`R/tune_score.R:178-185`). BDA3 names the
remedy, "another level of cross-validation" (p. 182). **Should change**: nest it (refit without fold *k*), or describe
it as what it is. Either way only the check moves, not the pick, the curve or the grades. The bootstrap (`R/tune_score.R:160-177`) resamples
groups of the fixed scores and refits nothing, so it measures how stable the choice is given the scores, not
uncertainty in the estimates (**differs**; the article's "checking the choice is not luck" is the right reading).

### Is the prior a prior? (Rethinking ch. 4, 7, 11; BDA3 ch. 13, 16)

*The principle.* A regularising prior is a sceptical one:

> "By “skeptical,” I mean a prior that slows the rate of learning from the sample." (mcelreath2020StatisticalRethinking, p. 214)

Fitted as a penalty, it gives the posterior mode and nothing more:

> "Ridge regression does not compute a posterior distribution." (mcelreath2020StatisticalRethinking, p. 216)

> "the posterior mode is often used in statistical practice as a point estimate, sometimes in the guise of a penalized likelihood estimate" (gelman_etal2013Bayesiandata, p. 311)

*What the method does.* The data-set and era coefficients carry a normal prior, SD 2.5 on the cloglog scale, as a
ridge inside the scorer's IRLS (`R/tune_score.R:245`, :265) and as a fixed `paraPen` penalty in the curve
(`R/tune_curve.R:97-105`). The rule, effort and group terms carry none. The scorer keeps a fallback to
`stats::glm.fit`, which takes no prior, for a fold where the absorbed fit drops a column the dense fit would keep
(`R/tune_score.R:267-270`, :384-390); under the prior a data-set or era column is never dropped, because the ridge
gives it a pseudo-row of its own (`R/tune_score.R:308`, :340-343), and the rule column is excluded from the test
(:384), so the fallback can only be reached through an unpenalised
column aliased with the groups, which `log(area)` would have to be.

*Where it stands.* **Aligned** in purpose: without it, separated levels ran to hazard ratios past a hundred million
(#84), the instability BDA3 calls common and often mishandled:

> "Separation is surprisingly common in applied logistic regression, especially with binary predictors, and in practical work is often handled inappropriately." (gelman_etal2013Bayesiandata, p. 412)

BDA3's default is scale 2.5 (p. 416), a Cauchy on the logit scale, with binary inputs put on this footing first:

> "Binary inputs are shifted to have a mean of 0 and to differ by 1 in their lower and upper conditions." (gelman_etal2013Bayesiandata, p. 415)

Our data-set and era dummies differ by 1, so the scale per unit matches for each dummy against its reference level
(era has three levels, so the two later eras differ from each other with prior SD 2.5·√2); centring them would move
only the intercept, which the group intercepts absorb. What differs is the family (a normal, with lighter tails than
the Cauchy), the link (cloglog, not logit) and the scope: BDA3 puts its default on every coefficient but the constant
(p. 416), the method on the sampling terms only. A prior
on a link scale is best checked by simulating what it implies on the outcome scale, since

> "A flat prior in the logit space is not a flat prior in the outcome probability space." (mcelreath2020StatisticalRethinking, p. 328)

and no such check was run (#186 is where priors are being set, and takes it). The fallback that would drop the prior
is out of reach of the penalised terms; a guard that stops a run if it ever fires under a finite prior would make that
a check rather than an argument (ISSUE_A).

### Fixed or pooled groups? (Rethinking ch. 13; BDA3 ch. 5, 15)

*The principle.* A fixed intercept per group is a group effect with no shared prior:

> "The first J1 components, which are implicitly modeled as exchangeable with infinite prior variance, are sometimes called fixed effects." (gelman_etal2013Bayesiandata, p. 383)

Rethinking calls such models amnesiac: what is learned about one group informs no other (p. 399). Pooling helps most
where a group has little data:

> "Smaller ponds produce more error, but the partial pooling estimates are better on average, especially in smaller ponds." (mcelreath2020StatisticalRethinking, p. 413)

*What the method does.* The scorer, the smoke run and the gate's no-rule baseline absorb a fixed intercept per group
(`.tune_glm_fe`, #83). Because a fixed intercept for a group whose visits all caught fish, or none did, runs to
infinity and informs nothing, those groups are dropped first (`.tune_modelled`, `R/tune_score.R:201`): chinook
rearing keeps 45 of the 111 groups its visits fall in, steelhead rearing 11 of 78, westslope cutthroat rearing 6 of 14
(each key's `groups` and `groups_both`, `data/tune/<key>_summary.csv`). The curve does pool: it fits the group as a
random effect by REML (`s(wsg, bs = "re")`, `R/tune_curve.R:104`), but on the same reduced set of groups, and scores
a held-out group by its own refit intercept, so the pooled distribution never predicts a group.

*Where it stands.* **Differs.** For scoring thousands of rules the fixed intercept is cheap and answers the
within-group question above. The cost is that the dropped groups, most groups for the thinnest keys, inform nothing,
where under pooling an all-empty group still says something about how often the species is found. #186 tests a pooled
curve; this review sets its terms (end of file).

### What does the grade predict, and for which group? (Rethinking ch. 13)

*The principle.* A multilevel model predicts for "an average cluster" (the random effect at its mean) or "marginal of
cluster" (averaged over the spread of clusters), and the book says to choose by the question:

> "The predictions that are marginal of actor illustrate how variable different chimpanzees are, according to the model." (mcelreath2020StatisticalRethinking, p. 429)

*What the method does.* The grade predicts each segment's rate with the group effect left out (`exclude = "s(wsg)"`,
`R/grade.R:64`), at the median effort and the commonest data set and latest era (`R/tune_curve.R:114`), and divides
by the 95th percentile of accessible segments' rates.

*Where it stands.* **Aligned**: the average group is the right reading for a map that compares segments across
groups. Where rates are low a cloglog rate scales with the group effect, so the ratio to the reference depends little
on which group is predicted; where rates are high it depends more. What no score has tested is the between-group part: every score refits the group's base rate,
so how well the grade compares a segment in one group with a segment in another is unmeasured.

### Is the gate a fair comparison? (Rethinking ch. 7; BDA3 ch. 7)

*What the method does.* A curve's grades are withheld when its held-out deviance is no better than the no-rule
model's on the same visits and folds (`cv$heldout >= null_heldout_curve`, `R/tune_run.R:292`). It is a point
comparison: no SE, a tie withholds. The curve's variables (the size measure, the river size of its distance) come
from the pick, which was chosen on the same folds that then score the curve.

*Where it stands.* **Differs.** Comparing held-out deviances is ch. 7's comparison, and the curve's smooths are
penalised, which is a prior on their wiggliness: BDA3's "Bayesian penalized (P) splines" (p. 490), and the same idea
with a fixed ridge on the weights in Rethinking (p. 118). So a gate on held-out deviance is not double-counting
complexity. Two things lean toward publishing: the curve's variables were chosen on the folds that score it (BDA3
p. 182, above), and, compared with a test that asks for a margin, a point comparison publishes on any improvement. Today it withholds three keys of seven (bull trout spawning, coho rearing,
westslope cutthroat rearing).

### Effort: offset or covariate? (Rethinking ch. 11)

*The principle.* Exposure enters a rate model as the log of the exposure with its coefficient fixed at one, and a
free coefficient is a hypothesis in its own right:

> "You can also put a parameter in front of log τi , which is one way to model the hypothesis that the rate is not constant with time." (mcelreath2020StatisticalRethinking, p. 357)

*What the method does.* `log(area)` enters the scorer and the curve as a free coefficient (`R/tune_score.R:224`;
`R/tune_curve.R:86`), unpenalised.

*Where it stands.* **Differs, defensibly.** The book's exposure is for a Poisson model with a log link; for a binary
"caught or not" with a cloglog link, a coefficient of one on log(area) is the model in which each square metre fished
carries the same chance of a catch (derived here; neither book states it for cloglog). A free coefficient lets
detection saturate with effort, which electrofishing plausibly does. Testing the offset is cheap, and is worth one
line in #186.

### Is "no fish caught" an absence? (Rethinking ch. 12, 15)

*The principle.* Rethinking puts it in ecology's own terms:

> "In ecology, the absence of an observation of a species is a subtle kind of observation. It could mean the species isn’t there." (mcelreath2020StatisticalRethinking, p. 499)

Or it is there and was missed; zero-inflated models (p. 376) and occupancy models are built for that duality.

*What the method does.* The response is whether the species was caught at the visit (`d$U <- as.integer(d$present)`,
`R/tune_run.R:176`), and the grade says what it is: expected use per standard electrofishing visit, not habitat
quality (`R/grade.R:9`).

*Where it stands.* **Differs**, honestly labelled. Read as detection per visit, the model is what it says; read as
presence, it conflates a species absent with a species missed. Separating them needs repeat visits and an occupancy
model, which Rethinking names (p. 499) and does not teach; MacKenzie et al. is not in the store. `data/fdis_repeat_surveys.csv` lists duplicate
loads of one survey, not repeat visits; whether the record holds true repeats is not measured here.

### What causes what? (Rethinking ch. 5–6; BDA3 ch. 8)

*The principle.* Which variables belong in a model is a causal question that a predictive score cannot settle:

> "It means that WAIC cannot be used to infer causation." (mcelreath2020StatisticalRethinking, p. 228)

and how the data were collected belongs in the model unless the design makes it ignorable (BDA3 ch. 8, p. 198).

*What the method does, as a DAG in words.* The habitat a segment offers (size, slope, distance to a river) affects
whether fish use it. Crews chose where to fish, by era and data set, and that choice affects both which habitats were
sampled and how hard: the method adjusts for era and data set as nuisance terms, the right move for a confound
(Rethinking ch. 6, p. 183). Three arrows run the other way, from the outcome into the inputs: link codes `access_bt = 2`
when a bull trout record sits upstream (the method keeps such segments but never uses the code as a predictor, which
is the right move); link cuts segments at fish records, so a visit that caught fish sits on a shorter segment whose
gradient depends on that catch (`gradient_col`: **should change**, #70); and one exclusion turns on the outcome: a
visit whose catch blocks the species' absence (`status == "blocked"`, `R/fdis_species.R`) is left out
(`R/tune_run.R:173`), and only a visit that did not catch the species can be blocked, so the gate drops some zeros and
no ones. A blocked absence is a missing outcome, and dropping it is complete-case analysis:

> "Complete case analysis is at best inefficient. It throws away data. But it can also produce bias, depending upon the causal details." (mcelreath2020StatisticalRethinking, p. 499)

Dropping zeros at random would only move each group's intercept; but the blocking codes are related species caught in
the same water, whose catch tracks habitat, which is selection on the outcome and on something tied to the
predictors at once, the mechanism of Rethinking's selection-distortion effect (p. 161). The access gate does not turn
on the catch: it reads natural barriers as they stood before link's observation overrides (`R/tune_run.R:174`,
`R/link_barrier_dnstr.R`). Nor does the range: link's range is a fixed table per watershed group
(`wsg_species_presence`, read by `scripts/0310-evidence-build.R`), so the visits do not set it. Under fixed intercepts
it decides which groups are compared, not the comparison within a group, and an out-of-range group is usually one
with no catch, which `.tune_modelled` drops anyway; where one held a catch, that group never reaches the comparison.

### Are the inputs measured? (Rethinking ch. 15)

Every input the rules read is itself an estimate: a visit's placement on a stream, the segment's gradient, a modelled
flow, a width model, a walk capped at 50 km. Rethinking's chapter 15 carries such error into the model:

> "Each observed predictor value is a draw from a distribution with an unknown mean, the true value, but known standard deviation." (mcelreath2020StatisticalRethinking, p. 495)

The method instead drops the worst cases (snap limits, `d_floor`) and carries the rest as exact. **Differs**; for most
inputs the error's size is not known per visit, which is what the book's approach needs.

## The steps

One row per step of `inst/method/pipeline.csv`. A step's verdict is its overall reading; a part that should change
is named in its text, and its settings and unkeyed choices carry their own verdicts below.

| step | what it does | against the books | verdict |
|---|---|---|---|
| 1 | The fish records | Reads the export and keeps one copy of a survey loaded twice: data, not inference. | no bearing |
| 2 | Putting sites on the stream map | A visit's placement is an estimate carried as exact; the snap limits drop the worst (Rethinking ch. 15). | differs |
| 3 | link's stream segments | link cuts segments at the fish records of the species it models, so a segment's length and gradient depend on the outcome (an arrow from outcome to predictor; Rethinking ch. 6). | differs |
| 4 | How much water each stream carries | A modelled flow read as measured (Rethinking ch. 15). | differs |
| 5 | Joining each site to its segment | Joins the inputs and each species' presence where link expects it. Access reads barriers before observation overrides and range is link's table per group, so neither is decided by the visit's catch; an absence blocked by another code is dropped, which removes zeros only, complete-case analysis (Rethinking p. 499). | differs |
| 6 | Candidate rules | A set of candidate models compared out of sample, as Rethinking ch. 7 asks; the larger the set, the more the winner's score flatters it (BDA3 p. 182), and the region is anchored on that score, so it carries the bias too; the nested check that would measure it is not nested (step 8). | aligned |
| 7 | Scoring and choosing | Whole groups held out and the SE of a difference taken over groups (aligned); a plug-in deviance with each held-out group's intercept refit on its own outcomes, fixed group intercepts, a one-SE width, and a pick by nearness to `default` inside the region (differs, each defensible); the gradient the rules read should change (`gradient_col`, #70). | differs |
| 8 | Checking the choice is not luck | Other fold seeds (aligned); a bootstrap of fixed scores, which measures stability, not estimation uncertainty (differs); and a nested check that is not nested (should change, `honest_nesting`). | differs |
| 9 | A curve and a grade | Groups pooled as a REML random effect and smooths penalised (aligned), graded at the average group (aligned); scored by refit intercepts on an outcome-selected set of groups, and gated by a point comparison on the folds that chose its variables (differs); an unseen sampling level handled unlike the scorer (should change, `curve_unseen_mode`). | differs |
| 10 | Running the rule on link's streams | Regenerates link's flags under each rule: no inference, apart from the lift's bootstrap of placed record locations (`cmp_n_boot`). | no bearing |
| 11 | Publishing | Publishes a pick, its region's range and a 1.96 reading, not a distribution of thresholds (Rethinking ch. 3's summaries of a posterior). | differs |

## The settings

One row per key of `inst/method/settings.csv`. `no bearing` means no statistical choice turns on the value.

| key | step | value | against the books | verdict |
|---|---|---|---|---|
| `sentinel_min` | 1 | 9999 | A data-cleaning code: FDIS's no-value marker read as missing. | no bearing |
| `junk_year_min` | 1 | 1950 | Which visits are in the record at all; no estimate turns on it beyond the era term. | no bearing |
| `junk_year_max` | 1 | 2022 | As `junk_year_min`. | no bearing |
| `snap_search` | 2 | 500 m | A search radius; the two limits below decide which placements are kept. | no bearing |
| `snap_limit` | 2 | 200 m | A visit snapped further than this from an unconfirmed stream is dropped, and one kept is placed as if exactly. Placement is measurement error in every predictor the visit reads (Rethinking ch. 15, p. 495); the method drops the worst cases and carries the rest as exact. Its sensitivity was measured (#91). | differs |
| `snap_limit_code` | 2 | 500 m | As `snap_limit`, for a pick on a stream the 1:50k code names. | differs |
| `snap_edges_excluded` | 2 | 6010 edge type | Which Atlas lines a visit may land on: topology, not a statistical choice. | no bearing |
| `ws50_code_length` | 2 | 45 characters | A format check on the 1:50k code. | no bearing |
| `ws50_code_zeros` | 2 | 42 characters | A format check on the 1:50k code. | no bearing |
| `flow_far_low` | 4 | 0.2 ratio | Which modelled flow a segment carries. The flow is an estimate read as if measured: predictor measurement error (Rethinking ch. 15), never carried into the fit. | differs |
| `cw_agree_min` | 5 | 0.9 share | A control on the width model, not an input to any fit. | no bearing |
| `flow_parent_edges` | 5 | 1100; 1150; 1300; 1350; 2300 FWA edge type | Topology of the parent-flow fallback (11 visits). | no bearing |
| `regulated_edges` | 5 | 1100; 1150; 1300; 1350; 2300 FWA edge type | Topology of a dam's regulated reach. | no bearing |
| `walk_q` | 5 | 1; 3; 5; 10; 20; 30; 50 m3/s | The river sizes a walk is measured to; each is a candidate in the grid and scored out of sample. | no bearing |
| `place_window` | 5 | 5 m | How a visit is matched to its segment's start. | no bearing |
| `place_overlap` | 5 | 0.01 m | A geometric tolerance at segment breaks. | no bearing |
| `wetland_ha_min` | 5 | 1 ha | Defines which lines are a wetland branch, outside the stream population scored. | no bearing |
| `lake_ha_min` | 5 | 100 ha | Defines which lines are a lake branch, outside the stream population scored. | no bearing |
| `dam_snap` | 5 | 500 m | Matches dams to segments. | no bearing |
| `regulation_min` | 5 | 10 % | Which dams count as regulating. | no bearing |
| `barrier_natural` | 5 | GRADIENT; FALLS; SUBSURFACE_FLOW; USER_DEFINITE | Which natural barriers block access, read before link's observation overrides so fish records do not decide access, and so which visits are in the population (`population_gate`). | no bearing |
| `walk_nontarget_edges` | 5 | 1100; 1150; 1300; 1350; 2300; 1400; 1450 FWA edge type | Where a walk may end (the bank rule, #73). | no bearing |
| `walk_hops` | 5 | 60 hops | When a walk stops; a stopped walk reads the cap (`dist_cap`). | no bearing |
| `grid_mad` | 6 | 0.1; 0.15; 0.2; 0.28; 0.35; 0.5; 0.75; 1 m3/s | The flow floors compared. A grid of candidate rules scored out of sample is the model set Rethinking ch. 7 compares; the range was not varied. | aligned |
| `grid_width` | 6 | 1; 1.5; 2; 3; 4 m | As `grid_mad`, for width floors. | aligned |
| `grid_grad` | 6 | 0.03; 0.04; 0.0549; 0.07; 0.09; 0.11; 0.13; 0.15; 0.2; 0.25; 0.3 m/m | As `grid_mad`, for gradient maxima; the ladder's top was tested (#67). | aligned |
| `grid_q` | 6 | 1; 3; 5; 10; 20; 30; 50 m3/s | As `grid_mad`, for the near-river exception's river sizes. | aligned |
| `grid_d` | 6 | 100; 250; 500; 1000; 2000; 5000 m | As `grid_mad`, for the exception's distances. | aligned |
| `edge_stream` | 7 | 1000; 1100; 2000; 2300 FWA edge type | Which branch is scored; rivers, wetlands and lakes are scoped out, not modelled. | no bearing |
| `area_range` | 7 | 10; 10000 m2 | Trims fished areas outside 10 to 10,000 m²; with `log_area` free (`log_area_free`) it bounds the range the effort slope is fitted on. | no bearing |
| `cmp_area_min` | 10 | 10 m2 | The comparison's restatement of `area_range`. | no bearing |
| `cmp_area_max` | 10 | 10000 m2 | As `cmp_area_min`. | no bearing |
| `gradient_col` | 7 | segment_gradient | The rules read link's segment gradient, and link cuts segments at the fish records of the species it models, so the segment, and its gradient, depend on the outcome: a predictor partly caused by the outcome, which a DAG of the evidence (Rethinking ch. 6, p. 185) draws as an arrow from outcome to predictor. The method measures it (#92, #149) and scores setups on other gradients (#120); fixed-window gradients, whose length would not depend on the outcome, are #70. | should change |
| `seed` | 7 | 54 | The fold seed, fixed, and the pick repeated on four more (`seeds_more`). | aligned |
| `folds` | 7 | 5 | Five folds of whole watershed groups, each held out once: cross-validation with the group, not the visit, as the unit, as Rethinking ch. 13 frames prediction for clusters not in the sample (p. 428). BDA3 notes that each fold's prediction, made from less than all the data, underestimates the fit (p. 175). | aligned |
| `fit` | 7 | fe | The scorer absorbs a fixed intercept per group: in BDA3's terms a group effect with infinite prior variance (p. 383), which Rethinking ch. 13 calls amnesia (p. 399). It drops every group with only one outcome (`one_outcome_groups`), so chinook rearing scores 45 of the 111 groups its visits fall in. Defensible for comparing rules within groups; a pooled curve is tested in #186. | differs |
| `prior_sd` | 7 | 2.5 cloglog | A normal prior, SD 2.5 on the cloglog scale, on the data-set and era terms, as a ridge (MAP, not a posterior: Rethinking p. 216, BDA3 p. 311). Rethinking calls this a regularising prior (p. 214) and BDA3's default for logistic coefficients is scale 2.5 (p. 416). Its dummies differ by 1, as BDA3's binary inputs do (p. 415); it differs in its family (normal, not Cauchy), its link (cloglog, not logit) and its scope (the sampling terms only, where BDA3's default covers every coefficient but the constant, p. 416), and no prior predictive check was run (Rethinking p. 328). Compared with no prior in #84. | aligned |
| `se_region` | 7 | 1 SE | The region is every rule within one SE of the best, the SE being √(groups) × the sd of per-group differences from the best: The region's width, one SE: a parsimony rule fixed before the run (`R/tune_repick.R:7-8`), a convention neither book sets. The SE itself is Rethinking's SE of a difference (`se_formula`, aligned). | differs |
| `se_strict` | 7 | 1.96 SE | 1.96 SE widens the region, so its pick moves toward `default`; stricter only about calling `default` worse. 1.96 is a convention Rethinking says is hard to defend (p. 56); it is reported beside the main reading, not used to pick. | differs |
| `d_floor` | 7 | 200 m | The pick moves off an exception under 200 m, because mainstem catches snapped to a tributary mouth cannot be told apart: placement error handled by excluding rules, not by modelling it (Rethinking ch. 15). | differs |
| `smoke_tol_null` | 7 | 0.25 deviance | The no-rule model's held-out deviance may exceed the in-sample null (each group at its own rate) by at most 25 %: a check that the scoring machinery works. | no bearing |
| `smoke_coef_max` | 7 | 5 cloglog | Fails a key whose largest non-group coefficient (nuisance or rule) on the smoke run's rules exceeds 5, twice `prior_sd`: a detector of separation, the instability BDA3 ch. 16 names (p. 412) and the prior is there to hold. | aligned |
| `min_wsg` | 7 | 5 groups | A key needs five groups with both outcomes to be fitted; under fixed intercepts only those groups inform a rule. | no bearing |
| `power_wsg` | 7 | 10 groups | A label: under ten groups a fit is called underpowered. | no bearing |
| `spawn_codes` | 7 | IM; M; MT; SP; ST | The maturity codes that make a spawning response: the outcome is a proxy, read as exact (Rethinking names outcomes that cannot be trusted, p. 249, and treats error on a continuous outcome, p. 491). | differs |
| `spawn_large` | 7 | 350 mm | As `spawn_codes`, a length that counts as a spawner. | differs |
| `flow_src` | 7 | pick | Which flow the rules read (wet's pick). | no bearing |
| `lake_target` | 7 | FALSE | Which rivers a walk may end on. | no bearing |
| `era_breaks` | 7 | 1994; 2004 | Era is in the model so a rule is not credited with a change in how crews sampled: adjustment for a confound in the sense of Rethinking ch. 6 (p. 183), with a prior (`prior_sd`). The breaks are a convention, not varied. | aligned |
| `seeds_more` | 8 | 55; 56; 57; 58 | The pick repeated on four more fold splits: a check that the pick does not rest on one split of the groups. | aligned |
| `n_boot` | 8 | 200 | 200 resamples of the groups' rows of the fixed held-out scores, re-picking each time with no refit: the stability of the choice given the scores, not uncertainty in the estimates (`boot_no_refit`). | differs |
| `seed_boot` | 8 | 541 | The bootstrap's seed. | no bearing |
| `dist_cap` | 9 | 50000 m | A walk that reaches the sea or stops reads 50 km: a censored predictor carried as observed (BDA3 treats censored outcomes, p. 224; a censored predictor is the missing-covariate case). | differs |
| `q_default` | 9 | 10 m3/s | The river size the curve walks to when the pick has no exception. | no bearing |
| `curve_k` | 9 | 6; 6; 6 | Basis sizes of the smooths, whose wiggliness REML penalises: a prior on wiggliness, as in BDA3's Bayesian penalised splines (p. 490; Rethinking's fixed ridge on spline weights, p. 118, is the same idea), with the smoothing parameter estimated (empirical Bayes), not integrated. mgcv's penalty is not checked against Wood, which is not in the store. | aligned |
| `grade_ref` | 9 | 0.95 quantile | The grade is a segment's rate over the 95th percentile of accessible segments' rates: a scaling. | no bearing |
| `grade_classes` | 9 | 0; 0.2; 0.4; 0.6; 0.8; 1 | Fifths of the grade, for maps. | no bearing |
| `grad_clamp` | 9 | 0.2 m/m | Gradients over 20 % are read as 20 % by the curve and the grade, so the curve is not extrapolated past where the visits are. | no bearing |
| `dist_offset` | 9 | 10 m | A constant before the log of distance. | no bearing |
| `grade_grad_col` | 9 | gradient | A column choice, held to the curve's gradient. | no bearing |
| `grade_size_mad` | 9 | mad_pick | A column choice. | no bearing |
| `grade_size_width` | 9 | channel_width | A column choice. | no bearing |
| `bridge_distance` | 10 | 10000 m | link's connectivity rule, applied as link applies it. | no bearing |
| `bridge_gradient` | 10 | 0.05 m/m | As `bridge_distance`. | no bearing |
| `cmp_n_boot` | 10 | 200 | 200 resamples of placed bcfishobs record locations for the comparison's lift. Locations cluster by group and the bootstrap ignores it, so the interval is likely too narrow (Rethinking ch. 13's clusters; not measured). | differs |
| `cmp_check_edges` | 10 | 1000; 1050; 1100; 1150; 2000; 2100; 2300; 1250; 1350 FWA edge type | Which visits the comparison counts. | no bearing |
| `tuned_as` | 10 | door | Which wetland structure is reported as tuned. | no bearing |
| `cmp_seed_boot` | 10 | 542 | The comparison bootstrap's seed. | no bearing |
| `link_default_flow` | 10 | unset | Which flow link's `default` reads. | no bearing |

## Choices with no settings key

The choices this review most needs have no settings key; each row names the line that makes it, and the check fails
if that line moves away.

| choice | where | what it does, against the books | verdict |
|---|---|---|---|
| `response_presence` | `R/tune_run.R:176` | The rearing response is "caught at this visit"; a miss reads as an absence (Rethinking p. 499). | differs |
| `population_gate` | `R/tune_run.R:173` | Visits outside link's range for the species (a fixed table per group) or with a blocked absence are left out (the barrier filter on the next line is `barrier_natural`). Only the blocked absence turns on the catch: it drops zeros only, complete-case analysis (Rethinking p. 499). | differs |
| `cloglog_link` | `R/tune_score.R:256` | A binomial GLM with a complementary log-log link: a hazard reading, natural for detection with effort. BDA3 names it a standard link (p. 407); neither book fits it. The GLM frame is Rethinking ch. 10's. | aligned |
| `log_area_free` | `R/tune_score.R:224` | Effort as a free, unpenalised coefficient, not an offset: the hypothesis that the chance of a catch does not grow in proportion to the area fished (Rethinking p. 357). | differs |
| `one_outcome_groups` | `R/tune_score.R:201` | Groups whose visits all caught the species, or none did, are dropped before scoring and before the curve: under fixed intercepts they inform nothing, under pooling they would. | differs |
| `stratified_folds` | `R/tune_score.R:211` | Groups are ranked by detections and dealt to folds in shuffled blocks, so the folds hold similar numbers of detections: a design choice for the score's variance. | no bearing |
| `heldout_intercept` | `R/tune_score.R:423` | Each held-out group refits its intercept on its own outcomes before its deviance is taken: a score conditional on the group's base rate (Rethinking p. 426). | differs |
| `prob_clamp` | `R/tune_score.R:410` | Probabilities held inside 10⁻¹² of 0 and 1, capping one visit's deviance: a numerical guard, and the smoke run stops a key with any visit at the cap. | no bearing |
| `fallback_no_prior` | `R/tune_score.R:267` | A fold where the absorbed fit drops a column the dense fit keeps is refit by `glm.fit`, without the prior; under the prior only an unpenalised column aliased with the groups can send it there, so in the published configuration it does not fire through the data-set or era terms. A guard would make that checked (ISSUE_A). | no bearing |
| `unseen_reference` | `R/tune_score.R:234` | In the scorer a held-out visit whose data set or era training lacked takes the reference level: a zero contrast, the mean of the zero-centred prior on that contrast. One such visit in the scorer's population in the published run (westslope cutthroat rearing), none in the other six keys. | aligned |
| `curve_unseen_mode` | `R/tune_curve.R:139` | In the curve the same visit takes training's commonest level, so the gate's two sides treat it differently; the scorer's reference is the prior's mean. The curve's own count of such visits is not recorded. It matters only where a held-out group mixes seen and unseen levels (a level constant within a group is absorbed by its intercept). | should change |
| `se_formula` | `R/tune_score.R:451` | √(groups) × the sd of per-group differences from the best: Rethinking's SE of a difference (p. 227) with the group as unit. | aligned |
| `pick_nearest_default` | `R/tune_score.R:458` | Inside the region, the rule with the fewest departures from `default`: a preference the scores do not make (#141). | differs |
| `honest_nesting` | `R/tune_score.R:181` | Fold *k*'s pick reads scores from fits that trained on fold *k*, so the check is not nested. | should change |
| `boot_no_refit` | `R/tune_score.R:167` | Resamples groups of the fixed score matrix and re-picks, refitting nothing. | differs |
| `curve_group_effect` | `R/tune_curve.R:104` | The group as a random effect by REML: partial pooling with its variance estimated, not integrated (Rethinking ch. 13; BDA3 ch. 5). | aligned |
| `curve_reference` | `R/tune_curve.R:114` | The curve and grade are read at the median effort, the commonest data set and the latest era: a reference point, a convention. | no bearing |
| `grade_gate` | `R/tune_run.R:292` | Grades withheld when the curve's held-out deviance is no lower than no rule's on the same visits: a point comparison, a tie withholds. | differs |
| `grade_average_group` | `R/grade.R:64` | The grade leaves the group effect out: Rethinking's average cluster (p. 429), right for comparing segments across groups. | aligned |

## What to try in the retune

Each item is an issue, so it is planned and reviewed on its own.

- **Make the curve take the reference for an unseen level, guard the fallback, and nest the nested check**
  (`curve_unseen_mode`, `fallback_no_prior`, `honest_nesting`): ISSUE_A. None moves a published pick: the unseen level
  could move only a gate, and westslope cutthroat's curve is withheld by a margin of 106 in deviance, which one visit
cannot close (a visit's deviance is capped at 55.3) and which the curve's own count, the issue's first measurement,
will settle; the fallback is out of reach of the penalised terms; and nesting changes only the check.
- **Score rules on a gradient that does not depend on the catch** (`gradient_col`): #70.
- **A pooled curve, scored both ways** (#186): a full posterior rather than REML plug-ins, priors on the smooths, the
  one-outcome groups kept, and each held-out group scored both by its own refit intercept (today's score) and as a new
  group from the population distribution, for the pooled curve and today's alike, since a new-group score for one
  against an own-intercept score for the other compares nothing. Two cheap additions: an offset for `log(area)` beside
  the free coefficient, and a prior predictive check of the data-set and era prior on the rate scale.
- **The methodology article says where the method stands** (ISSUE_B): a short section in `habitat_thresholds.Rmd`
  stating the findings above in the reader's terms, with the two books cited.

## Limits of this review

- It reads the method; it fits nothing. Every verdict about a size of effect (how much the curve's unseen-level fix
  moves its score, how much pooling would help) is a question for the issue that makes the change.
- Occupancy models (MacKenzie et al.) and mgcv's penalty scale (Wood) are not in the store; Rethinking names
  occupancy (p. 499) and BDA3 penalised splines (p. 490) without the detail, so those rows stop there.
- A page cited without a quote is not machine-checked; the meaning audit below re-read each one.
- Statements about the method hold for the code at this file's commit; `data-raw/bayesian_alignment_check.R` fails
  when the line behind an unkeyed choice moves, but not when a function's meaning changes around it.

## The meaning audit

A second reader audited every row for meaning against the code and the pages (2026-11-12). Round 1 found 23 errors
or overstatements, all fixed. Three verdicts changed (`fallback_no_prior`: the prior cannot be dropped through the
penalised terms; `unseen_reference`: the reference is the prior's mean; `curve_reference`: a convention) and one
recommendation narrowed (ISSUE_A). Two corrections of fact left their verdicts standing: a BDA3 bullet for continuous
inputs had been applied to binary ones (`prior_sd`), and the population gate had been described as built from fish
records (access reads barriers before observation overrides; the blocked absence is the one exclusion that turns on
the catch).

Pages re-read, quoted or not. Rethinking: 56, 118, 119, 161, 162, 183, 185, 210, 214, 216, 225, 227, 228, 249, 328,
357, 376, 377, 399, 413, 426–430, 491, 495, 499, 517, 521. BDA3: 174, 175, 182, 198, 224, 225, 311, 383, 407, 412,
415, 416, 490.

Round 2 read the fixes and found errors inside four of them (a citation for a discrete outcome that is about a
predictor; the region's width marked aligned on reasoning that marks 1.96 differs; the gate's selection quote; residues
in the step table and the limits) and one missed difference (the prior's scope). All fixed; `se_region` changed to
differs and step 8 to differs, with its should-change part named. Pages re-read in round 2: Rethinking 161, 185, 227,
249, 376, 428, 491, 499, 517, 521; BDA3 174, 182, 224, 407, 415, 416, 490.

AUDIT_ROUND3
