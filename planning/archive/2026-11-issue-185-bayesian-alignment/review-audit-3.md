# Meaning audit, round 3: research/bayesian_alignment.md

Read at `5648dad2`, scoped to the text that commit changed or added (`git show 5648dad2 -- research/bayesian_alignment.md`).
Code read at the same commit. Book text from pdftotext (Rethinking: printed page = form-feed index + 1 − 16; BDA3: − 10).
Probes ran in memory and wrote nothing. Counts marked "local build" come from the ignored `data/fdis/derived/` and
`data/fdis/build/catch.rds`, which are not the published evidence (round 2 found their md5s differ): indicative only.
Line numbers are the file's at `5648dad2`.

## Findings

| line | claim | verdict | evidence | fix |
|---|---|---|---|---|
| 271-273 | "the blocking codes are related species caught in the same water, whose catch tracks habitat" | **wrong** | `data/fdis_species_codes.csv`, column `blocks_absence_of`: the codes that block are mostly unresolved names that **could be the species itself**: `AF` ("All fish: could be anything"), `SP` ("Unidentified species"), `SA`/`AO` ("could be any salmon"), `CT` ("species not given: could be westslope cutthroat"), `TR` (unidentifiable trout fry), the cross and either/or codes (`CRS`, `CT/RB`, `RB/CT`). Only `KO`↔`SK` and, for BT, the other char codes (`R/fdis_species.R:14-17`, `:110-114`) are a different taxon, and even those are named because they cannot be told apart in the field. Local build, blocked visits by blocking code: WCT 2,235 (`CT` 1,562, `TR` 475, `SP` 339, `CRS` 54); CH 365 (`SP` 333, `SA` 25); ST 814 (`TR` 476, `SP` 345); BT 774 (`SP` 302, `DV` 88, `BT/DV` 19). So a blocked absence is a recorded zero whose true value is unknown and plausibly a one: missingness caused by the outcome itself. That is Rethinking's Figure 15.4 (d), "Dogs prefer to eat bad homework" (p. 500), of which p. 503 says "This type of missingness, in which the variable causes its own missing values, is the worst." p. 161's selection-distortion (selection on a combination of two variables inducing a correlation between them) is a weaker fit than this. Round 2 proposed the wording, and its own evidence column ("unidentified char or trout") already contradicted "related species". | "…but a blocking code is mostly a fish named too loosely to rule the species out (unidentified fish, cutthroat of unstated species, trout fry), so a blocked absence may be the species itself, and its catch also tracks habitat: missingness caused by the outcome, the case Rethinking calls the worst (Fig. 15.4 d, pp. 500, 503)." Drop or demote p. 161. Add p. 500 and 503 to the pages re-read. |
| 271 | "Dropping zeros at random would only move each group's intercept" | **overstated** (exact only under a logit) | Keeping a fraction r of zeros at random changes P to P/(P + r(1−P)). On the logit scale that is a constant shift, −log r (case-control sampling), so a group intercept absorbs it. On the cloglog scale (`R/tune_score.R:256`) it is not constant. With r = 0.9: shift 0.104 at P = 0.02, 0.098 at 0.13, 0.088 at 0.31, 0.066 at 0.63, 0.051 at 0.81 (logit: 0.105 throughout). So within a group the shift varies with the rule's linear predictor, slightly at low rates and more at high ones. The effect is small for the shares involved (WCT's blocked visits are about 6 % of its zeros, local build), but "only" is false under the link the method uses. Round 2's evidence said "approximately so under a cloglog at low rates", and the fix dropped the qualifier. | "Dropping zeros at random would move each group's intercept, exactly so under a logit and nearly so under the cloglog where catch rates are low;…" |
| 266-267, 301, 393 | "the gate drops some zeros and no ones"; step 5 "removes zeros only"; `population_gate` "it drops zeros only" | **accurate as recorded, misleading as read** (follows from the first row) | `R/fdis_species.R:120`: `blocked[k] <- !present[k] && …`, so only a recorded zero can be blocked. The recorded zero is exactly the value the blocking code puts in doubt, though (first row). | Say "recorded zeros" in all three places, e.g. step 5: "…which removes recorded zeros only, some of which may be the species under a looser name: complete-case analysis (Rethinking p. 499)". |
| 275-276, 301 | "link's range is a fixed table per watershed group (`wsg_species_presence`, read by `scripts/0310-evidence-build.R`), so the visits do not set it"; step 5 "range is link's table per group, so neither is decided by the visit's catch" | **mostly correct; "do not set it" slightly overstated** | Fixed table: confirmed. `scripts/0310-evidence-build.R:224-230` calls `link::lnk_species_pooling(loaded, …)` on `lnk_load_overrides(cfg)`, and that function reads `loaded$wsg_species_presence` (one row per group, a column per species) and returns the species present per group. The run computes nothing from the visits. But link curates that table against observation records. `extdata/configs/default/wsg_species_presence_review.csv` flags each group × species by the rule "at least 1 record dated 1950 or later" (327 `absent_recorded`, 24 `present_unsupported`), and those records include the FISS database, from which the FDIS export was built. So the visits do not set the range in this run, but their records were weighed when link set it. Under fixed intercepts that touches only which groups enter, so the paragraph's conclusion holds. Also, the table is read through link's function, not by 0310 directly. "Usually one with no catch": confirmed on the local build. Out-of-range groups that held a catch: CH 0 of 102, CO 1 of 125, WCT 3 of 203, KO 18 of 215. | "…a fixed table per watershed group (`wsg_species_presence`, which `scripts/0310-evidence-build.R` reads through `link::lnk_species_pooling()`), so this run does not compute it from the visits, though link's review of it weighs observation records." Optional in step 5. |
| 150-151, 351 | "era has three levels, so the two later eras differ from each other with prior SD 2.5·√2" | **correct** | `R/tune_run.R:139-140`: three era levels, reference `to1994`, so two dummies. The ridge adds one independent pseudo-row per penalised column (`R/tune_score.R:308`, `:340-343`), so each dummy is N(0, 2.5²) on its own and their difference is N(0, 2·2.5²): SD 2.5·√2 ≈ 3.54. The curve uses the same coding (`R/tune_curve.R:101`, `diag(nlevels − 1)`). `data_set` does not need the same note: it has three values in `visits_link.csv` (FCOL 5, FDIS, FDS), but all five FCOL visits fail `base`'s area or river filter (`R/tune_run.R:135-137`), and `factor(base$data_set)` (`:141`) leaves two levels (local build). BDA3 p. 416: independent Cauchy priors "to each of the coefficients … except the constant term", confirming the scope sentence. | none |
| 136-139 | "gives it a pseudo-row of its own (`R/tune_score.R:308`, :340-343), and the rule column is excluded from the test (:384)" | **correct** | `:308` builds `R <- diag(sqrt(ridge), p)[ridge > 0, ]`, and `:340-343` appends it to `Xd`. `:384` sets `cand <- (dropped & !zero)[-p]`, and `rule` is the last column (`:266`). | none |
| 101-102 | "the book warns that these standard errors understate the uncertainty in small samples (p. 227, said of each score's SE)" | **correct** | p. 227: "SE is the approximate standard error of each WAIC … When the sample is small, this approximation tends to dramatically underestimate the uncertainty." | none |
| 105-106 | "closer to what p. 225 asks than a single winner, though it reduces each difference to in or out and still names one pick" | **correct** | p. 225: selection "discards the information about relative model accuracy contained in the differences". | none |
| 104, 352 | "`R/tune_repick.R:7-8`" for "a parsimony rule fixed before the run" | **citation off by one** (minor) | "One standard error is a" is on line 6, "parsimony rule of thumb fixed before the run, not a boundary of noise" on line 7. Line 8 ("replays the same pick…") is not part of it. | `R/tune_repick.R:6-7`, in both places. |
| 352 | `se_region` row: "The region is every rule within one SE of the best, the SE being √(groups) × the sd of per-group differences from the best: The region's width, one SE: a parsimony rule…" | **garbled** (an edit residue: the old opening kept, the new text appended after a colon with a capital) | The row reads as two half-sentences. | "The region's width, one SE: every rule within one SE of the best is in it. A parsimony rule fixed before the run (`R/tune_repick.R:6-7`), a convention neither book sets. The SE itself is Rethinking's SE of a difference (`se_formula`, aligned)." |
| 359 | `spawn_codes`: "Rethinking names outcomes that cannot be trusted, p. 249, and treats error on a continuous outcome, p. 491" | **correct** | p. 249: "'occupancy' detection models, where specific values of the outcome (usually zero) cannot be trusted". p. 491: §15.1.1 "Error on the outcome" (the divorce rate, continuous). | none |
| 306, 379 | Step 10, `cmp_n_boot`: "the lift's bootstrap of placed record locations" | **correct** | `R/compare_rules.R:511-514` resamples `ls`, the placed record locations on stream segments, with replacement. | none |
| 416-420 | ISSUE_A: "the unseen level could move only a gate, and westslope cutthroat's curve is withheld by a margin of 106 in deviance, which one visit cannot close (a visit's deviance is capped at 55.3)" | **numbers correct; the argument covers one key of seven** (gap) | Margin: `data/tune/WCT_rear_summary.csv`, `dev_curve` 1536.69 − `null_heldout_curve` 1430.36 = 106.33. Cap: −2 log 10⁻¹² = 55.26 (`R/tune_score.R:410`, applied in `.tune_group_dev`, which the curve calls at `R/tune_curve.R:147`). The bound survives the held-out group's intercept refit: changing one visit's offset moves the group's minimised deviance by at most that visit's deviance range, [0, 55.3]. But the argument is made only for the key where the **scorer** met an unseen visit. The curve fits a subset of the scorer's rows (`R/tune_curve.R:82-85`) on the same folds, so its training folds can lack a level the scorer's held, in any key. Its count is recorded nowhere (`unseen` appears only in a comment at `R/tune_curve.R:135`; `unseen_level_visits` is the scorer's, `R/tune_score.R:139`). Two other gates sit within one visit's reach: bull trout spawning is withheld by 0.56 (404.41 vs 403.85), and grayling rearing is published by 14.36 (808.28 vs 822.64). Coho rearing (withheld by 58.08) is just past one visit. "None moves a published pick" stays true, since a gate is not a pick. The sentence still reads as if no gate can move, which the file cannot show. | "…None moves a published pick. The unseen level could move only a gate, and the curve's count of such visits, the issue's first measurement, is recorded for no key: one visit can move a gate by at most 55.3, enough to flip bull trout spawning (withheld by 0.56) or grayling rearing (published by 14.4) but not westslope cutthroat rearing (withheld by 106);…" Mend the indentation of the continuation lines (418-420 start at column 0, unlike 417). |
| 302 | Step 6: "…the region is anchored on that score, so it carries the bias too; the nested check that would measure it is not nested (step 8)", verdict **aligned** | **verdict strained by its own text** (minor) | The row now states an unmeasured selection bias, BDA3 p. 182's point, inside a step marked aligned. The bias arises in choosing (step 7, **differs**), not in setting the grid (the `grid_*` rows are aligned). | Either move the bias clause to step 7's text, leaving step 6 about the candidate set, or keep it in step 6 and say the aligned verdict is the grid's. |
| 454-458 | Round 2's summary: "found errors inside four of them (…) and one missed difference (the prior's scope). All fixed; `se_region` changed to differs and step 8 to differs" | **understates round 2** | `review-audit-2.md` also found: the range overstated (the "per group, so" reasoning and "absorb"); the gate argument answering the pick and not the gate, with the curve's count unmeasured; round 1's list of verdict changes wrong (now replaced at 442-448); the step-verdict rule unsettled; era's three levels (√2); the In brief omitting the guard; the `population_gate` citation partly unpinned; and two mild page overstatements (p. 227, p. 225). All were applied, but the summary names only four plus the scope. | Name them by kind, as round 1's paragraph does: "…and one missed difference (the prior's scope); it also tightened the range, the gate argument (to the scorer's count), round 1's list of verdict changes, era's √2 and two page readings (pp. 225, 227), and settled how a step's verdict reads." |

