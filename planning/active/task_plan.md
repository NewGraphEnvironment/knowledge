# Task: Read the tuning method against Statistical Rethinking: research/bayesian_alignment.md (#185)

**If we do it:** each step and setting of the tuning method is marked aligned, differs, or should change against Bayesian practice as *Statistical Rethinking* teaches it, with chapter and page, so the methodology article can say where the method stands and the retune knows what to try. **If we never do:** the method's choices (a prior fitted as a penalty, fixed group intercepts, one cut with a 1.96 reading) stay unexamined against the frame they most resemble.

Plan approved by Al, 2026-11-11 (plan mode, /planning-init 185).

## Context

The tuning method (11 steps in `inst/method/pipeline.csv`, 69 settings in `inst/method/settings.csv`, #93) has never
been read against the frame it most resembles. #95 built the `statistics` store (McElreath 2020, BDA3, Hill 2025,
Toffolon & Piccolroaz 2015; in the bucket since 2026-11-10) so it could be. The outcome is one research file that
marks each step and setting **aligned**, **differs** or **should change**, with chapter and printed page, so the
methodology article can say where the method stands and #186 (the partially pooled curve) knows its scope.

Branch `185-read-the-tuning-method-against-statistic` off `origin/main` at `89ee4d3` (local main is level with origin).

## What exploration found (shapes the rows; corrected by the plan review, `review-plan.md`)

The issue's starter table is wrong in three places: effort is not an offset, fixed intercepts are not the whole
method, and the gate withholds a curve "no better than" no rule (`>=`, a tie withholds), not one "worse than" it.

- **Effort is a covariate, not an offset.** `log_area` enters the scorer (`R/tune_score.R`, `.tune_fold_setup`) and the
  curve (`R/tune_curve.R`) as a free coefficient. Rethinking's exposure (ch. 11) fixes it at 1 on the log scale; with
  cloglog, a coefficient of 1 on `log(area)` is the constant-rate-per-area model. A **differs** row, not "agrees".
- **The curve already partially pools.** `knw_tune_curve()` fits `s(wsg, bs = "re")` by REML: a random group intercept.
  The scorer, the smoke run and the gate's no-rule baseline absorb groups as fixed effects (`.tune_glm_fe`, #83). The
  issue's "fixed group intercepts" is half the method.
- **A held-out group refits its own intercept on its own outcomes**, in the scorer and the curve alike
  (`.tune_score_one`; `tune_curve.R` held-out block). That is prediction conditional on the held-out group's
  base rate, not the "new cluster" prediction of ch. 13 (which draws the intercept from the population). The central
  row for ch. 7 / ch. 13, and the first thing #186 must decide how to score.
- The prior is a ridge (`b^2 / prior_sd^2`) inside IRLS in the scorer and `paraPen` in the GAM: a posterior mode
  (MAP), which Rethinking ch. 4 names as such. Aligned in spirit; say it is a mode, not a posterior.
- The region is 1 SE of group-level deviance differences (`.tune_sel`), the pick the region rule nearest `default`.
  1.96 **widens** the region, so its pick moves toward `default`: stricter only about calling `default` worse.
- **The held-out deviance is not −2 × lppd.** It is −2 × the log-likelihood at a point estimate (Rethinking's lppd
  averages over posterior draws), with one intercept per held-out group fitted on the outcomes being scored
  (`.tune_group_dev`), clamped at p = 1e-12. Optimistic by about one parameter per group, equally for every rule, so
  rule comparisons hold and the absolute score does not. It tests within-group discrimination; the grade drops
  `s(wsg)` to compare across groups, which no score tests.
- The prior is dropped on fallback folds (refit by `glm.fit` with no ridge); `honest` is not fully nested (fold k's
  pick reads scores from fits trained on fold k); the bootstrap resamples groups of fixed scores and refits nothing;
  groups with only one outcome are dropped before scorer and curve (`.tune_modelled`).
- PDFs to check pages against: `~/Zotero/storage/` holds two copies of the published Rethinking PDF and a 2020 draft;
  the group item `7UX9T7RQ`'s own attachment is resolved from a guarded `zotero.sqlite` copy before any page is cited.

## Decided at the gate (Al approved these recommendations with the plan, 2026-11-11)

1. **This PR writes the research file, not the article.** A paragraph in `vignettes/habitat_thresholds.Rmd` needs the
   bib regenerated through Zotero, an article review and a method-bundle rebuild; it goes in a follow-up issue whose
   body this PR writes. Public prose must not point at `research/`, so the article states the findings itself.
2. **Coverage:** one row per pipeline step (11), one per setting (69), and one per method choice that has no settings
   key (the held-out refit, the SE formula, the gate, the outcome-based group drop, unseen levels, the clamp, the
   fallback, the link, `log_area`'s role, the curve's reference, the stratified dealing), each in its own table with
   a last-column verdict. `no bearing` only where nothing statistical turns on a value: placement radii, the gradient
   source, a modelled flow and the distance cap are predictor measurement error (ch. 15), not `no bearing`.
3. **Quotes are short** (a sentence, ≤ ~30 words) and only where a passage decides a row; the store stays private.
   Every page cited is the **printed** page. A quoted page is machine-checked; an unquoted page citation rests on the
   meaning audit, which re-reads each cited page and records it.
4. **Sources beyond Rethinking:** BDA3 where Rethinking is silent or thinner (hierarchical models ch. 5, predictive
   accuracy ch. 7, model checking ch. 6, data collection ch. 8, weakly informative priors and separation ch. 16, basis
   functions ch. 20). Occupancy and mgcv's penalty scale are marked "outside the store" (Wood and MacKenzie et al. not
   held), never answered from memory. A link between cloglog-binomial and Poisson exposure is marked derived unless a
   page states it.
