# Code-check round 1: #21 (0220 Step 2 stage/haul, NFC code, Step 3)

## Findings

- **[severity: bug]** scripts/0220-fiss-xls-parse-nfc.R:359-360 (with the pre-existing roll-up at ~372/382)
  The new `== "NFC"` arm is correct per row. But the site roll-up sets
  `nfc = any_no_fish` whenever **any** record at the site says no fish, even when other
  records at the same site caught fish. Old-edition submissions write NFC per trap or pass,
  so this change marks sites that caught fish as `nfc_source = "submitted"` in the
  no-fish-captured layer. Measured on the staged outputs: sites with `nfc == TRUE` **and** a
  non-empty `species_list` went from 88 to 124 (LNTH), 52 to 86 (UNTH), 13 to 18 (PINE) and
  60 to 64 (UPCE); 299 across the 5 groups. Example: LNTH `16841:1` (Ipsoot Creek). Minnow
  traps 1, 2, 5, 6 and 7 are NFC, traps 3, 4, 8 and 9 caught RSC (120 in trap 9), SK and
  others, and the site now reads nfc=TRUE/submitted where it read FALSE before. The logic
  that folds a mixed site into "no fish" was already there for the 2016+ "No Fish Caught"
  label (the other ~220 such sites). The NFC match widens it: every reconcile gate passes,
  and the layer gains roughly 70 more false no-fish sites. Suggested predicate: submitted
  NFC counts only when no record at the site has a non-NFC species or `total_number > 0`,
  e.g. `nfc = (any_no_fish & !any_fish) | derived`. Add a reconcile count of
  nfc & species_list != "" so the conflict can be seen.

- **[severity: fragile]** scripts/0220-fiss-xls-parse-nfc.R:103-115 (variant_map) and 123-127 (step_pat)
  This is the known workbook where a sheet matching the Step 2 pattern holds individual-fish
  columns: UNTH report `16389`, sheet "Fish collection". Its `species_code` now maps to
  `species`, so its per-fish rows pass the payload filter. That report's Step 2 rows went
  from 21 to 71, and 10 new site keys (`16389:5`, `16389:25`, ...) appear in
  `fiss_sites_unth_all.csv` (sites_all 996 to 1006). Each one has no coordinates,
  `n_records` equal to its fish count (20 at `16389:25`), a species_list, and total_number
  NA. These are individual fish stored as collection records. Because Step 3 matched no
  sheet for that report, they are also missing from `fiss_step3_fish_unth.csv`. Nothing
  flags it, and any downstream use of Step 2 rows as catch records (0250 evidence,
  `n_records`) will read one row per fish. Suggested fix: route a Step-2-named sheet whose
  header carries `length_mm`/`weight_g` and no `total_number` to Step 3, or at least count
  it in the reconcile.

- **[severity: fragile]** scripts/0220-fiss-xls-parse-nfc.R:359-360
  (unverified, low) The Step 2 species column also holds `NFP` 24 times across the 5
  groups. If that is a "no fish present" code in some edition, the exact-match `== "NFC"`
  misses it. Worth one lookup against the provincial code table before trusting the NFC
  count.

## Checked and fine
- variant_map: measured over all Step 2/3 headers in the 5 groups, no sheet carries both
  `species` and `species_code`, both `method` and `sampling_method`, or both haul variants
  (the counts sum exactly: 300+169, 378+86, 300+164). The canonical-present guard is
  never exercised and nothing is dropped.
- `n_steps <- length(step_pat)` against the 4 gathered steps: if a pattern were added
  without a gather, the parse-log row check would fail and abort. That is the safe
  direction.
- Zero-row Step 3: `gather_step` fills with character(0), so `%in%`, `sum` and `paste`
  in the new reconcile row, and `select(-any_of())`, all work on an empty frame.
- `stage` is present in all 232 Step 2 headers. The 63% NA share is real blank data, not
  a missed variant.
