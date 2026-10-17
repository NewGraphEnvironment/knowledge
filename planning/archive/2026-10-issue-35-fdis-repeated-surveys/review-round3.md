# Code-check round 3 (#35): branch 35-fdis-site-visits-include-surveys-loaded

Reviewer: read-only. Probes ran in the session scratchpad (`r3/probe*.py`, `r3/spawn*.R`) against
the pre-#35 tables (`scratchpad/before/derived/`), the current `data/fdis/derived/`,
`data/fdis_repeat_surveys.csv` and the raw export. Nothing in the repo, the database or S3 was written.

## Mechanism

Rounds 1 and 2 share one assumption: **the kept copy stands for the group, and "does the kept copy
hold it" is tested on a container, not on each value.** Round 1 tested habitat as `has_habitat`
and round 2 treated ws50 codes as the kept copy's own fish rows. Both fixes repaired the container
they were found in, and the assumption is still there in three places:

- in 0230, the habitat carry and its guard check whether a habitat *record* is present, not
  whether each measured value is;
- in the filter, the twin-borrow assumes a dropped twin's row equals the kept copy's everywhere
  except the "verbatim" columns ("same placement and catch"). Habitat breaks that;
- in 0230, the maturity guard counts coded fish rather than comparing them.

## Findings

- **[bug]** scripts/0230-fdis-load.R:349-354 (donor / habitat carry) and 503-505 (`hab_lost` guard).
  The carry runs only when the kept copy has `has_habitat == FALSE`, and the guard checks the same
  thing. A kept copy that has a habitat record with no measurements in it gets nothing carried. On
  the pre-drop data, 2 pairs outside the 3 carried ones have values on the dropped copy only:
  - `7105_1_1` -> kept `30712_1_1`. The kept copy's only habitat row has temperature, conductivity
    and turbidity, and no gradient, width or bed. The dropped copy has gradient 0 %, channel width
    3.75 m, wetted width 3.75 m (n_cw_measures 6) and bed Fines. All of these are lost.
    `30712_1_1` is in `bt_use_visits` with `gradient_pct`, `channel_width_m` and `wetted_width_m`
    blank. 0291:271 (measured-gradient check) and 0293:242 (`site_gradient_class` sensitivity)
    read `gradient_pct`, and fdis_sites v2 publishes it.
  - `65749_105_1` -> kept `42509_105_1`. Water temperature 11 °C is lost (the kept copy's
    temperature is 110, removed as out of range).

  So the Enumeration's verdict, "habitat: present on the dropped copy only in 3 groups", holds at
  record level but not at value level: it is 5 pairs, and 2 are neither carried nor in the ledger.
  The guard cannot see this class. Either carry by value or by completeness (e.g. take the donor's
  record when the kept copy has no gradient and no width), or count it in the ledger as an
  accepted loss.

- **[bug]** planning/active/fdis_repeat_filter.py:82-84 and 102-106 (twin-borrow).
  `verbatim` is decided by exact string equality on every old row. readr's float round trip
  changes the last digit on some rows (`1.0833333333333335` -> `...37`; 913 rows of `wetted_width_m`
  and 420 of `area_m2` in ch_mad_visits). Every shared-name column is equal to fdis_sites
  numerically (checked to 1e-9 relative on all three tables), yet `wetted_width_m`, `area_m2` and
  `downstream_route_measure` (ch tables), and also `channel_width_m` and `mad_m3s` (bt_use), are
  judged not verbatim and keep the twin's value. For the one "now passes" case, kept
  `75709_133_1` takes twin `75734_133_1`'s row. The two copies' habitat differs, so
  `data/fdis/derived/ch_mad_visits.csv` and `ch_rule_visits.csv` now carry
  `wetted_width_m = 3.4166666666666665` (the twin's value) for `75709_133_1`. The new
  fdis_sites.csv has `1.8333333333333335`, which is what a rebuild gives.

  No analysis script reads `wetted_width_m` from these tables (0295, 0297 and 0298 do not), but
  the published v2 table is wrong on that row, and the filter does not "equal a rebuild" as it
  claims. The docstring's "(same placement and catch)" leaves out habitat, which differs in 115
  groups. Fix: compare numerically when judging verbatim, or overwrite every column that also
  appears in fdis_sites, and assert that the remaining columns cannot depend on habitat.

- **[fragile]** planning/active/fdis_repeat_filter.py:95-99 ("shared later step" assertion).
  It checks `flag_not_placed`, `flag_far_snap`, `flag_ws50_mismatch`, `flag_junk_date` and catch
  status. It leaves out the effort drop that 0290:86 and 0294:99 apply (`flag_effort_sentinel`,
  `flag_no_area`, `flag_no_effort`). Fishing time is outside the signature and differs on 36
  pairs, so copies can split on that drop. If the twin failed it while the kept copy passes, the
  kept copy belongs in the rebuilt table, but the filter would leave it out and the assertion would
  still pass. All three current twins (`77438_9_1`, `77474_55_1`, `75734_133_1`) have every effort
  flag FALSE, so today's output is unaffected. The assertion does not prove its own comment
  ("every twin passed the flag drops a copy can differ on").

- **[note, no output effect]** scripts/0230-fdis-load.R:323 (`coded_lost` / Enumeration "maturity-coded
  fish never lost"). The guard compares counts of coded fish, so a swap of codes is invisible. 3
  coded fish are held only on a dropped copy:
  - `121678_2_1` -> `121674_2_1`: species SP, IM x2;
  - `207116_2_1` -> `207102_2_1`: RB, MT x1.

  Neither is spawner evidence under 0240's rule (SP/ST, or M in Aug-Oct), and no BT/DV spawner,
  large-spawner, small-spawner or adult-size-only evidence sits on a dropped copy alone (checked
  over all 1,431 pairs). They fall inside the accepted 346 measured-fish loss, but the
  Enumeration's wording claims more than the guard proves.

## Checked and right

- The ws50 changes on kept copies: 3 now pass (`71624_9_1`, `71659_55_1`, `75709_133_1`) and 1 now
  fails (`80783_132_1`). The fails case is removed from both ch tables. `ws50_checked` never moves
  on a kept copy: in all 131 pairs that differ, the kept copy is the checked one. No visit table
  carries a ws50 column.
- `fish_ws50`: `dropped` and `kept_of` are taken from the same filter of `repeat_map`, so they
  align, and only dropped copies are re-keyed.
- The visit builders (0290, 0294, 0296) compute each visit's values independently of the others
  (per-visit DB lookups, per-WSG cuts from the network, stop-only controls). Dropping a row therefore
  equals a rebuild, apart from the twin case above.
- The other per-visit values the Enumeration lists match the data: fishing time is never present
  on the dropped copy only, and the effort sentinel, NFC conflict, area, date and pass flags never
  differ between copies.
