# Code-check review, round 2 (#36, groundwater variable)

Scope: the staged `pkg/` diff (literature.R, test-literature.R, NEWS.md, DESCRIPTION,
knw_literature_vocab.Rd), focused on what round 1 did not check.

## Clean

No issues found in the diff.

What was checked:

- **Roxygen claim "a groundwater row carries no value", for every kind.** True. A value with
  no unit fails `no_unit`; a value with any unit fails `misfit` (fits is `character(0)`); an
  `MM-DD` unit fails `unit_bad` first; a `qual` value fails `qual_value`; a `none` value fails
  the none check. No kind gets past. A `metric` on a groundwater row is `stray`.
- **Man page matches the roxygen** (same three lines, regenerated).
- **NEWS / DESCRIPTION consistent**: both 0.3.1; no prose restatement of the package version
  elsewhere in the repo (`0.3.0` hits in CLAUDE.md, scripts/README.md and 0150 are about `cred`).
- **Docs enumerating the variable vocabulary**: none found. CLAUDE.md, scripts/README.md,
  research/*.md and pkg/ (no README, no vignettes) name individual variables
  (`temperature`, `air_temperature`, `degree_days`) only in the context of `metric`, which
  groundwater does not take, so none is now incomplete.
- **Tests run green** from a temp copy (`test-literature.R`, 85 expectations), and the
  staged `data/literature_evidence.csv` reads: 9 groundwater rows, all `qual`
  (7 spawning, 2 incubation), none with a unit.
- **Fixture reach**: fixture row 1 has `metric = NA`, so the groundwater test is not
  short-circuited by `stray`; the `dist` + value assertion reaches `misfit`.

## Not a finding (planned, outside the pkg diff)

- `research/bt_spawning.md:69` still says "The evidence vocabulary has no groundwater
  variable (#36), so some of these statements are not recorded". Now stale, but it is the
  first item of the plan's Phase 3, so it is tracked. No stale "(the vocabulary has no
  groundwater variable)" note remains in the CSV.
