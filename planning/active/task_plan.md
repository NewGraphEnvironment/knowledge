# Task: Internal article: the tuning against Bayesian practice, and where it goes next (#204)

**If we do it:** an article at its own URL, not listed in the site's articles index or navbar, linked from one sentence of the methodology article, says in plain terms where the tuning stands against Bayesian practice with the two books cited: what it shares with the out-of-sample comparison *Statistical Rethinking* teaches, where it differs and why that is defensible, and how the method could evolve (what is tested next). It is for us first, a record of where the method is heading, and for the reader who follows the link. **If we never do:** the method's resemblance to Bayesian practice, and its departures (a penalty rather than a posterior, refit group intercepts, a pick and a range rather than a distribution), stay in a research file no reader of the site sees.

## Context

#185's review (`research/bayesian_alignment.md`) read the tuning against *Statistical Rethinking* (McElreath 2020)
and *BDA3* (Gelman et al. 2013) and recommended that an article state its findings rather than point at a research
file. The issue's decision (Al, 2026-11-13) is a **separate internal article**, not a section of the methodology
article: built at its own URL, left out of the index and navbar, and linked from one sentence of `tuning-method.Rmd`.
It says what the tuning shares with Rethinking's out-of-sample comparison, where it differs and why that is
defensible, and what is tested next (#203, #186, #70). #203 is open, so the article states the method as it is
and lists #203's changes as next (the issue's own condition).

What exploration found that shapes the phases:
- pkgdown 2.2.0: an `articles:` section titled `internal` is built and left out of the index and navbar.
  `.github/workflows/pkgdown.yaml` refuses only `_<name>.Rmd` drafts, so a normal file name passes.
- `inst/vignette-data/method.rds` has no per-key group counts and no gate results (`picks`, `stability` and
  `settings` only). The tracked `data/tune/<key>_summary.csv` hold them (`groups`, `groups_both`, `grade_withheld`,
  `dev_curve`, `null_heldout_curve`), and `vignette_method.R` already reads those summaries and pins their md5s.
  So the article's numbers come from a new `scope` element of `method.rds`, which a promotion keeps current, because
  `0335` reruns `vignette_method.R`.
- The rebuild is possible on this machine. The main checkout's `data/fdis/derived` md5s equal the promoted grades'
  `evidence_md5` (`db5ca99a…;6a2e28f1…;2e0f0f41…`), `../link` and `../wet` are present, and `PGSERVICE=fresh_local`
  is configured for the snap example. This worktree has no ignored `data/`, so those inputs are copied in first.
- `data-raw/bayesian_alignment_check.R` checks quotes against the PDF pages, but only in the research file's
  `"…" (key, p. N)` form. The article uses pandoc's `[@key, p. N]`, so the check gains an article mode.
  Convention (#79) is to check against the PDF ourselves, not with cred's audit.
- `research/bayesian_alignment.md`'s "What to try" still says #204 is "a short section in `tuning-method.Rmd`". That
  is stale after the decision.

## Decided at the gate

- A separate article at `articles/tuning-bayesian-practice.html`, in an `internal` section of `_pkgdown.yml`
  (issue body, Al 2026-11-13). It is not advertised, but it is not private either.
- The link sentence goes at the end of `#se` ("How are two habitat definitions told apart?"). The article opens on
  that same comparison: rules scored on held-out groups, with the SE of a difference.
- The article's numbers come from `method.rds`, extended with `scope`, and none are typed. It adds no number that
  shapes a result, so `settings.csv` gains no row. Settings it quotes (`prior_sd`, `se_region`, `folds`) are read
  through `val()` from `x$settings`.
- #203's changes appear as what comes next, not as made.
- What is tested next (#203, #186, #70) is named with its issues, an exception to writing.md's "No pointer to pending
  work" for this internal article, whose stated purpose is a record of where the method is heading (issue body).
- "Not listed" means the site's articles index and navbar: the article is still in `sitemap.xml`, the site search and
  the installed package's vignette index (plan review A3).
- The Articles menu is written out in `_pkgdown.yml`, because pkgdown adds "More articles..." for a section with no
  navbar entry; a test holds it to the sections (plan review G1).

## Phase 1: The method bundle carries the scope and the gate
- [x] `data-raw/vignette_method.R`: add `scope`, one row per key the run publishes (fitted or underpowered, as the
      script's line-338 population). Columns: key, `status`, `groups`, `groups_both`, `grade_withheld`,
      `dev_curve`, `null_heldout_curve`, all read from the summaries it already loads. The header OUTPUT gains it.
- [x] Stage the ignored inputs from the main checkout into this worktree (`data/fdis/derived`, `data/fdis/build`,
      plus anything else the script reads that is ignored), and check that their md5s equal the grades' `evidence_md5`.
- [x] Commit the script, then rerun it with `PGSERVICE=fresh_local`. It refuses to run with uncommitted code.
- [x] Compare every other element of the new `method.rds` with the old: identical but `meta`'s date, commit and
      md5s (settings.csv, a new WCT summary) and the register's `where` paths of three keys (findings.md)
- [x] `tests/testthat/test-vignette-data.R`: a test that `scope` exists, has the published keys, and that
      `groups_both <= groups`.

## Phase 2: The article
- [ ] `vignettes/tuning-bayesian-practice.Rmd`, written as a `bookdown::html_vignette2` in the series' style. It
      reads `method.rds` and computes every number inline. Each sentence a number supports gets a `stopifnot()`
      that pins it. Prose says "fish habitat definition" at first mention and "habitat definition" after, never "rule".
- [ ] Shape (writing.md):
  - Headings are the reader's questions.
  - It opens with the answer: what stands, where it differs, what changes next.
  - Each section teaches the principle in a sentence or two, then gives the method's numbers.
  - It stands alone and defines its terms in their own place (held-out score, fixed vs pooled group, prior as
    penalty).
- [ ] Sections, from the issue:
  1. The held-out comparison and the SE of a difference (aligned).
  2. The prior as a penalty at BDA3's scale.
  3. What the held-out score measures: ranking within a group, not a new group's level.
  4. Groups pooled in the curve and fixed in the scorer, with chinook rearing's kept and dropped groups from
     `scope`.
  5. The gate: a point comparison, with keys withheld and published from `scope`.
  6. What changes next: #203, #186, #70.
  7. Limits: what the review did not test.
  8. References.
- [x] Phase 1 follow-up from the plan review (A2): scope check and test allow a failed curve, never recompute the flag
- [ ] Use a few short quotes from the two books, each in `"…" [@key, p. N]` form, taken from passages the research
      file already checked.
- [ ] `_pkgdown.yml`: add an `- title: internal` section listing `tuning-bayesian-practice`.
- [ ] `vignettes/tuning-method.Rmd`: add one sentence at the end of `#se` linking the article.
- [ ] `data-raw/vignette_bib.R`: add a `bib_write()` line for the new article, update its header, and rerun it with
      Zotero running. It refuses any key Zotero does not return.

## Phase 3: Checks on the article's quotes and claims
- [ ] `data-raw/bayesian_alignment_check.R`: accept `[@key, p. N]` quotes, a `n_quotes` per file, coverage tables only
      for the research file, fenced chunks stripped, and a named log for the article (plan review G5). Was: an article mode (`RMD=`). It reads `"…" [@key, p. N]` quotes, checks
      each against its PDF page as the research mode does, and holds the article's own `n_quotes`. Coverage tables
      are skipped in this mode. Run it on both files and commit the logs.
- [ ] Have a blind meaning audit by a Plan agent read the article against the research file and the code it cites.
      Fix what it finds and re-audit the fixes until a round finds nothing inside them.

## Phase 4: Records and docs
- [ ] `research/bayesian_alignment.md`: change the "What to try" #204 bullet to the separate internal article, and
      add #204 to the header's issues.
- [ ] `CLAUDE.md`: a layout entry for the new article (internal section, its bundle and bib); the series' count of
      articles; the record section's line on what `vignette_method.R` checks of the gate; the promotion pins list (G2)
- [ ] `vignettes/tuning-chinook-rearing.Rmd`, README and NEWS: no changes; release bookkeeping is `/gh-pr-merge`'s.

## Validation
- [ ] Tests pass (`devtools::test()`, with `test-vignette-data.R` against the rebuilt bundle)
- [ ] `pkgdown::check_pkgdown()` passes; install the branch, then `pkgdown::build_article("tuning-bayesian-practice")`
      and `build_article("tuning-method")` render with no `citation … not found` in the log
- [ ] The built site has `articles/tuning-bayesian-practice.html`, the articles index page does not list it, the
      navbar does not carry it, and the link from `#se` resolves
- [ ] `bayesian_alignment_check.R` passes on the research file and on the article
- [ ] Rendered article sent to the phone for review before the merge
- [ ] No `rule`/`rules` outside code and quotes in the new article (`grep -nE '\brules?\b'`)
- [ ] The Articles menu is unchanged from main's (navbar HTML diff) and `test-pkgdown-navbar.R` passes
- [ ] A blind readability pass on the rendered text before and after the claim review (writing.md)
- [ ] `/code-check branch` clean
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

