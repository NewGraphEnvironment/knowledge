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

## What exploration found (shapes the rows; the issue's starter table is wrong in three places)

- **Effort is a covariate, not an offset.** `log_area` enters the scorer (`R/tune_score.R`, `.tune_fold_setup`) and the
  curve (`R/tune_curve.R`) as a free coefficient. Rethinking's exposure (ch. 11) fixes it at 1 on the log scale; with
  cloglog, a coefficient of 1 on `log(area)` is the constant-rate-per-area model. A **differs** row, not "agrees".
- **The curve already partially pools.** `knw_tune_curve()` fits `s(wsg, bs = "re")` by REML: a random group intercept.
  Only the scorer absorbs groups as fixed effects (`.tune_glm_fe`, #83). The issue's "fixed group intercepts" is half
  the method.
- **A held-out group refits its own intercept on its own outcomes**, in the scorer and the curve alike
  (`.tune_score_one`; `tune_curve.R` held-out block). That is prediction conditional on the held-out group's
  base rate, not the "new cluster" prediction of ch. 13 (which draws the intercept from the population). The central
  row for ch. 7 / ch. 13, and the first thing #186 must decide how to score.
- The prior is a ridge (`b^2 / prior_sd^2`) inside IRLS in the scorer and `paraPen` in the GAM: a posterior mode
  (MAP), which Rethinking ch. 4 names as such. Aligned in spirit; say it is a mode, not a posterior.
- The region is 1 SE of group-level deviance differences, the pick the region rule nearest `default`; 1.96 is a
  stricter reading (`knw_tune_repick`). Rethinking ch. 7 compares by WAIC/PSIS with its dSE; BDA3 ch. 7 by
  cross-validated log predictive density. Our held-out deviance is that quantity (−2 × lppd on held-out groups).
- PDFs to check pages against: `~/Zotero/storage/` holds two copies of the published Rethinking PDF and a 2020 draft;
  the group item `7UX9T7RQ`'s own attachment is resolved from a guarded `zotero.sqlite` copy before any page is cited.

## Decided at the gate (Al approved these recommendations with the plan, 2026-11-11)

1. **This PR writes the research file, not the article.** A paragraph in `vignettes/habitat_thresholds.Rmd` needs the
   bib regenerated through Zotero, an article review and a method-bundle rebuild; it goes in a follow-up issue whose
   body this PR writes. Public prose must not point at `research/`, so the article states the findings itself.
2. **Coverage:** one row per pipeline step (11, the substance), and one row per setting (69). Settings with no
   statistical bearing (snap radii, edge types, walk hops) are marked `no bearing` in a compact table by step; the
   statistical ones (steps 6–9: `fit`, `prior_sd`, `folds`, `se_region`, `se_strict`, `n_boot`, `curve_k`,
   `smoke_*`, `min_wsg`, `power_wsg`, `era_breaks`, `area_range`, `grade_*`, …) each get a verdict and source.
3. **Quotes are short** (a sentence, ≤ ~30 words) and only where a passage decides a row; the store stays private.
   Every page cited is the **printed** page, checked against the PDF text, not the store's chunk.
4. **Sources beyond Rethinking:** BDA3 where Rethinking is silent or thinner (hierarchical models ch. 5, predictive
   accuracy ch. 7, model checking ch. 6). Occupancy and GAM smoothness priors are marked "outside the store" (Wood and
   MacKenzie et al. not held), never answered from memory.
5. **"Should change" rows become issues** only where no open issue covers them (#186 pooling, #139 baselines, #70
   fixed-window gradients exist); each new one is filed at the end, sized for one `/planning-init`.

## Phase 1: Sources and the instrument
- [ ] Pre-flight: cred ≥ 0.4.0, embedding service up; `cred::crd_store_connect("statistics")` pulls and verifies;
      a test query returns `method = "hybrid"` rows (a `bm25` row is a failed search).
- [ ] Resolve the group item's PDF for McElreath 2020 and BDA3 (guarded copy of `zotero.sqlite`, group 4733734);
      measure each PDF's printed-page offset (pdftotext of two known pages).
- [ ] `data-raw/bayesian_alignment_check.R`: parses every quote in the research file written as
      `> "…" (<citekey>, p. N)`, extracts printed page N from that key's PDF (`pdftotext -f -l`, offset applied,
      whitespace and hyphenation normalised) and fails on any quote not found there; also fails when a key in
      `settings.csv` or a step in `pipeline.csv` has no row. Paths under `~`, none named in output; log to
      `scripts/logs/`.

## Phase 2: What the method does, from the code
- [ ] For each of the eight frames in the issue's table, and each step 6–9, write what the method does with the
      function that does it (`R/tune_score.R`, `R/tune_curve.R`, `R/tune_repick.R`, `R/tune_smoke.R`, `R/grade.R`,
      `R/tune_run.R`), read from the code, not the article. Correct the three starter-table errors above.

## Phase 3: The reading (searched through the `statistics` store, confirmed on the page)
- [ ] Out-of-sample scoring: leave-groups-out deviance vs ch. 7 (lppd, CV, WAIC/PSIS, dSE); the held-out-intercept
      refit; the 1-SE region and nearest-to-default pick vs ch. 7's comparison and BDA3 ch. 7.
- [ ] Priors: ridge/paraPen as MAP vs ch. 4 and ch. 7's regularising priors; SD 2.5 on the cloglog scale.
- [ ] Groups: fixed absorbed intercepts (scorer) vs REML random intercept (curve) vs ch. 13 / BDA3 ch. 5; thin keys.
- [ ] Reporting: one cut with 1 SE and 1.96 vs reporting the whole posterior (ch. 2–3, ch. 7); bootstrap of groups.
- [ ] Grade gate: curve vs no rule as model comparison; smoothness (REML) as a prior on wiggliness (outside store
      where Rethinking is silent).
- [ ] Link and exposure: cloglog binomial with `log(area)` free vs ch. 10–11 exposure/offset.
- [ ] Detection: "no fish caught" as absent vs ch. 15 measurement error; occupancy outside the store.
- [ ] Causal: `access_bt`, era, data set, crew site choice vs ch. 5–6 DAGs (a DAG of the evidence, drawn in words).

## Phase 4: The file and its links
- [ ] `research/bayesian_alignment.md`: header line (Verified · Issues #185, #95, #186 · Produced by the store, the
      two PDFs and the check script); a plain-language walk first (what the tuning does, what was asked, how it was
      judged, what stands, what to try), teaching each principle beside its verdict; the step table; the settings
      table; "What to try in the retune", each item an issue.
- [ ] `research/README.md` row; the check script passes.

## Phase 5: Feed the follow-ons
- [ ] Edit #186's body: the scope this review sets (how to score a new group, offset vs covariate, what "better"
      means) as tasks in its plan.
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

