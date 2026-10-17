# Code-check round 2 — branch 35-fdis-site-visits-include-surveys-loaded

Scope: the branch diff (base d54341a) with round 1's fixes (7d24f7d, 891e757): scripts/0230, 0293–0299,
planning/active/fdis_repeat_filter.py, CLAUDE.md, README.md, scripts/README.md, data/fdis_README.md;
outputs on disk (data/fdis_repeat_surveys.csv, data/fdis/build/*.rds, data/fdis/derived/*.csv), compared
with the pre-#35 copies in the session scratchpad (`before/derived/`).

## Findings

- **[severity: bug]** scripts/0230-fdis-load.R:396-399 (the `ws50` placement check, run after the repeat
  drop at :365-368) — the 50k watershed codes sit on fish rows, so a dropped copy's codes leave with it,
  the same way its habitat did before round 1's fix. The repeat signature and `fsig` leave out
  `watershed_code_50k`, so two copies can hold "identical measured fish" with different codes. Then the
  survey's `flag_ws50_mismatch` depends only on the tie-break (lowest collection id). Within one visit the
  rule is `ws50_match = any(hit)`, so pooled across the copies these surveys would pass. Measured (old
  fdis_sites.csv rows of the dropped copies against the new rows of the kept copies):
  - 5 surveys go from a match on the dropped copy to a mismatch on the kept one: `232907_7_1`->`226329_7_1`
    (PCEA, 16 BT), `75734_133_1`->`75709_133_1` (MAHD, 22 RB), `57222_68_1`->`54367_68_1`,
    `77438_9_1`->`71624_9_1` and `77474_55_1`->`71659_55_1`. Every one has `fish_same = TRUE`, and in each
    the dropped copy is the higher id.
  - 0290 and 0294 drop `flag_ws50_mismatch` visits. So the PCEA survey (16 BT) leaves bt_use_visits and the
    MAHD survey leaves ch_mad_visits and ch_rule_visits, though a copy of each was in the pre-#35 tables and
    passed. The filter script copies this, as a rebuild would.
  - 2 surveys go the other way (`90856_132_1`->`80783_132_1`, `80769_36_1`->`90843_36_1`). There the code
    that contradicted the snap leaves, which the `any()` rule would have overruled anyway.

  No ledger row, map column or guard reports any of this, unlike habitat (`repeat_habitat_carried_to_kept`,
  the `hab_lost` stop). Fix options:
  - run the ws50 check on every group member's fish codes: remap a dropped `site_visit` to its
    `kept_site_visit` in the fish rows before the drop, and feed those codes to `ws50` only (leave `fish.rds`
    as is);
  - or rank a codes match into the keep order;
  - at the least, add a ledger row and a map column (`ws50_same`).

  Other cases are fine as they are: 16 groups where the dropped copy had no checkable code and the kept
  copy mismatches (for example the KLUM `72421_1_1` group, which also leaves both tables) only gain
  evidence. Their exit is correct.

## Checked and not a problem

- Other per-visit fields against the kept copy (old rows of all 1,431 dropped copies against the new kept
  rows, every fdis_sites column):
  - Fishing time differs on 36 copies, but no dropped copy has a time where the kept one has none.
  - `flag_effort_sentinel`, `flag_no_effort`, `flag_no_area`, placement (`linear_feature_id`,
    `distance_to_stream`, `flag_far_snap`), date and `data_set` never differ.
  - `agency` differs on 44, the loader of each id. That is a fact of the data, and 0295's
    `sens_largest_project_out` and 0293's `without_top_two_agencies` read it as given.
  - No dropped copy has habitat where its kept copy has none (0 of 1,431 after the carry).
- Measured fish: in 13 groups a dropped copy holds measured fish that the kept copy lacks. That is 76 fish
  at most, counted per group at the maximum over the dropped copies. One example is `97132_91_1`: 66 fish,
  including RSC, against the kept copy's 117. This follows from the keep rule ("most measured fish") and
  sits inside `repeat_groups_fish_differ` (114). That row also counts groups where the kept copy is a
  superset, so it does not say how many fish leave. It is informational, not a defect.
- Round 1's habitat fix:
  - `donor` takes the best-ranked dropped copy, since `rep_cand` is still in keep order after `ungroup()`
    and `filter()`.
  - The `cols_habitat` names match `hab_site` plus `has_habitat`, and the filter script's list is the same.
  - The `hab_lost` guard reads post-carry `sites`, so it would stop if the carry were removed.
  - The 3 carried kept rows in ch_mad_visits and ch_rule_visits take their `wetted_width_m` from the new
    fdis_sites.csv in the same text form R writes, with NA as `""`, matching the other 12,006 empty cells.
  - No derived column in 0294 or 0296 (`cw_deploy`, `cw_model` and so on) reads FDIS habitat, so nothing
    else would change on a rebuild.
- fdis_repeat_filter.py:
  - The 17,745 distinct walk starts in ch_rule_visits equal those in ch_rule_walks, both ways.
  - ch_mad_visits and ch_rule_visits keep identical `site_visit` order.
  - Where the kept copy was absent from the old table but its dropped copy was present (3 per table), the
    kept copy carries `flag_ws50_mismatch = TRUE`, so a rebuild would exclude it too. The filter therefore
    equals a rebuild; the loss is the finding above.
- 0299:
  - The REPUBLISH guard sits before any upload, and fails toward refusal: an arrow version change that
    alters Parquet bytes refuses rather than overwrites.
  - The `changed` check still covers added and removed tables.
  - PULL of v2 writes `data/fdis/derived/fdis_repeat_surveys.csv`, not the tracked
    `data/fdis_repeat_surveys.csv`.
- No `dup_of`, `first_copy`, `v_dup` or `res$dup` remains in scripts/. The research/chinook_* files still
  cite "#35's 507 duplicates" and a "duplicates kept" sensitivity. The plan's research phases are open, so
  that is expected for now.

Verdict: 1 bug (ws50 evidence leaves with a dropped copy; 5 surveys flagged as mismatched by the
tie-break, 2 of them leaving the BT or CH visit tables), unreported in the ledger or the map.
