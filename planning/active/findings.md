# Findings — Anchoring check: report the pick from each starting point beside the best-scoring rule (#141)

## Issue context

**If done:** every tuned key reports how much its starting point chose its pick: the pick from link's `default`, the pick from link's flow version and the region's best-scoring rule, side by side. A baseline review then has a "before" and an "after" to compare, and the keys whose baseline steers most get reviewed first. **If never:** a baseline's influence on a published rule stays invisible, and rebuilding a baseline (#140) cannot show what it changed.

## Problem

The pick is the region rule with the fewest departures from link's `default` (`R/tune_score.R`, `.tune_pick()`), so the starting point can decide which of several near-equal rules is published (#139, #120). #80 added a second starting point, link's flow version (`pick_flow`, `recommended_flow`), but nothing reports the two picks beside the rule the data score best, or says when they differ.

## Proposed

- [ ] Per key, in the tune summary and `pick_report.csv`: the pick from `default`, the pick from link's flow version, and the region's best-scoring rule, each with its score and SE behind the best, and a flag where they are not one rule.
- [ ] Count departures between the three (size test, gradient, exception), so "how far the start moved the pick" is a number, not a reading.
- [ ] Run it on the current candidate and the published tables (no retune: the scores are already there), and keep grayling rearing's result as the "before" for #140.
- [ ] Tests: a fixture where the best rule and the pick differ, and one where they agree.

First in the order #139 sets (Al, 2026-11-03): this check, then each species' literature, then its register rows. Relates to #139 (the baseline register), #140 (grayling's baseline, read against this "before"), #80 (the flow starting point), #120 (where the anchoring showed).

## Errors Encountered

| Error | Resolution |
|-------|------------|