## The should-change verdicts against the changes the prose names

**Every "should change" verdict, and where its change and owner are stated:**

| item | verdict at | change stated at | owner |
|---|---|---|---|
| `honest_nesting` (the nested check is not nested) | prose 115; choices 405; step 8's text, 304 | 115 ("nest it … or describe it as what it is"); 416-420 ("nest the nested check") | ISSUE_A |
| `curve_unseen_mode` (the curve takes training's commonest level) | choices 402; step 9's text, 305 | 416-420 ("make the curve take the reference") | ISSUE_A |
| `gradient_col` (the rules read an outcome-dependent gradient) | prose 264; settings 347; step 7's text, 303 | 42-43, 347 ("fixed-window gradients … are #70"), 421 | #70 |

No step carries a **should change** verdict of its own now. The three parts named in steps 7, 8 and 9 are exactly the
three rows above. The In brief (40-43) names the same three, and says "Three things".

**Every change the prose names, and its verdict:**

| change | named at | verdict of the row it touches | owner |
|---|---|---|---|
| nest the nested check | 115, 417 | should change | ISSUE_A |
| curve takes the reference level | 40-41, 416 | should change | ISSUE_A |
| gradient not dependent on the catch | 42, 347, 421 | should change | #70 |
| guard that stops a run if the fallback fires under a finite prior | 44, 160-161, 400, 416 | `fallback_no_prior`: no bearing | ISSUE_A |
| pooled curve, scored both ways, one-outcome groups kept | 44-46, 184, 422-425 | `fit`, `one_outcome_groups`, `heldout_intercept`: differs | #186 |
| offset for `log(area)` beside the free coefficient | 230-231, 425 | `log_area_free`: differs | #186 |
| prior predictive check of the sampling prior | 159, 426 | `prior_sd`: aligned | #186 |
| a section in the methodology article | 427-428 | none (reporting) | ISSUE_B |

**The two sets match.** Each should-change has a stated change and an owner (ISSUE_A twice, #70 once), and no change the
prose names lacks an owner. Changes outside the should-change set are the ISSUE_A guard (stated as a check that makes
an argument certain), the #186 experiments and ISSUE_B's write-up. None of them contradicts its row's verdict.

Three small mismatches:

- 115 offers two remedies ("nest it … or describe it as what it is"), and the recommendation at 416 commits to one
  ("nest the nested check"). Either drop the alternative at 115 or let ISSUE_A carry both.
- The `fallback_no_prior` row (400, **no bearing**) names its owner (ISSUE_A), but the two **should change** rows it is
  filed with, `curve_unseen_mode` (402) and `honest_nesting` (405), do not. Add "(ISSUE_A)" to both, as
  `gradient_col` names #70.
- Step 3 (299) states the outcome→predictor arrow that `gradient_col` fixes, as **differs**, with no pointer. The rule
  at 292 says a should-change part is named in its step's text. `gradient_col` is a step-7 setting, so this is
  defensible. A "(the rules' reading of it: step 7, #70)" would close the loop.

Placeholders still open, as expected: `ISSUE_A` (400, 417), `ISSUE_B` (427), `AUDIT_ROUND3` (460).

## Pages re-read this round

Rethinking 161, 225, 227, 249, 491, 499, 500, 501, 502, 503; BDA3 415, 416.

## Dispositions (session, 2026-11-12)

Reproduced: `data/fdis_species_codes.csv`'s `blocks_absence_of` codes (AF, SP, SA, AO, CT, TR, the crosses and
either/or codes; KO↔SK the only distinct taxa); Rethinking p. 500 (Figure 15.4 d) and p. 503 ("the variable causes its
own missing values, is the worst"); `R/tune_repick.R:6-7`. All findings applied, including the three small mismatches
in the enumeration (owners named on both ISSUE_A rows, step 3 points to `gradient_col`, ISSUE_A carries both remedies
for `honest`). The local counts by blocking code are not quoted (older evidence build).
