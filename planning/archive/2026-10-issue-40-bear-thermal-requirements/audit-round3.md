# Meaning audit round 3 and code-check round 1 (2026-10-11)

Meaning round 3 (Plan-type reader) on the round-2 fixes: six findings, five inside round-2 work.

| # | finding | disposition |
|---|---|---|
| 1 | the report's LD50 regressions pool all experiments (Figs. 6, 8); "analyses the third WCT and second RB experiment" holds only for its growth and survival curves | fixed in notes and findings.md |
| 2 | the 2007 7-d values are the day-7 LT50 points of Fig. 2 (p. 1116), not readings off its fitted curve | fixed |
| 3 | "60-d UUILTs are the same estimates" claims too much: only the survival-curve values are shared | fixed in notes, research and findings.md |
| 4 | the field-association notes asserted a period average | fixed: the page does not say which |
| 5 | findings.md's `lab` precedent was survival optima, not growth optima | fixed |
| 6 | eight `pref` rows from #38 are stated or reviewed optima, contradicting the round-2 `pref` gloss | gloss restored to match them: measured optima `lab`, stated or reviewed optima `pref` |

Code-check round 1 (general-purpose reviewer, `review-round1.md`): one fragile finding, the same as meaning #6, from
the code side. Everything else checked clean: only the intended lines changed, the rows reproduce byte for byte
from `draft_rows.py`, `knw_literature_read()` accepts the table, `0270` handles both `pdf` values, every
cross-reference resolves, nothing private committed.

## Code-check round 2, with the enumeration (`review-round2.md`)

Mechanism, as the reviewer put it: p. 9's methods sentence ("only the third WCT and second RB experiment are
reported") was applied to every result. It was corrected only where a figure caption named its experiments, so
Fig. 5 (whose caption names none) was never counted against p. 8's 12 temperatures per experiment.

Enumeration: all 128 sentences in the notes of the touched rows (`claims-enumeration.tsv`), each checked against its
page by point counts and arithmetic rather than captions. 118 were `ok`. 10 were wrong, all of them the shared
2005 method sentence on six rows (two clauses each, less the growth rows' correct satiation clause), plus two
findings.md sentences. Two were fragile: the paper's satiation claim conflicts with the report on pooled survival
data, and the degree-sign sentence was left out of the list (true on every row that has it).

Fix: the method sentence is split. The growth rows (data rows 1088, 1091) say third or second experiment and
satiation. The survival rows (1082–1085) say every experiment pooled, including the earlier fixed rations. The paper's
survival rows (1071, 1072) now say the two sources disagree on ration. I checked each citation in the new
sentences against the text (p. 8, 12 temperatures; p. 9, fixed ration and satiation; p. 11, 16 temperatures;
Figs. 1, 2, 5, 6 and 8 on pp. 23, 24, 27, 28 and 30). The loop ends on this enumeration: every claim in the set has
a verdict, and every wrong one is fixed and re-checked.
