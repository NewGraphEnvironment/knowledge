# Code-check enumeration — 0220 (ends the loop after round 2 found defects inside round-1 fixes)

Mechanism behind round 2's findings: (a) a check whose two sides come from the same predicate,
so it cannot fire; (b) a routing condition narrower than the case it exists for.

## (a) Every reconcile check this diff adds or changes

| check | expected side from | actual side from | gate? | can fire? |
|---|---|---|---|---|
| parse_log_rows_vs_steps_per_workbook | `length(step_pat)` x workbooks | rows `gather_step()` wrote | yes | yes: a pattern with no gather call |
| workbooks_unopenable_since_fetch (`%/% n_steps`) | 0 | sheets_error rows / steps | yes | unchanged logic, divisor now derived |
| fish_layout_sheets_read_as_step3 | Step 2 parse-log rows with `fish_layout` | Step 3 parse-log rows `ok` on the same path+sheet | yes | **proven**: fallback disabled -> 1 vs 0, run stopped (LNTH) |
| step3_fish_without_step1_site | — | Step 3 keys vs Step 1 keys | no (count) | n/a |
| nfc_conflict_sites | — | count | no | n/a |
| nfc_sites_listing_a_species | — | nfc vs `species_list` (not `caught`) | no | n/a; replaced the tautological `nfc_sites_with_species_caught` |

## (b) Every routing branch this diff adds

| branch | condition | measured population |
|---|---|---|
| variant renames (7) | rename only if canonical absent | no sheet in 5 groups has both names (round 1 tabulated) |
| Step 2 `fish_layout` | `length_mm` present, `total_number` absent | 2 sheets (UNTH 16389, LNTH 16393); both read by Step 3 |
| Step 3 fallback | Step 3 sheet missing OR not ok OR 0 rows | covers the empty-template case round 2 raised |
| the converse (Step 2 layout under a Step 3 name) | none | 0 of 4 Step 3 header editions carry `total_number` (plan-mode probe) |

Set sizes: 6 checks, 4 branches. Nothing above its source of truth; loop ends here.
