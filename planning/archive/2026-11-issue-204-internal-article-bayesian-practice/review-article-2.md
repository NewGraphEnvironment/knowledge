# Article review, round 2 (2026-11-13): the fixes

A Plan agent read round 1's fixes (git diff 96d744f2..524d8a9d) against the research file, the code and the pages.

1. **Effort, an error inside round 1's fix.** Under the cloglog the chance of a catch is 1 - exp(-c·area) even with
   an offset, so it never grows in proportion to area and already levels off; the offset holds the catch *rate* per
   square metre constant, and the free slope lets that rate change with area. Checked the algebra (hazard ∝ area^b).
   Fixed in the article (table question and answer, bullet) and in research/bayesian_alignment.md, whose
   `log_area_free` row had the same slip and whose L231 "lets detection saturate" was ambiguous.
2. The prior-scale row's question, answer and verdict: now "a regularising prior at BDA's default scale", with the
   three departures in the answer.
3. The score's definition contradicted the refit; now "sites in watershed groups left out when the habitat
   definition, effort and sampling terms were fitted", with the refit flagged.
4. Close calls defined by the one-SE width, not "the records cannot rank".
5. The fallback: fires when the fast fit would drop a term the full fit keeps, not on a fit that fails.
6. "Each watershed group the scorer keeps"; "every stream with a size and slope"; guards now ensure the gate
   publishes some key and that the closest call does not print as 0.0.

Checked fine by the agent: the other 14 verdicts, "three should change", "three main departures", the gate's
sides, "any improvement publishes", "at most the groups", "more than half", the withheld keys, BDA3 p. 416, #186, #70.
