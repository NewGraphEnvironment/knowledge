# Code-check round 2: #21 (0220 Step 2 stage/haul, NFC roll-up fix, Step 3 fallback)

## Findings

- **[severity: fragile]** scripts/0220-fiss-xls-parse-nfc.R:601 (with 402 and 415)
  The new gate `nfc_sites_with_species_caught` (expected 0) cannot fire. `nfc` is defined as
  `!any_caught & ...` and `species_caught` is `species[caught]`, so any site with nfc TRUE has
  no caught row and therefore an empty `species_caught`, whatever the data is. The gate reads the
  predicate back against itself. It shows 0 in all 5 groups, and it would still show 0 if `caught`
  were wrong, for example if a real species code were ever added to the zero_catch set, or if
  `is_no_fish` matched too widely. Round 1 suggested counting `nfc & species_list != ""`, which
  is independent of `caught`. That count is not 0 by design (explicit zeros like LNTH 23268 "RB, 0"),
  so it needs to be a visible count (`pass = TRUE`) rather than a gate. As written, the round-1
  bug class has no working guard. The only protection is the predicate itself.

- **[severity: fragile]** scripts/0220-fiss-xls-parse-nfc.R:245-259
  Step 2 drops a fish-layout sheet (`return(done("fish_layout"))`), and the header comment says
  "its rows are read as Step 3 instead". That only holds when **no** sheet name matches the Step 3
  pattern, because the fallback is gated on `is.na(sh)`. A workbook that carries a template-shipped
  empty "Step 3" / "Individual Fish Data" sheet next to a per-fish sheet under a Step 2 name would
  have Step 3 read the empty sheet (`no_rows`) and Step 2 return `fish_layout`. Its fish would then
  be in neither output, and the only trace would be a status string in the parse log. No reconcile
  row checks this. Today both instances (UNTH 16389, LNTH 16393) have no Step 3 sheet and fall back
  correctly (71 and 94 fish), so nothing is lost now. The fix fails toward silent loss on the next
  workbook with that layout. Cheap guard: for every report with step2 status `fish_layout`, assert
  that its step3 row has `status == "ok"` and `sheet_matched` equal to the Step 2 sheet (expected 0
  violations). Or run the fallback whenever the matched Step 3 sheet yields no rows.

## Checked and fine
- Roll-up flips measured against main (`fiss_sites_<wsg>_all.csv`):
  - TRUE->FALSE: LNTH 88, UNTH 52, PINE 13, UPCE 60, COTR 7. These are the mixed sites from round 1.
  - FALSE->TRUE: LNTH 54, UNTH 48, PINE 67, UPCE 123, COTR 5. All are `submitted`, and the samples
    are NFC-code-only sites (e.g. LNTH 12300:1, PINE 17032:11). This is the intended new arm, not a
    regression.
- Sites removed from sites_all: UNTH 7 (16389:*) and LNTH 2 (16393:*). These were the per-fish rows
  that had been standing in as collection records. Neither report has a Step 1 sheet, so the sites
  had no coordinates. Their fish now show up in `step3_fish_without_step1_site` (94 LNTH, 296 UNTH
  including 16845), so the loss is visible.
- `caught` / `any_caught`: NA species and NA counts give FALSE. A non-numeric count with a species
  gives TRUE, which is the conservative direction (blocks nfc). A NFC row with a count is not
  caught. `na.rm` on `any()` is harmless.
- `zero_catch_codes`: `data/fdis_species_codes.csv` is tracked, the codes are uppercase (NFC, ZZZ),
  and the script reads it by relative path like every other path in the script. The repo-root run
  convention covers it. The `stopifnot` guards an empty set.
- New variants (`species_code`, `method`, `haul_*`, `date_yyyy_mm_day`) keep the rename guard for
  when the canonical name is already present. None of the targets collides with a wanted column of
  a different step.
- `nfc_source` / `nfc_conflict` are NA-safe for sites with no Step 2 (`%in% TRUE`, `na.rm = TRUE`).
- Parse-log shape: 4 rows per workbook in every group, so the `n_steps` check holds.

/Users/airvine/Projects/repo/knowledge/planning/active/review-round2.md
