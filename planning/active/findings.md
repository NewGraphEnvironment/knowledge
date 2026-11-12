# Findings — Read the tuning method against Statistical Rethinking (#185)

## Issue context

**If we do it:** each step and setting of the tuning method is marked aligned, differs, or should change against Bayesian practice as *Statistical Rethinking* teaches it, with chapter and page, so the methodology article can say where the method stands and the retune knows what to try. **If we never do:** the method's choices (a prior fitted as a penalty, fixed group intercepts, one cut with a 1.96 reading) stay unexamined against the frame they most resemble.

Split from backlog move 3 (#172), which built the `statistics` store this reads (#95, item 2).

## Proposed

`research/bayesian_alignment.md`: the methodology article's steps and settings register (`inst/method/pipeline.csv`, `inst/method/settings.csv`, #93) walked against McElreath's *Statistical Rethinking* (2nd ed., 2020; `mcelreath2020StatisticalRethinking`) and Gelman et al.'s *Bayesian Data Analysis* (3rd ed., 2013), searched through the `statistics` store. One row per step or setting: aligned, differs, or should change, with the chapter and page, and a short passage quoted where it decides the row. #95's table is the starting list:

| what the tuning does | the book's frame |
|---|---|
| scores rules on held-out watershed groups (deviance) | overfitting and out-of-sample prediction (ch. 7) |
| a normal prior, SD 2.5, on the data-set and era terms, fitted as a penalty | regularising priors |
| group intercepts absorbed as fixed effects (#83), refit for a held-out group | multilevel models, partial pooling (ch. 13) |
| one cut picked, with a one-SE region and a 1.96 reading | report the uncertainty whole |
| the grade gate (a curve worse than no rule gets no grade) | model comparison; priors on a smooth's wiggliness |
| cloglog detection with an effort offset | GLMs with exposure (ch. 10–11) |
| "no fish caught" read as absent | measurement error (ch. 15); occupancy models |
| covariates and confounds (`access_bt`'s circularity, era, where crews fished) | DAGs and causal reasoning (ch. 5–6) |

Findings feed the methodology article and the partially pooled curve's issue, which this review scopes.

Wood's *Generalized Additive Models* and MacKenzie et al.'s occupancy text join the store when a PDF is in hand.

## Errors Encountered

| Error | Resolution |
|-------|------------|
