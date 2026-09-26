## Findings

- **[bug]** scripts/0230-fdis-load.R:166-174, 188, 193-195 — `NFC` rows in the 2022 fish table are counted as fish. The `species_code != "NFC"` filter is applied to `counts` only; the fish table carries 139 `NFC` rows (137 with no length, 2 with length 1). They reach `catch` as `species_code == "NFC"` with `n_measured > 0`, so `n_caught_all > 0` and the site becomes `catch_status = "fish"`. They also go into `fish_keys`, so an NFC count row and an NFC detail row on the same pass flag a conflict. Measured against the current build:
  - **81** site visits are `fish` although their only catch is NFC. 70 of those also carry NFC in `counts`, so they should be `zero`; 68 are placed and have valid dates.
  - `sites_nfc_conflict` is inflated. Recomputing at KEY level without NFC detail rows gives 64 conflict sites, against 165 with them (the build reports 157 after the site join).
  - `species_caught` contains `"NFC"` on 105 sites, and `n_species` is inflated to match.
  - `fish_no_length` includes the 137 no-length NFC rows.

  `data/fdis_summary_ch_bt.csv` is **not** affected: CH and char absence tests `n_ch == 0` / `n_char == 0`, and those sites are "usable" under either status. The things that are wrong are `catch_status`, `n_caught_all`, `species_caught` and `flag_nfc_conflict` in `fdis_sites.{csv,gpkg}` (pushed to S3), and the reconcile rows `sites_catch_fish`, `sites_catch_zero` and `sites_nfc_conflict` (plus the committed log). Fix: drop `species_code == "NFC"` from `fish` before the `count()` at line 174 and before `fish_keys`, or treat an NFC detail row as NFC.

- **[bug]** scripts/0230-fdis-load.R:70, 123-124 — `mean_ok()` keeps only `v > 0`, so a recorded gradient of 0 % is discarded as missing. `habitat.csv` has 937 `GRADIENT11 == 0`, and 366 rows with both 11 and 12 equal to 0. Measured effect at site level:
  - **390** site visits get `gradient_pct = NA` where it should be 0.
  - **620** more get a biased-high value, because a 0 is dropped from the mean.

  Nothing flags this and the design notes do not mention it (sentinels are only `> 100`). The CH/char "present" rows barely move (CH: 143 vs 147 sites with gradient, share above spawn max 0.266 vs 0.259). Most of the loss falls on the `absent` rows and on the site table's `gradient_pct`, which link#284 consumes directly. Zero is a legitimate low-gradient value for gradient, unlike width. Use `v >= 0` for the gradient columns, or flag zeros explicitly if they are believed to be a no-data code.

- **[bug]** scripts/0240-fdis-evidence.R:67, 71 — a fish with `length_mm == 0` is classified into the first class (`len >= 0`), although 0230:162 defines `length_mm <= 0` as "no length". The tiling guard deliberately skips `len > 0`, so it cannot see this. Six CH fish have length 0 (sites 102480_3_1, 102483_6_1, 132248_1_1, 132212_1_1, 132222_1_1, 132267_1_1). They land in `CH fry` in `data/fdis_evidence.csv` and the fry summary row, and they are also left out of the `unmeasured` count (`n_nolength` only counts `is.na(size_class)`). Require `len > 0` in the `hit` test.

- **[fragile]** data/fdis_size_breaks.csv:8 (CH older_juvenile `basis`) — the quoted counts match neither source. The row says "17 of 4,765 measured CH >= 120 mm, 3 >= 145 mm". The 2022 fish table that 0230 actually uses has 5,587 measured CH (length > 0), 18 at 120 mm or more and 4 at 145 mm or more. The 2020 `details.csv` has 4,769 / 18 / 4. `research/fdis_export.md` line 91 ("2 CH >= 150 mm") is correct. `planning/active/findings.md:88` carries the same stale 4,765 / 17. This is a wrong number in a tracked deliverable, so re-derive it from `fish.rds`.

Checked and clean:
- No join fan-out in `catch`, `placed` (`stopifnot` holds; `channel_width` and `discharge` are 1:1 on `linear_feature_id`), `evidence`, `summ` or `ws_check`.
- Empty-group `first(na.omit())` returns NA.
- All-NA date `min()` resolves to NA via `is.finite`.
- The ws50 codes are 45 characters on both sides.
- The `fwa_indexpoint` argument order is right.
- The `basin` `integer64` array parameter works: all 51,455 placed sites got `fwa_basin`.
- The unmeasured arithmetic is correct apart from the length-0 case above.
- The research table numbers match the CSV.
- `cw_comparable` is 3,820, as stated.

/Users/airvine/Projects/repo/knowledge/planning/active/review-round1.md
