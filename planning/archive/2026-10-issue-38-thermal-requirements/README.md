# #38 — Thermal requirements by species and life stage

## Outcome

The evidence table can now say which statistic a temperature value is (`metric`), hold degree-day totals
(`degree_days`, with the accumulation window as the metric and the base temperature in the note), and keep
air temperatures, the IP models' proxy for water, apart (`air_temperature`). The 56 existing temperature rows
were migrated: 14 were air, 21 give no statistic (`unstated`). `0270` gained `--collection`, which built
`Fisheries/temperature` (48 items) and the `temperature` store. `0280` gained a thermal grid of 5 species ×
10 cells, every cell met by a value or a `none` row. Two drafters wrote 163 rows (BT, WCT, CH, CO, ST, plus
Colorado River cutthroat as `CRCT`), and two meaning-audit rounds followed. The settled verdict is in
[`research/thermal_requirements.md`](../../../research/thermal_requirements.md). No source read gives a
growing-season degree-day requirement for any BC species: the only thresholds are Coleman & Fausch's, for
Colorado cutthroat.

What was learned:
- **About a quarter of the "temperature" rows were air.** Planning found this, and code-check round 1 found
  two more (the Weiss rows).
- **The memo links had died.** The two stream-temperature memos' `/f/` links now serve an empty page. Their
  PDFs were printed from the `/analyses/` pages.
- **Bear et al. 2005/2007 (WCT thermal tolerance) could not be obtained.** They are the likeliest unread
  source of WCT degree-days.

## Measurement

- Evidence table: 510 → 674 rows. Gate: 0 failing quotes; the IP coverage grid 48/48; the thermal grid 0/50 →
  12/50 after the migration (BT and CH water limits; CO's rearing limits had all been air) → 50/50.
- Of the 20 degree-day cells, 3 have a value for a grid species: BT and CH to hatch, WCT to emergence. 17 are
  `none`. Among temperature-limit cells, only CO rearing lower has no value: its one value (Bjornn & Reiser's
  1.7 °C) OCRs as "17".
- Meaning audit: round 1 found 6 errors in 49 trout and char rows, and 13 in 22 of 114 salmon and steelhead
  rows, plus one missed value. Round 2 found one error inside a round-1 fix: Sauter Table 4 is observed
  temperatures, so `dist`, which round 1 had changed to `expert`. It also found the classes round 1 had
  missed: measured results still coded `expert`, and a DAT label that Sauter calls assumed. The audit ended by
  enumeration: every same-source, same-page group with mixed kind or metric is mixed by its own sentences.
  This repeats #29's lesson that the gate checks words, not meaning: every quote had verified before either
  round.
- Code: code-check round 1 found the Weiss air rows. Round 2 found the planning counts stale after that fix,
  and a metric accepted on rows with no value. Round 3 found the grid relying on `qual` rows having no value,
  which nothing enforced. Each round ended by enumeration. The first ended on 36 variable × kind × metric
  cases against the documented rule, all agreeing. The last ended on the four reader invariants `meets()`
  needs, all enforced.
- Stores: `temperature`, 38 documents and 7,892 chunks; `habitat_modelling` rebuilt, 207 → 220 documents. Both
  were pushed and verify on a fresh connect.

## Evidence

- Gate log: `scripts/logs/habitat/20261006_literature_verify*`.
- Collection, store build and push: `scripts/logs/habitat/20261006_{temperature,habitat}_*`.
- Drafts, reviews and audits: this directory. `draft-*-evidence.csv` are the drafters' output before the
  audit fixes; the table supersedes them.

Closed by: PR (see `gh pr list --search 38`)
