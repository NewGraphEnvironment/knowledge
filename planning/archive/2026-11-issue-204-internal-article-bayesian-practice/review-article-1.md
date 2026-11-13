# Article review, round 1 (2026-11-13)

Two Plan agents, run concurrently: a blind readability reader given only the rendered text, and a meaning audit
against research/bayesian_alignment.md, the code, the book pages and issues #203, #186 and #70.

## Readability (blind)
Took away the right message. Lost on: terms before their definitions (base rate, close calls, sampling terms,
`link`, scorer/curve, gate, fold, grade); "never predicts one"; why the refit flatters equally; "twice" in the gate;
deviance never named, so the table's numbers had no unit; the summary table before its vocabulary, with opaque
verdicts and rows missing for the unseen level, effort and inputs; the Gelman quote reads garbled; the ecology quote
restates its sentence. Done: "What does the tuning do?" now defines scorer, sampling terms, base rate, score
(deviance), folds, close calls, curve, grade and gate, and comes before the table; the table has one set of verdicts
(follows the books / departs, defensibly / departs / should change) and 16 rows, the missing three included; the
pooling, refit and gate sentences rewritten; the table's columns named and its caption gives the sign; the Gelman
quote cut to its clear clause (still checked on p. 182); the ecology quote cut to a citation (n_quotes 6 to 5);
`link` in code font throughout; the grade section folded into pooling. Kept: "Software and citation" (writing.md asks
for it).

## Meaning audit (15 findings, all taken)
1 1-SE and pick verdict "differs" in research: now "departs". 2 unseen-level row added. 3 "does not test it" ->
"does not fully hold its test data out". 4 "three ways" -> "three main departures". 5 effort: free slope lets the
chance grow more or less than in proportion (p. 357's hypothesis), not "level off". 6 "a regularising prior". 7
BDA3 p. 416: Cauchy, logistic coefficients, every coefficient but the constant; our scale named cloglog. 8 the curve
fits "at most" the scorer's groups (R/tune_curve.R:82-85 drops sites with no size or slope first; verified). 9 #186:
both curves scored both ways, chinook and WCT rearing only. 10 #70's two steps separated. 11 the commit and date
are the bundle's and the run's summaries'. 12 flattering "by our reasoning (not measured)". 13 penalised splines
named in BDA3, the library's scale in neither. 14 "three fixes" for #203, and the fallback guard explained in the
prior section. 15 "against no habitat definition".

The quote check flagged `link`'s after the code font: the blanked code span left the apostrophe after a space.
Inline code is now blanked with letters; both files pass and a planted stray quote still fails.