5. **"Should change" rows become issues** only where no open issue covers them (#186 pooling, #139 baselines, #70
   fixed-window gradients exist); each new one is filed at the end, sized for one `/planning-init`.

## Phase 1: Sources and the instrument
- [x] Pre-flight: cred ≥ 0.4.0, embedding service up; `cred::crd_store_connect("statistics")` pulls and verifies;
      a test query returns `method = "hybrid"` rows (a `bm25` row is a failed search).
- [x] Resolve the group item's PDF for McElreath 2020 and BDA3 (guarded copy of `zotero.sqlite`, group 4733734);
      measure each PDF's printed-page offset (pdftotext of two known pages).
- [x] `data-raw/bayesian_alignment_check.R`: parses every quote in the research file written as
      `> "…" (<citekey>, p. N)`, extracts printed page N from that key's PDF (`pdftotext -f -l`, offset applied,
      whitespace and hyphenation normalised) and fails on any quote not found there; also fails when a key in
      `settings.csv` or a step in `pipeline.csv` has no row. Paths under `~`, none named in output; log to
      `scripts/logs/`.
- [ ] Harden the check (review C2–C6): token matching as `0280` does (numbers as written, line-end hyphens joined), a
      minimum fragment length after an ellipsis; folio on the first or last line of the page; a quote outside a
      blockquote line fails; the three tables found by heading, each row's last cell exactly one verdict, duplicate
      and stale keys fail; the no-key choices held in the script with a code anchor each, which must still match.
      Negative tests: wrong page, fabricated quote, short fragment, verdict only in prose, duplicate row, stale key,
      deleted setting.

## Phase 2: What the method does, from the code
- [ ] For each of the eight frames in the issue's table, and each step 6–9, write what the method does with the
      function and file:line that does it (`R/tune_score.R`, `R/tune_curve.R`, `R/tune_repick.R`, `R/tune_smoke.R`,
      `R/grade.R`, `R/grade_species.R`, `R/tune_run.R`, `R/tune_grid.R`, `R/rule_in.R`, `R/thresholds_table.R`,
      `R/compare_rules.R`), read from the code, not the article. Correct the three starter-table errors above.

## Phase 3: The reading (searched through the `statistics` store, confirmed on the page)
- [ ] Out-of-sample scoring: leave-groups-out plug-in deviance with a refit held-out intercept vs ch. 7 (lppd, CV,
      WAIC/PSIS, dSE) and ch. 13's new clusters; the 1-SE region (group-level SE) and nearest-to-default pick (a prior
      in decision form, #141) vs ch. 7's comparison-not-selection and BDA3 ch. 7; `honest` and its nesting.
- [ ] Priors: ridge/paraPen as MAP vs ch. 4 and ch. 7's regularising priors; SD 2.5 on the cloglog scale vs ch. 11's
      prior predictive on a link scale and BDA3 ch. 16; which terms carry none; the fallback that drops it.
- [ ] Groups: fixed absorbed intercepts (scorer) vs REML random intercept (curve) vs ch. 13 / BDA3 ch. 5; thin keys;
      the outcome-selected groups; grading at RE = 0 (the average cluster) across groups no score tested.
- [ ] Reporting: one cut, its region's range and 1.96 vs reporting the whole posterior (ch. 2–3, ch. 7); the group
      bootstrap as selection stability, not estimation uncertainty.
- [ ] Grade gate: curve vs no rule as a point comparison on the folds that chose the curve's variables; smoothness
      (REML) as a prior on wiggliness (Rethinking ch. 4 B-splines, BDA3 ch. 20).
- [ ] Link and exposure: cloglog binomial with `log(area)` free vs ch. 10–11 exposure/offset.
- [ ] Detection: the response (presence per visit) and the grade's own claim ("expected use per standard
      electrofishing visit") vs ch. 15 measurement error and ch. 12's zero-inflated mixtures; occupancy outside the store.
- [ ] Causal: `access_bt`, era, data set, crew site choice, and link cutting segments at fish records (a predictor
      partly caused by the outcome) vs ch. 5–6 DAGs and BDA3 ch. 8 (a DAG of the evidence, drawn in words).
- [ ] Predictor measurement error: placement, the gradient source, modelled flow, the distance cap vs ch. 15.

## Phase 4: The file and its links
- [ ] `research/bayesian_alignment.md`: header line (Verified · Issues #185, #95, #186 · Produced by the store, the
      two PDFs and the check script); a plain-language walk first (what the tuning does, what was asked, how it was
      judged, what stands, what to try), teaching each principle beside its verdict; the step table; the settings
      table; "What to try in the retune", each item an issue.
- [ ] `research/README.md` row; the check script passes.

## Phase 5: Feed the follow-ons (after the meaning audit and `/code-check branch`, review O1)
- [ ] Edit #186's body: the curve already has varying intercepts; what differs is a full posterior, priors on the
      smooths, the one-outcome groups kept, and scoring a new group from the population; both models scored both ways
      (own intercept and new cluster).
- [ ] File the methodology-article follow-up (decision 1), and one issue per uncovered "should change" row
      (decision 5); each body names #185.

## Owed at the end (reported, done after merge)
- [ ] None expected beyond the filed issues.

## Validation
- [ ] Tests pass (`devtools::test()`; no package code changes expected)
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

**How each change is proved:** `data-raw/bayesian_alignment_check.R` passes (every quote on its printed page; every
step and setting has a row) and is shown to fail on a planted wrong page and a deleted settings row; every "what the
method does" sentence names the function it was read from; a row-by-row audit of meaning against the pages (the
#29 lesson: the gate checks words, not meaning) before the PR; `public_sweep.py` over the branch.

