# Review round 3 — no-data encodings in the FDIS load (0230) and evidence (0240)

Reviewer: code-check round 3, 2026-09-26. Diff `main...HEAD`. Probes in the session scratchpad
(`p1.R`–`p8.R`), run against the cached raw CSVs, `data/fdis/build/*.rds` and
`data/fdis/derived/fdis_sites.csv` as they stand on disk.

## Mechanism

Confirmed, with one refinement. FDIS has no single no-data convention: each field carries its
own (empty, `0`, a 9s-sentinel whose width varies by field — `9999`, `9999.9`, `99999`, `990` —
and pseudo-species codes). The scripts decide "is this a real value" **inline, per field, at the
point of use**, and each predicate was written from the **one** encoding seen for that field:
`n >= 99999` for counts, `< 500` for widths, `> 100` for gradient, `== "NFC"` for zero catch,
`zone %in% 7:11` for UTM. Every sibling encoding one digit shorter, or spelled differently,
passes the predicate as a value.

The refinement — a second arm that R1–R2 did not name: where a sentinel **is** caught, it is
nulled to `NA`, and `NA` is later `coalesce(..., 0)`'d (0230:194 `n_caught = pmax(coalesce(n_counted, 0), n_measured)`),
so "count not known" becomes "zero caught". Unknown → NA → 0 is the same defect as R1's NFC
(an absence marker read as a value), running the other way.

## Enumeration (every raw field 0230/0240 read)

Counts measured over the raw files (visits 62,892 rows; habitat 26,565; counts 114,217;
2022 details 341,607).

| field | encodings found | handling | leak? |
|---|---|---|---|
| visits.UTM_ZONE | 1,084 empty; 4 × `0` | `flag_no_utm` if NA or not 7–11 | n |
| visits.UTM_EASTING | 1,084 empty; 6 × `0` | only NA flagged; `0` with a valid zone passes | **y** (F4) |
| visits.UTM_NORTHING | 1,084 empty; 5 × `0`; max 9,594,573 | only NA flagged; outliers fail to snap (500 m) | n (0 placed with northing > 7e6) |
| visits.IN_DATE | no unparsable; years 0200–1007 (6); 34 × `01-01` | year outside 1950–2022 → `flag_junk_date` | n (01-01 feeds only `month`, and M-in-Aug–Oct cannot fire on Jan) |
| visits.FISHING_TIME | 2,689 empty; 8 × `0`; **20 × `9999`** | NA/≤0 → `flag_no_effort`; 9999 summed as seconds | **y** (F3) |
| visits.FISHING_AREA_LENGTH | 4,770 empty; 8 × `0`; **10 × `9999.9`** | multiplied into area, max'd into `fished_length_m` | **y** (F3) |
| visits.FISHING_AREA_WIDTH | 7,570 empty; 37 × `0`; **76 × `9999.9`, 18 × `9999`** | multiplied into area; ≤0 → `flag_no_area` | **y** (F3) |
| habitat.GRADIENT11/12 | empty; 937/612 × `0`; `990`; `110`, `110.2`, `120`; `100` (2) | `mean_ok(hi=100.0001)`; 0 kept unless `form_blank` | n* (see note) |
| habitat.GRADIENT21/22 | empty; 235/97 × `0`; `140` | same | n |
| habitat.CHANNELWIDTH1–7 | empty; `0` (1–251); `9999`; 500–700 | `mean_ok` keeps `0 < v < 500` | n |
| habitat.WETTEDWIDTH1–7 | empty; `0` (176–254); `999` (5); `99999` | same | n |
| habitat.WATER_TEMPERATURE | 559 empty; 14 × `0`; 50–556 (26 rows) | `num()` then `med()`, no range check | **y** (F5) |
| habitat.DOMINANT_BED_MATERIAL | `Not Specified` (19), `Not Applicable (same as Dominant)` (3) | `first(na.omit())` — text placeholders are not NA | y, categorical only (11 + 1 sites carry the placeholder as `bed_dominant`); not a number, noted not listed |
| counts.SPECIES_CODE | `NFC` 26,584; **`ZZZ` "No Fish Caught (BC Lakes Pre-1996)" 1**; **`SP` "Fish Unidentified Species" 626**; `ANODON` mussel 3 | only `NFC` is an absence marker; every other code is a species | **y** (F2, F6) |
| counts.NUMBER_CAUGHT | `0` 26,605 (21 non-NFC); **`9999` 23**; `99999` 48 | `>= 99999` → NA; then NA → 0 in `n_caught` | **y** (F1, F7) |
| counts.MINIMUM/MAXIMUM_LENGTH | 65,7xx empty; `0` 129/122; `99999` | `min()`/`max()` with `is.finite` only | **y** (F8) |
| details.SPECIES_CODE | `NFC` 139; `SP` 767; hybrids | `is_nfc`; hybrids into `char` | n for the fish table itself (SP enters via counts — F6) |
| details.LENGTH | 5,413 empty; 16 × `0`; `99999`, `10000`, `1100`, `1500` | `len > 0` for classes; `flag_no_length` | n — every ≥ 1000 mm row is non-focal; focal max is BT 906 mm; 6 CH × `0` go to `unmeasured` correctly |
| details.WEIGHT | 159,654 empty; 810 × `0` | read, never used in an output | n |
| details.MATURITY_CODE | 198,972 empty; `U` 69,276 | spawner = SP/ST or M Aug–Oct; check uses IM/SP/ST only | n |
| details.NEW_WATERSHED_CODE | never empty; all 45 digits; **mainstem-only codes** `XXX-000000-…` (e.g. `230-…` 89,101 fish rows) | any code in the xref can "contradict" the snap | **y** (F9) |

