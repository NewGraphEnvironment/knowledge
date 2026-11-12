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

## Sources (Phase 1, 2026-11-11)

- `statistics` store pulled from the bucket (4 docs, 6,579 chunks, nomic-embed-text); cred 0.7.0, ragnar 0.3.1;
  searches return `hybrid` rows.
- Group items and their own attachments (guarded copy of `zotero.sqlite`, quick_check ok):
  McElreath 2020 `7UX9T7RQ` (`mcelreath2020StatisticalRethinking`) → attachment `PVGNFJC9`, 609 PDF pages, printed
  page = PDF page − 16; BDA3 `5RKUXXZS` (`gelman_etal2013Bayesiandata`) → `JP3BM8T9`, 677 pages, printed = PDF − 10.
  The other Rethinking copy (`VRYUI5QB`) and the Feb 2020 draft (`8ET5IAV7`) are not the group item's.
- BDA3's first line on every page is its free-edition notice; the running head is the next line.
- The PDFs' text drops most word spaces and keeps subscripts inline ("log τi"): a quote must carry the subscript as
  printed. The check failed a fixture quote that omitted it, which is the strictness wanted.
- Rethinking p. 357 (ch. 11.2, exposure): a parameter in front of the log exposure "is one way to model the hypothesis
  that the rate is not constant" — so a free `log_area` coefficient is a named alternative, not an error.

## The research file's row contract (review O2)

The check reads three tables, each found by its `##` heading: `## The steps` (first cell the step number),
`## The settings` (first cell the key in backticks) and `## Choices with no settings key` (first cell a backticked
id the check holds with a code anchor). Each row's last cell is exactly one of `aligned`, `differs`,
`should change`, `no bearing`. Quotes stand on their own blockquote line: `> "…" (<citekey>, p. N)`.

## The check's negative tests (2026-11-12)

Fixtures generated from the registers (11 steps, 69 settings, 19 unkeyed choices) in the session scratchpad. The
clean fixture (a Rethinking p. 357 quote and a BDA3 p. 407 quote across an ellipsis) passes. The planted fixture fails
on all eight defects: a quote outside a blockquote, a wrong page, a fabricated word ("always constant"), a one-word
fragment after an ellipsis, a missing setting, a duplicate setting, a stale key, and a row whose verdict is only in its
prose. Exit status 1.
