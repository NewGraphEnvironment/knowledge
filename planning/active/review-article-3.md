# Article review, round 3 (2026-11-13): round 2's fixes

Four findings, two inside round 2's fixes, all taken:
1. Close calls read as "one SE of the best" (the SE the p. 227 quote warns against): now "one standard error of their
   difference from the best" (`.tune_sel`, R/tune_score.R:447-452).
2. The grade: only streams the species can reach (R/grade_species.R:143-144), with a size and a slope.
3. Table row on effort slipped between chance and rate: now "Is the catch rate per square metre the same however much
   area is fished?".
4. The research file cited the audit for a fisheries claim: now "(our expectation, not tested)".
5. A left-out group's base rate is "fitted", not "refitted", in the definition.
Also a guard tying the caption's sign to the gate flag, away from ties the summary's rounding could blur (mutation:
flipping one flag fails it).
Checked correct: the effort algebra in article and research, p. 357's use, score and base rate, the prior row, the
fallback sentence, and every guard on today's bundle.
