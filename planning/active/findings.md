# Findings — Compare only default and the reported structure unless asked (#112)

## Issue context

## Problem

`0330` regenerates link's flags under every structure a key has, though the tables, maps and thresholds report only
`door` (`TUNED_AS`): four rules for CH, CO and ST (`default`, `free`, `door`, `door_wetland`), three for BT rearing, RB and
WCT, two for BT spawning and GR. Classify, overlay and connect was 164 of #92's 269 comparison minutes
(`scripts/logs/habitat/20261027_compare.txt`).

The other structures feed two sentences of the methodology article: `free` and `door` "differ by under 0.01 in the ratio
and by under 1 point in either FDIS share", and `door_wetland` puts outside detections for CH and CO beyond that spread.

## Proposed

1. **Measure first.** Time each rule's three stages on one four-rule key (CH) and on BT rearing, so the saving is a
   number before anything changes (#101 makes the same estimate for `default`).
2. **If it pays:** `0330` runs `default` and the reported structure by default, and `STRUCTURES=all` adds `free` and
   `door_wetland`.
3. **The article's two sentences** either read the last promoted run that carried every structure, guarded on its
   tables, or are dropped. **Operator's decision.**

## Acceptance

- The measured minutes are in `research/database_builds.md`.
- A default `0330` regenerates two rules per key; `STRUCTURES=all` gives tables identical row for row to today's on one
  key.

Related: #73 (the structures), #101, #81.

## Exploration (2026-10-28)

- `knw_compare_rules()` already takes `structures =`; `0330` never passes it, so every key runs `.knw_compare_structures()`'s
  full set.
- The outside-check bootstrap draws one `idx` per iteration whatever the rule count, so dropping rules leaves `door`'s
  intervals unchanged under the same seed.
- #92's stage times (`scripts/logs/habitat/20261027_compare.txt`, remote link): classify, overlay and connect sum to
  164.3 min across keys; CH 31.7 min on 4 rules (near-river walks 57.0 min summed over 6 workers).
- This machine (m4) reaches the database at 63 ms per round trip; schemas `fresh_default` and `fresh_default_20261017`
  both present (2026-10-28).
- Readers of non-reported structures: the chinook article (`wl_free`), research prose on #92's run, `settings.csv`'s
  `tuned_as` note. Nothing else.

## Errors Encountered

| Error | Resolution |
|-------|------------|
