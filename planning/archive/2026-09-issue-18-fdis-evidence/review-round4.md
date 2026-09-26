# /code-check round 4 — review of 91e5921 (no-data table, presence apart from counts)

Scope: `scripts/0230-fdis-load.R`, `scripts/0240-fdis-evidence.R` at HEAD. Probes were run against
`data/fdis/build/*.rds`, `data/fdis/derived/fdis_sites.csv`, the raw `data/fdis/2020-11-16/*.csv`
and local fwapg (5432). The probe scripts are in the session scratchpad (p1–p3.R).

## R4-1 (real, wrong numbers): the mainstem filter also drops level-1 codes, which do discriminate (0230:278–281)

The filter is `substr(code, 10, 45) != strrep("0", 36)`. The 45-digit code is 3 (major) + 7×6, so
digits 4–9 are the first tributary level. The filter drops the mainstem-only `XXX-000000-…` codes
that F9 targeted. It also drops every **level-1 code** (`100-235900-000000-…`,
`920-257700-…`), which names a real stream. The research doc and F9 both describe the target as
`230-000000-…`, so the filter does more than it was meant to.

Measured per site against the xref, by the shallowest code level the site carries:

| code level | sites | mismatches (known code, snap not in xref) | mismatch rate |
|---|---:|---:|---:|
| L0 `XXX-000000-…` | 4,208 | 1,221 of ~4,200 known | ~29 % |
| L1 `XXX-NNNNNN-000000-…` | 3,496 | 486 of ~3,370 known | ~14 % |
| deeper | 9,133 | 858 of ~7,800 known | ~11 % |

L1 codes behave like deeper codes, not like L0, so they are real placement checks. Of the drop in
`sites_ws50_checked` (16,986 → 9,148), 3,496 sites are these. That also removes 486 genuine
`flag_ws50_mismatch` flags from `fdis_sites.csv` and `fdis_evidence.csv`.

Fix: test digits 4–45: `substr(watershed_code_50k, 4, 45) != strrep("0", 42)`. Fix the comment
too ("first 3").

## R4-2 (real): unidentified codes other than `SP` still assert absence (0230:53 `unid_codes`)

`whse_fish.species_cd` defines several group codes that cannot rule out a focal species. None of
them is in `unid_codes`. The counts are usable sites without `SP` where 0240 asserts absence:

| code | meaning | usable sites | CH absent asserted | char absent asserted |
|---|---|---:|---:|---:|
| `SA` | Salmon (General) | 37 | 36 | — |
| `SLV` | Char, General | 2 | — | 2 |
| `AF` | All Fish | 2 | 2 | 0 |
| `TR` | Unidentifiable Trout, fry < 70 mm | 511 | — | 402 (judgement call: juvenile BT/DV are called "trout") |

- `SA` should block CH absence, `SLV` should block char absence, and `AF` should block both.
- `SLV` is arguably char **presence**, but `char_codes` in 0240:36 omits it.
- `TR` is the user's call. It affects 402 char-absent sites, so it is the largest effect here.

Blocking per group, rather than with one flag for every group, keeps `SA` from blocking a char
absence.

## R4-3 (real): a zero-count species row now counts as a catch and as presence (0230:233, 0240:124)

The raw `counts.csv` holds species rows with `NUMBER_CAUGHT = 0`, beyond the 26,583 NFC rows:
RB 7, SDC 4, BT 2, DV 2, WCT 2, and 1 each of BB, CAS, EB, LSU. These rows are "none of this
species". Now that `any_catch` and `presence` depend only on a `catch` row existing, they become
"fish".

- There are 12 catch pairs with `n_caught == 0`. At 7 sites that pair is the whole catch: 103987_4_1,
  110276_36_1, 110278_38_1, 110279_39_1, 110281_40_1, 113616_12_1, 130599_34_1, 65483_102_1,
  87379_1_1 (one of these has other rows).
- Each of those sites is `catch_status = "fish"` with `n_caught_all = 0`. Before this commit they
  were zero or unknown.
- **113616_12_1 has only a `DV 0` row.** It gets `present_char = TRUE` with `n_char = 0`, so it
  enters the char `present_any_size` row of `fdis_summary_ch_bt.csv`. That is a false presence.

Fix: in the counts branch of `catch`, drop rows whose non-sentinel count is 0 and that have no
measured fish. Or make presence require `n_counted > 0 | n_measured > 0 | flag_count_sentinel`.

## R4-4 (minor, real): a sentinel-only catch still shows `n_caught_all = 0` (0230:227)

`sum(n_caught, na.rm = TRUE)` returns 0 at sites whose only counts are sentinels. In
`fdis_sites.csv`, 57 sites are `catch_status == "fish"` with `n_caught_all == 0`. About 50 of them
are sentinel-driven; the rest are R4-3. At site level this is the same "unknown count reads as none
caught" that the commit fixed per pair.

Fix: make it NA when any `n_caught` at the site is NA, or when all of them are.

## R4-5 (minor, real): CH presence from a sentinel count leaves no row in `fdis_evidence.csv` (0240:103–108)

For the `unmeasured` rows, `n = pmax(n_caught - n_measured, 0) + …` is NA when `n_caught` is NA,
and `filter(n > 0)` then drops the row. There are 4 CH site-visits with a sentinel count, and none
of them has any CH row in `fdis_evidence.csv` (probe: 0 of 4). The header says evidence "stands
alone for presence", so those 4 presences are missing from it. The summary still has them, because
it reads `present_CH`.

Fix: keep NA rows (`filter(is.na(n) | n > 0)`).

## Checked and clean

- `nodata(hi = sentinel_min - 1e-9)`: the raw `FISHING_TIME` has no value above 9999, and legit
  values run to 9995. There are 20 values at exactly 9999, which reads as a sentinel. Length and
  width have no legit values of 9999 or more. The cut is fine.
- UTM ranges: placed northings run from 5,335,030 to 6,653,857, and none of them is excluded.
  South BC is about 5.35 M and 60° N is about 6.65 M, so 5.2e6–6.8e6 covers the province.
  `NA | TRUE` short-circuits the NA comparisons correctly.
- Focal `across(if_else(is.na & site_visit %in% focal$site_visit …))`: within `focal`, NA arises
  only from sentinel counts. `values_fill = 0` covers the absent columns. The logic is right.
- `n_char` NA propagation: 0 occurrences.
- `present_CH` implies `catch_status == "fish"`: 0 violations.
- A site whose only catch is `SP` is "fish" and has absence blocked. That is correct.
- The reconcile `stop()`s have consistent filters on both sides (nonfish and zero-catch exclusions
  match). None of them can pass wrongly given this diff.