\* Gradient note (not a finding): 644 non-blank rows have one of GRADIENT11/12 = `0` and the
other > 0 — mostly `(0, 1)` 223 and `(1, 0)` 115, but also `(0, 12)` ×4. Whether that `0` is an
unfilled second slot or a reading cannot be told from the data; R1 decided 0 is real and these
follow that decision. Worth a line in `research/fdis_export.md`, not a fix.

## Findings (leaks only)

### F1 — `NUMBER_CAUGHT = 9999` is a sentinel the 99999 threshold misses (0230:48, 0230:160)
23 count rows are exactly 9999 (CT 13, CO 6, RB 4); no other value between 5,500 and 99,999
recurs. They pass `n >= count_sentinel` and are summed as fish.
- `reconcile.csv` `counts_fish_total` = 1,220,790 carries 23 × 9,999 = 229,977 of it (**19 %**);
  `counts_sentinel_rows` reports 48 and should be 71.
- `fdis_sites.csv` `n_caught_all` = 9999 at 20 site visits (all `species_caught = CT` or similar).
- Focal columns are unaffected (no CH/BT/DV row is 9999).
Fix: treat `>= 9999` (or `%in% c(9999, 99999)`) as the sentinel; there is no count between
5,500 and 9,999 to lose.

### F2 — `ZZZ` is a second no-fish-caught code (0230:178, 0230:199–200)
`counts.SPECIES` for `ZZZ` is "No Fish Caught (BC Lakes Pre-1996)". The code tests only
`== "NFC"`, so site visit `65646_2_1` gets a catch row `ZZZ` with n 0, `any_nfc = FALSE`,
`catch_status = "unknown"`, `species_caught = "ZZZ"`. One site; it should be `zero`.
Fix: one vector of absence codes (`c("NFC", "ZZZ")`) used at every `"NFC"` test (0230:173,
178, 199, 200, 282).

### F3 — effort sentinels summed into effort (0230:85–86, 99–101)
`FISHING_TIME` 9999 (20 passes), `FISHING_AREA_WIDTH` 9999.9/9999 (94 passes),
`FISHING_AREA_LENGTH` 9999.9 (10) are not filtered. In `fdis_sites.csv`: 130 site visits with
`area_m2 >= 99,990` (max 399,992,000 m²), 80 with `fishing_time_s >= 9999` (17 of them an exact
multiple of 9999), 5 with `fished_length_m >= 9999`. None is flagged — `flag_no_area` /
`flag_no_effort` test only NA and ≤ 0. Any CPUE/density a consumer computes from the site table
is wrong at those sites. Not used in 0240's summary.
Fix: NA the 9s-sentinels per pass before summing, and flag.

### F4 — easting `0` with a valid zone is placed on the network (0230:109)
`flag_no_utm` checks the zone range and NA only. `73455_7_1` (zone 11, easting 0, northing
5,436,335) snaps to Holyoak Creek, COWN, 404 m — a Vancouver Island location for a zone-11
record. It is `catch_status = zero`, placed, not junk-dated, so it is one CH-absent and one
char-absent site in `fdis_summary_ch_bt.csv` (summary does not filter `flag_far_snap`). One site.
Fix: add `utm_easting <= 0 | utm_northing <= 0` to `flag_no_utm`.

### F5 — water temperature has no range check (0230:137, 146)
26 habitat rows are 50–556 °C (likely °F or a keying error); 23 site visits carry
`water_temp_c > 40` in `fdis_sites.csv` (50, 55, 60 ×2, 70 ×2, 80 ×3, 90 ×4, 102, 110, 112,
126, 130, 213, 276 ×3, 556). Site table only.
Fix: NA above a plausible ceiling (e.g. 30 °C) and flag.

