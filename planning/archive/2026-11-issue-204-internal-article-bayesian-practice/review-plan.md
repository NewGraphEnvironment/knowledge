# Plan review — #204 (Plan agent, spawned 2026-11-13T07:45:33Z)

Findings as reported, with what was done about each.

- **G1 navbar (confirmed).** pkgdown 2.2.0's `navbar_articles()` adds "More articles..." when any section lacks
  `navbar:`; the internal section does. Probed: the branch's menu carried the link. Fixed: `_pkgdown.yml` writes the
  Articles menu out (`navbar: components: articles:`), and the rendered menu HTML is byte-identical to main's.
  `tests/testthat/test-pkgdown-navbar.R` holds the menu to the sections (fails on a stale menu, checked by mutation);
  `yaml` added to Suggests.
- **G2 CLAUDE.md.** Three more stale places: the "three articles are one series" layout entry, the record section's
  "`vignette_method.R` ... not at all" on the gate fields, and the promotion pins list. Folded into Phase 4.
- **G3 pending work.** writing.md bars issue links for unfinished work; the issue asks for "what is tested next".
  Recorded as a gate decision: an exception for this internal article, which is a record of where the method is heading.
- **G4 "rule".** Added a grep for `\brules?\b` outside code to Validation; glossary definitions used for "fish habitat
  definition" and "close call".
- **G5 quote check.** Took the simpler route the review names: widen the quote regex to accept `[@key, p. N]`, hold a
  `n_quotes` per file, run the coverage tables only for the research file, strip fenced chunks before the proximity
  guard, and write a named log for the article.
- **Ordering.** The bib rerun left the three existing `.bib` files unchanged (checked). The quote check runs after
  the meaning audit's fixes.
- **A1.** The rebuild was not "identical but date and commit": `where` paths of three keys, settings.csv's md5 and a
  new WCT summary md5 moved too (findings.md says so; the plan's line is corrected).
- **A2 (confirmed in R/tune_run.R:290-292).** A fitted key whose curve failed has NA deviances and grade_withheld
  FALSE, so `anyNA` would stop a promotion, and recomputing the flag from the CSV's rounded deviances could disagree
  at a tie. Fixed: the script and test require only the group counts and the flag, allow NA deviances in pairs, and
  never recompute the flag; the article marks such a key "no curve". The test no longer names WCT.
- **A3.** "Not listed" is the site's index and navbar only: the article is in sitemap.xml, the site search and the
  installed package's vignette index. Stated in the gate decision.
- **Q4.** As G5.
