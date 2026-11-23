# Articles: package names in code font at every mention (#258)

## Outcome

Every mention of a package or lower-case tool name in the four articles (`link`, `fresh`, `wet`, `fwapg`,
`bcfishpass`, `bcfishobs`, `knowledge`) is now in code font, in prose, headings, figure captions and table text, and
each article links a package at its first mention only. The methodology article's definition of a tuned threshold now
says it starts from the literature and/or judgment and changes only where the fish records support another value. No
PWF plan: a wording sweep, decided by Al on 2026-11-22 (code font at every mention; the link at the first). The rule
and what the sweep learned are in `CLAUDE.md`'s article notes. Text the methodology article prints from its bundle
keeps plain names until that bundle is rebuilt (#201).

## Measurement

- **Mentions marked:** 81 in prose and headings, about 20 more in captions and table text; code-font package names
  in the rendered pages went from 14 to 17 (Bayesian practice), 1 to 45 (chinook rearing), 12 to 47 (methodology)
  and 5 to 32 (stream splits). Left plain by design: the reference lists, and 37 mentions the methodology article
  prints from its bundle.
- **The text did not move.** Rendered before and after by `rmarkdown::render()`, and built by pkgdown against the
  live site (built from the same base commit): word for word the same apart from the "tuned" sentence and two
  places where a possessive that had rendered as an opening quote ("link‘s", "wet‘s") is now an apostrophe. Heading
  ids and figure alt text are the same; the only new link targets are the first-mention links.
- **Three traps the comparison found, each of which changed the work:**
  - after a code span pandoc can turn a straight apostrophe into an opening quote, so the possessive is written with
    the apostrophe itself (83 places);
  - knitr copies a caption's source, backticks and all, into a figure's alt text, so each article's setup chunk
    strips them with a `fig.cap` hook;
  - the first hook set the alt text of eight figures to the word "paste0", because knitr evaluates a caption after
    the chunk. The text comparison could not see it (it read text, not attributes); review round 1 did, and the
    comparison now covers attributes.
- **A wrong turn kept.** Table strings were first marked with `<code>` tags and `escape = FALSE` on four tables.
  Round 3 observed that a backtick renders there with the default escape (pandoc reads markdown inside HTML blocks).
  The tags and the four switches were taken out after the review, and the pages rendered identically to the
  reviewed tree, byte for byte with embedded images set aside, under both renderers. So the branch changes no
  table's escaping.
- **Review:** three rounds. Round 1: one bug (the alt text) and three fragile items, all fixed. Rounds 2 and 3:
  clean, each with its own builds; round 3 also built the search index, the sitemap and pkgdown's markdown copies at
  both commits and found only the intended differences.
- **Tests and lint:** the three test files that read the articles pass (272, 285 and 10 expectations); lint in the
  articles' chunks is the same count per file as on main.
- **Not covered:** the live site builds with pandoc 3.8.3 and pkgdown 2.2.1; every build here used pandoc 3.9.0.2
  and pkgdown 2.2.0. The first deploy is worth a look at each figure's alt text and a search for "‘s".

## Evidence

- `planning/archive/2026-11-issue-258-articles-package-names-code-font/review-round*.md`

Closed by: the PR for #258
