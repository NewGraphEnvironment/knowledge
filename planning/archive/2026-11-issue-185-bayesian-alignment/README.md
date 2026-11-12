## Outcome

The tuning method was read against McElreath's *Statistical Rethinking* (2nd ed.) and Gelman et al.'s *Bayesian
Data Analysis* (3rd ed.), searched through the `statistics` store and confirmed on the printed page, and written up as
[`research/bayesian_alignment.md`](../../../research/bayesian_alignment.md): every pipeline step (11), setting (69)
and method choice with no settings key (19) marked aligned, differs, should change or no bearing. The core stands:
whole watershed groups held out, the SE of a difference over groups, near-ties kept as a region, a regularising
prior at BDA3's scale, groups pooled in the curve. It differs where defensible: the held-out score is a plug-in
conditional on each group's refit intercept (ranking within a group, not prediction for a new one), the scorer's
groups are fixed and those with one outcome dropped, effort is a free covariate, a miss reads as an absence. Three
things should change: the curve's unseen-level handling and the nested check that is not nested (#203), and the
outcome-dependent gradient (#70). Follow-ups filed: #203, #204 (the methodology article's section); #186's body
rewritten so the pooled curve is scored both ways and keeps the one-outcome groups. Learned along the way: the issue's
starter table was wrong in three places (effort is not an offset, the curve already pools, the gate withholds on a
tie), and the plan's own claim that the score is −2 × lppd was wrong (the plan review's blocker).

## Measurement

- The scorer drops every group whose visits hold one outcome: chinook rearing scores 45 of the 111 groups its visits
  fall in, steelhead rearing 11 of 78, westslope cutthroat rearing 6 of 14 (`data/tune/<key>_summary.csv`, run
  `20261104_0543`). This turned #186's thin-key argument into a number and added "keep those groups" to its scope.
- Unseen sampling levels touch one scorer visit in the published run (westslope cutthroat rearing), none in six keys;
  the curve's own count is not recorded (#203's first measurement). One visit moves a gate by at most 55.3 in
  deviance, within reach of bull trout spawning (withheld by 0.56) and grayling rearing (published by 14.4).
- The fallback that would drop the prior cannot be reached through the penalised terms (each has a pseudo-row): a
  claimed "should change" retracted by audit round 1 after a probe through `.tune_glm_fe()` with and without the ridge.
- The quote check went through three designs before it held: one detector, then a loose and a strict detector
  compared by count (a strict match paid for a bad quote elsewhere on the line), then an enumeration of citations
  that looked only backwards. It holds by enumerating every page citation (76) against every quote mark left after
  checked passages are blanked (20; nearest 268 characters), with the quote count pinned (23). Each failed design and
  the probes that broke it are in `review-round1.md`–`review-round3.md`.
- Meaning audits: round 1 found 23 errors or overstatements, round 2 errors inside four of round 1's fixes, round 3
  one error inside round 2's (blocking codes are loose names for the species itself, not related species). Each
  round's findings and dispositions are in `review-audit-1.md`–`review-audit-3.md`.

## Evidence

`scripts/logs/habitat/*_bayesian_alignment_check.txt`

Closed by: PR (to be opened from branch `185-read-the-tuning-method-against-statistic`)
