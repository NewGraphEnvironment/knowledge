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
