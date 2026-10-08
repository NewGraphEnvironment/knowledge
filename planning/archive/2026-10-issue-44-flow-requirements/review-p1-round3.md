# Review: #44 Phase 1 staged diff, round 3

## Findings

- **[severity: fragile]** `data/literature_evidence.csv` data rows 497 and 498 (file lines 498 and 499), with
  `scripts/0280-literature-verify.R:323`. These two BT spawning `velocity` rows (Hagen & Weber 2019, 0.14-0.52 and
  0.65 `m/s`) were converted from a quote that says "velocities average 14-52 cm/s and are typically 65 cm/s or
  less". The new roxygen (`pkg/R/literature.R:47-50`) says depth and velocity are kept "in the unit the source
  wrote", and `cm/s` is now in the vocabulary, so both rows contradict the rule this diff documents.
  - **Mechanism.** The rule now lives in two places that disagree. The vocabulary and roxygen say "as written".
    0280's `SCALE` still carries `"m/s" = c(1, 0.01)`, the old convert-to-SI path. The gate therefore accepts a
    converted velocity: I simulated it, and a `0.65 m/s` row passes against a `65 cm/s` quote. It rejects a
    converted depth: a `0.24 m` row fails against a `24 cm` quote, because `m` scales only x1000. So "as written"
    is enforced for depth and not for velocity.
  - **Where it reaches.**
    - Rows 497 and 498 today.
    - Any Phase 2 velocity row drafted in `m/s` from a cm/s or HSI source, which will pass silently.
    - Hagen & Weber's depth clause in the same sentence ("Depths at redd locations average 24-58 cm"; #33 dropped
      it because cm could not verify) can now be added in `cm`. One quote would then be coded in two unit
      conventions, against the CLAUDE.md rule that rows from one table or page are coded alike.
  - **Why it matters.** `meets()` ignores units, so cell counts are unaffected. But any reader of
    `knw_literature_read(variable = "velocity")` that compares values gets mixed `m/s` and `cm/s` with no signal.
  - **Fix options.** Recode 497 and 498 to `cm/s` (14, 52, 65), or state in the roxygen that velocity may be
    converted to `m/s`. Either way, drop or keep the `m/s` x0.01 rescale to match.

No other defects.

## What was checked (evidence, not findings)

- **Staged tree.** Copied with `git checkout-index` to the scratchpad. `devtools::test("pkg", filter = "literature")`
  runs with no failures.
- **The real table reads.** `knw_literature_read("data/literature_evidence.csv")` reads 686 rows: 44 `discharge`, 1
  `instream_flow`, 3 `depth` (all `m bankfull`), 3 `velocity` (2 `m/s`, 1 `qual`).
  - No existing row trips either new guard. In the full parameter × variable table, `spawn_mad_min` (11),
    `rear_mad_min` (17) and `rear_mad_max` (3) all sit on `discharge`, and every other parameter sits on the
    variable its name implies.
- **Other stream-size depth or velocity rows still in `m` or `m/s`.** None. The only depth rows are the three
  Sloat rows, now `m bankfull`. Row 407 (Cooney & Holzer NHD mean annual velocity) is stream size, but it is `qual`
  with no unit or value.
- **`vocab$unit` against the union of `fits`.** The two sets are equal in both directions, with nothing orphaned.
- **0280 `value_in_quote()`.** I sourced the script's own `clean`, `tokens`, `SCALE`, `quote_numbers` and
  `value_in_quote` (lines 165-177 and 318-362) and ran them over every non-`none` row of the staged table: 0
  failures. The Sloat rows pass at `m bankfull` scale 1, because `>0.5` tokenises to `0.5`.
- **New units through `SCALE`.** `SCALE[[unit]]` is an exact `[[` lookup, so no new unit inherits another's
  rescale. Results of the simulation:
  - `cm`, `ft`, `cm/s`, `ft/s` and `percent MAD` verify only the value as written.
  - `percent MAD` from a "0.2 MAD" quote fails closed. Plan item G9 adds `c(1, 100)` in Phase 3.
  - "2000 MAD" for 20 fails.
  - `m3/s` from "1m3/sec" passes, because the exponent strip leaves 1.
  - `cfs` passes as written.
- **`grepl("_mad_", parameter)`.** `parameter` is a closed vocabulary, and only the three MAD parameters contain
  `_mad_`. `grepl` on `NA` is `FALSE`, so blank parameters are not flagged. `variable` is required, so
  `!= "discharge"` never meets `NA`.
- **Guard order.** An `instream_flow` row with a MAD parameter hits the `modelled` stop first, which is the right
  message. In the new tests, removing either guard leaves the corresponding read passing, so each `expect_error`
  pins a guard: the fixture's row 1 carries `spawn_gradient_max`, and its row 3 is `channel_width`.
- **The staged log.** `scripts/logs/habitat/20261007_literature_verify.csv` differs only at row 121, where the
  variable and metric changed. The Sloat unit change is not visible there because the log has no unit column, and
  the simulation above shows their status is unchanged.

## Notes, not defects

1. **`m bankfull` under `depth` relies on every consumer filtering by unit.** `knw_literature_read(variable =
   "depth")` returns bankfull channel depths mixed with site depths. Nothing counts `depth` today, but the Phase 3
   FLOW `meets()` must exclude `unit == "m bankfull"`. `task_plan.md:74` says so. It is the one place B1's
   mechanism can come back.
2. **Pre-existing, outside this diff.** `SCALE$m = c(1, 1e3)` exists for `bridge_distance` (km to m), but it is
   keyed by unit alone, so it also lets a `depth`, `elevation` or `channel_width` row in `m` verify at 1000 times
   the quoted number. Simulated: a `500 m` depth passes against "0.5 m". This is low risk (a typo-level error) and
   is not new.
3. **Roxygen lines 7-8.** "US units (`cfs`, `mi2`, `ft`) are kept as the source wrote them" does not list `ft/s`.
   This is wording only.