### F6 — `SP` "Fish Unidentified Species" counts as a known non-focal catch, so absence is asserted (0240:158–169)
`SP` is a pseudo-species code: fish were caught but not identified. It makes
`catch_status = "fish"` (correct) but also makes the visit a known-catch site for **absence**
of CH and char. Usable site visits with an `SP` row: 494 (105 of them SP only, SP n up to 713).
Of those, **467 are counted CH-absent and 404 char-absent** in `fdis_summary_ch_bt.csv`
(0.9 % of 49,499 CH-absent; 0.9 % of 43,830 char-absent — but 404 is 6 % of the 7,042 char
presence sites, the population the absence is compared against). Unidentified fish can be CH or
char, so absence at those sites is not known. `ANODON` (a mussel) likewise makes 1 site "fish".
Fix: exclude visits whose catch includes an unidentified code from the absence set (or at least
flag them); don't count non-fish codes toward `n_caught_all`.

### F7 — a caught sentinel becomes zero: "count unknown" → NA → 0 (0230:161, 194)
The 48 `99999` rows are NA'd, then `n_caught = pmax(coalesce(n_counted, 0), n_measured)`
turns them into 0. Effect: 37 species-at-visit pairs recorded as caught (some with lengths)
get `n_caught = 0`, across 34 site visits; **30 of those visits land in
`catch_status = "unknown"`** instead of `fish` (the other 4 have other species and stay `fish`,
with the sentinel species — all non-focal — silently absent). **4 unknown visits are CH**
(`63675_33_1`, `63676_31_1`, `63676_32_1`, `63697_313_1`, the last with min length 25 mm), all
placed and with a good date: CH presence is dropped from `n_ch` and from `present_any_size` in
`fdis_summary_ch_bt.csv` (1,373 → 1,377). A focal sentinel at a visit with other species would be
asserted **absent**; none does today, so the damage is the lost presence, not a false absence.
Fix: presence should not depend on the count — a row for species X at a visit means X present,
whatever `NUMBER_CAUGHT` holds. Carry `present = TRUE` separately from `n_caught`.
(Related, same arm: 21 non-NFC rows with `NUMBER_CAUGHT = 0` — 7 of them sole rows at their
visit — are zero-catch records spelled as a species with n 0; they land in `unknown`. Small.)

### F8 — `MINIMUM/MAXIMUM_LENGTH = 0` passes into evidence (0230:182–183, 190)
`is.finite()` keeps `0`. `data/fdis_evidence.csv` (tracked) has 4 rows with `min_length_mm = 0`
and 1 with `max_length_mm = 0` for focal species. `99999` in these fields is non-focal today, so
it does not reach the evidence file, but nothing stops it.
Fix: NA `<= 0` and `>= 9999` before `min()`/`max()`.

### F9 — basin-mainstem 50k codes flag correct placements as mismatches (0230:254–277)
Many FDIS records carry only the mainstem level of the 50k code (`230-000000-00000-…`, the Peace
mainstem, 89,101 fish rows; `300-…` Fraser, `235-…`, …) — a truncated code, not a stream
identity. `ws50_known` is TRUE for these (the xref has the mainstem, 51 blue_line_keys for 230),
so a site correctly placed on a tributary is flagged. Measured: **1,320 of the 2,701
`flag_ws50_mismatch` sites** carry only a mainstem-level code; 1,195 of those snap to order < 6
streams (Beaver, Billy, Sullivan, Lynx Creek … — named tributaries, i.e. the snap is plausibly
right and the code is the placeholder), 927 of them on `230`. This inflates
`sites_ws50_mismatch` in `reconcile.csv` and marks ~half the flagged rows in
`fdis_evidence.csv` wrongly. Confidence: medium — I did not complete a distance-to-coded-mainstem
probe (too slow on the full FWA join); the stream-order split is the evidence. Either way the
check cannot discriminate with a mainstem-only code.
Fix: treat a code whose only non-zero segment is the first (or whose trailing segments are all
zero below the level the snap sits at) as uninformative: `ws50_checked = FALSE` for it, or test
ancestry (the snapped stream's FWA code descends from the coded one) instead of equality.

## Not findings (checked, clean)
- Width sentinels (9999, 99999, 999, 500–700) all excluded by `< 500`; zero widths excluded.
- Gradient 990/110/120/140 excluded by `hi = 100.0001`; no site ends at 100 %.
- CH length 0 (6 fish) → `unmeasured`, not fry (R1's fix holds).
- Maturity blanks/`U` never reach spawner or maturity-check logic.
- Junk years all flagged; 01-01 dates cannot trigger the Aug–Oct spawner rule.

/Users/airvine/Projects/repo/knowledge/planning/active/review-round3.md
